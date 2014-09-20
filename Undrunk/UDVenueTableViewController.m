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
#import "UDUserDataStore.h"
#import "UDCredentialStore.h"

@interface UDVenueTableViewController ()
@property (nonatomic, strong)NSDictionary *untappdVenue;
@property (nonatomic, strong)NSArray *venueBeers;
@property (nonatomic, strong)NSArray *untriedBeers;
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
    return [self.untriedBeers count];
}

- (NSArray *)calculateUntriedBeers {
    NSLog(@"got %d venue beers %@", [self.venueBeers count], self.untappdVenue);
    NSLog(@"have %d user beers", [[self userBeers] count]);

    NSMutableArray *venueIds = [[NSMutableArray alloc] init];
    NSMutableArray *userIds = [[NSMutableArray alloc] init];

    for (NSDictionary *beer in self.venueBeers) {
        [venueIds addObject:beer[@"bid"]];
    }
    for (NSDictionary *beer in [self userBeers]) {
        [userIds addObject:beer[@"bid"]];
    }

    NSMutableArray *venueIdsWithoutUser = [venueIds mutableCopy];
    [venueIdsWithoutUser removeObjectsInArray:userIds];

    NSMutableArray *untried = [[NSMutableArray alloc] init];
    for (NSDictionary *venueBeer in self.venueBeers) {
        if ([venueIdsWithoutUser containsObject:venueBeer[@"bid"]]) {
            [untried addObject:venueBeer];
        }
    }
    NSLog(@"going to return %d untried beers", [untried count]);
    
//    NSMutableArray *removed=  [self.venueBeers mutableCopy];
//    [removed removeObjectsInArray:untried];
//    NSLog(@"removed beers were: %@", removed);
    
    return [untried copy];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell" forIndexPath:indexPath];
    cell.textLabel.text = [[self untriedBeers] objectAtIndex:indexPath.row][@"beer_name"];
    return cell;
}

- (NSArray *)userBeers {
    return [[UDUserDataStore sharedStore] beersForCurrentUser];
}

- (void)loadVenueBeers {
    self.untappdVenue = [[UDUntappdClient client] untappdVenueForFoursquareID:self.foursquareVenue[@"id"]];
    self.venueBeers = [[UDUntappdClient client] recentBeersForUntappdVenue:self.untappdVenue[@"venue_id"]];
    self.untriedBeers = [[self calculateUntriedBeers] copy];
    NSLog(@"got %d beers for venue %@", [self.venueBeers count], self.untappdVenue);
    
}

- (IBAction)logOut:(id)sender {
    [[[UDCredentialStore alloc] init] clearSavedCredentials];
    [self.navigationController popToRootViewControllerAnimated:YES];
    NSLog(@"log otu");
}
@end
