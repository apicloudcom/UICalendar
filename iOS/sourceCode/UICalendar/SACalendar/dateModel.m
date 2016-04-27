/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */

#import "dateModel.h"

@implementation dateModel

- (id)copyWithZone:(NSZone *)zone {
    dateModel *model = [[dateModel alloc]init];
    model.year = self.year;
    model.month = self.month;
    model.day = self.day;
    return model;
}

@end
