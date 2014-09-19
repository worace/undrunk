//
//  UDCredentialStore.m
//  Undrunk
//
//  Created by Horace Williams on 4/22/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "UDCredentialStore.h"
#import "SSKeychain.h"

#define SERVICE_NAME @"Undrunk"
#define AUTH_TOKEN_KEY @"UntappdOauthToken"

@implementation UDCredentialStore

- (BOOL)isLoggedIn {
    return [self authToken] != nil;
}

- (void)clearSavedCredentials {
    NSLog(@"clearing credentials");
    [SSKeychain deletePasswordForService:SERVICE_NAME account:AUTH_TOKEN_KEY];
}

- (NSString *)authToken {
    return [SSKeychain passwordForService:SERVICE_NAME account:AUTH_TOKEN_KEY];
}

- (void)setAuthToken:(NSString *)authToken {
    [SSKeychain setPassword:authToken
                 forService:SERVICE_NAME
                    account:AUTH_TOKEN_KEY];
}

@end
