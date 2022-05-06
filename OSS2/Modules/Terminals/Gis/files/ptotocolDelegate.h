//
//  ptotocolDelegate.h
//  OSS2.0-ios-v1
//
//  Created by 孟诗萌 on 16/4/22.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ptotocolDelegate <NSObject>

@optional
-(void)returnStation:(NSString *) stationName : (NSString *) stationID;//设置所属局站
-(void)makeImageNames:(NSString *) imageNames;//设置资源的照片
-(void)returnRegion:(NSString *) regionName;//设置所属维护区域
-(void)returnGenerator:(NSString *) generatorName : (NSString *) generatorID;//设置所属机房
-(void)makeGeneratorModelEqu:(NSMutableDictionary *)odfEqu : (NSString *) doType;//设置当前机房平面图下ODF设备变动后所返回的相关信息
-(void)returnCable:(NSString *) cableName : (NSString *) cableId;//设置所属缆段
-(void)returnRedCable:(NSString *) cableName : (NSString *) cableId;//设置所属缆段(备用)
-(void)returnRfid:(NSString *)rfidStr;//获取标签号
-(void)getCable:(NSDictionary *) cable;//获取所属缆段
-(void)getRoute:(NSDictionary *) route;//获取所属光缆
-(void)getPoint:(NSDictionary *) point;//获取端子信息
-(void)makeRfidText:(NSString *)rfidText;//写入扫描结果
-(void)equInitReturn:(NSDictionary *)initInfo;//设备初始化
-(void)newDeciceWithDict:(NSDictionary<NSString *,NSString *> *)dict;//刷新列表
-(void)deleteDeviceWithDict:(NSDictionary *)dict withViewControllerClass:(__unsafe_unretained Class)vcClass;//删除刷新
-(void)reloadTableViewWithDict:(NSDictionary *)dict;//删除列表
-(void)wellFaceRefreshWithDict:(NSDictionary *)dict :(NSString *) locationNo;//刷新当前井面
-(void)setLoginSetState:(BOOL)isSavePWD;//变更登录界面密码保存状态;
-(void)setMapSelectRegion:(NSString *)selectRegion andDomainCode:(NSString *)domainCode;//地区切换所选择的省份
-(void)setDeleteDeviceShowView:(NSDictionary *)dic;//删除OBD后刷新所在主设备面板调用方法
-(void)setUpdateDeviceInfo:(NSDictionary *)dic;//修改OBD信息后刷新所在主设备面板相关数据
-(void)returnBtInfo:(NSString *) name :(NSString *) uuidStr;//设置当前连接设备的信息(蓝牙连接用)
-(void)returnfjListInfo:(NSMutableArray *) fjList :(NSDictionary *)selectLouceng;//修改用户新增的楼层内房间信息
-(void)doSomeThingo:(NSDictionary *)dic;//使控制器做一些事情
-(void)returnLockId:(NSString *) lockId;//设置获取到的锁Id
-(void)returnSaomiaoRfid:(NSString *) rfidStr;
/**
 *  照片路径，仅在离线中使用
 */
-(void)photoWithPath:(NSString *)photoPath;
-(void)returnBackPollingInfo:(NSMutableDictionary *)backPollingInfo;//巡检执行成功回调方法

- (void)didSelectABlueTooth;// 选中蓝牙列表中的蓝牙设备信息后调用，用于更新是否验证mac地址的变量


@end
