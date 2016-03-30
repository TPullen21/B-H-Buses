//
//  RoutesTableViewController.m
//  B&H Buses
//
//  Created by Tom Pullen on 29/02/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import "RoutesTableViewController.h"
#import "Route.h"

@interface RoutesTableViewController ()

@property (strong, nonatomic) HTTPGetRequest *httpGetRequest;
@property (strong, nonatomic) NSMutableArray *downloadedRoutes;
@property (strong, nonatomic) Route *selectedRoute;

@end

@implementation RoutesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.httpGetRequest.delegate = self;
    
    [self.httpGetRequest downloadDataWithURL:@"http://bh.buscms.com//brightonbuses/api/XmlEntities/v1/routes.aspx?xsl=json"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.downloadedRoutes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"routesCell" forIndexPath:indexPath];
    
    // Get the route to be shown
    Route *route = self.downloadedRoutes[indexPath.row];
    
    cell.textLabel.text = route.routeName;
    
    return cell;
}

- (void)dataDownloaded:(NSData *)data {
    self.downloadedRoutes = [self parseDownloadedDataToArrayOfRoutes:data];
    
    [self.tableView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 */

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

@end
