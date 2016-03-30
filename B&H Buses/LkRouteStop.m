//
//  LkRouteStop.m
//  B&H Buses
//
//  Created by Tom Pullen on 30/03/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import "LkRouteStop.h"
#import "Route.h"
#import "Stop.h"

@implementation LkRouteStop

+ (void)insertRouteStopLinkIntoCoreDataWithStopID:(NSString *)stopID forRouteID:(NSString *)routeID withOrder:(int)listOrder forContext:(NSManagedObjectContext *)context {
    
    // Insert a route/stop link into Core Data for a given context from a stop/route ID
    CDLkRouteStop *coreDataRouteStopLink = [NSEntityDescription insertNewObjectForEntityForName:@"CDLkRouteStop" inManagedObjectContext:context];
    coreDataRouteStopLink.listOrder = [[NSNumber alloc] initWithInt:listOrder];
    coreDataRouteStopLink.route = [Route getCDRouteForRouteID:routeID withContext:context];
    coreDataRouteStopLink.stop = [Stop getCDStopForStopID:stopID withContext:context];
}

@end
