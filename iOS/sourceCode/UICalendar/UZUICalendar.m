/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import "UZUICalendar.h"
#import "NSDictionaryUtils.h"
#import "UZAppUtils.h"
#import "SACalendar.h"
#import "DateUtil.h"
#import "dateModel.h"
#import "specialDatesModel.h"

@interface UZUICalendar ()
<SACalendarDelegate> {
    UIView *_superView;
    NSInteger openCbid;
    scrollDirection _switchMode;
    SACalendar *_calendar;
    NSMutableArray *_specilDate;
    CGRect _rect;
    NSNumber *_curShowYear, *_curShowMonth, *_getSelectDay;
}

@property (nonatomic, strong) NSMutableDictionary *nowDate;

@end

@implementation UZUICalendar

- (void)dispose {
    _calendar = nil;
    _superView = nil;
    _nowDate = nil;
    _specilDate = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"currentShowDate" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"currentShowDay" object:nil];
}

#pragma mark - interFace -

- (void)open:(NSDictionary *)params_ {
    if (_superView) {
        [[_superView superview] bringSubviewToFront:_superView];
        _superView.hidden = NO;
        return;
    }
    NSDictionary *rect = [params_ dictValueForKey:@"rect" defaultValue:@{}];
    _nowDate = [[NSMutableDictionary alloc] init];
    NSString *switchStr = [params_ stringValueForKey:@"switchMode" defaultValue:@"vertical"];
    if ([switchStr isEqualToString:@"vertical"]) {
        _switchMode = ScrollDirectionVertical;
    } else if ([switchStr isEqualToString:@"horizontal"]) {
        _switchMode = ScrollDirectionHorizontal;
    } else if ([switchStr isEqualToString:@"none"]) {
        _switchMode = ScrollDirectionNone;
    } else {
        _switchMode = ScrollDirectionVertical;
    }
    float x = [rect floatValueForKey:@"x" defaultValue:0];
    float y = [rect floatValueForKey:@"y" defaultValue:0];
    openCbid = [params_ floatValueForKey:@"cbId" defaultValue:-1];
    NSString *fixedOn = [params_ stringValueForKey:@"fixedOn" defaultValue:nil];
    float width = [UIScreen mainScreen].bounds.size.width;
    if (fixedOn != nil) {
        UIView *mainView = [self getViewByName:fixedOn];
        width = mainView.frame.size.width;
    }
    float w = [rect floatValueForKey:@"w" defaultValue:width];
    float h = [rect floatValueForKey:@"h" defaultValue:220];
    NSArray *dates = [params_ arrayValueForKey:@"specialDate" defaultValue:@[]];
    _specilDate = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *dataDict in dates) {
        specialDatesModel *spDatesModel = [[specialDatesModel alloc]initWithSpecialDates:dataDict];
        [_specilDate addObject:spDatesModel];
    }
    NSDictionary *styles = [params_ dictValueForKey:@"styles" defaultValue:@{}];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:styles];
    NSString *bg = [dict stringValueForKey:@"bg" defaultValue:@"rgba(0,0,0,0)"];
    if (!bg.length) {
        bg = @"rgba(0,0,0,0)";
    }
    if (![UZAppUtils isValidColor:bg]) {
        bg = [self getPathWithUZSchemeURL:bg];
        [dict setObject:bg forKey:@"bg"];
    }
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"UZMarkDic"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _rect = CGRectMake(0, 0, w, h);
    _calendar = [[SACalendar alloc]initWithFrame:_rect
                                 scrollDirection:_switchMode
                                   pagingEnabled:YES
                                     specialDate:_specilDate];
    _superView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    _calendar.delegate = self;
    [_superView addSubview:_calendar];
    BOOL fixed = [params_ boolValueForKey:@"fixed" defaultValue:YES];
    [self addSubview:_superView fixedOn:fixedOn fixed:fixed];
    //callback
    NSMutableDictionary *sendDict = [NSMutableDictionary dictionaryWithCapacity:2];
    NSInteger current_date = [[DateUtil getCurrentDate]intValue];
    NSInteger current_month = [[DateUtil getCurrentMonth]intValue];
    NSInteger current_year = [[DateUtil getCurrentYear]intValue];
    [sendDict setObject:[NSNumber numberWithInteger:current_year] forKey:@"year"];
    [sendDict setObject:[NSNumber numberWithInteger:current_month] forKey:@"month"];
    [sendDict setObject:[NSNumber numberWithInteger:current_date] forKey:@"day"];
    [sendDict setObject:@"show" forKey:@"eventType"];
    [_superView setTranslatesAutoresizingMaskIntoConstraints:NO];
    //屏蔽手势
    [self view:_superView preventSlidBackGesture:YES];
    [self sendResultEventWithCallbackId:openCbid dataDict:sendDict errDict:nil doDelete:NO];
    //为setSpecialDates接口做准备
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getCurrentShowDate:) name:@"currentShowDate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSelectedDays:) name:@"currentShowDay" object:nil];
}

- (void)nextMonth:(NSDictionary *)params_ {
    if (!_calendar) {
        return;
    }
    int year = (int)[_nowDate integerValueForKey:@"year" defaultValue: -1];
    int month = (int)[_nowDate integerValueForKey:@"month" defaultValue: -1] + 1;
    if (month > 12) {
        month = 1;
        year += 1;
    }
    [self setDate:year month:month day:-1 cbId:[params_ floatValueForKey:@"cbId" defaultValue:-1] isDate:NO];
}

- (void)prevMonth:(NSDictionary *)params_ {
    if (!_calendar) {
        return;
    }
    int year = (int)[_nowDate integerValueForKey:@"year" defaultValue: -1];
    int month = (int)[_nowDate integerValueForKey:@"month" defaultValue: -1] - 1;
    if (month == 0) {
        year -= 1;
        month = 12;
    }
    [self setDate:year month:month day: -1 cbId:[params_ floatValueForKey:@"cbId" defaultValue: -1] isDate:NO];
}

- (void)nextYear:(NSDictionary *)params_ {
    if (!_calendar) {
        return;
    }
    int year = (int)[_nowDate integerValueForKey:@"year" defaultValue:-1] + 1;
    int month = (int)[_nowDate integerValueForKey:@"month" defaultValue:-1];
    [self setDate:year month:month day:-1 cbId:[params_ floatValueForKey:@"cbId" defaultValue:-1] isDate:NO];
}

- (void)prevYear:(NSDictionary *)params_ {
    if (!_calendar) {
        return;
    }
    int year = (int)[_nowDate integerValueForKey:@"year" defaultValue: -1] - 1;
    int month = (int)[_nowDate integerValueForKey:@"month" defaultValue: -1];
    [self setDate:year month:month day: -1 cbId:[params_ floatValueForKey:@"cbId" defaultValue: -1] isDate:NO];
}

- (void)close:(NSDictionary *)params_ {
    [_calendar removeFromSuperview];
    [_superView removeFromSuperview];
    _calendar = nil;
    _superView = nil;
}

- (void)hide:(NSDictionary *)params_ {
    _superView.hidden = YES;
}

- (void)setDate:(NSDictionary *)params_ {
    if (!_calendar) {
        return;
    }
    [_calendar removeFromSuperview];
    _calendar = nil;
    int month = [[DateUtil getCurrentMonth] intValue];
    int year = [[DateUtil getCurrentYear] intValue];
    int day = [[DateUtil getCurrentDate] intValue];
    [_nowDate setValue:[NSNumber numberWithInt:month] forKey:@"month"];
    [_nowDate setValue:[NSNumber numberWithInt:year] forKey:@"year"];
    [_nowDate setValue:[NSNumber numberWithInt:day] forKey:@"day"];
    
    BOOL isIgnore = [params_ boolValueForKey:@"ignoreSelected" defaultValue:false];
    NSString *date = [params_ stringValueForKey:@"date" defaultValue:nil];
    if (date!=nil && date.length>0) {
        year = [[date substringToIndex:4]intValue];
        month = [[[date substringFromIndex:5]substringToIndex:2]intValue];
        day =[[date substringFromIndex:8]intValue];
    }
    if (isIgnore) {
        day = 0;
    }
    [self setDate:year month:month day:day cbId:[params_ floatValueForKey:@"cbId" defaultValue:-1] isDate:YES];
}

- (void)show:(NSDictionary *)params_ {
    _superView.hidden = NO;
}

- (void)setDate:(int)year month:(int)month day:(int)day cbId:(NSInteger)cbId isDate:(BOOL)isDate{
    [_calendar removeFromSuperview];
    _calendar = nil;
    [_nowDate setObject:[NSNumber numberWithInt:year] forKey:@"year"];
    [_nowDate setObject:[NSNumber numberWithInt:month] forKey:@"month"];
    _calendar = [[SACalendar alloc] initWithFrame:_rect
                                            month:month
                                             year:year
                                              day:day
                                      specialDate:_specilDate
                                  scrollDirection:_switchMode];
    _calendar.delegate = self;
    if (isDate) {
        [self sendResultEventWithCallbackId:cbId
                                   dataDict:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"status", nil]
                                    errDict:nil
                                   doDelete:NO];
    } else {
        [self sendResultEventWithCallbackId:cbId
                                   dataDict:_nowDate
                                    errDict:nil
                                   doDelete:YES];
    }
    [_superView addSubview:_calendar];
}

- (void)setSpecialDates:(NSDictionary *)params_ {
    if (!_calendar) {
        return;
    }
    NSArray *specialDates = [params_ arrayValueForKey:@"specialDates" defaultValue:@[]];
    if (specialDates.count == 0) {
        return;
    }
    NSMutableArray *openSpecialDate = [NSMutableArray arrayWithArray:_specilDate];
    for (NSDictionary *dataDict in specialDates) {
        BOOL isSame = false;
        specialDatesModel *spDatesModel = [[specialDatesModel alloc]initWithSpecialDates:dataDict];
        for (specialDatesModel *tempSpDate in openSpecialDate) {
            if ([tempSpDate.spDateDate.year isEqualToString:spDatesModel.spDateDate.year] && [tempSpDate.spDateDate.month isEqualToString:spDatesModel.spDateDate.month] && [tempSpDate.spDateDate.day isEqualToString:spDatesModel.spDateDate.day]) {
                isSame = true;
                NSUInteger curIndex = [openSpecialDate indexOfObject:tempSpDate];
                [_specilDate replaceObjectAtIndex:curIndex withObject:spDatesModel];
                break;
            } else {
                isSame = false;
            }
        }
        if (!isSame) {
            [_specilDate addObject:spDatesModel];
        }
    }
    [_calendar removeFromSuperview];
    _calendar = nil;
    _calendar = [[SACalendar alloc] initWithFrame:_rect
                                            month:[_curShowMonth intValue]
                                             year:[_curShowYear intValue]
                                              day:[_getSelectDay intValue]
                                      specialDate:_specilDate
                                  scrollDirection:_switchMode];
    _calendar.delegate = self;
    [_superView addSubview:_calendar];
}

- (void)cancelSpecialDates:(NSDictionary *)params_ {
    if (!_calendar) {
        return;
    }
    NSArray *cancelSpecDates = [params_ arrayValueForKey:@"specialDates" defaultValue:@[]];
    if (cancelSpecDates == nil || [cancelSpecDates isKindOfClass:[NSNull class]] || cancelSpecDates.count == 0) {
        return;
    }
    NSMutableArray *oldSpecDates = [NSMutableArray arrayWithArray:_specilDate];
    //解析需要取消的日期数组
    for (NSString *cancelDateStr in cancelSpecDates) {
        //使用临时NSDateComponents转换是为了防止如“02”时 与获取的当前日期中的 “2” 做比较时不相等
        NSDateComponents *tempCom = [[NSDateComponents alloc]init];
        dateModel *cancelSpecModel = [[dateModel alloc]init];
        tempCom.year = [[cancelDateStr substringToIndex:4]intValue];
        tempCom.month = [[[cancelDateStr substringFromIndex:5]substringToIndex:2]intValue];
        tempCom.day =[[cancelDateStr substringFromIndex:8] intValue];
        cancelSpecModel.year = [NSString stringWithFormat:@"%ld",(long)tempCom.year];
        cancelSpecModel.month = [NSString stringWithFormat:@"%ld",(long)tempCom.month];
        cancelSpecModel.day = [NSString stringWithFormat:@"%ld",(long)tempCom.day];
        //遍历旧的特殊日期，找出存在的特殊日期删除
        for (specialDatesModel *oldSpecdate in oldSpecDates) {
            if ([oldSpecdate.spDateDate.year isEqualToString: cancelSpecModel.year] &&
                [oldSpecdate.spDateDate.month isEqualToString:cancelSpecModel.month] &&
                [oldSpecdate.spDateDate.day isEqualToString: cancelSpecModel.day]) {
                [_specilDate removeObject:oldSpecdate];
            }
        }
    }
    [_calendar removeFromSuperview];
    _calendar = nil;
    _calendar = [[SACalendar alloc] initWithFrame:_rect
                                            month:[_curShowMonth intValue]
                                             year:[_curShowYear intValue]
                                              day:[_getSelectDay intValue]
                                      specialDate:_specilDate
                                  scrollDirection:_switchMode];
    _calendar.delegate = self;
    [_superView addSubview:_calendar];
}

- (void)getCurrentShowDate:(NSNotification *)notification {
    _curShowYear = notification.userInfo[@"year"];
    _curShowMonth = notification.userInfo[@"month"];
}

- (void)getSelectedDays:(NSNotification *)notification {
    _getSelectDay = notification.userInfo[@"selectedDay"];
}

#pragma mark - SACalendarDelegate -

- (NSString *)getPath:(NSString *)path {
    return [self getPathWithUZSchemeURL:path];
}

- (void)callBack:(NSDictionary *)date isShow:(BOOL)isShow {
    if (isShow) {
        [self sendResultEventWithCallbackId:openCbid dataDict:date errDict:nil doDelete:NO];
    } else {
        _nowDate = (NSMutableDictionary *)date;
    }
}

@end
