//
//  ABChargeEditDataManager.m
//  AccountBook
//
//  Created by zhourongqing on 15/10/11.
//  Copyright © 2015年 mtry. All rights reserved.
//

#import "ABChargeEditDataManager.h"

NSString *const ABChargeEditStartDate = @"开始日期";
NSString *const ABChargeEditEndDate = @"结束日期";
NSString *const ABChargeEditTitle = @"名称";
NSString *const ABChargeEditAmount = @"额度";
NSString *const ABChargeEditNotes = @"备注";

@interface ABChargeEditDataManager ()

@property (nonatomic, strong) NSMutableArray *listItem;

@property (nonatomic, readonly) ABChargeDataManger *chargeDataManager;

@property (nonatomic, readonly) NSInteger editIndex;

@end

@implementation ABChargeEditDataManager

@synthesize isModify = _isModify;

- (NSMutableArray *)listItem
{
    if(!_listItem)
    {
        _listItem = [NSMutableArray array];
    }
    return _listItem;
}

- (instancetype)initWithChargeDataManger:(ABChargeDataManger *)chargeDataManager index:(NSInteger)index
{
    self = [super init];
    if(self)
    {
        _isModify = index >= 0 ? YES : NO;
        
        _editIndex = index;
        _chargeDataManager = chargeDataManager;
        
        ABChargeModel *chargeModel;
        if(index >= 0)
        {
            chargeModel = [chargeDataManager dataAtIndex:index];
        }
        [self initDataWithChargeModel:chargeModel];
    }
    return self;
}

- (void)initDataWithChargeModel:(ABChargeModel *)chargeModel
{
    [self.listItem removeAllObjects];
    
    NSArray *titleArray = @[@[ABChargeEditStartDate, ABChargeEditEndDate],
                            @[ABChargeEditTitle],
                            @[ABChargeEditAmount],
                            @[ABChargeEditNotes]];
    for(NSArray *array in titleArray)
    {
        NSMutableArray *dataArray = [NSMutableArray array];
        for(NSString *title in array)
        {
            ABChargeEditModel *editModel = [[ABChargeEditModel alloc] init];
            editModel.title = title;
            if([title isEqualToString:ABChargeEditStartDate])
            {
                editModel.date = chargeModel ? [NSDate dateWithTimeIntervalSince1970:chargeModel.startTimeInterval] : [NSDate date];
            }
            else if([title isEqualToString:ABChargeEditEndDate])
            {
                editModel.date = chargeModel ? [NSDate dateWithTimeIntervalSince1970:chargeModel.endTimeInterval] : [NSDate date];
            }
            else if([title isEqualToString:ABChargeEditTitle])
            {
                editModel.desc = chargeModel ? chargeModel.title : @"";
            }
            else if([title isEqualToString:ABChargeEditAmount])
            {
                editModel.desc = chargeModel ? [NSString stringWithFormat:@"%.2lf", chargeModel.amount] : @"";
            }
            else if([title isEqualToString:ABChargeEditNotes])
            {
                editModel.desc = chargeModel ? chargeModel.notes : @"";
            }
            
            [dataArray addObject:editModel];
        }
        
        [self.listItem addObject:dataArray];
    }
}

- (NSInteger)numberSection
{
    return self.listItem.count;
}

- (NSInteger)numberOfRowAtSection:(NSInteger)section
{
    if(section < self.listItem.count)
    {
        NSArray *array = self.listItem[section];
        if([array isKindOfClass:[NSArray class]])
        {
            return array.count;
        }
    }
    return 0;
}

- (ABChargeEditModel *)dataAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section < self.listItem.count)
    {
        NSArray *array = self.listItem[indexPath.section];
        if([array isKindOfClass:[NSArray class]] && indexPath.row < array.count)
        {
            return array[indexPath.row];
        }
    }
    return nil;
}

- (ABChargeEditModel *)dataForTitle:(NSString *)title
{
    for(NSArray *array in self.listItem)
    {
        for(ABChargeEditModel *model in array)
        {
            if([model.title isEqualToString:title])
            {
                return model;
            }
        }
    }
    return nil;
}

- (BOOL)finishEdited
{
    ABChargeEditModel *model = [self dataForTitle:ABChargeEditTitle];
    if(model.desc.length == 0)
    {
        NSString *message = [NSString stringWithFormat:@"请输入%@", ABChargeEditTitle];
        [self.callBackUtils callBackAction:@selector(dataManager:errorMessge:) object1:self object2:message];
        return NO;
    }
    
    model = [self dataForTitle:ABChargeEditAmount];
    if(model.desc.length == 0)
    {
        NSString *message = [NSString stringWithFormat:@"请输入%@", ABChargeEditAmount];
        [self.callBackUtils callBackAction:@selector(dataManager:errorMessge:) object1:self object2:message];
        return NO;
    }
    
    return YES;
}

@end
