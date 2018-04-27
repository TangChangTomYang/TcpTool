//
//  YRDomainTool.h
//  YRTcpSocketDemo
//
//  Created by yangrui on 2018/4/26.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DomainCallBack)(NSArray<NSString *>* arr ,NSError *err);

@interface YRDomainTool : NSObject
+(instancetype)shareInstance;
// 比如： name = "en.gobuylight.com"
-(void)parseName:(NSString *)name callBack:(DomainCallBack)callBack;
@end
