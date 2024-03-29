//
//  Route.m
//  B&H Buses
//
//  Created by Tom Pullen on 29/02/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import "Route.h"
#import "Stop.h"
#import "CDLkRouteStop.h"

@implementation Route

- initWithName:(NSString *)routeName andID:(NSString *)routeID {
    
    self = [super init];
    
    if (self) {
        _routeID = routeID;
        _routeName = routeName;
    }
    
    return self;
}

#pragma mark - Core Data Helper Methods

+ (CDRoute *)getCDRouteForRouteID:(NSString *)routeID withContext:(NSManagedObjectContext *)context {
    
    NSError *error;
    
    // Create the fetch object to get the route for the route ID and name
    NSFetchRequest *getRouteRequest = [[NSFetchRequest alloc] initWithEntityName:@"CDRoute"];
    getRouteRequest.predicate = [NSPredicate predicateWithFormat:@"routeID = %@", routeID];
    NSArray *listOfRoutes = [context executeFetchRequest:getRouteRequest error:&error];
    
    if (error) NSLog(@"%@", error);
    
    // Return the first object in the array (should only be one)
    return [listOfRoutes firstObject];
}

+ (CDRoute *)getCDRouteForRouteID:(NSString *)routeID withRouteName:(NSString *)routeName withContext:(NSManagedObjectContext *)context {
    
    NSError *error;
    
    // Create the fetch object to get the route for the route ID and name
    NSFetchRequest *getRouteRequest = [[NSFetchRequest alloc] initWithEntityName:@"CDRoute"];
    getRouteRequest.predicate = [NSPredicate predicateWithFormat:@"routeID = %@ && routeName = %@", routeID, routeName];
    NSArray *listOfRoutes = [context executeFetchRequest:getRouteRequest error:&error];
    
    if (error) NSLog(@"%@", error);
    
    // Return the first object in the array (should only be one)
    return [listOfRoutes firstObject];
}

+ (NSMutableArray *)getAllRoutesFromCoreDataWithContext:(NSManagedObjectContext *)context {
    
    NSError *error;
    
    // Create the fetch object to get all the routes, sorted by name ascending
    NSFetchRequest *getAllRoutesRequest = [[NSFetchRequest alloc] initWithEntityName:@"CDRoute"];
    getAllRoutesRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"routeName" ascending:YES selector:@selector(localizedStandardCompare:)]];
    NSArray *listOfRoutes = [context executeFetchRequest:getAllRoutesRequest error:&error];
    
    if (error) NSLog(@"%@", error);
    
    return [listOfRoutes mutableCopy];
    
}

+ (void)insertRoutesFromFileIntoCoreDataWithContext:(NSManagedObjectContext *)context {
    
    // Get the file of routes
    NSData *fileData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Routes" ofType:@"json"]];
    
    NSError *error;
    
    // Read the JSON file into an array of dictionaries
    NSArray *routeDictArray = (NSArray *)[NSJSONSerialization JSONObjectWithData:fileData options:NSJSONReadingAllowFragments error:&error];
    
    // For every dictionary, retrieve the route information and insert it into core data
    for (NSDictionary *routeDictionary in routeDictArray) {
        
        Route *route = [[Route alloc] initWithName:routeDictionary[@"RouteName"] andID:routeDictionary[@"RouteID"]];
        
        [Route insertRouteIntoCoreData:route forContext:context];
    }
}

+ (NSMutableArray *)insertAndReturnRoutesFromFileIntoCoreDataWithContext:(NSManagedObjectContext *)context {
    
    NSMutableArray *routesToReturn = [[NSMutableArray alloc] init];
    
    // Get the file of routes
    NSData *fileData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Routes" ofType:@"json"]];
    
    NSError *error;
    
    // Read the JSON file into an array of dictionaries
    NSArray *routeDictArray = (NSArray *)[NSJSONSerialization JSONObjectWithData:fileData options:NSJSONReadingAllowFragments error:&error];
    
    // For every dictionary, retrieve the route information and insert it into core data
    for (NSDictionary *routeDictionary in routeDictArray) {
        
        Route *route = [[Route alloc] initWithName:routeDictionary[@"RouteName"] andID:routeDictionary[@"RouteID"]];
        
        [Route insertRouteIntoCoreData:route forContext:context];
        [routesToReturn addObject:route];
    }
    
    return routesToReturn;
}

+ (void)insertRouteIntoCoreData:(Route *)route forContext:(NSManagedObjectContext *)context {
    
    // Insert a route into Core Data for a given context from a route object
    CDRoute *coreDataRoute = [NSEntityDescription insertNewObjectForEntityForName:@"CDRoute"
                                                           inManagedObjectContext:context];
    coreDataRoute.routeID = route.routeID;
    coreDataRoute.routeName = route.routeName;
}

+ (NSArray *)getRoutesForStopID:(NSString *)stopID withContext:(NSManagedObjectContext *)context {
    
    NSError *error;
    
    CDStop *tempCDStop = [Stop getCDStopForStopID:stopID withContext:context];
    
    NSOrderedSet *set = tempCDStop.lkStopRoute;
    
    NSMutableArray *listOfRoutes = [[NSMutableArray alloc] init];
    
    for (CDLkRouteStop *cdLkRouteStop in set) {
        [listOfRoutes addObject:cdLkRouteStop.route];
        //NSLog(@"%@", cdLkRouteStop.route.routeName);
    }
    
    if (error) NSLog(@"%@", error);
    //NSLog(@"%lu", (unsigned long)[listOfRoutes count]);
    
    return listOfRoutes;
}

+ (NSString *)getRouteNumbersForStopID:(NSString *)stopID withContext:(NSManagedObjectContext *)context {
    
    NSArray *routes = [Route getRoutesForStopID:stopID withContext:context];
    NSString *routeNumbers = @"";
    BOOL firstIteration = YES;
    
    for (CDRoute *cdRoute in routes) {
        if (firstIteration) {
            routeNumbers = [routeNumbers stringByAppendingString:[cdRoute.routeName substringToIndex:[cdRoute.routeName rangeOfString:@" "].location]];
            firstIteration = NO;
        } else {
            routeNumbers = [routeNumbers stringByAppendingString:[@", " stringByAppendingString:[cdRoute.routeName substringToIndex:[cdRoute.routeName rangeOfString:@" "].location]]];
        }
    }
    
    return routeNumbers;
}

@end
