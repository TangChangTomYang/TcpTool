//
//  YRTcpRequest.m
//  YRTcpSocketDemo
//
//  Created by yangrui on 2018/4/26.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "YRTcpRequest.h"

@interface YRTcpRequest(){
    NSTimeInterval _timeOut_t;
    YRTcpRequestQualityType _quality_t;
    NSData *_data_t;
    NSDate *_reqDate_t;
    YRTcpRequestCallBack _callBack_t;
}

@end


@implementation YRTcpRequest

#pragma mark- get
-(NSData *)data{
    return _data_t;
}

-(NSDate *)reqDate{
    return _reqDate_t;
}

-(NSTimeInterval)timeOut{
    
    if (_timeOut_t == 0) {
        return 10;
    }
    else if (_timeOut_t > 0) {
       return _timeOut_t;
    }
    return -1;
}

-(YRTcpRequestQualityType)quality{

    return _quality_t;
}

-(YRTcpRequestCallBack)callBack{
    
    return _callBack_t;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _reqDate_t = [NSDate date];
    }
    return self;
}

/** timeOut < 0 永不超时,timeOut = 0 使用默认超时 1秒,timeOut > 0 使用当前超时*/
-(instancetype)initWithTimeOut:(NSTimeInterval)timeOut
                          quality:(YRTcpRequestQualityType)quality
                             data:(NSData *)data
                         callBack:(YRTcpRequestCallBack)callBack {
    
    YRTcpRequest *req = [[YRTcpRequest alloc] init];
    _timeOut_t = timeOut;
    _quality_t = quality;
    _data_t = data;
    _reqDate_t = [NSDate date];
    _callBack_t = callBack;
    
    return req;
}

/** timeOut < 0 永不超时,timeOut = 0 使用默认超时 1秒,timeOut > 0 使用当前超时*/
+(instancetype)requestWithTimeOut:(NSTimeInterval)timeOut
                          quality:(YRTcpRequestQualityType)quality
                             data:(NSData *)data
                         callBack:(YRTcpRequestCallBack)callBack{
    
    return  [[self alloc] initWithTimeOut:timeOut quality:quality data:data callBack:callBack];
}

@end
