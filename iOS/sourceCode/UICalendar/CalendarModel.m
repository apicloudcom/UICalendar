//
//  CalendarModel.m
//  UICalendar
//
//  Created by Answer on 2019/6/10.
//  Copyright © 2019 zhenhua.liu. All rights reserved.
//

#import "CalendarModel.h"

@implementation CalendarModel
- (NSMutableDictionary *)nowDate {
    if (!_nowDate) {
        _nowDate = [NSMutableDictionary dictionary];
    }
    return _nowDate;
}
- (NSMutableArray *)specilDate {
    if (!_specilDate) {
        _specilDate = [NSMutableArray array];
    }
    return _specilDate;
}
@end
