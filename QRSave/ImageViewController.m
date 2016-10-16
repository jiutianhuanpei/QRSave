//
//  ImageViewController.m
//  QRSave
//
//  Created by shenhongbang on 2016/10/16.
//  Copyright © 2016年 中移(杭州)信息技术有限公司. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@property (nonatomic, strong) UIImage *image;

@end

@implementation ImageViewController {
    UIImageView *_imgView;
}


- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        _image = image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    _imgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _imgView.contentMode = UIViewContentModeScaleAspectFit;
    _imgView.image = _image;
    [self.view addSubview:_imgView];
    
}

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    __weak typeof(self) SHB = self;
    UIPreviewAction *action = [UIPreviewAction actionWithTitle:@"保存" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [SHB saveImage];
    }];
    UIPreviewAction *cancel = [UIPreviewAction actionWithTitle:@"取消" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        
    }];
    return @[action, cancel];
}

- (void)saveImage {
    UIImageWriteToSavedPhotosAlbum(_image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    __weak typeof(self) SHB = self;
    UILabel *alert = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 80)];
    alert.userInteractionEnabled = false;
    alert.text = @"保存成功";
    alert.textColor = [UIColor whiteColor];
    alert.font = [UIFont systemFontOfSize:30];
    alert.textAlignment = NSTextAlignmentCenter;
    alert.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    alert.layer.cornerRadius = 10;
    alert.layer.masksToBounds = true;
    alert.center = self.view.center;
    alert.alpha = 0;
    [self.view addSubview:alert];
    [UIView animateWithDuration:0.5 animations:^{
        
        alert.alpha = 1;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SHB.navigationController popViewControllerAnimated:true];
        });
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
