//
//  Inc_ShareListCell.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/7/14.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_ShareListCell.h"

// 跳转到
#import "Inc_Push_MB.h"

// 跳转到路由
//#import "Inc_Share_RouterVC.h"

// 转派人员选择
//#import "Inc_KP_UserChooseVC.h"


#import "Inc_Share_HttpModel.h"
//#import "Inc_KP_HttpModel.h"
@implementation Inc_ShareListCell

{
    
    UIView * _backView;
    
    UIImageView * _timeIcon;
    UILabel * _time;
    
    // 分享
    UIButton * _shareBtn;
    
    // 执行
    UIButton * _doBtn;
    
    // 分割线
    UIView * _line;
    
    // **** **** ****
    
    UILabel * _state;
    UILabel * _resName;
    UILabel * _noteSympol;
    UILabel * _note;
    
    // *** *** ***
    
    UIImageView * _shareIcon;
    UILabel * _shareMsg;
    
    UIImageView * _personIcon;
    UILabel * _person;
    
    
    #pragma mark - 业务 ---
    
    // 分享状态
    ShareListEnum_ _shareEnum;
    // 执行状态
    ShareListEnum_ _doEnum;
    
    // 资源Id
    NSString * _resId;
    
    NSDictionary * _myDic;
    
    NSString * _resType;
}


#pragma mark - 初始化构造方法

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self UI_Init];
        self.contentView.backgroundColor = UIColor.f2_Color;
    }
    return self;
}


- (void) reloadWithDict:(NSDictionary *)dict {
    
    _myDic = dict;
    
    _resId = dict[@"resId"];
    
    // 资源名称
    NSString * resName = dict[@"resName"] ?: @"";
    
    // 类型
    _resType = dict[@"resType"] ?: @"";
    
    // 接收人姓名
    NSString * receiverRealName = dict[@"receiverRealName"] ?: @"";
    
    // 已读状态
    NSNumber * isDeal = dict[@"isDeal"];
    
    // 备注
    NSString * note = dict[@"note"] ?: @"";
    
    // 分享原因
    NSString * shareMsg = dict[@"strShareReason"] ?: @"";
    
    // 转发状态
    NSNumber * forwardState = dict[@"isForwarding"];
    
    // 转派给谁 姓名
    NSString * next_receiver_real_name = dict[@"nextReceiverRealName"];
    
    // 分享时间
    NSString * shareTime = dict[@"shareTime"];
    
    
    _time.text = [Yuan_Foundation fromObject:shareTime];
    _resName.text = [Yuan_Foundation fromObject:resName];
    _person.text = [NSString stringWithFormat:@"执行人: %@",[Yuan_Foundation fromObject:receiverRealName]];
    _note.text = [Yuan_Foundation fromObject:note];
    _shareMsg.text = [NSString stringWithFormat:@"分享原因: %@",[Yuan_Foundation fromObject:shareMsg]];
    
    
    // 路由
    if ([_resType isEqualToString:@"optRout"]) {
        [_doBtn setImage:[UIImage Inc_imageNamed:@"shareLook"] forState:0];
        _doEnum = ShareListEnum_Look;
    }
    
    // 光缆段 或其他资源
    else {
        [_doBtn setImage:[UIImage Inc_imageNamed:@"shareZhiXing"] forState:0];
        _doEnum = ShareListEnum_Do;
    }
    
    // 是否已完成
    if ([isDeal isEqualToNumber:@0] || [isDeal isEqualToNumber:@1]) {
        _state.text = @"未完成";
        _state.backgroundColor = UIColor.systemRedColor;
    }
    
    else {
        _state.backgroundColor = UIColor.systemGreenColor;
        _state.text = @"已完成";
    }
    
    // 转发状态  已转发
    if (forwardState.intValue == 1) {
        [_shareBtn setImage:nil forState:0];
        [_shareBtn setTitle:[NSString stringWithFormat:@"已转发给%@",next_receiver_real_name ?: @""]
                   forState:0];
        _shareEnum = ShareListEnum_AlreadyShare;
    }
    
    // 未分享
    else {
        [_shareBtn setImage:[UIImage Inc_imageNamed:@"shareZhuanFa"] forState:0];
        [_shareBtn setTitle:@"" forState:0];
        _shareEnum = ShareListEnum_CanShare;
    }
    
}


#pragma mark - btnClick ---

// 分享
- (void) shareClick {
    
    if (_shareEnum == ShareListEnum_AlreadyShare) {
        return;
    }
    
    NSDictionary * loginDict = Http.shareInstance.david_LoginDict;
    NSNumber * regionId = loginDict[@"user"][@"regionId"];
    
    if (!regionId) {
        [YuanHUD HUDFullText:@"分享失败 , 未找到部门Id"];
        return;
    }
    
    [YuanHUD HUDFullText:@"到这了Inc_KP_HttpModel"];

//    [Inc_KP_HttpModel Http_KP_GetWorkersListFromRegionId:[Yuan_Foundation fromObject:regionId]
//                                                 Success:^(id  _Nonnull result) {
//
//        NSArray * arr = result;
//
//        if (arr.count == 0) {
//            [YuanHUD HUDFullText:@"该部门内无人员"];
//            return;
//        }
//        [YuanHUD HUDFullText:@"到这了Inc_KP_UserChooseVC"];
////        Inc_KP_UserChooseVC * users =
////        [[Inc_KP_UserChooseVC alloc] initWithChoosePersons:arr
////                                                      Block:^(NSDictionary * _Nonnull dict) {
////            // 调用分享
////            [self http_ShareWithDict:dict];
////        }];
////
////        Push(_vc, users);
//
//    }];
}

// 执行
- (void) doClick {
    
    
    if (_doEnum == ShareListEnum_Do) {
        
        NSString * resLogicName = @"";
        
        // 局站
        if ([_resType isEqualToString:@"station"]) {
            resLogicName = @"stationBase";
        }
        
        // 光缆段
        else if ([_resType isEqualToString:@"optSect"]) {
            
            resLogicName = @"cable";
        }
        
        // 机房
        else if ([_resType isEqualToString:@"room"]) {
            
            resLogicName = @"generator";
        }
        
        // ODF
        else if ([_resType isEqualToString:@"rackOdf"]) {
            
            resLogicName = @"ODF_Equt";
        }
        
        // 光缆
        else if ([_resType isEqualToString:@"opt"]) {
            
            resLogicName = @"route";
        }
        
        // 光分纤箱、光终端盒
        else if ([_resType isEqualToString:@"optJntBox"]) {
            
            resLogicName = @"ODB_Equt";
        }
        
        // 光交接箱
        else if ([_resType isEqualToString:@"optConnectBox"]) {
            
            resLogicName = @"OCC_Equt";
        }
        
        // 接头
        else if ([_resType isEqualToString:@"optTieIn"]) {
            
            resLogicName = @"joint";
        }
        
        else resLogicName = @"";
        
        

        if (resLogicName.length == 0) {
            
            [YuanHUD HUDFullText:@"暂未适配该资源"];
            return;
        }
        
        
        
        
        [Http.shareInstance V2_POST:HTTP_TYK_Normal_Get dict:@{@"GID":_resId ,
                                                               @"resLogicName":resLogicName}
                            succeed:^(id data) {
                
            NSArray * result = data;
            
            if (result.count == 0) {
                [YuanHUD HUDFullText:@"我查询到该资源"];
                return;
            }
            
            NSMutableDictionary * resDict = [NSMutableDictionary dictionaryWithDictionary:result.firstObject];
            
            // 光缆段特殊模板跳转
            if ([resLogicName isEqualToString:@"cable"]) {
                
                /*
                 // 老版本的光缆段跳转
                TYKDeviceInfoMationViewController * vc =
                [Inc_Push_MB push_Cable_From:_vc
                                         dict:resDict
                                         type:TYKDeviceListUpdate];
                
                // 回调回来以后 调用
                vc.savSuccessBlock = ^{
                    // 变更执行状态
                    [self http_ChangeCable_ShareState];
                };
                */
                
                [Inc_Push_MB NewMB_PushDetailsFromId:resDict[@"GID"]
                                                Enum:Yuan_NewMB_ModelEnum_optSect
                                                  vc:_vc saveBlock:^(id  _Nonnull result) {
                    // 变更执行状态
                    [self http_ChangeCable_ShareState];
                }];
                

            }
            
            else {

                
                TYKDeviceInfoMationViewController * vc =
                [Inc_Push_MB pushFrom:_vc
                         resLogicName:resLogicName
                                 dict:resDict
                                 type:TYKDeviceListUpdate];

                // 回调回来以后 调用
                vc.savSuccessBlock = ^{
                    // 变更执行状态
                    [self http_ChangeCable_ShareState];
                };
                
            }
            
            
        }];
    }
    
    // 只查看 路由数据 不做操作
    else {
        
        [YuanHUD HUDFullText:@"到这了Inc_Share_RouterVC"];
//        NSNumber * numIndex = _myDic[@"numIndex"] ?: @0;
//
//        Inc_Share_RouterVC * router =
//        [[Inc_Share_RouterVC alloc] initWithRouterId:_resId
//                                                Index:numIndex.integerValue];
//
//        Push(_vc, router);
    }
    
    
    
    
}


#pragma mark - http ---

- (void) http_ChangeCable_ShareState {
    

    
    
    NSNumber * shareId = _myDic[@"id"];
    NSString * receiverUsername = UserModel.userName;
    NSString * isRead = @"2";
    
    NSDictionary * dict = @{
        
        @"shareId" : shareId,
        @"receiverUsername" : receiverUsername,
        @"isRead" : isRead
    };
    
    [Inc_Share_HttpModel http_UpDataFromParam:dict
                                       success:^(id  _Nonnull result) {
            
        if (_reloadHttpList) {
            _reloadHttpList();
        }
        
    }];
    
}



- (void) http_ShareWithDict:(NSDictionary *) dict {
    
    


    
    NSNumber * shareId = _myDic[@"id"];
    NSString * receiverUsername = dict[@"name"];
    NSString * receiverRealName = dict[@"realName"];
    NSString * receiverPhoneNum = dict[@"mobile"];
    NSString * shareUsername = UserModel.userName;
    
    NSDictionary * postDict = @{
        @"shareId" : shareId,
        @"receiverUsername" : receiverUsername,
        @"receiverRealName" : receiverRealName,
        @"receiverPhoneNum" : receiverPhoneNum,
        @"shareUsername" : shareUsername
    };
    
    [Inc_Share_HttpModel http_ForwardingFromParam:postDict
                                           success:^(id  _Nonnull result) {
            
        // 转发成功后 , 刷新列表
        if (_reloadHttpList) {
            _reloadHttpList();
        }
    }];
    
    

    
}

#pragma mark - UI_Init

- (void) UI_Init {
    
    
    _backView = [UIView viewWithColor:UIColor.whiteColor];
    [_backView cornerRadius:10 borderWidth:0 borderColor:nil];
    [self.contentView addSubview:_backView];
    
    
    
    _timeIcon = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"shareTime"]
                                   frame:CGRectNull];
    
    _time = [UIView labelWithTitle:@"2020-12-21 15:25:31" frame:CGRectNull];
    _time.font = Font_Yuan(12);
    
    
    _shareBtn = [UIView buttonWithImage:@"shareZhuanFa"
                              responder:self
                              SEL_Click:@selector(shareClick)
                                  frame:CGRectNull];
    
    [_shareBtn setTitleColor:UIColor.mainColor forState:0];
    _shareBtn.titleLabel.font = Font_Yuan(12);
    
    _doBtn = [UIView buttonWithImage:@"shareLook"
                           responder:self
                           SEL_Click:@selector(doClick)
                               frame:CGRectNull];
    
    _line = [UIView viewWithColor:UIColor.f2_Color];
    
    // 中间部分 ********* *************
    _state = [UIView labelWithTitle:@"已完成" frame:CGRectNull];
    _state.textColor = UIColor.whiteColor;
    [_state cornerRadius:2 borderWidth:0 borderColor:nil];
    _state.backgroundColor = UIColor.systemGreenColor;
    _state.textAlignment = NSTextAlignmentCenter;
    _state.font = Font_Yuan(12);
    
    _resName = [UIView labelWithTitle:@"资源名称" frame:CGRectNull];
    _resName.font = Font_Bold_Yuan(15);
    
    _noteSympol = [UIView labelWithTitle:@"备注 :" frame:CGRectNull];
    _noteSympol.font = Font_Yuan(12);
    
    _note = [UIView labelWithTitle:@"askljdkljasdkljaslkdklasjdklasdkasjdjhfhjklasfhaskljdkljasdkljas"
                             frame:CGRectNull];
    
    _note.textColor = ColorValue_RGB(0x666666);
    
    
    // 底部 ********* *************
    
    _shareIcon = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"shareFenXiang"]
                                    frame:CGRectNull];
    _shareMsg = [UIView labelWithTitle:@"分享原因: 路由查看" frame:CGRectNull];
    
    
    _personIcon = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"sharePerson"] frame:CGRectNull];
    _person = [UIView labelWithTitle:@"执行人: 袁某某" frame:CGRectNull];
    
    _shareMsg.font = _person.font = Font_Yuan(12);
     
    [_backView addSubviews:@[_timeIcon,
                             _time,
                             _shareBtn,
                             _doBtn,
                             _line,
                             _state,
                             _resName,
                             _noteSympol,
                             _note,
                             _shareIcon,
                             _shareMsg,
                             _personIcon,
                             _person]];
    
    [self yuan_LayoutSubViews];
    
    
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(10);
    
    [_backView Yuan_Edges:UIEdgeInsetsMake(limit/2, limit, limit/2, limit)];
    
    [_timeIcon YuanToSuper_Top:limit];
    [_timeIcon YuanToSuper_Left:limit];
    
    [_time YuanAttributeHorizontalToView:_timeIcon];
    [_time YuanMyEdge:Left ToViewEdge:Right ToView:_timeIcon inset:limit];
    
    [_doBtn YuanToSuper_Right:limit];
    [_doBtn YuanAttributeHorizontalToView:_time];
    
    [_shareBtn YuanMyEdge:Right ToViewEdge:Left ToView:_doBtn inset:-limit];
    [_shareBtn YuanAttributeHorizontalToView:_doBtn];
    
    [_line YuanToSuper_Top:Vertical(30)];
    [_line YuanToSuper_Left:0];
    [_line YuanToSuper_Right:0];
    [_line Yuan_EdgeHeight:Vertical(1)];
    
    
    [_state YuanToSuper_Left:limit];
    [_state YuanMyEdge:Top ToViewEdge:Bottom ToView:_line inset:limit/2];
    [_state Yuan_EdgeSize:CGSizeMake(Horizontal(40), Vertical(20))];
    
    [_resName YuanMyEdge:Left ToViewEdge:Right ToView:_state inset:limit];
    [_resName YuanAttributeHorizontalToView:_state];
    [_resName YuanToSuper_Right:limit];
    
    
    [_noteSympol YuanMyEdge:Top ToViewEdge:Bottom ToView:_state inset:limit/2];
    [_noteSympol YuanToSuper_Left:limit];
    
    
    
    [_note YuanToSuper_Left:limit];
    [_note YuanToSuper_Right:limit];
    [_note YuanMyEdge:Top ToViewEdge:Bottom ToView:_noteSympol inset:limit/2];
    [_note YuanToSuper_Bottom:Vertical(40)];
    
    [_shareIcon YuanToSuper_Left:limit];
    [_shareIcon YuanToSuper_Bottom:limit];
    
    [_shareMsg YuanMyEdge:Left ToViewEdge:Right ToView:_shareIcon inset:limit/2];
    [_shareMsg YuanAttributeHorizontalToView:_shareIcon];
    
    [_person YuanToSuper_Right:limit];
    [_person YuanAttributeHorizontalToView:_shareIcon];
    
    [_personIcon YuanMyEdge:Right ToViewEdge:Left ToView:_person inset:-limit];
    [_personIcon YuanAttributeHorizontalToView:_shareIcon];
    
    
    
    
}

@end
