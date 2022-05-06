//
//  Yuan_MoreLevelDeleteVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/1/25.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_MoreLevelDeleteVC.h"
#import "Yuan_MoreLevelDeleteTipsView.h"


#import "Yuan_ML_HttpModel.h"

static float baseHeight = 220;
static float tipsHeight = 150;

@interface Yuan_MoreLevelDeleteVC ()

/** 背景 */
@property (nonatomic , strong) UIView * backView;
    
/** 关闭 */
@property (nonatomic , strong) UIButton * cancelBtn;

/** ⚠️ */
@property (nonatomic , strong) UILabel * warningMsg;

/** 分割线 */
@property (nonatomic , strong) UIView * line;

/** 您可以申请级联删除 */
@property (nonatomic , strong) UILabel * msg;

/** 什么是级联删除? */
@property (nonatomic , strong) UIButton * whats_MoreDeleteBtn;

/** tips */
@property (nonatomic , strong) Yuan_MoreLevelDeleteTipsView * tipsView;

/** 申请级联删除 */
@property (nonatomic , strong) UIButton * applyToMoreLevelDeleteBtn;

@end

@implementation Yuan_MoreLevelDeleteVC
{
    
    NSLayoutConstraint * _tipsLayout;
    NSLayoutConstraint * _heightLayout;
    
    NSDictionary * _errorDict;
    
}



#pragma mark - 初始化构造方法

- (instancetype)initWithRequestDict:(NSDictionary *)requestDict {
    
    if (self = [super init]) {
        _errorDict = requestDict;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self UI_Init];
}


- (void) UI_Init {
    
    _backView = [UIView viewWithColor:UIColor.whiteColor];
    [_backView cornerRadius:5 borderWidth:0 borderColor:nil];
    
    _cancelBtn = [UIView buttonWithImage:@"DC_guanbi" responder:self SEL_Click:@selector(cancelClick) frame:CGRectNull];
    
    _warningMsg = [UIView labelWithTitle:@"⚠️删除失败" frame:CGRectNull];
    
    NSString * info = _errorDict[@"info"];
    
    if (info) {
        _warningMsg.text = [NSString stringWithFormat:@"⚠️ %@",info];
    }
    
    
    _warningMsg.numberOfLines = 0;//根据最大行数需求来设置
    _warningMsg.lineBreakMode = NSLineBreakByTruncatingTail;
    _warningMsg.textColor = UIColor.mainColor;
    
    if (_errorMsg && _errorMsg.length > 0) {
        _warningMsg.text = _errorMsg;
    }
    
    
    
    _line = [UIView viewWithColor:ColorValue_RGB(0xf2f2f2)];
    
    _msg = [UIView labelWithTitle:@"如果是由于某些资源占用等原因(非系统原因)导致的删除失败,您可以申请级联删除"
                            frame:CGRectNull];
    
    _msg.numberOfLines = 0;//根据最大行数需求来设置
    _msg.lineBreakMode = NSLineBreakByTruncatingTail;
    
    
    _whats_MoreDeleteBtn = [UIView buttonWithTitle:@"级联删除"
                                         responder:self
                                               SEL:@selector(whatsMoreDeleteClick)
                                             frame:CGRectNull];
    
    
    NSMutableAttributedString* tncString = [[NSMutableAttributedString alloc] initWithString:@"级联删除"];
        
    [tncString addAttribute:NSUnderlineStyleAttributeName
                      value:@(NSUnderlineStyleSingle)
                      range:(NSRange){0,[tncString length]}];
    
    //此时如果设置字体颜色要这样
    [tncString addAttribute:NSForegroundColorAttributeName
                      value:[UIColor mainColor]
                      range:NSMakeRange(0,[tncString length])];
    
    //设置下划线颜色...
    [tncString addAttribute:NSUnderlineColorAttributeName
                      value:[UIColor mainColor]
                      range:(NSRange){0,[tncString length]}];
    
    [_whats_MoreDeleteBtn setAttributedTitle:tncString forState:UIControlStateNormal];
    
    _applyToMoreLevelDeleteBtn = [UIView buttonWithTitle:@"申请级联删除"
                                               responder:self
                                                     SEL:@selector(applyToMoreLevelDeleteClick)
                                                   frame:CGRectNull];
    
    [_applyToMoreLevelDeleteBtn cornerRadius:5 borderWidth:0 borderColor:nil];
    _applyToMoreLevelDeleteBtn.backgroundColor = UIColor.mainColor;
    [_applyToMoreLevelDeleteBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    
    _tipsView = [[Yuan_MoreLevelDeleteTipsView alloc] init];
    [_tipsView cornerRadius:1 borderWidth:1 borderColor:ColorValue_RGB(0xe2e2e2)];
    
    
    [self.view addSubview:_backView];
    
    
    
    [_backView addSubviews:@[_cancelBtn,
                             _warningMsg,
                             _line,
                             _msg,
                             _whats_MoreDeleteBtn,
                             _tipsView,
                             _applyToMoreLevelDeleteBtn]];
     
    [self yuan_LayoutSubViews];
    
}



- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(15);
    
    
    [_backView autoSetDimension:ALDimensionWidth toSize:ScreenWidth / 5 * 4];
    _heightLayout = [_backView autoSetDimension:ALDimensionHeight toSize:Vertical(baseHeight)];
    
    [_backView YuanAttributeHorizontalToView:self.view];
    [_backView YuanAttributeVerticalToView:self.view];
    
    [_cancelBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_cancelBtn autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:limit];
    
    [_warningMsg YuanAttributeHorizontalToView:_cancelBtn];
    [_warningMsg autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    [_warningMsg autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:Horizontal(50)];
    
    [_line autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_line autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_line autoSetDimension:ALDimensionHeight toSize:1];
    [_line autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_warningMsg withOffset:limit];
    
    [_msg autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_line withOffset:limit];
    [_msg autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    [_msg autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    
    
    [_whats_MoreDeleteBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_msg withOffset:limit/2];
    [_whats_MoreDeleteBtn autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    
    [_tipsView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    [_tipsView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    
    [_tipsView autoPinEdge:ALEdgeTop
                    toEdge:ALEdgeBottom
                    ofView:_whats_MoreDeleteBtn
                withOffset:limit/2];
    
    _tipsLayout =  [_tipsView autoSetDimension:ALDimensionHeight toSize:0];
    
    
    [_applyToMoreLevelDeleteBtn autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    [_applyToMoreLevelDeleteBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
//    [_applyToMoreLevelDeleteBtn autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:limit];
    [_applyToMoreLevelDeleteBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_tipsView withOffset:limit];
    [_applyToMoreLevelDeleteBtn autoSetDimension:ALDimensionHeight toSize:Vertical(40)];
    
    
}

#pragma mark - 关闭 ---

// 关闭
- (void) cancelClick {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


// 什么是联级删除 tips
- (void) whatsMoreDeleteClick {
    
    _tipsLayout.active = NO;
    _heightLayout.active = NO;
    
    _tipsLayout = [_tipsView autoSetDimension:ALDimensionHeight toSize:Vertical(tipsHeight)];
    _heightLayout = [_backView autoSetDimension:ALDimensionHeight toSize:Vertical(baseHeight + tipsHeight)];
}


// 联级删除
- (void) applyToMoreLevelDeleteClick {
    
    
    [UIAlert alertSmallTitle:@"是否申请级联删除?"
                          vc:self
               agreeBtnBlock:^(UIAlertAction *action) {
        
        [self http_DeleteAll];
    }];

    
}





- (void) http_DeleteAll {
    
    if (![_resourceDict.allKeys containsObject:@"GID"] ||
        ![_resourceDict.allKeys containsObject:@"resLogicName"]) {
        
        [[Yuan_HUD shareInstance] HUDFullText:@"缺少必要的字段"];
        return;
    }
    

    
    NSString * createBy = UserModel.userName;
    NSString * gid = _resourceDict[@"GID"];
    NSString * resType = [self resLogicNameToResType:_resourceDict[@"resLogicName"]];
    
    
    NSMutableDictionary * dict = NSMutableDictionary.dictionary;
    
    dict[@"provinceCode"] = Yuan_WebService.webServiceGetDomainCode;
    dict[@"createBy"] = createBy;
    dict[@"gid"] = gid;
    dict[@"resType"] = resType;
    dict[@"resName"] = _resourceDict[_resName];
    
    
    [Yuan_ML_HttpModel HTTP_MLD_UpLoadApply:dict success:^(id  _Nonnull result) {
        [[Yuan_HUD shareInstance] HUDFullText:@"已申请级联删除"];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    

    
    
}



- (NSString *) resLogicNameToResType:(NSString *)resLogicName {
    
    NSString * resType = @"";
    
    //标石路径
    if ([resLogicName isEqualToString:@"markStonePath"]) {
        resType = @"markerSys";
    }
    
    // 杆路
    else if ([resLogicName isEqualToString:@"poleline"]) {
        resType = @"pole";
    }
    
    //管道
    else if ([resLogicName isEqualToString:@"pipe"]) {
        resType = @"pipe";
    }
    
    //ODF
    else if ([resLogicName isEqualToString:@"ODF_Equt"]) {
        resType = @"rackOdf";
    }
    
    //OCC
    else if ([resLogicName isEqualToString:@"OCC_Equt"]) {
        resType = @"optConnectBox";
    }
    
    //ODB
    else if ([resLogicName isEqualToString:@"ODB_Equt"]) {
        resType = @"optJntBox";
    }
    
    else if ([resLogicName isEqualToString:@"cable"]) {
        
        resType = @"optSect";
    }
    
    
    return resType;
}


@end
