//
//  UDVenueTableViewController.m
//  Undrunk
//
//  Created by Horace Williams on 9/15/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "UDVenueTableViewController.h"
#import "UDUntappdClient.h"
#import "SVProgressHUD.h"

@interface UDVenueTableViewController ()
@property (nonatomic, strong)NSDictionary *untappdVenue;
@property (nonatomic, strong)NSArray *venueBeers;
@end

@implementation UDVenueTableViewController

- (NSArray *)venueBeers {
    if (!_venueBeers) {
        _venueBeers = @[];
    }
    return  _venueBeers;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self loadVenueBeers];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [SVProgressHUD dismiss];
        });
    });

}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.venueBeers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell" forIndexPath:indexPath];
    cell.textLabel.text = [self.venueBeers objectAtIndex:indexPath.row][@"beer_name"];
    return cell;
}

- (void)loadVenueBeers {
    self.untappdVenue = [[UDUntappdClient client] untappdVenueForFoursquareID:self.foursquareVenue[@"id"]];
    self.venueBeers = [[UDUntappdClient client] recentBeersForUntappdVenue:self.untappdVenue[@"venue_id"]];
}
@end
