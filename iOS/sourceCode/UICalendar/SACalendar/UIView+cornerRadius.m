//
//  UIView+cornerRadius.m
//  view设置圆角
//
//  Created by 郑连乐 on 2018/1/18.
//  Copyright © 2018年 apicloud. All rights reserved.
//

#import "UIView+cornerRadius.h"

@implementation UIView (cornerRadius)

- (void)lgg_viewRoundingCorners:(UIRectCorner)roundingCorners
{
    [self lgg_viewRoundingCorners:roundingCorners cornerRadius:25];
}

- (void)lgg_viewCancelRoundingCorners
{
    [self lgg_viewRoundingCorners:UIRectCornerAllCorners cornerRadius:0];
}

- (void)lgg_viewRoundingCorners:(UIRectCorner)roundingCorners cornerRadius:(CGFloat)cornerRadius
{
    UIBezierPath * bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:roundingCorners cornerRadii:CGSizeMake(cornerRadius , cornerRadius)];
    
    CAShapeLayer * layer = [[CAShapeLayer alloc] init];
    
    layer.frame = self.bounds;
    
    layer.path = bezierPath.CGPath;
    
    self.layer.mask = layer;
}

@end
