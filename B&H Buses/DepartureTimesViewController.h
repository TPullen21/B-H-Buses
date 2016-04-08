//
//  DepartureTimesViewController.h
//  B&H Buses
//
//  Created by Tom Pullen on 08/04/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import "HTTPGetRequest.h"
#import "CDStop.h"

@interface DepartureTimesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, HTTPGetRequestProtocol>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) CDStop *stop;

@end
