//
//  IWPTestClass.m
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2016/8/10.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "IWPCleanCache.h"


#define kOfflineDataPath(fileName) [NSString stringWithFormat:@"%@/%@/%@.data",DOC_DIR,kOffilineData,(fileName)]

@implementation IWPCleanCache
-(NSArray *)cacheListWithDir:(NSString *)dirName{
    
    
    // 获得此程序的沙盒路径
    NSArray *patchs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // 获取Documents路径
    // [patchs objectAtIndex:0]
    NSString *documentsDirectory = [patchs objectAtIndex:0];
    
    NSString *fileDirectory = [documentsDirectory stringByAppendingPathComponent:dirName];
    
//    NSLog(@"fileDirectory = %@",fileDirectory);
    
    if ([dirName isEqualToString:kOnlineImage]) {
        fileDirectory = [fileDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@",UserModel.domainCode]];
    }
    
//    NSLog(@"fileDirectory = %@",fileDirectory);
    NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:fileDirectory error:nil];
    
    NSMutableArray * newFiles = [NSMutableArray array];
    
    
//    for (index = 0; index < newFiles.count; index++) {
//        if ([newFiles[index] isEqualToString:@".DS_Store"] ||
//            [[newFiles[index] substringToIndex:1] isEqualToString:@"."]) {
//            [newFiles removeObject:newFiles[index]];
//        }
//    }
    
    
    for (NSString * fileName in files) {
     
        if (![fileName hasPrefix:@"."]) {
            [newFiles addObject:fileName];
        }
        
    }
    
    
    
    return newFiles;
}

-(NSArray *)cacheListWithDir:(NSString *)dirName withType:(NSString *)fileType2{
    
    NSArray * files = [self cacheListWithDir:dirName];
    NSMutableArray * filePathsArrTemp = [NSMutableArray array];
    
    for (NSString * fileName in files) {
        NSString * fileType = [fileName componentsSeparatedByString:@"."].lastObject;
        if ([[fileType lowercaseString] isEqualToString:[fileType2 lowercaseString]]) {
            [filePathsArrTemp addObject:fileName];
        }
    }
    
    
    return filePathsArrTemp;
    
}

-(void)refreshSandBoxWithCompletedHandler:(void (^)(BOOL isNeedShowHint))completed{
    NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *createPath = [NSString stringWithFormat:@"%@/%@", pathDocuments,kPropertiesPath];
    
    // 判断文件夹是否存在，如果不存在，则创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:createPath]) {
        
        
        // 首先， 取出所有文件列表
        NSArray * files = [self cacheListWithDir:@""];
        
        // 分门别类存放于不同数组
        NSMutableArray * properties = [NSMutableArray array];
        NSMutableArray * onlineImages = [NSMutableArray array];
        
        for (NSString * filePath in files) {
            if ([[[filePath componentsSeparatedByString:@"."] lastObject] isEqualToString:@"properties"]) {
                // 配置文件
                [properties addObject:filePath];
            }else if ([[[filePath componentsSeparatedByString:@"."] lastObject] isEqualToString:@"jpg"] ||
                      [[[filePath componentsSeparatedByString:@"."] lastObject] isEqualToString:@"png"]){
                // 图片
                [onlineImages addObject:filePath];
            }
        }
        
//        NSLog(@"%lu",(unsigned long)properties.count
//              );
        // 将配置文件保存至目录中
        for (NSString * fileName in properties) {
            NSString * filePath = [NSString stringWithFormat:@"%@/%@",DOC_DIR,fileName];
//            NSLog(@"旧文件路径：%@",filePath);
            // 读取文件
            NSData * data = [NSData dataWithContentsOfFile:filePath];
            // 创建文件管理器
            NSFileManager * fileManager = [NSFileManager defaultManager];
            // 创建新的存储路径
            NSString * path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:[NSString stringWithFormat:@"/%@",kPropertiesPath]];
//            NSLog(@"新文件路径：%@",path);
            // 创建文件夹
            [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
            
            // 将文件写入新目录
            [data writeToFile:[path stringByAppendingString:[NSString stringWithFormat:@"/%@",fileName]] atomically:YES];
            // 删除老文件
//            NSLog(@"path = %@", filePath);
            [fileManager removeItemAtPath:filePath error:nil];
            
//            NSLog(@"");
        }
//        NSLog(@"onlineImages = %@",onlineImages);
        for (NSString * fileName in onlineImages) {
            NSString * filePath = [NSString stringWithFormat:@"%@/%@",DOC_DIR,fileName];
//            NSLog(@"旧文件路径：%@",filePath);
            // 读取文件
            NSData * data = [NSData dataWithContentsOfFile:filePath];
            // 创建文件管理器
            NSFileManager * fileManager = [NSFileManager defaultManager];
            // 创建新的存储路径
            NSString * path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:[NSString stringWithFormat:@"/%@",kOnlineImage]];
//            NSLog(@"新文件路径：%@",path);
            // 创建文件夹
            [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
            
            // 将文件写入新目录
            [data writeToFile:[path stringByAppendingString:[NSString stringWithFormat:@"/%@",fileName]] atomically:YES];
            // 删除老文件
//            NSLog(@"path = %@", filePath);
            [fileManager removeItemAtPath:filePath error:nil];
            
//            NSLog(@"");
        }
        completed(NO);
    } else {
        completed(NO);
    }
    
}
-(float)fileSizeWithFilePath:(NSString *)path{
    float ret = 0.f;
    
    NSDictionary *fileAttributeDic=[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    
    ret = fileAttributeDic.fileSize/ 1024.0/ 1024.0;
    
    return ret;
}
-(float)sizeOfDir:(NSString *)dir{
    // 传入Documents中的文件夹名称，获取该文件夹下的缓存大小
    
    NSString * path = [NSString stringWithFormat:@"%@/%@",DOC_DIR,dir];
    NSFileManager * fileManager = [[NSFileManager alloc] init];
    
    float size = 0;
    
    NSArray * array = [fileManager contentsOfDirectoryAtPath:path error:nil];
    
    for (int i = 0; i < [array count]; i++){
        
        NSString *fullPath = [path stringByAppendingPathComponent:[array objectAtIndex:i]];
        
        BOOL isDir = false;
        
        if (!([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && isDir)){
            
            NSDictionary * fileAttributeDic = [fileManager attributesOfItemAtPath:fullPath error:nil];
            
            size += fileAttributeDic.fileSize / 1024.f / 1024.f;
            
        }else{
            [self sizeOfDir:fullPath];
        }
        
    }

    return size;
}
-(BOOL)deleteFileAtPath:(NSString *)filePath{
    
    NSError * err = nil;
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&err];
    
    if (err) {
        return NO;
    }else{
        return YES;
    }
}

- (BOOL)renameFileAtPath:(NSString *)filePath withNewName:(NSString *)newName{
    
    NSError * err = nil;
    NSData * data = [NSData dataWithContentsOfFile:filePath];
    
    [NSFileManager.defaultManager removeItemAtPath:filePath error:&err];
    
    if (err) {
        return NO;
    }else{
        
        NSArray * main = [filePath componentsSeparatedByString:@"/"];
        
        NSString * oldFileFullName = main.lastObject;
        
        NSArray * temp = [oldFileFullName componentsSeparatedByString:@"."];
        
        
        
        NSString * fileType = nil;
        if (temp.count > 1) {
            fileType = temp.lastObject;
        }
        
        NSString * savePath = [filePath stringByAppendingString:oldFileFullName];
        
        NSString * newFullFilePath = nil;
        
        if (fileType != nil) {
            newFullFilePath = [NSString stringWithFormat:@"%@/%@.%@", savePath, newName, fileType];
        }else{
            newFullFilePath = [NSString stringWithFormat:@"%@/%@", savePath, newName];
        }
        
        
        [data writeToFile:newFullFilePath atomically:false];
        return TRUE;
    }
    
    
    
}

-(float)sizeOfAllCache{
    float retSize = 0.f;

    NSArray * arr = @[kOffilineData, kOfflineImage,[NSString stringWithFormat:@"%@/%@",kOnlineImage,UserModel.domainCode], kPropertiesPath, kEqutProps, kDeviceModel, kCardModelProps, kIFlyFileDir, kResourceMainProps, kHIKVideoDir];
    for (int i = 0; i < arr.count; i++) {
        retSize += [self sizeOfDir:arr[i]];
    }
    
    return retSize;
}
-(BOOL)isExist:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:path];
}
-(void)saveDeviceToLocation:(NSDictionary *)dict{
    NSString * fileName = dict[@"resLogicName"];
    
    if (fileName.length == 0) {
        return;
    }
    
    NSString * filePath = [NSString stringWithFormat:@"%@/%@/%@.data", DOC_DIR, kOffilineData, fileName];
    NSString * trueKey = [NSString stringWithFormat:@"%@Id", fileName];
    NSData * jsonData = [NSData dataWithContentsOfFile:filePath];
    NSMutableArray * devices = nil;
    if (jsonData) {
        devices = [NSMutableArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil][@"info"]];
        NSInteger index2 = 0;
        for (NSDictionary * dict2 in devices) {
            if ([dict2[@"deviceId"] integerValue] == [dict[@"deviceId"] integerValue] ||
                ([dict2[trueKey] integerValue] == [dict[trueKey] integerValue] && [dict[trueKey] integerValue] != 0)) {
                [devices replaceObjectAtIndex:index2 withObject:dict];
                break;
            }
            index2++;
        }
        
        if (index2 == devices.count) {
            [devices addObject:dict];
        }
        
    }else{
        devices = [NSMutableArray arrayWithArray:@[dict]];
    }
    
    NSDictionary * writeDict = @{@"info":devices};
    
    NSData * writeData = [DictToString(writeDict) dataUsingEncoding:NSUTF8StringEncoding];
    
    [writeData writeToFile:filePath atomically:NO];
}
-(void)removeOfflineDeviceFromLocationMainFile:(NSDictionary *)dict{
    NSString * deviceType = dict[@"resLogicName"];
    NSString * fileName = nil;
    
    if ([deviceType isEqualToString:@"pole"]) {
        fileName = @"poleline";
    }else if ([deviceType isEqualToString:@"well"]){
        fileName = @"pipe";
    }else if ([deviceType isEqualToString:@"markStone"]){
        fileName = @"markStonePath";
    }
    
    NSString * filePath = [NSString stringWithFormat:@"%@/%@/%@.data",DOC_DIR,kOffilineData,fileName];
    NSData * jsonData = [NSData dataWithContentsOfFile:filePath];
    
    
    if (jsonData) {
        
        NSMutableDictionary * mainDevice = nil;
        NSArray * mainDevices = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil][@"info"];
        
        // 找到该资源所属主资源
        NSInteger mainIndex = 0;
        for (NSDictionary * temp in mainDevices) {
            if ([temp[@"deviceId"] isEqualToNumber:dict[@"mainDeviceId"]]) {
                mainDevice = [NSMutableDictionary dictionaryWithDictionary:temp];
                break;
            }
            mainIndex++;
        }
        
        if (mainDevice) {
            NSMutableArray * arr = [NSMutableArray arrayWithArray:mainDevice[@"subDevices"]];
            NSInteger index = 0;
            for (NSDictionary * dic in mainDevice[@"subDevices"]) {
                if ([dic[@"deviceId"] isEqualToNumber:dict[@"deviceId"]]) {
                    [arr removeObjectAtIndex:index];
                }
                index++;
            }
            
            [mainDevice setObject:arr forKey:@"subDevices"];
            
            NSMutableArray * devices = [NSMutableArray arrayWithArray:mainDevices];
            [devices replaceObjectAtIndex:mainIndex withObject:mainDevice];
            
            NSData * data = [DictToString(@{@"info":devices}) dataUsingEncoding:NSUTF8StringEncoding];
            [data writeToFile:filePath atomically:NO];
        }
        
        
    }else{
#warning 应该不会有这个情况才对
        NSLog(@"⚠️⚠️⚠️⚠️⚠️⚠️我在这里：%s，这个判断没写全⚠️⚠️⚠️⚠️⚠️⚠️",__func__);
    }
    
}
-(void)removeOfflineDeviceFromLocation:(NSDictionary *)dict{
    NSString * fileName = dict[@"resLogicName"];
    
    if (fileName.length == 0) {
        return;
    }
    
    NSString * filePath = [NSString stringWithFormat:@"%@/%@/%@.data", DOC_DIR, kOffilineData, fileName];
    NSData * jsonData = [NSData dataWithContentsOfFile:filePath];
    
    if (jsonData) {
        NSMutableArray * allDevices = [NSMutableArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil][@"info"]];
        NSArray * tempArr = [NSArray arrayWithArray:allDevices];
        
        for (NSDictionary * temp in tempArr) {
            if ([temp[@"deviceId"] integerValue] == [dict[@"deviceId"] integerValue] && [dict[@"deviceId"] integerValue] != 0) {
                [allDevices removeObject:temp];
            }
            
        }
        
        NSDictionary * writeDict = @{@"info":allDevices};
        NSData * writeData = [DictToString(writeDict) dataUsingEncoding:NSUTF8StringEncoding];
        [writeData writeToFile:filePath atomically:NO];
        
        if (allDevices.count == 0) {
            [self deleteFileAtPath:filePath];
        }
    }
    
}
-(NSArray<NSDictionary *> *)readSubDevicesFromMainDevice:(NSString *)fileName withMainDeviceId:(NSNumber *)mainDeviceId{
    NSString * filePath = [NSString stringWithFormat:@"%@/%@/%@.data",DOC_DIR,kOffilineData, fileName];
    NSData * jsonData = [NSData dataWithContentsOfFile:filePath];
    NSString * trueKey  = [NSString stringWithFormat:@"%@Id",fileName];
    if (jsonData) {
        // 有数据
        
        NSArray * allMainDevices = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil][@"info"];
        
        // 遍历数组，找到与传入设备ID相同的主涉笔
        NSDictionary * mainDevice = nil;
        for (NSDictionary * temp in allMainDevices) {
            
//            NSLog(@"%@ ==== %@",temp[trueKey], mainDeviceId);
            if (([temp[trueKey] integerValue] == mainDeviceId.integerValue && [temp[trueKey] integerValue] != 0) ||
                ([temp[@"deviceId"] integerValue] == mainDeviceId.integerValue)) {
                mainDevice = [NSDictionary dictionaryWithDictionary:temp];
                break;
            }
            
        }
        
        if (!mainDevice) {
            // 如果未对该字典赋值，说明没有任何资源被读取，直接返回空字典
            return @[];
        }
        
        // 读取到了，直接返回
        
//        NSLog(@"mainDevice[@\"subDevices\"]%@",mainDevice[@"subDevices"]);
        return mainDevice[@"subDevices"];
        
        
    }
    // 无数据，直接返回空数组
    return @[];
}
-(void)addNewOfflineDeviceWithDict:(NSDictionary *)dict{
    NSString * fileName = dict[@"resLogicName"];
    NSString * filePath = [NSString stringWithFormat:@"%@/%@/%@.data",DOC_DIR,kOffilineData, fileName];
    NSData * jsonData = [NSData dataWithContentsOfFile:filePath];
    
    if (jsonData) {
        // 已有资源
        NSMutableArray * saveArr = [NSMutableArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil][@"info"]];
        [saveArr addObject:dict];
        
        NSDictionary * writeDict = @{@"info":saveArr};
        NSData * writeData = [DictToString(writeDict) dataUsingEncoding:NSUTF8StringEncoding];
        [writeData writeToFile:filePath atomically:NO];
    }else{
        
        // 没有资源，直接放
        NSDictionary * writeDict = @{@"info":@[dict]};
        NSData * writeData = [DictToString(writeDict) dataUsingEncoding:NSUTF8StringEncoding];
        [writeData writeToFile:filePath atomically:NO];
    }
    
}
-(void)addNewOfflineSubDeviceToMainDeviceWithDict:(NSDictionary *)dict{
    
    
    
    NSString * deviceType = dict[@"resLogicName"];
    NSString * fileName = nil;
    
    if ([deviceType isEqualToString:@"pole"]) {
        fileName = @"poleline";
    }else if ([deviceType isEqualToString:@"well"]){
        fileName = @"pipe";
    }else if ([deviceType isEqualToString:@"markStone"]){
        fileName = @"markStonePath";
    }
    
    if (dict[@"isOnlineDevice"]) {
        // 在线转离线设备应调用此方法，本判断为防止误操作
        [self addNewOfflineDeviceWithDict:dict];
        return;
    }
    
    NSString * filePath = kOfflineDataPath(fileName);
    NSData * jsonData = [NSData dataWithContentsOfFile:filePath];
    
    if (jsonData) {
        // 有数据
        NSMutableDictionary * mainDevice = nil;
        NSArray * mainDevices = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil][@"info"];
        
        // 找到该资源所属主资源
        NSInteger mainIndex = 0;
        for (NSDictionary * temp in mainDevices) {
            if ([temp[@"deviceId"] isEqualToNumber:dict[@"mainDeviceId"]]) {
                mainDevice = [NSMutableDictionary dictionaryWithDictionary:temp];
                break;
            }
            mainIndex++;
        }
        
        if (mainDevice) {
            
            NSMutableArray * arr = [NSMutableArray arrayWithArray:mainDevice[@"subDevices"]];
            // 具体是替换、删除还是添加，应于调用该方法前判断
            [arr addObject:dict];
            
            [mainDevice setObject:arr forKey:@"subDevices"];
            
            NSMutableArray * devices = [NSMutableArray arrayWithArray:mainDevices];
            
            [devices replaceObjectAtIndex:mainIndex withObject:mainDevice];
            
            NSData * data = [DictToString(@{@"info":devices}) dataUsingEncoding:NSUTF8StringEncoding];
            [data writeToFile:filePath atomically:NO];
            
//            NSString * file = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            
//            NSLog(@"%@", file);
            
        }
    }
    
}
-(void)replaceOfflineDeviceWithNewDict:(NSDictionary *)dict{
    NSString * fileName = dict[@"resLogicName"];
    NSString * filePath = [NSString stringWithFormat:@"%@/%@/%@.data",DOC_DIR,kOffilineData, fileName];
    NSData * jsonData = [NSData dataWithContentsOfFile:filePath];
    
    // 既然是替换，说明本地一定有文件
    if (jsonData) {
        NSArray * oldAllDevices = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil][@"info"];
        
        NSMutableArray * newAllDevices = [NSMutableArray array];
        for (NSDictionary * temp in oldAllDevices) {
            if ([temp[@"deviceId"] isEqualToNumber:dict[@"deviceId"]]) {
                [newAllDevices addObject:dict];
            }else{
                [newAllDevices addObject:temp];
            }
        }
        
        NSDictionary * writeDict = @{@"info":newAllDevices};
        NSData * writeData = [DictToString(writeDict) dataUsingEncoding:NSUTF8StringEncoding];
        [writeData writeToFile:filePath atomically:NO];
    }else{
        //#warning 应该不会有这个情况才对
        NSLog(@"⚠️⚠️⚠️⚠️⚠️⚠️我在这里：%s，这个判断没写全⚠️⚠️⚠️⚠️⚠️⚠️",__func__);
    }
}
-(void) deleteDeviceWithDict:(NSDictionary *)dict{
    NSString * filePath = [NSString stringWithFormat:@"%@/%@/%@.data", DOC_DIR, kOffilineData, dict[@"resLogicName"]];
    
    NSData * jsonData = [NSData dataWithContentsOfFile:filePath];
    
    if (jsonData) {
        
        NSMutableArray * devices = [NSMutableArray arrayWithArray:[[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil] valueForKey:@"info"]];
        for (int i = 0; i < devices.count; i++) {
            if ([devices[i][@"deviceId"] integerValue] ==
                [dict[@"deviceId"] integerValue]) {
                [devices removeObjectAtIndex:i];
            }
        }
        
        NSData * writeData = [DictToString(@{@"info":devices}) dataUsingEncoding:NSUTF8StringEncoding];
        
        [writeData writeToFile:filePath atomically:NO];
        
    }else{
        NSLog(@"UNKNOWERROR(不该为空的data为空了)");
    }
}

-(void)replaceOfflineSubDeviceWithNewDict:(NSDictionary *)dict{
    NSString * deviceType = dict[@"resLogicName"];
    NSString * fileName = nil;
    
    if ([deviceType isEqualToString:@"pole"]) {
        fileName = @"poleline";
    }else if ([deviceType isEqualToString:@"well"]){
        fileName = @"pipe";
    }else if ([deviceType isEqualToString:@"markStone"]){
        fileName = @"markStonePath";
    }
    
    if (dict[@"isOnlineDevice"]) {
        // 在线转离线设备应调用此方法，本判断为防止误操作
        [self replaceOfflineDeviceWithNewDict:dict];
        return;
    }
    
    NSString * filePath = kOfflineDataPath(fileName);
    NSData * jsonData = [NSData dataWithContentsOfFile:filePath];
    
    if (jsonData) {
        // 有数据
        NSMutableDictionary * mainDevice = nil;
        NSArray * mainDevices = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil][@"info"];
        
        // 找到该资源所属主资源
        NSInteger mainIndex = 0;
        for (NSDictionary * temp in mainDevices) {
            if ([temp[@"deviceId"] isEqualToNumber:dict[@"mainDeviceId"]]) {
                mainDevice = [NSMutableDictionary dictionaryWithDictionary:temp];
                break;
            }
            mainIndex++;
        }
        
        if (mainDevice) {
            
            NSMutableArray * arr = [NSMutableArray arrayWithArray:mainDevice[@"subDevices"]];
            // 具体是替换、删除还是添加，应于调用该方法前判断
            
            NSInteger index = 0;
            
            for (NSDictionary * device in arr) {
                
                if ([device[@"deviceId"] integerValue] == [dict[@"deviceId"] integerValue]) {
                    break;
                }
                index++;
            }
            
            
            [arr replaceObjectAtIndex:index withObject:dict];
            
            [mainDevice setObject:arr forKey:@"subDevices"];
            
            NSMutableArray * devices = [NSMutableArray arrayWithArray:mainDevices];
            
            [devices replaceObjectAtIndex:mainIndex withObject:mainDevice];
            
            NSData * data = [DictToString(@{@"info":devices}) dataUsingEncoding:NSUTF8StringEncoding];
            [data writeToFile:filePath atomically:NO];
        }
    }
    
}

@end
