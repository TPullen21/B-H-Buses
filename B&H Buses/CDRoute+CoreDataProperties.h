//
//  CDRoute+CoreDataProperties.h
//  B&H Buses
//
//  Created by Tom Pullen on 30/03/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDRoute.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDRoute (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *routeID;
@property (nullable, nonatomic, retain) NSString *routeName;
@property (nullable, nonatomic, retain) CDLkRouteStop *lkRouteStop;

@end

NS_ASSUME_NONNULL_END
