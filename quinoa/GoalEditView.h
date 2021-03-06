//
//  GoalEditView.h
//  quinoa
//
//  Created by Amie Kweon on 7/31/14.
//  Copyright (c) 2014 3eesho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Goal.h"
#import "User.h"
#import "ASValueTrackingSlider.h"

@interface GoalEditView : UIView <ASValueTrackingSliderDataSource>

@property (nonatomic, strong) Goal *goal;
@property (nonatomic, strong) User *user;

@property (nonatomic, strong) NSNumber *targetWeight; // pounds
@property (nonatomic, strong) NSNumber *targetDate; // # of days
@property (nonatomic, strong) NSNumber *targetDailyDuration; // seconds

@end
