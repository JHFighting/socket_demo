//
//  AsyncSocketHandler.m
//  socket_test
//
//  Created by huan on 2018/7/5.
//  Copyright © 2018年 欢god. All rights reserved.
//

#import "AsyncSocketHandler.h"
#import "GCDAsyncSocket.h"

@interface AsyncSocketHandler() <GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *asyncSocket;
/** 是否连接成功 */
@property (nonatomic, assign) BOOL connected;

@end

@implementation AsyncSocketHandler

+ (instancetype)sharedInstance
{
    static AsyncSocketHandler *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AsyncSocketHandler alloc] init];
    });
    return sharedInstance;
}

- (void)asyncSocket_connectToHost
{
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    // 创建socket并指定代理对象
    _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    NSString *host = @"127.0.0.1";
    uint16_t port = 5001;
    NSError *error = nil;
    if (![_asyncSocket connectToHost:host onPort:port error:&error]) {
        NSLog(@"Error connecting: %@", error);
    }
}

- (void)asyncSocket_sendMessage:(NSString *)message
{
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    [self.asyncSocket writeData:data withTimeout:-1 tag:0];
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"连接主机成功，主机: %@，对应端口: %d", host, port);
    self.connected = YES;
    
    // 读取服务器数据
    [self.asyncSocket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *text = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    self.receiveInfoBlock(text);
    
    // 读取到服务端数据值后,能再次读取
    [self.asyncSocket readDataWithTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err
{
    NSLog(@"断开连接");
    self.connected = NO;
    self.asyncSocket.delegate = nil;
    self.asyncSocket = nil;
}

@end
