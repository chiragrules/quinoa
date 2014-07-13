//
//  ActivityCell.m
//  quinoa
//
//  Created by Amie Kweon on 7/12/14.
//  Copyright (c) 2014 3eesho. All rights reserved.
//

#import "ActivityCell.h"
#import "Utils.h"

@interface ActivityCell ()

@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightBlurbLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightUnitLabel;

@property (weak, nonatomic) IBOutlet UILabel *physicalValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *physicalUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *physicalBlurbLabel;
@property (weak, nonatomic) IBOutlet UILabel *physicalDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *physicalDivider;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *physicalBottomConstraint;

@end

@implementation ActivityCell


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CALayer* layer = self.layer;
        [layer setCornerRadius:5.0f];
        [layer setMasksToBounds:YES];
        [layer setBorderWidth:0.5f];
        [layer setBorderColor:[Utils getGray].CGColor];
    }
    return self;
}



- (void)setActivity:(Activity *)activity {
    _activity = activity;
    if (self.subviews.count > 0) {
        [self.subviews[0] removeFromSuperview];
    }

    [self addView];

    if (self.activity.activityType == Eating) {

    } else if (self.activity.activityType == Physical) {
        int minutes = lroundf([self.activity.activityValue floatValue] / 60);
        if (minutes >= 60) {
            float hours = (minutes / 60);
            self.physicalValueLabel.text = [NSString stringWithFormat:@"%.2f", hours];
            self.physicalUnitLabel.text = @"Hours of activity";
        } else {
            self.physicalValueLabel.text = [NSString stringWithFormat:@"%d", minutes];
            self.physicalUnitLabel.text = @"Minutes of activity";
        }
        self.physicalDescriptionLabel.text = self.activity.descriptionText;
        // TODO: Figure out the best way to calculate average of activity value
        //self.physicalBlurbLabel.text = @"";
        if ([self.activity.descriptionText length] > 0) {
            self.physicalDivider.hidden = NO;
            self.physicalDescriptionLabel.hidden = NO;
        } else {
            // TODO: Shorten height when description text is not provided
            //self.physicalBottomConstraint.constant = 0;
//            CGRect currentFrame = self.frame;
//            currentFrame.size.height = currentFrame.size.height - 10;
//            self.frame = currentFrame;
        }
        [self.physicalValueLabel setTextColor:[Utils getVibrantBlue]];
        [self.physicalUnitLabel setTextColor:[Utils getVibrantBlue]];
        [self.physicalBlurbLabel setTextColor:[Utils getGray]];
    } else if (self.activity.activityType == Weight) {
        self.weightLabel.text = [NSString stringWithFormat:@"%@", self.activity.activityValue];
        [self.weightLabel setTextColor:[Utils getGreen]];
        [self.weightUnitLabel setTextColor:[Utils getGreen]];
        [self.weightBlurbLabel setTextColor:[Utils getGray]];
    }
}

- (void)addView {

    NSString *nibName = @"";
    switch (self.activity.activityType) {
        case Eating:
            nibName = @"Eating";
            break;
        case Physical:
            nibName = @"Physical";
            break;
        case Weight:
            nibName = @"Weight";
            break;
    }

    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:self options:nil];
    [self addSubview:objects[0]];
}

- (CGSize)intrinsicContentSize {
    UICollectionViewCell *cell = self.subviews[0];
    return cell.bounds.size;
}

//- (void)drawRect:(CGRect)rect
//{
//    // draw a rounded rect bezier path filled with blue
//    CGContextRef aRef = UIGraphicsGetCurrentContext();
//    CGContextSaveGState(aRef);
//    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:5.0f];
//    [bezierPath setLineWidth:5.0f];
//    [[UIColor blackColor] setStroke];
//    UIColor *fillColor = [UIColor colorWithRed:0.529 green:0.808 blue:0.922 alpha:1]; // color equivalent is #87ceeb
//    [fillColor setFill];
//    [bezierPath stroke];
//    [bezierPath fill];
//    CGContextRestoreGState(aRef);
//}

@end
