//
//  StopsTableViewController.h
//  B&H Buses
//
//  Created by Tom Pullen on 30/03/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPGetRequest.h"
#import "Route.h"

@interface StopsTableViewController : UITableViewController <HTTPGetRequestProtocol>

@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *context;

@property (nonatomic) Route *route;

@end
