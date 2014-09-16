//
//  UDAppDelegate.m
//  Undrunk
//
//  Created by Horace Williams on 9/15/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "UDAppDelegate.h"
#import "UDFoursquareClient.h"

@implementation UDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self configureFouresquare];
    return YES;
}

- (void)configureFouresquare {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"configuration" ofType:@"plist"];
    NSDictionary *configuration = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    [UDFoursquareClient client].clientID = configuration[@"FOURSQUARE_CLIENT_ID"];
    [UDFoursquareClient client].clientSecret = configuration[@"FOURSQUARE_CLIENT_SECRET"];
}


@end
