//
//  Inc_NewMB_Item.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/3/15.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_NewMB_Item.h"
#import "Inc_NewMB_Model.h"
#import "Inc_NewMB_Presenter.h"
// 下拉框
#import "Yuan_TextFieldPicker.h"

// type10 日期选择
#import "Yuan_PickerView.h"

// 扫一扫
#import "IWPSaoMiaoViewController.h"

// 获取另一张表中的接口  -- gid 和 name  -- 仅type6使用
#import "Inc_NewMB_AssistListVC.h"

// 获取地图经纬度 -- Type 4
#import "Inc_NewMB_AssistMapVC.h"

// type9 走郑小英通用查询接口时使用 , 新版查询通用接口 id name 的列表
#import "Inc_NewMB_Type9_AssistListVC.h"

// 资源选择 需要 resLogicName
#import "Inc_Push_MB.h"


@interface Inc_NewMB_Item ()
<
    UITextViewDelegate ,
    UITextFieldDelegate
//    ptotocolDelegate
>


@end

@implementation Inc_NewMB_Item

{
    Inc_NewMB_Presenter * _presenter;
    UIViewController * _vc;
    
    
    // 对应模板数据
    Yuan_NewMB_ModelItem * _model;
    NSInteger _type;
    
    // 标题
    UILabel * _title;
    
    UIView * _backView;
    
    // 输入框
    UITextView * _textView;
    // 下拉框
    UITextField * _textField;
    
    Yuan_TextFieldPicker * _picker;
    
    
    // 按钮
    UIButton * _btn;
    
    // 特殊备注 , 当前仅纤芯使用
    UILabel * _specialNote;
    
    float limit;
    
    // 当前模板对应的map
    NSDictionary * _mbDict;
    
}

#pragma mark - 初始化构造方法


- (instancetype)initItemWithModel:(Yuan_NewMB_ModelItem *)model
                               vc:(UIViewController *)vc
                           mbDict:(NSDictionary *)mbDict{
    
    if (self = [super init]) {
        
        _mbDict = mbDict;
        _vc = vc;
        _myModel = _model = model;
        _presenter = Inc_NewMB_Presenter.presenter;
        [self UI_Init];
        
    }
    return self;
}


// UI搭建和屏幕适配
- (void) UI_Init {
    
    limit = Horizontal(10);
    
    NSInteger type = _model.type.integerValue;
    _type = type;
    
    
    // 先初始化
    [self BaseUI_Init];
    
    
    switch (type) {
        
        case 1:         //纯文字输入
            [self UI_Init_Type1];
            break;
         
        case 3:         //picker选择
            [self UI_Init_Type3];
            break;
            
        case 4:         //4 -- 获取经纬度
        case 6:         //按钮 + textView  UI状态 6和8都一样 , 但按钮的点击事件业务不太相同
        case 8:         //8 -- 所属维护区域
        case 9:         //9 -- 生产厂家
            [self UI_Init_Type6];
            break;
            
        case 10:        //时间选择器
            [self UI_Init_Type10];
            break;
            
        case 52:        //rfid
            [self UI_Init_Type52];
            break;
            
        default:
            break;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 (int64_t)(0.3 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),  ^{
        

        // textView 居中
        [self contentTextViewSizeToFit];
    });
        
    
}



#pragma mark - TypeView ---

/// type1 纯文字输入
- (void) UI_Init_Type1 {
        
    [_title YuanToSuper_Top:limit];
    [_title YuanToSuper_Left:limit];
    
    [_backView YuanToSuper_Left:limit];
    [_backView YuanToSuper_Right:limit];
    [_backView YuanToSuper_Bottom:limit + Vertical(3)];
    [_backView YuanMyEdge:Top ToViewEdge:Bottom ToView:_title inset:limit];
    
    
    [_textView YuanToSuper_Left:limit];
    [_textView YuanToSuper_Right:limit];
    [_textView YuanToSuper_Top:0];
    [_textView YuanToSuper_Bottom:0];
    
    [_specialNote YuanMyEdge:Top ToViewEdge:Bottom ToView:_backView inset:Vertical(2)];
    [_specialNote YuanToSuper_Left:limit];
    [_specialNote YuanToSuper_Bottom:0];
    
}


/// type3 picker 选择
- (void) UI_Init_Type3 {
    
    if (!_model.optionsArr) {
        return;
    }
    
    
    [_title YuanToSuper_Top:limit];
    [_title YuanToSuper_Left:limit];
    
    [_backView YuanToSuper_Left:limit];
    [_backView YuanToSuper_Right:limit];
    [_backView YuanToSuper_Bottom:limit];
    [_backView YuanMyEdge:Top ToViewEdge:Bottom ToView:_title inset:limit];
    
    
    [_textField YuanToSuper_Left:0];
    [_textField YuanToSuper_Right:0];
    [_textField YuanToSuper_Top:0];
    [_textField YuanToSuper_Bottom:0];
    _textField.backgroundColor = UIColor.whiteColor;
    
    
    // 下拉箭头
    UIImageView * img = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"yuanMB_xiala"]
                                           frame:CGRectNull];
    
    [_textField addSubview:img];
    
    [img YuanAttributeHorizontalToView:_textField];
    [img autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:Horizontal(15)];
    
    
    __typeof(self)weakSelf = self;
    // 确认按钮点击事件
    _picker.commitBlock = ^(NSInteger selectIndex) {
        [weakSelf type3_CommitIndex:selectIndex];
    };
    
    
}



- (void) type3_CommitIndex:(NSInteger) selectIndex {
    
    NSString * selectText = _model.optionsArr[selectIndex];
    NSString * selectEnum = _model.optionsEnumArr[selectIndex];
    
    _textField.text = selectText;
    
    
    if ([selectText isEqualToString:@"请选择"] || [selectEnum isEqualToString:@"-1"]) {
        
        // 传 nil , 让外部把这个key 移除掉
        [self value_GoBackPostDict:@{_model.key:NSNull.null}];
        return;
    }
    
    // type == 3 时修改值的回调 , 传的是枚举值
    [self value_GoBackPostDict:@{_model.key:selectEnum}];
    
    
    // 当是动态必选项时
    if ([_model.haveRelate isEqualToString:@"1"]) {
        
        
        if (self.delegate != NULL &&
            [self.delegate respondsToSelector:@selector(Yuan_NewMB_ReLoadAllItems)]) {
            
            [self.delegate Yuan_NewMB_ReLoadAllItems];
        }
    }
    
    
    // 如果 当前修改的 type3 有下属联动的关系 , 当变更type3时 , 下属联动要清空
    if (_model.subResId && _model.subResName) {
        
        NSDictionary * modifiDict = @{
            _model.key:_model.optionsEnumArr[selectIndex]
        };
        
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:modifiDict];
        
        if (_model.subResId && _model.subResName) {
            dict[_model.subResId] = @"";
            dict[_model.subResName] = @"";
        }
        
        
        // type == 6 时修改值的回调  需要刷新界面
        [self reload_Value_GoBackPostDict:dict];
    }
    
}




/// type6 按钮通过获取resLogicName 获取所属区域等数据 , 带回数据即可
- (void) UI_Init_Type6 {
    
    
    [_title YuanToSuper_Top:limit];
    [_title YuanToSuper_Left:limit];
    
    [_backView YuanToSuper_Left:limit];
    [_backView YuanToSuper_Right:limit];
    [_backView YuanToSuper_Bottom:limit];
    [_backView YuanMyEdge:Top ToViewEdge:Bottom ToView:_title inset:limit];
    
    
    [_textView YuanToSuper_Left:0];
    [_textView YuanToSuper_Right:Horizontal(100)];
    [_textView YuanToSuper_Top:0];
    [_textView YuanToSuper_Bottom:0];
    _textView.backgroundColor = UIColor.whiteColor;
    
    
    [_btn YuanAttributeHorizontalToView:_backView];
    [_btn YuanToSuper_Right:limit/2 ];
    [_btn autoSetDimensionsToSize:CGSizeMake(Horizontal(60), Vertical(30))];
    
}


// 入网时间专用的 时间选择器
- (void) UI_Init_Type10 {
    
    
    [_title YuanToSuper_Top:limit];
    [_title YuanToSuper_Left:limit];
    
    [_backView YuanToSuper_Left:limit];
    [_backView YuanToSuper_Right:limit];
    [_backView YuanToSuper_Bottom:limit];
    [_backView YuanMyEdge:Top ToViewEdge:Bottom ToView:_title inset:limit];
    
    
    [_textField YuanToSuper_Left:0];
    [_textField YuanToSuper_Right:0];
    [_textField YuanToSuper_Top:0];
    [_textField YuanToSuper_Bottom:0];
    _textField.backgroundColor = UIColor.whiteColor;
    
    // 下拉箭头
    UIImageView * img = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"yuanMB_xiala"]
                                           frame:CGRectNull];
    
    [_textField addSubview:img];
    
    [img YuanAttributeHorizontalToView:_textField];
    [img autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:Horizontal(15)];
    
    
    
    CGRect picker10_Frame = CGRectMake(0, ScreenHeight - Vertical(250), ScreenWidth, Vertical(250));
    
    Yuan_PickerView * picker = [[Yuan_PickerView alloc] initWithFrame:picker10_Frame
                                                          PickerBlock:nil
                                                              section:5];
    
    
    if (_model.needFuture && [_model.needFuture isEqualToString:@"1"]) {
        [picker needFuture];
    }
    
    __typeof(self)weakSelf = self;
    // 确认按钮 点击事件的回调
    picker.selectBlock = ^(NSString * _Nonnull year,
                           NSString * _Nonnull month,
                           NSString * _Nonnull day,
                           NSString * _Nonnull hour,
                           NSString * _Nonnull minute) {
        
        NSString * result = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:00",year,month,day,hour,minute];
        
        [weakSelf type10_Commit:result];
    };
    

    
    _textField.inputView = picker;
    _textField.inputAccessoryView = nil;
    
}


- (void) type10_Commit:(NSString *)result{
    
    _textField.text = result;
    [_textField resignFirstResponder];
    
    // 要看当选项的时候 , 传的是什么? 是汉字 还是数值

    // type == 10 时修改值的回调
    [self value_GoBackPostDict:@{_model.key:_textField.text}];
}



// rfid 扫描
- (void) UI_Init_Type52 {
    
    
    [_title YuanToSuper_Top:limit];
    [_title YuanToSuper_Left:limit];
    
    [_backView YuanToSuper_Left:limit];
    [_backView YuanToSuper_Right:limit];
    [_backView YuanToSuper_Bottom:limit];
    [_backView YuanMyEdge:Top ToViewEdge:Bottom ToView:_title inset:limit];
    
    
    [_textView YuanToSuper_Left:0];
    [_textView YuanToSuper_Right:Horizontal(100)];
    [_textView YuanToSuper_Top:0];
    [_textView YuanToSuper_Bottom:0];
    _textView.backgroundColor = UIColor.whiteColor;
    
    
    [_btn YuanAttributeHorizontalToView:_backView];
    [_btn YuanToSuper_Right:limit/2 ];
    [_btn autoSetDimensionsToSize:CGSizeMake(Horizontal(60), Vertical(30))];
    
}




#pragma mark - BaseUI ---

- (void) BaseUI_Init {
    
    
    _title = [UIView labelWithTitle:@"标题" frame:CGRectNull];
    _title.font = Font_Yuan(16);
    
    _backView = [UIView viewWithColor:UIColor.whiteColor];
    [_backView cornerRadius:5 borderWidth:1 borderColor:ColorValue_RGB(0xb2b2b2)];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectNull];
    _textView.delegate = self;
    _textView.font = Font_Yuan(13);
    
    if ([_model.keyBoardType isEqualToString:@"number"]) {
        _textView.keyboardType = UIKeyboardTypeDecimalPad;
    }
    
    
    _textField = [UIView textFieldFrame:CGRectNull];
    _textField.delegate = self;
    _textField.textAlignment = NSTextAlignmentCenter;
    _textField.font = Font_Yuan(13);
    
    _picker = [[Yuan_TextFieldPicker alloc]initWithDataSource:_model.optionsArr
                                                     textField:_textField];
    
    
    _btn = [UIView buttonWithTitle:@"" responder:self SEL:@selector(btnClick) frame:CGRectNull];
    [_btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _btn.backgroundColor = UIColor.mainColor;
    [_btn cornerRadius:3 borderWidth:0 borderColor:nil];
    
    _specialNote = [UIView labelWithTitle:@"" frame:CGRectNull];
    _specialNote.textColor = UIColor.mainColor;
    _specialNote.font = Font_Yuan(11);
    _specialNote.hidden = YES;
    
    [self addSubviews:@[_title,_backView,_specialNote]];
    [_backView addSubviews:@[_textView,_btn,_textField]];
    
    
    // 配置一些其他信息
    [self ModelConfig];
}




- (void) btnClick {
    
    // 取消编辑模式
    [_vc.view endEditing:YES];
    
    NSInteger type = _model.type.integerValue;
    
    // 扫一扫
    if (type == 52) {
        // TODO: 智网通 扫一扫
        
        Http.shareInstance.statisticEnum = HttpStatistic_ResourceBindQR;
        
        IWPSaoMiaoViewController * saomiao = [[IWPSaoMiaoViewController alloc] init];
        saomiao.isGet = YES;
        Push(_vc, saomiao);
        
        // 获取的回调
        saomiao.hanlder = ^(NSString *QRCode) {
            
            if (!QRCode || [QRCode obj_IsNull]) {
                [YuanHUD HUDFullText:@"扫一扫结果获取失败"];
                return;
            }
            
            _textView.text = QRCode;
            [self contentTextViewSizeToFit];
            
            if (_type == 52) {
                [self value_GoBackPostDict:@{_model.key:QRCode}];
            }
        };

    }
    
    // 新版按钮通用查询接口
    if (type == 9) {
        
        
        if (!_model.targetResLogicName) {
            [YuanHUD HUDFullText:@"没有对应的resLogicName"];
            return;
        }
        
        NSMutableDictionary * postDict = NSMutableDictionary.dictionary;
        postDict[@"type"] = _model.targetResLogicName;
        
        
        ///MARK:  特殊字段的注入 --- ---
        
        // 查询设备类型
        if ([_model.targetResLogicName isEqualToString:@"eqpType"]) {
            postDict[@"resType"] = _fileName ?: @"";
        }
        
        
        // 根据 设备restypeid 查询 本省分所有的该设备 -- occ odf odb
        if ([_model.targetResLogicName isEqualToString:@"normalDevice"] &&
            _model.checkId) {
            
            postDict[@"resType"] = _mbDict[_model.checkId] ?: @"";
        }
        
        
        // 动态类型判断 -- 通常是 type3 + type9 的组合 ,type3确定类型 , type9 根据类型转type值
        if ([_model.targetResLogicName isEqualToString:@"dynamicType"] &&
            _model.checkId) {
            
            
           NSString * deviceEnglishCode =
            [Inc_NewMB_Presenter DeviceNumCode_To_DeviceEnglishCode:_mbDict[_model.checkId]];
            
            if (deviceEnglishCode.length > 0) {
                postDict[@"type"] = deviceEnglishCode;
            }
            
            else {
                [YuanHUD HUDFullText:@"设备编码未知"];
                return;
            }
            
        }
        
        
        
        
        // 根据 OLT 查询 OLT端口
        if ([_model.targetResLogicName isEqualToString:@"OLT_Port"]) {
            
            // 当已有OLT 查询OLT端口时
            if (_model.checkId) {
                postDict[@"id"] = _mbDict[_model.checkId];
            }
        }
        
        
        
        ///MARK: 判断是否有checkid  并且 checkUsed 不为0 --- ---
        if (_model.checkId && ![_model.checkUsed isEqualToString:@"0"]) {
            
            if (![_mbDict.allKeys containsObject:_model.checkId]) {
                [YuanHUD HUDFullText:[NSString stringWithFormat:@"请先选择%@",_model.checkTitle]];
                return;
            }
            else {
                postDict[_model.checkId] = _mbDict[_model.checkId];
            }
        }
        
        
        Inc_NewMB_Type9_AssistListVC * type9_Vc =
        [[Inc_NewMB_Type9_AssistListVC alloc] initWithPostDict:postDict];
        
        // 配置标题
        [type9_Vc configTitle:_model.title];
        
        // 选择
        type9_Vc.Type9_Choose_ResBlock = ^(NSDictionary * _Nonnull dict) {
            
            NSString * targetId = dict[@"gid"];
            NSString * targetName = dict[@"name"];
            
            NSDictionary * upDataDict = @{_model.targetResId:targetId,
                                          _model.targetResName:targetName};
            
            _textView.text = targetName;
            [self contentTextViewSizeToFit];
            
            // 如果存在联动关系 , 那么删除联动关系对应的字段
            if (_model.subResId && _model.subResName) {
                    
                NSMutableDictionary * subDict = [NSMutableDictionary dictionaryWithDictionary:upDataDict];
                
                if (_model.subResId && _model.subResName) {
                    subDict[_model.subResId] = @"";
                    subDict[_model.subResName] = @"";
                }
                
                
                // type == 6 时修改值的回调  需要刷新界面
                [self reload_Value_GoBackPostDict:subDict];
            }
            
            // 通常的情况是走该分支
            else {
                // type == 9 时修改值的回调
                [self value_GoBackPostDict:upDataDict];
            }

        };
    
        Push(_vc, type9_Vc);
    }
    
    // 获取经纬度
    if (type == 4) {
        
        // 获取地址经纬度
        if ([_model.key isEqualToString:@"x|y"]) {
            
            Inc_NewMB_AssistMapVC * mapView = [[Inc_NewMB_AssistMapVC alloc] init];
            Push(_vc, mapView);
            
            mapView.Type4_GetLatLonBlock = ^(double lat, double lon) {
                
                NSString * Lat = [NSString stringWithFormat:@"%lf",lat];
                NSString * Lon = [NSString stringWithFormat:@"%lf",lon];
                
                // 选择完经纬度后 需要重新刷新数据
                [self reload_Value_GoBackPostDict:@{@"y":Lat,
                                                    @"x":Lon}];
                
                
                // 如果存在 经纬度和地址的联动关系 , 为地址请求反地理编码
                if (_model.subResId && _model.subResName) {
                    
                    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(lat, lon);
                    
                    [_presenter reGeocodeSearch:coor
                                        success:^(NSString * _Nonnull address) {
                        
                        [self reload_Value_GoBackPostDict:@{_model.subResId : address}];
                    }];
                    
                }
            };
        }
        
        else {
            
            
            // 如果不存在 x y 字段 返回空
            if (![_mbDict.allKeys containsObject:@"x"] ||
                ![_mbDict.allKeys containsObject:@"y"]) {
                
                [self reload_Value_GoBackPostDict:@{_model.key : @""}];
            }
            
            
            else {
            
                NSString * Lat = [NSString stringWithFormat:@"%@",_mbDict[@"y"]];
                NSString * Lon = [NSString stringWithFormat:@"%@",_mbDict[@"x"]];
                
                
                CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(Lat.doubleValue, Lon.doubleValue);
                
                [_presenter reGeocodeSearch:coor
                                    success:^(NSString * _Nonnull address) {
                    
                    [self reload_Value_GoBackPostDict:@{_model.key : address}];
                }];
            }
        }
    }
}


///MARK:  初始化配置  -- 用数据为View赋值的过程
- (void) ModelConfig {
    
    
    // 赋值
    _title.text = _model.title ?: @"";
    
    // model的key 在数据中 , 那么给他赋值
    if ([_mbDict.allKeys containsObject:_model.key]) {
        
        // 取出对应的值 , 为输入框赋值
        if ([_mbDict.allKeys containsObject:_model.key]) {
            _textField.text =  [Yuan_Foundation fromObject:_mbDict[_model.key]];
            _textView.text = [Yuan_Foundation fromObject:_mbDict[_model.key]];
        }
        else {
            _textField.text = @"";
            _textView.text = @"";
        }
        
        
        // 枚举选项
        if (_type == 3) {
            
            //[NSString stringWithFormat:@"%@",_mbDict[_model.key]]  zzc适配后台返回long类型 目前电表使用
            NSString * value = [NSString stringWithFormat:@"%@",_mbDict[_model.key]];
            
            NSInteger index = 0;
            
            if ([_model.optionsEnumArr containsObject:value]) {
                index = [_model.optionsEnumArr indexOfObject:value];
            }
            
            
            NSLog(@"-- key: %@ \n, title: %@\n value : %@ \n",_model.key , _model.title , value);
            
            if (index > 0) {
                _textField.text = _model.optionsArr[index];
            }
            else {
                _textField.text = @"请选择";
            }
        }
        
    }
    
    // type 4 专用的  获取经纬度
    if ([_model.key isEqualToString:@"x|y"]) {
        
        if (![_mbDict.allKeys containsObject:@"x"] ||
            ![_mbDict.allKeys containsObject:@"y"]) {
            
            _textView.text = @"";
            
        }
        
        else {
            
            NSString * x = _mbDict[@"x"] ?: @"";
            NSString * y = _mbDict[@"y"] ?: @"";
            
            if (!x) x = @"";
            if (!y) y = @"";
            
            // x 代表lat 维度
            // y 代表lon 精度
            _textView.text = [NSString stringWithFormat:@"%@/%@",x,y];
            
        }
    }
    
    
    // 按钮文字
    if (_model.btnTitle) {
        [_btn setTitle:_model.btnTitle forState:UIControlStateNormal];
    }
    
    
    // 不可编辑
    
    {
        
        if (_model.edit.intValue == 0) {
            _textView.userInteractionEnabled = NO;
        }
        else _textView.userInteractionEnabled = YES;
    }
    
    
    // 是否必填
    
    {
        
        if (_model.required.intValue == 0) {
            _title.textColor = ColorValue_RGB(0x666666);
        }
        else _title.textColor = UIColor.mainColor;
    }
    
    
    // 特殊字段的判断
    if ([_presenter theKeyIsInSpecial:_model.key]) {
        
        _textView.text = [_presenter NewMB_Item_ModelConfigKey:_model.key
                                                           dict:_mbDict];
    }
    
    
}


/// 获取高度
- (float) getHeight {
    
    float height = 0;
    
    switch (_type) {
          
            
        case 1:
            height = Vertical(90);
            break;
            
        case 52:
            height = Vertical(120);
            break;
            
        default:
            height = Vertical(85);
            break;
    }
    
    
    
    
    return height;
}



#pragma mark - textViewDelegate ---

// 结束编辑的时候 , 赋值
- (void)textViewDidEndEditing:(UITextView *)textView {
    
    int type = _model.type.intValue;
    
    // 纯文字输入 结束编辑时 , 赋值
    if (type == 1) {
        
        
        // 居中
        [self contentTextViewSizeToFit];
        // 纤芯衰耗系数
        if ([_model.key isEqualToString:@"lightAttenuationCoefficient"]) {
            
            // 控制是否是纯数字
            _textView.text = [_presenter lightAttenuationCoefficient_Config:textView.text];
            
            if (_textView.text.length == 0) {
                _specialNote.hidden = YES;
            }
            else {
                _specialNote.hidden = NO;
            }
            
            // 控制底部描述
            NSString * specialTxt = [_presenter optPair_SpecialConfig:textView.text];
            _specialNote.text = specialTxt;
        }
        
        // type == 1 时修改值的回调
        [self value_GoBackPostDict:@{_model.key:_textView.text}];
        
    }
    
    else if (type == 52) {
        // type == 52 也是一样
        [self value_GoBackPostDict:@{_model.key:_textView.text}];
    }
    
}


// textView , 回车
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range      replacementText:(NSString *)text {
//    [_vc.view endEditing:YES];
    return YES;
}



// 重新加载数据
- (void) reloadWithDict:(NSDictionary *) reloadDict {
    
    
    _mbDict = reloadDict;
    
    NSInteger type = _model.type.integerValue;
    
    // 恢复原状
    if (type == 3) {
        _textField.text = @"请选择";
    }
    
    _textView.text = @"";
    
    
    // 在根据myDict 新数据赋值
    
    NSString * key = _model.key;
    
    // 如果数据源中有该数据的话
    if ([_mbDict.allKeys containsObject:key]) {
        
        if (type == 3) {
            
            // 得到枚举值
            NSString * Intge = [NSString stringWithFormat:@"%@",_mbDict[key]];
            
            if ([_model.optionsEnumArr containsObject:Intge]) {
                
                NSInteger optionsIndex = [_model.optionsEnumArr indexOfObject:Intge];
                _textField.text = _model.optionsArr[optionsIndex];
            }
            else {
                _textField.text = @"请选择";
            }
            
        }
        
        else {
            _textView.text = [NSString stringWithFormat:@"%@",_mbDict[key]] ?: @"";
        }
    }
    
    
    // type 4 专用的  获取经纬度
    if ([key isEqualToString:@"x|y"]) {
        
        if (![_mbDict.allKeys containsObject:@"x"] ||
            ![_mbDict.allKeys containsObject:@"y"]) {
            
            _textView.text = @"";
            
        }
        
        else {
            
            NSString * x = _mbDict[@"x"] ?: @"";
            NSString * y = _mbDict[@"y"] ?: @"";
            
            if (!x) x = @"";
            if (!y) y = @"";
            
            // x 代表lat 维度
            // y 代表lon 精度
            _textView.text = [NSString stringWithFormat:@"%@/%@",x,y];
            
        }
    }
}


- (void) changeTitleColor:(BOOL)isMainColor {
    
    if (isMainColor) _title.textColor = UIColor.mainColor;
    else _title.textColor = ColorValue_RGB(0x666666);
    
}


#pragma mark - 代理的方式 把值回调回去 ---
- (void) value_GoBackPostDict:(NSDictionary * )postDict{
    
    if (self.delegate != NULL &&
        [self.delegate respondsToSelector:@selector(Yuan_NewMB_Item:newDict:)]) {
        [self.delegate Yuan_NewMB_Item:self newDict:postDict];
    }
}


// 只有需要刷新数据的时候 才会使用   目前是 type6  和 type4 使用
- (void) reload_Value_GoBackPostDict:(NSDictionary * )postDict {
    
    if (self.delegate != NULL &&
        [self.delegate respondsToSelector:@selector(Yuan_NewMB_Item:newDict:isReload:)]) {
         [self.delegate Yuan_NewMB_Item:self newDict:postDict isReload:YES];
    }
    
}



#pragma mark - textView 垂直居中 ---

- (void)contentTextViewSizeToFit {
    //先判断一下有没有文字（没文字就没必要设置居中了）
    if([_textView.text length]>0)
    {
        //textView的contentSize属性
        CGSize contentSize = _textView.contentSize;
        //textView的内边距属性
        UIEdgeInsets offset;
        CGSize newSize = contentSize;
        
        
        //textView的高度减去文字高度除以2就是Y方向的偏移量，也就是textView的上内边距
        CGFloat offsetY = (_textView.frame.size.height - contentSize.height)/2;
        offset = UIEdgeInsetsMake(offsetY, 0, 0, 0);
        
        //根据前面计算设置textView的ContentSize和Y方向偏移量
        [_textView setContentSize:newSize];
        [_textView setContentInset:offset];
        
    }
}

@end
