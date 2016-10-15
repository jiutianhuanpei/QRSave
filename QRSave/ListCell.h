//
//  ListCell.h
//  QRSave
//
//  Created by shenhongbang on 2016/10/13.
//  Copyright © 2016年 中移(杭州)信息技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListModel.h"

@interface ListCell : UITableViewCell

- (void)configModel:(ListModel *)model;

+ (CGFloat)heightWithModel:(ListModel *)model;

@end
