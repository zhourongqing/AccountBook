//
//  ABMainCollectionViewCell.m
//  AccountBook
//
//  Created by zhourongqing on 15/9/19.
//  Copyright (c) 2015年 mtry. All rights reserved.
//

#import "ABMainCollectionViewCell.h"

@interface ABMainCollectionViewCell()

@property (nonatomic, readonly) UILabel *imageLabel;

@property (nonatomic, readonly) UILabel *titleLabel;

@end

@implementation ABMainCollectionViewCell

@synthesize imageLabel = _imageLabel;
@synthesize titleLabel = _titleLabel;

- (UILabel *)imageLabel
{
    if(!_imageLabel)
    {
        _imageLabel = [[UILabel alloc] init];
        _imageLabel.textColor = [UIColor whiteColor];
        _imageLabel.textAlignment = NSTextAlignmentCenter;
        _imageLabel.clipsToBounds = YES;
    }
    return _imageLabel;
}

- (UILabel *)titleLabel
{
    if(!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self.contentView addSubview:self.imageLabel];
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = CGRectZero;
    rect.size.height = CGRectGetHeight(self.contentView.frame) * 3 / 4;
    rect.size.width = rect.size.height;
    rect.origin.x = (CGRectGetWidth(self.contentView.frame) - rect.size.width) / 2;
    self.imageLabel.frame = rect;
    self.imageLabel.layer.cornerRadius = CGRectGetHeight(self.imageLabel.frame) / 2;
    
    CGFloat fontSize = [ABUtils fontSizeForHeight:CGRectGetHeight(self.frame) / 3 fontName:@"STXingkai"];
    self.imageLabel.font = [UIFont fontWithName:@"STXingkai" size:fontSize];
    
    rect.origin.x = 5;
    rect.origin.y = CGRectGetMaxY(self.imageLabel.frame) + 1;
    rect.size.width = CGRectGetWidth(self.contentView.frame) - rect.origin.x * 2;
    rect.size.height = CGRectGetHeight(self.contentView.frame) - rect.origin.y;
    self.titleLabel.frame = rect;
    self.titleLabel.font = [UIFont systemFontOfSize:[ABUtils fontSizeForSystemFontHeight:CGRectGetHeight(self.titleLabel.frame)] * 2 / 3];
}

- (void)reloadWithModel:(ABCategoryModel *)model
{
    self.imageLabel.backgroundColor = [UIColor colorWithHexString:model.colorHexString];
    self.imageLabel.text = model.name;
    self.titleLabel.text = model.name;
}

@end
