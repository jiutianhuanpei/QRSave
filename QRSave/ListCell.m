//
//  ListCell.m
//  QRSave
//
//  Created by shenhongbang on 2016/10/13.
//  Copyright © 2016年 中移(杭州)信息技术有限公司. All rights reserved.
//

#import "ListCell.h"

CGFloat const VSpace = 10;
CGFloat const PhotoW = 80;

@interface ListCell ()

@property (nonatomic, strong) UIImageView *photo;
@property (nonatomic, strong) UILabel *content;
@property (nonatomic, strong) UILabel *time;

@end

@implementation ListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.photo];
        [self addSubview:self.content];
        [self addSubview:self.time];
        
        self.layer.shouldRasterize = true;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    }
    return self;
}

#pragma mark - Action
- (void)configModel:(ListModel *)model {
    _photo.image = [UIImage imageWithData:model.imgData];
    _content.text = model.content;
    
    static NSDateFormatter *mat = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mat = [[NSDateFormatter alloc] init];
        mat.dateFormat = @"yyyy/mm/dd hh:mm:ss";
    });
    
    NSString *time = [mat stringFromDate:model.date];

    _time.text = time;
    
    _photo.frame = CGRectMake(VSpace, VSpace, PhotoW, PhotoW);
    
    CGFloat width = CGRectGetWidth(self.frame) - VSpace * 3 - PhotoW;
    
    CGSize contentSize = [_content.text boundingRectWithSize:CGSizeMake(width, _content.font.lineHeight * 3) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : _content.font} context:nil].size;
    _content.frame = CGRectMake(CGRectGetMaxX(_photo.frame) + VSpace, VSpace, width, contentSize.height);
    
    _time.frame = CGRectMake(CGRectGetMaxX(_photo.frame) + VSpace, CGRectGetHeight(self.frame) - VSpace - _time.font.lineHeight, width, _time.font.lineHeight);
}

+ (CGFloat)heightWithModel:(ListModel *)model {
    return VSpace * 2 + PhotoW;
}

#pragma mark - getter
- (UIImageView *)photo {
    if (_photo == nil) {
        _photo = [[UIImageView alloc] initWithFrame:CGRectZero];
        _photo.layer.cornerRadius = PhotoW / 2.;
        _photo.layer.masksToBounds = true;
    }
    return _photo;
}

- (UILabel *)content {
    if (_content == nil) {
        _content = [[UILabel alloc] initWithFrame:CGRectZero];
        _content.textColor = [UIColor redColor];
        _content.font = [UIFont systemFontOfSize:16];
        _content.numberOfLines = 0;
    }
    return _content;
}

- (UILabel *)time {
    if (_time == nil) {
        _time = [[UILabel alloc] initWithFrame:CGRectZero];
        _time.textColor = [UIColor grayColor];
        _time.font = [UIFont systemFontOfSize:14];
    }
    return _time;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
