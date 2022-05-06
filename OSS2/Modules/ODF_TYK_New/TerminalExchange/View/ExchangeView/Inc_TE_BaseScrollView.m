//
//  Inc_TE_BaseScrollView.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/8/19.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_TE_BaseScrollView.h"

// content
#import "Inc_TE_BaseContentView.h"





@interface Inc_TE_BaseScrollView () <UIScrollViewDelegate>

@end

@implementation Inc_TE_BaseScrollView

{
    
    Inc_TE_ViewModel * _VM;
    
    // 对调前后 按钮
    UIButton * _changeBeforeBtn;
    UIButton * _changeAfterBtn;
    UIView * _btnLine;
    NSLayoutConstraint * _btnLineLayout;
    
    
    
    UIScrollView * _baseScroll;
    BaseScroll_ _scrollStateEnum;
    
    
    // ***
    
    Inc_TE_BaseContentView * _beforeView;
    Inc_TE_BaseContentView * _afterView;
    
    // 网络请求查询接口
    NSDictionary * _httpResult;
    
    // A端子的路由数据
    NSDictionary * _originTerm ;
    // B端子的路由数据
    NSDictionary * _swapTerm;
    
}


#pragma mark - 初始化构造方法

- (instancetype)init {
    
    if (self = [super init]) {
        
        _VM = Inc_TE_ViewModel.shareInstance;
        _scrollStateEnum = BaseScroll_Before;
        [self UI_Init];
        
        [self http_SelectDatasFromId];
    }
    return self;
}


#pragma mark - method ---

- (void) changePageToAfter {
    
    
    [UIView animateWithDuration:0.5 animations:^{
        // 切换到下一个页面
        _baseScroll.contentOffset = CGPointMake(ScreenWidth, 0);
    }];
    
    
}


// 开始对调
- (void) startExchange {
    
    // 发起对调请求
    [self http_ModifiExchange];
}




#pragma mark - http ---

- (void) http_SelectDatasFromId {
    
    
    if (_VM.Terminal_A_Dict && _VM.Terminal_B_Dict) {
        
        // 原始端子id
        NSString * A_ID = _VM.Terminal_A_Dict[@"GID"];
        
        // 对调目标端子id
        NSString * B_ID = _VM.Terminal_B_Dict[@"GID"];
        
        NSDictionary * dict = @{@"oid" : A_ID , @"eid" : B_ID};
        
        [Inc_TE_HttpModel Http_TE_GetDatasFromTerminalIds:dict
                                                  success:^(id  _Nonnull result) {
                    
            _httpResult = result;
            
            // A 端子的路由数据
            _originTerm = _httpResult[@"originTerm"];
            
            // B 端子的路由数据
            _swapTerm = _httpResult[@"swapTerm"];
            

            // 加载 对调前 对调后 两个content
            [self create_ContentView];
            
            
        }];
        
    }
    
    else {
        [YuanHUD HUDFullText:@"数据错误"];
        return;
    }
    
}


- (void) http_ModifiExchange {
    
    NSArray * route_A = _originTerm[@"route"];
    NSArray * route_B = _swapTerm[@"route"];
    
    NSMutableDictionary * mt_OriginTerm = [NSMutableDictionary dictionaryWithDictionary:_originTerm];
    NSMutableDictionary * mt_swapTerm = [NSMutableDictionary dictionaryWithDictionary:_swapTerm];
    
    // 交换
    mt_OriginTerm[@"route"] = route_B;
    mt_swapTerm[@"route"] = route_A;
    
    // 交换后 是否进行跳接绑定?
    NSDictionary * postOriginDict = [_VM afterTerminalExchange_IsJumpT:mt_OriginTerm];
    NSDictionary * postSwapDict = [_VM afterTerminalExchange_IsJumpT:mt_swapTerm];
    
    
    NSDictionary * postDict = @{
        
        @"originTerm" : postOriginDict,
        @"swapTerm" : postSwapDict,
    };
    
    
    
    [Inc_TE_HttpModel Http_TE_ExchangeTerminal:postDict
                                       success:^(id  _Nonnull result) {
            
        if (_exchengeSuccessBlock) {
            _exchengeSuccessBlock();
        }
        
    }];
    
}


#pragma mark -  click ---

// 对调前
- (void) changeBeforeClick {
    
    _baseScroll.contentOffset = CGPointMake(0, 0);
}


// 对调后
- (void) changeAfterClick {

    _baseScroll.contentOffset = CGPointMake(ScreenWidth, 0);
}


- (void) resetBtn {
    
    _btnLineLayout.active = NO;
    _btnLineLayout = [_btnLine YuanAttributeVerticalToView:_scrollStateEnum == BaseScroll_Before ? _changeBeforeBtn : _changeAfterBtn];
    
    
    [_changeBeforeBtn setTitleColor:ColorValue_RGB(0x333333) forState:0];
    [_changeAfterBtn setTitleColor:ColorValue_RGB(0x333333) forState:0];
    
    if (_scrollStateEnum == BaseScroll_Before) {
        [_changeBeforeBtn setTitleColor:UIColor.mainColor forState:0];
    }
    else {
        [_changeAfterBtn setTitleColor:UIColor.mainColor forState:0];
    }
    
    

    
}


#pragma mark - delelgate ---

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    float offset_x = scrollView.contentOffset.x;
    
    // 对调前
    if (offset_x == 0) {
        
        _scrollStateEnum = BaseScroll_Before;
        
        // 将当前的状态回调回去 , 是对调前还是对调后
        if (_BaseScroll_StateBlock) {
            _BaseScroll_StateBlock(_scrollStateEnum);
        }
        
        [self resetBtn];
        
    }
    
    // 对调后
    if (offset_x == ScreenWidth) {
        
        _scrollStateEnum = BaseScroll_After;
        
        // 将当前的状态回调回去 , 是对调前还是对调后
        if (_BaseScroll_StateBlock) {
            _BaseScroll_StateBlock(_scrollStateEnum);
        }
        
        [self resetBtn];
        
    }
}



#pragma mark - UI_Init

- (void) UI_Init {
    
    _changeBeforeBtn = [UIView buttonWithTitle:@"对调前"
                                     responder:self
                                           SEL:@selector(changeBeforeClick)
                                         frame:CGRectNull];
    
    _changeAfterBtn = [UIView buttonWithTitle:@"对调后"
                                    responder:self
                                          SEL:@selector(changeAfterClick)
                                        frame:CGRectNull];
    
    [_changeBeforeBtn setTitleColor:UIColor.mainColor forState:0];
    
    _btnLine = [UIView viewWithColor:UIColor.mainColor];
    [_btnLine cornerRadius:5 borderWidth:0 borderColor:nil];
    
    
    _baseScroll = [[UIScrollView alloc] init];
    _baseScroll.delegate = self;
    _baseScroll.contentSize = CGSizeMake(ScreenWidth * 2, 0) ;
    _baseScroll.bounces = NO;
    _baseScroll.showsHorizontalScrollIndicator = YES;
    _baseScroll.pagingEnabled = YES;
    

    
    [self addSubviews:@[_changeBeforeBtn,
                        _changeAfterBtn,
                        _btnLine,
                        _baseScroll]];
    
    
    
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(10);
    
    [_changeBeforeBtn YuanToSuper_Top:limit];
    [_changeBeforeBtn YuanToSuper_Left:Horizontal(100)];
    
    [_changeAfterBtn YuanToSuper_Top:limit];
    [_changeAfterBtn YuanToSuper_Right:Horizontal(100)];
    
    [_changeBeforeBtn Yuan_EdgeSize:CGSizeMake(Horizontal(60), Vertical(30))];
    [_changeAfterBtn Yuan_EdgeSize:CGSizeMake(Horizontal(60), Vertical(30))];
    
    
    _btnLineLayout = [_btnLine YuanAttributeVerticalToView:_changeBeforeBtn];
    [_btnLine YuanMyEdge:Top ToViewEdge:Bottom ToView:_changeBeforeBtn inset:0];
    [_btnLine Yuan_EdgeSize:CGSizeMake(Horizontal(60), Vertical(2))];
    
    [_baseScroll YuanToSuper_Left:0];
    [_baseScroll YuanToSuper_Right:0];
    [_baseScroll YuanToSuper_Bottom:0];
    [_baseScroll YuanMyEdge:Top ToViewEdge:Bottom ToView:_btnLine inset:limit];
    
}


// 加载 对调前 对调后 两个view
- (void) create_ContentView {
    
    
    
    _beforeView =
    [[Inc_TE_BaseContentView alloc] initWithEnum:BaseScroll_Before
                                           frame:CGRectMake(0,
                                                            0,
                                                            ScreenWidth,
                                                            _baseScroll.height)];
    
    _afterView =
    [[Inc_TE_BaseContentView alloc] initWithEnum:BaseScroll_After
                                           frame:CGRectMake(ScreenWidth,
                                                            0,
                                                            ScreenWidth,
                                                            _baseScroll.height)];

    [_baseScroll addSubviews:@[_beforeView,_afterView]];
    
    
    
    // 对调后的端子 ******
    
    NSArray * route_A = _originTerm[@"route"];
    NSArray * route_B = _swapTerm[@"route"];
    
    NSMutableDictionary * mt_OriginTerm = [NSMutableDictionary dictionaryWithDictionary:_originTerm];
    NSMutableDictionary * mt_swapTerm = [NSMutableDictionary dictionaryWithDictionary:_swapTerm];
    
    // 交换
    mt_OriginTerm[@"route"] = route_B;
    mt_swapTerm[@"route"] = route_A;
    
    // 证明是互换后 , 需要对 A B 进行调换
    mt_OriginTerm[@"afterExchange"] = @"1";
    mt_swapTerm[@"afterExchange"] = @"1";
    
    
    
    // 特殊处理 *****
    
    
    NSNumber * seq_originTerm = _originTerm[@"seq"];
    NSNumber * seq_swapTerm = _swapTerm[@"seq"];
    
    NSNumber * sameRouter = _originTerm[@"sameRouter"];
    
    
    // 互为跳接关系
    if (sameRouter.boolValue == true) {
        
        // 不止是路由 , 跳接关系也需要更换
        NSDictionary * up_Term_A = _originTerm[@"upTerm"];
        NSDictionary * up_Term_B = _swapTerm[@"upTerm"];
        
        mt_OriginTerm[@"upTerm"] = up_Term_B;
        mt_swapTerm[@"upTerm"] = up_Term_A;
        
        // 对调前的端子 ******  只取 up 和 路由中的第一个端子
        [_beforeView reloadSpecialEnum:TE_ContentSpecialMode_JumpingRelationship
                                 ADict:_originTerm
                                 BDict:_swapTerm];
        
        
        // 对调后的端子 ******  只取 up 和 路由中的第一个端子
        [_afterView reloadSpecialEnum:TE_ContentSpecialMode_JumpingRelationship
                                ADict:mt_OriginTerm
                                BDict:mt_swapTerm];
        return;
    }
    
    
    
    // 有一个为倒顺序的话
    if (!seq_originTerm.boolValue || !seq_swapTerm.boolValue) {
        
        // 对调前的端子 ******  只取 up 和 路由中的第一个端子
        [_beforeView reloadSpecialEnum:TE_ContentSpecialMode_Reverse
                                 ADict:_originTerm
                                 BDict:_swapTerm];
        
        
        // 对调后的端子 ******  只取 up 和 路由中的第一个端子
        [_afterView reloadSpecialEnum:TE_ContentSpecialMode_Reverse
                                ADict:mt_OriginTerm
                                BDict:mt_swapTerm];
        
        return;
    }
    

    // 正常状态
    
    
    // 对调前的端子 ******
    [_beforeView reloadFrom_ADict:_originTerm
                            BDict:_swapTerm];
    

    
    [_afterView reloadFrom_ADict:mt_OriginTerm
                           BDict:mt_swapTerm];
}
 
@end
