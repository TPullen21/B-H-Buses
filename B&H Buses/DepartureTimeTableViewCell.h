//
//  DepartureTimeTableViewCell.h
//  B&H Buses
//
//  Created by Tom Pullen on 08/04/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DepartureTimeTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *serviceNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *destinationLabel;
@property (strong, nonatomic) IBOutlet UILabel *departureTimeInMinsLabel;
@property (strong, nonatomic) IBOutlet UILabel *departureTimestampLabel;

@end
