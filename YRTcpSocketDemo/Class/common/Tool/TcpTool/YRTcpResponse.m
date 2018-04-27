//
//  YRTcpResponse.m
//  YRTcpSocketDemo
//
//  Created by yangrui on 2018/4/26.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "YRTcpResponse.h"

@interface YRTcpResponse (){
  NSData *_data;
}

@end

@implementation YRTcpResponse

#pragma mark- get
-(NSData *)data{
    return _data;
}


- (instancetype)initWithData:(NSData *)data{
    self = [super init];
    if (self) {
        _data = data;
    }
    return self;
}

+(instancetype)responeWithData:(NSData *)data{
   return  [[self alloc] initWithData:data];
}


@end
