//
//  ListModel.h
//  QRSave
//
//  Created by shenhongbang on 2016/10/13.
//  Copyright © 2016年 中移(杭州)信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Realm/Realm.h>

@interface ListModel : RLMObject

@property (nonatomic, strong) NSData *imgData;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSDate *date;

@end
