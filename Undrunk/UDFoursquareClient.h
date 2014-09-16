//
//  UDFoursquareClient.h
//  Undrunk
//
//  Created by Horace Williams on 9/15/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface UDFoursquareClient : NSObject
@property (nonatomic, strong) NSString *clientID;
@property (nonatomic, strong) NSString *clientSecret;

+(instancetype)client;
-(NSArray *)venuesForLocation:(CLLocation *)location;
@end
