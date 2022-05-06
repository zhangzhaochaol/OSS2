//
//  StrUtil.m
//  OSS2.0-ios-v1
//
//  Created by 孟诗萌 on 16/4/5.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "StrUtil.h"
#import "sys/utsname.h"
#include <mach/mach.h>

#define kColorLength_Version (1 * 2)
#define kColorLength_DeviceType_DeviceNO (4 * 2)
#define kColorLength_Production_Province (4 * 2)

#define kColorLength_UUID (22 * 2)
#define kColorLength_URL (64 * 2)
#define kColorLength_Preorder (64 * 2)

#define kColorValue_Version @"#0063d2"
#define kColorValue_DeviceType_DeviceNO @"#f00"
#define kColorValue_Production_Province @"#f2b101"
#define kColorValue_UUID @"#000"
#define kColorValue_URL @"#000"
#define kColorValue_Preorder @"#000"



@implementation StrUtil

-(NSString *)strToMD5:(NSString *)str
{
//    const char *myPasswd = [str UTF8String ];
//    
//    unsigned char mdc[ 16 ];
//    
//    CC_MD5 (myPasswd, ( CC_LONG ) strlen (myPasswd), mdc);
//    
//    NSMutableString *md5String = [ NSMutableString string ];
//    
//    for ( int i = 0 ; i< 16 ; i++) {
//        
//        [md5String appendFormat : @"%02x" ,mdc[i]];
//        
//    }
//   
//    NSRange range = NSMakeRange(8,16);
//     NSLog(@"%@",md5String);
//    NSString* newStr = [md5String substringWithRange:range];
//     NSLog(@"%@",newStr);
    //return newStr;
    return  str;
}
-(NSString *)dicToJSon:(NSMutableDictionary *)dic
{
//    return dic.json;
    
    NSString *jsonStr = @"{";
    NSDictionary *valueDic = [dic valueForKey:@"infoIn"];
    if (valueDic == nil) {
        valueDic = dic;
    }

    for (NSString *key in [valueDic keyEnumerator]) {
        NSObject *tempValue =[valueDic valueForKey:key];
        if ([tempValue isKindOfClass:[NSString class]]) {
            if ([(NSString *)tempValue isEqualToString:@""]) {
                tempValue = @"\"\"";
            }else{
                tempValue = [NSString stringWithFormat:@"\"%@\"",tempValue];
            }
        }
        //如果有时间类型，需要加双引号中心才会认识，此处在开发时暂时采用遇到一个添加一个if的方式
        if ([key isEqualToString:@"creationDate"]) {
            NSString *addStr = [NSString stringWithFormat:@"%@:\"%@\",",key,tempValue];
            jsonStr = [jsonStr stringByAppendingString:addStr];

        }else if ([key isEqualToString:@"lastUpdateDate"]) {
            NSString *addStr = [NSString stringWithFormat:@"%@:\"%@\",",key,tempValue];
            jsonStr = [jsonStr stringByAppendingString:addStr];
        }else if ([key isEqualToString:@"projectGuaranteeOverTime"]) {
            NSString *addStr = [NSString stringWithFormat:@"%@:\"%@\",",key,tempValue];
            jsonStr = [jsonStr stringByAppendingString:addStr];
        }else if ([key isEqualToString:@"commissioningDate"]) {
            NSString *addStr = [NSString stringWithFormat:@"%@:\"%@\",",key,tempValue];
            jsonStr = [jsonStr stringByAppendingString:addStr];
        }else if ([key isEqualToString:@"overTime"]) {
            NSString *addStr = [NSString stringWithFormat:@"%@:\"%@\",",key,tempValue];
            jsonStr = [jsonStr stringByAppendingString:addStr];
        }else if ([key isEqualToString:@"renewalOverTime"]) {
            NSString *addStr = [NSString stringWithFormat:@"%@:\"%@\",",key,tempValue];
            jsonStr = [jsonStr stringByAppendingString:addStr];
        }else if ([key isEqualToString:@"pipeSegmentLength"]) {
            NSString *addStr = [NSString stringWithFormat:@"%@:\"%@\",",key,tempValue];
            jsonStr = [jsonStr stringByAppendingString:addStr];
        }else if ([key isEqualToString:@"renewalExpirationDate"]) {
            NSString *addStr = [NSString stringWithFormat:@"%@:\"%@\",",key,tempValue];
            jsonStr = [jsonStr stringByAppendingString:addStr];
        }else if ([key isEqualToString:@"projectWarrantyExpireDate"]) {
            NSString *addStr = [NSString stringWithFormat:@"%@:\"%@\",",key,tempValue];
            jsonStr = [jsonStr stringByAppendingString:addStr];
        }else if ([key isEqualToString:@"MTIME"]) {
            NSString *addStr = [NSString stringWithFormat:@"%@:\"%@\",",key,tempValue];
            jsonStr = [jsonStr stringByAppendingString:addStr];
        }else if ([key isEqualToString:@"imageNames"]) {
            if(![[NSString stringWithFormat:@"%@",tempValue] containsString:@"\""]){
                NSString *addStr = [NSString stringWithFormat:@"%@:\"%@\",",key,tempValue];
                jsonStr = [jsonStr stringByAppendingString:addStr];
            }
        }else{
            NSString *addStr = [NSString stringWithFormat:@"%@:%@,",key,tempValue];
            jsonStr = [jsonStr stringByAppendingString:addStr];
        }
    }
    NSLog(@"----jsonStr:%@",jsonStr);
    if (jsonStr.length>1) {
        jsonStr = [jsonStr substringToIndex:([jsonStr length]-1)];
    }

    jsonStr = [jsonStr stringByAppendingString:@"}"];


    NSLog(@"%@",jsonStr);

    NSMutableString * ret = [jsonStr mutableCopy];

    NSRange range;
    range.length = 1;
    for (int i = 0; i < ret.length; i++) {
        range.location = i;
        NSString * chars = [ret substringWithRange:range];
//        if ([chars isEqualToString:@"("]) {
//            [ret replaceCharactersInRange:range withString:@"["];
//        }
        if ([chars isEqualToString:@";"]) {
            [ret replaceCharactersInRange:range withString:@","];
        }
//        if ([chars isEqualToString:@")"]) {
//            [ret replaceCharactersInRange:range withString:@"]"];
//        }

        if ([chars isEqualToString:@"\n"]) {
            [ret replaceCharactersInRange:range withString:@""];
        }
//        if ([chars isEqualToString:@" "] || [chars isEqualToString:@"    "]) {
//            [ret replaceCharactersInRange:range withString:@""];
//        }
    }
    NSLog(@"ret = %@",ret);
    return ret;
}
-(NSString *)dicArrToJSon:(NSMutableArray *)arr{
//    NSString *jsonStr = @"[";
//    for (int i = 0; i<arr.count; i++) {
//        NSDictionary *dic = arr[i];
//        jsonStr = [jsonStr stringByAppendingString:@"{"];
//        NSDictionary *valueDic = [dic valueForKey:@"infoIn"];
//        if (valueDic == nil) {
//            valueDic = dic;
//        }
//
//        for (NSString *key in [valueDic keyEnumerator]) {
//            NSObject *tempValue =[valueDic valueForKey:key];
//            if ([tempValue isKindOfClass:[NSString class]]) {
//                if ([(NSString *)tempValue isEqualToString:@""]) {
//                    tempValue = @"\"\"";
//                }else{
//                    tempValue = [NSString stringWithFormat:@"\"%@\"",tempValue];
//                }
//            }
//            //如果有时间类型，需要加双引号中心才会认识，此处在开发时暂时采用遇到一个添加一个if的方式
//            if ([key isEqualToString:@"creationDate"]) {
//                NSString *addStr = [NSString stringWithFormat:@"%@:\"%@\",",key,tempValue];
//                jsonStr = [jsonStr stringByAppendingString:addStr];
//
//            }else if ([key isEqualToString:@"lastUpdateDate"]) {
//                NSString *addStr = [NSString stringWithFormat:@"%@:\"%@\",",key,tempValue];
//                jsonStr = [jsonStr stringByAppendingString:addStr];
//            }else if ([key isEqualToString:@"projectGuaranteeOverTime"]) {
//                NSString *addStr = [NSString stringWithFormat:@"%@:\"%@\",",key,tempValue];
//                jsonStr = [jsonStr stringByAppendingString:addStr];
//            }else if ([key isEqualToString:@"commissioningDate"]) {
//                NSString *addStr = [NSString stringWithFormat:@"%@:\"%@\",",key,tempValue];
//                jsonStr = [jsonStr stringByAppendingString:addStr];
//            }else if ([key isEqualToString:@"overTime"]) {
//                NSString *addStr = [NSString stringWithFormat:@"%@:\"%@\",",key,tempValue];
//                jsonStr = [jsonStr stringByAppendingString:addStr];
//            }else if ([key isEqualToString:@"renewalOverTime"]) {
//                NSString *addStr = [NSString stringWithFormat:@"%@:\"%@\",",key,tempValue];
//                jsonStr = [jsonStr stringByAppendingString:addStr];
//            }else if ([key isEqualToString:@"pipeSegmentLength"]) {
//                NSString *addStr = [NSString stringWithFormat:@"%@:\"%@\",",key,tempValue];
//                jsonStr = [jsonStr stringByAppendingString:addStr];
//            }else if ([key isEqualToString:@"renewalExpirationDate"]) {
//                NSString *addStr = [NSString stringWithFormat:@"%@:\"%@\",",key,tempValue];
//                jsonStr = [jsonStr stringByAppendingString:addStr];
//            }else if ([key isEqualToString:@"projectWarrantyExpireDate"]) {
//                NSString *addStr = [NSString stringWithFormat:@"%@:\"%@\",",key,tempValue];
//                jsonStr = [jsonStr stringByAppendingString:addStr];
//            }else if ([key isEqualToString:@"MTIME"]) {
//                NSString *addStr = [NSString stringWithFormat:@"%@:\"%@\",",key,tempValue];
//                jsonStr = [jsonStr stringByAppendingString:addStr];
//            }else if ([key isEqualToString:@"imageNames"]) {
//                if(![[NSString stringWithFormat:@"%@",tempValue] containsString:@"\""]){
//                    NSString *addStr = [NSString stringWithFormat:@"%@:\"%@\",",key,tempValue];
//                    jsonStr = [jsonStr stringByAppendingString:addStr];
//                }
//            }else{
//                NSString *addStr = [NSString stringWithFormat:@"%@:%@,",key,tempValue];
//                jsonStr = [jsonStr stringByAppendingString:addStr];
//            }
//        }
//        jsonStr = [jsonStr substringToIndex:([jsonStr length]-1)];
//        jsonStr = [jsonStr stringByAppendingString:@"}"];
//        if (i!=arr.count-1) {
//            jsonStr = [jsonStr stringByAppendingString:@","];
//        }
//    }
//    jsonStr = [jsonStr stringByAppendingString:@"]"];
//
//    NSLog(@"%@",jsonStr);
//
//    NSMutableString * ret = [jsonStr mutableCopy];
//
//    NSRange range;
//    range.length = 1;
//    for (int i = 0; i < ret.length; i++) {
//        range.location = i;
//        NSString * chars = [ret substringWithRange:range];
//        if ([chars isEqualToString:@"("]) {
//            [ret replaceCharactersInRange:range withString:@"["];
//        }
//        if ([chars isEqualToString:@";"]) {
//            [ret replaceCharactersInRange:range withString:@","];
//        }
//        if ([chars isEqualToString:@")"]) {
//            [ret replaceCharactersInRange:range withString:@"]"];
//        }
//
//        if ([chars isEqualToString:@"\n"]) {
//            [ret replaceCharactersInRange:range withString:@""];
//        }
////        if ([chars isEqualToString:@" "] || [chars isEqualToString:@"    "]) {
////            [ret replaceCharactersInRange:range withString:@""];
////        }
//    }
//    NSLog(@"ret = %@",ret);
    return arr.json;
}
-(NSString *)GMTToLocal:(NSString *)intime{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"MMM dd, yyyy HH:mm:ss"];
    NSDate *inDate=[dateFormatter dateFromString:intime];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strDate = [dateFormatter stringFromDate:inDate];
    NSLog(@"%@",inDate);
    return strDate;
}
-(NSString *)GMTToLocalWithAMPM:(NSString *)intime{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"MMM dd, yyyy HH:mm:ss a"];
    NSDate *inDate=[dateFormatter dateFromString:intime];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strDate = [dateFormatter stringFromDate:inDate];
    NSLog(@"%@",inDate);
    return strDate;
}

-(NSString *)LocalToGMT:(NSString *)intime{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:locale];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *inDate=[dateFormatter dateFromString:intime];
    
    [dateFormatter setDateFormat:@"MMM dd, yyyy HH:mm:ss"];
    
     NSString *strDate = [dateFormatter stringFromDate:inDate];
    
    return strDate;
}

-(NSString *)LocalToGMTWithSecond:(NSString *)intime{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:locale];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *inDate=[dateFormatter dateFromString:intime];
    
    [dateFormatter setDateFormat:@"MMM dd, yyyy HH:mm:ss"];
    
    NSString *strDate = [dateFormatter stringFromDate:inDate];
    
    return strDate;
}
-(NSString *)GMTToLocalWithSecond:(NSString *)intime{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"MMM dd, yyyy HH:mm:ss"];
    NSDate *inDate=nil;
   
    NSArray * formats = @[@"MMM dd, yyyy HH:mm:ss", @"E MMM dd HH:mm:ss z yyyy", @"yyyy-MM-dd HH:mm:ss"];
    for (NSString * format in formats) {
        [dateFormatter setDateFormat:format];
        inDate = [dateFormatter dateFromString:intime];
        if (inDate != nil) {
            break;
        }
    }
    
    
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:inDate];
    NSLog(@"%@",inDate);
    return strDate;
}

-(NSString *)GMTToLocalWithSecond_PMAM:(NSString *)intime{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"MMM dd, yyyy hh:mm:ss aa"];
    NSDate *inDate=[dateFormatter dateFromString:intime];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:inDate];
    NSLog(@"%@",inDate);
    return strDate;
}

- (UIImage *) addText:(UIImage *)img lon:(NSString *)lon lat:(NSString *)lat {
    if (img == nil) {
        return  nil;
    }
    int w = img.size.width;
    int h = img.size.height;
    UIGraphicsBeginImageContext(img.size);
    [[UIColor redColor] set];
    [img drawInRect:CGRectMake(0, 0, w, h)];
    //经纬度部分
    NSString * mark;
    if (lon == nil) {
        lon = @"";
    }
    if (lat == nil) {
        lat = @"";
    }
    //当前时间
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    
    //绘制水印
    mark = [NSString stringWithFormat:@"经纬度:%@/%@\n时间:%@",lon,lat,dateString];
    [mark drawInRect:CGRectMake(0, 0, w, h) withFont:[UIFont systemFontOfSize: w/15]];
    
    UIImage *aimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return aimg;
}
-(NSString *)dateToTimeInterval:(NSDate *)date{
    return [NSString stringWithFormat:@"%ld",(long)[date timeIntervalSince1970]];
}
/**
  *  设备版本
  *
  *  @return e.g. iPhone 5S
  */
-(NSString*)deviceVersion
{
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    //iPhone
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,3"])    return @"iPhone SE";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    
    //iPod
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([deviceString isEqualToString:@"iPod7,1"])      return @"iPod Touch 6G";
    
    //iPad
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2 (32nm)";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad mini (GSM)";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad mini (CDMA)";
    
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3(WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3(CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3(4G)";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4 (4G)";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (CDMA)";
    
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    
    if ([deviceString isEqualToString:@"iPad4,4"]
        ||[deviceString isEqualToString:@"iPad4,5"]
        ||[deviceString isEqualToString:@"iPad4,6"])      return @"iPad mini 2";
    
    if ([deviceString isEqualToString:@"iPad4,7"]
        ||[deviceString isEqualToString:@"iPad4,8"]
        ||[deviceString isEqualToString:@"iPad4,9"])      return @"iPad mini 3";
    
    if ([deviceString isEqualToString:@"iPad5,1"]
        ||[deviceString isEqualToString:@"iPad5,2"])      return @"iPad mini 4";
    
    return deviceString;
}
/**
 *  系统版本
 */
-(NSString *)systemVersion{
    return [[UIDevice currentDevice] systemVersion];
}
/**
 * 网络状态
 */
-(NSString *)getNetWorkStates{
    
    return @"forbidden_Wifi";
    
//    id _statusBar = nil;
//    if (@available(iOS 13.0, *)) {
//        UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].keyWindow.windowScene.statusBarManager;
//        if ([statusBarManager respondsToSelector:@selector(createLocalStatusBar)]) {
//            UIView *_localStatusBar = [statusBarManager performSelector:@selector(createLocalStatusBar)];
//            if ([_localStatusBar respondsToSelector:@selector(statusBar)]) {
//                _statusBar = [_localStatusBar performSelector:@selector(statusBar)];
//            }
//        }
//    } else {
//        // Fallback on earlier versions
//        UIApplication *app = [UIApplication sharedApplication];
//        _statusBar = [app valueForKeyPath:@"statusBar"];
//    }
//
//
//
//
//    NSArray *children = [[valueForKeyPath:@"foregroundView"]subviews];
//    NSString *state = [[NSString alloc]init];
//    int netType = 0;
//    //获取到网络返回码
//    for (id child in children) {
//        if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
//            //获取到状态栏
//            netType = [[child valueForKeyPath:@"dataNetworkType"]intValue];
//
//            switch (netType) {
//                case 0:
//                    state = @"无网络";
//                    //无网模式
//                    break;
//                case 1:
//                    state = @"2G";
//                    break;
//                case 2:
//                    state = @"3G";
//                    break;
//                case 3:
//                    state = @"4G";
//                    break;
//                case 5:
//                {
//                    state = @"WIFI";
//                }
//                    break;
//                default:
//                    break;
//            }
//        }
//    }
    //根据状态选择
//    return state;
}
/**
 * 获取当前设备可用内存
 */
-(double)availableMemory{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    return ((vm_page_size *vmStats.free_count) / 1024.0) / 1024.0;
}
//设置大头针上绘制的文字
-(UILabel *)makeAnnotationViewLabel:(NSString *)titleCode :(NSString *)titleSubNum :(NSString *)mark :(BOOL)markFirst{
    UILabel *lable=[[UILabel alloc]init];
    lable.font=[UIFont systemFontOfSize:13];
    lable.textColor=[UIColor blueColor];
    NSString *title;
    if (markFirst) {
        title =(titleCode == nil ||[titleCode isEqualToString:@""] || [titleCode isEqualToString:@"(null)"])?@"无序号":[NSString stringWithFormat:@"%@%@",mark,titleCode];
    }else{
        title =(titleCode == nil ||[titleCode isEqualToString:@""] || [titleCode isEqualToString:@"(null)"])?@"无序号":[NSString stringWithFormat:@"%@%@",titleCode,mark];
    }
    if (titleSubNum!=nil) {
        lable.text=(titleSubNum ==nil ||[titleSubNum isEqualToString:@""])?[NSString stringWithFormat:@"%@%@",mark,titleCode]:[NSString stringWithFormat:@"%@_%@",title,titleSubNum];
    }else{
        if (markFirst) {
            lable.text=(titleCode ==nil ||[titleCode isEqualToString:@""])?@"无序号":[NSString stringWithFormat:@"%@%@",mark,titleCode];
        }else{
            lable.text=(titleCode ==nil ||[titleCode isEqualToString:@""])?@"无序号":[NSString stringWithFormat:@"%@%@",titleCode,mark];
        }
    }
    [lable sizeToFit];
    
    if ([lable.text isEqualToString:@"无序号"]) {
        lable.text = @"";
    }
    
    return lable;
}
+(NSString *)textColorWithDevice:(NSString *)taskId{
 
    if (taskId && taskId.length > 0 && ![taskId isEqualToString:@"null"]) {
        /* 有内容时带颜色显示 */
        
        
        BOOL isSelfOrder = false;
        
        NSString * userName = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
        
        
        NSArray * arr = [taskId componentsSeparatedByString:@"#"];
        
        for (NSString * string in arr) {
            
            if ([string isEqualToString:userName]) {
                isSelfOrder = true;
                break;
            }
            
        }
        
        if (isSelfOrder) {
            /* 当前角色的工单中的资源 */
            
            return @"#e60d36";
            
        }else{
            /* 其它角色的工单资源 */
            
            return @"#096ee0";
            
        }
        
        
    }else{
        /* 为空时正常显示 */
        return @"#000";
    }
    
}

+(BOOL)isMyOrderWithTaskId:(NSString *)taskId{
    BOOL isMyOrder = false;
    
    if (taskId == nil) {
        
        /* 容错：若未在调用此方法前进行taskId的为空判断的情况下，若为空，直接返回真 */
        
        return true;
    }
    
    if (taskId) {
        /* 如果有，获取当前登录账号*/
        NSString * userName = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
        /* 分割为数组 */
        NSArray * arr = [taskId componentsSeparatedByString:@"#"];
    
        /* 遍历数组，确认接收人中是否包含当前账号 */
        for (NSString * reciverName in arr) {
            
            if ([reciverName isEqualToString:userName]) {
                /* 如果包含 */
                isMyOrder = true;
                break;
            }
            
        }
    }
    
    return isMyOrder;
}
+ (NSString *)taskIdWithTaskId:(NSString *)taskId{

    
    NSString * ret = nil;
    
    /* 可变化数组 */
    NSMutableArray * taskInfo = [NSMutableArray arrayWithArray:[taskId componentsSeparatedByString:@"#"]];
    /* 移除空项 */
    
    
    NSLog(@"%@ --- %@", taskId, taskInfo);
    
    [taskInfo removeObject:@""];
    
    /* 取出工单 */
    ret = [taskInfo firstObject];
    
    return ret;
    
}
+(NSString *)reciverWithTaskId:(NSString *)taskId{
    
    /* 创建接收人字符串 */
    NSString * reciverName = @"";
    NSMutableArray * taskInfo = [NSMutableArray arrayWithArray:[taskId componentsSeparatedByString:@"#"]];
    
    [taskInfo removeObject:[self taskIdWithTaskId:taskId]];
    [taskInfo removeObject:@""];
    
    /* 取出接收人拼接字符串 */
    for (NSString * str in taskInfo) {
        if (![str isEqualToString:taskId]) {
            reciverName = [reciverName stringByAppendingString:[NSString stringWithFormat:@"%@、",str]];
        }
    }
    /* 剔除末尾的、 */
    if (reciverName.length > 0) {
        reciverName = [reciverName substringToIndex:reciverName.length - 1];
    }
    
    return reciverName;
}
+ (NSString *)getAppVersion{
    NSDictionary * dic = [[NSBundle mainBundle] infoDictionary];
    
    return dic[@"CFBundleShortVersionString"];
    
}
+ (CGFloat)heightOfTop{
    
    UINavigationController * nav = [[UINavigationController alloc] init];
    
    NSLog(@"%@",@([[UIApplication sharedApplication] statusBarFrame].size.height + nav.navigationBar.frame.size.height));
    
    return ([[UIApplication sharedApplication] statusBarFrame].size.height + nav.navigationBar.frame.size.height);
    
}
@end

@implementation NSString (IWPString2)

- (NSString *)getSrtingBetweenSting:(NSString *)startString andString:(NSString *)endString{
    
    NSRange startRange = [self rangeOfString:startString];
    NSRange endRange = [self rangeOfString:endString];

    NSRange trueRange = NSMakeRange(startRange.length + startRange.location, endRange.location - (startRange.length + startRange.location));
    
    
    NSLog(@"%@ -- %@", [self substringWithRange:startRange], [self substringWithRange:endRange]);
    
    
    NSLog(@"%@ -- %@ --- %@", NSStringFromRange(startRange), NSStringFromRange(endRange), NSStringFromRange(trueRange));
    
    
    if (trueRange.length > self.length) {
        return @"";
    }
    
    return [self substringWithRange:trueRange];

    
}


-(BOOL)isAllZero{
    
    
    for (NSInteger i = 0; i < self.length; i++) {
        
        NSString * str = [self substringWithRange:NSMakeRange(i, 1)];
        NSLog(@"%@", str);
    
        if (![str isEqualToString:@"0"]) {
            return NO;
        }
    }
    
    return YES;
    
}
-(NSAttributedString *)getColorfulQRCode{
    
    NSMutableAttributedString * ret = [[NSMutableAttributedString alloc] initWithString:self attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.f]}];
    
    
    if (ret.length >= 18) {
        
        
        [ret setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:kColorValue_Version],
                             NSFontAttributeName:[UIFont systemFontOfSize:18.f]
                             } range:NSMakeRange(0, kColorLength_Version)];
        
        [ret setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:kColorValue_DeviceType_DeviceNO],NSFontAttributeName:[UIFont systemFontOfSize:18.f]} range:NSMakeRange(kColorLength_Version, kColorLength_DeviceType_DeviceNO)];
        
        [ret setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:kColorValue_Production_Province],NSFontAttributeName:[UIFont systemFontOfSize:18.f]} range:NSMakeRange(kColorLength_DeviceType_DeviceNO + kColorLength_Version, kColorLength_Production_Province)];
        
    }
    
    
    
    return ret;
}
-(NSString *)deleteZeroString{
    
    if (self.length == 0) {
        return @"";
    }
    
    if ([self isEqualToString:@"0"] || [self isAllZero]) {
        return @"...";
    }

    NSRange finalRange = NSMakeRange(0, 0);
    

    for (NSInteger i = self.length; i >= 0; i--) {
        
        NSString * c = [self substringWithRange:NSMakeRange(i - 1, 1)];
        if (![c isEqualToString:@"0"]) {
            
            finalRange.length = i;
            break;
        }
        
    }
    
    
    NSLog(@"%lu", (unsigned long)finalRange.length);
    
    
    if (finalRange.length == self.length) {
        return self;
    }else{
        return [[self substringWithRange:finalRange] stringByAppendingString:@"..."];
    }
}

-(BOOL)isEqualToAnyStringInArr:(NSArray <NSString *> *)arr{
    
    if (arr.count == 0) {
        return false;
    }
    
    BOOL ret = false;
    for (NSString * str in arr) {
        if ([self isEqualToString:str]) {
            ret = true;
            break;
        }
    }
    
    return ret;
    
}

-(BOOL)isEqualToAnyString:(NSString *)string, ...NS_REQUIRES_NIL_TERMINATION{
    
    if ([self isEqualToString:string]) {
        return YES;
    }
    
    va_list args;
    va_start(args, string);
    if (string){
        
        NSString * otherString = nil;
        
        do {
            otherString = va_arg(args,id);
            
            // NSLog(@"%@ ===== %@", self, otherString);
            
            
            if ([self isEqualToString:otherString]) {
                return YES;
            }
            
        } while (otherString != nil);
        
        
        
    }
    va_end(args);
    
    return NO;
    
}
-(NSString *)makeDeviceId{
    
    return [self stringByAppendingString:@"Id"];
    
}

-(NSString *)GMTToLocalWithSecond{
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"MMM dd, yyyy HH:mm:ss"];
    NSDate *inDate=[dateFormatter dateFromString:self];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:inDate];
    NSLog(@"%@",inDate);
    return strDate;
    
}
@end
