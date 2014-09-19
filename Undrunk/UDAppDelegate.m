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
#import "UDCredentialStore.h"
#import "UDUserDataStore.h"

@implementation UDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [[[UDCredentialStore alloc] init] clearSavedCredentials];
    NSLog(@"saved beers count: %d", [[[UDUserDataStore sharedStore] beersForCurrentUser] count]);
    [self configureClients];
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"opened app from url: %@", url);
    NSString *urlString = [url absoluteString];
    if ([urlString rangeOfString:@"authenticate"].location != NSNotFound) {
        NSScanner *scanner = [NSScanner scannerWithString:urlString];
        [scanner scanUpToString:@"=" intoString:nil];
        [scanner scanString:@"=" intoString:nil];
        NSString *token = [urlString substringFromIndex:[scanner scanLocation]];
        NSLog(@"authenticate with token: %@", token);
        [[[UDCredentialStore alloc] init] setAuthToken:token];
        NSLog(@"token is now: %@", [[[UDCredentialStore alloc] init] authToken]);
        [[UDUserDataStore sharedStore] refreshBeersForCurrentUser];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.WoracesWorkshop.Undrunk.UserAuthenticated" object:nil];
    }
    return  YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"will resign active");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"entered background!");
    [[UDUserDataStore sharedStore] saveChanges];
}

@end
