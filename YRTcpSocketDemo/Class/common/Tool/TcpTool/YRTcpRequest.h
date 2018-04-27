//
//  YRTcpRequest.h
//  YRTcpSocketDemo
//
//  Created by yangrui on 2018/4/26.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YRTcpResponse.h"
typedef void(^YRTcpRequestCallBack)(YRTcpResponse *response, BOOL isTimeOut);

@interface YRTcpRequest : NSObject
/** 创建请求的时间 */
@property(nonatomic, strong,readonly)NSDate *reqDate;

@property(nonatomic, strong,readonly)NSData *data;
@property(nonatomic, assign,readonly)NSTimeInterval timeOut;
@property(nonatomic, assign,readonly)YRTcpRequestQualityType quality;
@property(nonatomic, copy,readonly)YRTcpRequestCallBack callBack;

@property(nonatomic, assign)int failTimes; // 请求失败的次数

/** timeOut < 0 永不超时,timeOut = 0 使用默认超时 1秒,timeOut > 0 使用当前超时*/
+(instancetype)requestWithTimeOut:(NSTimeInterval)timeOut
                          quality:(YRTcpRequestQualityType)quality
                             data:(NSData *)data
                         callBack:(YRTcpRequestCallBack)callBack;

@end
