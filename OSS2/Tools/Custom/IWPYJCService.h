//
//  IWPYJCService.h
//  javaScript_ObjectC
//
//  Created by yuanquan on 2022/4/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IWPYJCService : NSObject

/**
 获取非空值
 
 @param needToUse 想要显示的内容
 @param other 备选内容
 @return 不为空的值，若两者均为空则返回nil
 */
extern id AnyObject(id needToUse, id other);

/**
 推出控制器
 
 @param self 誰
 @param bePush 推誰
 */
extern void Push(__kindof UIViewController * self, __kindof UIViewController * bePush);

/**
 返回上一個控制器
 
 @param poper 誰
 */
extern void Pop(__kindof UIViewController * poper);

/**
 彈出控制器
 
 @param presenter 誰
 @param bePresent 彈誰
 */
extern void Present(__kindof UIViewController * presenter, __kindof UIViewController * bePresent);


extern CLLocationCoordinate2D CoordinateFromNSString(NSString * str);

extern UITableView * TableView(id<UITableViewDataSource, UITableViewDelegate> delegate, UITableViewStyle style);

extern NSString * NSStringFromCoordinate(CLLocationCoordinate2D coordinate);

extern id LoadJSONFile(NSString * fileName);



/** 基本连接 **/
extern NSString * BaseURL_Auto(NSString * link);
/** 模板下载连接 **/
extern NSString * DOWNLOAD_LINK_Auto(NSString * link);
/** OLT模板连接 **/
extern NSString * EqutProps_Download_Link_Auto(NSString * link);
/** 上传照片 **/
extern NSString * BaseURLNoUp_Auto(NSString * link);
/** 下载照片 **/
extern NSString * BasePhotoURL_Auto(NSString * link);
/** 菜单页文件下载地址 **/
extern NSString * MenuProps_MainPage_Download_Link_Auto(NSString * link);
/** 菜单界面配置文件下载地址 **/
extern NSString * MenuProps_Download_Link_Auto(NSString * link);

extern UIColor * HexColor(NSString * temp);
extern UIFont * Font(CGFloat size);
@end

NS_ASSUME_NONNULL_END
