//
//  StationSelectResultViewController.h
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/10/25.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//
#import "Inc_BaseVC.h"
#import "ptotocolDelegate.h"
@protocol StationSelectResultTYKViewControllerDelegate <NSObject>
@optional
-(void)deviceWithDict:(NSDictionary *)dict withSenderTag:(NSInteger)senderTag;
@end
@interface StationSelectResultTYKViewController : Inc_BaseVC<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) UITableView *stationTableView;
@property (strong, nonatomic) NSMutableArray *stationArray;//获取到的资源信息列表
@property (copy, nonatomic) NSString *backStr;//返回的信息
@property (nonatomic, weak) id <StationSelectResultTYKViewControllerDelegate> delegate;

@property (nonatomic, copy) NSString * startOREndDevice_Key;
@property (nonatomic, copy) NSString * startOREndDevice_Id;
@property (nonatomic, assign) NSInteger senderTag;
@property (strong, nonatomic) NSString *fileName;//需要查询的资源类型

/** 显示名称 */
@property (nonatomic ,copy)  NSString *showName;

@property (assign,nonatomic)NSString *doType;//操作类型

/**
 2017年04月28日 新增 杆路段、管道段、标石段，起始终止设施内部查询key
 */
@property (nonatomic, copy) NSString * ssDeviceKey;

/**
 ------------------------------------------------------Id
 */
@property (nonatomic, copy) NSString * ssDeviceId;




/// 袁全新增 构造方法 , 用于楼宇
- (instancetype) initWithBulid_ODBBlock:(void(^)(NSDictionary * cableMsg))block;



/// 当选择所属设备后 , 再去选择ODB
- (instancetype) initWithBulid_EquipmentPointTo_ODF:(NSDictionary *)equipmentPointDict
                                            Block:(void(^)(NSDictionary * odfBlock))odf_BackBlock;


/// 袁全新增 构造方法 , 通用回调
- (instancetype) initWithResLogicName:(NSString *)resLogicName
                                Block:(void(^)(NSDictionary * cableMsg))block;






@end
