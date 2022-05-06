//
//  CableTYKViewController.m
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/7/25.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "CableTYKViewController.h"
#import "IWPPropertiesReader.h"
@interface CableTYKViewController ()

@end

@implementation CableTYKViewController

{
    NSString * TYKNew_fileName;  //统一库新增了 UNI_前缀的 fileName ; 袁全添加--
}


-(instancetype)initWithControlMode:(TYKDeviceListControlTypeRef)controlMode withMainModel:(IWPPropertiesSourceModel *)model withViewModel:(NSArray<IWPViewModel *> *)viewModel withDataDict:(NSDictionary *)dict withFileName:(NSString *)fileName{
    
    TYKNew_fileName = [NSString stringWithFormat:@"UNI_%@",fileName];
    
    NSMutableArray * newArr = [viewModel mutableCopy];
    
    model.btn_Other2 = @"1";
    model.btn_Other_Title2 = @"标签";
    model.btn_Other2_BeanName = @"rfidInfo";
    
    self = [super initWithControlMode:controlMode withMainModel:model withViewModel:newArr withDataDict:dict withFileName:fileName];
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
