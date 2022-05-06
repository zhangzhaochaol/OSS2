//
//  Yuan_CFConfigVM.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/21.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN




typedef NS_ENUM(NSUInteger, CF_VM_FiberLocation_) {
    CF_VM_FiberLocation_up = 0 ,
    CF_VM_FiberLocation_down = 1,
    CF_VM_FiberLocation_unknow = 2
};


typedef NS_ENUM(NSUInteger, CF_VC_StartOrEndType_) {
    CF_VC_StartOrEndType_Start ,    //从 '起始' 设备进入  不论成端还是熔接
    CF_VC_StartOrEndType_End        //从 '终止' 设备进入  不论成端还是熔接
};


@interface Yuan_CFConfigVM : NSObject


+ (Yuan_CFConfigVM *)shareInstance;


/**
 从列表页 进入详情页 , 我是从起始设备进入 还是从终止设备进入的?
 Yuan_CFListHeader 里设置的
 */
@property (nonatomic ,assign) CF_VC_StartOrEndType_ startOrEnd;


/** 光缆段模板传过来的Dict */
@property (nonatomic,strong) NSDictionary *moBan_Dict;


/** 第一个网络请求回来的数据 , 赋值给viewModel */
@property (nonatomic,strong) NSArray *WDW_Port_Array;




/**
    Z端 对端的GID , (注释:resZEqp_Id A端是指moBan_Dict里的GID 也就是光缆段ID)
    
    如果Z端是成端的话 , resZEqp_Id  == startOrEndDevice_Id
    如果Z端是熔接 (光缆接头) 的话 , 还需要进一步选择对应的光缆段ID 给 resZEqp_Id 赋值
 
 */
@property (nonatomic ,copy)  NSString *resZEqp_Id;



/**
    保存接口使用 GID, 如果是起始设备 就赋值起始设备ID , 终止设备就赋值终止设备ID
 */
@property (nonatomic ,copy , readonly)  NSString *startOrEndDevice_Id;


/** 纤芯配置界面的 type  是成端模块 还是 熔接模块 */
@property (nonatomic ,assign) CF_HeaderCellType_ configVC_type;


/** 熔接模式下 , 光缆段列表对应的 光缆段资源数组 , 如果请求过了就不要在请求了 */
@property (nonatomic,strong) NSMutableArray *connect_LazyLoad_DataSource;


/** 成端模式下 , odf对应的 资源数组 , 懒加载 */
@property (nonatomic,strong) NSMutableArray *ODF_LazyLoad_DataSource;



// *****  *****  *****  *****  *****  *****  *****  *****  *****  *****

// 把网络请求回来的纤芯list 拆分成三个数组
// 1. 所有纤芯的数组 ,  2. 所有 和起始设备相关的数组  3. 所有和终止设备相关的数组

/** 拆分处理的纤芯数组  用于验证和判断 */
@property (nonatomic,strong , readonly) NSMutableArray *allXianXinArray;


/** 拆分处理的和起始设备相关的数组  用于验证和判断 */
@property (nonatomic,strong, readonly) NSMutableArray *allStartDeviceArray;


/** 拆分处理的和终止设备相关的数组  用于验证和判断 */
@property (nonatomic,strong, readonly) NSMutableArray *allEndDeviceArray;



/// 拆分数组的方法
/// @param listArray httpListArray
- (void) clearUpToArrays:(NSArray *)listArray;




// *****  *****  *****  *****  *****  *****  *****  *****  *****  *****

/** 纤芯配置时  上方光缆段内部纤芯的 选中的dict (每次配对以后 清空) 下次选中时赋值 */
@property (nonatomic,strong ) NSDictionary *baseLinkDict;


/** 纤芯配置时 , 或是成端的ODF对应的端子dict ,
    或是熔接时,对象光缆段的纤芯的dict (每次配对以后 清空) 下次选中时赋值
 暂时不用
 */
@property (nonatomic,strong) NSDictionary *otherLinkDict;



/** 所有关联 待保存的map组成的一个等待上传的大数组
    
    里面的对象是 baseLinkDict 和 otherLinkDict 以某种形式结合的新map
 
    当保存成功时 !! 和 退出CFConfigController控制器时 清空 !!
 */
@property (nonatomic,strong) NSMutableArray *linkSaveHttpArray;




/** 当前我选择的 我这个光缆段下的纤芯Id 每次组成map add进 linkSaveHttpArray后 置niu*/
@property (nonatomic ,copy , nullable)  NSString *baseLink_FiberId;


/**
    选择了 baseLink_FiberId 后 , 才能给 otherLink_FiberOrTerminalID 赋值
    
 一定要判断先后顺序 , 一定要先赋值 baseLink_FiberId 后 才能 赋值 otherLink_FiberOrTerminalID
   在组成map后 置为nil .
 
 */
@property (nonatomic ,copy , nullable)  NSString *otherLink_FiberOrTerminalID;





/** 声明 绑定成功后 刷新collection的UI , 让选中的纤芯变为绿色 , 下一个纤芯变为红色 的block */
@property (nonatomic ,copy) void(^viewModel_Block_ReloadConfigListCollection)(void);


- (void) viewModel_NotiConfigController_ReloadTheCollection;




/** 声明 保存回调 刷新页面的 的block */
@property (nonatomic ,copy) void(^viewModel_Block_ReloadHttp)(void);


- (void) viewModel_NotiListControllerReloadHttp;







#pragma mark -  关于长按  ---

/** 需要循环调用的次数  listConllectionView.index_row 和 _dataSource.count 的关系 */
@property (nonatomic ,assign) NSInteger for_Circle_Count;


/** 声明 通知 开始长按事件啦  的block */
@property (nonatomic ,copy) void(^viewModel_for_Circle_Block)(NSInteger tapIndex , NSInteger position);



/// 执行长按事件的view 通知其上层view , 进行长按循环事件
- (void) viewModel_Notification_forCircleClick:(NSInteger) index
                                      position:(NSInteger )position;


// **** ****  **** ****  **** ****  **** ****  **** ****

/*
    @{
        type --  @"1" : 代表成端   @"2" : 代表熔接
        location --  @"1" : 代表左上   @"2" 代表右下
    }
 */
/// 根据纤芯的单个Dict 判断应该显示在左上右下 是成端还是熔接
/// @param fiberDict 纤芯dict
- (NSDictionary *) viewModelFiberTypeAndLocationFromDict:(NSDictionary *) fiberDict
                                                  pairId:(NSString *)pairId;



/*
    获取起始和终止设备Id  Id是不区分 熔接还是成端的 只要Id 熔接成端自己去判断
    获取起始和终止设备名称
 */
- (NSString *) viewModel_GetStartDeviceId;
- (NSString *) viewModel_GetEndDeviceId;



- (NSString *) viewModel_GetStartDeviceName;
- (NSString *) viewModel_GetEndDeviceName;


#pragma mark -  关于端子盘内所有btn的集合  ---

/** 所有端子按钮的集合 , 当切换框的时候 , 需要清空该集合 */
@property (nonatomic,strong) NSMutableArray *terminalBtnArray;

/** 所有熔接 item的集合 , 当退出控制器时需要清空 */
@property (nonatomic,strong) NSMutableArray *connectionItemArray;







#pragma mark -  新增 长按   ---

/// 通知 准备手动配置了


typedef NS_ENUM(NSUInteger, CF_ConfigHandle_) {
    CF_ConfigHandle_None ,      //没有事件
    CF_ConfigHandle_Setting  , //正在手动配置中 , 等待下一个点击时 响应
    CF_ConfigHandle_NOSelectClick,  //不给纤芯点击事件
};


/**
 手动配置状态
 Yuan_CFConfigController.m 退出时 会清为 None
 */
@property (nonatomic ,assign) CF_ConfigHandle_ handleConfig_State;


/** 声明 通知 开始长按_手动配置事件啦  的block */
@property (nonatomic ,copy) void(^viewModel_for_HandleConfig_Block)(NSInteger tapIndex);



/** 声明 通知 开始长按_手动配置事件啦  的block */
@property (nonatomic ,copy) void(^viewModel_for_HandleConfig_END_Block)(NSInteger tapIndex);




/// 手动配置 '成端' '熔接' 时 先存下当前点击的按钮的值 , 再点击一个按钮时  校验
/// @param index 当前长按的对象 在对应资源数组中的位置
- (void) Notification_HandleConfigWithNowIndexFromResArray:(NSInteger)index;



/// 手动配置结束时点击的按钮的位置
- (void) Notification_HandleConfigEndIndexFromResArray:(NSInteger)endIndex;




/** 用于储存关联关系的数组 */
@property (nonatomic ,copy)  NSArray *termIds_Arr;

/** 当前光缆段的全部纤细Id */
@property (nonatomic ,copy)  NSArray *fiberIds_Arr;

/** 和其他光缆段纤芯成端的端子Id们 */
@property (nonatomic,strong) NSMutableArray *AnotherCableConfigTermIds_Arr;




/** 2020.12.15新增 是否是楼宇模式 ? 楼宇模式 不使用长按功能 */
@property (nonatomic ,assign) BOOL isBuildingMode;


/** 构造器4 对应的是无绑卡数字 , 无端子position数字  只有 占 和 闲 两个状态 */
@property (nonatomic , assign) BOOL isInitType_4_Mode;


@end

NS_ASSUME_NONNULL_END
