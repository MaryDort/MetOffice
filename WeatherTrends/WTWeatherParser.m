//
//  WTWeatherParser.m
//  WeatherTrends
//
//  Created by Mariia Cherniuk on 29.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import "WTWeatherParser.h"
#import "WTCity.h"
#import "WTLocation.h"
#import "WTYear.h"
#import "WTMonth.h"

@interface WTWeatherParser ()

@property (nonatomic, readwrite, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation WTWeatherParser

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    self = [super init];
    
    if (self) {
        _managedObjectContext = managedObjectContext;
    }
    
    return self;
}

- (void)parseWeatherData:(NSData *)weatherData {
    NSString *dataString = [[NSString alloc] initWithData:weatherData encoding:NSUTF8StringEncoding];
    NSArray *components = [dataString componentsSeparatedByString:@"\n"];
    WTLocation *location = [self parsedLacationFromComponents:components[1]];
    NSArray *yearMonthArray = [components subarrayWithRange:NSMakeRange(7, components.count-7)];
    NSSet *yearsSet = [self yearsFromComponents:yearMonthArray];
    
    [self parseCityWithName:components[0] location:location years:yearsSet];
}

- (WTLocation *)parsedLacationFromComponents:(NSString *)components {
    NSArray *locationComponents = [components componentsSeparatedByString:@","];
    NSArray *latitudeLongitudeComponents = [self seperatedComponentsFromString:locationComponents[1]];
    WTLocation *location = [NSEntityDescription insertNewObjectForEntityForName:@"WTLocation"
                                                         inManagedObjectContext:_managedObjectContext];
    
    location.latitude = latitudeLongitudeComponents[1];
    location.longitude = latitudeLongitudeComponents[3];
    location.metresAboveSea = locationComponents[2];

    return location;
}

- (void)parseCityWithName:(NSString *)name location:(WTLocation *)location years:(NSSet *)years {
    WTCity *city = [NSEntityDescription insertNewObjectForEntityForName:@"WTCity"
                                                         inManagedObjectContext:_managedObjectContext];
    
    city.name = name;
    city.location = location;
    city.years = years;
}

- (NSSet *)yearsFromComponents:(NSArray *)components {
    NSMutableSet *yearsSet = [[NSMutableSet alloc] init];
    NSString *currentYear = @"";
    WTYear *year;
    
    for (NSString *component in components) {
        if (component.length != 0) {
            NSArray *yearMonthComponents = [self seperatedComponentsFromString:component];
            
            if (![currentYear isEqualToString:yearMonthComponents[0]]) {
                year = [NSEntityDescription insertNewObjectForEntityForName:@"WTYear"
                                                     inManagedObjectContext:_managedObjectContext];
               
                year.number = yearMonthComponents[0];
                currentYear = year.number;
                
                [yearsSet addObject:year];
            }
            [year addMonthsObject:[self parsedMonthFromComponents:yearMonthComponents]];
        }
    }
    
    return yearsSet;
}

- (WTMonth *)parsedMonthFromComponents:(NSArray *)components {
    WTMonth *month = [NSEntityDescription insertNewObjectForEntityForName:@"WTMonth"
                                                   inManagedObjectContext:_managedObjectContext];
   
    month.number = components[1];
    month.maxTemp = components[2];
    month.minTemp = components[3];
    month.afDays = components[4];
    month.rainAmount = components[5];
    month.sunAmount = components[6];

    return month;
}

#pragma mark - Helper

- (NSArray *)arrayWithoutEmptyComponentsFromSourceArray:(NSArray *)source {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString *evaluatedObject,
                                                                   NSDictionary<NSString *,id> *bindings) {
        return evaluatedObject.length != 0;
    }];
    
    return [source filteredArrayUsingPredicate:predicate];
}

- (NSArray *)seperatedComponentsFromString:(NSString *)component {
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    NSArray *yearMonthSeparatedComponents = [component componentsSeparatedByCharactersInSet:set];
    NSArray *yearMonthComponents = [self arrayWithoutEmptyComponentsFromSourceArray:yearMonthSeparatedComponents];
    
    return yearMonthComponents;
}

@end
