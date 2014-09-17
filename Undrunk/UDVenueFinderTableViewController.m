//
//  UDVenueFinderTableViewController.m
//  Undrunk
//
//  Created by Horace Williams on 9/15/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "UDVenueFinderTableViewController.h"
#import "SVProgressHUD.h"
#import <CoreLocation/CoreLocation.h>
#import "UDFoursquareClient.h"
#import "UDVenueTableViewController.h"

@interface UDVenueFinderTableViewController ()
@property (nonatomic, strong) NSArray *venues;
@end

@implementation UDVenueFinderTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.venues = @[];
//        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"defaultCell"];
    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"hi there");
    [super viewDidLoad];
    [SVProgressHUD show];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self loadVenues];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"dismiss hud");
            [SVProgressHUD dismiss];
        });
    });
}

- (void)loadVenues {
    self.venues = [[UDFoursquareClient client] venuesForLocation:[self userLocation]];
    [self.tableView reloadData];
}

- (CLLocation *)userLocation {
    return [[CLLocation alloc] initWithLatitude:38.931783 longitude:-77.028438];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.venues count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.venues objectAtIndex:indexPath.row][@"name"];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"selectVenue"]) {
        NSDictionary *venue = [self.venues objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        UDVenueTableViewController *dest = segue.destinationViewController;
        dest.foursquareVenue = venue;
    }
}

@end
