//
//  ViewController.m
//  图片合成
//
//  Created by Christian on 16/3/5.
//  Copyright © 2016年 slq. All rights reserved.
//
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define ScreenWidth [UIScreen mainScreen].bounds.size.width

#import "ViewController.h"
#import "SLQCollectionView.h"

@interface ViewController ()
/// UILabel
@property (nonatomic, strong) UILabel *contentLabel;
/// UITextField
@property (nonatomic, strong) UITextField *nameField;
/// UITextField
@property (nonatomic, strong) UITextField *ageField;
/// UITextField
@property (nonatomic, strong) UITextField *infoField;
/// UITextField
@property (nonatomic, strong) UITextField *timeField;
/// SLQCollectionView
@property (nonatomic, strong) SLQCollectionView *collectionView;
/// SLQCollectionView
@property (nonatomic, strong) UIButton *mergePhoto;
/// 图片数组
@property (nonatomic, strong) NSMutableArray *photoArr;

/// 文字图片
@property (nonatomic, strong) UIImage *textImage;
/// 将要保存的图片
@property (nonatomic, strong) UIImage *postImage;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupViews];
}

- (NSString *)getCurrentDate {
    // 设置当前时间
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *currentDate = [NSDate date];
    NSString *createTime = [dateformatter stringFromDate:currentDate];
    return createTime;
}

/// 初始化子控件
- (void)setupViews {
    //
    _nameField = [[UITextField alloc] initWithFrame:CGRectMake(0, 22, ScreenWidth, 44)];
    _nameField.placeholder = @"请输入姓名";
    [self.view addSubview:_nameField];
    
    _ageField = [[UITextField alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_nameField.frame), ScreenWidth, 44)];
    _ageField.placeholder = @"请输入年龄";
    [self.view addSubview:_ageField];
    
    _infoField = [[UITextField alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_ageField.frame), ScreenWidth, 44)];
    _infoField.placeholder = @"请输入简介";
    [self.view addSubview:_infoField];
    
    _timeField = [[UITextField alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(_infoField.frame),ScreenWidth, 44)];
    _timeField.text = [self getCurrentDate];
    _timeField.enabled = NO;
    [self.view addSubview:_timeField];

    
    _collectionView = [[SLQCollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_timeField.frame),ScreenWidth, 100)];
    [_collectionView setTitle:@"相关照片"];
    __weak typeof (self)weakSelf = self;
    _collectionView.heightAndPhotosBlock = ^(CGFloat height,NSArray *photos){
        [weakSelf.photoArr removeAllObjects];
        weakSelf.photoArr = [NSMutableArray arrayWithArray:photos];
    };

    [self.view addSubview:_collectionView];
    
    _mergePhoto = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_collectionView.frame), 100, 44)];
    [_mergePhoto setTitle:@"发布" forState:UIControlStateNormal];
    _mergePhoto.backgroundColor = [UIColor redColor];
    [_mergePhoto addTarget:self action:@selector(postPhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_mergePhoto];
    
    _mergePhoto.center = CGPointMake(ScreenWidth/2, _mergePhoto.center.y);
    
    _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 200)];
    _contentLabel.hidden = YES;
    
    [self.view addSubview:_contentLabel];
    
}

/// 发布图片
- (void)postPhoto {
    self.postImage = nil;
    
    NSString *name = self.nameField.text;
    NSString *age = self.ageField.text;
    NSString *info = self.infoField.text;
    NSString *time = self.timeField.text;
    
    NSString *content = [NSString stringWithFormat:@"姓名：%@\n年龄：%@\n简介：%@\n时间：%@\n相关图片：",name,age,info,time];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.text = content;
    [self.contentLabel sizeToFit];
    self.contentLabel.hidden = NO;
    [self.contentLabel setNeedsDisplay];

    
    if (self.photoArr.count) {
        for (NSInteger i = 0 ; i < self.photoArr.count; i ++) {
            
            self.postImage = [self mergeImages:self.photoArr[i]];
        }
    }
}

#pragma mark - 合成图片
// 获得顶部图片
- (UIImage *)getImageFromView
{
    // 已经合成过一次,就去上次的合成结果
    if(self.postImage) {
        return self.postImage;
    }else
    {
        // 获取contentLable
        UIGraphicsBeginImageContextWithOptions(self.contentLabel.frame.size, NO, 0.0);
        //获取图像
        [self.contentLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.contentLabel.hidden = YES;
        // 保存图片，需要转换成二进制数据
        [self saveImageToPhotos:image];
        self.contentLabel.hidden = YES;
        self.textImage = image;
        return image;
    }
}

// 获得待合成图片
- (UIImage *)mergeImages:(UIImage *)mergeImage
{
    UIImage *newimage = mergeImage;
    UIImage *postImage = [self getImageFromView];
    // 获取位图上下文
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(ScreenWidth, postImage.size.height + ScreenHeight - self.textImage.size.height), NO, 0.0);
    [newimage drawInRect:CGRectMake(0, postImage.size.height, ScreenWidth, ScreenHeight - self.textImage.size.height)];

    [postImage drawAtPoint:CGPointMake(0,0)];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)photoArr{
    if (!_photoArr) {
        _photoArr = [NSMutableArray array];
    }
    return _photoArr;
}

@end
