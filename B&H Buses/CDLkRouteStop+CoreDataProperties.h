//
//  CDLkRouteStop+CoreDataProperties.h
//  B&H Buses
//
//  Created by Tom Pullen on 30/03/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDLkRouteStop.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDLkRouteStop (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *listOrder;
@property (nullable, nonatomic, retain) CDRoute *route;
@property (nullable, nonatomic, retain) CDStop *stop;

@end

NS_ASSUME_NONNULL_END
