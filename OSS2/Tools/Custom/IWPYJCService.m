//
//  IWPYJCService.m
//  javaScript_ObjectC
//
//  Created by yuanquan on 2022/4/20.
//

#import "IWPYJCService.h"

@implementation IWPYJCService

extern id AnyObject(id needToUse, id other){
    
    return needToUse ? needToUse : other;
    
}

extern void Push(__kindof UIViewController * pusher, __kindof UIViewController * bePush){
    
    
    if (![pusher isKindOfClass:UINavigationController.class] && ![bePush isKindOfClass:UINavigationController.class]) {
        
        [pusher.navigationController pushViewController:bePush animated:true];
        
    }
    
}
void Present(__kindof UIViewController * presenter, __kindof UIViewController * bePresent){
    
    if (@available(iOS 13, *)){
        if (bePresent.modalPresentationStyle == UIModalPresentationPageSheet){
            bePresent.modalPresentationStyle = UIModalPresentationFullScreen; // 重置为iOS13前的默认
        }
    }
    
    if (presenter && bePresent) {
        
        [presenter presentViewController:bePresent animated:true completion:nil];
        
    }
}

extern void Pop(__kindof UIViewController * poper){
    if (![poper isKindOfClass:UINavigationController.class]) {
        
        [poper.navigationController popViewControllerAnimated:true];
        
    }else if ([poper isKindOfClass:UINavigationController.class]){
        Pop([(UINavigationController *)poper viewControllers].lastObject);
    }
}


CLLocationCoordinate2D CoordinateFromNSString(NSString * str){
    
    NSMutableArray * arr = [NSMutableArray arrayWithArray:[str componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"{,}"]]];
    [arr removeObject:@""];
    NSString * lat = arr.firstObject;
    NSString * lon = arr.lastObject;
    
    return CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue);
    
    
}

UITableView * TableView(id<UITableViewDataSource, UITableViewDelegate> delegate, UITableViewStyle style){
    
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 1, 1) style:(style)];
    
    tableView.delegate = delegate;
    tableView.dataSource = delegate;
    
    tableView.estimatedRowHeight = IphoneSize_Height(44.f);
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    
    return tableView;
    
    
}

NSString * NSStringFromCoordinate(CLLocationCoordinate2D coordinate){
    
    return [NSString stringWithFormat:@"{%f,%f}", coordinate.latitude, coordinate.longitude];
    
}

id LoadJSONFile(NSString * fileName){
    
    NSBundle * bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                  pathForResource:@"OSS2_Json"
                                                  ofType:@"bundle"]];
    
    NSString * jsonPath = [bundle pathForResource:fileName ofType:@"json"];
    
    NSData * jsonData = [NSData dataWithContentsOfFile:jsonPath];
    
    return jsonData.object;
}


// MARK: 袁全修改过  将 domainHost 修改为  [Http zbl_BaseUrl]

NSString * BaseURL_Auto(NSString * link){
    return [NSString stringWithFormat:@"http://%@/service/", ((link) == nil ? [Http zbl_BaseUrl] : (link))];
}

#pragma mark - 所属维护区域 ---
NSString * DOWNLOAD_ATTACH_regionFiles_Auto(NSString * link){
   return [NSString stringWithFormat:@"http://%@/attach/regionFiles/", ((link) == nil ? [Http zbl_SourceUrl] : (link))];
}

// 政企用户
NSString * DOWNLOAD_ATTACH_pec_Auto(NSString * link){
   return [NSString stringWithFormat:@"http://%@/attach/pec/", ((link) == nil ? [Http zbl_SourceUrl] : (link))];
}




#pragma mark -
// 模板下载地址
 NSString * DOWNLOAD_LINK_Auto(NSString * link){
    return [NSString stringWithFormat:@"http://%@/dynamicProps/", ((link) == nil ? [Http zbl_SourceUrl] : (link))];
}

#pragma mark -
/** OLT模板连接 **/
 NSString * EqutProps_Download_Link_Auto(NSString * link){
    return [NSString stringWithFormat:@"http://%@/equtProps/", ((link) == nil ? [Http zbl_SourceUrl] : (link))];
}
/** 上传照片 **/
 NSString * BaseURLNoUp_Auto(NSString * link){
    return [NSString stringWithFormat:@"http://%@/service/upload?code=", ((link) == nil ? [Http zbl_BaseUrl] : (link))];
}
/** 下载照片 **/
 NSString * BasePhotoURL_Auto(NSString * link){
    return [NSString stringWithFormat:@"http://%@/upload/", ((link) == nil ? [Http zbl_BaseUrl] : (link))];
}

#pragma mark -
/** 菜单页文件下载地址 **/
 NSString * MenuProps_MainPage_Download_Link_Auto(NSString * link){
    return [NSString stringWithFormat:@"http://%@/menuProps", ((link) == nil ? [Http zbl_SourceUrl] : (link))];
}

#pragma mark - 虽然修改 但是弃用了 ---
/** 菜单界面配置文件下载地址 **/
 NSString * MenuProps_Download_Link_Auto(NSString * link){
    return [NSString stringWithFormat:@"http://%@/menuProps/ResourceMainDic.properties", ((link) == nil ? [Http zbl_SourceUrl] : (link))];
}


#pragma mark -
/** 机架模板下载 **/
 NSString * CrowdfundingModelDownload_Auto(NSString * link){
    return [NSString stringWithFormat:@"http://%@/cardModelProps/", ((link) == nil ? [Http zbl_SourceUrl] : (link))];
}

extern NSString * BuildingImageName(NSDictionary *dict, NSInteger count){
    
    NSString * resLogicName = dict[@"resLogicName"];
    __block NSString * id = dict[[NSString stringWithFormat:@"%@Id",dict[@"resLogicName"]]];
    
    
    if (id.integerValue == 0){
        id = dict[@"id"];
    }
    
    
    NSString * imageName = [NSString stringWithFormat:@"%@_%@_%@.jpg",resLogicName, id, @(count)];
    
    
    // 证明是新自主巡检过来的
    if ([dict.allKeys containsObject:@"orderId"]) {
        
        NSString * myId = dict[@"id"];
        NSString * myOrderId = dict[@"orderId"];
        
        imageName = [NSString stringWithFormat:@"%@_%@_%@_%@.jpg",resLogicName,myOrderId,myId,@(count)];
    }
    
    return imageName;
}

NSString * json_encode(id object){
    return [object json];
}

id json_decode(NSString * json){
    return json.object;
}

UIWindow * Window(){
 
    return UIApplication.sharedApplication.keyWindow;
}



UIColor * HexColor(NSString * temp){
    
    if (temp == nil) {
        return UIColor.blackColor;
    }
    
    NSString * hexString = [temp hasPrefix:@"#"] ? temp : [@"#" stringByAppendingString:temp];
    
    return [UIColor colorWithHexString:hexString];
    
}


UIFont * Font(CGFloat size){
    return [UIFont systemFontOfSize:Horizontal(size)];
}
@end
