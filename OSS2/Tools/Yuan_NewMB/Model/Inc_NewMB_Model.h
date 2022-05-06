//
//  Inc_NewMB_Model.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/3/16.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

// 管理枚举
#import "Yuan_NewMB_Enum.h"

NS_ASSUME_NONNULL_BEGIN



@class Yuan_NewMB_ModelItem;
@interface Inc_NewMB_Model : NSObject



/// 根据资源配置新模板
/// @param modelEnum 新模板
- (instancetype)initWithEnum:(Yuan_NewMB_ModelEnum_) modelEnum;


// 获取对应的模板
- (NSArray <Yuan_NewMB_ModelItem *> *) model;



@end


@interface Inc_NewMB_HttpPort : NSObject


+ (instancetype) ModelEnum:(Yuan_NewMB_ModelEnum_) modelEnum;


/** 获取查询接口 */
@property (nonatomic , copy , readonly) NSString * Select;

/** 获取 根据Id和type 查询详细信息接口 */
@property (nonatomic , copy , readonly) NSString * SelectFrom_IdType;

/** 获取新增接口 */
@property (nonatomic , copy , readonly) NSString * Add;

/** 获取修改保存接口 */
@property (nonatomic , copy , readonly) NSString * Modifi;

/** 获取删除接口 */
@property (nonatomic , copy , readonly) NSString * Delete;



/** 获取设备类型 */
@property (nonatomic , copy , readonly) NSString * type;

/** 获取设备code编码 */
@property (nonatomic , copy , readonly) NSString * code;


@end



@interface Yuan_NewMB_ModelItem : BaseModel

/** title 标题  -- 汉字名字 */
@property (nonatomic , copy) NSString * title;

/** key 对应的传参字段  */
@property (nonatomic , copy) NSString * key;

/** value 上传时 key 对应的 value */
@property (nonatomic , copy) NSString * value;



/** 键盘类型
 nil    普通类型
 number 数组类型
 
 */
@property (nonatomic , copy) NSString * keyBoardType;



/** 当type6 或 type9 使用 目标Id 字段   对应模板 name2 */
@property (nonatomic , copy) NSString * targetResId;

/** 当type6 或 type8 使用 目标的 resLogicName  字段 对应模板 name3 */
@property (nonatomic , copy) NSString * targetResLogicName;

/** 当type6 或 type8 使用 目标的名称 字段 对应模板 name4 */
@property (nonatomic , copy) NSString * targetResName;





#pragma mark - 验证部分 ---
/** 需要验证 才能继续进行的 目前只属于 type 106 */
@property (nonatomic , copy) NSString * checkId;

/** 需要验证 才能继续进行的 目前只属于 type 106 */
@property (nonatomic , copy) NSString * checkTitle;

/** checkUsed 为 0 的话 就不启用 */
@property (nonatomic , copy) NSString * checkUsed;



/** 联动 id */
@property (nonatomic , copy) NSString * subResId;

/** 联动删除 */
@property (nonatomic , copy) NSString * subResName;




// *** *** *** *** *** *** *** *** *** *** *** ***

/** btn文字 */
@property (nonatomic , copy) NSString * btnTitle;


/** 可选数组  用于piker 下拉数据源*/
@property (nonatomic , copy , readonly) NSArray * optionsArr;

/** 可选数组的枚举值 , 用于发送和结束 */
@property (nonatomic , copy , readonly) NSArray * optionsEnumArr;

/** 自建的字段 , 代表着UI的类型 */
@property (nonatomic , copy  , readonly) NSString * type;


/** 是否是 重要词条 对应着 是否是红色标注 '*'
 0  非必填
 1  必填
 2  扫描二维码
 3  关联显示和隐藏 对应MC  - -  选中对应的字段时 ,为必选 选中非对应字段时,为非必须.  (暂未启用)
 */
@property (nonatomic , copy , readonly) NSString * required;

/** 是否是 可编辑的词条 0-1 */
@property (nonatomic , copy , readonly) NSString * edit;



#pragma mark - 只有当 require是3的时候 才会验证---

// *** *** *** 主动字段

/** 是否是主动字段  为1  */
@property (nonatomic , copy) NSString * haveRelate;



// *** *** *** 从动字段

/** 哪个字段的改变 , 会对我造成影响呢? */
@property (nonatomic , copy , readonly) NSString * relateKey;

/** 当这个字段选中哪个值的时候 , 才会对我造成影响 , 当前对数是 数值型枚举值 */
@property (nonatomic , copy , readonly) NSString * relateValue;


#pragma mark - type 10 的判断 ---

/** isMustFuture */
@property (nonatomic , copy) NSString * needFuture;


@end




NS_ASSUME_NONNULL_END
