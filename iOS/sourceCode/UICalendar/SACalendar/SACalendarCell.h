//
//  SACalendarCell.h
//  SACalendarExample
//
//  Created by Nop Shusang on 7/12/14.
//  Copyright (c) 2014 SyncoApp. All rights reserved.
//
//  Distributed under MIT License

#import <UIKit/UIKit.h>

@protocol CalenCell <NSObject>

- (NSString *)getPathCell:(NSString *)path;

@end

@interface SACalendarCell : UICollectionViewCell

/**
 *  grey line above the label
 */
@property UIView *topLineView;

/**
 *  a circle that appears on the current date
 */
@property UIView *circleView;

/**
 *  a circle that appears on the selected date
 */
@property UIView *selectedView;

/**
 *  the label showing the cell's date
 */
@property UILabel *dateLabel;

@property (nonatomic , strong) UIImageView *specialImg;
@property (nonatomic , strong) UIView *specialView;

@property (nonatomic , assign) id <CalenCell> delegate;
@property (nonatomic , strong) UIImageView *img;
@property (nonatomic , strong) UIImageView *todayImg;
@end
