//
//  SACalendar.m
//  SACalendarExample
//
//  Created by Nop Shusang on 7/10/14.
//  Copyright (c) 2014 SyncoApp. All rights reserved.
//
//  Distributed under MIT License

#import "SACalendar.h"
#import "SACalendarCell.h"
#import "DMLazyScrollView.h"
#import "DateUtil.h"
#import "UZAppUtils.h"
#import "NSDictionaryUtils.h"
#import "dateModel.h"
#import "specialDatesModel.h"
#import "UIView+cornerRadius.h"

@interface SACalendar () <UICollectionViewDataSource, UICollectionViewDelegate, CalenCell>{
    DMLazyScrollView* scrollView;
    NSMutableDictionary *controllers;
    NSMutableDictionary *calendars;
    //    NSMutableDictionary *monthLabels;
    
    int year, month;
    int prev_year, prev_month;
    int next_year, next_month;
    int current_date, current_month, current_year;
    
    int state, scroll_state;
    int previousIndex;
    BOOL scrollLeft;
    
    int firstDay;
    NSArray *daysInWeeks;
    CGSize cellSize;
    
    int selectedRow;
    int headerSize;
    
    NSDictionary *_date,*_today,*_specialDateDict;
    NSArray *_specialDate;
    NSString *_dateNow;
    UICollectionView *_calendar;
    
    scrollDirection switchMode;
    
    NSString *_weekendColor;
    int day;
    NSMutableArray *_weekDays;
}

@property (nonatomic,strong) NSMutableArray * selectArray;
@property (nonatomic,strong) NSMutableArray * leftArray;
@property (nonatomic,strong) NSMutableArray * rightArray;

@end

@implementation SACalendar

- (NSMutableArray *)selectArray {
    if (!_selectArray) {
        _selectArray = [NSMutableArray array];
    }
    return _selectArray;
}

- (NSMutableArray *)leftArray {
    if (!_leftArray) {
        _leftArray = [NSMutableArray arrayWithObjects:@(0), @(7),@(14),@(21),@(28),@(35), nil];
    }
    return _leftArray;
}

- (NSMutableArray *)rightArray {
    if (!_rightArray) {
        _rightArray = [NSMutableArray arrayWithObjects:@(6), @(13),@(20),@(27),@(34),@(41), nil];
    }
    return _rightArray;
}


- (id)initWithFrame:(CGRect)frame {
    day = -1;
    return [self initWithFrame:frame month:0 year:0 scrollDirection:ScrollDirectionHorizontal pagingEnabled:YES];
}

- (id)initWithFrame:(CGRect)frame month:(int)m
               year:(int)y
                day:(int)d
        specialDate:(NSArray *)specialDate
    scrollDirection:(scrollDirection)direction {
    day = d;
    _specialDate = [[NSArray alloc] initWithArray:specialDate];
    return [self initWithFrame:frame month:m year:y scrollDirection:direction pagingEnabled:YES];
}

-(id)initWithFrame:(CGRect)frame
   scrollDirection:(scrollDirection)direction
     pagingEnabled:(BOOL)paging
       specialDate:(NSArray *)specialDate {
    _specialDate = [[NSArray alloc] initWithArray:specialDate];
    day = -1;
    return [self initWithFrame:frame month:0 year:0 scrollDirection:direction pagingEnabled:paging];
}

-(id)initWithFrame:(CGRect)frame
             month:(int)m
              year:(int)y
   scrollDirection:(scrollDirection)direction
     pagingEnabled:(BOOL)paging {
    self = [super initWithFrame:frame];
    switchMode = direction;
    _styles = [[NSDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"UZMarkDic"]];
    _date = [[NSDictionary alloc] initWithDictionary:[_styles dictValueForKey:@"date" defaultValue:@{}]];
    _today = [[NSDictionary alloc] initWithDictionary:[_styles dictValueForKey:@"today" defaultValue:@{}]];
    _specialDateDict = [[NSDictionary alloc] initWithDictionary:[_styles dictValueForKey:@"specialDate" defaultValue:@{}]];
    
    SACalendarCell *cell = [[SACalendarCell alloc] init];
    cell.delegate = self;
    
    _weekDays = [[NSMutableArray alloc] initWithObjects:@"0",@"7",@"14",@"21",@"28",@"35",@"6",@"13",@"20",@"27",@"34",@"41", nil];
    //背景
    NSString *bg = [_styles stringValueForKey:@"bg" defaultValue:@"rgba(0,0,0,0)"];
    if (!bg.length) {
        bg = @"rgba(0,0,0,0)";
    }
    if ([UZAppUtils isValidColor:bg]) {
        self.backgroundColor = [UZAppUtils colorFromNSString:bg];
    } else {
        //设置背景为图片
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        img.image = [UIImage imageWithContentsOfFile:bg];
        [self addSubview:img];
    }
    
    
    NSArray *weekArr = [NSArray arrayWithObjects:@"日",@"一",@"二",@"三",@"四",@"五",@"六", nil];
    
    NSDictionary *week = [_styles dictValueForKey:@"week" defaultValue:@{}];
    NSString *weekdayColor = [week stringValueForKey:@"weekdayColor" defaultValue:@"#3b3b3b"];
    if (!weekdayColor.length) {
        weekdayColor = @"#3b3b3b";
    }
    _weekendColor = [week stringValueForKey:@"weekendColor" defaultValue:@"#a8d400"];
    if (!_weekendColor.length) {
        _weekendColor = @"#a8d400";
    }
    float weekSize = [week floatValueForKey:@"size" defaultValue:24];
    
    float width = self.frame.size.width/7;
    for (int i = 0; i < 7; i++) {
        //            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i*width, headerSize+headerSize*(1/3), width, headerSize)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i*width, 0, width, self.frame.size.height/7)];
        label.backgroundColor = [UIColor clearColor];
        label.text = weekArr[i];
        label.textAlignment = NSTextAlignmentCenter;
        if (i == 0 || i == 6) {
            label.textColor = [UZAppUtils colorFromNSString:_weekendColor];
        } else {
            label.textColor = [UZAppUtils colorFromNSString:weekdayColor];
        }
        [label setFont:[UIFont systemFontOfSize:weekSize]];
        [self addSubview:label];
    }
    
    if (self) {
        controllers = [NSMutableDictionary dictionary];
        calendars = [NSMutableDictionary dictionary];
        //        monthLabels = [NSMutableDictionary dictionary];
        
        daysInWeeks = [[NSArray alloc]initWithObjects:@"Sunday",@"Monday",@"Tuesday",
                       @"Wednesday",@"Thursday",@"Friday",@"Saturday", nil];
        
        state = LOADSTATESTART;
        scroll_state = SCROLLSTATE_120;
        
        selectedRow = -1;
        current_date = [[DateUtil getCurrentDate]intValue];
        current_month = [[DateUtil getCurrentMonth]intValue];
        current_year = [[DateUtil getCurrentYear]intValue];
        
        if (m == 0 && y == 0) {
            month = current_month;
            year = current_year;
        } else {
            month = m;
            year = y;
        }
       
        CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        
        if (direction == DMLazyScrollViewDirectionNone) {
            scrollView = [[DMLazyScrollView alloc] initWithFrameAndDirection:rect direction:direction circularScroll:NO paging:paging];
        } else {
            scrollView = [[DMLazyScrollView alloc] initWithFrameAndDirection:rect direction:direction circularScroll:YES paging:paging];

        }
        [self addObserver:self forKeyPath:@"delegate" options:NSKeyValueObservingOptionNew context:nil];
    }
    __weak __typeof(&*self)weakSelf = self;
    scrollView.dataSource = ^(NSUInteger index) {
        return [weakSelf controllerAtIndex:index];
    };
    
    scrollView.numberOfPages = 3;
    [self addSubview:scrollView];
    return self;
}

- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    if (nil != _delegate && [_delegate respondsToSelector:@selector(SACalendar:didDisplayCalendarForMonth:year:)]) {
        [_delegate SACalendar:self didDisplayCalendarForMonth:month year:year];
    }
}

#pragma mark - SCROLL VIEW DELEGATE -
extern int kUZUICalendarMultipleSelect;
- (UIViewController *) controllerAtIndex:(NSInteger) index {
    //Handle right scroll
    if (index == previousIndex && state == LOADSTATEPREVIOUS) {
        if (++month > MAX_MONTH) {
            month = MIN_MONTH;
            year ++;
        }
        scrollLeft = NO;
        selectedRow = DESELECT_ROW;
#pragma mark - 修改day
//        day = -1;
    }
    
    //Handle left scroll
    else if(state == LOADSTATEPREVIOUS) {
        if (--month < MIN_MONTH) {
            month = MAX_MONTH;
            year--;
        }
        scrollLeft = YES;
        selectedRow = -1;
#pragma mark - 修改day
//        day = -1;
    }
    previousIndex = (int)index;
    
    if (state  <= LOADSTATEPREVIOUS ) {
        state = LOADSTATENEXT;
    } else if(state == LOADSTATENEXT) {
        prev_month = month - 1;
        prev_year = year;
        if (prev_month < MIN_MONTH) {
            prev_month = MAX_MONTH;
            prev_year--;
        }
        state = LOADSTATECURRENT;
    } else {
        next_month = month + 1;
        next_year = year;
        if (next_month > MAX_MONTH) {
            next_month = MIN_MONTH;
            next_year++;
        }
        
        if (scrollLeft) {
            if (--scroll_state < SCROLLSTATE_120) {
                scroll_state = SCROLLSTATE_012;
            }
        } else {
            scroll_state++;
            if (scroll_state > SCROLLSTATE_012) {
                scroll_state = SCROLLSTATE_120;
            }
        }
        state = LOADSTATEPREVIOUS;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"currentShowDate"
                                                            object:self
                                                          userInfo:@{@"year":[NSNumber numberWithInt:year],@"month":[NSNumber numberWithInt:month]}];
        if (nil != _delegate) {
            NSMutableDictionary *sendDict = [NSMutableDictionary dictionaryWithCapacity:5];
            [sendDict setObject:[NSNumber numberWithInteger:year] forKey:@"year"];
            [sendDict setObject:[NSNumber numberWithInt:month] forKey:@"month"];
            if (switchMode == ScrollDirectionHorizontal || switchMode == ScrollDirectionVertical) {
                [sendDict setObject:@"switch" forKey:@"eventType"];
            }
            [_delegate callBack:sendDict isShow:YES];
        }
        if (nil != _delegate && [_delegate respondsToSelector:@selector(SACalendar:didDisplayCalendarForMonth:year:)]) {
            [_delegate SACalendar:self didDisplayCalendarForMonth:month year:year];
        }
    }
    
    //if already exists, reload the calendar with new values
    UICollectionView *calendar = [calendars objectForKey:[NSString stringWithFormat:@"%li",(long)index]];
    
    #pragma mark - ---
    if (kUZUICalendarMultipleSelect == 1) {
        self.selectArray = nil;
        self.leftArray = nil;
        self.rightArray = nil;
        selectedRow = DESELECT_ROW;
        day = -1;
    }
    
    [calendar reloadData];
    
    //create new view controller and add it to a dictionary for caching
    if (![controllers objectForKey:[NSString stringWithFormat:@"%li",(long)index]]) {
        UIViewController *contr = [[UIViewController alloc] init];
        UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize = self.frame.size;
        headerSize = scrollView.frame.size.height / 6;
#warning xiugai
        CGRect rect = CGRectMake(0,self.frame.size.height/7, self.frame.size.width, self.frame.size.height);
        UICollectionView *calendar = [[UICollectionView alloc]initWithFrame:rect collectionViewLayout:flowLayout];
#pragma mark - UICollectionView 适配iOS11
        if (@available(iOS 11.0, *)) {
            calendar.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        calendar.dataSource = self;
        calendar.delegate = self;
        calendar.pagingEnabled = NO;
        [calendar registerClass:[SACalendarCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
        calendar.tag = index;
        calendar.backgroundColor = [UIColor clearColor];
        [contr.view addSubview:calendar];
        [calendars setObject:calendar forKey:[NSString stringWithFormat:@"%li",(long)index]];
        [controllers setObject:contr forKey:[NSString stringWithFormat:@"%li",(long)index]];
        return contr;
    } else {
        return [controllers objectForKey:[NSString stringWithFormat:@"%li",(long)index]];
    }
}

/**
 *  Get the month corresponding to the collection view
 *
 *  @param tag of the collection view
 *
 *  @return month that the collection view should load
 */
- (int)monthToLoad:(int)tag {
    if (scroll_state == SCROLLSTATE_120) {
        if (tag == 0) return next_month;
        else if(tag == 1) return prev_month;
        else return month;
    } else if(scroll_state == SCROLLSTATE_201){
        if (tag == 0) return month;
        else if(tag == 1) return next_month;
        else return prev_month;
    } else {
        if (tag == 0) return prev_month;
        else if(tag == 1) return month;
        else return next_month;
    }
}

/**
 *  Get the year corresponding to the collection view
 *
 *  @param tag of the collection view
 *
 *  @return year that the collection view should load
 */
- (int)yearToLoad:(int)tag {
    if (scroll_state == SCROLLSTATE_120) {
        if (tag == 0) return next_year;
        else if(tag == 1) return prev_year;
        else return year;
    }
    else if(scroll_state == SCROLLSTATE_201){
        if (tag == 0) return year;
        else if(tag == 1) return next_year;
        else return prev_year;
    }
    else{
        if (tag == 0) return prev_year;
        else if(tag == 1) return year;
        else return next_year;
    }
}

#pragma mark - COLLECTION VIEW DELEGATE -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    int monthToLoad = [self monthToLoad:(int)collectionView.tag];
    int yearToLoad = [self yearToLoad:(int)collectionView.tag];
    
    firstDay = (int)[daysInWeeks indexOfObject:[DateUtil getDayOfDate:1 month:monthToLoad year:yearToLoad]];
    return MAX_CELL;
}

/**
 *  Controls what gets displayed in each cell
 *  Edit this function for customized calendar logic
 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isSelectedDay = false;
    
    SACalendarCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    int monthToLoad = [self monthToLoad:(int)collectionView.tag];
    int yearToLoad = [self yearToLoad:(int)collectionView.tag];
    
    // number of days in the month we are loading
    int daysInMonth = (int)[DateUtil getDaysInMonth:monthToLoad year:yearToLoad];
    
    
    // if cell is out of the month, do not show
    if (indexPath.row < firstDay || indexPath.row >= firstDay + daysInMonth) {
        cell.topLineView.hidden = cell.dateLabel.hidden = cell.circleView.hidden = cell.selectedView.hidden = YES;
    } else {
        cell.topLineView.hidden = cell.dateLabel.hidden = NO;
        cell.circleView.hidden = YES;
        
        BOOL special = NO;
        // if the cell is the current date, display the red circle
        BOOL isToday = NO;
        if (indexPath.row - firstDay + 1 == current_date
            && monthToLoad == current_month
            && yearToLoad == current_year) {
            cell.circleView.hidden = NO;
            NSString *todayBg = [_today stringValueForKey:@"bg" defaultValue:@""];
            //当日的背景
            if ([UZAppUtils isValidColor:todayBg]) {
                cell.circleView.backgroundColor = [UZAppUtils colorFromNSString:todayBg];
                cell.circleView.layer.masksToBounds = YES;
                cell.todayImg.hidden = YES;
            } else {
                cell.todayImg.hidden = NO;
                cell.todayImg.image = [UIImage imageWithContentsOfFile:[self.delegate getPath:todayBg]];
            }
            //当日的字体颜色
            NSString *color = [_today stringValueForKey:@"color" defaultValue:@"#a8d500"];
            if (!color.length) {
                color = @"#a8d500";
            }
            cell.dateLabel.textColor = [UZAppUtils colorFromNSString:color];
            isToday = YES;
        } else {
            NSString *color = [_date stringValueForKey:@"color" defaultValue:@"#3b3b3b"];
            if (!color.length) {
                color = @"#3b3b3b";
            }
            cell.dateLabel.textColor = [UZAppUtils colorFromNSString:color];
        }
        
        NSString *selectedBg = [_date stringValueForKey:@"selectedBg" defaultValue:@"#a8d500"];
        if (!selectedBg.length) {
            
            selectedBg = @"#a8d500";
        }
        if (![UZAppUtils isValidColor:selectedBg]) {
            cell.img.image = [UIImage imageWithContentsOfFile:[self.delegate getPath:selectedBg]];
            cell.img.hidden = NO;
        } else {
            cell.img.hidden = YES;
            cell.selectedView.backgroundColor = [UZAppUtils colorFromNSString:selectedBg];
            cell.selectedView.layer.masksToBounds = YES;
        }
        // if the cell is selected, display the black circle
        //点击后的数字
        NSString *selectedColor = [_date stringValueForKey:@"selectedColor" defaultValue:@"#fff"];
        if (!selectedColor.length) {
            selectedColor = @"#fff";
        }
        
        if (indexPath.row == selectedRow ||
            (day == ((int)indexPath.row - firstDay + 1) && collectionView.tag == 0)) {
            cell.circleView.hidden = YES;
            cell.selectedView.hidden = NO;
            cell.dateLabel.textColor = [UZAppUtils colorFromNSString:selectedColor];
            //收集选中的day:indexPath.row 并发送消息，在open接口设置监听，将值传给setSpecialDates接口
            NSNumber *selectedDayIndex = [NSNumber numberWithInt:((int)indexPath.row - firstDay + 1)];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"currentShowDay"
                                                                object:self
                                                              userInfo:@{@"selectedDay":selectedDayIndex}];
        } else {
            cell.selectedView.hidden = YES;
            // 不选中下的today（工作日）
            if (indexPath.row - firstDay + 1 == current_date
                && monthToLoad == current_month
                && yearToLoad == current_year) {
                cell.circleView.hidden = NO;
                NSString *todayBg = [_today stringValueForKey:@"bg" defaultValue:@""];
                //当日的背景
                if ([UZAppUtils isValidColor:todayBg]) {
                    cell.circleView.backgroundColor = [UZAppUtils colorFromNSString:todayBg];
                    cell.circleView.layer.masksToBounds = YES;
                    cell.todayImg.hidden = YES;
                } else {
                    cell.todayImg.hidden = NO;
                    cell.todayImg.image = [UIImage imageWithContentsOfFile:[self.delegate getPath:todayBg]];
                }
                //当日的字体颜色
                NSString *color = [_today stringValueForKey:@"color" defaultValue:@"#a8d500"];
                if (!color.length) {
                    color = @"#a8d500";
                }
                cell.dateLabel.textColor = [UZAppUtils colorFromNSString:color];
            } else {
                NSString *color = [_date stringValueForKey:@"color" defaultValue:@"#3b3b3b"];
                if (!color.length) {
                    color = @"#3b3b3b";
                }
                cell.dateLabel.textColor = [UZAppUtils colorFromNSString:color];
            }
            //周末的字体颜色
            for (int i = 0; i < _weekDays.count; i++) {
                if (indexPath.row == [_weekDays[i] integerValue]) {
                    cell.dateLabel.textColor = [UZAppUtils colorFromNSString:_weekendColor];
                }
            }
            // 不选中下的today（周末）
            if (indexPath.row - firstDay + 1 == current_date
                 && monthToLoad == current_month
                 && yearToLoad == current_year) {
//                cell.circleView.hidden = NO;    ///
                NSString *todayBg = [_today stringValueForKey:@"bg" defaultValue:@""];
                //当日的背景
                if ([UZAppUtils isValidColor:todayBg]) {
                    cell.circleView.backgroundColor = [UZAppUtils colorFromNSString:todayBg];
                    cell.circleView.layer.masksToBounds = YES;
                    cell.todayImg.hidden = YES;
                    cell.circleView.hidden = NO;    ///
                } else {
                    UIImage * image = [UIImage imageWithContentsOfFile:[self.delegate getPath:todayBg]];
                    if (image) {
                        cell.todayImg.hidden = NO;
                        cell.todayImg.image = image;
                        cell.circleView.hidden = NO;
                        cell.circleView.backgroundColor = [UIColor clearColor];
                    }else {
                        cell.todayImg.hidden = YES;
                        cell.circleView.hidden = YES;
                    }
                }
                //当日的字体颜色
                NSString *color = [_today stringValueForKey:@"color" defaultValue:@"#a8d500"];
                if (!color.length) {
                    color = @"#a8d500";
                }
                cell.dateLabel.textColor = [UZAppUtils colorFromNSString:color];
            }
            //特殊日期
            /*（判断是否选中为指定日：day && collectionView.tag == 0），setSpecial时未传day,故这里需重新判断(主要根据
               open，      collectionView.tag == 0，传的day为-1
               setDate,    传day为d,(day == ((int)indexPath.row - firstDay + 1) && collectionView.tag == 0)
               setSpecial  传的day为0, 当specialDates有指定日期时collectionView.tag == 0，
             */
            // 判断是否为today：day && month && year）,setSpecial时未传day,故这里需重新判断

            for (specialDatesModel *spDatesModel in _specialDate) {
                if (((indexPath.row - firstDay + 1) == [spDatesModel.spDateDate.day integerValue])
                    && (monthToLoad == [spDatesModel.spDateDate.month integerValue])
                    && (yearToLoad == [spDatesModel.spDateDate.year integerValue])) {
                    
                    special = YES;
                    
                    //普通日期选中后的背景Bg
                    NSString *selectedBg = [_date stringValueForKey:@"selectedBg" defaultValue:@"#a8d500"];
                    if (!selectedBg.length) {
                        selectedBg = @"#a8d500";
                    } else {
                        if (![UZAppUtils isValidColor:selectedBg]) {
                            NSString *realPath = [self.delegate getPath:selectedBg];
                            BOOL isPath = [[NSFileManager defaultManager] fileExistsAtPath:realPath];
                            if (!isPath) {
                                selectedBg = @"#a8d500";
                            }
                        }
                    }
                    //判断是否是被选中过的日期 即指定日期
//                    if (([self.selectedDay intValue]-firstDay+1) == [spDatesModel.spDateDate.day integerValue]) {
//                        isSelectedDay = true;
//                    }
                    //ollectionView.tag == 0 && isSelectedDay
                    
                    if (collectionView.tag == 0 && isSelectedDay) {  //特殊日期中的指定日期
//                        cell.circleView.hidden = YES;
//                        cell.selectedView.hidden = NO;
//                        cell.dateLabel.textColor = [UZAppUtils colorFromNSString:selectedColor];
                    } else {
                        //open->styles->specialDate->bg / setSpecialDates->specialDates->bg
                        NSString *specialbg = spDatesModel.spDateBg;
                        if (!specialbg.length) {
                            //open->styles->specialDate->bg
                            specialbg = [_specialDateDict stringValueForKey:@"bg" defaultValue:selectedBg];
                        } else {
                            if (![UZAppUtils isValidColor:specialbg]) {
                                NSString *realPath = [self.delegate getPath:specialbg];
                                BOOL isPath = [[NSFileManager defaultManager] fileExistsAtPath:realPath];
                                if (!isPath) {
                                    //open->styles->specialDate->bg
                                    specialbg = [_specialDateDict stringValueForKey:@"bg" defaultValue:selectedBg];
                                }
                            }
                        }
                        if (!specialbg.length) {
                            //特殊日期里的today Bg
                            if (indexPath.row - firstDay + 1 == current_date
                                && monthToLoad == current_month
                                && yearToLoad == current_year) {
                                cell.circleView.hidden = NO;
                                NSString *todayBg = [_today stringValueForKey:@"bg" defaultValue:@""];
                                if ([UZAppUtils isValidColor:todayBg]) {
                                    cell.circleView.backgroundColor = [UZAppUtils colorFromNSString:todayBg];
                                    cell.circleView.layer.masksToBounds = YES;
                                    cell.todayImg.hidden = YES;
                                } else {
                                    //当日的背景
                                    cell.todayImg.hidden = NO;
                                    cell.todayImg.image = [UIImage imageWithContentsOfFile:[self.delegate getPath:todayBg]];
                                    
                                }
                                continue;
                            } else {
                                specialbg = selectedBg;
                            }
                        }
                        if ([UZAppUtils isValidColor:specialbg]) {
                            cell.circleView.backgroundColor = [UZAppUtils colorFromNSString:specialbg];
                            cell.todayImg.hidden = YES;
                            cell.circleView.layer.masksToBounds = YES;
                        } else {
                            NSString *realPath = [self.delegate getPath:specialbg];
                            BOOL isPath = [[NSFileManager defaultManager] fileExistsAtPath:realPath];
                            if (isPath) {
                                cell.todayImg.hidden = NO;
                                cell.circleView.layer.masksToBounds = NO;
                                cell.todayImg.image = [UIImage imageWithContentsOfFile:[self.delegate getPath:specialbg]];
                            } else {
                                cell.circleView.backgroundColor = [UZAppUtils colorFromNSString:selectedBg];
                                cell.todayImg.hidden = YES;
                                cell.circleView.layer.masksToBounds = YES;
                            }
                        }
                        cell.selectedView.hidden = YES;
                        cell.circleView.hidden = NO;
                        
                        //style->date->color
                        NSString *dateColor = [_date stringValueForKey:@"color" defaultValue:@"3b3b3b"];
                        if (!dateColor.length) {
                            //特殊日期里的today color
                            if (indexPath.row - firstDay + 1 == current_date
                                              && monthToLoad == current_month
                                               && yearToLoad == current_year) {
                                NSString *color = [_today stringValueForKey:@"color" defaultValue:@"#a8d500"];
                                if (!color.length) {
                                    color = @"#a8d500";
                                }
                                cell.dateLabel.textColor = [UZAppUtils colorFromNSString:color];
                            } else {
                                dateColor = @"#3b3b3b";
                            }
                        }
                        //open->styles->specialDate->color / setSpecialDates->specialDates->color
                        NSString *color = spDatesModel.spDateColor;
                        if (!color.length) {
                            color = [_specialDateDict stringValueForKey:@"color" defaultValue:dateColor];
                        }
                        if (!color.length) {
                            color = dateColor;
                        }
                        cell.dateLabel.textColor = [UZAppUtils colorFromNSString:color];
                    }
                }
            }
        }
        
#pragma mark - 修改选中cell
        if (indexPath.row == selectedRow ||
            day == ((int)indexPath.row - firstDay + 1)) {
            cell.selectedView.hidden = NO;
            cell.dateLabel.textColor = [UZAppUtils colorFromNSString:selectedColor];
        }
        
        NSMutableDictionary *sendDict = [NSMutableDictionary dictionaryWithCapacity:3];
        [sendDict setObject:[NSNumber numberWithInt:yearToLoad] forKey:@"year"];
        [sendDict setObject:[NSNumber numberWithInt:monthToLoad] forKey:@"month"];
        [self.delegate callBack:sendDict isShow:NO];
        // set the appropriate date for the cell
        cell.dateLabel.text = [NSString stringWithFormat:@"%i",(int)indexPath.row - firstDay + 1];
        
        #pragma mark - ---
        if (kUZUICalendarMultipleSelect == 1) {
//            cell.selectedView.hidden = YES; // 翻月后清除选择日期
            [cell.selectedView lgg_viewCancelRoundingCorners];
            // 设置选中
            for (NSNumber * row in self.selectArray) {
                if (indexPath.row == [row integerValue]) {
                    cell.selectedView.hidden = NO;
                    cell.dateLabel.textColor = [UZAppUtils colorFromNSString:selectedColor];
                    if (indexPath.row - firstDay + 1 == current_date
                        && monthToLoad == current_month
                        && yearToLoad == current_year) {
                        cell.circleView.hidden = YES;
                        cell.todayImg.hidden = YES;
                    }
                    if (special) {
                        cell.circleView.hidden = YES;
                    }
                    
                    // 设置圆角
                    BOOL left = NO;
                    for (NSNumber * lrow in self.leftArray) {
                        if (indexPath.row == [lrow integerValue]) {
                            left = YES;
                            break;
                        }
                    }
                
                    BOOL right = NO;
                    for (NSNumber * rrow in self.rightArray) {
                        if (indexPath.row == [rrow integerValue]) {
                            right = YES;
                            break;
                        }
                    }
                    
                    if (left && right) {
                        [cell.selectedView lgg_viewRoundingCorners:UIRectCornerAllCorners];
                    }else if (left){
                        [cell.selectedView lgg_viewRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft];
                    }else if (right) {
                        [cell.selectedView lgg_viewRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight];
                    }
                    
                    break;
                }
            }
        }
        
    }
    [cell.dateLabel setFont:[UIFont systemFontOfSize:[_date floatValueForKey:@"size" defaultValue:24]]];
    return cell;
}

/*
 * Scale the collection view size to fit the frame
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int width = self.frame.size.width;
    int height = self.frame.size.height - headerSize;
//    float width = self.frame.size.width;
//    float height = self.frame.size.height - headerSize;
    cellSize = CGSizeMake(width/DAYS_IN_WEEKS, height / MAX_WEEK);
    return CGSizeMake(width/DAYS_IN_WEEKS, height / MAX_WEEK);
}

/*
 * Set all spaces between the cells to zero
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

/*
 * If the width of the calendar cannot be divided by 7, add offset to each side to fit the calendar in
 */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    int width = self.frame.size.width;
//    int offset = (width % DAYS_IN_WEEKS) / 4;
    float offset = (width % DAYS_IN_WEEKS) / 2;
    // top, left, bottom, right
    return UIEdgeInsetsMake(0,offset,0,offset);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    int daysInMonth = (int)[DateUtil getDaysInMonth:[self monthToLoad:(int)collectionView.tag] year:[self yearToLoad:(int)collectionView.tag]];
    day = -1;
    int dateSelected = (int)indexPath.row - firstDay + 1;
    
    if (dateSelected < 1 || dateSelected > daysInMonth) {
        return;
    }
    
    if (!(indexPath.row < firstDay || indexPath.row >= firstDay + daysInMonth)) {
        if (nil != _delegate && [_delegate respondsToSelector:@selector(SACalendar:didSelectDate:month:year:)]) {
            [_delegate SACalendar:self didSelectDate:dateSelected month:month year:year];
        }
        selectedRow = (int)indexPath.row;
    #pragma mark - 修改day
        day = (int)indexPath.row - firstDay + 1;
    } else {
        selectedRow = DESELECT_ROW;
        day = -1;
    }
    
    //点击回调
    int monthToLoad = [self monthToLoad:(int)collectionView.tag];
    int yearToLoad = [self yearToLoad:(int)collectionView.tag];
    
    NSString *eventType = @"normal";
    for (specialDatesModel *spModel in _specialDate) {
        if (dateSelected == [spModel.spDateDate.day integerValue]
            && monthToLoad == [spModel.spDateDate.month integerValue]
            && yearToLoad == [spModel.spDateDate.year integerValue]) {
            eventType = @"special";
        }
    }
    
    #pragma mark - ---
    if (kUZUICalendarMultipleSelect == 1) {
        SACalendarCell * cell = (SACalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (cell.selectedView.isHidden == NO) { // 取消选中效果
            selectedRow = DESELECT_ROW;
            day = -1;
            [self.selectArray removeObject:@(indexPath.row)];
            eventType = [eventType isEqualToString:@"normal"] ? @"cancelNormal" : @"cancelSpecial";
            
            // 圆角效果
            if ((indexPath.row != 0) && (indexPath.row !=7) && (indexPath.row !=14) && (indexPath.row !=21) && (indexPath.row !=28) && (indexPath.row !=35)) {
                // 左边
                NSIndexPath * preIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
                SACalendarCell * preCell = (SACalendarCell *)[collectionView cellForItemAtIndexPath:preIndexPath];
                if (preCell.selectedView.isHidden == NO) {
                    [self.rightArray addObject:@(indexPath.row-1)];
                }else{
                    [self.leftArray removeObject:@(indexPath.row)];
                }
            }
            if ((indexPath.row != 41) && (indexPath.row !=6) && (indexPath.row !=13) && (indexPath.row !=20) && (indexPath.row !=27) && (indexPath.row !=34)) {
                // 右边
                NSIndexPath * nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
                SACalendarCell * nextCell = (SACalendarCell *)[collectionView cellForItemAtIndexPath:nextIndexPath];
                if (nextCell.selectedView.isHidden == NO) {
                    [self.leftArray addObject:@(indexPath.row+1)];
                }else {
                    [self.rightArray removeObject:@(indexPath.row)];
                }
            }
        }else{ // 添加选中效果
            [self.selectArray addObject:@(indexPath.row)];
            
            // 圆角效果
            if ((indexPath.row != 0) && (indexPath.row !=7) && (indexPath.row !=14) && (indexPath.row !=21) && (indexPath.row !=28) && (indexPath.row !=35)) {
                // 左边
                NSIndexPath * preIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
                SACalendarCell * preCell = (SACalendarCell *)[collectionView cellForItemAtIndexPath:preIndexPath];
                if (preCell.selectedView.isHidden == YES) {
                    [self.leftArray addObject:@(indexPath.row)];
                }else{
                    [self.rightArray removeObject:@(indexPath.row-1)];
                }
            }
            
            if ((indexPath.row != 41) && (indexPath.row !=6) && (indexPath.row !=13) && (indexPath.row !=20) && (indexPath.row !=27) && (indexPath.row !=34)) {
                // 右边
                NSIndexPath * nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
                SACalendarCell * nextCell = (SACalendarCell *)[collectionView cellForItemAtIndexPath:nextIndexPath];
                if (nextCell.selectedView.isHidden == YES) {
                    [self.rightArray addObject:@(indexPath.row)];
                }else{
                    [self.leftArray removeObject:@(indexPath.row+1)];
                }
            }
            
        }
    }
    
    NSMutableDictionary *dateDict = [NSMutableDictionary dictionaryWithCapacity:3];
    [dateDict setObject:[NSNumber numberWithInt:yearToLoad] forKey:@"year"];
    [dateDict setObject:[NSNumber numberWithInt:monthToLoad] forKey:@"month"];
    [dateDict setObject:[NSNumber numberWithInt:dateSelected] forKey:@"day"];
    [dateDict setObject:eventType forKey:@"eventType"];
    [self.delegate callBack:dateDict isShow:YES];
    
    [collectionView reloadData];
}

- (void)changeDate:(float)months {
    if (months > 0) {
        [scrollView setContentOffset:CGPointMake(0, scrollView.contentSize.height + months*self.frame.size.height)];
        return;
    }
    [scrollView setContentOffset:CGPointMake(0, - self.frame.size.height)];
}

/**
 *  Clean up
 */
- (void)dealloc {
    [self removeObserver:self forKeyPath:@"delegate"];
}

- (NSString *)getPathCell:(NSString *)path {
    return [self.delegate getPath:path];
}

@end
