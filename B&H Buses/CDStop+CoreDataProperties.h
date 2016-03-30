//
//  CDStop+CoreDataProperties.h
//  B&H Buses
//
//  Created by Tom Pullen on 30/03/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDStop.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDStop (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *latitude;
@property (nullable, nonatomic, retain) NSString *longitude;
@property (nullable, nonatomic, retain) NSString *operatorsCode;
@property (nullable, nonatomic, retain) NSString *stopID;
@property (nullable, nonatomic, retain) NSString *stopName;
@property (nullable, nonatomic, retain) CDLkRouteStop *lkStopRoute;

@end

NS_ASSUME_NONNULL_END
