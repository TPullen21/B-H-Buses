//
//  InitialLoadViewController.h
//  B&H Buses
//
//  Created by Tom Pullen on 29/02/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *hasLoadedWithFileDataKey = @"HasLoaded";
static NSString *loadingDataLabelText = @"Performing initial app data processing, this should take less than a minute.";

@interface InitialLoadViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *initialLoadLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *context;

@end
