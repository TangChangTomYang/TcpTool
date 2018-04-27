//
//  TcpDefine.h
//  YRTcpSocketDemo
//
//  Created by yangrui on 2018/4/26.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#ifndef TcpDefine_h
#define TcpDefine_h


#endif /* TcpDefine_h */


typedef enum {
    YRTcpRequestQualityType_default, //使用默认超时
    YRTcpRequestQualityType_hight,   //超时后最多再发送一次请求
    YRTcpRequestQualityType_Highest, //超时后最多再发二次送请求
}YRTcpRequestQualityType;



