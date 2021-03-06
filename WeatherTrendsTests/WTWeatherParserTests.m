//
//  WeatherTrendsTests.m
//  WeatherTrendsTests
//
//  Created by Mariia Cherniuk on 29.08.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSManagedObjectContext+Tests.h"
#import "WTWeatherParser.h"
#import "WTCity.h"
#import "WTYear.h"
#import "WTLocation.h"
#import "WTMonth.h"

@interface WTWeatherParserTests : XCTestCase

@property (nonatomic, readwrite, strong) NSManagedObjectContext *context;

@end

@implementation WTWeatherParserTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    self.context = [NSManagedObjectContext WT_testManagedObjectContextWithBundle:bundle];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testParseWeatherData1 {
    [self runParseTestForWheaterDataFileName:@"weather_data1"];
}

- (void)testParseWheatherData2 {
    [self runParseTestForWheaterDataFileName:@"weather_data2"];
}

- (void)testThatItDoesNotParseNilData {
    WTWeatherParser *parser = [[WTWeatherParser alloc] initWithManagedObjectContext:_context];
    WTCity *city = [parser parseWeatherData:nil];
    
    XCTAssertNil(city);
}

- (void)runParseTestForWheaterDataFileName:(NSString *)fileName {
    //GIVEN
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:fileName withExtension:@"txt"];
    NSData *weatherData = [NSData dataWithContentsOfURL:url];
    WTWeatherParser *parser = [[WTWeatherParser alloc] initWithManagedObjectContext:_context];
    
    //WHEN
    WTCity *city = [parser parseWeatherData:weatherData];
    
    //THEN
    [self checkFieldsForCity:city];
}

- (void)checkFieldsForCity:(WTCity *)city {
    XCTAssertNotNil(city);
    XCTAssertNotNil(city.name);
    
    XCTAssertNotNil(city.location);
    [self checkFieldsForLocation:city.location];
    
    XCTAssertNotNil(city.years);
    [self checkFieldsForYears:city.years];
}

- (void)checkFieldsForLocation:(WTLocation *)location {
    XCTAssertNotNil(location.latitude);
    XCTAssertNotNil(location.longitude);
    XCTAssertNotNil(location.metresAboveSea);
}

- (void)checkFieldsForYears:(NSSet *)years {
    for (WTYear *year in years) {
        XCTAssertNotNil(year.number);
        XCTAssertNotNil(year.months);
        XCTAssertNotNil(year.averageMaxTemp);
        XCTAssertNotNil(year.averageMinTemp);
        XCTAssertNotNil(year.averageAFDays);
        XCTAssertNotNil(year.averageRainfall);
        XCTAssertNotNil(year.averageSunshine);
        
        for (WTMonth *month in year.months) {
            [self checkFieldsForMonth:month];
        }
    }
}

- (void)checkFieldsForMonth:(WTMonth *)month {
    XCTAssertNotNil(month.afDays);
    XCTAssertNotNil(month.maxTemp);
    XCTAssertNotNil(month.rainAmount);
    XCTAssertNotNil(month.minTemp);
    XCTAssertNotNil(month.number);
    XCTAssertNotNil(month.sunAmount);
}

@end
