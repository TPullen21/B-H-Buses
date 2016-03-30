//
//  Stop.m
//  B&H Buses
//
//  Created by Tom Pullen on 30/03/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import "Stop.h"
#import "Route.h"
#import "LkRouteStop.h"

@implementation Stop

// Init with all the information
- initWithID:(NSString *)stopID withName:(NSString *)stopName withLatitude:(NSString *)latitude withLongitude:(NSString *)longitude withOperatorsCode:(NSString *)operatorsCode {
    
    self = [super init];
    
    if (self) {
        _stopID = stopID;
        _stopName = stopName;
        _latitude = latitude;
        _longitude = longitude;
        _operatorsCode = operatorsCode;
    }
    
    return self;
}

// Init with a dictionary of the information
- initWithDictionary:(NSDictionary *)dict {
    
    self = [super init];
    
    if (self) {
        _stopID = dict[@"StopId"];
        _stopName = dict[@"StopName"];;
        _operatorsCode = dict[@"OperatorsCode4"];;
        _latitude = dict[@"Lat"];
        _longitude = dict[@"Lng"];;
    }
    
    return self;
}

#pragma mark - Core Data Helper Methods

+ (NSArray *)returnStopsFromFile {
    
    // Get the file of all the stops for all the routes
    NSData *fileData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AllStopsForAllRoutes" ofType:@"json"]];
    
    NSError *error;
    
    // Read the JSON file into an array of dictionaries
    NSDictionary *routeDictArray = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:fileData options:NSJSONReadingAllowFragments error:&error];
    
    return (NSArray *)routeDictArray[@"Routes"];
}

+ (CDStop *)getCDStopForStopID:(NSString *)stopID withContext:(NSManagedObjectContext *)context {
    
    NSError *error;
    
    // Create the fetch object to get the stop for the stop ID
    NSFetchRequest *getStopRequest = [[NSFetchRequest alloc] initWithEntityName:@"CDStop"];
    getStopRequest.predicate = [NSPredicate predicateWithFormat:@"stopID = %@", stopID];
    NSArray *listOfStops = [context executeFetchRequest:getStopRequest error:&error];
    
    if (error) NSLog(@"%@", error);
    
    // Return the first object in the array (should only be one)
    return [listOfStops firstObject];
}

+ (void)insertStopIntoCoreData:(Stop *)stop forRouteID:(NSString *)routeID withRouteName:(NSString *)routeName withOrder:(int)listOrder forContext:(NSManagedObjectContext *)context {
    
    // Insert a link between the route and stop
    //    [CDLkRouteStop insertRouteStopLinkIntoCoreDataWithStopID:stop.stopID forRouteID:routeID withRouteName:routeName forContext:context];
    
    // If the stop does not already exist in core data, add it
    if (![Stop getCDStopForStopID:stop.stopID withContext:context]) {
        
        // Insert a stop into Core Data for a given context from a stop object
        CDStop *coreDataStop = [NSEntityDescription insertNewObjectForEntityForName:@"CDStop"
                                                             inManagedObjectContext:context];
        coreDataStop.stopID = stop.stopID;
        coreDataStop.stopName = stop.stopName;
        coreDataStop.latitude = stop.latitude;
        coreDataStop.longitude = stop.longitude;
        coreDataStop.operatorsCode = stop.operatorsCode;
        
        [LkRouteStop insertRouteStopLinkIntoCoreDataWithStopID:stop.stopID forRouteID:routeID withOrder:listOrder forContext:context];
    }
}
//
//+ (void)linkStop:(Stop *)stop withRoute:(Route *)route withRouteName:(NSString *)routeName withOrder:(int)listOrder forContext:(NSManagedObjectContext *)context {
//    
//    // Insert a link between the route and stop
//    //    [CDLkRouteStop insertRouteStopLinkIntoCoreDataWithStopID:stop.stopID forRouteID:routeID withRouteName:routeName forContext:context];
//    
//    // If the stop does not already exist in core data, add it
//    if (![Stop getCDStopForStopID:stop.stopID withContext:context]) {
//        
//        // Insert a stop into Core Data for a given context from a stop object
//        CDStop *coreDataStop = [NSEntityDescription insertNewObjectForEntityForName:@"CDStop"
//                                                             inManagedObjectContext:context];
//        coreDataStop.stopID = stop.stopID;
//        coreDataStop.stopName = stop.stopName;
//        coreDataStop.latitude = stop.latitude;
//        coreDataStop.longitude = stop.longitude;
//        coreDataStop.operatorsCode = stop.operatorsCode;
//        coreDataStop.listOrder = [[NSNumber alloc] initWithInt:listOrder];
//        
//        CDRoute *route = [Route getCDRouteForRouteID:routeID withContext:context];
//        
//        if (route) {
//            coreDataStop.lkStopRoute = route;
//        } else {
//            NSLog(@"Route not found. Name: %@ ID: %@", routeName, routeID);
//        }
//    }
//}

+ (NSArray *)getStopsFromCoreForRoute:(NSString *)routeName withID:(NSString *)routeID withContext:(NSManagedObjectContext *)context {
    
    NSError *error;
    
    // Create the fetch object to get the stop for the stop ID
    NSFetchRequest *getStopRequest = [[NSFetchRequest alloc] initWithEntityName:@"CDStop"];
    getStopRequest.predicate = [NSPredicate predicateWithFormat:@"ANY lkRouteStop.routeID = %@ && ANY lkRouteStop.routeName = %@", routeID, routeName];
    getStopRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"listOrder" ascending:YES selector:@selector(localizedStandardCompare:)]];
//#warning TODO: Brings back stops in a random order
    NSArray *listOfStops = [context executeFetchRequest:getStopRequest error:&error];
    
    if (error) NSLog(@"%@", error);
    NSLog(@"%lu", (unsigned long)[listOfStops count]);
    
    // Return the first object in the array (should only be one)
    return listOfStops;
}

@end
