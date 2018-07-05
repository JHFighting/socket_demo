//
//  DataModel.h
//  socket_test
//
//  Created by huan on 2018/7/5.
//  Copyright © 2018年 欢god. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataModel : NSObject

@property (nonatomic, copy) NSString *content;
/** YES: 自己， NO: 他人 */
@property (nonatomic, assign) BOOL tag;

@end
