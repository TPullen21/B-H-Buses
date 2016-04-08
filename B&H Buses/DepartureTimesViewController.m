//
//  DepartureTimesViewController.m
//  B&H Buses
//
//  Created by Tom Pullen on 08/04/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import "DepartureTimesViewController.h"
#import "DepartureTime.h"

@interface DepartureTimesViewController ()

@property (strong, nonatomic) NSMutableArray *departureTimes;
@property (strong, nonatomic) HTTPGetRequest *httpGetRequest;

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
    [self.mapView setRegion:viewRegion animated:YES];
    
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
    
    NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSArray *myWords = [myString componentsSeparatedByString:@"data-departureTime=\""];
    
    for (int i = 1; i < myWords.count; i++)
    {
        NSArray *myWords2 = [myWords[i] componentsSeparatedByString:@"\" title=\""];
        
        NSRange firstRange = [myWords2[1] rangeOfString:@"\""];
        NSRange finalRange = NSMakeRange(0, firstRange.location);
        
        NSString *time = [myWords2[1] substringWithRange:finalRange];
        
        NSRange timestampRange = NSMakeRange(11, 5);
        NSString *timestamp = [myWords2[0] substringWithRange:timestampRange];
        
        DepartureTime *newDepartureTime = [[DepartureTime alloc] init];
        newDepartureTime.departureTimeStamp = timestamp;
        newDepartureTime.departureTimeInMinutes = time;
        
        // Add this question to the departureTimes array
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
    UITableViewCell *myCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Get the depature time record to be shown
    DepartureTime *departureTime = self.departureTimes[indexPath.row];
    
    // Assign the relevant information to the cell's text labels
    myCell.textLabel.text = departureTime.departureTimeInMinutes;
    myCell.detailTextLabel.text = departureTime.departureTimeStamp;
    
    return myCell;
}

- (BOOL)tableView:(nonnull UITableView *)tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return YES;
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
