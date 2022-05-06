//
//  Yuan_CFConfigModel.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/21.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_CFConfigModel : BaseModel



/// 先把数据拆分成三个 数组 , 1. 纤芯数组 2.连接所有起始设备的数组 3. 连接所有终止设备的数组
- (void) clearUpToArrays:(NSArray *)listArray ;




/// 获取单个数据源
/// @param GID 当前选中的纤芯的ID 上边 collectionItem 对应的 ID
/// @param linkId_resBID 下边选中的 端子 或 纤芯的ID 
- (NSMutableDictionary *) saveSingleDictWithFiberID:(NSString * _Nonnull)GID
                                             LinkID:(NSString *)linkId_resBID;






/// 收集需要保持的数组 (单对单 选中的模式)
/// @param otherTerminalOrFiberDict 对端的map
/// 是否添加成功?
- (BOOL) joinSingleDictToLinkSaveHttpArray:(NSDictionary *)otherTerminalOrFiberDict
                                      type:(CF_HeaderCellType_)chengduan_Or_Rongjie;







/// 模板跳转前的map转型
/// @param wangDavieDict 王大为返回的list
- (NSDictionary *) wangDavieToLonggeMoBanDictChange:(NSDictionary *)wangDavieDict ;


@end

NS_ASSUME_NONNULL_END
