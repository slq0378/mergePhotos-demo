//
//  SLQCollectionView.h
//  SLQUniversalProject
//
//  Created by Christian on 16/1/7.
//  Copyright © 2016年 slq. All rights reserved.
// 

#import <UIKit/UIKit.h>

typedef void (^GetHeightAndPhotosBlock)(CGFloat height,NSArray *photos);
@interface SLQCollectionView : UIView

/**
 *  数据传递block
 *  @param height 添加过图片，collectionView的高度变化值
 *  @param photos 图片数组
 */
@property (nonatomic, copy) GetHeightAndPhotosBlock heightAndPhotosBlock;
/**
 *  设置图片
 *
 *  @param photos 图片数组
 */
- (void)setPhotos:(NSArray *)photos;
/**
 *  设置副标题
 *
 *  @param title 标题
 *  @param color 字体颜色
 */
- (void)setRightTitle:(NSString *)title withColor:(UIColor *)color;
/**
 *  设置主标题
 *
 *  @param title 标题
 */
- (void)setTitle:(NSString *)title;

@end


@interface PhotoCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) UIImageView *imageView;
@property(strong,nonatomic)UIButton *deleteButton;
@end
