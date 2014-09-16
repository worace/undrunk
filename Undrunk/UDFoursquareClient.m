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
    return @[];
}
@end
