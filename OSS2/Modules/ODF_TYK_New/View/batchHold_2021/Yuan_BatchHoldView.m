//
//  Yuan_BatchHoldView.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/3/2.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_BatchHoldView.h"
#import "Yuan_BlockLabelView.h"

#import "Yuan_TextFieldPicker.h"
#import "Yuan_PhotoCheckVM.h"

@implementation Yuan_BatchHoldView

{
    
    Yuan_BlockLabelView * _blockView;
    UILabel * _pleaseChooseLab;
    
    
    UITextField * _stateChooseBtn; // 选择批量修改的类型
    
    UIButton * _clearBtn;
    UIButton * _saveBtn;
    UIButton * _cancelBtn;
    
    UILabel * _msg;
    
    Yuan_TextFieldPicker * _picker;
    UITextField * _textField;
    
    NSArray * _chooseArr;
    
    Yuan_PhotoCheckVM * _VM;
}

#pragma mark - 初始化构造方法

- (instancetype)init {
    
    if (self = [super init]) {
        _VM = Yuan_PhotoCheckVM.shareInstance;
        [self UI_Init];
        [self blockInit];
        self.backgroundColor = UIColor.whiteColor;
    }
    return self;
}


- (void) UI_Init {
    
    
    _chooseArr = @[@"■ 空闲" ,
                   @"■ 预占",
                   @"■ 占用",
                   @"■ 预释放" ,
                   @"■ 预留",
                   @"■ 预选",
                   @"■ 备用" ,
                   @"■ 停用",
                   @"■ 闲置",
                   @"■ 损坏" ,
                   @"■ 测试",
                   @"■ 临时占用"];
    
    
    _VM.optState = BatchHoldOprState_ZhanYong;
    _VM.selectOprState = _chooseArr.firstObject;
    
    
    _blockView = [[Yuan_BlockLabelView alloc] initWithBlockColor:UIColor.mainColor title:@"批量修改端子状态"];
    _pleaseChooseLab = [UIView labelWithTitle:@"请选择预设端子状态 :" frame:CGRectNull];
    
    _stateChooseBtn = [[UITextField alloc] initWithFrame:CGRectNull];
    [_stateChooseBtn cornerRadius:3 borderWidth:1 borderColor:UIColor.lightGrayColor];
    _stateChooseBtn.font = Font_Yuan(13);
    _stateChooseBtn.textAlignment = NSTextAlignmentCenter;
    _stateChooseBtn.textColor = ColorValue_RGB(0x333333);
    
    
    _picker = [[Yuan_TextFieldPicker alloc] initWithDataSource:_chooseArr textField:_stateChooseBtn];
    
    _clearBtn = [UIView buttonWithImage:@"ODF_New_Clear"
                              responder:self
                              SEL_Click:@selector(clearClick)
                                  frame:CGRectNull];
    
    _saveBtn = [UIView buttonWithTitle:@"保存"
                             responder:self
                                   SEL:@selector(saveClick)
                                 frame:CGRectNull];
    
    [_saveBtn cornerRadius:3 borderWidth:0 borderColor:nil];
    [_saveBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _saveBtn.backgroundColor = UIColor.mainColor;
    
    _cancelBtn = [UIView buttonWithTitle:@"取消"
                               responder:self
                                     SEL:@selector(cancelClick)
                                   frame:CGRectNull];
    
    [_cancelBtn cornerRadius:3 borderWidth:0 borderColor:nil];
    [_cancelBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _cancelBtn.backgroundColor = UIColor.lightGrayColor;
    
    
    
    _msg = [UIView labelWithTitle:@"(* 点击下方要修改的按钮后 , 点击保存按钮即可批量修改端子状态.)" frame:CGRectNull];
    _msg.textColor = UIColor.mainColor;
    _msg.font = Font_Yuan(10);
    
    
    [self addSubviews:@[_blockView ,
                        _pleaseChooseLab ,
                        _stateChooseBtn ,
                        _clearBtn ,
                        _saveBtn ,
                        _cancelBtn ,
                        _msg]];
    
    [self yuan_LayoutSubViews];
}



- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(15);
    
    [_blockView YuanToSuper_Left:limit];
    [_blockView YuanToSuper_Top:limit];
    
    [_pleaseChooseLab YuanMyEdge:Top ToViewEdge:Bottom ToView:_blockView inset:limit];
    [_pleaseChooseLab YuanToSuper_Left:limit];
    
    [_stateChooseBtn YuanAttributeHorizontalToView:_pleaseChooseLab];
    [_stateChooseBtn YuanMyEdge:Left ToViewEdge:Right ToView:_pleaseChooseLab inset:limit];
    [_stateChooseBtn autoSetDimensionsToSize:CGSizeMake(Horizontal(80), Vertical(25))];
    
    [_clearBtn YuanToSuper_Left:limit];
    [_clearBtn YuanMyEdge:Top ToViewEdge:Bottom ToView:_pleaseChooseLab inset:limit];
    
    
    [_saveBtn YuanAttributeHorizontalToView:_clearBtn];
    [_saveBtn autoSetDimensionsToSize:CGSizeMake(Horizontal(120), Vertical(35))];
    [_saveBtn YuanMyEdge:Left ToViewEdge:Right ToView:_clearBtn inset:limit];
    
    [_cancelBtn YuanAttributeHorizontalToView:_clearBtn];
    [_cancelBtn autoSetDimensionsToSize:CGSizeMake(Horizontal(120), Vertical(35))];
    [_cancelBtn YuanMyEdge:Left ToViewEdge:Right ToView:_saveBtn inset:limit];
    
    [_msg YuanToSuper_Left:limit];
    [_msg YuanToSuper_Bottom:limit];
    [_msg YuanToSuper_Right:limit];
    
    
}


- (void) blockInit {
    
    __typeof(self)weakSelf = self;
    
    _picker.commitBlock = ^(NSInteger selectIndex) {
      
        [weakSelf config:selectIndex];
    };
}

- (void) config:(NSInteger) selectIndex {
    
    NSString * str = _chooseArr[selectIndex];
    _VM.selectOprState = str;
    
    
    switch (selectIndex + 1) {
        case 2:     //预占
        case 4:     //预释放
        case 5:     //预留
        case 6:     //预选
        case 7:     //备用
        case 11:    //测试
        case 12:    //临时占用
            
            _stateChooseBtn.textColor = ColorR_G_B(252, 160, 0);
            break;
        
        case 3:     //占用
            
            _stateChooseBtn.textColor = ColorR_G_B(147, 222, 113);
            break;
        
        case 8:     //停用
        case 10:    //损坏
            
            _stateChooseBtn.textColor = ColorR_G_B(255, 0, 44);
            break;
            
        default:    //1.空闲 9.闲置
            
            _stateChooseBtn.textColor = ColorValue_RGB(0x333333);
            break;
    }
    
    
}

#pragma mark - btnClick ---

- (void) clearClick {
    
    if (!_BatchHold_StateBlock) {
        return;
    }
    _BatchHold_StateBlock(BatchHold_Clear);
}


- (void) saveClick {
    
    if (!_BatchHold_StateBlock) {
        return;
    }
    _BatchHold_StateBlock(BatchHold_Enter);
}


- (void) cancelClick {
    
    if (!_BatchHold_StateBlock) {
        return;
    }
    _BatchHold_StateBlock(BatchHold_Cancel);
}


@end
