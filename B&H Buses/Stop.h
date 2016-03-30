//
//  Stop.h
//  B&H Buses
//
//  Created by Tom Pullen on 30/03/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDStop.h"

@interface Stop : NSObject

@property (nonatomic) double distance;
@property (strong, nonatomic) NSString *stopID;
@property (strong, nonatomic) NSString *stopName;
@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;
@property (strong, nonatomic) NSString *operatorsCode;

- initWithDictionary:(NSDictionary *)dict;
- initWithID:(NSString *)stopID withName:(NSString *)stopName withLatitude:(NSString *)latitude withLongitude:(NSString *)longitude withOperatorsCode:(NSString *)operatorsCode;

+ (NSArray *)returnStopsFromFile;

+ (CDStop *)getCDStopForStopID:(NSString *)stopID withContext:(NSManagedObjectContext *)context;
+ (void)insertStopIntoCoreData:(Stop *)stop forRouteID:(NSString *)routeID withRouteName:(NSString *)routeName withOrder:(int)listOrder forContext:(NSManagedObjectContext *)context;
+ (NSArray *)getStopsFromCoreForRoute:(NSString *)routeName withID:(NSString *)routeID withContext:(NSManagedObjectContext *)context;

@end
