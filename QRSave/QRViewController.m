//
//  QRViewController.m
//  QRSave
//
//  Created by shenhongbang on 2016/10/15.
//  Copyright © 2016年 中移(杭州)信息技术有限公司. All rights reserved.
//

#import "QRViewController.h"
#import "UIImage+Helps.h"
#import <Realm/Realm.h>
#import "ListModel.h"
#import "ImageViewController.h"

@interface QRViewController ()<UIViewControllerPreviewingDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIImageView *imgView;

@end

@implementation QRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.title = @"生成二维码";
    self.automaticallyAdjustsScrollViewInsets = false;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"生成" style:UIBarButtonItemStylePlain target:self action:@selector(generateQRImage)];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 74, CGRectGetWidth(self.view.frame) - 20, 70)];
    _textView.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    _textView.layer.borderColor = [UIColor grayColor].CGColor;
    _textView.layer.cornerRadius = 5;
    _textView.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:_textView];
    
    _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_textView.frame) + 20, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(_textView.frame) - 40)];
    _imgView.contentMode = UIViewContentModeScaleAspectFit;
    _imgView.userInteractionEnabled = true;
    [self.view addSubview:_imgView];
    

    
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_textView becomeFirstResponder];
}

#pragma mark - UIViewControllerPreviewingDelegate
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    ImageViewController *img = [[ImageViewController alloc] initWithImage:_imgView.image];
    return img;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self.navigationController pushViewController:viewControllerToCommit animated:false];
}

#pragma mark - Action
- (void)generateQRImage {
    [self.view endEditing:true];
    if (_textView.text.length == 0) {
        return;
    }
    UIImage *image = [UIImage qrImageWithContent:_textView.text width:CGRectGetWidth(_imgView.frame)];
    _imgView.image = image;
}

- (void)longPress:(UILongPressGestureRecognizer *)press {
    if (press.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"是否保存？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"不保存" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        ListModel *model = [[ListModel alloc] init];
        model.content = _textView.text;
        model.imgData = UIImageJPEGRepresentation(_imgView.image, 1);
        model.date = [NSDate date];
        
        [[RLMRealm defaultRealm] transactionWithBlock:^{
            [[RLMRealm defaultRealm] addOrUpdateObject:model];
        }];
        
    }]];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:true];
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
