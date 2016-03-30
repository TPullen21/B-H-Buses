//
//  Route.h
//  B&H Buses
//
//  Created by Tom Pullen on 29/02/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDRoute.h"

@interface Route : NSObject

@property (nonatomic) NSString *routeID;
@property (strong, nonatomic) NSString *routeName;

- initWithName:(NSString *)routeName andID:(NSString *)routeID;

+ (CDRoute *)getCDRouteForRouteID:(NSString *)routeID withContext:(NSManagedObjectContext *)context;
+ (CDRoute *)getCDRouteForRouteID:(NSString *)routeID withRouteName:(NSString *)routeName withContext:(NSManagedObjectContext *)context;
+ (NSMutableArray *)getAllRoutesFromCoreDataWithContext:(NSManagedObjectContext *)context;
+ (void)insertRoutesFromFileIntoCoreDataWithContext:(NSManagedObjectContext *)context;
+ (NSMutableArray *)insertAndReturnRoutesFromFileIntoCoreDataWithContext:(NSManagedObjectContext *)context;
+ (void)insertRouteIntoCoreData:(Route *)route forContext:(NSManagedObjectContext *)context;

@end
