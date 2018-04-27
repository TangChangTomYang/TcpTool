//
//  YRTcpConnect.m
//  YRTcpSocketDemo
//
//  Created by yangrui on 2018/4/27.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "YRTcpConnect.h"
#import "YRTcpRequest.h"
#import "YRTcpTool.h"

@interface YRTcpConnect ()<YRTcpToolDelegate>

@property(nonatomic, strong)YRTcpTool *tcpTool;

#pragma mark- 发送数据
@property(nonatomic, strong)NSTimer *timer;
@property(nonatomic, strong)NSMutableDictionary<NSString *, YRTcpRequest *> *requestDicM;
@property(nonatomic, strong)NSMutableDictionary<NSString *, YRTcpRequest *> *timeOutReqDicM;

#pragma mark- 建立连接
@property(nonatomic, strong)NSTimer *connectTimer;
@property(nonatomic, copy)ConnectCallBack conCallback;

@property(nonatomic, strong)NSTimer *reconnectTimer;
@property(nonatomic, copy)ConnectCallBack reconCallback;
@end

static NSInteger _reqSequence = 0;
@implementation YRTcpConnect

#pragma mark- get

#pragma mark- get for 内部
-(NSMutableDictionary *)requestDicM{
    if (!_requestDicM) {
        _requestDicM = [NSMutableDictionary dictionary];
    }
    return _requestDicM;
}

+(NSString *)createRequestName{
    _reqSequence += 1;
   return  @(_reqSequence).stringValue;
    
}

-(void)updateConnectTimer{
    
    [self emptyConnectTimer];
    
    self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(connectTimerAction) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.connectTimer forMode:NSRunLoopCommonModes];
    
}

-(void)emptyConnectTimer{
    [self.connectTimer invalidate];
    self.connectTimer = nil;
}

-(void)connectTimerAction{
  
    [self connectResult:NO];
}

-(void)connectResult:(BOOL)result{
    [self emptyConnectTimer];
    if(self.conCallback){
        self.conCallback(result);
    }
}

-(void)updateReConnectTimer{
    
    [self emptyReConnectTimer];
    
    self.reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(reconnectTimerAction) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.reconnectTimer forMode:NSRunLoopCommonModes];
    
}

-(void)emptyReConnectTimer{
    [self.reconnectTimer invalidate];
    self.reconnectTimer = nil;
}

-(void)reconnectTimerAction{
    
    [self reconnectResult:NO];
}

-(void)reconnectResult:(BOOL)result{
    [self emptyReConnectTimer];
    if(self.reconCallback){
        self.reconCallback(result);
    }
}


#pragma mark- get for 外部

-(NSMutableDictionary<NSString *,YRTcpRequest *> *)requests{
    
    return self.requestDicM;
}

-(instancetype)init{
    
    self = [super init];
    if (self) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
    return self;
}

-(void)dealloc{
    [self.timer invalidate];
    self.timer = nil;
    
    [self emptyConnectTimer];
    [self emptyReConnectTimer];
}

-(void)timerAction{
    
    NSTimeInterval intervalSince1970 = [[NSDate date] timeIntervalSince1970];
    
    [self.requestDicM enumerateKeysAndObjectsUsingBlock:^(NSString * key, YRTcpRequest *request, BOOL *  stop) {
        NSTimeInterval reqTimeLen  = intervalSince1970 - [request.reqDate timeIntervalSince1970];
        NSTimeInterval timeOut = request.timeOut;
        
        switch (request.quality) {
            case YRTcpRequestQualityType_default:
                
                if (reqTimeLen >= timeOut ) {
                    self.timeOutReqDicM[key] = request;
                }
                
                break;
            case YRTcpRequestQualityType_hight:
                
                if(reqTimeLen >= timeOut * 2){ //记录失败的请求
                    self.timeOutReqDicM[key] = request;
                }
                else if(reqTimeLen >= timeOut && request.failTimes == 0){
                    request.failTimes += 1; // 增加一次失败次数
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        [self sendRequestData:request.data];
                    });
                }
               
                break;
            case YRTcpRequestQualityType_Highest:
                
                if(reqTimeLen >= timeOut * 3 ){ //记录失败的请求
                    self.timeOutReqDicM[key] = request;
                }
                else if(reqTimeLen >= timeOut * 2 && request.failTimes == 1){
                    request.failTimes += 1; // 增加一次失败次数, 再次重发
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        [self sendRequestData:request.data];
                    });
                }
                else if(reqTimeLen >= timeOut && request.failTimes == 0){
                    request.failTimes += 1; // 增加一次失败次数
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        [self sendRequestData:request.data];
                    });
                }
                
                break;
        }
        
        
    }];
    
    
    if(self.timeOutReqDicM.allKeys.count == 0){
        return;
    }
    
    // 移除过期的请求
    [self.requestDicM removeObjectsForKeys:self.timeOutReqDicM.allKeys];
    
    // 处理超时的请求回调
    [self.timeOutReqDicM enumerateKeysAndObjectsUsingBlock:^(NSString *key, YRTcpRequest *request, BOOL * _Nonnull stop) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
             request.callBack(nil, YES);
        });
    }];
    
    [self.timeOutReqDicM removeAllObjects];
    self.timeOutReqDicM = nil;
    
}


-(void)sendRequest:(YRTcpRequest *)request{
    NSString *reqName = [YRTcpConnect createRequestName];
    self.requestDicM[reqName] = request;
    
    [self sendRequestData:request.data];
}

-(void)sendRequestData:(NSData *)data{
    [self.tcpTool  sendData:data];
}


+(instancetype)createCnnection2Host:(NSString *)host port:(int)port callBack:(ConnectCallBack)callBack{
    YRTcpConnect *tcpConnect = [[self alloc] init];
    tcpConnect.tcpTool = [YRTcpTool createConnect2Host:host port:port delegate:tcpConnect];
    tcpConnect.conCallback = callBack;
    [tcpConnect updateConnectTimer];
    return nil;
}

+(instancetype)createCnnection2Domain:(NSString *)domain port:(int)port callBack:(ConnectCallBack)callBack{
    
    YRTcpConnect *tcpConnect = [[self alloc] init];
    tcpConnect.tcpTool = [YRTcpTool createConnect2Domain:domain port:port delegate:tcpConnect];
    tcpConnect.conCallback = callBack;
    [tcpConnect updateConnectTimer];
    return nil;
}

-(void)reconnectCallBack:(ConnectCallBack)callBack{
    [self updateConnectTimer];
    self.reconCallback = callBack;
    [self.tcpTool reconnect];
}

#pragma mark- YRTcpToolDelegate

// 连接失败
- (void)tcpTool:(YRTcpTool *)tcpTool connectFailToDomain:(NSString *)domain port:(UInt16)port info:(NSString *)info{
    
    if (self.conCallback) {
       [self connectResult:NO];
    }
    else{
       [self reconnectResult:NO];
    }
    
}

- (void)tcpTool:(YRTcpTool *)tcpTool connectFailToHost:(NSString *)host port:(UInt16)port info:(NSString *)info{
    if (self.conCallback) {
        [self connectResult:NO];
    }
    else{
        [self reconnectResult:NO];
    }
}

// 连接成功
- (void)tcpTool:(YRTcpTool *)tcpTool didConnectToHost:(NSString *)host port:(UInt16)port{
    
    if (self.conCallback) {
        [self connectResult:NO];
    }
    else{
        [self reconnectResult:NO];
    }
}
- (void)tcpTool:(YRTcpTool *)tcpTool didConnectToDomain:(NSString *)domain port:(UInt16)port{
    if (self.conCallback) {
        [self connectResult:NO];
    }
    else{
        [self reconnectResult:NO];
    }
}


// 连接中断
- (void)tcpTool:(YRTcpTool *)tcpTool didDisconnectHost:(NSString *)host port:(UInt16)port error:(NSError *)err{
    
    if (tcpTool.reconnectCount < 3) {
        
        [self reconnectCallBack:^(BOOL isSuccess) {
             [[NSNotificationCenter defaultCenter] postNotificationName:@"reconnect success" object:nil];
        }];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tcpToolDidDisconnectNotice" object:nil];
    }
}

- (void)tcpTool:(YRTcpTool *)tcpTool didDisconnectDomain:(NSString *)domain port:(UInt16)port error:(NSError *)err{
    if (tcpTool.reconnectCount < 3) {
        [self reconnectCallBack:^(BOOL isSuccess) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reconnect success" object:nil];
        }];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tcpToolDidDisconnectNotice" object:nil];
    }
    
}


// 重新连接失败
- (void)tcpTool:(YRTcpTool *)tcpTool reconnectFailToDomain:(NSString *)host port:(UInt16)port info:(NSString *)info{
    
}
- (void)tcpTool:(YRTcpTool *)tcpTool reconnectFailToHost:(NSString *)domain port:(UInt16)port info:(NSString *)info{
    
}


// 成功接收到数据
- (void)tcpTool:(YRTcpTool *)tcpTool didReceiveData:(NSData *)data{
//    YRParseDataTool
//    ... ...
}


@end
