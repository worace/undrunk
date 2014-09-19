//
//  UDUserDataStore.h
//  Undrunk
//
//  Created by Horace Williams on 9/18/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UDUserDataStore : NSObject
- (NSArray *)beersForCurrentUser;
- (void)refreshBeersForCurrentUser;
+ (instancetype)sharedStore;
- (BOOL)saveChanges;
@end
