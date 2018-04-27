//
//  YRTcpTool.m
//  YRTcpSocketDemo
//
//  Created by yangrui on 2018/4/26.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "YRTcpTool.h"
#import "GCDAsyncSocket.h"
#import "YRDomainTool.h"

@interface YRTcpTool ()<GCDAsyncSocketDelegate>{
    
    NSString *_domain;
    NSString *_host;
    int _port;
    int _reconnectCount;
    BOOL _manualDisconnect;
    
}

@property(nonatomic, strong)GCDAsyncSocket *tcpSocket;
@end

static int _tcpToolIndex =  0;
@implementation YRTcpTool

#pragma mark- 内部方法
-(GCDAsyncSocket *)tcpSocket{
    if (!_tcpSocket) {
        _tcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _tcpSocket;
}

-(void)cleanProperty{
    _domain = nil;
    _host = nil;
    _port = 0;
    _reconnectCount = 0;
    _manualDisconnect = NO;
    _name = nil;
}

-(void)connectToDomain:(NSString *)domain  port:(int)port{
    _domain = domain;
    __weak typeof(self) weakSelf = self;
    [[YRDomainTool  shareInstance] parseName:domain callBack:^(NSArray<NSString *> *arr, NSError *err) {
        if (err == nil && arr.count > 0) {
            NSString *host = arr.firstObject;
            [weakSelf connectToHost:host port:port];
        }
        else{
            // 连接失败
            if ([weakSelf.delegate respondsToSelector:@selector(tcpTool:connectFailToDomain:port:info:)]) {
                [weakSelf.delegate tcpTool:self connectFailToDomain:domain port:port info:[NSString stringWithFormat:@"%@,域名解析失败",domain]];
            }
        }
        
    }];
    
}

-(void)connectToHost:(NSString *)host  port:(int)port{
    
    _host = host;
    _port = port;
    
    self.tcpSocket = nil;
    _reconnectCount += 1;
    
    NSError *err = nil;
    [self.tcpSocket  connectToHost:host onPort:port error:&err];
    
    if (err != nil) {
        // 连接失败
        if ([self.delegate respondsToSelector:@selector(tcpTool:connectFailToHost:port:info:)]) {
            [self.delegate tcpTool:self connectFailToHost:host port:port info:err.localizedDescription];
        }
    }
}

#pragma mark- 外部方法
#pragma mark- get
-(GCDAsyncSocket *)socket{
    return _tcpSocket;
}

-(NSString *)domian{
    return _domain;
}

-(NSString *)host{
    return _host;
}

-(int)port{
    return _port;
}

-(BOOL)isManualDisconnect{
    return _manualDisconnect;
}

-(NSString *)name{
    if (_name.length == 0) {
        _name = @(_tcpToolIndex).stringValue;
    }
    return _name;
}

+(instancetype)createConnect2Host:(NSString *)host  port:(int)port delegate:(id<YRTcpToolDelegate>)delegate{
    
    YRTcpTool *tcpTool = [[self alloc] init];
    [tcpTool cleanProperty];
    tcpTool.delegate = delegate;
    
    [tcpTool connectToHost:host port:port];
    return tcpTool;
}

+(instancetype)createConnect2Domain:(NSString *)domain  port:(int)port delegate:(id<YRTcpToolDelegate>)delegate{
    YRTcpTool *tcpTool = [[self alloc] init];
    [tcpTool cleanProperty];
    tcpTool.delegate = delegate;
    
    [tcpTool connectToDomain:domain port:port];
    return tcpTool;
}


-(void)reconnect{
    if (_host.length > 0) {
        [self connectToHost:_host port:_port];
    }
    else{
        NSLog(@"重连时 没有检测到 host ");
    }
}

-(BOOL)sendData:(NSData *)data{
    @synchronized(self){
        if ([self.tcpSocket isConnected] && _tcpSocket != nil) {
            [self.tcpSocket writeData:data withTimeout:-1 tag:0];
            return YES;
        }
        return NO;
    }
}

-(void)disconnected{
    _manualDisconnect = YES;
    [self.tcpSocket disconnect];
    self.tcpSocket = nil;
    
}

-(BOOL)isConnected{
    if(_tcpSocket == nil){
        return NO;
    }
   return  [_tcpSocket isConnected];
}


#pragma mark- GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    _reconnectCount = 1;
    
    if(_domain.length > 0){
        if([self.delegate respondsToSelector:@selector(tcpTool: didConnectToDomain: port:)]){
            [self.delegate tcpTool:self didConnectToDomain:_domain port:_port];
        }
    }
    else{
        if([self.delegate respondsToSelector:@selector(tcpTool: didConnectToHost: port:)]){
            [self.delegate tcpTool:self didConnectToHost:host port:port];
        }
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err{
    
    if (_manualDisconnect == YES) {
        _manualDisconnect = NO;
        return;
    }
    
    if (_domain.length > 0) {
        if ([self.delegate respondsToSelector:@selector(tcpTool:didDisconnectHost: port:error:)]) {
            [self.delegate tcpTool:self didDisconnectDomain:_domain port:_port error:err];
        }
    }
    else{
        if ([self.delegate respondsToSelector:@selector(tcpTool:didDisconnectHost: port:error:)]) {
            [self.delegate tcpTool:self didDisconnectHost:self.host port:self.port error:err];
        }
        
    }
    
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    [sock readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    @synchronized(self){
        if ([self.delegate respondsToSelector:@selector(tcpTool:didReceiveData:)]) {
            [self.delegate tcpTool:self didReceiveData:data];
        }
    }
}




@end
