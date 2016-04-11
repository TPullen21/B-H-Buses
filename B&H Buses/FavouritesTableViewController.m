//
//  FavouritesTableViewController.m
//  B&H Buses
//
//  Created by Tom Pullen on 11/04/2016.
//  Copyright © 2016 Tom Pullen. All rights reserved.
//

#import "FavouritesTableViewController.h"
#import "Constants.m"

@interface FavouritesTableViewController ()

@property (strong, nonatomic) NSMutableArray *favouritedStops;

@end

@implementation FavouritesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.favouritedStops = [self getFavouritedStops];
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
    
    cell.textLabel.text = self.favouritedStops[indexPath.row];
    
    return cell;
}

-(void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
}

#pragma mark - Helper Methods

- (NSMutableArray *)getFavouritedStops {
    
    NSArray *favouritedStops = [[NSUserDefaults standardUserDefaults] arrayForKey:FAVOURITED_STOPS_KEY];
    
    if (!favouritedStops) {
        favouritedStops = [[NSArray alloc] init];
    }
    
    return [favouritedStops mutableCopy];
}

@end
