//
//  UDUserDataStore.m
//  Undrunk
//
//  Created by Horace Williams on 9/18/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "UDUserDataStore.h"
#import "UDCredentialStore.h"
#import "UDUntappdClient.h"

@interface UDUserDataStore ()
@property (nonatomic, strong) NSMutableDictionary *userData;
@property (nonatomic, strong) UDCredentialStore *credentialStore;
@end

@implementation UDUserDataStore
+(instancetype)sharedStore {
    static UDUserDataStore *sharedStore;
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    return sharedStore;
}

- (instancetype)init {
    return [[self class] sharedStore];
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        self.credentialStore = [[UDCredentialStore alloc] init];
    }
    return self;
}

- (NSMutableDictionary *)userData {
    if (!_userData) {
        _userData = [self loadSavedData];
    }
    return _userData;
}

- (NSArray *)beersForCurrentUser {
    NSString *token = [self.credentialStore authToken];
    if (token == nil) {
        return @[];
    } else if (self.userData[token] == nil) {
        self.userData[token] = @[];
        return self.userData[token];
    } else {
        return self.userData[token];
    }
}

- (void)refreshBeersForCurrentUser {
    if (![[[UDCredentialStore alloc] init] isLoggedIn]) {
        NSLog(@"not logged in, can't refresh beers");
    } else {
        NSString *token = [self.credentialStore authToken];
        NSLog(@"refresh user beeeeers!");
        NSArray *beers = [[UDUntappdClient client] uniqueBeersForUser:token];
        NSLog(@" set %d beers for token %@", [beers count], token);
        self.userData[token] = beers;
    }
}

- (NSString *)itemArchivePath {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    return [documentDirectory stringByAppendingPathComponent:@"com.WoracesWorkshop.Undrunk.UserData"];
}

- (BOOL)saveChanges {
    NSLog(@"save changes for user data: %@", self.userData);
    NSString *path = [self itemArchivePath];
    return [NSKeyedArchiver archiveRootObject:self.userData toFile:path];
}

- (NSMutableDictionary *)loadSavedData {
    NSMutableDictionary *savedData = [NSKeyedUnarchiver unarchiveObjectWithFile:[self itemArchivePath]];
    if (savedData) {
        return savedData;
    } else {
        return [[NSMutableDictionary alloc] init];
    }
}

@end
