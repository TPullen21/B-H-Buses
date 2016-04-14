//
//  RoutesTableViewController.m
//  B&H Buses
//
//  Created by Tom Pullen on 29/02/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import "RoutesTableViewController.h"
#import "StopsTableViewController.h"
#import "NearestStopsViewController.h"
#import "FavouritesTableViewController.h"
#import "Route.h"

@interface RoutesTableViewController ()

@property (strong, nonatomic) HTTPGetRequest *httpGetRequest;
@property (strong, nonatomic) NSMutableArray *downloadedRoutes;
@property (strong, nonatomic) NSMutableArray *coreDataRoutes;
@property (strong, nonatomic) NSArray *searchResultsRoutes;
@property (strong, nonatomic) Route *selectedRoute;
@property BOOL searchTextEntered;

@end

@implementation RoutesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.httpGetRequest.delegate = self;
    self.searchBar.delegate = self;
    self.searchTextEntered = NO;
    
    //[self.httpGetRequest downloadDataWithURL:@"http://bh.buscms.com//brightonbuses/api/XmlEntities/v1/routes.aspx?xsl=json"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // If we haven't initialised the document for the core data context, initialise it
    if (!self.document) [self initialiseDocument];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dataDownloaded:(NSData *)data {
    self.downloadedRoutes = [self parseDownloadedDataToArrayOfRoutes:data];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return [self.downloadedRoutes count];
    if (self.searchTextEntered) {
        return [self.searchResultsRoutes count];
        
    } else {
        return [self.coreDataRoutes count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"routesCell" forIndexPath:indexPath];
    
    // Get the route to be shown
    //Route *route = self.downloadedRoutes[indexPath.row];
    Route *route = nil;
    if (self.searchTextEntered) {
        route = self.searchResultsRoutes[indexPath.row];
    } else {
        route = self.coreDataRoutes[indexPath.row];
    }
    
    cell.textLabel.text = route.routeName;
    
    return cell;
}

-(void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if (self.searchTextEntered) {
        self.selectedRoute = self.searchResultsRoutes[indexPath.row];
    } else {
        self.selectedRoute = self.coreDataRoutes[indexPath.row];
    }
    
    [self performSegueWithIdentifier:@"showStopsTVC" sender:nil];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // If we're segueing to the stops contoller, set the routeID
    if ([segue.destinationViewController isKindOfClass:[StopsTableViewController class]]) {
        
        StopsTableViewController *stopsVC = segue.destinationViewController;
        
        stopsVC.route = self.selectedRoute;
        stopsVC.document = self.document;
        stopsVC.context = self.context;
    } else if ([segue.destinationViewController isKindOfClass:[NearestStopsViewController class]]) {
        
        NearestStopsViewController *nearestStopsVC = segue.destinationViewController;
        
        nearestStopsVC.context = self.context;
    } else if ([segue.destinationViewController isKindOfClass:[FavouritesTableViewController class]]) {
        
        FavouritesTableViewController *favouritesTVC = segue.destinationViewController;
        
        favouritesTVC.context = self.context;
    }
}

#pragma mark - Helper Methods

- (NSMutableArray *)parseDownloadedDataToArrayOfRoutes:(NSData *)data {
    
    NSMutableArray *routesListToReturn = [[NSMutableArray alloc] init];
    
    NSData *routesData = [self correctJSONFormat:data];
    
    NSError *error;
    
    NSArray *routeDictArray = (NSArray *)[NSJSONSerialization JSONObjectWithData:routesData options:NSJSONReadingAllowFragments error:&error];
    
    if (error) NSLog(@"Error parsing downloaded routes: [%@]", error);
    
    for (NSDictionary *routeDictionary in routeDictArray) {
        
        Route *route = [[Route alloc] initWithName:routeDictionary[@"RouteName"] andID:routeDictionary[@"RouteId"]];
        
        // Add this to the routes array to return
        [routesListToReturn addObject:route];
    }
    
    // Ready to notify delegate that data is ready and pass back list of routes
    return routesListToReturn;
}

- (NSData *)correctJSONFormat:(NSData *)jsonDataInIncorrectFormat {
    // JSON on the web page is in an incorrect format - it has no quotes around the keys
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonDataInIncorrectFormat encoding:NSUTF8StringEncoding];
    
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"RouteId" withString:@"\"RouteId\""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"RouteName" withString:@"\"RouteName\""];
    
    return [jsonString dataUsingEncoding:NSUTF8StringEncoding];
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
            
            self.coreDataRoutes = [Route getAllRoutesFromCoreDataWithContext:self.context];
            
            // If we receive an empty array (not nil!) then get the routes from the file and reload the table
            if (self.coreDataRoutes && ![self.coreDataRoutes count]) {
                NSLog(@"Oops");
            }
            // Else if we received the routes, reload the table to show them!
            else if (self.coreDataRoutes && [self.coreDataRoutes count]) {
                [self.tableView reloadData];
            }
            else if (!self.coreDataRoutes) {
                NSLog(@"Unable to fetch routes from Core Data.");
            }
            
            // Call the download items method of the routes model object
            //[self.routesModel downloadItems];
            
        }
        else {
            NSLog(@"Context failed to intialise.");
        }
        
    }
    else {
        NSLog(@"Document is not in normal state.");
    }
}

- (void)filterContentForSearchText:(NSString*)searchText
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"routeName contains[c] %@", searchText];
    self.searchResultsRoutes = [self.coreDataRoutes filteredArrayUsingPredicate:resultPredicate];
}

- (BOOL)isStringEmpty:(NSString *)string {
    if([string length] == 0) { //string is empty or nil
        return YES;
    }
    
    if(![[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        //string is all whitespace
        return YES;
    }
    
    return NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    // The user has entered some text to search
    if([searchText length] > 0) {
        [self filterContentForSearchText:searchText];
        self.searchTextEntered = YES;
    }
    // The user clicked the [X] button or otherwise cleared the text.
    else {
        [searchBar performSelector: @selector(resignFirstResponder) withObject: nil afterDelay: 0.1];
        self.searchTextEntered = NO;
    }
    
    [self.tableView reloadData];
}


#pragma mark - Lazy Instantiation

- (NSMutableArray *)downloadedRoutes {
    
    if (!_downloadedRoutes) {
        _downloadedRoutes = [[NSMutableArray alloc] init];
    }
    
    return _downloadedRoutes;
}

- (HTTPGetRequest *)httpGetRequest {
    
    if (!_httpGetRequest) {
        _httpGetRequest = [[HTTPGetRequest alloc] init];
    }
    
    return _httpGetRequest;
}

- (IBAction)nearestStopsBarButtonItemPressed:(id)sender {
    [self performSegueWithIdentifier:@"showNearestStopsVC" sender:nil];
}

- (IBAction)favouritesBarButtonItemPressed:(id)sender {
    [self performSegueWithIdentifier:@"showFavouritesTVC" sender:nil];
}

@end
