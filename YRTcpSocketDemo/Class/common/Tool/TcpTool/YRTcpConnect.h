//
//  YRTcpConnect.h
//  YRTcpSocketDemo
//
//  Created by yangrui on 2018/4/27.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YRTcpTool;
@class YRTcpRequest;



typedef void(^ConnectCallBack)(BOOL isSuccess) ;
@interface YRTcpConnect : NSObject

//-(YRTcpTool *)tcpTool;
-(NSMutableDictionary<NSString *, YRTcpRequest *> *)requests;

-(void)sendRequest:(YRTcpRequest *)request;



+(instancetype)createCnnection2Host:(NSString *)host port:(int)port callBack:(ConnectCallBack)callBack;
+(instancetype)createCnnection2Domain:(NSString *)domain port:(int)port callBack:(ConnectCallBack)callBack;

//
//-(void)createConnect2Host:(NSString *)host  port:(int)port;
//-(void)createConnect2Domain:(NSString *)domain  port:(int)port;
//
//-(void)reConnect2Host:(NSString *)host  port:(int)port ;
//-(void)reConnect2Domain:(NSString *)domain  port:(int)port;
//
//-(BOOL)sendData:(NSData *)data;
//
//-(BOOL)isConnected;
//-(void)disconnected;
@end
