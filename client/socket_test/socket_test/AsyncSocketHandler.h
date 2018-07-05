//
//  AsyncSocketHandler.h
//  socket_test
//
//  Created by huan on 2018/7/5.
//  Copyright © 2018年 欢god. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AsyncSocketHandler : NSObject

@property (nonatomic, copy) void(^receiveInfoBlock)(NSString *message);

+ (instancetype)sharedInstance;

/** 连接服务器 */
- (void)asyncSocket_connectToHost;

/** 发送数据 */
- (void)asyncSocket_sendMessage:(NSString *)message;

@end
