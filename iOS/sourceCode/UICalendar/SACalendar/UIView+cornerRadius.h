//
//  UIView+cornerRadius.h
//  view设置圆角
//
//  Created by 郑连乐 on 2018/1/18.
//  Copyright © 2018年 apicloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (cornerRadius)

- (void)lgg_viewRoundingCorners:(UIRectCorner)roundingCorners;
- (void)lgg_viewCancelRoundingCorners;
- (void)lgg_viewRoundingCorners:(UIRectCorner)roundingCorners cornerRadius:(CGFloat)cornerRadius;

@end
