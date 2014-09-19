//
//  UDUntappdClient.m
//  Undrunk
//
//  Created by Horace Williams on 9/15/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "UDUntappdClient.h"

@implementation UDUntappdClient
+(instancetype)client {
    static UDUntappdClient *client;
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

- (NSDictionary *)untappdVenueForFoursquareID:(NSString *)id {
    NSURL *url = [self queryURLForFoursquareVenueID:id];
    NSDictionary *data = [self fetchURLFromUntappdApi:url];
    
    if ([[data allKeys] count] > 0) {
        return [data[@"response"][@"venue"][@"items"] objectAtIndex:0];
    } else {
        return @{};
    }
}

- (NSDictionary *)fetchURLFromUntappdApi:(NSURL *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (!error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
        return json;
    } else {
        NSLog(@"error fetching url %@, error: %@", url, error);
        return @{};
    }
}

- (NSArray *)uniqueBeersForUser:(NSString *)userName {
    NSLog(@"will fetch user beers from url %@", [self queryURLForUserDistinctBeers:userName withOffset:0]);
    NSMutableArray *beers = [[NSMutableArray alloc] init];
    BOOL reachedEnd = NO;
    int iteration = 0;

    while (!reachedEnd) {
        NSURL *url = [self queryURLForUserDistinctBeers:userName withOffset:(iteration*25)];
        NSLog(@"fetching beers for jimmy on iteration %d wiht URL %@", iteration, url);
        NSDictionary *data = [self fetchURLFromUntappdApi:url];
        NSArray *newBeers;
        if (([data count] > 0) && ([data[@"response"] count] > 0)) newBeers = data[@"response"][@"beers"][@"items"];
        [beers addObjectsFromArray:newBeers];
        NSLog(@"adding %d newBeers", [newBeers count]);
        if ([newBeers count] < 25) reachedEnd = YES;
//        if (iteration > 5) reachedEnd = YES;
        iteration ++;
    }
    return [beers copy];
}

- (NSArray *)recentBeersForUntappdVenue:(NSString *)venueID {
    // Get N batches of most recent checkins by paging through with max_id
    // param which is the most recent checkin that will be returned
    int count = 0;
    NSMutableArray *checkins = [[NSMutableArray alloc] init];
    
    while (count < 4) {
        if ([checkins count] > 0) {
            NSDictionary *lastCheckin = [checkins lastObject];
            NSDictionary *data = [self fetchURLFromUntappdApi:[self queryURLForUntappdVenueFeed:venueID withMaxID:lastCheckin[@"checkin_id"]]];
            if ([[data allKeys] count] > 0) {
                [checkins addObjectsFromArray:data[@"response"][@"checkins"][@"items"]];
            }
        } else {
            NSDictionary *data = [self fetchURLFromUntappdApi:[self queryURLForUntappdVenueFeed:venueID withMaxID:nil]];
            if ([[data allKeys] count] > 0) {
                [checkins addObjectsFromArray:data[@"response"][@"checkins"][@"items"]];
            }
        }
        count ++;
    }
    NSMutableArray *beers = [[NSMutableArray alloc] init];
    for (NSDictionary *checkin in checkins) {
        [beers addObject:checkin[@"beer"]];
    }
    return [[NSSet setWithArray:[beers copy]] allObjects];
}

- (NSString *)untappdURLBase {
    return @"https://api.untappd.com/v4";
}

- (NSURL *)queryURLForFoursquareVenueID:(NSString *)venueID {
    NSString *url = [NSString stringWithFormat:@"%@/venue/foursquare_lookup/%@?client_id=%@&client_secret=%@", [self untappdURLBase], venueID, self.clientID, self.clientSecret];
    return [NSURL URLWithString:url];
}

- (NSURL *)queryURLForUntappdVenueFeed:(NSString *)venueID withMaxID:(NSString *)maxID {
    if (maxID) {
        NSString *url = [NSString stringWithFormat:@"%@/venue/checkins/%@?client_id=%@&client_secret=%@&max_id=%@", [self untappdURLBase], venueID, self.clientID, self.clientSecret, maxID];
        return [NSURL URLWithString:url];

    } else {
        NSString *url = [NSString stringWithFormat:@"%@/venue/checkins/%@?client_id=%@&client_secret=%@", [self untappdURLBase], venueID, self.clientID, self.clientSecret];
        return [NSURL URLWithString:url];
    }
}

- (NSURL *)queryURLForUserDistinctBeers:(NSString *)username withOffset:(int)offset {
    NSString *url = [NSString stringWithFormat:@"%@/user/beers/%@?client_id=%@&client_secret=%@&offset=%d", [self untappdURLBase], username, self.clientID, self.clientSecret, offset];
    return  [NSURL URLWithString:url];
}


//
//- (NSArray *)venuesForLocation:(CLLocation *)location {
//    NSLog(@"get locations from foursequare with client id %@, client secret %@ for location %@", self.clientID, self.clientSecret, location);
//    NSURLRequest *request = [NSURLRequest requestWithURL:[self queryURLForLocation:location]];
//    NSURLResponse *response = nil;
//    NSError *error = nil;
//    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//    if (!error) {
//        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
//        NSArray *venues = json[@"response"][@"venues"];
//        NSLog(@"%lu venues found", (unsigned long)[venues count]);
//        return venues;
//    } else {
//        NSLog(@"no venues found for location %@, error: %@", location, error);
//        return @[];
//    }
//}

@end
