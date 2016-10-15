//
//  UIImage+Helps.h
//  QRSave
//
//  Created by shenhongbang on 2016/10/13.
//  Copyright © 2016年 中移(杭州)信息技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Helps)

- (UIImage *)cutInRect:(CGRect)rect;

+ (UIImage *)snapshotView:(UIView *)view;

+ (UIImage *)shotImageWithView:(UIView *)view frame:(CGRect)frame;

+ (UIImage *)imageFromLayer:(CALayer *)layer;

+ (UIImage *)qrImageWithContent:(NSString *)content;
+ (UIImage *)qrImageWithContent:(NSString *)content width:(CGFloat)width;

- (NSString *)qrString;

@end
