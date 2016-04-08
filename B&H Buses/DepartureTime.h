//
//  DepartureTime.h
//  B&H Buses
//
//  Created by Tom Pullen on 08/04/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DepartureTime : NSObject

@property (strong, nonatomic) NSString *serviceName;
@property (strong, nonatomic) NSString *destination;
@property (strong, nonatomic) NSString *departureTimeStamp;
@property (strong, nonatomic) NSString *departureTimeInMinutes;

@end
