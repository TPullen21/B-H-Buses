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
@property (nullable, nonatomic, retain) NSOrderedSet<CDLkRouteStop *> *lkRouteStop;

@end

@interface CDRoute (CoreDataGeneratedAccessors)

- (void)insertObject:(CDLkRouteStop *)value inLkRouteStopAtIndex:(NSUInteger)idx;
- (void)removeObjectFromLkRouteStopAtIndex:(NSUInteger)idx;
- (void)insertLkRouteStop:(NSArray<CDLkRouteStop *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeLkRouteStopAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInLkRouteStopAtIndex:(NSUInteger)idx withObject:(CDLkRouteStop *)value;
- (void)replaceLkRouteStopAtIndexes:(NSIndexSet *)indexes withLkRouteStop:(NSArray<CDLkRouteStop *> *)values;
- (void)addLkRouteStopObject:(CDLkRouteStop *)value;
- (void)removeLkRouteStopObject:(CDLkRouteStop *)value;
- (void)addLkRouteStop:(NSOrderedSet<CDLkRouteStop *> *)values;
- (void)removeLkRouteStop:(NSOrderedSet<CDLkRouteStop *> *)values;

@end

NS_ASSUME_NONNULL_END
