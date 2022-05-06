//
//  Inc_ImageCheckNewVC.h
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/8/10.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"
#import "Inc_BusDeviceView.h"
#import "Yuan_terminalBtn.h"

NS_ASSUME_NONNULL_BEGIN

@interface Inc_ImageCheckNewVC : Inc_BaseVC

- (instancetype)initWithImage:(UIImage *) image
                        Array:(NSArray *) arr ;


// 赋值
- (void) configDatasArray:(NSArray *) txtCoordinated
                imgBase64:(NSString *) img
                   matrix:(NSArray *) matrix;

/** 数据 */
@property (nonatomic , copy) NSArray * datas;

/** 模板dict */
@property (nonatomic , copy) NSDictionary * mb_Dict;

/** 行内端子个数 */
@property (nonatomic , assign) NSInteger inLineNums;

/** 行数 */
@property (nonatomic , assign) NSInteger hangNum;

/** 列数 */
@property (nonatomic , assign) NSInteger lieNum;

/** 行优还是列优 */
@property (nonatomic , assign) BOOL isHang;

/** 行优还是列优 */
@property (nonatomic , assign) Important_ importRuler;

/** 左上右下 */
@property (nonatomic , assign) Direction_ dire;

/** <#注释#> */
@property (nonatomic , copy) NSDictionary * pieDict;


/** <#注释#>  block */
@property (nonatomic , copy) void (^reloadWithPie) (void);

// 存放所有端子的Array
@property (nonatomic, strong)  NSArray < Yuan_terminalBtn *> * btnsArray;

@end


NS_ASSUME_NONNULL_END
