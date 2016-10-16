//
//  RootViewController.m
//  QRSave
//
//  Created by shenhongbang on 2016/10/13.
//  Copyright © 2016年 中移(杭州)信息技术有限公司. All rights reserved.
//

#import "RootViewController.h"
#import "ListCell.h"
#import "ScanViewController.h"
#import "DetailViewController.h"
#import "QRViewController.h"
#import "UIImage+Helps.h"
#import <Realm/Realm.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface RootViewController ()<UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *pickPhoto;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) UILabel *hud;

@end

@implementation RootViewController {
    RLMNotificationToken *_notification;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    _dataArray = [NSMutableArray arrayWithCapacity:0];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"生成二维码" style:UIBarButtonItemStylePlain target:self action:@selector(gotoGenerateQR)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"识别二维码" style:UIBarButtonItemStylePlain target:self action:@selector(readQRImage)];
    
    [self.view addSubview:self.tableView];
    
    [self.view addSubview:self.pickPhoto];
    self.pickPhoto.bounds = CGRectMake(0, 0, 80, 80);
    self.pickPhoto.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2., CGRectGetHeight(self.view.frame) - CGRectGetHeight(_pickPhoto.frame));
    
    
    _notification = [[RLMRealm defaultRealm] addNotificationBlock:^(RLMNotification  _Nonnull notification, RLMRealm * _Nonnull realm) {
        [self getData];
    }];
    
    [self getData];
    
}

- (void)getData {
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    
    RLMResults *results = [ListModel allObjectsInRealm:[RLMRealm defaultRealm]];
    
        results = [results sortedResultsUsingDescriptors:@[[RLMSortDescriptor sortDescriptorWithProperty:@"date" ascending:false]]];
    
    for (int i = 0; i < results.count; i++) {
        ListModel *model = [results objectAtIndex:i];
        [array addObject:model];
    }
    
    [_dataArray removeAllObjects];
    [_dataArray addObjectsFromArray:array];
    [_tableView reloadData];
}

#pragma mark - Action
- (void)readQRImage {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = @[(NSString *)kUTTypeImage];
    picker.delegate = self;
    [self presentViewController:picker animated:true completion:nil];
}

- (void)gotoGenerateQR {
    QRViewController *qr = [[QRViewController alloc] init];
    [self.navigationController pushViewController:qr animated:true];
}

- (void)scanQRCode {
    ScanViewController *scan = [[ScanViewController alloc] init];
    
    [scan setCallback:^(NSData *imgData, NSString *stringValue) {
        ListModel *model = [[ListModel alloc] init];
        model.content = stringValue;
        model.imgData = imgData;
        model.date = [NSDate date];
        [[RLMRealm defaultRealm] transactionWithBlock:^{
            [[RLMRealm defaultRealm] addOrUpdateObject:model];
        }];
    }];
    
    [self.navigationController pushViewController:scan animated:true];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:true completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:true completion:^{
        NSString *type = info[UIImagePickerControllerMediaType];
        if ([type isEqualToString:(NSString *)kUTTypeImage]) {
            
            UIImage *image = info[UIImagePickerControllerOriginalImage];
            
            NSString *str = [image qrString];
            
            if (str.length > 0) {
                ListModel *model = [[ListModel alloc] init];
                model.content = str;
                model.date = [NSDate date];
                model.imgData = UIImageJPEGRepresentation(image, 1);
                
                [[RLMRealm defaultRealm] transactionWithBlock:^{
                    [[RLMRealm defaultRealm] addOrUpdateObject:model];
                }];
            } else {
                
                [self showHud];
                
                
                
            }

        }
    }];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ListCell class]) forIndexPath:indexPath];
    
    [cell configModel:_dataArray[indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ListCell heightWithModel:_dataArray[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailViewController *detail = [[DetailViewController alloc] initWithListModel:_dataArray[indexPath.row]];
    [self.navigationController pushViewController:detail animated:true];
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        ListModel *model = _dataArray[indexPath.row];
        [[RLMRealm defaultRealm] transactionWithBlock:^{
            [[RLMRealm defaultRealm] deleteObject:model];
        }];
        
    }];
    return @[action];
}

- (void)showHud {
    [self.view addSubview:self.hud];
    self.hud.center = self.view.center;
    self.hud.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        _hud.alpha = 1;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                _hud.alpha = 0;
            } completion:^(BOOL finished) {
                [_hud removeFromSuperview];
            }];
        });
    }];
}

#pragma mark - getter
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[ListCell class] forCellReuseIdentifier:NSStringFromClass([ListCell class])];
    }
    return _tableView;
}

- (UIButton *)pickPhoto {
    if (_pickPhoto == nil) {
        _pickPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pickPhoto setImage:[UIImage imageNamed:@"pick"] forState:UIControlStateNormal];
        [_pickPhoto addTarget:self action:@selector(scanQRCode) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pickPhoto;
}

- (UILabel *)hud {
    if (_hud == nil) {
        _hud = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        _hud.text = @"未识别";
        _hud.textColor = [UIColor whiteColor];
        _hud.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _hud.font = [UIFont systemFontOfSize:30];
        _hud.textAlignment = NSTextAlignmentCenter;
        _hud.layer.cornerRadius = 10;
        _hud.layer.masksToBounds = true;
    }
    return _hud;
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
