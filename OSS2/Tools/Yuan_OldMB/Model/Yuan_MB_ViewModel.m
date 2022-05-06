//
//  Yuan_MB_ViewModel.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/3/1.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_MB_ViewModel.h"
#import "IWPPropertiesReader.h"

@implementation Yuan_MB_ViewModel


+ (instancetype) viewModel {
    
    return [[Yuan_MB_ViewModel alloc] init];
}

#pragma mark - 初始化构造方法

- (instancetype)init {
    
    if (self = [super init]) {
        
    }
    return self;
}



- (NSArray *) Special_MB_Config:(NSMutableArray *) arr {
    
    if (_model.subName.length > 0 && ![_model.subName isEqualToString:@"null"]) {
        
        IWPViewModel * viewModelnew2 = [[IWPViewModel alloc] init];
        viewModelnew2.tv1_Required = @"1";
        viewModelnew2.tv1_Text = [NSString stringWithFormat:@"%@名称", _model.name];
        viewModelnew2.ed1_Ed = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:_model.subNameEditable.integerValue]];
        viewModelnew2.type = @"9"; // type9
        viewModelnew2.name1 = _model.list_item_title_name;
        [arr insertObject:viewModelnew2 atIndex:0];
    }
    
    //直放站/天线/RRU/eBodeB/NodeB/BTS/基站控制器(RNC)/基站控制器(BSC)/铁塔/归属位置寄存器(HLR)/PCRF/HSS/网关（PGW,SGW）/MME/媒体网关(MGW)/MscServer MSC/SGSN/GGSN/MSCPOOL/信令网设备/数据网设备/接入网设备/智能网设备/软交换设备/传统交换网设备/传输设备/UTN设备/存储设备/服务器设备/其他设备/网络设备/分光器/分光器端子
    if (self.controlMode == TYKDeviceListInsertRfid||
        self.controlMode == TYKDeviceListUpdateRfid||
        self.controlMode == TYKDeviceInfomationTypeDuanZiMianBan_Update) {
        
        if ([_fileName isEqualToString:@"opticTerm"]||
            [_fileName isEqualToString:@"shelf"] ||
            [_fileName isEqualToString:@"optPair"] ||
            [_fileName isEqualToString:@"markStonePath"] ||
            [_fileName isEqualToString:@"EquipmentPoint"]) {
            
            // optPair 纤芯光缆段配置 -- yuan
        }else{
            IWPViewModel * viewModelnew = [[IWPViewModel alloc] init];
            viewModelnew.tv1_Required = @"1";
            viewModelnew.tv1_Text = @"标签ID";
            viewModelnew.type = @"52";
            viewModelnew.name1 = @"rfid";// key
            viewModelnew.ed1_Ed = @"1";
            viewModelnew.ed1_Hint = @"请扫描";
            viewModelnew.btn1_text = @"扫描";
            [arr insertObject:viewModelnew atIndex:0];
        }
    }
    
   
    
    //MARK: 袁全新增 , 管线资源 -- 引上点上加一个扫一扫
    if ([_fileName isEqualToString:@"ledUp"]) {
        IWPViewModel * viewModelnew = [[IWPViewModel alloc] init];
        viewModelnew.tv1_Required = @"1";
        viewModelnew.tv1_Text = @"标签ID";
        viewModelnew.type = @"52";
        viewModelnew.name1 = @"rfid";// key
        viewModelnew.ed1_Ed = @"1";
        viewModelnew.ed1_Hint = @"请扫描";
        viewModelnew.btn1_text = @"扫描";
        [arr insertObject:viewModelnew atIndex:0];
    }
    
    
    //MARK: 袁全新增 , 管线资源 -- 引上点上加一个扫一扫
    if ([_fileName isEqualToString:@"EquipmentPoint"]) {
        IWPViewModel * viewModelnew = [[IWPViewModel alloc] init];
        viewModelnew.tv1_Required = @"1";
        viewModelnew.tv1_Text = @"标签ID";
        viewModelnew.type = @"52";
        viewModelnew.name1 = @"rfid";// key
        viewModelnew.ed1_Ed = @"1";
        viewModelnew.ed1_Hint = @"请扫描";
        viewModelnew.btn1_text = @"扫描";
        [arr insertObject:viewModelnew atIndex:0];
    }
    
    
    
    // _viewModel = viewModel; yuan ---
    
    
    // 维护单位 -- 当维护单位的时候 , 需要修改模板为  *** **** ***
    
    NSInteger whdw_Index = 0;
    BOOL isNeedRelace_whdw = NO;
    
    IWPViewModel * _viewM = nil;
    
    for (IWPViewModel * viewModel in arr) {
        
        // 维护单位对应的
        if ([viewModel.name1 isEqualToString:@"maintenanceOrgId"]) {
            whdw_Index = [arr indexOfObject:viewModel];
            isNeedRelace_whdw = YES;
            _viewM= viewModel;
            break;
        }
    }
    
    if (isNeedRelace_whdw) {
        IWPViewModel * viewModel_whdw = [[IWPViewModel alloc] init];
        viewModel_whdw.tv1_Required = _viewM.tv1_Required;
        viewModel_whdw.tv1_Text = @"维护单位";
        viewModel_whdw.type = @"13";
        viewModel_whdw.name1 = @"maintenanceOrgId";// key
        viewModel_whdw.ed1_Ed = @"1";
        viewModel_whdw.btn1_text = @"获取";
        
        
        [arr replaceObjectAtIndex:whdw_Index withObject:viewModel_whdw];
    }
    

    return arr;
}




// 对特殊字段进行特殊处理
- (NSMutableDictionary *) Special_MB_KeyConfig:(NSMutableDictionary *) requestDict
                                           key:(NSString *)key{
    
    
    if ([requestDict.allKeys containsObject:key]) {
        NSString * date = requestDict[key];
        if ( [date containsString:@"GMT+08:00"]) {
            requestDict[@"startUseDate"] = [date stringByReplacingOccurrencesOfString:@"GMT+08:00" withString:@"CST"];
        }
        
    }
    
    
    return requestDict;
}

@end
