//
//  CDStop+CoreDataProperties.m
//  B&H Buses
//
//  Created by Tom Pullen on 30/03/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDStop+CoreDataProperties.h"

@implementation CDStop (CoreDataProperties)

@dynamic latitude;
@dynamic longitude;
@dynamic operatorsCode;
@dynamic stopID;
@dynamic stopName;
@dynamic lkStopRoute;

@end
