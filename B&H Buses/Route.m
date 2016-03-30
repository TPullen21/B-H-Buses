//
//  Route.m
//  B&H Buses
//
//  Created by Tom Pullen on 29/02/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import "Route.h"

@implementation Route

- initWithName:(NSString *)routeName andID:(NSString *)routeID {
    
    self = [super init];
    
    if (self) {
        _routeID = routeID;
        _routeName = routeName;
    }
    
    return self;
}

@end
