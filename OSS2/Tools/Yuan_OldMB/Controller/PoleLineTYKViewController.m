//
//  PoleLineTYKViewControllerViewController.m
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/9/29.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "PoleLineTYKViewController.h"
#import "IWPPropertiesReader.h"
@interface PoleLineTYKViewController ()

@end

@implementation PoleLineTYKViewController

{
    NSString * TYKNew_fileName;  //统一库新增了 UNI_前缀的 fileName ; 袁全添加--
    
}

-(instancetype)initWithControlMode:(TYKDeviceListControlTypeRef)controlMode withMainModel:(IWPPropertiesSourceModel *)model withViewModel:(NSArray<IWPViewModel *> *)viewModel withDataDict:(NSDictionary *)dict withFileName:(NSString *)fileName{
    
    TYKNew_fileName = [NSString stringWithFormat:@"UNI_%@",fileName];
    
    NSArray * views = [NSArray arrayWithArray:[[IWPPropertiesReader propertiesReaderWithFileName:TYKNew_fileName withFileDirectoryType:IWPPropertiesReadDirectoryDocuments] viewModels]];
    
    NSMutableArray * newArr = [views mutableCopy];
    IWPViewModel * viewModelnew = [[IWPViewModel alloc] init];
    viewModelnew.tv1_Required = @"1";
    viewModelnew.tv1_Text = @"杆路名称";
    viewModelnew.type = @"50";
    viewModelnew.name1 = @"poleLineName";
    viewModelnew.ed1_Ed = @"1";
    viewModelnew.ed1_Hint = @"请获取";
    viewModelnew.btn1_text = @"获取";
    [newArr insertObject:viewModelnew atIndex:0];
    
    
    if (self = [super initWithControlMode:controlMode withMainModel:model withViewModel:newArr withDataDict:dict withFileName:fileName]) {
        
    }
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
