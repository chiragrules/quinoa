//
//  ActivityLike.h
//  quinoa
//
//  Created by Chirag Davé on 7/17/14.
//  Copyright (c) 2014 3eesho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "User.h"
#import "Activity.h"

@interface ActivityLike : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

+ (void)getActivityLikesByUser:(User *)user
                      success:(void (^) (NSArray *activityLikes))success
                        error:(void (^) (NSError *error))error;

+ (void)getActivityLikesByExpert:(User *)expert
                         success:(void (^)(NSArray *activityLikes))success
                           error:(void (^)(NSError *error))error;

+ (ActivityLike *)likeActivity:(Activity *)activity user:(User *)user expert:(User *)expert;

+ (void)unlikeActivity:(Activity *)activity
                expert:(User *)expert;

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) User *expert;
@property (strong, nonatomic) Activity *activity;
@property (assign) ActivityType activityType;


@end
