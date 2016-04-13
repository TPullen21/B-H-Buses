//
//  FavouritesTableViewController.m
//  B&H Buses
//
//  Created by Tom Pullen on 11/04/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import "FavouritesTableViewController.h"
#import "DepartureTimesViewController.h"
#import "Constants.m"
#import "Stop.h"

@interface FavouritesTableViewController ()

@property (strong, nonatomic) NSArray *favouritedStops;
@property (strong, nonatomic) Stop *selectedStop;

@end

@implementation FavouritesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.favouritedStops = [Stop getFavouritedStopsArrayWithContext:self.context];
    [self.tableView reloadData];
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
    //return [self.downloadedRoutes count];
    return [self.favouritedStops count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"favouritedStopCell" forIndexPath:indexPath];
    
    Stop *stop = self.favouritedStops[indexPath.row];
    
    cell.textLabel.text = stop.stopName;
    
    return cell;
}

- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    self.selectedStop = self.favouritedStops[indexPath.row];
    [self performSegueWithIdentifier:@"showFavouriteDepartureTimesVC" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[DepartureTimesViewController class]]) {
        DepartureTimesViewController *departureTimesVC = segue.destinationViewController;
        departureTimesVC.stop = self.selectedStop;
    }
}

@end
