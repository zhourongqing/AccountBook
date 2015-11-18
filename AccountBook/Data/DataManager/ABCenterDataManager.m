//
//  ABCenterDataManager.m
//  AccountBook
//
//  Created by zhourongqing on 15/10/15.
//  Copyright © 2015年 mtry. All rights reserved.
//

#import "ABCenterDataManager.h"
#import "ABCenterCoreDataManager.h"
#import "ABCoreDataHelper.h"

@interface ABCenterDataManager ()

@property (nonatomic, readonly) ABCenterCoreDataManager *centerCoreDataManager;

@end

@implementation ABCenterDataManager
{
    BOOL _isFinishedUploadCategoryData;
    BOOL _isFinishedUploadChargeData;
    NSInteger _uploadErrorCount;
}

@synthesize centerCoreDataManager = _centerCoreDataManager;

+ (ABCenterDataManager *)share
{
    static id shareObject;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
       
        shareObject = [[[self class] alloc] init];
    });
    return shareObject;
}

- (ABCenterCoreDataManager *)centerCoreDataManager
{
    if(!_centerCoreDataManager)
    {
        _centerCoreDataManager = [[ABCenterCoreDataManager alloc] init];
    }
    return _centerCoreDataManager;
}

///请求分类列表数据
- (void)requestCategoryListData
{
    NSArray *array = [self.centerCoreDataManager selectCategoryListData:NO];
    [self.callBackUtils callBackAction:@selector(centerDataManager:successRequestCategoryListData:) object1:self object2:array];
}

///请求增加分类
- (void)requestCategoryAddModel:(ABCategoryModel *)model
{
    model.isRemoved = NO;
    model.isExistCloud = NO;
    model.createTime = [[NSDate date] timeIntervalSince1970];
    model.modifyTime = [[NSDate date] timeIntervalSince1970];
    
    [self.centerCoreDataManager insertCategoryModel:model];
}

///请求删除分类
- (void)requestCategoryRemoveCategoryId:(NSString *)categoryId
{
    [self.centerCoreDataManager deleteCategoryCategoryID:categoryId];
}

///请求修改分类
- (void)requestCategoryUpdateModel:(ABCategoryModel *)model
{
    model.modifyTime = [[NSDate date] timeIntervalSince1970];
    
    [self.centerCoreDataManager updateCategoryModel:model];
}

///请求消费列表
- (void)requestChargeListDateWithCategoryId:(NSString *)categoryId
{
    NSArray *array = [self.centerCoreDataManager selectChargeListDateWithCategoryID:categoryId];
    if(array)
    {
        [self.callBackUtils callBackAction:@selector(centerDataManager:successRequestChargeListData:) object1:self object2:array];
    }
}

///请求增加消费记录
- (void)requestChargeAddModel:(ABChargeModel *)model
{
    model.isRemoved = NO;
    model.isExistCloud = NO;
    model.modifyTime = [[NSDate date] timeIntervalSince1970];
    
    [self.centerCoreDataManager insertChargeModel:model];
}

///请求删除消费记录
- (void)requestChargeRemoveChargeId:(NSString *)chargeId
{
    [self.centerCoreDataManager deleteChargeChargeID:chargeId];
}

///请求修改消费记录
- (void)requestChargeUpdateModel:(ABChargeModel *)model
{
    model.modifyTime = [[NSDate date] timeIntervalSince1970];
    
    [self.centerCoreDataManager updateChargeModel:model];
}


#pragma mark - iCloud

///同步iCould数据
- (void)mergeCouldDataFinishedHandler:(void(^)(void))finishedHandler
                         errorHandler:(void(^)(CKAccountStatus accountStatus, NSError *error))errorHandler
{
    [ABCloudKit requestIsOpenCloudCompletionHandler:^(CKAccountStatus accountStatus, NSError *error) {
        
        if(accountStatus == CKAccountStatusNoAccount)
        {
            if(errorHandler)
            {
                errorHandler(accountStatus, error);
            }
        }
        else if(accountStatus == CKAccountStatusAvailable)
        {
            _uploadErrorCount = 0;
            
            __block BOOL isCategoryFinished = NO;
            __block BOOL isChargeFinidshed = NO;
            
            [self mergeCategoryDataCompletionHandler:^(NSArray<ABCategoryModel *> *mergeData, NSError *error) {
                
                if(!error)
                {
                    for(ABCategoryModel *model in mergeData)
                    {
                        model.isExistCloud = YES;
                        [self.centerCoreDataManager updateCategoryModel:model];
                    }
                    [self requestCategoryListData];
                    
                    isCategoryFinished = YES;
                    if(isChargeFinidshed)
                    {
                        if(finishedHandler)
                        {
                            finishedHandler();
                        }
                    }
                    
                    [self requestUploadCategoryData:mergeData];
                }
                else
                {
                    if(errorHandler)
                    {
                        errorHandler(accountStatus, error);
                    }
                }
            }];
            
            [self mergeChargeDataCompletionHandler:^(NSArray<ABChargeModel *> *mergeData, NSError *error) {
                
                if(!error)
                {
                    for(ABChargeModel *model in mergeData)
                    {
                        model.isExistCloud = YES;
                        [self.centerCoreDataManager updateChargeModel:model];
                    }
                    
                    isChargeFinidshed = YES;
                    if(isCategoryFinished && finishedHandler)
                    {
                        finishedHandler();
                    }
                    
                    [self requestUploadChargeData:mergeData];
                }
                else
                {
                    if(errorHandler)
                    {
                        errorHandler(accountStatus, error);
                    }
                }
            }];
        }
        else
        {
            if(errorHandler)
            {
                errorHandler(accountStatus, error);
            }
        }
    }];
}

///合并分类数据
- (void)mergeCategoryDataCompletionHandler:(void(^)(NSArray<ABCategoryModel *> *mergeData, NSError *error))completionHandler
{
    [ABCloudKit requestCategoryListDataCompletionHandler:^(NSArray<ABCategoryModel *> *results, NSError *error) {
        
        if(error)
        {
            completionHandler(nil, error);
        }
        else
        {
            NSMutableArray *mergeData = [NSMutableArray array];
            NSArray *localData = [self.centerCoreDataManager selectCategoryListData:YES];
            for(ABCategoryModel *cloudModel in results)
            {
                ABCategoryModel *newModel = nil;
                for(ABCategoryModel *localModel in localData)
                {
                    if([cloudModel.categoryID isEqualToString:localModel.categoryID])
                    {
                        if(cloudModel.modifyTime > localModel.modifyTime)
                        {
                            newModel = [cloudModel copy];
                        }
                        else
                        {
                            newModel = [localModel copy];
                        }
                        break;
                    }
                }
                
                if(!newModel)
                {
                    newModel = [cloudModel copy];
                }
                [mergeData addObject:newModel];
            }
            
            for(ABCategoryModel *localModel in localData)
            {
                BOOL isFinded = NO;
                for(ABCategoryModel *mergeModel in mergeData)
                {
                    if([localModel.categoryID isEqualToString:mergeModel.categoryID])
                    {
                        isFinded = YES;
                        break;
                    }
                }
                if(!isFinded)
                {
                    [mergeData addObject:[localModel copy]];
                }
            }
            completionHandler(mergeData, nil);
        }
    }];
}

///合并消费数据
- (void)mergeChargeDataCompletionHandler:(void(^)(NSArray<ABChargeModel *> *mergeData, NSError *error))completionHandler
{
    [ABCloudKit requestChargeListDataWithCompletionHandler:^(NSArray<ABChargeModel *> *results, NSError *error) {
        
        if(error)
        {
            completionHandler(nil, error);
        }
        else
        {
            NSMutableArray *mergeData = [NSMutableArray array];
            NSArray *localData = [self.centerCoreDataManager selectChargeListData];
            for(ABChargeModel *cloudModel in results)
            {
                ABChargeModel *newModel = nil;
                for(ABChargeModel *localModel in localData)
                {
                    if([cloudModel.chargeID isEqualToString:localModel.chargeID])
                    {
                        if(cloudModel.modifyTime > localModel.modifyTime)
                        {
                            newModel = [cloudModel copy];
                        }
                        else
                        {
                            newModel = [localModel copy];
                        }
                        break;
                    }
                }
                
                if(!newModel)
                {
                    newModel = [cloudModel copy];
                }
                [mergeData addObject:newModel];
            }
            
            for(ABChargeModel *localModel in localData)
            {
                BOOL isFinded = NO;
                for(ABChargeModel *mergeModel in mergeData)
                {
                    if([localModel.chargeID isEqualToString:mergeModel.chargeID])
                    {
                        isFinded = YES;
                        break;
                    }
                }
                if(!isFinded)
                {
                    [mergeData addObject:[localModel copy]];
                }
            }
            
            completionHandler(mergeData, nil);
        }
    }];
}

///请求上传分类数据
- (void)requestUploadCategoryData:(NSArray *)categoryData
{
    __block NSInteger uploadCnt = 0;
    _isFinishedUploadCategoryData = NO;
    
    for(ABCategoryModel *model in categoryData)
    {
        [ABCloudKit requestInsertCategoryData:model completionHandler:^(NSError *error) {
            
            if(error && !model.isRemoved)
            {
                _uploadErrorCount ++;
            }
            
            uploadCnt ++;
            if(uploadCnt == categoryData.count)
            {
                _isFinishedUploadCategoryData = YES;
                if(_isFinishedUploadChargeData)
                {
                    [self requestDeleteDiscardChargeData];
                    
                    if(_uploadErrorCount)
                    {
                        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"有 %ld 条数据上传Cloud失败", _uploadErrorCount]];
                    }
                }
            }
        }];
    }
}

///请求上传消费数据
- (void)requestUploadChargeData:(NSArray *)chargeData
{
    __block NSInteger uploadCnt = 0;
    _isFinishedUploadChargeData = NO;
    
    for(ABChargeModel *model in chargeData)
    {
        [ABCloudKit requestInsertChargeData:model completionHandler:^(NSError *error) {
            
            if(error && !model.isRemoved)
            {
                _uploadErrorCount ++;
            }
            
            uploadCnt ++;
            if(uploadCnt == chargeData.count)
            {
                _isFinishedUploadChargeData = YES;
                if(_isFinishedUploadCategoryData)
                {
                    [self requestDeleteDiscardChargeData];
                    
                    if(_uploadErrorCount)
                    {
                        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"有 %ld 条数据上传Cloud失败", _uploadErrorCount]];
                    }
                }
            }
        }];
    }
}

///请求删除多余数据
- (void)requestDeleteDiscardChargeData
{
    [self mergeCategoryDataCompletionHandler:^(NSArray<ABCategoryModel *> *mergeData, NSError *error) {
        
        if(mergeData)
        {
            for(ABCategoryModel *model in mergeData)
            {
                if(model.isRemoved)
                {
                    [self.centerCoreDataManager deleteChargeListDataWithCategoryID:model.categoryID];
                    
                    [ABCloudKit requestDeleteChargeListDataWithCategoryID:model.categoryID];
                }
            }
        }
    }];
}

@end
