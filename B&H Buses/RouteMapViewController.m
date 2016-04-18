//
//  RouteMapViewController.m
//  B&H Buses
//
//  Created by Tom Pullen on 18/04/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import "RouteMapViewController.h"
#import "BusStopAnnotation.h"
#import "Stop.h"
#import "Route.h"

@interface RouteMapViewController ()

@property (strong, nonatomic) MKPolyline *polyline;
@property (strong, nonatomic) MKPolylineView *lineView;

@property (strong, nonatomic) MKPolylineRenderer *lineViewRenderer;
@property (strong, nonatomic) NSMutableArray *coreDataStops;

@end

@implementation RouteMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    
    [self getStopsFromCoreData];
    [self drawLine];
}

#pragma mark - Helper Methods

- (void)getStopsFromCoreData {
        
    // If we've managed to get the context, proceed
    if (self.context) {
            
        self.coreDataStops = [[Stop getStopsFromCoreForRoute:self.route.routeName withID:self.route.routeID withContext:self.context] mutableCopy];
            
        // If we receive an empty array (not nil!) then get the routes from the file and reload the table
        if (self.coreDataStops && ![self.coreDataStops count]) {
            NSLog(@"Oops");
        }
        // Else if we received the routes, reload the table to show them!
        else if (self.coreDataStops && [self.coreDataStops count]) {
            
            [self zoomMapToStops];
            
            for (Stop *stop in self.coreDataStops) {
                
                CLLocationCoordinate2D poiCoodinates;
                poiCoodinates.latitude = [stop.latitude doubleValue];
                poiCoodinates.longitude= [stop.longitude doubleValue];
                
                BusStopAnnotation *pin = [[BusStopAnnotation alloc] init];
                pin.coordinate = poiCoodinates;
                pin.title = stop.stopName;
                pin.subtitle = [Route getRouteNumbersForStopID:stop.stopID withContext:self.context];
                pin.stop = stop;
                [self.mapView addAnnotation:pin];
            }
            NSLog(@"%lu", (unsigned long)[self.coreDataStops count]);
        }
        else if (!self.coreDataStops) {
            NSLog(@"Unable to fetch routes from Core Data.");
        }
        
    }
    else {
        NSLog(@"Context failed to intialise.");
    }
}

- (void)zoomMapToStops {
    
    Stop *firstStop = [self.coreDataStops firstObject];
    Stop *lastStop = [self.coreDataStops lastObject];
    Stop *midStop = self.coreDataStops[[self.coreDataStops count] / 2];
    
    
    CLLocation *firstStopLocation = [[CLLocation alloc] initWithLatitude:[firstStop.latitude doubleValue] longitude:[firstStop.longitude doubleValue]];
    CLLocation *midStopLocation = [[CLLocation alloc] initWithLatitude:[midStop.latitude doubleValue] longitude:[midStop.longitude doubleValue]];
    CLLocation *lastStopLocation = [[CLLocation alloc] initWithLatitude:[lastStop.latitude doubleValue] longitude:[lastStop.longitude doubleValue]];
    
    CLLocationDistance firstStopDistance = [midStopLocation distanceFromLocation:firstStopLocation];
    CLLocationDistance lastStopDistance = [midStopLocation distanceFromLocation:lastStopLocation];
    CLLocationDistance distanceToUse = firstStopDistance > lastStopDistance ? firstStopDistance : lastStopDistance;
    
    NSLog(@"First Stop Distance: %f Last Stop Distance: %f", firstStopDistance, lastStopDistance);
    
    // Zoom to a region based on the furthest nearest stop
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(midStopLocation.coordinate, distanceToUse * 3, distanceToUse * 3);
    
    [self.mapView setRegion:viewRegion animated:YES];
    
}

- (void)drawLine {
    
    // Remove polyline if one exists
    [self.mapView removeOverlay:self.polyline];
    
    // Create an array of coordinates from the stops' co-ordinates
    CLLocationCoordinate2D coordinates[self.coreDataStops.count];
    int i = 0;
    for (Stop *stop in self.coreDataStops) {
        CLLocationCoordinate2D coord;
        coord.latitude = [stop.latitude doubleValue];
        coord.longitude = [stop.longitude doubleValue];
        coordinates[i] = coord;
        i++;
    }
    
    // Create a polyline with all of the co-oridnates
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinates count:self.coreDataStops.count];
    [self.mapView addOverlay:polyline];
    self.polyline = polyline;
    
    // Create an MKPolylineRenderer for the map view overlay
    self.lineViewRenderer = [[MKPolylineRenderer alloc] initWithPolyline:self.polyline];
    self.lineViewRenderer.strokeColor = [UIColor redColor];
    self.lineViewRenderer.lineWidth = 5;
    
}

#pragma mark - Map View Delegate Methods

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    return  self.lineViewRenderer;
}

@end
