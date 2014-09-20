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
#import "UDCredentialStore.h"

@interface UDVenueFinderTableViewController ()
@property (nonatomic, strong) NSArray *venues;
@property (nonatomic, strong) UDCredentialStore *credentialStore;
@property (nonatomic, strong) UIViewController *loginModal;
@end

@implementation UDVenueFinderTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.venues = @[];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@" venue finder will appear");
    [self requireLogin];
}

- (void)viewDidLoad
{
    self.credentialStore = [[UDCredentialStore alloc] init];
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

- (void)requireLogin {
    NSLog(@"token is now: %@", [[[UDCredentialStore alloc] init] authToken]);
    NSLog(@"store %@", self.credentialStore);
    if (![self.credentialStore isLoggedIn]) {
        NSLog(@"not logged in!");
        UIWebView *webView = [[UIWebView alloc] init];
        NSURLRequest *untappd = [[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:@"https://untappd.com/oauth/authenticate/?client_id=EAEFF1E766047A9B5859E28E902523CAC9AC23E0&response_type=token&redirect_url=com.WoracesWorkshop.Undrunk%3A%2F%2Fauthenticate"]];
        [webView loadRequest:untappd];
        
        self.loginModal = [[UIViewController alloc] init];
        self.loginModal.view = webView;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearLoginModal) name:@"com.WoracesWorkshop.Undrunk.UserAuthenticated" object:nil];
        [self.navigationController pushViewController:self.loginModal animated:YES];
    }
}

- (void)clearLoginModal {
    NSLog(@"clear login modal, got notif");
    [self.navigationController popViewControllerAnimated:YES];
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

- (IBAction)logOut:(id)sender {
    [[[UDCredentialStore alloc] init] clearSavedCredentials];
    [self requireLogin];
    NSLog(@"log out from venue list");
}
@end
