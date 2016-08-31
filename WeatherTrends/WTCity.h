//
//  WTCity.h
//  WeatherTrends
//
//  Created by Mariia Cherniuk on 29.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WTLocation, WTYear;

NS_ASSUME_NONNULL_BEGIN

@interface WTCity : NSManagedObject

+ (WTCity *)WT_findFirsInContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "WTCity+CoreDataProperties.h"
