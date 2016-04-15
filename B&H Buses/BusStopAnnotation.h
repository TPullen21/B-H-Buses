//
//  BusStopAnnotation.h
//  B&H Buses
//
//  Created by Tom Pullen on 15/04/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Stop.h"

@interface BusStopAnnotation : MKPointAnnotation

@property (strong, nonatomic) Stop *stop;

@end
