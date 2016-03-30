//
//  Route.h
//  B&H Buses
//
//  Created by Tom Pullen on 29/02/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Route : NSObject

@property (nonatomic) NSString *routeID;
@property (strong, nonatomic) NSString *routeName;

- initWithName:(NSString *)routeName andID:(NSString *)routeID;

@end
