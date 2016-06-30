//
//  SLQCollectionView.m
//  SLQUniversalProject
//
//  Created by Christian on 16/1/7.
//  Copyright © 2016年 slq. All rights reserved.
//

#define CollectionCellWH 50
#define CollectionCellColumn 5
#define CollectionCellMargin 5
#define CollectionCellButtonFontSize 15

#ifndef ScreenWidth
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#endif
#ifndef ScreenHeight
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#endif

#ifndef UIColorFromRGB
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#endif

#import "SLQCollectionView.h"
//#import "PhotoBroswerVC.h"


@interface SLQCollectionView ()
<
UICollectionViewDataSource,
UICollectionViewDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate
>


/**title*/
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *rightTitleLabel;

@property (strong, nonatomic) UICollectionView *photoCollectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *photoCellectionFlowLayout;
/// 图片数组
@property (nonatomic, strong) NSMutableArray *photoArr;
/// collection高度
@property (assign, nonatomic) CGFloat photoCollectionViewHeight;

@property (nonatomic,strong) UIImagePickerController *imagePickerController;
@end

@implementation SLQCollectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UILabel *starLabel = [[UILabel alloc] init];
        starLabel.text = @"*";
        starLabel.textColor = [UIColor redColor];
        starLabel.font = [UIFont systemFontOfSize:17];
        starLabel.frame = CGRectMake(7, 0, 8.5, 44);
        [self addSubview:starLabel];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(starLabel.frame) + 2,0, 70, 44)];
        _titleLabel.text = @"拍照记录";
        _titleLabel.font = [UIFont systemFontOfSize:17];
        [self addSubview:_titleLabel];
        
        _rightTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_titleLabel.frame) ,0, frame.size.width - 120, 44)];
        _rightTitleLabel.text = @"（至少一张照片）";
        _rightTitleLabel.textColor = UIColorFromRGB(0x708090);
        _rightTitleLabel.font = [UIFont systemFontOfSize:CollectionCellButtonFontSize - 2];
        [self addSubview:_rightTitleLabel];
        
        _photoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(CGRectGetMinX(starLabel.frame),CGRectGetHeight(_rightTitleLabel.frame), frame.size.width - 2 * 5, CollectionCellWH) collectionViewLayout:self.photoCellectionFlowLayout];
        
        _photoCollectionView.backgroundColor = [UIColor whiteColor];
        _photoCollectionView.dataSource = self;
        _photoCollectionView.delegate = self;
        
        [_photoCollectionView registerClass:[PhotoCollectionViewCell class] forCellWithReuseIdentifier:@"PhotoCollectionViewCell"];
        
        [self addSubview:_photoCollectionView];
    }
    return self;
}

- (void)setRightTitle:(NSString *)title withColor:(UIColor *)color
{
    if (![title isEqualToString:@""]) {
        
        self.rightTitleLabel.text = [NSString stringWithFormat:@"(%@)",title];
        self.rightTitleLabel.numberOfLines = 0;
        CGRect temp = _photoCollectionView.frame;
        temp.origin.y = CGRectGetMaxY(self.rightTitleLabel.frame);
        _photoCollectionView.frame = temp;
    }
    
    if (color) {
        self.rightTitleLabel.textColor = color;
    }
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (void)setPhotos:(NSArray *)photos
{
    _photoArr = [NSMutableArray arrayWithArray:photos];
    [_photoCollectionView reloadData];
    
    [self getHeight];
}

- (void)getHeight{
    NSInteger row = self.photoArr.count / CollectionCellColumn;
    self.photoCollectionViewHeight = (row + 1) * (CollectionCellMargin + CollectionCellWH);
    CGFloat preHeight = CGRectGetHeight(self.photoCollectionView.frame);
    self.photoCollectionView.frame = CGRectMake(CGRectGetMinX(self.photoCollectionView.frame),
                                                CGRectGetMinY(self.photoCollectionView.frame),
                                                CGRectGetWidth(self.photoCollectionView.frame),
                                                self.photoCollectionViewHeight);
    [self.photoCollectionView reloadData];
    self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame),CGRectGetMaxY(self.photoCollectionView.frame));
    
    // 传递高度变化值
    self.heightAndPhotosBlock(self.photoCollectionViewHeight - preHeight,self.photoArr);
}

#pragma mark - UIImagePickerControllerDelegate
/// 拍照相关
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage *photo = info[UIImagePickerControllerOriginalImage];
    UIImage *resultImage = [self mergeImages:photo];
    [self.photoArr addObject:resultImage];
    
    [self getHeight];
    
    [_imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [_imagePickerController dismissViewControllerAnimated:YES completion:nil];
}
// 获得待合成图片
- (UIImage *)mergeImages:(UIImage *)mergeImage
{
    UIImage *newimage = mergeImage;
//    UIImage *postImage = [self gestImageFromView];
    // 获取位图上下文
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(ScreenWidth,ScreenHeight), NO, 0.0);
    [newimage drawInRect:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    
    // 设置当前时间
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    NSDate *currentDate = [NSDate date];
    NSString *createTime = [dateformatter stringFromDate:currentDate];
    
    [createTime drawAtPoint:CGPointMake(0, 0) withAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
    //    [str drawAtPoint:CGPointMake(0,0) withFont:[UIFont systemFontOfSize:22]];
    //    [postImage drawAtPoint:CGPointMake(0,0)];
    // 获取位图
    UIImage *saveimage = UIGraphicsGetImageFromCurrentImageContext();
    // 关闭位图上下文
    UIGraphicsEndImageContext();
    // 保存图片，需要转换成二进制数据
    [self saveImageToPhotos:saveimage];
    return saveimage;
}

- (void)saveImageToPhotos:(UIImage*)savedImage
{
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}
// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.photoArr.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PhotoCollectionViewCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCollectionViewCell" forIndexPath:indexPath];
    if (indexPath.item < self.photoArr.count) {
        photoCell.deleteButton.hidden = NO;
        photoCell.imageView.image = (UIImage *)self.photoArr[indexPath.item];
        [photoCell.deleteButton setBackgroundImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];

//        [photoCell.deleteButton setBackgroundImage:[UIImage imageNamed:@"输入撤销"] forState:UIControlStateHighlighted];
        photoCell.deleteButton.tag = indexPath.item;
        [photoCell.deleteButton addTarget:self action:@selector(deleteButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }else{
        photoCell.deleteButton.hidden = YES;
        photoCell.imageView.image = [UIImage imageNamed:@"add"];
    }
    
    return photoCell;
}
//删除按钮点击事件
- (void)deleteButtonDidClick:(UIButton *)sender {
    NSLog(@"------删除图片按钮被点击了");
    [self.photoArr removeObjectAtIndex:sender.tag];
    [self getHeight];
//    [self.photoCollectionView reloadData];


}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item >= self.photoArr.count) {
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self.imagePickerController animated:YES completion:NULL];
    }
    else
    {
        // 图片浏览
//        [self localImageShow:indexPath.item];
    }
}
///*
// *  本地图片展示
// */
//-(void)localImageShow:(NSUInteger)index {
//    
//    [PhotoBroswerVC show:[self getCurrentVC] type:PhotoBroswerVCTypeModal index:index photoModelBlock:^NSArray *{
//        NSMutableArray *modelsM = [NSMutableArray arrayWithCapacity:self.photoArr.count];
//        for (NSUInteger i = 0; i< self.photoArr.count; i++) {
//            
//            PhotoModel *pbModel=[[PhotoModel alloc] init];
//            pbModel.mid = i + 1;
//            pbModel.image = self.photoArr[i];
//            
//            [modelsM addObject:pbModel];
//        }
//        
//        return modelsM;
//    }];
//}

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

#pragma mark - 懒加载
- (UICollectionViewFlowLayout *)photoCellectionFlowLayout
{
    if (!_photoCellectionFlowLayout) {
        _photoCellectionFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        _photoCellectionFlowLayout.itemSize = CGSizeMake(CollectionCellWH, CollectionCellWH);
        _photoCellectionFlowLayout.minimumInteritemSpacing = 10;
        _photoCellectionFlowLayout.minimumLineSpacing = 10;
        _photoCellectionFlowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
    }
    return _photoCellectionFlowLayout;
}

- (NSMutableArray *)photoArr
{
    if (!_photoArr) {
        _photoArr = [NSMutableArray array];
    }
    return _photoArr;
}

- (UIImagePickerController *)imagePickerController
{
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            _imagePickerController.delegate = self;
        }
    }
    return _imagePickerController;
}


@end


@implementation PhotoCollectionViewCell


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _imageView.userInteractionEnabled = YES;
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        //删除图片按钮
        _deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-15, 0, 15, 15)];
//        _deleteButton.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:_imageView];
        [self.contentView addSubview:_deleteButton];
    }
    return self;
}

@end
