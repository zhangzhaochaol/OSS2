//
//  Yuan_NotificationName.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/6/7.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#ifndef Yuan_NotificationName_h
#define Yuan_NotificationName_h


/*
    服务器请求成功 , 但是没有返回值 , 只有info里有服务器的返回信息 , 有的类需要调用这个返回信息
    @{@"info":info}  
 */
#define HttpSuccess_Error_Info_Notification @"HttpSuccess_Error_Info_Notification"


/*
    ODF 端子盘信息错误
 */
#define Noti_DuanZiPan_msg_Error @"Noti_DuanZiPan_msg_Error"


/*
    初始化 端子界面 , 点击选择datapicker的通知回调
 */
#define Noti_DataPickerCommit @"Noti_DataPickerCommit"


/*
    在档案 - 材料及成本中 , 长按删除一个记录后 通知 Yuan_materials_CostVC 执行 NotiHeight_change 方法
    刷新对应的高度
 */
#define Noti_RecordDetail_MC_NotiHeight_change @"Noti_RecordDetail_MC_NotiHeight_change"



#define Cache_BuildNameSearchHistory @"Cache_BuildNameSearchHistory"

#endif /* Yuan_NotificationName_h */

