//
//  ProfileCell.h
//  quinoa
//
//  Created by Amie Kweon on 7/13/14.
//  Copyright (c) 2014 3eesho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileViewWithActivity.h"
#import "User.h"

@interface ProfileCell : UICollectionViewCell

@property (nonatomic, strong) User *user;
@property (strong, nonatomic) ProfileViewWithActivity *profileView;
@property BOOL isExpertView;
@property id goalDelegate;
@end
