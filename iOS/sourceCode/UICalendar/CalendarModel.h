//
//  CalendarModel.h
//  UICalendar
//
//  Created by Answer on 2019/6/10.
//  Copyright © 2019 zhenhua.liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SACalendarConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface CalendarModel : NSObject

@property (nonatomic, strong) NSMutableArray *specilDate;

@property (nonatomic, assign) CGRect rect;

@property (strong, nonatomic) NSNumber *curShowYear;
@property (strong, nonatomic) NSNumber *curShowMonth;
@property (strong, nonatomic) NSNumber *getSelectDay;
@property (strong, nonatomic) NSMutableDictionary *nowDate;

@property (nonatomic, assign) scrollDirection switchMode;

@end

NS_ASSUME_NONNULL_END
