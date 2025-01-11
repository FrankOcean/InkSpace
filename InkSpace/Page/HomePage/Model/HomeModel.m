//
//  HomeModel.m
//  InkSpace
//
//  Created by puyang on 2024/6/15.
//

#import "HomeModel.h"

@implementation HomeModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    
    return  @{
        @"ID" : @"id",
        @"desc" : @"description"
    };
    
}

+ (unsigned int)getHistoricIDForCategory:(NSUInteger)category {
    NSString *cate = [NSString stringWithFormat:@"%lu", category];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"historicID_%@", cate];
    if ([defaults objectForKey:key] == nil) {
        return 0;
    } else {
        return (unsigned int)[defaults integerForKey:key];
    }
}

+ (void)setHistoricID:(unsigned int)ID forCategory:(NSUInteger)category {
    NSString *cate = [NSString stringWithFormat:@"%lu", category];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"historicID_%@", cate];
    [defaults setInteger:ID forKey:key];
    [defaults synchronize];  // 同步保存
}

@end
