//
//  ViewController.m
//  socket_test
//
//  Created by huan on 2018/7/5.
//  Copyright © 2018年 欢god. All rights reserved.
//

#import "ViewController.h"
#import "DataModel.h"
#import "SocketHandler.h"
#import "AsyncSocketHandler.h"

/** 0: 原生接口，1: AsyncSocket */
#define Base_Socket 1

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *sendBtn;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 30, 200, 30)];
    self.textField.borderStyle = UITextBorderStyleLine;
    [self.view addSubview:self.textField];
    self.sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(225, 30, 50, 30)];
    self.sendBtn.backgroundColor = [UIColor lightGrayColor];
    [self.sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [self.sendBtn addTarget:self action:@selector(sendData) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sendBtn];
    
    self.dataArray = [NSMutableArray array];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 65, self.view.bounds.size.width, self.view.bounds.size.height - 65)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self connectServer];
}

- (void)connectServer
{
    if (Base_Socket) {
        [[AsyncSocketHandler sharedInstance] asyncSocket_connectToHost];
        [[AsyncSocketHandler sharedInstance] asyncSocket_receiveMessage:^(NSString *message) {
            [self readData:message];
        }];
        
    } else {
        [[SocketHandler sharedInstance] socket_connectToHost];
        [[SocketHandler sharedInstance] socket_receiveMessage:^(NSString *message) {
            [self readData:message];
        }];
    }
}

#pragma mark - 发送数据
- (void)sendData
{
    NSString *sendStr = self.textField.text;
    if (sendStr.length == 0) {
        return;
    }
    DataModel *model = [[DataModel alloc] init];
    model.tag = YES;
    model.content = sendStr;
    [self reloadDataWithModel:model];
    
    if (Base_Socket) {
        [[AsyncSocketHandler sharedInstance] asyncSocket_sendMessage:sendStr];
    } else {
        [[SocketHandler sharedInstance] socket_sendMessage:sendStr];
    }
    self.textField.text = nil;
}

#pragma mark - 读取服务器返回数据
- (void)readData:(NSString *)recStr
{
    DataModel *model = [[DataModel alloc] init];
    model.tag = NO;
    model.content = recStr;
    [self reloadDataWithModel:model];
}

- (void)reloadDataWithModel:(DataModel *)model
{
    [self.dataArray addObject:model];
    [self.tableView reloadData];
    
    NSIndexPath *lastPath = [NSIndexPath indexPathForRow:self.dataArray.count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    DataModel *model = self.dataArray[indexPath.row];
    NSString *content;
    UIColor *color;
    
    if (model.tag) {
        content = [NSString stringWithFormat:@"我: %@", model.content];
        color = [UIColor blueColor];
    } else {
        content = [NSString stringWithFormat:@"电脑: %@", model.content];
        color = [UIColor redColor];
    }
    cell.textLabel.text = content;
    cell.textLabel.textColor = color;
    
    return cell;
}

@end
