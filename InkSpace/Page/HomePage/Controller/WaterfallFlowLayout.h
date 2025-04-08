//
//  WaterfallFlowLayout.h
//  InkSpace
//
//  Created by puyang on 2024/6/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WaterfallFlowLayoutDelegate <NSObject>

@required
// 返回每个item的高度
- (CGFloat)waterfallLayout:(UICollectionViewLayout *)layout heightForItemAtIndexPath:(NSIndexPath *)indexPath itemWidth:(CGFloat)itemWidth;

@optional
// 返回列数
- (NSInteger)columnCountInWaterfallLayout:(UICollectionViewLayout *)layout;
// 返回列间距
- (CGFloat)columnMarginInWaterfallLayout:(UICollectionViewLayout *)layout;
// 返回行间距
- (CGFloat)rowMarginInWaterfallLayout:(UICollectionViewLayout *)layout;
// 返回内边距
- (UIEdgeInsets)edgeInsetsInWaterfallLayout:(UICollectionViewLayout *)layout;

@end

@interface WaterfallFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, weak) id<WaterfallFlowLayoutDelegate> delegate;

@end

NS_ASSUME_NONNULL_END 