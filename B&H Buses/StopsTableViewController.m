//
//  StopsTableViewController.m
//  B&H Buses
//
//  Created by Tom Pullen on 30/03/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import "StopsTableViewController.h"
#import "DepartureTimesViewController.h"
#import "Stop.h"

@interface StopsTableViewController ()

@property (strong, nonatomic) HTTPGetRequest *httpGetRequest;
@property (strong, nonatomic) NSMutableArray *coreDataStops;
@property (strong, nonatomic) NSMutableArray *downloadedStops;
@property (strong, nonatomic) CDStop *selectedStop;

@end

@implementation StopsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.httpGetRequest.delegate = self;
    
    //[self.httpGetRequest downloadDataWithURL:[NSString stringWithFormat:@"http://bh.buscms.com//brightonbuses/api/XmlEntities/v1/route.aspx?routeid=%@&stops=true&xsl=json", self.route.routeID]];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self getStopsFromCoreData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dataDownloaded:(NSData *)data {
    self.coreDataStops = [self parseDownloadedDataToArrayOfRoutes:data];
    
    [self.tableView reloadData];
}

- (NSMutableArray *)parseDownloadedDataToArrayOfRoutes:(NSData *)data {
    
    NSMutableArray *stopsToReturn = [[NSMutableArray alloc] init];
    
    NSError *error;
    
    NSDictionary *jsonDictionary = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    NSArray *stopsArray = jsonDictionary[@"Stops"];
    
    // Loop through Json objects, create question objects and add them to our questions array
    for (int i = 0; i < stopsArray.count; i++)
    {
        if ([stopsArray[i] isKindOfClass:[NSDictionary class]]) {
            
            // Create a new stop object and set its props to JsonElement properties
            Stop *newStop = [[Stop alloc] init];
            newStop.stopID = stopsArray[i][@"StopId"];
            newStop.stopName = stopsArray[i][@"StopName"];
            newStop.operatorsCode = stopsArray[i][@"OperatorsCode4"];
            newStop.latitude = stopsArray[i][@"Lat"];
            newStop.longitude = stopsArray[i][@"Lng"];
            
            // Add this question to the stops array
            [stopsToReturn addObject:newStop];
        }
    }
    
    return stopsToReturn;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.coreDataStops count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Retrieve cell
    NSString *cellIdentifier = @"StopsCell";
    UITableViewCell *myCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Get the location to be shown
    Stop *stop = self.coreDataStops[indexPath.row];
    
    // Get references to labels of cell
    myCell.textLabel.text = stop.stopName;
    
    return myCell;
}

- (BOOL)tableView:(nonnull UITableView *)tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return YES;
}

-(void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    self.selectedStop = self.coreDataStops[indexPath.row];
    
    [self performSegueWithIdentifier:@"showDepartureTimesVC" sender:nil];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // If we're segueing to the departure times view contoller, set the stop
    if ([segue.destinationViewController isKindOfClass:[DepartureTimesViewController class]]) {
        
        DepartureTimesViewController *departureTimesVC = segue.destinationViewController;
        
        departureTimesVC.stop = self.selectedStop;
    }
}

#pragma mark - Helper Methods

- (void)getStopsFromCoreData {
    
    // If it's in the normal state, proceed
    if (self.document.documentState == UIDocumentStateNormal) {
        
        // Get the context from the document
        self.context = self.document.managedObjectContext;
        
        // If we've managed to get the context, proceed
        if (self.context) {
            
            self.coreDataStops = [[Stop getStopsFromCoreForRoute:self.route.routeName withID:self.route.routeID withContext:self.context] mutableCopy];
            
            // If we receive an empty array (not nil!) then get the routes from the file and reload the table
            if (self.coreDataStops && ![self.coreDataStops count]) {
                NSLog(@"Oops");
            }
            // Else if we received the routes, reload the table to show them!
            else if (self.coreDataStops && [self.coreDataStops count]) {
                [self.tableView reloadData];
            }
            else if (!self.coreDataStops) {
                NSLog(@"Unable to fetch routes from Core Data.");
            }
            
        }
        else {
            NSLog(@"Context failed to intialise.");
        }
        
    }
    else {
        NSLog(@"Document is not in normal state.");
    }
}

#pragma mark - Lazy Instantiation

- (NSMutableArray *)downloadedStops {
    
    if (!_downloadedStops) {
        _downloadedStops = [[NSMutableArray alloc] init];
    }
    
    return _downloadedStops;
}

- (HTTPGetRequest *)httpGetRequest {
    
    if (!_httpGetRequest) {
        _httpGetRequest = [[HTTPGetRequest alloc] init];
    }
    
    return _httpGetRequest;
}

@end
