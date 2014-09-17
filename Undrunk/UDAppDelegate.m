//
//  UDAppDelegate.m
//  Undrunk
//
//  Created by Horace Williams on 9/15/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "UDAppDelegate.h"
#import "UDFoursquareClient.h"
#import "UDUntappdClient.h"

@implementation UDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self configureClients];
    [self fetchUserBeersAsync];
    return YES;
}

- (void)configureClients {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"configuration" ofType:@"plist"];
    NSDictionary *configuration = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    [UDFoursquareClient client].clientID = configuration[@"FOURSQUARE_CLIENT_ID"];
    [UDFoursquareClient client].clientSecret = configuration[@"FOURSQUARE_CLIENT_SECRET"];
    [UDUntappdClient client].clientID = configuration[@"UNTAPPD_CLIENT_ID"];
    [UDUntappdClient client].clientSecret = configuration[@"UNTAPPD_CLIENT_SECRET"];
}

- (void)fetchUserBeersAsync {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSArray *beers = [[UDUntappdClient client] uniqueBeersForUser:@"jimmyburdette"];
        NSLog(@"got %d beers for jimmy", [beers count]);
    });
}

@end
