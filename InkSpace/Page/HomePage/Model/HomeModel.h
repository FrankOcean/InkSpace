//
//  HomeModel.h
//  InkSpace
//
//  Created by puyang on 2024/6/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeModel : NSObject

@property (nonatomic, assign) unsigned int ID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *resolution;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) unsigned int favorite;

+ (unsigned int)getHistoricIDForCategory:(NSUInteger)category;
+ (void)setHistoricID:(unsigned int)ID forCategory:(NSUInteger)category;

@end

NS_ASSUME_NONNULL_END
