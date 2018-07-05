//
//  SocketHandler.h
//  socket_test
//
//  Created by huan on 2018/7/5.
//  Copyright © 2018年 欢god. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocketHandler : NSObject

{
    NSInputStream *_inputStream;    //对应输入流
    NSOutputStream *_outputStream;  //对应输出流
}


+ (instancetype)sharedInstance;

/** 连接服务器 */
- (void)socket_connectToHost;

/** 发送数据 */
- (void)socket_sendMessage:(NSString *)message;

/** 接收回调数据 */
- (void)socket_receiveMessage:(void (^)(NSString *message))msg;

@end
