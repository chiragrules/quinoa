//
//  PhysicalActivity.m
//  quinoa
//
//  Created by Amie Kweon on 7/14/14.
//  Copyright (c) 2014 3eesho. All rights reserved.
//

#import "PhysicalActivity.h"
#import "Utils.h"

@interface PhysicalActivity ()

@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;
@property (weak, nonatomic) IBOutlet UILabel *blurbLabel;
@property (weak, nonatomic) IBOutlet UIView *divider;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation PhysicalActivity

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UINib *nib = [UINib nibWithNibName:@"PhysicalActivity" bundle:nil];
        NSArray *objects = [nib instantiateWithOwner:self options:nil];
        [self addSubview:objects[0]];
    }
    return self;
}


- (void)setActivity:(Activity *)activity {
    _activity = activity;

    int minutes = lroundf([self.activity.activityValue floatValue] / 60);
    if (minutes >= 60) {
        float hours = (minutes / 60);
        self.valueLabel.text = [NSString stringWithFormat:@"%.2f", hours];
        self.unitLabel.text = @"Hours of activity";
    } else {
        self.valueLabel.text = [NSString stringWithFormat:@"%d", minutes];
        self.unitLabel.text = @"Minutes of activity";
    }
    self.valueLabel.font = [UIFont fontWithName:@"SourceSansPro-Semibold" size:38];

    self.descriptionLabel.text = self.activity.descriptionText;
    // TODO: Figure out the best way to calculate average of activity value
    //blurbLabel = @"";
    if ([self.activity.descriptionText length] > 0) {
        self.divider.hidden = NO;
        self.descriptionLabel.hidden = NO;
        self.divider.backgroundColor = [Utils getLightGray];
    } else {
        // TODO: Shorten height when description text is not provided
        //self.physicalBottomConstraint.constant = 0;
        //            CGRect currentFrame = self.frame;
        //            currentFrame.size.height = currentFrame.size.height - 10;
        //            self.frame = currentFrame;
    }
    [self.valueLabel setTextColor:[Utils getVibrantBlue]];
    [self.unitLabel setTextColor:[Utils getVibrantBlue]];
    [self.blurbLabel setTextColor:[Utils getGray]];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
