//
//  Yuan_DC_MapView.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2021/1/11.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_DC_MapView.h"
#import "Yuan_DC_PointHandleView.h"     //资源控制台
#import "Yuan_DC_TubeHandleView.h"      //管孔控制台


// 业务类
#import "Yuan_DC_HttpModel.h"
#import "Yuan_DC_VM.h"

//zzc 2021-07-14 全部撤缆
#import "Inc_DC_HttpModel1.h"

@interface Yuan_DC_MapView ()
<
    MAMapViewDelegate ,     //起始终止设备点
    MAMultiPointOverlayRendererDelegate //海量点
>

/** 资源点控制台 */
@property (nonatomic , strong) Yuan_DC_PointHandleView * pointHandle;

/** 管孔控制台 */
@property (nonatomic , strong) Yuan_DC_TubeHandleView * tubeHandle;

/** 取消编辑按钮 */
@property (nonatomic , strong) UIButton * endEditingBtn;

@end

@implementation Yuan_DC_MapView

{
    
    Yuan_DC_VM * _VM;
    
    // 起始终止资源点数组
    NSMutableArray * _cableStartEndAnnoArr;
    
    // 光缆段路由 资源点 数组
    NSMutableArray * _cableRoute_AnnoArr;
    
    // 光缆段路由 线段 数组
    NSMutableArray * _cableRoute_LineArr;
    
    // 获取附近资源时查回来的资源点 数组
    NSMutableArray * _circleRadiusAnnoArr;
    
    
    // 获取线路 的 点和线资源
    NSMutableArray * _getLinesAnnoArr;
    NSMutableArray * _getLinesLineArr;
    
    
    // 路由id keys  用于获取线路时 , 剔除已经加载过的数组
    NSMutableArray * _cableRoutePoint_IdsArr;
    NSMutableArray * _cableRouteLine_IdsArr;
    
    // 海量点图层
    
    Yuan_PointOverlay * _routeOverlay;
    Yuan_PointOverlay * _circleRadiusOverlay;
    Yuan_PointOverlay * _getLinesPointOverlay;
    
    
    
    NSString * _startDeviceId;
    NSString * _endDeviceId;
    
    DC_AnnoPointType_ _nowShowDCType;
        

    
    
    
    // 当撤缆或穿缆后 , 下一个选中的点的Id是多少 (撤缆比较复杂)
    NSString * _myNextSelectId;
    
    NSString * _nowSelectId;
    
    
    // 挂缆 起点和终点的Id
    
    NSString * _putCableStartPointId;
    NSString * _putCableEndPointId;
    
    NSDictionary * _putCableStartPointDict;
    NSDictionary * _putCableEndPointDict;
    
    
    //  当前选中的点 新的标记 !!!  这是插在海量点上的一个大头针
    Yuan_PointAnnotation * _nowSelectAnno_Symbol;
    
    
    
    // 当前穿缆的起始终止dict , 仅用于手动穿缆
    NSDictionary * _nowHandlePutCablePost_StartDict;
    NSDictionary * _nowHandlePutCablePost_EndDict;
    
    // 手动穿缆是使用
    NSInteger _nowIndex;
    
    // 接下来需要手动穿缆的数据 都有哪些.
    NSArray * _sectResList;
    
    // 递归时使用
    NSDictionary * _handleEndDict;
    
    
    // 选中标记
    MACircle * _circle;
    
    // 中心点 圆环 1000m
    MACircle * _centerCircle_1000m;
    Yuan_PointAnnotation * _center_Anno;
    
    BOOL _isCircleCenter;
}


#pragma mark - 初始化构造方法

- (instancetype) init {
    
    if (self = [super init]) {
        
        _VM = Yuan_DC_VM.shareInstance;
        _VM.isCableing = NO;
        
        [self addSubview:self.mapView];
        [_mapView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        
        // 点和线
        _cableRoute_AnnoArr = NSMutableArray.array;
        _cableRoute_LineArr = NSMutableArray.array;
        
        // 起始终止设备
        _cableStartEndAnnoArr = NSMutableArray.array;
        
        // 获取附近资源
        _circleRadiusAnnoArr = NSMutableArray.array;
        
        // 获取线路 资源
        _getLinesAnnoArr = NSMutableArray.array;
        _getLinesLineArr = NSMutableArray.array;
        
        
        // ID
        _cableRoutePoint_IdsArr = NSMutableArray.array;
        _cableRouteLine_IdsArr = NSMutableArray.array;

    }
    return self;
}



#pragma mark - http ---



//MARK: 获取路由
- (void) http_GetCableRoute {
    
    // 隐藏 取消编辑按钮
    [self hideEndEditingBtn];
    
    // 先清空ids 数组
    [_cableRoutePoint_IdsArr removeAllObjects];
    [_cableRouteLine_IdsArr removeAllObjects];
    
    
    
    
    [Yuan_DC_HttpModel http_GetCableRoute:_VM.cableId
                                  success:^(id  _Nonnull result) {
            
        NSDictionary * resultDict = result;
        
        [self loadView:resultDict];
        
    }];
    
}


//MARK: 加载屏幕中心点附近资源
- (void) http_LoadCircleRadiusRes:(NSArray *) circleRadiusArray {
    
    _nowSelectId = @"";
    _myNextSelectId = @"";
    
    [self hidePointHandle:YES];
    // 先清除除了路由外的其他地图资源
    [self removeMapSourceExceptRoute];
    
    
    if (circleRadiusArray.count == 0) {
        [YuanHUD HUDFullText:@"暂无数据"];
        return;
    }
    
    [self showEditingBtn];
    [self addAnnotations:circleRadiusArray dcType:DC_AnnoPointType_circleRadiusPoint];
}



//MARK: 获取线路接口
- (void) http_GetPointLines:(NSDictionary *)postDict {
    
    [self removeMapSourceExceptRoute];
    
    _myNextSelectId = @"";
    
    
    NSNumber * lat = postDict[@"lat"];
    NSNumber * lon = postDict[@"lon"];
    
    CLLocationCoordinate2D zoomTo = CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue);
    
    [Yuan_DC_HttpModel http_GetBelongResourceFromDict:postDict
                                              success:^(id  _Nonnull result) {
            
        NSDictionary * resDict = result;
        
        if (!resDict || [resDict obj_IsNull]) {
            return;
        }
        
        NSLog(@"%@", resDict.json);
        
        NSArray * sectData = resDict[@"sectData"];
        NSArray * pointData = resDict[@"pointData"];
        
        
        NSMutableArray * sectScreenArray = NSMutableArray.array;
        NSMutableArray * pointScreenArray = NSMutableArray.array;
        
        
        
        // 移除已经在路由上的点和线
        for (NSDictionary * source_dict in sectData) {
            
            // 有井资源 线段属于管孔
            if ([source_dict.allKeys containsObject:@"pipeSectId"]) {
                if (![_cableRouteLine_IdsArr containsObject:source_dict[@"pipeSectId"]]) {
                    [sectScreenArray addObject:source_dict];
                }
            }
            // 没有井资源 类似杆路段等
            else {
                
                // 只添加未在路由中的部分 线
                if (![_cableRouteLine_IdsArr containsObject:source_dict[@"resId"]]) {
                    [sectScreenArray addObject:source_dict];
                }
            }
            
        }
        
        
        for (NSDictionary * source_dict in pointData) {
            
            // 只添加未在路由中的部分 点
            if (![_cableRoutePoint_IdsArr containsObject:source_dict[@"resId"]]) {
                [pointScreenArray addObject:source_dict];
            }
        }
        
        
        if (sectScreenArray.count == 0 || pointScreenArray.count == 0) {
            [[Yuan_HUD shareInstance] HUDFullText:@"当前资源点暂无所属线路"];
            
            [self hidePointHandle:YES];
            return;
        }
        else {
            
            [[Yuan_HUD shareInstance] HUDFullText:@"请选中一个蓝色线路点进行穿缆"];
            // 正在穿缆中
            _VM.isCableing = true;
            
            // 配置挂缆时 起始点Id  -- 是 source_Dict 而不是 source_dict !!
            _putCableStartPointId = postDict[@"resId"];
            _putCableStartPointDict = postDict;
            
            [self hidePointHandle:NO];
            
            if (_nowSelectAnno_Symbol) {
                [_mapView setCenterCoordinate:_nowSelectAnno_Symbol.coordinate animated:YES];
                [_mapView setZoomLevel:18];
            }
            
        }
        
        
        [self loadGetLinesPoint:pointScreenArray];
        [self loadGetLinesLine:sectScreenArray];
        
        
        _VM.isCableing = YES;
        // 进入编辑模式
        [self showEditingBtn];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     (int64_t)(1 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(),  ^{
            
            
            [_mapView setCenterCoordinate:zoomTo animated:YES];
            [_mapView setZoomLevel:18 animated:YES];
            
        });
    }];
    
}



//MARK:  获取 副线路接口   --- 有待测试
- (void) http_GetAnotherLinsPort:(NSDictionary *)postDict {
    
    [self removeMapSourceExceptRoute];
    
    _myNextSelectId = @"";
    
    NSNumber * lat = postDict[@"lat"];
    NSNumber * lon = postDict[@"lon"];
    
    CLLocationCoordinate2D zoomTo = CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue);
    
    [Yuan_DC_HttpModel http_GetReleatResourceFromDict:postDict
                                              success:^(id  _Nonnull result) {
            
        NSDictionary * resDict = result;
        
        if (!resDict || [resDict obj_IsNull]) {
            return;
        }
        
        NSLog(@"%@", resDict.json);
        
        NSArray * sectData = resDict[@"sectData"];
        NSArray * pointData = resDict[@"pointData"];
        
        // 点  resName  resType
        // 线  sTypeId eTypeId
        NSMutableArray * sectScreenArray = NSMutableArray.array;
        NSMutableArray * pointScreenArray = NSMutableArray.array;
        
        
        
        // 移除已经在路由上的点和线
        for (NSDictionary * source_dict in sectData) {
            
            // 有井资源 线段属于管孔
            if ([source_dict.allKeys containsObject:@"pipeSectId"]) {
                if (![_cableRouteLine_IdsArr containsObject:source_dict[@"pipeSectId"]]) {
                    [sectScreenArray addObject:source_dict];
                }
            }
            // 没有井资源 类似杆路段等
            else {
                
                // 只添加未在路由中的部分 线
                if (![_cableRouteLine_IdsArr containsObject:source_dict[@"resId"]]) {
                    [sectScreenArray addObject:source_dict];
                }
            }
            
        }
        
        
        for (NSDictionary * source_dict in pointData) {
            
            // 只添加未在路由中的部分 点
            if (![_cableRoutePoint_IdsArr containsObject:source_dict[@"resId"]]) {
                [pointScreenArray addObject:source_dict];
            }
        }
        
        
        if (sectScreenArray.count == 0 || pointScreenArray.count == 0) {
            [[Yuan_HUD shareInstance] HUDFullText:@"当前资源点暂无其他线路"];
            [self hidePointHandle:YES];
            return;
        }
        else {
            
            [[Yuan_HUD shareInstance] HUDFullText:@"请选中一个蓝色线路点进行穿缆"];
            // 正在穿缆中
            _VM.isCableing = true;
            
            // 配置挂缆时 起始点Id  -- 是 source_Dict 而不是 source_dict !!
            _putCableStartPointId = postDict[@"resId"];
            _putCableStartPointDict = postDict;
            
            [self hidePointHandle:NO];
            
            if (_nowSelectAnno_Symbol) {
                [_mapView setCenterCoordinate:_nowSelectAnno_Symbol.coordinate animated:YES];
                [_mapView setZoomLevel:18];
            }
            
        }
        
        
        [self loadGetLinesPoint:pointScreenArray];
        [self loadGetLinesLine:sectScreenArray];
        
        
        _VM.isCableing = YES;
        // 进入编辑模式
        [self showEditingBtn];
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     (int64_t)(1 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(),  ^{
            
            
            [_mapView setCenterCoordinate:zoomTo animated:YES];
            [_mapView setZoomLevel:18 animated:YES];
            
        });
    }];
    
}



//MARK: 撤缆接口
- (void) http_deleteCable:(NSDictionary *)source_Dict {
    
    
    NSMutableArray * idsArr = NSMutableArray.array;
    
    NSDictionary * postDict = @{
        
        @"eqpId" : source_Dict[@"resId"],
        @"eqpTypeId" : source_Dict[@"resType"]
    };
    
    
    
    
    // 如果是井的时候 , 就不能这么撤缆了  , 撤的起始是管孔
    if ([source_Dict[@"resType"] isEqualToString:@"hole"]) {
        
        for (Yuan_PolyLine * line in _cableRoute_LineArr) {
            NSDictionary * dataSource = line.dataSource;
            
            NSString * sid = dataSource[@"sid"];
            NSString * eid = dataSource[@"eid"];
            
            
            // TODO: 撤缆时 找大为要管孔的数据 当前是管道段 ..
            
            if ([@[sid,eid] containsObject:source_Dict[@"resId"] ?: @""]) {
                
                // 证明这个穿的是子孔
                if ([dataSource[@"typeName"] isEqualToString:@"子孔"]) {
                    
                    postDict = @{
                        
                        @"eqpId" : dataSource[@"resId"],
                        @"eqpTypeId" : @"subHole"
                        
                    };
                }
                
                // 证明是这个管孔
                // 管孔的数据
                else {
                    
                    
                    postDict = @{
                        
                        @"eqpId" : dataSource[@"resId"],
                        @"eqpTypeId" : @"pipeHole"
                        
                    };
                    
                }
                
                break;
            }
        }
        
    }
    
    [idsArr addObject:postDict];
    
    
    
    NSDictionary * myFriendDict =
    [_VM isHaveJurisdictionHandle:_cableRoute_LineArr pointData:_cableRoute_AnnoArr myLineFacePointDict:source_Dict];
    
    // 证明我的伙伴也是把山点
    if (myFriendDict && myFriendDict.count > 0) {
        
        
        NSDictionary * friendPostDict = @{
            
            @"eqpId" : myFriendDict[@"resId"],
            @"eqpTypeId" : myFriendDict[@"resType"]
        };
        
        
        
        
        // 如果是井的时候 , 就不能这么撤缆了  , 撤的起始是管孔
        if ([myFriendDict[@"resType"] isEqualToString:@"hole"]) {
            
            for (Yuan_PolyLine * line in _cableRoute_LineArr) {
                NSDictionary * dataSource = line.dataSource;
                
                NSString * sid = dataSource[@"sid"];
                NSString * eid = dataSource[@"eid"];
                
                
                // TODO: 撤缆时 找大为要管孔的数据 当前是管道段 ..
                
                if ([@[sid,eid] containsObject:myFriendDict[@"resId"]]) {
                    
                    // 证明这个穿的是子孔
                    if ([dataSource[@"typeName"] isEqualToString:@"子孔"]) {
                        
                        postDict = @{
                            
                            @"eqpId" : dataSource[@"resId"],
                            @"eqpTypeId" : @"subHole"
                            
                        };
                    }
                    
                    // 证明是这个管孔
                    // 管孔的数据
                    else {
                        
                        postDict = @{
                            
                            @"eqpId" : dataSource[@"resId"],
                            @"eqpTypeId" : @"pipeHole"
                            
                        };
                        
                    }
                    
                    
                    break;
                }
            }
            
        }
        
        
        [idsArr addObject:friendPostDict];
    }
    
    
    
    
    // 撤缆时 如果只剩两个点了 , 他俩都走撤缆接口
    
    [Yuan_DC_HttpModel http_DeleteCableFromArray:idsArr
                                         cableId:_VM.cableId
                                         success:^(id  _Nonnull result) {
            
        
        
        
        _myNextSelectId = [_VM whosAnnoIsMySelectNext:_cableRoute_LineArr myId:source_Dict[@"resId"]];
        
        // 清除所有地图资源 (除起始终止设备点)
        [self removeAllMapSource];
        
        // 清空控制台
        [self hidePointHandle:true];
        
        // 重新获取路由
        [self http_GetCableRoute];
        
    }];
    
}




//MARK: 开始挂缆操作  -- 自动挂缆
- (void) http_PutUpCable_Auto {
    
    
    if (!_putCableStartPointId ||
        !_putCableEndPointId ||
        _putCableStartPointId.length == 0 ||
        _putCableEndPointId.length == 0) {
        
        [[Yuan_HUD shareInstance] HUDFullText:@"未获取到起止点Id"];
        return;
    }
    
    
    NSMutableDictionary * mt_Dict = NSMutableDictionary.dictionary;
    
    mt_Dict[@"routePointArray"] = _cableRoute_AnnoArr;
    mt_Dict[@"routeLineArray"] = _cableRoute_LineArr;
    
    mt_Dict[@"routeLineIdsArr"] = _cableRouteLine_IdsArr;
    mt_Dict[@"routePointIdsArr"] = _cableRoutePoint_IdsArr;
    
    mt_Dict[@"getLinesPointArray"] = _getLinesAnnoArr;
    mt_Dict[@"getLinesLineArray"] = _getLinesLineArr;
    
    mt_Dict[@"startId"] = _putCableStartPointId;
    mt_Dict[@"endId"] = _putCableEndPointId;
    
    

    
    // 需要 关联的数组  ***  重要!
    NSArray * sectResList = [_VM putCableRouteWith:mt_Dict];
    
    
    if (!sectResList || sectResList.count == 0) {
        [[Yuan_HUD shareInstance] HUDFullText:@"算路失败 , 无法与该资源点进行穿缆"];
        return;
    }
    
    // 正式进入 自动穿缆业务
    [self autoConfig:sectResList];
    
}


// 自动穿缆业务抽离
- (void) autoConfig:(NSArray *) sectResList {
    
    NSMutableDictionary * postDict = NSMutableDictionary.dictionary;
    
    postDict[@"sectResList"] = sectResList;
    postDict[@"optSectId"] = _VM.cableId;
    postDict[@"eqpId"] = _putCableStartPointDict[@"resId"];
    postDict[@"eqpTypeId"] = _putCableStartPointDict[@"resType"];
    
    //
    
    [Yuan_DC_HttpModel http_putUpCableAuto:postDict
                                   success:^(id  _Nonnull result) {
        
        NSLog(@"%@",result);
            
        
        NSDictionary * resultDict = result;
        
        NSNumber * code = resultDict[@"CODE"];
        
        if ([code obj_IsNull]) {
            
            [[Yuan_HUD shareInstance] HUDFullText:@"数据错误"];
            return;
        }
        
        if (code.intValue == 200) {
            
            [[Yuan_HUD shareInstance] HUDFullText:@"穿缆成功"];
            
            // 最后一次关联的点 作为下一次的控制台点
            _myNextSelectId = _putCableEndPointId;
                        
            [self removeAllMapSource];
            
            // 重新获取路由
            [self http_GetCableRoute];
        }
        else {
            
            [[Yuan_HUD shareInstance] HUDFullText:@"穿缆失败"];
            
            [self removeAllMapSource];
            
            // 重新获取路由
            [self http_GetCableRoute];
        }
        
        
    }];
    
    
}




//MARK: 开始挂缆操作  -- 手动挂缆
- (void) http_PutUpCable_Handle {
    
    // 手动前半部分 与自动一致
    if (!_putCableStartPointId ||
        !_putCableEndPointId ||
        _putCableStartPointId.length == 0 ||
        _putCableEndPointId.length == 0) {
        
        [[Yuan_HUD shareInstance] HUDFullText:@"未获取到起止点Id"];
        return;
    }
    
    
    NSMutableDictionary * mt_Dict = NSMutableDictionary.dictionary;
    
    mt_Dict[@"routePointArray"] = _cableRoute_AnnoArr;
    mt_Dict[@"routeLineArray"] = _cableRoute_LineArr;
    
    mt_Dict[@"routeLineIdsArr"] = _cableRouteLine_IdsArr;
    mt_Dict[@"routePointIdsArr"] = _cableRoutePoint_IdsArr;
    
    mt_Dict[@"getLinesPointArray"] = _getLinesAnnoArr;
    mt_Dict[@"getLinesLineArray"] = _getLinesLineArr;
    
    mt_Dict[@"startId"] = _putCableStartPointId;
    mt_Dict[@"endId"] = _putCableEndPointId;
    
    
    // 需要 关联的数组  ***  重要!
    NSArray * sectResList = [_VM putCableRouteWith:mt_Dict];
    
    
    if (!sectResList || sectResList.count == 0) {
        [[Yuan_HUD shareInstance] HUDFullText:@"算路失败 , 无法与该资源点进行穿缆"];
        return;
    }
    
    // 是否转为自动穿缆
    BOOL isNeedAuto = YES;
    
    for (NSDictionary * dict in sectResList) {
        
        
        NSString * stypeId = dict[@"stypeId"];
        NSString * etypeId = dict[@"etypeId"];
        
        if ([stypeId isEqualToString:@"hole"] || [etypeId isEqualToString:@"hole"]) {
            isNeedAuto = NO;
        }  
    }
    
    
    // 这批穿缆中 没有出现井资源  *** 走自动穿缆
    if (isNeedAuto) {
        
        [self autoConfig:sectResList];
    }
    
    // 正式进入手动穿缆
    else {
        
        [self handleConfig:sectResList];
    }
    
    
}


// 手动穿缆业务抽离
- (void) handleConfig:(NSArray *) sectResList {
    
    NSString * newRouteFirstPointResId = _putCableStartPointDict[@"resId"];
    
    // 从0 开始递归
    _nowIndex = 0;
    
    _sectResList = sectResList;
    
    // 证明这个起点是在已有路由上的
    if ([_cableRoutePoint_IdsArr containsObject:newRouteFirstPointResId]) {
        
        // 起点在路由上 , 就不需要传起点
        [self DiGui_Handle_StartDict:_putCableStartPointDict
                             EndDict:sectResList.firstObject
                     isNeedPostStart:false];
    }
    
    // 证明这个起点是搜索附近设备的单独点
    else {
        
        [self DiGui_Handle_StartDict:_putCableStartPointDict
                             EndDict:sectResList.firstObject
                     isNeedPostStart:true];
    }
    
}




- (void) DiGui_Handle_StartDict:(NSDictionary *) startDict
                        EndDict:(NSDictionary *) endDict
                isNeedPostStart:(BOOL)isNeed{
    
    _handleEndDict = endDict;
    
    // 当前便利到第几个了
    _nowIndex++;

    
    NSMutableArray * optOccupyList = NSMutableArray.array;
    
    BOOL isHole = NO;
    
    if ([startDict[@"resType"] isEqualToString:@"hole"] ||
        [endDict[@"resType"] isEqualToString:@"hole"] ||
        [startDict[@"stypeId"] isEqualToString:@"hole"] ||
        [startDict[@"etypeId"] isEqualToString:@"hole"] ||
        [endDict[@"stypeId"] isEqualToString:@"hole"] ||
        [endDict[@"etypeId"] isEqualToString:@"hole"]) {
        
        isHole = YES;
    }
    
    

    
    
    
    // 证明起始或终止有一个是井 , 需要手动选择管孔
    if (isHole) {
        
        
        // 先在 _getLinesLineArr 中 找出 起点终点和 这个起点终点id 重合的
        // endDict 的 resId 指的是管孔的Id , 并不是管道段的
        NSString * startId = endDict[@"sid"];
        NSString * endId = endDict[@"eid"];
        
        // 获取两点之间的管道段和管孔的数据  -- 实际是管孔的数据 ,
        NSDictionary * centerPipeSegmentDict;
        
        for (Yuan_PolyLine * line in _getLinesLineArr) {
            
            NSDictionary * singleLineDict = line.dataSource;
            
            NSString * sid = singleLineDict[@"sid"];
            NSString * eid = singleLineDict[@"eid"];
            
            // 固定出来中间的管道段和管孔
            if (([sid isEqualToString:startId] && [eid isEqualToString:endId]) ||
                ([sid isEqualToString:endId] && [eid isEqualToString:startId])) {
                
                centerPipeSegmentDict = singleLineDict;
                break;
            }
        }
        
        
        if (!centerPipeSegmentDict) {
            [[Yuan_HUD shareInstance] HUDFullText:@"关联错误, 未获取到两点间的管道段"];
            return;
        }
       
        //TODO: 第一处修改
        // 获取到所属管道段的Id , 通过管道段要查询下属管孔有哪些  之前是 pipeSectId
        NSString * belongPipeSectId = centerPipeSegmentDict[@"resId"];
        
        
        // 都是取 endDict , 没错 !!  因为endDict 对应的是管道段 , 有起始终止设备
        _nowHandlePutCablePost_StartDict = @{
            @"eqpId" : endDict[@"sid"],
            @"eqpTypeId" : endDict[@"stypeId"] ,
            @"optSectId" : _VM.cableId
        };
        
        _nowHandlePutCablePost_EndDict = @{
            
            @"eqpId" : endDict[@"eid"],
            @"eqpTypeId" : endDict[@"etypeId"] ,
            @"optSectId" : _VM.cableId
        };
        
        
        // 发送网络请求  通过管道段Id 查询下属管孔都有哪些
        [self http_SegmentIdSearchTube:belongPipeSectId];
        
        
    }
    
    // 如果两个都不是井 , 就不涉及管孔信息 , 直接传就行  直接开始网络请求
    else {
        
        NSDictionary * startPostDict = @{
            @"eqpId" : endDict[@"sid"],
            @"eqpTypeId" : endDict[@"stypeId"] ,
            @"optSectId" : _VM.cableId
        };
        
        NSDictionary * endPostDict = @{
            @"eqpId" : endDict[@"eid"],
            @"eqpTypeId" : endDict[@"etypeId"] ,
            @"optSectId" : _VM.cableId
        };
        
        // 传起始和终止设备
        [optOccupyList addObject:startPostDict];
        [optOccupyList addObject:endPostDict];
        
        [self handlePort_Http:optOccupyList success:^{
            
            
            // 结束递归  否则就越界了 老哥
            if (_nowIndex > _sectResList.count - 1) {
                _nowIndex = 0;
                
                // 结束递归
                [self handleEndDiGui];
                
                return;
            }
            
            // 获取下一次递归时的终止设备 , 一会儿用
            NSDictionary * nextDict = _sectResList[_nowIndex];
            
            // 再进行递归
            [self DiGui_Handle_StartDict:_handleEndDict EndDict:nextDict isNeedPostStart:NO];
        }];
    }
}



// 发送最终穿缆数据
- (void) handlePort_Http:(NSArray *) postArr
                 success:(void(^)(void))success{
    
    
    [Yuan_DC_HttpModel http_putUpCableHands_FromArray:postArr
                                              success:^(id  _Nonnull result) {
        
        NSArray * DATAS = result[@"DATAS"];
        NSDictionary * singleDict = DATAS.firstObject;
        NSString * mess = singleDict[@"MESS"];
        
        if ([mess isEqualToString:@"新增成功"]) {
            if (success) {
                success();
            }
        }
        else {
            
            [[Yuan_HUD shareInstance] HUDFullText:mess];
        }
            
            
        
        

    }];
}





//MARK: 通过管道段Id 查询下属管孔数据

- (void) http_SegmentIdSearchTube:(NSString *)pipeSegmentId {
    
    [Yuan_DC_HttpModel http_GetFatherTubeFromId:pipeSegmentId
                                        success:^(id  _Nonnull result) {
       
        // 拿到数据 ,  是当前管道段对应的下属管孔的数据 , 如果有子孔的话 , 在管孔的map 里有 subHoleList字段
        NSArray * nowPipeSegment_SubTubeArr = result;
        // 唤醒管孔配置界面
        [self showTubeHandle:nowPipeSegment_SubTubeArr pipeId:pipeSegmentId];
    }];
}



//MARK: 选择穿缆的管孔 , 成功后再次递归

- (void) http_ChooseTube:(NSDictionary *) tubeDict {
    
    
    [UIAlert alertSmallTitle:@"是否选中此管孔进行穿缆配置"
               agreeBtnBlock:^(UIAlertAction *action) {
        
        NSDictionary * tubePostDict = @{
            
            @"eqpId" : tubeDict[@"resId"],
            @"eqpTypeId" : tubeDict[@"resType"] ,
            @"optSectId" : _VM.cableId
            
        };
        
        
        NSMutableArray * postArr = NSMutableArray.array;
        
        // 传起始点终止点和管孔 , 如果起始终止点是井 'hole' 则不传
        
        if (![_nowHandlePutCablePost_StartDict[@"eqpTypeId"] isEqualToString:@"hole"]) {
            [postArr addObject:_nowHandlePutCablePost_StartDict];
        }
        
        if (![_nowHandlePutCablePost_EndDict[@"eqpTypeId"] isEqualToString:@"hole"]) {
            [postArr addObject:_nowHandlePutCablePost_EndDict];
        }
        
        
        [postArr addObject:tubePostDict];
        
        
        [self handlePort_Http:postArr success:^{
                
            // 结束递归  否则就越界了 老哥
            if (_nowIndex > _sectResList.count - 1) {
                _nowIndex = 0;
                
                // 结束递归
                [self handleEndDiGui];
                
                return;
            }
            
            // 获取下一次递归时的终止设备 , 一会儿用
            NSDictionary * nextDict = _sectResList[_nowIndex];
            
            // 再进行递归
            [self DiGui_Handle_StartDict:_handleEndDict EndDict:nextDict isNeedPostStart:NO];
            
        }];
    }];
 
}


- (void) handleEndDiGui {
    
    // 退出编辑状态
    _VM.isCableing = NO;
    
    [self hideTubeHandle];
    
    [self removeMapSourceExceptRoute];
    
    [self http_GetCableRoute];
}





#pragma mark - 关联起止终止设备 ---

- (void) http_ConnectStartEndDevice:(NSDictionary *) dict {
    
//    _pointHandle.myDict;  当点
    // dict  起始或终止设备点
    
    // 和之前的关联方式不同 在于 之前会返回线的  , 现在 是在两点之间新建一条线段
    
    
    NSArray * sectResList = @[
    
    
        
    ];
    
    
    
    NSMutableDictionary * postDict = NSMutableDictionary.dictionary;
    
    postDict[@"sectResList"] = sectResList;
    postDict[@"optSectId"] = _VM.cableId;
    postDict[@"eqpId"] = _putCableStartPointDict[@"resId"];
    postDict[@"eqpTypeId"] = _putCableStartPointDict[@"resType"];
    
    
    
    
}



#pragma mark - 全部撤缆

- (void) http_AllDeleteRoute:(NSDictionary *) param {
    
    [Inc_DC_HttpModel1 http_AllDeleteRoute:param success:^(id  _Nonnull result) {
        
        if (result) {
           
            // 清除所有地图资源 (除起始终止设备点)
            [self removeAllMapSource];
            
            // 清空控制台
            [self hidePointHandle:true];
            
            // 重新获取路由
            [self http_GetCableRoute];
            
        }
    }];
    
    
    
}



#pragma mark -  UI  ---

- (MAMapView *)mapView {
    
    if (!_mapView) {
        
        _mapView = [UIView mapViewAndDelegate:self
                                        frame:CGRectNull];
    
        _mapView.zoomLevel = 11;
    }
    return _mapView;
}


#pragma mark - 开始拖动和结束拖动 ---


- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction {
    
    if (!wasUserAction) {
        return;
    }
    
    if (_isCircleCenter) {
        
        [self hideCenterCircle];
        [self showCenterCircle];
    }
    
    
}




#pragma mark -  加载资源点 --
- (MAAnnotationView *)mapView:(MAMapView *)mapView
            viewForAnnotation:(id<MAAnnotation>)annotation
{
    
    if ([annotation isKindOfClass:[MAUserLocation class]]) {
        return nil;
    }
    
    
    Yuan_PointAnnotation * yuan_anno = (Yuan_PointAnnotation *) annotation;
    
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        
        
        static NSString *busStopIdentifier = @"yuan_anno";

        
        MAAnnotationView *annotationView = (MAAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:busStopIdentifier];
        
        if (annotationView == nil) {
            
           annotationView =
           [[MAAnnotationView alloc] initWithAnnotation:yuan_anno
                                        reuseIdentifier:busStopIdentifier];
       }
        
        
        
        switch (yuan_anno.dc_Type) {
            case DC_AnnoPointType_StartEndPoint:    //起点和终点
                annotationView.image = [UIImage Inc_imageNamed:[self getImageName:yuan_anno.dataSource[@"typeId"]]];
                break;
                
            case DC_AnnoPointType_None:             // 定位点
                annotationView.image = [UIImage Inc_imageNamed:@"DC_shizi"];
                
                for (UIView * view in annotationView.subviews) {
                    if ([view.class isEqual:[UILabel class]]) {
                        view.hidden = YES;
                    }
                }
                
                break;
            
            case DC_AnnoPointType_SelectSympol:     // 选中的点
                annotationView.image = [UIImage Inc_imageNamed:@"icon_XJ_xuanzhong"];
                
                for (UIView * view in annotationView.subviews) {
                    if ([view.class isEqual:[UILabel class]]) {
                        view.hidden = YES;
                    }
                }
                
                break;
            default:
                break;
        }
        
        
        
        
        if (yuan_anno.dc_Type == DC_AnnoPointType_StartEndPoint) {
            
            // 新版 楼宇资源点下方有楼宇名称
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectNull];
                        
            label.text = yuan_anno.dataSource[@"name"] ?: @"";
            label.backgroundColor = Color_V2Red;

            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:13];

            label.numberOfLines = 0;//根据最大行数需求来设置

            label.lineBreakMode = NSLineBreakByTruncatingTail;

            CGSize maximumLabelSize = CGSizeMake(200, 9999);//labelsize的最大值

            //关键语句

            CGSize expectSize = [label sizeThatFits:maximumLabelSize];
                
            [label autoSetDimensionsToSize:CGSizeMake(expectSize.width, expectSize.height)];
        
            [annotationView addSubview:label];
            
            [label autoPinEdge:ALEdgeBottom
                             toEdge:ALEdgeTop
                             ofView:annotationView
                         withOffset:- 2];
            
            [label YuanAttributeVerticalToView:annotationView];
            
        }
        
        
        
        
        return annotationView;
    }
    
    return nil;
}



#pragma mark -  线资源 海量点  ---
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView
            rendererForOverlay:(id<MAOverlay>)overlay
{
    
    
    // 线段
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        
        Yuan_PolyLine * yuan_Line = (Yuan_PolyLine *)overlay;
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:yuan_Line];
        
        polylineRenderer.lineWidth   = 4.f;
        polylineRenderer.strokeColor = ColorValue_RGB(0x000000);
        
        
        switch (yuan_Line.dc_Type) {
                
            case DC_AnnoPointType_GetLinesPoint:
                polylineRenderer.strokeColor = UIColor.blueColor;
                break;
                
            case DC_AnnoPointType_RoutePoint:
                polylineRenderer.strokeColor = UIColor.orangeColor;
                break;
                
            default:
                break;
        }
        
        return polylineRenderer;
    }
    
    
    // 圆环
    if ([overlay isKindOfClass:[MACircle class]])
    {
        
        MACircleRenderer *circleRenderer = [[MACircleRenderer alloc] initWithCircle:overlay];
        
        circleRenderer.lineWidth    = 0;
        
        circleRenderer.fillColor    = [UIColor colorWithRed:0 green:188/255.0 blue:180/255.0 alpha:0.2];
        
        return circleRenderer;
    }
    
    
    
    
    
    // 海量点
    if ([overlay isKindOfClass:[MAMultiPointOverlay class]])
    {
        MAMultiPointOverlayRenderer * renderer = [[MAMultiPointOverlayRenderer alloc] initWithMultiPointOverlay:overlay];
        
        ///设置锚点
        renderer.anchor = CGPointMake(0.5, 1.0);
        renderer.delegate = self;
        
        Yuan_PointOverlay * overlay_Yuan = (Yuan_PointOverlay *)renderer.overlay;
        
        NSArray <MAMultiPointItem *> * items = overlay_Yuan.items;
        
        for (MAMultiPointItem * yuan_Item in items) {
                
            Yuan_MultiPointItem * yuan_anno = (Yuan_MultiPointItem *) yuan_Item;

            UIImage * img ;
            
            switch (overlay_Yuan.overlayState) {
                // 路由
                case DC_MultiPointOverlayState_Route:
                    img = [UIImage Inc_imageNamed:@"icon_SI_anno_completed"];
                    break;
                    
                // 线路
                case DC_MultiPointOverlayState_Lines:
                // 散点
                case DC_MultiPointOverlayState_Single:
                    
                    
                    img = [UIImage Inc_imageNamed:@"icon_SI_anno_normal"];
                    break;
                    
                default:
                    img = [UIImage Inc_imageNamed:@"icon_SI_anno_completed"];
                    break;
            }
            
            
//            renderer.icon = [UIImage Inc_imageNamed:@"icon_SI_anno_completed"];
            
            renderer.icon = img;
            
            NSDictionary * dataSource = yuan_anno.dataSource;
            
            // 如果 撤缆或穿缆 重新加载路由后 发现这个点是我下一个需要选中的点时 , 模拟它的点击事件
            if ([dataSource[@"resId"] isEqualToString:_myNextSelectId]) {
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                             (int64_t)(1 * NSEC_PER_SEC)),
                               dispatch_get_main_queue(),  ^{
                    
                    [self multiPointOverlayRenderer:renderer didItemTapped:yuan_Item];
                });
            }
        }
        
        return renderer;
    }
    
    return nil;
}



#pragma mark -  资源点的点击事件  ---

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view {
    
    
    // 如果点击的是 定位小蓝点的话 直接return
    if ([view.class isEqual:NSClassFromString(@"MAUserLocationView")]) {
    
        return;
    }
    
    
    
    // 点击 立即取消选中状态
    [mapView deselectAnnotation:view.annotation animated:true];
    
    Yuan_PointAnnotation * yuan_anno = (Yuan_PointAnnotation *)view.annotation;
    
    if (yuan_anno.dc_Type == DC_AnnoPointType_StartEndPoint) {
    
        return;
        
        BOOL isInRoute = [_VM isStartEndDevice_IsInRoute:_cableRoute_LineArr deviceDict:yuan_anno.dataSource];
        
        NSDictionary * source_Dict = yuan_anno.dataSource;
        
        DC_AnnoPointType_ dcType = yuan_anno.dc_Type;
        
        [_mapView setCenterCoordinate:yuan_anno.coordinate animated:YES];
        [_mapView setZoomLevel:18 animated:true];
        
        // 已在路由中 , 那么你是要撤缆么?
        if (isInRoute) {
            [self showPointHandle:source_Dict dcType:dcType];
        }
        else {
            [YuanHUD HUDFullText:@"当前设备未接入路由中,请选中一端路由进行关联设备"];
        }
        
    }
}


///MARK: 海量点的点击事件

- (void)multiPointOverlayRenderer:(MAMultiPointOverlayRenderer *)renderer
                    didItemTapped:(MAMultiPointItem *)item {
        
    //获取资源map
    Yuan_MultiPointItem * yuan_anno = (Yuan_MultiPointItem *) item;
    
    DC_AnnoPointType_ dcType = yuan_anno.dc_Type;
    NSDictionary * source_Dict = yuan_anno.dataSource;
    
    
    // 当开始挂缆时 只能选中一个获取线路点进行操作
    // 编辑状态下 , 可以选中的点 包括 -- 所属路线的点 , 路由的把山点
    if (_VM.isCableing ) {
        
        if (dcType == DC_AnnoPointType_RoutePoint) {
            
            // 判断当前选中的点 是不是把山点 , 只有把山点才可以选中
            BOOL isHaveQX = [_VM isHaveJurisdictionHandle:_cableRoute_LineArr myDict:source_Dict];
            
            if (!isHaveQX) {
                [[Yuan_HUD shareInstance] HUDFullText:@"请选中一个所属线路上的点进行挂缆"];
                return;
            }
            
        }
        
        
        NSString * msg = [NSString stringWithFormat:@"是否选中(%@)资源进行挂缆, 如果挂缆起始点中间有多个资源,会进行批量挂缆",source_Dict[@"resName"]];
        
        [UIAlert alertSmallTitle:msg
                   agreeBtnBlock:^(UIAlertAction *action) {
               
            // 作为终点
            _putCableEndPointId = source_Dict[@"resId"];
            _putCableEndPointDict = source_Dict;
            
            // 终点Id 作为下一次的选中点Id
            _myNextSelectId = _putCableEndPointId;
            
            // 自动还是手动 挂缆
            if (_VM.isAutoConfigTube) {
                
                // 自动挂缆
                [self http_PutUpCable_Auto];
            }
            
            else {
                // 手动挂缆
                [self http_PutUpCable_Handle];
            }
            
            
            
        }];
        
        return;
    }
    
    
    NSLog(@"-- %@",source_Dict);
    
    // 控制台
    [self showPointHandle:source_Dict dcType:dcType];
    
    // 圆环  标志点击点位置
    [self circle_Init:yuan_anno];
    
}




#pragma mark - pointHandle 显示和隐藏 ---


- (void) showPointHandle:(NSDictionary *) pointDict dcType:(DC_AnnoPointType_)dcType{
    
    // 先隐藏
    [self hidePointHandle:YES];
    
    
    if (dcType == DC_AnnoPointType_None ||              //啥也不是
        dcType == DC_AnnoPointType_GetLinesPoint)       //获取线路点
    {
        return;
    }
     
    
    
    // 选中标记  五角星标记
    [self addSymbolPoint:pointDict];
    
    
    
    if (!_pointHandle) {
        
        // 当前选中的Id
        _nowSelectId = pointDict[@"resId"];
        
        // 当前显示的类型是什么
        _nowShowDCType = dcType;
        
        __typeof(self)weakSelf = self;
        
        _pointHandle = [[Yuan_DC_PointHandleView alloc] initWithBtnHandlesBlock:^(DC_PointHandle_ handleType) {
            
            switch (handleType) {
                    
                case DC_PointHandle_Cancel:         // 关闭
                    [weakSelf hidePointHandle:YES];
                    break;
                    
                case DC_PointHandle_GetRoute:       // 线路
                    [weakSelf getRouteClick:_pointHandle.myDict];
                    break;
                
                case DC_PointHandle_GetAnotherLines:    //获取其他线路
                    [weakSelf getAnotherLinesClick:_pointHandle.myDict];
                    break;
                
                case DC_PointHandle_DeleteCable:    // 撤缆
                    [weakSelf deleteCableClick:_pointHandle.myDict];
                    break;
                
                case DC_PointHandle_ConnectDevice:  //关联起始设备
                    [weakSelf connectStartEndDevice:_pointHandle.myDict];
                    break;
          
                default:
                    break;
            }
        }];
        
        // 判断是否是 把山的资源点  只有他们才有操作权限
        BOOL isHaveQX = [_VM isHaveJurisdictionHandle:_cableRoute_LineArr myDict:pointDict];
        
        
        float height = Vertical(150);
        
        // 如果是路由点 并且你没有权限 那么 隐藏所有操作点
        if (dcType == DC_AnnoPointType_RoutePoint && !isHaveQX) {
            height = Vertical(100);
            [_pointHandle btnsHide];
        }
        
        
        
        [self addSubview:_pointHandle];
        
        [_pointHandle autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
        [_pointHandle autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
        [_pointHandle autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
        [_pointHandle autoSetDimension:ALDimensionHeight toSize:height];
        
        
        // 根据资源点的类型 确认他该显示什么样的状态
        [_pointHandle reloadHandleDict:pointDict dcType:dcType];
        
    }
}



#pragma mark - pointHandle 点击事件 ---


// 关闭
- (void) hidePointHandle:(BOOL) isClearSympol {
    
    if (_pointHandle) {
        
        if (isClearSympol) {
            [self removeSymbolAnnotation];  // 移除
            
        }

        [_pointHandle removeFromSuperview];
        _pointHandle = nil;
    }
}


// 获取线路
- (void) getRouteClick:(NSDictionary *)source_Dict {
    

    [self http_GetPointLines:source_Dict];
}


// 获取其他线路
- (void) getAnotherLinesClick:(NSDictionary *)source_Dict {
    
    [self http_GetAnotherLinsPort:source_Dict];
}


// 撤缆
- (void) deleteCableClick:(NSDictionary *)source_Dict {
    
    [self http_deleteCable:source_Dict];
}


// 关联设备
- (void) connectStartEndDevice:(NSDictionary *)source_Dict {
    
    
    NSDictionary * startDict;
    NSDictionary * endDict;
    
    for (Yuan_PointAnnotation * anno in _cableStartEndAnnoArr) {
        
        NSDictionary * dict = anno.dataSource;
        
        if ([dict[@"position"] isEqualToString:@"start"]) {
            startDict = dict;
        }
        
        else if ([dict[@"position"] isEqualToString:@"end"]) {
            endDict = dict;
        }
        
        else {
            startDict = dict;
        }
        
    }
    
    
    if (!startDict || !endDict) {
        [YuanHUD HUDFullText:@"缺少起始终止设备数据 , 无法进行关联"];
        return;
    }
    
    
    [UIAlert alertSmallActionSheetTitle:@"请选择关联的设备"
                                     vc:_vc
                             firstTitle:@"关联起始设备"
                            secondTitle:@"关联终止设备"
                          firstBtnBlock:^(UIAlertAction *action) {
            
        NSString * name = startDict[@"name"];
        NSString * msg = [NSString stringWithFormat:@"是否关联%@",name];
        
        [UIAlert alertSmallTitle:msg vc:_vc agreeBtnBlock:^(UIAlertAction *action) {
            [self http_ConnectStartEndDevice:source_Dict];
        }];
        
    } secondBtnBlock:^(UIAlertAction *action) {
        
        NSString * name = endDict[@"name"];
        NSString * msg = [NSString stringWithFormat:@"是否关联%@",name];
        
        [UIAlert alertSmallTitle:msg vc:_vc agreeBtnBlock:^(UIAlertAction *action) {
            [self http_ConnectStartEndDevice:source_Dict];
        }];
        
    }];
}








#pragma mark - 管孔控制台显示 ---

- (void) showTubeHandle:(NSArray *)pipeData pipeId:(NSString *) pipeId{
    
    
    if (pipeData.count == 0) {
        
        [YuanHUD HUDFullText:@"当前管道段下无管孔 , 建议修改为自动穿缆后重试"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     (int64_t)(1 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(),  ^{
            
            [self hideTubeHandle];
        });
        
        return;
    }
    
    
    if (!_tubeHandle) {
        _tubeHandle = [[Yuan_DC_TubeHandleView alloc] init];
        
        
        [self addSubview:_tubeHandle];
        
        [_tubeHandle autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
        [_tubeHandle autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
        [_tubeHandle autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
        [_tubeHandle autoSetDimension:ALDimensionHeight toSize:Vertical(200)];
    }
    
    
    [_tubeHandle reloadWithArray:pipeData];
    
    NSString * name;
    
    for (Yuan_PolyLine * line in _getLinesLineArr) {
        NSDictionary * dict = line.dataSource;
        NSString * Id = dict[@"resId"];
        
        if ([pipeId isEqualToString:Id]) {
            name = dict[@"resName"];
            break;
        }
    }

    if (name) {
        [_tubeHandle pipeName:name];
    }
    
    
    
    for (Yuan_PolyLine * line in _getLinesLineArr) {
        
        NSDictionary * lineDict = line.dataSource;
        
        NSString * line_PipeId = lineDict[@"pipeSectId"];
        
        if ([line_PipeId isEqualToString:pipeId]) {
            NSString * line_PipeName = lineDict[@"pipeSectName"];
            [_tubeHandle pipeName:line_PipeName];
        }
        
    }
    
    
    
    __typeof(self)weakSelf = self;
    
    // 关闭事件
    _tubeHandle.cancelBlock = ^{
        [weakSelf hideTubeHandle];
    };
    
    
    // 成功选取了穿缆管孔
    _tubeHandle.chooseTubeBlock = ^(NSDictionary * _Nonnull tubeDict) {
        [weakSelf http_ChooseTube:tubeDict];
    };
    
    
    [[Yuan_HUD shareInstance] HUDFullText:@"请选择您想穿缆的管孔,如果管孔有下属子孔,需要和子孔进行穿缆"];
    
}


- (void) hideTubeHandle {
    
    if (_tubeHandle) {
        [_tubeHandle removeFromSuperview];
        _tubeHandle = nil;
        
        // 结束递归
        [self handleEndDiGui];
    }
}




#pragma mark - 取消编辑按钮 ---


- (UIButton *) endEditingBtn {
    
    if (!_endEditingBtn) {
        
        _endEditingBtn = [UIView buttonWithImage:@"DC_EndEditing"
                                       responder:self
                                       SEL_Click:@selector(endEndingClick)
                                           frame:CGRectNull];
    }
    return _endEditingBtn;
}



- (void) showEditingBtn {
    
    
    
    // 进入编辑状态
    [self addSubview:self.endEditingBtn];
    [_endEditingBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:Horizontal(15)];
    [_endEditingBtn YuanAttributeVerticalToView:self];
}


- (void) hideEndEditingBtn {
    
    if (!_endEditingBtn) {
        return;
    }
    
    _VM.isCableing = NO;
    
    [_endEditingBtn removeFromSuperview];
    _endEditingBtn = nil;
    
}


// 点击事件
- (void) endEndingClick {
    
    [UIAlert alertSmallTitle:@"是否退出编辑状态?"
               agreeBtnBlock:^(UIAlertAction *action) {
            
        // 退出编辑状态
        [self hideEndEditingBtn];
        
        [self removeMapSourceExceptRoute];
        
        [self http_GetCableRoute];
        
    }];
    
    
    
}




#pragma mark - 添加或移除资源点 ---


//MARK: 加载起始终止设备
- (void) loadStartEnd:(NSArray *) startEndDeviceArray {

    
    for (NSDictionary * source_dict in startEndDeviceArray) {
        
        
        Yuan_PointAnnotation * yuan_anno = Yuan_PointAnnotation.alloc.init;

        yuan_anno.dataSource = source_dict;
        
        yuan_anno.title = source_dict[@"resName"];
        
        yuan_anno.isStartOrEndPoint = false;

        double lat = [source_dict[@"lat"] doubleValue];
        double lon = [source_dict[@"lon"] doubleValue];

        yuan_anno.coordinate = CLLocationCoordinate2DMake(lat, lon);
        
        yuan_anno.isStartOrEndPoint = true;
        
        // 拿到起始终止设备Id
        if ([source_dict[@"position"] isEqualToString:@"start"]) {
            _startDeviceId = source_dict[@"id"];
        }
        
        
        if ([source_dict[@"position"] isEqualToString:@"end"]) {
            _endDeviceId = source_dict[@"id"];
        }
        
        
        // 附近的散点
        yuan_anno.dc_Type = DC_AnnoPointType_StartEndPoint;
        
        [_cableStartEndAnnoArr addObject:yuan_anno];
    }
    
    [_mapView addAnnotations:_cableStartEndAnnoArr];
    
}




//MARK: 加载路由资源
- (void) loadView:(NSDictionary *) resDict {
    

    
    NSArray * sectData = resDict[@"sectData"];
    NSArray * pointData = resDict[@"pointData"];
    
    if (sectData.count == 0 && pointData.count == 0) {
        [YuanHUD HUDFullText:@"未获取到路由数据"];
        return;
    }
    
    // 延迟处理
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 (int64_t)(0.5 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),  ^{
        
            
        [self loadAnnotation:pointData];
        [self addLines:sectData dcType:DC_AnnoPointType_RoutePoint];
    });
}


- (void) loadAnnotation:(NSArray *) annotationArrays {
    
    [self addAnnotations:annotationArrays dcType:DC_AnnoPointType_RoutePoint];
}










#pragma mark - 加载获取线路资源点和线 ---

- (void) loadGetLinesPoint:(NSArray *) annotationArrays {
    
    [self addAnnotations:annotationArrays dcType:DC_AnnoPointType_GetLinesPoint];
}


- (void) loadGetLinesLine:(NSArray *) lineArrays {
    
    [self addLines:lineArrays dcType:DC_AnnoPointType_GetLinesPoint];
}



#pragma mark - 创建地图资源总成 ---


// 线
- (void) addLines:(NSArray *) lineArrays dcType:(DC_AnnoPointType_) dcType{
    
    NSMutableArray * arr = NSMutableArray.array;
    
    for (NSDictionary * source_dict in lineArrays) {
        
        NSNumber * sLon = source_dict[@"slon"];
        NSNumber * sLat = source_dict[@"slat"];
        
        NSNumber * eLon = source_dict[@"elon"];
        NSNumber * eLat = source_dict[@"elat"];
        
        CLLocationCoordinate2D sCoor = CLLocationCoordinate2DMake(sLat.doubleValue, sLon.doubleValue);
        
        CLLocationCoordinate2D eCoor = CLLocationCoordinate2DMake(eLat.doubleValue, eLon.doubleValue);
            
        CLLocationCoordinate2D coors[2] = {0};
        coors[0] = sCoor;
        coors[1] = eCoor;
    
        
        // 获取 keys
        if (dcType == DC_AnnoPointType_RoutePoint) {
            
            if ([source_dict.allKeys containsObject:@"pipeSectId"]) {
                [_cableRouteLine_IdsArr addObject:source_dict[@"pipeSectId"]];
            }
            else {
                [_cableRouteLine_IdsArr addObject:source_dict[@"resId"]];
            }
        }
        // pipeSectId
        Yuan_PolyLine * yuan_Line = [Yuan_PolyLine polylineWithCoordinates:coors count:2];
        
        yuan_Line.dataSource = source_dict;
        yuan_Line.startCoor = sCoor;
        yuan_Line.endCoor = eCoor;
        
        yuan_Line.dc_Type = dcType;
        
        [arr addObject:yuan_Line];
        
    }
    
    
    switch (dcType) {
        case DC_AnnoPointType_RoutePoint:
            
            // 如果之前有数据 , 那么先清空路由线路数据
            if (_cableRoute_LineArr.count > 0) {
                [_mapView removeOverlays:_cableRoute_LineArr];
            }
            
            _cableRoute_LineArr  = arr;
            break;
        
        case DC_AnnoPointType_GetLinesPoint:
            _getLinesLineArr = arr;
            break;
            
        default:
            break;
    }
    
    [_mapView addOverlays:arr level:MAOverlayLevelAboveRoads];
    
}


// 加载资源点
- (void) addAnnotations:(NSArray *) annoArray dcType:(DC_AnnoPointType_) dcType {
    
    NSMutableArray * arr = NSMutableArray.array;
    
    for (NSDictionary * source_dict in annoArray) {
        
        
        Yuan_MultiPointItem * yuan_anno = Yuan_MultiPointItem.alloc.init;

        yuan_anno.dataSource = source_dict;
        
        yuan_anno.title = source_dict[@"resName"];
        
        double lat = [source_dict[@"lat"] doubleValue];
        double lon = [source_dict[@"lon"] doubleValue];

        yuan_anno.coordinate = CLLocationCoordinate2DMake(lat, lon);
        
        // 获取 keys
        if (dcType == DC_AnnoPointType_RoutePoint) {
            [_cableRoutePoint_IdsArr addObject:source_dict[@"resId"]];
        }
        
        
        if (dcType == DC_AnnoPointType_circleRadiusPoint) {
            if ([_cableRoutePoint_IdsArr containsObject:source_dict[@"resId"]]) {
                continue;
            }
        }
        
        
        // 附近的散点
        yuan_anno.dc_Type = dcType;
        
        [arr addObject:yuan_anno];
    }
    
    
    Yuan_PointOverlay * overlay;
    
    switch (dcType) {
            
        case DC_AnnoPointType_RoutePoint:               //路由
            
            // 先清空路由点数据
            if (_routeOverlay) {
                [_mapView removeOverlay:_routeOverlay];
            }

            _cableRoute_AnnoArr = arr;
            overlay = [[Yuan_PointOverlay alloc] initWithMultiPointItems:arr];
            _routeOverlay = overlay;
            overlay.overlayState = DC_MultiPointOverlayState_Route;
            break;
            
        case DC_AnnoPointType_circleRadiusPoint:        //附近资源
            _circleRadiusAnnoArr = arr;
            overlay = [[Yuan_PointOverlay alloc] initWithMultiPointItems:arr];
            _circleRadiusOverlay = overlay;
            overlay.overlayState = DC_MultiPointOverlayState_Single;
            break;
            
        case DC_AnnoPointType_GetLinesPoint:            //获取线路
            
            _getLinesAnnoArr = arr;
            overlay = [[Yuan_PointOverlay alloc] initWithMultiPointItems:arr];
            _getLinesPointOverlay = overlay;
            overlay.overlayState = DC_MultiPointOverlayState_Lines;
            break;
            
        default:
            break;
    }
    
    
    [self addOverlay:overlay level:MAOverlayLevelAboveLabels];
}




- (void)  addOverlay:(Yuan_PointOverlay *) overlay level:(MAOverlayLevel)level{
    
    
    if (overlay.items.count == 0) {
        [YuanHUD HUDFullText:@"暂无数据"];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [_mapView addOverlay:overlay level:level];
        [_mapView showOverlays:@[overlay] animated:NO];
    });
}


- (void) addSymbolPoint:(NSDictionary *)pointDict {
    
    [self removeSymbolAnnotation];
    
    _nowSelectAnno_Symbol = [[Yuan_PointAnnotation alloc] init];

    double lat = [pointDict[@"lat"] doubleValue];
    double lon = [pointDict[@"lon"] doubleValue];
    _nowSelectAnno_Symbol.coordinate = CLLocationCoordinate2DMake(lat, lon);
    _nowSelectAnno_Symbol.dc_Type = DC_AnnoPointType_SelectSympol;
    [_mapView addAnnotation:_nowSelectAnno_Symbol];
    
    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(lat, lon) animated:true];
    [_mapView setZoomLevel:18];
    
}


- (void) removeSymbolAnnotation {
    
    [_mapView removeAnnotation:_nowSelectAnno_Symbol];
    _nowSelectAnno_Symbol = nil;
    
    [_mapView removeOverlay:_circle];
    _circle = nil;
}


#pragma mark - 清空所有资源 ---

// 清空全部资源
- (void) removeAllMapSource {
    
    // 选中点 标记点
    [self removeSymbolAnnotation];
    
    // 路由点和线
    [_mapView removeOverlays:_cableRoute_LineArr];
    [_mapView removeOverlay:_routeOverlay];

    // 附近资源点的
    [_mapView removeOverlay:_circleRadiusOverlay];
    
    
    // 移除获取线路得到的点和线
    [_mapView removeOverlay:_getLinesPointOverlay];
    [_mapView removeOverlays:_getLinesLineArr];
    
    
    // 数据
    [_cableRoute_LineArr removeAllObjects];
    [_cableRoute_AnnoArr removeAllObjects];
    [_circleRadiusAnnoArr removeAllObjects];
}



// 清空除了路由外的一切资源
- (void) removeMapSourceExceptRoute {
    
    // 清空所有 附近资源
    [_mapView removeOverlay:_circleRadiusOverlay];
    [_circleRadiusAnnoArr removeAllObjects];
    
    // 移除获取线路得到的点和线
    [_mapView removeOverlay:_getLinesPointOverlay];
    [_mapView removeOverlays:_getLinesLineArr];
    
    // 清空
    [_getLinesLineArr removeAllObjects];
    [_getLinesAnnoArr removeAllObjects];
    
}

// 圆环
- (void) circle_Init:(Yuan_MultiPointItem *)yuan_anno {
    
    // 先清空
    if (_circle) {
        [_mapView removeOverlay:_circle];
        _circle = nil;
    }
    
    
    _circle = [[MACircle alloc] init];
    
    // 圆心坐标
    _circle.coordinate = yuan_anno.coordinate;
    _circle.radius = 30;
    [_mapView addOverlay:_circle level:MAOverlayLevelAboveRoads];
    
    [_mapView setCenterCoordinate:yuan_anno.coordinate animated:true];
    [_mapView setZoomLevel:18];
    
}



// 显示和隐藏 中心点圆环
- (void) showCenterCircle  {
    
    _isCircleCenter = YES;
    CLLocationCoordinate2D mapCenterCoor = _mapView.region.center;
    
    _center_Anno = Yuan_PointAnnotation.alloc.init;
    _center_Anno.coordinate = mapCenterCoor;
    _center_Anno.dc_Type = DC_AnnoPointType_None;
    [_mapView addAnnotation:_center_Anno];

    
    _centerCircle_1000m = MACircle.alloc.init;
    _centerCircle_1000m.coordinate = mapCenterCoor;
    _centerCircle_1000m.radius = 1000;
    [_mapView addOverlay:_centerCircle_1000m level:MAOverlayLevelAboveRoads];
}



- (void) hideCenterCircle {
    
    _isCircleCenter = NO;
    
    [_mapView removeAnnotation:_center_Anno];
    [_mapView removeOverlay:_centerCircle_1000m];
    
}


/// 根据id显示起始终止设备icon图片
/// @param typeId  设备类型id
-(NSString *)getImageName:(NSString *)typeId {
    
    NSString *imgName;
    
    switch ([typeId intValue]) {
        //odf
        case 302:
            imgName = @"DC_Anno_ODF";
            break;
        //接头
        case 705:
            imgName = @"DC_Anno_Joint";
            break;
        //odb
        case 704:
            imgName = @"DC_Anno_ODB";
            break;
       //机房
        case 205:
            imgName = @"DC_Anno_generator";
            break;
        //occ
        case 703:
            imgName = @"DC_Anno_OCC";
            break;
        //设备放置点
        case 208:
            imgName = @"DC_Anno_point";
            break;
        //综合箱
        case 383:
            imgName = @"DC_Anno_Box";
            break;
        //省界
        case 733:
            imgName = @"DC_Anno_shengjie";
            break;
        //光虚拟接入点
        case 711:
            imgName = @"DC_Anno_guangxu";
            break;
            
        default:
            imgName = @"DC_Anno_OCC";
            break;
    }
    
    
    
    return imgName;
    
}


@end
