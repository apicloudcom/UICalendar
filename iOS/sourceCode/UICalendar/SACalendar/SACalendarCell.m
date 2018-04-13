//
//  SACalendarCell.m
//  SACalendarExample
//
//  Created by Nop Shusang on 7/12/14.
//  Copyright (c) 2014 SyncoApp. All rights reserved.
//
//  Distributed under MIT License

#import "SACalendarCell.h"
#import "SACalendarConstants.h"
#import "NSDictionaryUtils.h"
#import "UZAppUtils.h"


@implementation SACalendarCell
/**
 *  Draw the basic components of the cell, including the top grey line, the red current date circle,
 *  the black selected circle and the date label. Customized the cell apperance by editing this function.
 *
 *  @param frame - size of the cell
 *
 *  @return initialized cell
 */
extern int kUZUICalendarMultipleSelect;
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //* labelToCellRatio
        self.dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.dateLabel.textAlignment = NSTextAlignmentCenter;
        
        CGRect labelFrame = self.dateLabel.frame;
        CGSize labelSize = labelFrame.size;
        
        CGPoint origin;
        int length;
        if (labelSize.width > labelSize.height) {
            origin.x = (labelSize.width - labelSize.height * circleToCellRatio) / 2;
            origin.y = (labelSize.height * (1 - circleToCellRatio)) / 2;
            length = labelSize.height * circleToCellRatio;
        } else {
            origin.x = (labelSize.width * (1 - circleToCellRatio)) / 2;
            origin.y = (labelSize.height - labelSize.width * circleToCellRatio) / 2;
            length = labelSize.width * circleToCellRatio;
        }
        NSDictionary *styles = [[NSDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"UZMarkDic"]];
        CGRect rect = CGRectMake(0,0,frame.size.width,frame.size.height);
        self.circleView = [[UIView alloc] initWithFrame:rect];
        
        _todayImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _todayImg.contentMode = UIViewContentModeScaleAspectFit;
        [self.circleView addSubview:_todayImg];
        
        NSDictionary *date = [styles dictValueForKey:@"date" defaultValue:@{}];
        
        #pragma mark - ---
//        self.selectedView = [[UIView alloc] initWithFrame:rect];
//        self.selectedView = [[UIView alloc] initWithFrame:CGRectMake(rect.origin.x-0.5, rect.origin.y+5, rect.size.width+1, rect.size.height-10)];
        self.selectedView = kUZUICalendarMultipleSelect ? [[UIView alloc] initWithFrame:CGRectMake(rect.origin.x-0.5, rect.origin.y+5, rect.size.width+1, rect.size.height-10)] : [[UIView alloc] initWithFrame:rect];
        
        NSString *selectedBg = [date stringValueForKey:@"selectedBg" defaultValue:@""];
        _img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _img.contentMode = UIViewContentModeScaleAspectFit;
        if ([UZAppUtils isValidColor:selectedBg]) {
            self.selectedView.backgroundColor = [UZAppUtils colorFromNSString:selectedBg];
        } else {
            _img.image = [UIImage imageWithContentsOfFile:[self.delegate getPathCell:selectedBg]];
            self.selectedView.backgroundColor = [UIColor clearColor];
        }
        [self.selectedView addSubview:_img];

//        [self.viewForBaselineLayout addSubview:self.topLineView];
        [self.viewForBaselineLayout addSubview:self.circleView];
        [self.viewForBaselineLayout addSubview:self.selectedView];
        [self.viewForBaselineLayout addSubview:self.dateLabel];
        [self.viewForBaselineLayout addSubview:self.specialView];
        
    }
    return self;
}

@end
