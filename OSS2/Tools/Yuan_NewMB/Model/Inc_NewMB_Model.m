//
//  Inc_NewMB_Model.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/3/16.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_NewMB_Model.h"
#import "Inc_NewMB_VM.h"

@implementation Inc_NewMB_Model

{
    
    Yuan_NewMB_ModelEnum_ _enum;
    
    NSString * _jsonFile;
    
}



#pragma mark - 初始化构造方法

- (instancetype)initWithEnum:(Yuan_NewMB_ModelEnum_) modelEnum {
    
    if (self = [super init]) {
        
        _enum = modelEnum;
        
        Inc_NewMB_VM * VM = Inc_NewMB_VM.viewModel;
        
        // 根据枚举值 , 管理模板对应的文件
        _jsonFile = [VM fileNameFromEnum:modelEnum];;
    }
    return self;
}


// 根据json 获取Views的模板数据
- (NSArray <Yuan_NewMB_ModelItem *> *) model {
    
    
    if (_jsonFile.length == 0 || !_jsonFile) {
        
        [YuanHUD HUDFullText:@"未配置模板文件对应的文件名"];
        return nil;
    }
    
    // 根据json文件名称 取出对应的模板
    NSDictionary * jsonDict = LoadJSONFile(_jsonFile);

    // 证明模板文件错误
    if (jsonDict.count == 1 &&
        [jsonDict.allKeys containsObject:@"error"]) {
        [YuanHUD HUDFullText:jsonDict[@"error"]];
        return @[];
    }
    
    NSArray * views = jsonDict[@"views"];
    
    
    NSMutableArray * mt_Arr = NSMutableArray.array;
    
    for (NSDictionary * data in views) {

        
        NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:data];
        
        if ([mt_Dict[@"required"] isEqualToString:@"1"]) {
            mt_Dict[@"title"] = [NSString stringWithFormat:@"%@ *",mt_Dict[@"title"]];
        }
        
        // map 转 model
        Yuan_NewMB_ModelItem * item = [Yuan_NewMB_ModelItem Json:mt_Dict];
        
        [mt_Arr addObject:item];
    }
    
    return mt_Arr;
}

@end














// ***** ***** ***** ***** 分割线 ***** ***** ***** ***** ***** *****



///MARK:  根据Json 获取模板对应的增删改查 和其他必要的信息  --- --- ---
@implementation Inc_NewMB_HttpPort

{
    
    // 想要哪个资源的接口呢?
    Yuan_NewMB_ModelEnum_ _enum;
    
    NSDictionary * _URL_Dict;
    
    // 模板枚举对应的Json文件名
    NSString * _jsonFile;
}



+ (instancetype) ModelEnum:(Yuan_NewMB_ModelEnum_) modelEnum {
    
    return [[Inc_NewMB_HttpPort alloc] initWithEnum:modelEnum];
}


#pragma mark - 初始化构造方法

- (instancetype)initWithEnum:(Yuan_NewMB_ModelEnum_) modelEnum {
    
    if (self = [super init]) {
        _enum = modelEnum;
        
        Inc_NewMB_VM * VM = Inc_NewMB_VM.viewModel;
        
        // 根据枚举值 , 管理模板对应的文件
        _jsonFile = [VM fileNameFromEnum:modelEnum];;
        
        if (_jsonFile.length != 0) {
            _URL_Dict = LoadJSONFile(_jsonFile);
        }
        else {
            [YuanHUD HUDFullText:@"未配置模板文件对应的文件名"];
            _URL_Dict = @{};
        }
    }
    return self;
}


#pragma mark - 增删改查 ---

- (NSString *)Select {
    
    
    if ([_URL_Dict.allKeys containsObject:@"url_select"]) {
        return _URL_Dict[@"url_select"];
    }
    
    return @"";
}


- (NSString *)SelectFrom_IdType {
    
    if ([_URL_Dict.allKeys containsObject:@"url_select_detail_fromId"]) {
        return _URL_Dict[@"url_select_detail_fromId"];
    }
    
    return @"";
}


- (NSString *)Add {
    
 
    if ([_URL_Dict.allKeys containsObject:@"url_insert"]) {
        return _URL_Dict[@"url_insert"];
    }
    
    return @"";
}



- (NSString *)Modifi {
    
    if ([_URL_Dict.allKeys containsObject:@"url_update"]) {
        return _URL_Dict[@"url_update"];
    }
    
    return @"";

}



- (NSString *)Delete {
    
    
    if ([_URL_Dict.allKeys containsObject:@"url_delete"]) {
        return _URL_Dict[@"url_delete"];
    }
    
    return @"";
}




// 通用模板类型(type) 与 必要的查询设备编码(code)

- (NSString *)type {
    
    if ([_URL_Dict.allKeys containsObject:@"type"]) {
        return _URL_Dict[@"type"];
    }
    return nil;
}


- (NSString *)code {
    
    if ([_URL_Dict.allKeys containsObject:@"code"]) {
        return _URL_Dict[@"code"];
    }
    return nil;
}




@end















// ***** ***** ***** ***** 分割线 ***** ***** ***** ***** ***** *****

@implementation Yuan_NewMB_ModelItem


#pragma mark - 初始化构造方法



-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
    
}




- (id)valueForUndefinedKey:(NSString *)key {
    
    return @"";
}


@end
