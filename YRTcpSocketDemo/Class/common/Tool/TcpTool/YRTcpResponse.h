//
//  YRTcpResponse.h
//  YRTcpSocketDemo
//
//  Created by yangrui on 2018/4/26.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface YRTcpResponse : NSObject

@property(nonatomic, strong,readonly)NSData *data;

+(instancetype)responeWithData:(NSData *)data;
@end
