//
//  UDFoursquareClient.m
//  Undrunk
//
//  Created by Horace Williams on 9/15/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "UDFoursquareClient.h"

@implementation UDFoursquareClient
+(instancetype)client {
    static UDFoursquareClient *client;
    if (!client) {
        client = [[self alloc] initPrivate];
    }
    return client;
}

- (instancetype)init {
    return [[self class] client];
}

- (instancetype)initPrivate {
    self = [super init];
    return self;
}

- (NSArray *)venuesForLocation:(CLLocation *)location {
    NSLog(@"get locations from foursequare with client id %@, client secret %@ for location %@", self.clientID, self.clientSecret, location);
    NSURLRequest *request = [NSURLRequest requestWithURL:[self queryURLForLocation:location]];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (!error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
        NSArray *venues = json[@"response"][@"venues"];
        NSLog(@"%lu venues found", (unsigned long)[venues count]);
        return venues;
    } else {
        NSLog(@"no venues found for location %@, error: %@", location, error);
        return @[];
    }
}

- (NSURL *)queryURLForLocation:(CLLocation *)location {
//    https://api.foursquare.com/v2/venues/search?ll=38.931783,-77.028438&client_id=CLIENT_ID&client_secret=CLIENT_SECRET&v=YYYYMMDD
    NSString *base = @"https://api.foursquare.com/v2/venues/search";
    NSString *full = [NSString stringWithFormat:@"%@?ll=%f,%f&client_id=%@&client_secret=%@&v=20140915", base, location.coordinate.latitude, location.coordinate.longitude, self.clientID, self.clientSecret];
    return [NSURL URLWithString:full];
}
@end
