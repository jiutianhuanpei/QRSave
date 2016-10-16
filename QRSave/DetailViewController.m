//
//  DetailViewController.m
//  QRSave
//
//  Created by shenhongbang on 2016/10/15.
//  Copyright © 2016年 中移(杭州)信息技术有限公司. All rights reserved.
//

#import "DetailViewController.h"
#import "ImageViewController.h"

@interface DetailViewController ()<UIViewControllerPreviewingDelegate>

@property (nonatomic, strong) ListModel *model;

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIImageView *imgView;

@end

@implementation DetailViewController

- (instancetype)initWithListModel:(ListModel *)model {
    self = [super init];
    if (self) {
        _model = model;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"详情";
    self.automaticallyAdjustsScrollViewInsets = false;
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 74, CGRectGetWidth(self.view.frame) - 20, 100)];
    _textView.editable = false;
    _textView.font = [UIFont systemFontOfSize:20];
    [self.view addSubview:_textView];
    
    _textView.text = _model.content;
    
    _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_textView.frame) + 20, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(_textView.frame) - 40)];
    _imgView.contentMode = UIViewContentModeScaleAspectFit;
    _imgView.userInteractionEnabled = true;
    [self.view addSubview:_imgView];
    
    _imgView.image = [UIImage imageWithData:_model.imgData];
    
    
    
    if ([self respondsToSelector:@selector(traitCollection)])
    {
        if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)])
        {
            if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)
            {
                [self registerForPreviewingWithDelegate:self sourceView:_imgView];
                // 支持3D Touch
            }
            else
            {
                UILongPressGestureRecognizer *pres = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
                [_imgView addGestureRecognizer:pres];
                // 不支持3D Touch
            }
        }
    }
}

#pragma mark - UIViewControllerPreviewingDelegate
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    ImageViewController *img = [[ImageViewController alloc] initWithImage:_imgView.image];
    return img;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self.navigationController pushViewController:viewControllerToCommit animated:false];
}



- (void)longPress:(UILongPressGestureRecognizer *)press {
    if (press.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"是否保存到相册？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"不保存" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIImageWriteToSavedPhotosAlbum(_imgView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        
    }]];
    [self presentViewController:alert animated:true completion:nil];
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
