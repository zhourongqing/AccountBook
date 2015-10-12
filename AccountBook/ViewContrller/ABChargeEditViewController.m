//
//  ABChargeEditViewController.m
//  AccountBook
//
//  Created by zhourongqing on 15/9/30.
//  Copyright (c) 2015年 mtry. All rights reserved.
//

#import "ABChargeEditViewController.h"
#import "ABTextViewController.h"
#import "ABDatePicker.h"
#import "ABChargeEditCell.h"
#import "ABChargeEditDataManager.h"


@interface ABChargeEditViewController ()<UITableViewDelegate, UITableViewDataSource, ABDatePickerDeleage, ABTextViewControllerDelegate, ABDataManagerTableCallBackDelegate>

@property (nonatomic, readonly) ABTableView *tableView;

@property (nonatomic, readonly) ABDatePicker *datePicker;

@property (nonatomic, readonly) ABChargeEditDataManager *editDataManager;

@end

@implementation ABChargeEditViewController
{
    ///当前选择的indexPath
    NSIndexPath *_currentSelectedIndexPath;
    
    ///是否是编辑模式
    BOOL _isEdit;
}

@synthesize tableView = _tableView;
@synthesize datePicker = _datePicker;
@synthesize editDataManager = _editDataManager;

- (ABTableView *)tableView
{
    if(!_tableView)
    {
        _tableView = [[ABTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.sectionHeaderHeight = 10;
        _tableView.sectionFooterHeight = 0;
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 10)];
    }
    return _tableView;
}

- (ABDatePicker *)datePicker
{
    if(!_datePicker)
    {
        _datePicker = [[ABDatePicker alloc] init];
        _datePicker.delegate = self;
    }
    return _datePicker;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _editDataManager = [[ABChargeEditDataManager alloc] initWithChargeDataManger:self.chargeDataManager
                                                                           index:self.editIndex];
    [_editDataManager.callBackUtils addDelegate:self];
    
    if(self.editDataManager.isModify)
    {
        _isEdit = NO;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(touchRightBarButtonItem:)];
    }
    else
    {
        _isEdit = YES;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭"
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(touchLeftBarButtonItem:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(touchRightBarButtonItem:)];
    }
    
    [self.view addSubview:self.tableView];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.editDataManager.numberSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.editDataManager numberOfRowAtSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ABChargeEditModel *model = [self.editDataManager dataAtIndexPath:indexPath];
    if(model)
    {
        return [ABChargeEditCell heightWithModel:model width:CGRectGetWidth(self.tableView.frame)];
    }
    return ABChargeEditCellDefaultHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ABChargeEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if(!cell)
    {
        cell = [[ABChargeEditCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"reuseIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    ABChargeEditModel *model = [self.editDataManager dataAtIndexPath:indexPath];
    if(model)
    {
        [cell reloadWithModel:model isEdit:_isEdit];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_isEdit)
    {
        return;
    }
    
    _currentSelectedIndexPath = indexPath;
    
    ABChargeEditModel *model = [self.editDataManager dataAtIndexPath:indexPath];
    if(model)
    {
        if([model.title isEqualToString:ABChargeEditStartDate] ||
           [model.title isEqualToString:ABChargeEditEndDate])
        {
            [self.datePicker show];
        }
        else
        {
            ABTextViewController *controller = [[ABTextViewController alloc] init];
            controller.title = model.title;
            controller.delegate = self;
            
            if([model.title isEqualToString:ABChargeEditAmount])
            {
                controller.textView.keyboardType = UIKeyboardTypeDecimalPad;
                controller.textView.text = model.desc;
            }
            else
            {
                controller.textView.keyboardType = UIKeyboardTypeDefault;
                controller.textView.text = model.desc;
            }
            
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

#pragma mark - ABDatePickerDeleage

- (void)datePicker:(ABDatePicker *)picker didConfirmDate:(NSDate *)date
{
    ABChargeEditModel *model = [self.editDataManager dataAtIndexPath:_currentSelectedIndexPath];
    if(model)
    {
        if([model.title isEqualToString:ABChargeEditStartDate] ||
           [model.title isEqualToString:ABChargeEditEndDate])
        {
            model.date = date;
        }
        
        [self.tableView reloadRowsAtIndexPaths:@[_currentSelectedIndexPath, ] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - ABTextViewControllerDelegate

- (void)textViewController:(ABTextViewController *)controller didFinishedText:(NSString *)text
{
    ABChargeEditModel *model = [self.editDataManager dataAtIndexPath:_currentSelectedIndexPath];
    if(model)
    {
        if([model.title isEqualToString:ABChargeEditAmount] ||
           [model.title isEqualToString:ABChargeEditTitle] ||
           [model.title isEqualToString:ABChargeEditNotes])
        {
            model.desc = text;
        }
        
        [self.tableView reloadRowsAtIndexPaths:@[_currentSelectedIndexPath, ] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - 点击事件

- (void)touchLeftBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    if(!self.editDataManager.isModify)
    {
        ABAlertView *alertView = [[ABAlertView alloc] initWithTitle:@"您还没有保存哦"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
        [alertView showUsingClickButtonBlock:^(UIAlertView *alertView, NSUInteger atIndex) {
           
            if(atIndex != alertView.cancelButtonIndex)
            {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}

- (void)touchRightBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    if(self.editDataManager.isModify)
    {
        if(_isEdit)
        {
            if([self.editDataManager finishEdited])
            {
                self.navigationItem.rightBarButtonItem.title = @"编辑";
                
            }
            else
            {
                return;
            }
        }
        else
        {
            self.navigationItem.rightBarButtonItem.title = @"完成";
        }
        
        _isEdit = !_isEdit;
        
        [self.tableView reloadData];
    }
    else
    {
        if([self.editDataManager finishEdited])
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark - 数据处理

- (void)dataManager:(ABDataManager *)manager errorMessge:(NSString *)message
{
    [SVProgressHUD showInfoWithStatus:message];
}

@end
