//
//  HttpPort.m
//  INCP&EManager
//
//  Created by 袁全 on 2020/4/3.
//  Copyright © 2020 Unigame.space. All rights reserved.
//

#import <Foundation/Foundation.h>



#pragma mark ---  通用地址  ---

#define Yuan_BaseURL_Local          @"http://192.168.1.8:8888/im/service/"      //龙哥本地
#define Yuan_BaseURL_OnLineTest     @"http://60.10.25.166:8080/im/service/"     //测试服务器
#define Yuan_BaseURL_OnlineRelease  @"http://120.52.12.11:8080/im/service/"     //正式服务器

#pragma mark ---  通用接口  ---


#define HTTP_General_GetData @"data!getData.interface"

#define HTTP_General_UpData  @"data!updateData.interface"






#pragma mark - 统一库 端子展现 ***  Yuan_New_ODFModelVC


/// 获取端子展现的数据
#define ODFModel_GetLimitData @"rm!getCommonData.interface"

/// 新建一个端子盘数据
#define ODFModel_InitPie @"rm!createCnctShelf.interface"

/// 删除一个原有的端子盘
#define ODFModel_DeletePie @"rm!deleteCommonData.interface"

/// 获取端子盘信息 - 详情    行 列 行内个数
#define ODFModel_DetailData @"rm!queryPointsByCnctShelf.interface"

/// 创建模块信息 , 红色绑卡长按创建
#define ODFModel_LongPressTapInitModule @"rm!createModule.interface"


/// ****** ******  ****** ******  ****** ******  ****** ******


#pragma mark ---  盯防和巡检 工作台 workSurface ---

/// 巡检工单接口 通用请求接口
#define WS_HTTP_XJList  HTTP_General_GetData


/// 盯防工单接口 通用请求接口
#define WS_HTTP_DFList  HTTP_General_GetData



#pragma mark -  光缆纤芯 2020.07.21  ---

#define CF_HTTP_InitFiber @"rm!createOptPair.interface"

#define CF_HTTP_ConnectSearchCableList @"rm!getEqutCable.interface"

#define CF_HTTP_ConfigSave @"rm!updateOptPairConnect.interface"


#pragma mark -  Bulid 楼宇 2020.8.13  ---

#define Bulid_Http_StandardAddrPort  @"spcApi/findAddrSegmByScope"

