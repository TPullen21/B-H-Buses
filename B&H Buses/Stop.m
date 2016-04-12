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
#import "Constants.m"

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
        _stopName = dict[@"StopName"];
        _operatorsCode = dict[@"OperatorsCode4"];
        _latitude = dict[@"Lat"];
        _longitude = dict[@"Lng"];
    }
    
    return self;
}

// Init with a stop object retrieved from Core Data
- initWithCDStop:(CDStop *)cdStop {
    
    self = [super init];
    
    if (self) {
        _stopID = cdStop.stopID;
        _stopName = cdStop.stopName;
        _operatorsCode = cdStop.operatorsCode;
        _latitude = cdStop.latitude;
        _longitude = cdStop.longitude;
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

+ (NSArray *)getAllCDStopsWithContext:(NSManagedObjectContext *)context {
    
    NSError *error;
    
    // Create the fetch object to get the stop for the stop ID
    NSFetchRequest *getStopRequest = [[NSFetchRequest alloc] initWithEntityName:@"CDStop"];
    NSArray *listOfStops = [context executeFetchRequest:getStopRequest error:&error];
    
    if (error) NSLog(@"%@", error);
    
    return listOfStops;
}

+ (void)insertStopIntoCoreData:(Stop *)stop forRouteID:(NSString *)routeID withRouteName:(NSString *)routeName withOrder:(int)listOrder forContext:(NSManagedObjectContext *)context {
    
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

+ (NSArray *)getStopsFromCoreForRoute:(NSString *)routeName withID:(NSString *)routeID withContext:(NSManagedObjectContext *)context {
    
    NSError *error;
    
    CDRoute *tempcdroute = [Route getCDRouteForRouteID:routeID withContext:context];
    
    NSOrderedSet *set = tempcdroute.lkRouteStop;
    
    NSMutableArray *listOfStops = [[NSMutableArray alloc] init];
    
    for (CDLkRouteStop *cdLkRouteStop in set) {
        [listOfStops addObject:cdLkRouteStop.stop];
    }
    
    if (error) NSLog(@"%@", error);
    NSLog(@"%lu", (unsigned long)[listOfStops count]);
    
    // Return the first object in the array (should only be one)
    return listOfStops;
}

#pragma mark - Favourite Stops Helper Methods

+ (NSArray *)getFavouritedStopIDs {
    
    NSArray *favouritedStops = [[NSUserDefaults standardUserDefaults] arrayForKey:FAVOURITED_STOPS_KEY];
    
    if (!favouritedStops) {
        favouritedStops = [[NSArray alloc] init];
    }
    
    return favouritedStops;
}

+ (NSArray *)getFavouritedStopsArrayWithContext:(NSManagedObjectContext *)context {
    
    NSArray *favouritedStopIDs = [self getFavouritedStopIDs];
    
    NSError *error;
    
    NSSet *favouritedStopIDsSet = [NSSet setWithArray:favouritedStopIDs];
    
    // Create the fetch object to get the stop for the stop ID
    NSFetchRequest *getStopRequest = [[NSFetchRequest alloc] initWithEntityName:@"CDStop"];
    getStopRequest.predicate = [NSPredicate predicateWithFormat:@"any stopID in %@", favouritedStopIDsSet];
    NSArray *cdStopsArray = [context executeFetchRequest:getStopRequest error:&error];
    
    if (error) NSLog(@"%@", error);
    
    NSMutableArray *stopsArray = [[NSMutableArray alloc] init];
    
    for (CDStop *stop in cdStopsArray) {
        [stopsArray addObject:[[Stop alloc] initWithCDStop:stop]];
    }
    
    return stopsArray;
}

+ (void)addStopToFavourites:(NSString *)stopID {
    NSMutableArray *favouritedStops = [[Stop getFavouritedStopIDs] mutableCopy];
    [favouritedStops addObject:stopID];
    [[NSUserDefaults standardUserDefaults] setObject:[favouritedStops copy] forKey:FAVOURITED_STOPS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeStopFromFavourites:(NSString *)stopID {
    NSMutableArray *favouritedStops = [[Stop getFavouritedStopIDs] mutableCopy];
    [favouritedStops removeObject:stopID];
    [[NSUserDefaults standardUserDefaults] setObject:[favouritedStops copy] forKey:FAVOURITED_STOPS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isStopFavourited:(NSString *)stopID {
    NSArray *favouritedStops = [self getFavouritedStopIDs];
    
    for (NSString *favouritedStopID in favouritedStops) {
        if ([favouritedStopID isEqualToString:stopID]) {
            return YES;
        }
    }
    
    return NO;
}

@end
