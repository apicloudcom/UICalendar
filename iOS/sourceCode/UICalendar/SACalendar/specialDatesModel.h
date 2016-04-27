/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import <Foundation/Foundation.h>
#import "dateModel.h"

@interface specialDatesModel : NSObject

@property (strong, nonatomic) dateModel *spDateDate;
@property (strong, nonatomic) NSString *spDateColor;
@property (strong, nonatomic) NSString *spDateBg;

- (instancetype)initWithSpecialDates:(NSDictionary *)specialDateData;

@end
