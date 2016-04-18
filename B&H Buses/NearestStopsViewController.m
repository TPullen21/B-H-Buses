//
//  NearestStopsViewController.m
//  B&H Buses
//
//  Created by Tom Pullen on 08/04/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import "NearestStopsViewController.h"
#import "DepartureTimesViewController.h"
#import "BusStopAnnotation.h"
#import "Stop.h"
#import "Route.h"
#import "CDRoute.h"

@interface NearestStopsViewController ()

@property (strong, nonatomic) NSMutableArray *allStops;
@property (strong, nonatomic) NSArray *nearestStops;
@property (strong, nonatomic) Stop *selectedStop;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *latestLocation;

@end

@implementation NearestStopsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.mapView.delegate = self;
    
    // Initiate request for user's location and for updates on their location
    [self startStandardUpdates];
    
    // Get all the stops from Core Data
    [self getStopsFromCoreData];
    
    self.mapView.showsUserLocation = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table View Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of feed items (initially 0)
    return self.nearestStops.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Retrieve re-usable cell
    NSString *cellIdentifier = @"StopsCell";
    UITableViewCell *myCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Get the stop for this cell row
    Stop *stop = self.nearestStops[indexPath.row];
    
    myCell.textLabel.text = stop.stopName;
    
    return myCell;
}

-(void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    self.selectedStop = self.nearestStops[indexPath.row];
    
    [self performSegueWithIdentifier:@"showNearestStopsDepartureTimesViewController" sender:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.destinationViewController isKindOfClass:[DepartureTimesViewController class]]) {
        
        DepartureTimesViewController *departureTimesVC = segue.destinationViewController;
        
        departureTimesVC.stop = self.selectedStop;
        departureTimesVC.animateZoom = NO;
    }
}

#pragma mark - CLLocationManager Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation* location = [locations lastObject];
    
    self.latestLocation = location;
    
    [self getNearestStopsWithLocation:location];
    
    [self.tableView reloadData];
}

#pragma mark - Helper Methods

- (void)startStandardUpdates {
    
    // Request permission to access user's location - will only prompt if we have no access
    [self.locationManager requestWhenInUseAuthorization];
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    // Set a movement threshold for new events
    self.locationManager.distanceFilter = 500; // Meters
    
    [self.locationManager startUpdatingLocation];
}

- (void)getStopsFromCoreData {
    
    NSArray *cdStops = [Stop getAllCDStopsWithContext:self.context];
    
    // 'Convert' the core data stop objects to stop objects
    for (CDStop *cdStop in cdStops) {
        [self.allStops addObject:[[Stop alloc] initWithCDStop:cdStop]];
    }
    
    if (self.latestLocation != nil) {
        [self getNearestStopsWithLocation:self.latestLocation];
        
        // Reload the table view
        [self.tableView reloadData];
    }
}

- (void)getNearestStopsWithLocation:(CLLocation *)location {
    
    self.nearestStops = [[NSMutableArray alloc] init];
    
    // Find out the distance of every stop from the user's current location, and assign the distance to each stop
    for (Stop *stop in self.allStops) {
        
        CLLocation *stopLocation = [[CLLocation alloc] initWithLatitude:[stop.latitude doubleValue] longitude:[stop.longitude doubleValue]];
        
        CLLocationDistance distance = [location distanceFromLocation:stopLocation];
        
        stop.distance = distance;
    }
    
    // Sort the array of stops using the distance field we've just populated
    NSArray *sortedStops = [self.allStops sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = [[NSNumber alloc] initWithDouble:((Stop *)a).distance];
        NSNumber *second = [[NSNumber alloc] initWithDouble:((Stop *)b).distance];
        return  [first compare:second];
    }];
    
    NSArray *nearestStops = [sortedStops subarrayWithRange:NSMakeRange(0, 15)];
    
    // Get the furthest nearest stop we'll be showing, as well as the location of it
    Stop *furthestStopToShow = [nearestStops lastObject];
    CLLocation *furthestStopLocation = [[CLLocation alloc] initWithLatitude:[furthestStopToShow.latitude doubleValue] longitude:[furthestStopToShow.longitude doubleValue]];
    
    // Zoom to a region based on the furthest nearest stop
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(furthestStopLocation.coordinate, furthestStopToShow.distance, furthestStopToShow.distance);
    
    [self.mapView setRegion:viewRegion animated:YES];
    
    // For every nearest stop, plot a pin of its location
    for (Stop *stop in nearestStops) {
        
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
    
    self.nearestStops = nearestStops;
    
}

#pragma mark - MKMapViewDelegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    NSString *reuseId = @"pin";
    
    MKAnnotationView *pinView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    
    if (pinView == nil) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        pinView.canShowCallout = true;
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton titleForState:UIControlStateNormal];
        
        pinView.rightCalloutAccessoryView = rightButton;
    }
    else {
        pinView.annotation = annotation;
    }
    
    return pinView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    if (control == view.rightCalloutAccessoryView) {
        BusStopAnnotation *annotation = view.annotation;
        self.selectedStop = annotation.stop;
        [self performSegueWithIdentifier:@"showNearestStopsDepartureTimesViewController" sender:nil];
    }
}

#pragma mark - Lazy Instantiation

- (NSArray *)nearestStops {
    
    if (!_nearestStops) {
        _nearestStops = [[NSArray alloc] init];
    }
    
    return _nearestStops;
}

- (NSMutableArray *)allStops {
    
    if (!_allStops) {
        _allStops = [[NSMutableArray alloc] init];
    }
    
    return _allStops;
}

- (CLLocationManager *)locationManager {
    
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    
    return _locationManager;
}

@end
