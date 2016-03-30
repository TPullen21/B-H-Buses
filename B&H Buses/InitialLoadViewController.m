//
//  InitialLoadViewController.m
//  B&H Buses
//
//  Created by Tom Pullen on 29/02/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import "InitialLoadViewController.h"
#import "Route.h"
#import "Stop.h"
#import "LkRouteStop.h"
#import "CDStop.h"

@interface InitialLoadViewController ()

@end

@implementation InitialLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *hasLoadedWithFileData = [[NSUserDefaults standardUserDefaults] objectForKey:hasLoadedWithFileDataKey];
    
    if (hasLoadedWithFileData) {
        [self segueToNavigationController];
    }
    else {
        self.initialLoadLabel.text = loadingDataLabelText;
        self.initialLoadLabel.hidden = NO;
        
        [self.activityIndicatorView startAnimating];
        self.activityIndicatorView.hidden = NO;
        
        // If we haven't initialised the document for the core data context, initialise it
        if (!self.document) [self initialiseDocument];
        else [self documentIsReady];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialiseDocument {
    
    // Create a file manager and get the user's document directory path
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    
    // Create the document object
    NSString *documentName = @"Buses";
    NSURL *documentURL = [documentsDirectory URLByAppendingPathComponent:documentName];
    self.document = [[UIManagedDocument alloc] initWithFileURL:documentURL];
    
    // If the document exists in the user's documents, open it, else save it
    if ([[NSFileManager defaultManager] fileExistsAtPath:[documentURL path]]) {
        [self.document openWithCompletionHandler:^(BOOL success) {
            if (success) [self documentIsReady];
            if (!success) NSLog(@"Couldn't open document at %@", documentURL);
        }];
    } else {
        [self.document saveToURL:documentURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) [self documentIsReady];
            if (!success) NSLog(@"Couldn't open document at %@", documentURL);
        }];
    }
}

- (void)documentIsReady {
    
    // If it's in the normal state, proceed
    if (self.document.documentState == UIDocumentStateNormal) {
        
        // Get the context from the document
        self.context = self.document.managedObjectContext;
        
        // If we've managed to get the context, proceed
        if (self.context) {
            
            //[Route insertRoutesFromFileIntoCoreDataWithContext:self.context];
            [self initialiseCoreDataWithStops];
            [[NSUserDefaults standardUserDefaults] setObject:@"Loaded" forKey:hasLoadedWithFileDataKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.activityIndicatorView stopAnimating];
            [self segueToNavigationController];
            
        }
        else {
            NSLog(@"Context failed to intialise.");
        }
        
    }
    else {
        NSLog(@"Document is not in normal state.");
    }
}

- (void)initialiseCoreDataWithStops {
    NSArray *listOfStops = [Stop returnStopsFromFile];
    NSMutableArray *listOfStopsAlreadyAdded = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in listOfStops) {
        Route *route = [[Route alloc] initWithName:dict[@"RouteName"] andID:dict[@"RouteId"]];
        int stopCount = 1;
        
        [Route insertRouteIntoCoreData:route forContext:self.context];
        
        for (NSDictionary *stopDict in dict[@"Stops"]) {
            
            if ([stopDict isKindOfClass:[NSDictionary class]]) {
                Stop *stop = [[Stop alloc] initWithDictionary:stopDict];
                
                if (![listOfStopsAlreadyAdded containsObject:stop.stopID]) {
                    [Stop insertStopIntoCoreData:stop forRouteID:route.routeID withRouteName:route.routeName withOrder:stopCount++ forContext:self.context];
                    [listOfStopsAlreadyAdded addObject:stop.stopID];
                }
                else {
                    [LkRouteStop insertRouteStopLinkIntoCoreDataWithStopID:stop.stopID forRouteID:route.routeID withOrder:stopCount++ forContext:self.context];
                }
            }
        }
    }
}

- (void)segueToNavigationController {
    [self performSegueWithIdentifier:@"showNavigationC" sender:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
