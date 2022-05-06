//
//  Yuan_DC_TubeHandleView.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/1/12.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_DC_TubeHandleView.h"
#import "Yuan_DC_TubeHandleScroll.h"

#import "Yuan_BlockLabelView.h"


static NSString * isHaveSubTube = @"subHoleList";



@implementation Yuan_DC_TubeHandleView

{
    Yuan_BlockLabelView * _blockView;
        
    UIButton * _cancelBtn;
    
    UILabel * _deviceName;
    
    UIButton * _createBtn;
    
    Yuan_DC_TubeHandleScroll * _fatherTube;
    
    Yuan_DC_TubeHandleScroll * _subTube;        //实际做适配的
    
    NSArray * _resultAllSourceArray;
    
}


#pragma mark - 初始化构造方法

- (instancetype)init {
    
    if (self = [super init]) {
        [self UI_Init];
    }
    return self;
}


#pragma mark - method ---

- (void) reloadWithArray:(NSArray *)dataArray {
    
    _resultAllSourceArray = dataArray;
    
    [_fatherTube reloadTitle:@"管孔" dataSource:_resultAllSourceArray];
    
    NSDictionary * firstData = dataArray.firstObject;
    
    if ([firstData.allKeys containsObject:isHaveSubTube]) {
        
        [_subTube reloadTitle:@"子孔" dataSource:firstData[isHaveSubTube]];
    }
    
}



- (void) pipeName:(NSString *)name  {
    
    _deviceName.text = name ?: @"";
}



#pragma mark - 点击事件 ---


- (void) cancelClick {
    
    if (!_cancelBlock) return;
    
    _cancelBlock();
}



- (void) createClick {
    [[Yuan_HUD shareInstance] HUDFullText:@"生成管孔"];
}


- (void) block_Init {
    
    
    __typeof(self)weakSelf = self;
    
    _fatherTube.tubeHandleBtnBlock = ^(NSDictionary * _Nonnull btnDict,
                                       TubeHandleType_ type) {
        
        
        if ([btnDict.allKeys containsObject:isHaveSubTube]) {
            
            // 如果有下属子孔 刷新子孔
            
            NSArray * subArr = btnDict[isHaveSubTube];
            
            [weakSelf->_subTube reloadTitle:@"子孔"
                                 dataSource:subArr];
        }
        
        // 没有子孔 则直接调用
        else {
            
            if (weakSelf->_chooseTubeBlock) {
                weakSelf->_chooseTubeBlock(btnDict);
            }
            
        }
        
    };
    
    
    _subTube.tubeHandleBtnBlock = ^(NSDictionary * _Nonnull btnDict,
                                    TubeHandleType_ type) {
        
        if (weakSelf->_chooseTubeBlock) {
            weakSelf->_chooseTubeBlock(btnDict);
        }
        
    };
    
}


#pragma mark - UI ---

- (void) UI_Init {
    
    self.backgroundColor = UIColor.whiteColor;
    
    _blockView = [[Yuan_BlockLabelView alloc] initWithBlockColor:Color_V2Red title:@"请选择管孔"];
    
    _cancelBtn = [UIView buttonWithImage:@"DC_guanbi"
                               responder:self
                               SEL_Click:@selector(cancelClick)
                                   frame:CGRectNull];
    
    _deviceName = [UIView labelWithTitle:@"设备名称" frame:CGRectNull];
    
    _deviceName.numberOfLines = 0;//根据最大行数需求来设置
    _deviceName.lineBreakMode = NSLineBreakByTruncatingTail;

    _fatherTube = [[Yuan_DC_TubeHandleScroll alloc] init];
    
    _subTube = [[Yuan_DC_TubeHandleScroll alloc] init];
    
    _createBtn = [UIView buttonWithImage:@"DC_shengcheng"
                               responder:self
                               SEL_Click:@selector(createClick)
                                   frame:CGRectNull];
    
    
    [_fatherTube reloadTitle:@"管孔" dataSource:@[]];
    [_subTube reloadTitle:@"子孔" dataSource:@[]];
    
    
    
    
    [self block_Init];
    
    
    [self addSubviews:@[_blockView,_cancelBtn,_deviceName,_fatherTube,_subTube,_createBtn]];
    
    [self yuan_LayoutSubViews];
    
}

- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(15);
    
    
    
    
    
    [_cancelBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_cancelBtn autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:limit];
    
    [_blockView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    [_blockView YuanAttributeHorizontalToView:_cancelBtn];
    [_blockView autoSetDimension:ALDimensionHeight toSize:Vertical(30)];
    
    
    
    [_deviceName autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    [_deviceName autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_blockView withOffset:limit];
    [_deviceName autoSetDimension:ALDimensionWidth toSize:Horizontal(300)];
    
    
    [_fatherTube autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:_subTube withOffset:-limit];
    [_fatherTube autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_fatherTube autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_fatherTube autoSetDimension:ALDimensionHeight toSize:Horizontal(35)];
    
    
    
    [_subTube autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:limit];
    [_subTube autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_subTube autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_subTube autoSetDimension:ALDimensionHeight toSize:Horizontal(35)];
}

@end
