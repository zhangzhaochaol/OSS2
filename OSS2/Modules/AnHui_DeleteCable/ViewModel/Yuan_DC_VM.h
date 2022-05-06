//
//  Yuan_DC_VM.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2021/1/11.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_DC_VM : NSObject

+ (Yuan_DC_VM *) shareInstance;


/** 定位中 .. */
@property (nonatomic , assign) BOOL isLocationing;


/** 是否正在配置中 */
@property (nonatomic , assign) BOOL isCableing;


/** 是否自动配置  默认false */
@property (nonatomic , assign) BOOL isAutoConfigTube;


/** 是否正在关联起止终止设备 */
@property (nonatomic , assign) BOOL isConnectStartEndDevice;



/** 模板的Dict */
@property (nonatomic , copy) NSString * cableId;


//. 验证是否有获取线路 和 撤缆的权限  -- 是否是 把山点
- (BOOL) isHaveJurisdictionHandle:(NSArray *) linesArr myDict:(NSDictionary *)myDict;


// 我 当前点的对端点 是不是也是把山点?
- (NSDictionary *) isHaveJurisdictionHandle:(NSArray *)linesArr
                                  pointData:(NSArray *)pointArr
                        myLineFacePointDict:(NSDictionary *)myDict;




// 验证起始或终止设备 是否在路由上
- (BOOL) isStartEndDevice_IsInRoute:(NSArray *) linesArr deviceDict:(NSDictionary *) deviceDict;




// 当撤缆时调用 , 哪个资源点应该是我撤缆结束后 , 变为新的选中状态的资源点呢?
- (NSString *) whosAnnoIsMySelectNext:(NSArray *) linesArr myId:(NSString *) myId;



// resType 转 eqpTypeId
- (id) resType_To_EqpTypeId:(NSString *)resType;




// 穿缆时 配置起始终止Id们
- (NSArray *) putCableRouteWith:(NSDictionary *)cableDict ;



@end

NS_ASSUME_NONNULL_END
