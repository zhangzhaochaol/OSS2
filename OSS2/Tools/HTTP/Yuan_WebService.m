//
//  Yuan_WebService.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/21.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_WebService.h"

@implementation Yuan_WebService


- (NSString *) webServiceGetDomainCode {
    
    // TODO: 上线的时候一定要改回来
    
    #if DEBUG
//        return @"anhui";
    #endif
    

    NSString * domainCode = UserModel.domainCode; //delegate.domainCode
    
    NSString * province = @"";
    
    
    if (!domainCode) {
        return @"";
    }
    
    if([domainCode isEqualToString:@"01/"]){
        province = @"beijing";
    }else if([domainCode isEqualToString:@"02/"]){
        province = @"tianjin";
    }else if([domainCode isEqualToString:@"03/"]){
        province = @"chongqing";
    }else if([domainCode isEqualToString:@"04/"]){
        province = @"heilongjiang";
    }else if([domainCode isEqualToString:@"05/"]){
        province = @"guangxi";
    }else if([domainCode isEqualToString:@"06/"]){
        province = @"neimenggu";
    }else if([domainCode isEqualToString:@"07/"]){
        province = @"xizang";
    }else if([domainCode isEqualToString:@"08/"]){
        province = @"xinjiang";
    }else if([domainCode isEqualToString:@"09/"]){
        province = @"ningxia";
    }else if([domainCode isEqualToString:@"0A/"]){
        province = @"hebei";
    }else if([domainCode isEqualToString:@"0B/"]){
        province = @"shandong";
    }else if([domainCode isEqualToString:@"0C/"]){
        province = @"liaoning";
    }else if([domainCode isEqualToString:@"0D/"]){  // 上线改回上海
        province = @"shanghai";
    }else if([domainCode isEqualToString:@"0E/"]){
        province = @"jilin";
    }else if([domainCode isEqualToString:@"0F/"]){
        province = @"gansu";
    }else if([domainCode isEqualToString:@"0G/"]){
        province = @"qinghai";
    }else if([domainCode isEqualToString:@"0H/"]){
        province = @"henan";
    }else if([domainCode isEqualToString:@"0I/"]){
        province = @"jiangsu";
    }else if([domainCode isEqualToString:@"0J/"]){
        province = @"hubei";
    }else if([domainCode isEqualToString:@"0K/"]){
        province = @"hunan";
    }else if([domainCode isEqualToString:@"0L/"]){
        province = @"jiangxi";
    }else if([domainCode isEqualToString:@"0M/"]){
        province = @"zhejiang";
    }else if([domainCode isEqualToString:@"0N/"]){
        province = @"guangdong";
    }else if([domainCode isEqualToString:@"0O/"]){
        province = @"yunnan";
    }else if([domainCode isEqualToString:@"0P/"]){
        province = @"fujian";
    }else if([domainCode isEqualToString:@"0Q/"]){
        province = @"hainan";
    }else if([domainCode isEqualToString:@"0R/"]){
        province = @"shanxi";
    }else if([domainCode isEqualToString:@"0S/"]){
        province = @"sichuan";
    }else if([domainCode isEqualToString:@"0T/"]){
        province = @"shannxi";
    }else if([domainCode isEqualToString:@"0U/"]){
        province = @"guizhou";
    }else if([domainCode isEqualToString:@"0V/"]){
        province = @"anhui";
    }else if([domainCode isEqualToString:@"0W/"]){
        province = @"henan_t";
    }else {
        province = @"beijing";
    }
    
    
    
    
    return province;
    
}



+ (NSString *) webServiceGetDomainCode {
    
    
    
#if DEBUG
//    return @"anhui";
#endif
    
    

    NSString * domainCode = UserModel.domainCode; //delegate.domainCode
    
    NSString * province = @"";
    
    
    if (!domainCode) {
        return @"";
    }
    
    if([domainCode isEqualToString:@"01/"]){
        province = @"beijing";
    }else if([domainCode isEqualToString:@"02/"]){
        province = @"tianjin";
    }else if([domainCode isEqualToString:@"03/"]){
        province = @"chongqing";
    }else if([domainCode isEqualToString:@"04/"]){
        province = @"heilongjiang";
    }else if([domainCode isEqualToString:@"05/"]){
        province = @"guangxi";
    }else if([domainCode isEqualToString:@"06/"]){
        province = @"neimenggu";
    }else if([domainCode isEqualToString:@"07/"]){
        province = @"xizang";
    }else if([domainCode isEqualToString:@"08/"]){
        province = @"xinjiang";
    }else if([domainCode isEqualToString:@"09/"]){
        province = @"ningxia";
    }else if([domainCode isEqualToString:@"0A/"]){
        province = @"hebei";
    }else if([domainCode isEqualToString:@"0B/"]){
        province = @"shandong";
    }else if([domainCode isEqualToString:@"0C/"]){
        province = @"liaoning";
    }else if([domainCode isEqualToString:@"0D/"]){  // 上线改回上海
        province = @"shanghai";
    }else if([domainCode isEqualToString:@"0E/"]){
        province = @"jilin";
    }else if([domainCode isEqualToString:@"0F/"]){
        province = @"gansu";
    }else if([domainCode isEqualToString:@"0G/"]){
        province = @"qinghai";
    }else if([domainCode isEqualToString:@"0H/"]){
        province = @"henan";
    }else if([domainCode isEqualToString:@"0I/"]){
        province = @"jiangsu";
    }else if([domainCode isEqualToString:@"0J/"]){
        province = @"hubei";
    }else if([domainCode isEqualToString:@"0K/"]){
        province = @"hunan";
    }else if([domainCode isEqualToString:@"0L/"]){
        province = @"jiangxi";
    }else if([domainCode isEqualToString:@"0M/"]){
        province = @"zhejiang";
    }else if([domainCode isEqualToString:@"0N/"]){
        province = @"guangdong";
    }else if([domainCode isEqualToString:@"0O/"]){
        province = @"yunnan";
    }else if([domainCode isEqualToString:@"0P/"]){
        province = @"fujian";
    }else if([domainCode isEqualToString:@"0Q/"]){
        province = @"hainan";
    }else if([domainCode isEqualToString:@"0R/"]){
        province = @"shanxi";
    }else if([domainCode isEqualToString:@"0S/"]){
        province = @"sichuan";
    }else if([domainCode isEqualToString:@"0T/"]){
        province = @"shannxi";
    }else if([domainCode isEqualToString:@"0U/"]){
        province = @"guizhou";
    }else if([domainCode isEqualToString:@"0V/"]){
        province = @"anhui";
    }else if([domainCode isEqualToString:@"0W/"]){
        province = @"henan_t";
    }else {
        province = @"beijing";
    }
    
    
    
    
    return province;
    
}


+ (NSString *) webServiceGetChineseName {
    

    NSString * domainCode = UserModel.domainCode; //delegate.domainCode
    
    NSString * province = @"";
    
    
    if (!domainCode) {
        return @"";
    }
    
    if([domainCode isEqualToString:@"01/"]){
        province = @"北京";
    }else if([domainCode isEqualToString:@"02/"]){
        province = @"天津";
    }else if([domainCode isEqualToString:@"03/"]){
        province = @"重庆";
    }else if([domainCode isEqualToString:@"04/"]){
        province = @"黑龙江";
    }else if([domainCode isEqualToString:@"05/"]){
        province = @"广西";
    }else if([domainCode isEqualToString:@"06/"]){
        province = @"内蒙古";
    }else if([domainCode isEqualToString:@"07/"]){
        province = @"西藏";
    }else if([domainCode isEqualToString:@"08/"]){
        province = @"新疆";
    }else if([domainCode isEqualToString:@"09/"]){
        province = @"宁夏";
    }else if([domainCode isEqualToString:@"0A/"]){
        province = @"河北";
    }else if([domainCode isEqualToString:@"0B/"]){
        province = @"山东";
    }else if([domainCode isEqualToString:@"0C/"]){
        province = @"辽宁";
    }else if([domainCode isEqualToString:@"0D/"]){  // 上线改回上海
        province = @"上海";
    }else if([domainCode isEqualToString:@"0E/"]){
        province = @"吉林";
    }else if([domainCode isEqualToString:@"0F/"]){
        province = @"甘肃";
    }else if([domainCode isEqualToString:@"0G/"]){
        province = @"青海";
    }else if([domainCode isEqualToString:@"0H/"]){
        province = @"河南";
    }else if([domainCode isEqualToString:@"0I/"]){
        province = @"江苏";
    }else if([domainCode isEqualToString:@"0J/"]){
        province = @"湖北";
    }else if([domainCode isEqualToString:@"0K/"]){
        province = @"湖南";
    }else if([domainCode isEqualToString:@"0L/"]){
        province = @"江西";
    }else if([domainCode isEqualToString:@"0M/"]){
        province = @"浙江";
    }else if([domainCode isEqualToString:@"0N/"]){
        province = @"广东";
    }else if([domainCode isEqualToString:@"0O/"]){
        province = @"云南";
    }else if([domainCode isEqualToString:@"0P/"]){
        province = @"福建";
    }else if([domainCode isEqualToString:@"0Q/"]){
        province = @"海南";
    }else if([domainCode isEqualToString:@"0R/"]){
        province = @"山西";
    }else if([domainCode isEqualToString:@"0S/"]){
        province = @"四川";
    }else if([domainCode isEqualToString:@"0T/"]){
        province = @"陕西";
    }else if([domainCode isEqualToString:@"0U/"]){
        province = @"贵州";
    }else if([domainCode isEqualToString:@"0V/"]){
        province = @"安徽";
    }else if([domainCode isEqualToString:@"0W/"]){
        province = @"河南测试";
    }else {
        province = @"北京";
    }
    
    return province;
    
}

@end
