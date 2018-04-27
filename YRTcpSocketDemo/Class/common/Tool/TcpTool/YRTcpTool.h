//
//  YRTcpTool.h
//  YRTcpSocketDemo
//
//  Created by yangrui on 2018/4/26.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YRTcpTool;
@protocol YRTcpToolDelegate <NSObject>

// 连接失败
- (void)tcpTool:(YRTcpTool *)tcpTool connectFailToDomain:(NSString *)domain port:(UInt16)port info:(NSString *)info;
- (void)tcpTool:(YRTcpTool *)tcpTool connectFailToHost:(NSString *)host port:(UInt16)port info:(NSString *)info;

// 连接成功
- (void)tcpTool:(YRTcpTool *)tcpTool didConnectToHost:(NSString *)host port:(UInt16)port;
- (void)tcpTool:(YRTcpTool *)tcpTool didConnectToDomain:(NSString *)domain port:(UInt16)port;


// 连接中断
- (void)tcpTool:(YRTcpTool *)tcpTool didDisconnectHost:(NSString *)host port:(UInt16)port error:(NSError *)err;
- (void)tcpTool:(YRTcpTool *)tcpTool didDisconnectDomain:(NSString *)domain port:(UInt16)port error:(NSError *)err;


// 连接中断
- (void)tcpTool:(YRTcpTool *)tcpTool reconnectFailToDomain:(NSString *)host port:(UInt16)port info:(NSString *)info;;
- (void)tcpTool:(YRTcpTool *)tcpTool reconnectFailToHost:(NSString *)domain port:(UInt16)port info:(NSString *)info;;


// 成功接收到数据
- (void)tcpTool:(YRTcpTool *)tcpTool didReceiveData:(NSData *)data;

@end


@class GCDAsyncSocket;


@interface YRTcpTool : NSObject

/** 这个参数是重连接的次数 */
@property(nonatomic, assign,readonly)int  reconnectCount;
@property(nonatomic, copy)NSString *name;
@property(nonatomic, weak)id<YRTcpToolDelegate> delegate;



@property(nonatomic, strong,readonly)GCDAsyncSocket *socket;
@property(nonatomic, copy,readonly)NSString *domian;
@property(nonatomic, copy,readonly)NSString *host;
@property(nonatomic, assign,readonly)int port;
/** 被动断开== YES*/
@property(nonatomic, assign,readonly)BOOL isManualDisconnect;


+(instancetype)createConnect2Host:(NSString *)host  port:(int)port delegate:(id<YRTcpToolDelegate>)delegate;
+(instancetype)createConnect2Domain:(NSString *)domain  port:(int)port delegate:(id<YRTcpToolDelegate>)delegate;;

-(void)reconnect;
//-(void)reConnect2Host:(NSString *)host  port:(int)port ;
//-(void)reConnect2Domain:(NSString *)domain  port:(int)port;

-(BOOL)sendData:(NSData *)data;

-(BOOL)isConnected;
-(void)disconnected;



@end
