//
//  RoutesTableViewController.h
//  B&H Buses
//
//  Created by Tom Pullen on 29/02/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPGetRequest.h"

@interface RoutesTableViewController : UITableViewController <HTTPGetRequestProtocol>

@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *context;

- (IBAction)nearestStopsBarButtonItemPressed:(id)sender;

@end
