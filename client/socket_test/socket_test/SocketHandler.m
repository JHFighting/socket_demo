//
//  SocketHandler.m
//  socket_test
//
//  Created by huan on 2018/7/5.
//  Copyright © 2018年 欢god. All rights reserved.
//

#import "SocketHandler.h"

@interface SocketHandler() <NSStreamDelegate>

@end

@implementation SocketHandler

+ (instancetype)sharedInstance
{
    static SocketHandler *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SocketHandler alloc] init];
    });
    return sharedInstance;
}

- (void)socket_connectToHost
{
    NSString *host = @"127.0.0.1";
    int port = 5001;
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)(host), port, &readStream, &writeStream);
    
    // 把C语言的输入输出流转化成OC对象
    _inputStream = (__bridge NSInputStream *)(readStream);
    _outputStream = (__bridge NSOutputStream *)(writeStream);
    
    _inputStream.delegate = self;
    _outputStream.delegate = self;
    
    // 把输入输入流添加到主运行循环
    [_inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    // 打开输入输出流
    [_inputStream open];
    [_outputStream open];
}

- (void)socket_sendMessage:(NSString *)message
{
    NSData *data =[message dataUsingEncoding:NSUTF8StringEncoding];
    [_outputStream write:data.bytes maxLength:data.length];
}

- (NSString *)readData
{
    uint8_t buf[1024];
    NSInteger len = [_inputStream read:buf maxLength:sizeof(buf)];
    NSData *data =[NSData dataWithBytes:buf length:len];
    NSString *recStr =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return recStr;
}

#pragma mark - NSStreamDelegate
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            NSLog(@"输入输出流打开完成");
            break;
        case NSStreamEventHasBytesAvailable: {
            NSLog(@"有字节可读");
            NSString *tempStr = [self readData];
            self.receiveInfoBlock(tempStr);
            break;
        }
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"可以发送字节");
            break;
        case NSStreamEventErrorOccurred:
            NSLog(@"连接出现错误");
            break;
        case NSStreamEventEndEncountered:
            NSLog(@"连接结束");
            //关闭输入输出流
            [_inputStream close];
            [_outputStream close];
            
            //从主运行循环移除
            [_inputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [_outputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        default:
            break;
    }
}

@end
