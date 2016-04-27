/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import "specialDatesModel.h"
#import "dateModel.h"

@implementation specialDatesModel

- (instancetype)initWithSpecialDates:(NSDictionary *)specialDateData {
    self = [super init];
    if (self) {
        NSString *date = [specialDateData objectForKey:@"date"];
        NSString *color = [specialDateData objectForKey:@"color" ];
        NSString *bg = [specialDateData objectForKey:@"bg"];
        self.spDateColor = color;
        self.spDateBg = bg;
        
        NSDateComponents *tempCom = [[NSDateComponents alloc]init];
        dateModel *model = [[dateModel alloc] init];
        tempCom.year = [[date substringToIndex:4]intValue];
        tempCom.month = [[[date substringFromIndex:5]substringToIndex:2]intValue];
        tempCom.day =[[date substringFromIndex:8] intValue];
        model.year = [NSString stringWithFormat:@"%ld",(long)tempCom.year];
        model.month = [NSString stringWithFormat:@"%ld",(long)tempCom.month];
        model.day = [NSString stringWithFormat:@"%ld",(long)tempCom.day];
        self.spDateDate = model;
    }
    return self;
}

@end
