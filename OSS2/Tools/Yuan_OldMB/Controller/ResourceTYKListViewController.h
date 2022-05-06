//
//  ResourceTYKListViewController.h
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/6/28.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//


@protocol TYKDeviceInfomationDelegate;
@protocol ptotocolDelegate;

@interface ResourceTYKListViewController : Inc_BaseVC  <ptotocolDelegate>
@property (nonatomic,copy)NSString *fileName;// 文件名
@property (nonatomic,copy)NSString *showName;// 中文名
@property (nonatomic,strong)NSDictionary *dicIn;// 传过来的上级信息

@property (nonatomic, copy) NSString * sourceFileName; // 路由展现 - 来源文件名


/** tube 管孔时 , 如果是从子孔进入的 ,保存时 会在requestDict中 新增 isFather = 2的字段*/
@property (nonatomic ,assign) BOOL isNeed_isFather;
/** 管孔的父id */
@property (nonatomic ,copy)  NSString *fatherPore_Id;




/// 袁全新增 构造方法 , 用于智能判障
- (instancetype) initWithSearchTitle:(NSString *)title
                            blockMsg:(void(^)(NSDictionary * cableMsg))block;


/// 袁全新增 构造方法 , 用于楼宇
- (instancetype) initWithBulid_ODBBlock:(void(^)(NSDictionary * cableMsg))block;


//zzc 2021-9-17 选择列表某条数据回调  目前横向拆分使用
@property (nonatomic, copy) void (^facilitiesBlock)(NSDictionary *dic);

@end
