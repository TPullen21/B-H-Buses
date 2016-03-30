//
//  LkRouteStop.h
//  B&H Buses
//
//  Created by Tom Pullen on 30/03/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDLkRouteStop.h"

@interface LkRouteStop : NSObject

+ (void)insertRouteStopLinkIntoCoreDataWithStopID:(NSString *)stopID forRouteID:(NSString *)routeID withOrder:(int)listOrder forContext:(NSManagedObjectContext *)context;

@end
