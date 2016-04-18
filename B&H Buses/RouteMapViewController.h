//
//  RouteMapViewController.h
//  B&H Buses
//
//  Created by Tom Pullen on 18/04/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Route.h"

@interface RouteMapViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSManagedObjectContext *context;

@property (strong, nonatomic) Route *route;

@end
