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
    
    CDRoute *cdRoute = [Route getCDRouteForRouteID:routeID withContext:context];
    CDStop *cdStop = [Stop getCDStopForStopID:stopID withContext:context];
    
    if (!cdRoute) NSLog(@"No route found when trying to link for id: %@", routeID);
    if (!cdStop) NSLog(@"No stop found when trying to link for id: %@", stopID);
    
    coreDataRouteStopLink.route = cdRoute;
    coreDataRouteStopLink.stop = cdStop;
    
//    if (cdRoute && cdStop) {
//        
//        if (!cdRoute.lkRouteStop) {
//            cdRoute.lkRouteStop = [[NSMutableSet alloc] init];
//        }
////        NSMutableSet *routeSet = [cdRoute.lkRouteStop mutableCopy];
////        NSSet *routeSet2 = [cdRoute valueForKey:@"lkRouteStop"];
////        NSLog(@"%@", cdRoute.routeName);
////        [routeSet addObject:coreDataRouteStopLink];
////        [cdRoute setLkRouteStop:routeSet];
//        [cdRoute addLkRouteStopObject:coreDataRouteStopLink];
//        //cdRoute.lkRouteStop = routeSet;
//        
//        if (!cdStop.lkStopRoute) {
//            cdStop.lkStopRoute = [[NSMutableSet alloc] init];
//        }
////        NSMutableSet *stopSet = [cdStop.lkStopRoute mutableCopy];
////        [stopSet addObject:coreDataRouteStopLink];
////        [cdStop setLkStopRoute:stopSet];
//        //cdStop.lkStopRoute = stopSet;
//        [cdStop addLkStopRouteObject:coreDataRouteStopLink];
//    }
}

@end
