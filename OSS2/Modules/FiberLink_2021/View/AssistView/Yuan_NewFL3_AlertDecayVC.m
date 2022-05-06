//
//  Yuan_NewFL3_AlertDecayVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2022/4/8.
//  Copyright © 2022 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_NewFL3_AlertDecayVC.h"
#import "Yuan_NewFL_VM.h"
@interface Yuan_NewFL3_AlertDecayVC ()

/** 标题 */
@property (nonatomic , strong) UILabel * titleLab;

/** 关闭按钮 */
@property (nonatomic , strong) UIButton * cancelBtn;

/** line */
@property (nonatomic , strong) UIView * lineA;

/** 衰耗数值 */
@property (nonatomic , strong) UILabel * decayTitle;

/** textField */
@property (nonatomic , strong) UITextField * decayTextField;

/** line */
@property (nonatomic , strong) UIView * lineB;

/** 确认分解 */
@property (nonatomic , strong) UIButton * finishBtn;

@end

@implementation Yuan_NewFL3_AlertDecayVC
{
    
    Yuan_NewFL_VM * _VM;
    
    UIView * _bgView;
    
    NSString * _textValue;
    
    NSArray * _dataArr;
}
#pragma mark - 初始化构造方法

- (instancetype)initWithArray:(NSArray *) dataArr {
    
    if (self = [super init]) {
        
        _dataArr = dataArr;
        _VM = Yuan_NewFL_VM.shareInstance;
    }
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self UI_Init];
    
}


#pragma mark - btnClick ---

- (void) cancelClick {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 确认分解
- (void) finishClick {
    
    if (_decayTextField.text.length == 0) {
        [YuanHUD HUDFullText:@"不能为空"];
        return;
    }
    
    NSMutableArray * fiberIdsArr = NSMutableArray.array;
    NSMutableArray * cableIdsArr = NSMutableArray.array;
    
    for (NSDictionary * linkData in _dataArr) {
        
        
        if ([linkData.allKeys containsObject:@"eptTypeId"]) {
            
            if ([linkData[@"eptTypeId"] isEqualToString:@"702"]) {
                
                [fiberIdsArr addObject:linkData[@"eptId"]];
                [cableIdsArr addObject:linkData[@"relateResId"]];
            }
            
            else if ([linkData[@"eptTypeId"] isEqualToString:@"731"]) {
                
                for (NSDictionary * routeDict in linkData[@"optLogicRouteList"]) {
                    
                    if ([routeDict[@"nodeTypeId"] isEqualToString:@"702"]) {
                        
                        [fiberIdsArr addObject:routeDict[@"nodeId"]];
                        [cableIdsArr addObject:routeDict[@"rootId"]];
                    }
                    else {
                        continue;
                    }
                }
            }
            
        }
        
        else if ([linkData.allKeys containsObject:@"nodeTypeId"]) {
            
            if ([linkData[@"nodeTypeId"] isEqualToString:@"702"]) {
                
                [fiberIdsArr addObject:linkData[@"nodeId"]];
                [cableIdsArr addObject:linkData[@"rootId"]];
            }
            
            else if ([linkData[@"nodeTypeId"] isEqualToString:@"731"]) {
                
                for (NSDictionary * routeDict in linkData[@"optLogicRouteList"]) {
                    
                    if ([routeDict[@"nodeTypeId"] isEqualToString:@"702"]) {
                        
                        [fiberIdsArr addObject:routeDict[@"nodeId"]];
                        [cableIdsArr addObject:routeDict[@"rootId"]];
                    }
                    else {
                        continue;
                    }
                }
            }
            
        }
        
        else {
            continue;
        }
        
        
    }
    
    
    
    
    NSDictionary * postDict = @{
        @"cableIds" : cableIdsArr,
        @"fiberIds" : fiberIdsArr,
        @"value" : _decayTextField.text
    };
    
    
    [Yuan_NewFL_HttpModel Http3_DecayPortDict:postDict
                                      success:^(id result) {
        
        [YuanHUD HUDFullText:@"修改成功"];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }];
}


#pragma mark - UI_Init

- (void) UI_Init {
    
    _bgView = [UIView viewWithColor:UIColor.whiteColor];
    [_bgView cornerRadius:5 borderWidth:0 borderColor:nil];
    
    _titleLab = [UIView labelWithTitle:@"衰耗分解" frame:CGRectNull];
    _titleLab.font = Font_Bold_Yuan(16);
    
    _cancelBtn = [UIView buttonWithImage:@"icon_guanbi"
                               responder:self
                               SEL_Click:@selector(cancelClick)
                                   frame:CGRectNull];
    
    _lineA = [UIView viewWithColor:UIColor.f2_Color];
    _lineB = [UIView viewWithColor:UIColor.f2_Color];
    
    _decayTitle = [UIView labelWithTitle:@"衰耗数值" frame:CGRectNull];
    _decayTitle.textColor = UIColor.lightGrayColor;
    _decayTitle.font = Font(12);
    
    _decayTextField = [UIView textFieldFrame:CGRectNull];
    _decayTextField.keyboardType = UIKeyboardTypeDecimalPad;
    
    UILabel *paddingView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 25)];
    paddingView.text = @"db ";
    paddingView.textColor = [UIColor darkGrayColor];
    paddingView.backgroundColor = [UIColor clearColor];
    _decayTextField.rightView = paddingView;
    _decayTextField.rightViewMode = UITextFieldViewModeAlways;
    _decayTextField.placeholder = @"请添加衰耗数值";
    [_decayTextField cornerRadius:5 borderWidth:1 borderColor:UIColor.f2_Color];
    
    
    _finishBtn = [UIView buttonWithTitle:@"确认分解"
                               responder:self
                                     SEL:@selector(finishClick)
                                   frame:CGRectNull];
    
    [_finishBtn setTitleColor:UIColor.mainColor forState:0];
    
    [self.view addSubview:_bgView];
    
    [_bgView addSubviews:@[_titleLab,
                           _cancelBtn,
                           _lineA,_lineB,
                           _decayTitle,
                           _decayTextField,
                           _finishBtn]];
    
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(15);
    
    [_bgView YuanAttributeHorizontalToView:self.view];
    [_bgView YuanAttributeVerticalToView:self.view];
    [_bgView Yuan_EdgeWidth:ScreenWidth / 4 * 3];
    [_bgView Yuan_EdgeHeight:Vertical(180)];
    
    [_titleLab YuanAttributeVerticalToView:_bgView];
    [_titleLab YuanToSuper_Top:limit];
    
    [_cancelBtn YuanToSuper_Right:limit];
    [_cancelBtn YuanToSuper_Top:limit];
    
    [_lineA YuanToSuper_Left:0];
    [_lineA YuanToSuper_Right:0];
    [_lineA Yuan_EdgeHeight:1];
    [_lineA YuanMyEdge:Top ToViewEdge:Bottom ToView:_titleLab inset:limit];
    
    [_decayTitle YuanToSuper_Left:limit];
    [_decayTitle YuanMyEdge:Top ToViewEdge:Bottom ToView:_lineA inset:limit];
    
    [_decayTextField YuanToSuper_Left:limit];
    [_decayTextField YuanToSuper_Right:limit];
    [_decayTextField Yuan_EdgeHeight:Vertical(40)];
    [_decayTextField YuanMyEdge:Top ToViewEdge:Bottom ToView:_decayTitle inset:3];
    
    
    [_lineB YuanToSuper_Left:0];
    [_lineB YuanToSuper_Right:0];
    [_lineB Yuan_EdgeHeight:1];
    [_lineB YuanMyEdge:Top ToViewEdge:Bottom ToView:_decayTextField inset:limit];
    
    
    [_finishBtn YuanAttributeVerticalToView:self.view];
    [_finishBtn YuanToSuper_Bottom:limit];
    [_finishBtn YuanMyEdge:Top ToViewEdge:Bottom ToView:_lineB inset:limit];
    
    
    
}

@end
