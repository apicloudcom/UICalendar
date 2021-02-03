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
#import "CalendarModel.h"

@interface UZUICalendar ()
<SACalendarDelegate> {
//    UIView *_superView;
    NSInteger openCbid;
//    scrollDirection _switchMode;
//    SACalendar *_calendar;
//    NSMutableArray *_specilDate;
//    CGRect _rect;
//    NSNumber *_curShowYear, *_curShowMonth, *_getSelectDay;
}

//@property (nonatomic, strong) NSMutableDictionary *nowDate;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) NSMutableDictionary *allDict;
@property (nonatomic, strong) NSMutableDictionary *modelDict;
@property (nonatomic, strong) NSMutableDictionary *calendarDict;

@end

@implementation UZUICalendar

- (void)dispose {
//    _calendar = nil;
//    _superView = nil;
//    _nowDate = nil;
//    _specilDate = nil;
    
    _index = 0;
    
    [_allDict removeAllObjects];
    [_modelDict removeAllObjects];
    [_calendarDict removeAllObjects];
    
    _allDict = nil;
    _modelDict = nil;
    _calendarDict = nil;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"currentShowDate" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"currentShowDay" object:nil];
}

#pragma mark - interFace -

int kUZUICalendarMultipleSelect;
- (void)open:(NSDictionary *)params_ {
//    if (_superView) {
//        [[_superView superview] bringSubviewToFront:_superView];
//        _superView.hidden = NO;
//        return;
//    }
    
    
    CalendarModel *calendarModel = [[CalendarModel alloc] init];
    
    BOOL multipleSelect = [params_ boolValueForKey:@"multipleSelect" defaultValue:NO];
    
    //今天以前的日期是否可选
    BOOL isBefore = [params_ boolValueForKey:@"isBefore" defaultValue:NO];
    //今天以后的日期是否可选
    BOOL isAfter = [params_ boolValueForKey:@"isAfter" defaultValue:NO];
    kUZUICalendarMultipleSelect = multipleSelect ? 1 : 0;
    
//    NSDictionary *rect = [params_ dictValueForKey:@"rect" defaultValue:@{}];
//    _nowDate = [[NSMutableDictionary alloc] init];
    NSString *switchStr = [params_ stringValueForKey:@"switchMode" defaultValue:@"vertical"];
    if ([switchStr isEqualToString:@"vertical"]) {
        calendarModel.switchMode = ScrollDirectionVertical;
    } else if ([switchStr isEqualToString:@"horizontal"]) {
        calendarModel.switchMode = ScrollDirectionHorizontal;
    } else if ([switchStr isEqualToString:@"none"]) {
        calendarModel.switchMode = ScrollDirectionNone;
    } else {
        calendarModel.switchMode = ScrollDirectionVertical;
    }
    openCbid = [params_ floatValueForKey:@"cbId" defaultValue:-1];

//    float x = [rect floatValueForKey:@"x" defaultValue:0];
//    float y = [rect floatValueForKey:@"y" defaultValue:0];
//    NSString *fixedOn = [params_ stringValueForKey:@"fixedOn" defaultValue:nil];
//    float width = [UIScreen mainScreen].bounds.size.width;
//    if (fixedOn != nil) {
//        UIView *mainView = [self getViewByName:fixedOn];
//        width = mainView.frame.size.width;
//    }
//    float w = [rect floatValueForKey:@"w" defaultValue:width];
//    float h = [rect floatValueForKey:@"h" defaultValue:220];
    
    NSString *fixedOn = [params_ stringValueForKey:@"fixedOn" defaultValue:nil];
    UIView *superView = [self getViewByName:fixedOn];
    CGRect rect = [params_ rectValueForKey:@"rect" defaultValue:CGRectMake(0, 0, superView.frame.size.width, 220) relativeToSuperView:superView];
    float x = rect.origin.x;
    float y = rect.origin.y;
    float w = rect.size.width;
    float h = rect.size.height;
    NSArray *dates = [params_ arrayValueForKey:@"specialDate" defaultValue:@[]];
//    _specilDate = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *dataDict in dates) {
        specialDatesModel *spDatesModel = [[specialDatesModel alloc]initWithSpecialDates:dataDict];
        [calendarModel.specilDate addObject:spDatesModel];
    }
    NSDictionary *styles = [params_ dictValueForKey:@"styles" defaultValue:@{}];
    
    BOOL showTodayStyle =[params_ boolValueForKey:@"showTodayStyle" defaultValue:YES];
    
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
    calendarModel.rect = CGRectMake(0, 0, w, h);
    SACalendar *calendar = [[SACalendar alloc]initWithFrame:calendarModel.rect
                                 scrollDirection:calendarModel.switchMode
                                   pagingEnabled:YES
                                     specialDate:calendarModel.specilDate];
    
    
    UIView *calendarView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    calendar.delegate = self;
    calendar.isBefore = isBefore;
    calendar.isAfter = isAfter;
    calendar.showTodayStyle = showTodayStyle;
    calendar.index = _index;
    [calendarView addSubview:calendar];
    BOOL fixed = [params_ boolValueForKey:@"fixed" defaultValue:YES];
    [self addSubview:calendarView fixedOn:fixedOn fixed:fixed];
    
    
    [self.allDict setObject:calendar forKey:@(_index)];
    [self.calendarDict setObject:calendarView forKey:@(_index)];
    [self.modelDict setObject:calendarModel forKey:@(_index)];
    //callback
    NSMutableDictionary *sendDict = [NSMutableDictionary dictionaryWithCapacity:2];
    NSInteger current_date = [[DateUtil getCurrentDate]intValue];
    NSInteger current_month = [[DateUtil getCurrentMonth]intValue];
    NSInteger current_year = [[DateUtil getCurrentYear]intValue];
    [sendDict setObject:[NSNumber numberWithInteger:current_year] forKey:@"year"];
    
    if (current_month < 10) {
        [sendDict setObject:[NSString stringWithFormat:@"0%ld",(long)current_month] forKey:@"month"];
    }else{
        [sendDict setObject:[NSNumber numberWithInteger:current_month] forKey:@"month"];
    }
    if (current_date < 10) {
        [sendDict setObject:[NSString stringWithFormat:@"0%ld",(long)current_date] forKey:@"day"];
    }else{
        [sendDict setObject:[NSNumber numberWithInteger:current_date] forKey:@"day"];
    }
    [sendDict setObject:@(_index) forKey:@"id"];
    [sendDict setObject:@"show" forKey:@"eventType"];
    [calendarView setTranslatesAutoresizingMaskIntoConstraints:NO];
    //屏蔽手势
    [self view:calendarView preventSlidBackGesture:YES];
    [self sendResultEventWithCallbackId:openCbid dataDict:sendDict errDict:nil doDelete:NO];
    //为setSpecialDates接口做准备
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getCurrentShowDate:) name:@"currentShowDate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSelectedDays:) name:@"currentShowDay" object:nil];
    
    _index++;
}

- (void)nextMonth:(NSDictionary *)params_ {
    NSInteger calendarID = [params_ integerValueForKey:@"id" defaultValue:0];
    
    
    SACalendar *calendar = [_allDict objectForKey:@(calendarID)];
    CalendarModel *model = [_modelDict objectForKey:@(calendarID)];
    UIView *calendarView = [_calendarDict objectForKey:@(calendarID)];
    if (!calendar) {
        return;
    }
    int year = (int)[model.nowDate integerValueForKey:@"year" defaultValue: -1];
    int month = (int)[model.nowDate integerValueForKey:@"month" defaultValue: -1] + 1;
    if (month > 12) {
        month = 1;
        year += 1;
    }
    [self setDate:year month:month day:-1 cbId:[params_ floatValueForKey:@"cbId" defaultValue:-1] isDate:NO calendar:calendar model:model superView:calendarView calendarID:calendarID];
}

- (void)prevMonth:(NSDictionary *)params_ {
    
    NSInteger calendarID = [params_ integerValueForKey:@"id" defaultValue:0];
    SACalendar *calendar = [_allDict objectForKey:@(calendarID)];
    CalendarModel *model = [_modelDict objectForKey:@(calendarID)];
    UIView *calendarView = [_calendarDict objectForKey:@(calendarID)];
    if (!calendar) {
        return;
    }
    int year = (int)[model.nowDate integerValueForKey:@"year" defaultValue: -1];
    int month = (int)[model.nowDate integerValueForKey:@"month" defaultValue: -1] - 1;
    if (month == 0) {
        year -= 1;
        month = 12;
    }
    [self setDate:year month:month day: -1 cbId:[params_ floatValueForKey:@"cbId" defaultValue: -1] isDate:NO calendar:calendar model:model superView:calendarView calendarID:calendarID];
}

- (void)nextYear:(NSDictionary *)params_ {
    
    NSInteger calendarID = [params_ integerValueForKey:@"id" defaultValue:0];
    SACalendar *calendar = [_allDict objectForKey:@(calendarID)];
    CalendarModel *model = [_modelDict objectForKey:@(calendarID)];
    UIView *calendarView = [_calendarDict objectForKey:@(calendarID)];
    
    if (!calendar) {
        return;
    }
    int year = (int)[model.nowDate integerValueForKey:@"year" defaultValue:-1] + 1;
    int month = (int)[model.nowDate integerValueForKey:@"month" defaultValue:-1];
    [self setDate:year month:month day:-1 cbId:[params_ floatValueForKey:@"cbId" defaultValue:-1] isDate:NO calendar:calendar model:model superView:calendarView calendarID:calendarID];
}

- (void)prevYear:(NSDictionary *)params_ {
    
    NSInteger calendarID = [params_ integerValueForKey:@"id" defaultValue:0];
    SACalendar *calendar = [_allDict objectForKey:@(calendarID)];
    CalendarModel *model = [_modelDict objectForKey:@(calendarID)];
    UIView *calendarView = [_calendarDict objectForKey:@(calendarID)];
    
    if (!calendar) {
        return;
    }
    int year = (int)[model.nowDate integerValueForKey:@"year" defaultValue: -1] - 1;
    int month = (int)[model.nowDate integerValueForKey:@"month" defaultValue: -1];
    [self setDate:year month:month day: -1 cbId:[params_ floatValueForKey:@"cbId" defaultValue: -1] isDate:NO calendar:calendar model:model superView:calendarView calendarID:calendarID];
}

- (void)turnPage:(NSDictionary *)params_ {
    
    NSInteger calendarID = [params_ integerValueForKey:@"id" defaultValue:0];
    SACalendar *calendar = [_allDict objectForKey:@(calendarID)];
    CalendarModel *model = [_modelDict objectForKey:@(calendarID)];
    UIView *calendarView = [_calendarDict objectForKey:@(calendarID)];
    
    if (!calendar) {
        return;
    }
    NSString *turnToDate = [params_ stringValueForKey:@"date" defaultValue:nil];
    if (!turnToDate || (turnToDate.length <= 0)) {
        return;
    }
    int turnToYear = [[turnToDate substringToIndex:4] intValue];
    int turnToMonth = [[[turnToDate substringFromIndex:5] substringToIndex:2] intValue];
    [self setDate:turnToYear month:turnToMonth day: -1 cbId:-1 isDate:NO calendar:calendar model:model superView:calendarView calendarID:calendarID];
}

- (void)close:(NSDictionary *)params_ {
    
    NSInteger calendarID = [params_ integerValueForKey:@"id" defaultValue:0];
    SACalendar *calendar = [_allDict objectForKey:@(calendarID)];
    UIView *calendarView = [_calendarDict objectForKey:@(calendarID)];
    
    [calendar removeFromSuperview];
    [calendarView removeFromSuperview];

}

- (void)hide:(NSDictionary *)params_ {
    
    NSInteger calendarID = [params_ integerValueForKey:@"id" defaultValue:0];
    UIView *calendarView = [_calendarDict objectForKey:@(calendarID)];
    calendarView.hidden = YES;
}

- (void)setDate:(NSDictionary *)params_ {
    
    NSInteger calendarID = [params_ integerValueForKey:@"id" defaultValue:0];
    SACalendar *calendar = [_allDict objectForKey:@(calendarID)];
    CalendarModel *model = [_modelDict objectForKey:@(calendarID)];
    UIView *calendarView = [_calendarDict objectForKey:@(calendarID)];
    if (!calendar) {
        return;
    }
    int month = [[DateUtil getCurrentMonth] intValue];
    int year = [[DateUtil getCurrentYear] intValue];
    int day = [[DateUtil getCurrentDate] intValue];
    [model.nowDate setValue:[NSNumber numberWithInt:month] forKey:@"month"];
    [model.nowDate setValue:[NSNumber numberWithInt:year] forKey:@"year"];
    [model.nowDate setValue:[NSNumber numberWithInt:day] forKey:@"day"];
    
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
    [self setDate:year month:month day:day cbId:[params_ floatValueForKey:@"cbId" defaultValue:-1] isDate:YES calendar:calendar model:model superView:calendarView calendarID:calendarID];
}

- (void)show:(NSDictionary *)params_ {
    NSInteger calendarID = [params_ integerValueForKey:@"id" defaultValue:0];
    UIView *calendarView = [_calendarDict objectForKey:@(calendarID)];
    calendarView.hidden = NO;
}

- (void)setDate:(int)year month:(int)month day:(int)day cbId:(NSInteger)cbId isDate:(BOOL)isDate calendar:(SACalendar *)calendar model:(CalendarModel *)model superView:(UIView *)superView calendarID:(NSInteger)calendarID{
    
    [model.nowDate setObject:[NSNumber numberWithInt:year] forKey:@"year"];
    [model.nowDate setObject:[NSNumber numberWithInt:month] forKey:@"month"];
    SACalendar *newCalendar = [[SACalendar alloc] initWithFrame:model.rect
                                            month:month
                                             year:year
                                              day:day
                                      specialDate:model.specilDate
                                  scrollDirection:model.switchMode];
    newCalendar.isBefore = calendar.isBefore;
    newCalendar.isAfter = calendar.isAfter;
    newCalendar.s_year = calendar.s_year;
    newCalendar.s_month = calendar.s_month;
    newCalendar.s_day = calendar.s_day;
    newCalendar.selectArray = calendar.selectArray;
    newCalendar.index = calendar.index;
    newCalendar.showTodayStyle = calendar.showTodayStyle;
    newCalendar.delegate = self;
    [calendar removeFromSuperview];
    [superView addSubview:newCalendar];
    
    [_allDict setObject:newCalendar forKey:@(calendarID)];
    [_modelDict setObject:model forKey:@(calendarID)];
    if (isDate) {
        [self sendResultEventWithCallbackId:cbId
                                   dataDict:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"status", nil]
                                    errDict:nil
                                   doDelete:NO];
    } else {
        if (cbId >= 0) {
            [self sendResultEventWithCallbackId:cbId
                                       dataDict:model.nowDate
                                        errDict:nil
                                       doDelete:YES];
        }
    }
}

- (void)setSpecialDates:(NSDictionary *)params_ {
    
    NSInteger calendarID = [params_ integerValueForKey:@"id" defaultValue:0];
    SACalendar *calendar = [_allDict objectForKey:@(calendarID)];
    CalendarModel *model = [_modelDict objectForKey:@(calendarID)];
    UIView *calendarView = [_calendarDict objectForKey:@(calendarID)];
    
    if (!calendar) {
        return;
    }
    NSArray *specialDates = [params_ arrayValueForKey:@"specialDates" defaultValue:@[]];
    if (specialDates.count == 0) {
        return;
    }
    NSMutableArray *openSpecialDate = [NSMutableArray arrayWithArray:model.specilDate];
    for (NSDictionary *dataDict in specialDates) {
        BOOL isSame = false;
        specialDatesModel *spDatesModel = [[specialDatesModel alloc]initWithSpecialDates:dataDict];
        for (specialDatesModel *tempSpDate in openSpecialDate) {
            if ([tempSpDate.spDateDate.year isEqualToString:spDatesModel.spDateDate.year] && [tempSpDate.spDateDate.month isEqualToString:spDatesModel.spDateDate.month] && [tempSpDate.spDateDate.day isEqualToString:spDatesModel.spDateDate.day]) {
                isSame = true;
                NSUInteger curIndex = [openSpecialDate indexOfObject:tempSpDate];
                [model.specilDate replaceObjectAtIndex:curIndex withObject:spDatesModel];
                break;
            } else {
                isSame = false;
            }
        }
        if (!isSame) {
            [model.specilDate addObject:spDatesModel];
        }
    }
    
    SACalendar *newCalendar = [[SACalendar alloc] initWithFrame:model.rect
                                            month:[model.curShowMonth intValue]
                                             year:[model.curShowYear intValue]
                                              day:[model.getSelectDay intValue]
                                      specialDate:model.specilDate
                                  scrollDirection:model.switchMode];
    newCalendar.isBefore = calendar.isBefore;
    newCalendar.isAfter = calendar.isAfter;
    newCalendar.s_year = calendar.s_year;
    newCalendar.s_month = calendar.s_month;
    newCalendar.s_day = calendar.s_day;
    newCalendar.selectArray = calendar.selectArray;
    newCalendar.index = calendar.index;
    newCalendar.showTodayStyle = calendar.showTodayStyle;
    newCalendar.delegate = self;
    [calendar removeFromSuperview];
    [calendarView addSubview:newCalendar];
    
    [_allDict setObject:newCalendar forKey:@(calendarID)];
    [_modelDict setObject:model forKey:@(calendarID)];
}

- (void)cancelSpecialDates:(NSDictionary *)params_ {
    NSInteger calendarID = [params_ integerValueForKey:@"id" defaultValue:0];
    SACalendar *calendar = [_allDict objectForKey:@(calendarID)];
    CalendarModel *model = [_modelDict objectForKey:@(calendarID)];
    UIView *calendarView = [_calendarDict objectForKey:@(calendarID)];
    
    if (!calendar) {
        return;
    }
    NSArray *cancelSpecDates = [params_ arrayValueForKey:@"specialDates" defaultValue:@[]];
    if (cancelSpecDates == nil || [cancelSpecDates isKindOfClass:[NSNull class]] || cancelSpecDates.count == 0) {
        return;
    }
    NSMutableArray *oldSpecDates = [NSMutableArray arrayWithArray:model.specilDate];
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
                [model.specilDate removeObject:oldSpecdate];
            }
        }
    }
    
    SACalendar *newCalendar = [[SACalendar alloc] initWithFrame:model.rect
                                            month:[model.curShowMonth intValue]
                                             year:[model.curShowYear intValue]
                                              day:[model.getSelectDay intValue]
                                      specialDate:model.specilDate
                                  scrollDirection:model.switchMode];
    newCalendar.isBefore = calendar.isBefore;
    newCalendar.isAfter = calendar.isAfter;
    newCalendar.s_year = calendar.s_year;
    newCalendar.s_month = calendar.s_month;
    newCalendar.s_day = calendar.s_day;
    newCalendar.selectArray = calendar.selectArray;
    newCalendar.index = calendar.index;
    newCalendar.showTodayStyle = calendar.showTodayStyle;
    newCalendar.delegate = self;
    
    [calendar removeFromSuperview];
    [calendarView addSubview:newCalendar];
    
    [_allDict setObject:newCalendar forKey:@(calendarID)];
    [_modelDict setObject:model forKey:@(calendarID)];
    
    
}

- (void)getCurrentShowDate:(NSNotification *)notification {
    
    NSInteger calendarID = [notification.userInfo[@"index"] integerValue];
    CalendarModel *model = [_modelDict objectForKey:@(calendarID)];
    
    model.curShowYear = notification.userInfo[@"year"];
    model.curShowMonth = notification.userInfo[@"month"];
    
    [_modelDict setObject:model forKey:@(calendarID)];
}
- (void)getSelectedDays:(NSNotification *)notification {
    
    NSInteger calendarID = [notification.userInfo[@"index"] integerValue];
    CalendarModel *model = [_modelDict objectForKey:@(calendarID)];
    
    model.getSelectDay = notification.userInfo[@"selectedDay"];
    [_modelDict setObject:model forKey:@(calendarID)];
}

#pragma mark - SACalendarDelegate -

- (NSString *)getPath:(NSString *)path {
    return [self getPathWithUZSchemeURL:path];
}

- (void)callBack:(NSDictionary *)date isShow:(BOOL)isShow index:(NSInteger)index{

    CalendarModel *model = [_modelDict objectForKey:@(index)];
    if (isShow) {
        [self sendResultEventWithCallbackId:openCbid dataDict:date errDict:nil doDelete:NO];
    } else {
        model.nowDate = (NSMutableDictionary *)date;
    }
    [_modelDict setObject:model forKey:@(index)];
}
- (NSMutableDictionary *)allDict {
    if (!_allDict) {
        _allDict = [NSMutableDictionary dictionary];
    }
    return _allDict;
}
- (NSMutableDictionary *)modelDict {
    if (!_modelDict) {
        _modelDict = [NSMutableDictionary dictionary];
    }
    return _modelDict;
}
- (NSMutableDictionary *)calendarDict {
    if (!_calendarDict) {
        _calendarDict = [NSMutableDictionary dictionary];
    }
    return _calendarDict;
}
@end
