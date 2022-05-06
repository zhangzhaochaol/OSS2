//
//  Inc_OSS2_VM.m
//  javaScript_ObjectC
//
//  Created by yuanquan on 2022/4/21.
//

#import "Inc_OSS2_VM.h"

// 模块
#import "GisTYKMainViewController.h"
#import "Inc_Push_MB.h"
#import "Yuan_NewFL_SearchListVC.h"              //局向光纤 和 光路列表入口

@implementation Inc_OSS2_VM



// 跳转至哪一个模块
- (void) viewModel_JoinModule:(JoinModule_)joinModule {
    
    switch (joinModule) {
            
        case JoinModule_GIS: {
            
            GisTYKMainViewController * gis = [[GisTYKMainViewController alloc] init];
            Push(_homeVC, gis);
        }
            
            break;
            
        default:
            break;
    }
    
}


// 跳转至模板
- (void) JumpToMB:(NSDictionary *) jumpDict {
    
    [_webViewBridge callHandler:@"jumpToMBClick"
                           data:jumpDict.json
               responseCallback:^(id responseData) {
            
    }];
    
}



// 跳转模块的json
- (void) viewModel_JoinModuleDict:(NSDictionary *) jumpDict {
    
    
    NSString * version = jumpDict[@"version"];
    // 该资源老模板对应的resLogicName
    NSString * resLogicName = jumpDict[@"resLogicName"];
    // 该资源新模板对应的fileName
    NSString * fileName = jumpDict[@"fileName"];
    NSString * title = jumpDict[@"title"];
 
    
    if ([resLogicName isEqualToString:@"GIS"]) {
        
        GisTYKMainViewController * gis = [[GisTYKMainViewController alloc] init];
        Push(_homeVC, gis);
        
        return;
    }
    
    
    
    if (!version || !resLogicName) {
        [YuanHUD HUDFullText:@"模板数据错误"];
        return;
    }
    
    
    if ([version isEqualToString:@"new"]) {
        
        Inc_NewMB_VM * vm = Inc_NewMB_VM.viewModel;
        
        Yuan_NewMB_ModelEnum_ modelEnum = [vm EnumFromFileName:fileName];
        
        [Inc_Push_MB push_NewMB_ListEnum:modelEnum vc:_homeVC];
        
    }
    
    else if ([version isEqualToString:@"old"]) {
        
        // 光纤光路
        if ([resLogicName isEqualToString:@"opticalPath"]) {
        
            Yuan_NewFL_SearchListVC * link =
            [[Yuan_NewFL_SearchListVC alloc] initWithEnterType:NewFL_EnterType_Link];
            
            Push(_homeVC, link);
            
            return;
        }
        
        // 局向光纤
        if ([resLogicName isEqualToString:@"optLogicPair"]) {
            
            Yuan_NewFL_SearchListVC * link =
            [[Yuan_NewFL_SearchListVC alloc] initWithEnterType:NewFL_EnterType_Route];
            
            Push(_homeVC, link);
            
            
            return;
        }
        
        
        
        [Inc_Push_MB pushResourceTYKListFrom:_homeVC
                                    fileName:resLogicName
                                    showName:title];

    }
    
    else {
        return;
    }
    
    
}

 
 

#pragma mark - 声明单粒 ---

+ (Inc_OSS2_VM *) shareInstance {
    
    static Inc_OSS2_VM * instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[super alloc] init];
    });
    
    return instance;
}


- (id) copyWithZone:(NSZone *) zone {
    
    return  [self.class shareInstance];
}

- (id) mutableCopyWithZone:(NSZone *) zone {
    
    return  [self.class shareInstance];
}

@end
