//
//  YRDomainTool.m
//  YRTcpSocketDemo
//
//  Created by yangrui on 2018/4/26.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "YRDomainTool.h"
#import "HostResolver.h"

@interface YRDomainTool ()<HostResolverDelegate>

@property(nonatomic, strong)HostResolver *hostResoler;
@property(nonatomic, copy)DomainCallBack callBack;
@end

static YRDomainTool *_domainTool = nil;
@implementation YRDomainTool

+(instancetype)shareInstance{
    if (!_domainTool) {
        _domainTool = [[self alloc] init];
    }
    return _domainTool;
}



// 比如： name = "en.gobuylight.com"
-(void)parseName:(NSString *)name callBack:(DomainCallBack)callBack{

    self.hostResoler = [[HostResolver alloc]initWithName:name];
    self.hostResoler.delegate = self;
    self.callBack = callBack;
    [self.hostResoler start];

}

- (void)hostResolverDidFinish:(HostResolver *)resolver{
    [resolver cancel];
    NSMutableArray *nameArrM = [NSMutableArray array];
    if (resolver.resolvedAddressStrings.count > 0) {
        [nameArrM addObjectsFromArray:resolver.resolvedAddressStrings];
    }
    
    self.callBack(nameArrM, nil);
    self.callBack = nil;
    
}
- (void)hostResolver:(HostResolver *)resolver didFailWithError:(NSError *)error{
    [resolver cancel];
    self.callBack(nil, error);
    self.callBack = nil;
}

@end
