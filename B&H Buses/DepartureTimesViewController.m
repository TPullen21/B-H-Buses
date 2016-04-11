//
//  DepartureTimesViewController.m
//  B&H Buses
//
//  Created by Tom Pullen on 08/04/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import "DepartureTimesViewController.h"
#import "DepartureTimeTableViewCell.h"
#import "DepartureTime.h"
#import "Constants.m"

@interface DepartureTimesViewController ()

@property (strong, nonatomic) NSMutableArray *departureTimes;
@property (strong, nonatomic) NSMutableArray *favouritedStops;
@property (strong, nonatomic) HTTPGetRequest *httpGetRequest;
@property BOOL stopIsFavourited;

@end

@implementation DepartureTimesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set the protocol delegates
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.httpGetRequest.delegate = self;
    
    // Call the method to asynchronously download the departure times information
    [self.httpGetRequest downloadDataWithURL:[NSString stringWithFormat:@"http://m.buses.co.uk/brightonbuses/operatorpages/mobilesite/stop.aspx?source=siri&stopid=%@", self.stop.stopID]];
    
    self.favouritedStops = [self getFavouritedStops];
    
    if ([self currentStopIsFavourited]) {
        self.stopIsFavourited = YES;
        self.favouritedBarButtonItem.image = [UIImage imageNamed:@"Full Star"];
    } else {
        self.stopIsFavourited = NO;
        self.favouritedBarButtonItem.image = [UIImage imageNamed:@"Empty Star"];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Create coordinates from location lat/long
    CLLocationCoordinate2D poiCoodinates;
    poiCoodinates.latitude = [self.stop.latitude doubleValue];
    poiCoodinates.longitude= [self.stop.longitude doubleValue];
    
    // Zoom to that region
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(poiCoodinates, 750, 750);
    [self.mapView setRegion:viewRegion animated:self.animateZoom];
    
    // Plot pin
    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
    pin.coordinate = poiCoodinates;
    [self.mapView addAnnotation:pin];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - HTTP Get Request Delegate Method

// This delegate method will get called when the departure times web page has been downloaded
- (void)dataDownloaded:(NSData *)data {
    
    NSString *htmlPageToScrape = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSArray *htmlPageSplitByTableRows = [htmlPageToScrape componentsSeparatedByString:@"rowServiceDeparture"];
    
    for (int i = 1; i < htmlPageSplitByTableRows.count; i++)
    {
        NSArray *htmlTableRowsSplitByTableData = [htmlPageSplitByTableRows[i] componentsSeparatedByString:@"<td"];
        
        DepartureTime *newDepartureTime = [[DepartureTime alloc] init];
        
        newDepartureTime.serviceName = [self scrapeServiceNameOrDestination:htmlTableRowsSplitByTableData[1]];
        newDepartureTime.destination = [self scrapeServiceNameOrDestination:htmlTableRowsSplitByTableData[2]];
        [self scrapeDepartureTimeStampAndTimeInMins:htmlTableRowsSplitByTableData[3] withModel:newDepartureTime];
        
        // Add this depature time record to the departureTimes array
        [self.departureTimes addObject:newDepartureTime];
    }
    
    // Reload the table view
    [self.tableView reloadData];
}

#pragma mark Table View Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of departure time records
    return self.departureTimes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Retrieve reusable cell cell
    NSString *cellIdentifier = @"DepartureTimesCell";
    DepartureTimeTableViewCell *departureTimeCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Get the depature time record to be shown
    DepartureTime *departureTime = self.departureTimes[indexPath.row];
    
    // Assign the relevant information to the cell's text labels
    departureTimeCell.serviceNameLabel.text = departureTime.serviceName;
    departureTimeCell.destinationLabel.text = departureTime.destination;
    departureTimeCell.departureTimeInMinsLabel.text = departureTime.departureTimeInMinutes;
    departureTimeCell.departureTimestampLabel.text = departureTime.departureTimeStamp;
    
    return departureTimeCell;
}

- (BOOL)tableView:(nonnull UITableView *)tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - Helper Methods

- (NSString *)scrapeServiceNameOrDestination:(NSString *)htmlTDString {
    
    NSRange firstRange = [htmlTDString rangeOfString:@">"];
    firstRange.location++;
    NSRange finalRange = [htmlTDString rangeOfString:@"<"];
    NSRange substringRange = NSMakeRange(firstRange.location, finalRange.location - firstRange.location);
    
    return [htmlTDString substringWithRange:substringRange];
}

- (void)scrapeDepartureTimeStampAndTimeInMins:(NSString *)htmlTDString withModel:(DepartureTime *)dt {
    
    NSRange firstRange = [htmlTDString rangeOfString:@"data-departureTime=\""];
    firstRange.location+= 31;
    NSRange finalRange = [htmlTDString rangeOfString:@"\" title="];
    NSRange substringRange = NSMakeRange(firstRange.location, finalRange.location - firstRange.location - 3);
    
    NSString *timestamp = [htmlTDString substringWithRange:substringRange];
    
    
    firstRange = [htmlTDString rangeOfString:@">"];
    firstRange.location++;
    finalRange = [htmlTDString rangeOfString:@"<"];
    substringRange = NSMakeRange(firstRange.location, finalRange.location - firstRange.location);
    
    NSString *time = [htmlTDString substringWithRange:substringRange];
    
    dt.departureTimeStamp = timestamp;
    dt.departureTimeInMinutes = time;
}

- (NSMutableArray *)getFavouritedStops {
    
    NSArray *favouritedStops = [[NSUserDefaults standardUserDefaults] arrayForKey:FAVOURITED_STOPS_KEY];
    
    if (!favouritedStops) {
        favouritedStops = [[NSArray alloc] init];
    }
    
    return [favouritedStops mutableCopy];
}

- (BOOL)currentStopIsFavourited {
    
    for (NSString *stopID in self.favouritedStops) {
        if ([stopID isEqualToString:self.stop.stopID]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)addStopToFavourites {
    [self.favouritedStops addObject:self.stop.stopID];
    [[NSUserDefaults standardUserDefaults] setObject:[self.favouritedStops copy] forKey:FAVOURITED_STOPS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeStopFromFavourites {
    [self.favouritedStops removeObject:self.stop.stopID];
    [[NSUserDefaults standardUserDefaults] setObject:[self.favouritedStops copy] forKey:FAVOURITED_STOPS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Lazy Instantiation

- (NSMutableArray *)departureTimes {
    
    if (!_departureTimes) {
        _departureTimes = [[NSMutableArray alloc] init];
    }
    
    return _departureTimes;
}

- (HTTPGetRequest *)httpGetRequest {
    
    if (!_httpGetRequest) {
        _httpGetRequest = [[HTTPGetRequest alloc] init];
    }
    
    return _httpGetRequest;
}

- (IBAction)favouritedBarButtonItemPressed:(id)sender {
    if (self.stopIsFavourited) {
        self.stopIsFavourited = NO;
        self.favouritedBarButtonItem.image = [UIImage imageNamed:@"Empty Star"];
        [self removeStopFromFavourites];
    } else {
        self.stopIsFavourited = YES;
        self.favouritedBarButtonItem.image = [UIImage imageNamed:@"Full Star"];
        [self addStopToFavourites];
    }
}
@end
