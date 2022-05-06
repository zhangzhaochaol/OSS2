//
//  IWPTestClass.h
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2016/8/10.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IWPCleanCache : NSObject




/**
 *  获取某目录中的所有文件
 *
 *  @param path 目录
 *
 *  @return 文件名数组
 */
-(NSArray *)cacheListWithDir:(NSString *)dirName;

-(NSArray *)cacheListWithDir:(NSString *)dirName withType:(NSString *)fileType;

/**
 *  重新整理沙盒文件，将其放入其应该在的地方
 */
-(void)refreshSandBoxWithCompletedHandler:(void(^)(BOOL isNeedShowHint))completed;
/**
 *  获取某文件夹下所有文件的大小
 *
 *  @param dir 目标文件夹
 *
 *  @return 该文件夹所有文件的大小(MB)
 */
-(float)sizeOfDir:(NSString *)dir;
/**
 *  删除指定文件
 *
 *  @param filePath 文件路径
 *
 *  @return 是否删除成功
 */
-(BOOL)deleteFileAtPath:(NSString *)filePath;

/**
 重命名文件

 @param filePath 当前文件路径
 @param newName 新文件名称（不含扩展名）
 @return 是否成功
 */
- (BOOL)renameFileAtPath:(NSString *)filePath withNewName:(NSString *)newName;
/**
 *  获取所有缓存的大小
 *
 *  @return 所有缓存大小
 */
-(float)sizeOfAllCache;
/**
 *  获取某个文件的大小
 *
 *  @param path 该文件所处路径
 *
 *  @return 该文件的大小
 */
-(float)fileSizeWithFilePath:(NSString *)path;
/**
 *  判断文件/目录是否存在
 *
 *  @param path 要查询的路径
 *
 *  @return 存在返回真，否则返回假
 */
-(BOOL)isExist:(NSString *)path;

/**
 保存资源到本地文件

 @param dict 资源字典
 */
-(void)saveDeviceToLocation:(NSDictionary *)dict;

/**
 从本地文件中删除某离线资源

 @param dict 要删除的离线资源字典
 */
-(void)removeOfflineDeviceFromLocation:(NSDictionary *)dict;
/**
 从本地文件中删除某离线资源的下属资源
 
 @param dict 要删除的离线资源字典
 */
-(void)removeOfflineDeviceFromLocationMainFile:(NSDictionary *)dict;


/**
 从本地主设备中读取下属子设备

 @param fileName     要读取的主设备文件名
 @param mainDeviceId 主设备的真实ID

 @return 下属子设备的数组
 */
-(NSArray <NSDictionary *>*)readSubDevicesFromMainDevice:(NSString *)fileName withMainDeviceId:(NSNumber *)mainDeviceId;

/**
 添加新的离线设备到本地文件，多用于一级(父)资源或在线转离线子资源

 @param dict 设备字典
 */
-(void)addNewOfflineDeviceWithDict:(NSDictionary *)dict;

/**
 添加新的离线子资源到本地主资源文件，多用于纯离线子资源
 
 @param dict 设备字典
 */
-(void)addNewOfflineSubDeviceToMainDeviceWithDict:(NSDictionary *)dict;



/**
 替换已有的离线资源到本地文件

 @param dict 更新后的资源字典
 */
-(void)replaceOfflineDeviceWithNewDict:(NSDictionary *)dict;

/**
 替换已有的离线子资源
 */
-(void)replaceOfflineSubDeviceWithNewDict:(NSDictionary *)dict;

-(void)deleteDeviceWithDict:(NSDictionary *)dict;

@end
