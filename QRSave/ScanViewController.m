//
//  ScanViewController.m
//  QRSave
//
//  Created by shenhongbang on 2016/10/13.
//  Copyright © 2016年 中移(杭州)信息技术有限公司. All rights reserved.
//

#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import "UIImage+Helps.h"

@interface ScanViewController ()<AVCaptureMetadataOutputObjectsDelegate, AVCapturePhotoCaptureDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;

@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;

@property (nonatomic, strong) AVCapturePhotoOutput *photoOutput;

@property (nonatomic, strong) UIImageView *scanView;

@end

@implementation ScanViewController {
    AVCaptureVideoPreviewLayer *_previewLayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    _output = [[AVCaptureMetadataOutput alloc] init];
    
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];


    if ([self.session canAddInput:input]) {
        [_session addInput:input];
    }
    
    if ([_session canAddOutput:_output]) {
        [_session addOutput:_output];
        //设置扫码支持的编码格式
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
        
        if ([_output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
            [array addObject:AVMetadataObjectTypeQRCode];
        }
        if ([_output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN13Code]) {
            [array addObject:AVMetadataObjectTypeEAN13Code];
        }
        if ([_output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN8Code]) {
            [array addObject:AVMetadataObjectTypeEAN8Code];
        }
        if ([_output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
            [array addObject:AVMetadataObjectTypeCode128Code];
        }
        _output.metadataObjectTypes = array;
        
    }
    
    _imageOutput = [[AVCaptureStillImageOutput alloc] init];
    _imageOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
    if ([_session canAddOutput:_imageOutput]) {
        [_session addOutput:_imageOutput];
    }
    
//    _photoOutput = [[AVCapturePhotoOutput alloc] init];
//    
//    AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettings];
//    
//    [_photoOutput capturePhotoWithSettings:settings delegate:self];
////    _photoOutput.stillImageStabilizationSupported = true;
//    
//    if ([_session canAddOutput:_photoOutput]) {
//        [_session addOutput:_photoOutput];
//    }
    
    
    [self.view addSubview:self.scanView];
    self.scanView.bounds = CGRectMake(0, 0, 150, 150);
    self.scanView.center = self.view.center;
    
    _output.rectOfInterest = [self rectOfInterestByScanViewRect:_scanView.frame];
    
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:_previewLayer];
    
    
    [self.view bringSubviewToFront:_scanView];
    [_session startRunning];
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    [[self.navigationController.navigationBar.subviews firstObject] setAlpha:0];
//}
//
//- (void)viewDidDisappear:(BOOL)animated {
//    [super viewDidDisappear:animated];
//    [[self.navigationController.navigationBar.subviews firstObject] setAlpha:1];
//}

- (CGRect)rectOfInterestByScanViewRect:(CGRect)rect {
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    
    CGFloat x = (height - CGRectGetHeight(rect)) / 2 / height;
    CGFloat y = (width - CGRectGetWidth(rect)) / 2 / width;
    
    CGFloat w = CGRectGetHeight(rect) / height;
    CGFloat h = CGRectGetWidth(rect) / width;
    
    return CGRectMake(x, y, w, h);
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {

    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *codeObj = [metadataObjects firstObject];
        
        AVCaptureConnection *connection = [_imageOutput.connections firstObject];
        if (connection == nil) {
            return;
        }
        
        [_imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
           
            if (imageDataSampleBuffer) {
                NSData *imgData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                
                
                if (_callback) {
                    _callback(imgData, codeObj.stringValue);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:true];
                });
            } else {
                NSLog(@"222");
                
            }
        }];
        [_session removeOutput:_imageOutput];
    }
}

#pragma mark - AVCapturePhotoCaptureDelegate
- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingRawPhotoSampleBuffer:(nullable CMSampleBufferRef)rawSampleBuffer previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings error:(nullable NSError *)erro {
    
    
    
    NSLog(@"");
}

#pragma  mark - getter
- (AVCaptureSession *)session {
    if (_session == nil) {
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = AVCaptureSessionPresetHigh;
        
    }
    return _session;
}

- (UIImageView *)scanView {
    if (_scanView == nil) {
        _scanView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _scanView.layer.borderColor = [UIColor greenColor].CGColor;
        _scanView.layer.borderWidth = 1;
    }
    return _scanView;
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
