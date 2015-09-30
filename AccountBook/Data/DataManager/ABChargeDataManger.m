//
//  ABChargeDataManger.m
//  AccountBook
//
//  Created by zhourongqing on 15/9/20.
//  Copyright (c) 2015年 mtry. All rights reserved.
//

#import "ABChargeDataManger.h"

@interface ABChargeDataManger ()

@property (nonatomic, strong) NSMutableArray *listItem;

@end

@implementation ABChargeDataManger

- (NSMutableArray *)listItem
{
    if(!_listItem)
    {
        _listItem = [NSMutableArray array];
    }
    return _listItem;
}

///请求列表数据
- (void)requestChargeDataWithID:(NSString *)chargeID
{
    ABChargeModel *model;
    for(NSInteger i = 0; i < 20; i++)
    {
        model = [[ABChargeModel alloc] init];
        model.title = @"周杰伦";
        model.money = 55555.5555;
        model.startTimeInterval = 1440770901.491756;
        model.endTimeInterval = 1442470901.491756 + i * 100000;
        model.remark = @"抖动阿萨德发到空间发大发啊速度啊速度加夫里什的肌肤的肌肤";
        [self.listItem addObject:model];
    }
    
    [self.callBackUtils callBackAction:@selector(dataManagerReloadData:) object1:self];
}

///请求添加
- (void)requestAddModel:(ABChargeModel *)model
{
    if([model isKindOfClass:[ABChargeModel class]])
    {
        [self.listItem addObject:model];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.numberOfItem inSection:0];
        [self.callBackUtils callBackAction:@selector(dataManager:addIndexPath:) object1:self object2:indexPath];
    }
}

///请求删除
- (void)requestRemoveIndex:(NSInteger)index
{
    if(index < self.numberOfItem)
    {
        [self.listItem removeObjectAtIndex:index];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.callBackUtils callBackAction:@selector(dataManager:removeIndexPath:) object1:self object2:indexPath];
    }
}

- (NSInteger)numberOfItem
{
    return self.listItem.count;
}

- (ABChargeModel *)modelAtIndex:(NSInteger)index
{
    if(index < self.numberOfItem)
    {
        return self.listItem[index];
    }
    return nil;
}

@end
