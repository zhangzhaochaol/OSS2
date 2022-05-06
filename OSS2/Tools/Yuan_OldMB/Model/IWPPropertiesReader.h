//
//  IWPPropertiesReader.h
//  Properties
//
//  Created by 王旭焜 on 2016/5/30.
//  Copyright © 2016年 王旭焜. All rights reserved.
//

#import "INCBaseModel.h"
@class IWPPropertiesSourceModel;
@class IWPViewModel;


@interface IWPPropertiesReader : NSObject
@property (nonatomic, assign) IWPPropertiesReadDirectoryRef readType;
/**
 *  本地文件初始化
 *
 *  @param fileName 文件路徑
 *
 *  @return self
 */
-(instancetype)initWithFileName:(NSString *)fileName withFileDirectoryType:(IWPPropertiesReadDirectoryRef)directoryType;
+(instancetype)propertiesReaderWithFileName:(NSString *)fileName withFileDirectoryType:(IWPPropertiesReadDirectoryRef)directoryType;
-(instancetype)initWithMD5FileName:(NSString *)fileName withFileDirectoryType:(IWPPropertiesReadDirectoryRef)directoryType;
+(instancetype)propertiesReaderWithMD5FileName:(NSString *)fileName withFileDirectoryType:(IWPPropertiesReadDirectoryRef)directoryType;
/**
 *  網絡文件初始化
 *
 *  @param url 文件地址
 *
 *  @return self
 */
- (instancetype)initWithURL:(NSString *)url;
+ (instancetype)proertiesReaderWithURL:(NSString *)url;
- (instancetype)initWithMD5FileURL:(NSString *)url;
+ (instancetype)proertiesReaderWithMD5FileURL:(NSString *)url;
//- (void)readFile:(NSString *)fileName withDirectoryType:(IWPPropertiesReadDirectoryRef)directoryType;

-(NSDictionary *)result;
-(IWPPropertiesSourceModel *)mainModel;
-(NSArray <IWPViewModel *>*)viewModels;
-(NSDictionary *)md5Check;



/**
 获取模板文件最新资源列表
 */
+ (NSArray *)newEqutPropsFileList;

+ (BOOL)isHasRetion:(NSString *)fileName;

+ (BOOL)isHasCoordinate:(NSString *)fileName;
+(NSArray *)getMainNewFileList;

/**
 2017年05月04日 修改常规模板文件更新检查获取更新项

 @return 新文件列表
 */
+ (NSArray *)newFileList;
@end

@interface IWPPropertiesSourceModel : INCBaseModel

/**
 是否载入成功
 */
@property (nonatomic, assign) BOOL loaded;
/**
 名称
 */
@property (nonatomic, copy) NSString * name;

/**
 修改接口
 */
@property (nonatomic, copy) NSString * update_name;

/**
 新增接口
 */
@property (nonatomic, copy) NSString * insert_name;

/**
 删除接口
 */
@property (nonatomic, copy) NSString * delete_name;

/**
 搜索接口
 */
@property (nonatomic, copy) NSString * get_name;

/**
 搜索提示文字
 */
@property (nonatomic, copy) NSString * list_sreach_text;

/**
 搜索关键字Key
 */
@property (nonatomic, copy) NSString * list_sreach_name;

/**
 列表标题文字key
 */
@property (nonatomic, copy) NSString * list_item_title_name;

/**
 列表副标题文字key
 */
@property (nonatomic, copy) NSString * list_item_note_name;

/**
 保存按钮标题
 */
@property (nonatomic, copy) NSString * btnVi_Save;

/**
 删除按钮标题
 */
@property (nonatomic, copy) NSString * btnVi_Delete;

/**
 拍照按钮标题
 */
@property (nonatomic, copy) NSString * btnVi_Photo;

/**
 经度
 */
@property (nonatomic, copy) NSString * lon;

/**
 纬度
 */
@property (nonatomic, copy) NSString * lat;

/**
 所属局站名称
 */
@property (nonatomic, copy) NSString * areaName;

/**
 所属局站ID
 */
@property (nonatomic, copy) NSString * areaNo;

/**
 所属机房名称
 */
@property (nonatomic, copy) NSString * generatorName;

/**
 所属机房ID
 */
@property (nonatomic, copy) NSString * generatorId;
@property (nonatomic, copy) NSString * maintenanceAreaName;

/**
 拼名公式
 */
@property (nonatomic, copy) NSString * subName;

/**
 拼名编辑框是否可编辑，为1时可编辑，为空或为0时不可编辑
 */
@property (nonatomic, copy) NSString * subNameEditable;

/**
 cell侧滑按钮标题
 */
@property (nonatomic, copy) NSString * get_text_name_1;
@property (nonatomic, copy) NSString * list_item_id;

/**
 详情页views数组
 */
@property (nonatomic, strong) NSArray * view;

/**
 cell侧滑接口文件
 */
@property (nonatomic, copy) NSString * get_bean_name_3;

/**
 cell侧滑内容key
 */
@property (nonatomic, copy) NSString * get_field_name_3;
@property (nonatomic, copy) NSString * get_text_name_2;
@property (nonatomic, copy) NSString * get_field_name_1;
@property (nonatomic, copy) NSString * get_text_name_3;
@property (nonatomic, copy) NSString * get_btn_Vi_3;
@property (nonatomic, copy) NSString * get_btn_Vi_2;
@property (nonatomic, copy) NSString * get_btn_Vi_1;

/**
 其它按钮是否使用
 */
@property (nonatomic, copy) NSString * btn_Other;

/**
 其它按钮标题
 */
@property (nonatomic, copy) NSString * btn_Other_Title;

/**
 其它按钮是否使用2
 */
@property (nonatomic, copy) NSString * btn_Other2;

/**
 其它按钮标题2
 */
@property (nonatomic, copy) NSString * btn_Other_Title2;



/**
 其它按钮是否使用2
 */
@property (nonatomic, copy) NSString * btn_Other3;

/**
 其它按钮标题2
 */
@property (nonatomic, copy) NSString * btn_Other_Title3;


@property (nonatomic, copy) NSString * btn_Other3_BeanName;



/**
 其它按钮是否使用4
 */
@property (nonatomic, copy) NSString * btn_Other4;

/**
 其它按钮标题4
 */
@property (nonatomic, copy) NSString * btn_Other_Title4;


@property (nonatomic, copy) NSString * btn_Other4_BeanName;



/**
 其它按钮点击key
 */
@property (nonatomic, copy) NSString * btn_Other2_BeanName;
@property (nonatomic, copy) NSString * get_bean_name_1;
@property (nonatomic, copy) NSString * get_field_name_2;
@property (nonatomic, copy) NSString * get_bean_name_2;
 


// 構造方法
- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)modelWithDict:(NSDictionary *)dict;
@end


@interface IWPViewModel : INCBaseModel

/**
 label标题
 */
@property (nonatomic, copy) NSString * tv1_Text;

/**
 是否必填
 */
@property (nonatomic, copy) NSString * tv1_Required;

/**
 key1
 */
@property (nonatomic, copy) NSString * name1;

/**
 key2
 */
@property (nonatomic, copy) NSString * name2;

/**
 key4
 */
@property (nonatomic, copy) NSString * name4;

/**
 key3
 */
@property (nonatomic, copy) NSString * name3;

/**
 视图type
 */
@property (nonatomic, copy) NSString * type;

/**
 编辑框1是否可编辑
 */
@property (nonatomic, copy) NSString * ed1_Ed;

/**
 编辑框1placeholder
 */
@property (nonatomic, copy) NSString * ed1_Hint;

/**
 编辑框2是否可编辑
 */
@property (nonatomic, copy) NSString * ed2_Ed;

/**
 编辑框2placeholder
 */
@property (nonatomic, copy) NSString * ed2_Hint;

/**
 pickerView文字列表
 */
@property (nonatomic, copy) NSString * sp_text;

/**
 按钮标题
 */
@property (nonatomic, copy) NSString * btn1_text;


/**
 按钮2标题
 */
@property (nonatomic, copy) NSString * btn2_text;
/**
 lebel1标题
 */
@property (nonatomic, copy) NSString * text1;

/**
 起始终止设备获取时用到的相关内容，包括名称key、idkey、文件名
 */
@property (nonatomic, copy) NSString * temp_text;

/**
 lebel2标题
 */
@property (nonatomic, copy) NSString * text2;


// 構造方法
- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)modelWithDict:(NSDictionary *)dict;


@end
