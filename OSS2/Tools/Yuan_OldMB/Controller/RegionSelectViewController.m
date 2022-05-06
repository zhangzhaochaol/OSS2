//
//  RegionSelectViewController.m
//  OSS2.0-ios-v1
//
//  Created by 孟诗萌 on 16/4/28.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "RegionSelectViewController.h"

#import "CusButton.h"



#import "MBProgressHUD.h"
#import "IWPCleanCache.h"

static NSString * const kAreaName = @"areaName";
static NSString * const kAreaList = @"areaList";

@interface RegionSelectViewController ()
{
    UITextField * _searchTextField;
    
    NSMutableArray * _dataArray;
    UITableView *regionTableView;
}
/**
 *  保存CGContact的数组
 */

@property (nonatomic, weak) UIView * contentView;
@property (nonatomic, strong) NSMutableArray *regionTemp;
@end

@implementation RegionSelectViewController
{
    NSUserDefaults *historys;//历史查询记录存储域
}
@synthesize backStr;


- (NSString *)readMD5:(NSString *)filePath{
    NSData * data = nil;
    if ([filePath rangeOfString:@"http"].length > 0) {
        data = [NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]];
    }else{
        data = [NSData dataWithContentsOfFile:filePath];
    }
    
    NSString * str = [NSString stringWithData_V2:data];
    
    
    NSArray * arr = [str componentsSeparatedByString:@"\n\r"];
    NSString * ret = nil;
    for (NSString * string in arr) {
        
        if ([string rangeOfString:@"region.json="].length > 0) {
            
            ret = [string componentsSeparatedByString:@"="].lastObject;
            break;
            
        }
        
    }
    return ret;
    
    
}

- (void)checkUpdate{
    //http://120.52.12.11:8080/im/attach/regionFiles/region.json
    NSString * newMD5URL = [NSString stringWithFormat:@"%@regionMD5.properties", BaseURL_Auto(IWPServerService.sharedService.link)];
    NSString * oldMD5Path = [DOC_DIR stringByAppendingPathComponent:@"regionMD5.properties"];
    
    NSString * newMD5 = [self readMD5:newMD5URL];
    NSString * oldMD5 = [self readMD5:oldMD5Path];
    if (oldMD5 == nil || ![oldMD5 isEqualToString:newMD5]) {
        // 需要更新
        
        NSData * newMD5Data = [NSData dataWithContentsOfURL:[NSURL URLWithString:newMD5URL]];
        [newMD5Data writeToFile:oldMD5Path atomically:true];
        
        NSData * newFile = [NSData dataWithContentsOfURL:[NSURL URLWithString:[newMD5URL stringByReplacingOccurrencesOfString:@"regionMD5.properties" withString:@"region.json"]]];

        
        
        
        NSString * tempFilePath = [oldMD5Path stringByReplacingOccurrencesOfString:@"regionMD5.properties" withString:@"region.json"];
        
        [IWPCleanCache.new deleteFileAtPath:tempFilePath];
        
        NSLog(@"%@", tempFilePath);
        
        [newFile writeToFile:[oldMD5Path stringByReplacingOccurrencesOfString:@"regionMD5.properties" withString:@"region.json"] atomically:false];
        
        
    }
    [self searchAllRegion];
    
}

- (void)viewDidLoad {

    // [self checkUpdate];
    
    self.title = @"所属维护区域";
    
    self.view.backgroundColor=[UIColor whiteColor];

    _dataArray = [NSMutableArray array];
    
    historys = [NSUserDefaults standardUserDefaults];
    
//    [self uiInit];
    [self configSubViews];
    [self searchAllRegion];
    [super viewDidLoad];
}
//控件初始化
-(void)configSubViews{
    CGFloat x,y,w,h,margin = 8.f;
    x = 0;
    y = HeigtOfTop;
    w = ScreenWidth;
    h = 40;
    
    UIView * contentView = [[UIView alloc] init];// 暂时不设置 frame
    self.contentView = contentView;
    
    contentView.backgroundColor = [UIColor whiteColor];
    
    
    h = 30.f;// 编辑框默认高度
    y = 0;
    UILabel * searchLabel = [[UILabel alloc] init];
    searchLabel.text = @"所属维护区域";
    searchLabel.font = [UIFont systemFontOfSize:14];
    
    searchLabel.numberOfLines = 0;
    CGSize deflaultSize = CGSizeMake(ScreenWidth / 4.f, MAXFLOAT);
    CGSize labelSize = [searchLabel.text boundingRectWithSize:deflaultSize options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:searchLabel.font,NSFontAttributeName, nil] context:nil].size;
    h = labelSize.height;
    w = labelSize.width;
    
    searchLabel.frame = CGRectMake(x,y,w,h);
    searchLabel.textAlignment = NSTextAlignmentCenter;
    
    // 这时设置 contentView的 frame
    
    h = h > 40 ? h : 40;
    contentView.frame = CGRectMake(0, HeigtOfTop, ScreenWidth, h);
    
    
    [contentView addSubview:searchLabel];
    
    
    
    x = CGRectGetMaxX(searchLabel.frame) + margin;
    w = ScreenWidth - w - margin - 40;
    h = 30.f;
    y = (contentView.bounds.size.height - h) / 2.f;
    
    UITextField * searchKeyWord = [[UITextField alloc] initWithFrame:CGRectMake(x,y,w,h)];
    searchKeyWord.borderStyle = UITextBorderStyleRoundedRect;
    searchKeyWord.placeholder = @"请输入区域名称";
    searchKeyWord.font = [UIFont systemFontOfSize:17];
    searchKeyWord.delegate = self;
    searchKeyWord.returnKeyType = UIReturnKeySearch;
    _searchTextField = searchKeyWord;
    [contentView addSubview:searchKeyWord];
    
    x = CGRectGetMaxX(searchKeyWord.frame);
    w = h = 40;
    y = (contentView.bounds.size.height - h) / 2.f;
    
    UIButton * searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    searchButton.frame = CGRectMake(x,y,w,h);
    
    [searchButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:searchButton];
    [searchButton setImage:[UIImage Inc_imageNamed:@"search"] forState:UIControlStateNormal];
    
    // 让单行的 label 纵向居中
    CGPoint center = searchLabel.center;
    center.y = searchKeyWord.center.y;
    searchLabel.center = center;
    //    searchLabel.backgroundColor = [UIColor getStochasticColor];
    [self.view addSubview:contentView];
    
    x = 0;
    y = CGRectGetMaxY(contentView.frame);
    w = ScreenWidth;
    h = ScreenHeight - y;
    
    
    regionTableView=[[UITableView alloc] initWithFrame:CGRectMake(x,y,w,h) style:UITableViewStylePlain];
    regionTableView.backgroundColor=[UIColor whiteColor];
    [regionTableView setEditing:NO];
    regionTableView.delegate=self;
    regionTableView.dataSource=self;
    [self.view addSubview:regionTableView];
    

}

-(void)uiInit
{
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(5,HeigtOfTop+5,85,30)];
    label.text = @"所属维护区域";
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:label];
    
    _searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(85+10,HeigtOfTop+5,ScreenWidth-105-60,30)];
    _searchTextField.delegate=self;
    _searchTextField.backgroundColor = [UIColor whiteColor];
    _searchTextField.font = [UIFont systemFontOfSize:13];
    _searchTextField.textColor=[UIColor blackColor];
    _searchTextField.placeholder = @"请输入区域名称";
    [_searchTextField setBorderStyle:UITextBorderStyleRoundedRect];
    _searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    //    _locationText.textAlignment = NSTextAlignmentCenter;
    _searchTextField.leftViewMode = UITextFieldViewModeAlways;
    [_searchTextField addTarget:self action:@selector(searchTextChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_searchTextField];
    
    
    
    CusButton * btn = [[CusButton alloc]initWithFrame:CGRectMake(ScreenWidth-60,HeigtOfTop+5,55, 30)];
    [btn setTitle:@"搜索" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor mainColor]];
    btn.layer.cornerRadius = 4;
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    //UIImage * image = [UIImage Inc_imageNamed:@"aaa"];
    //[btn setBackgroundImage:image forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    regionTableView=[[UITableView alloc] initWithFrame:CGRectMake(5, 65+5+30+5, ScreenWidth-10, ScreenHeight - (65+5+30+5)) style:UITableViewStyleGrouped];
    regionTableView.backgroundColor=[UIColor whiteColor];
    [regionTableView setEditing:NO];
    regionTableView.delegate=self;
    regionTableView.dataSource=self;
    [self.view addSubview:regionTableView];
    
}
//查找全部数据
- (void)searchAllRegion
{

    //配置文件模式

//    NSString * filePath = [NSString stringWithFormat:@"%@/region.json",DOC_DIR];
//    
//    NSLog(@"%@", [IWPCleanCache.new cacheListWithDir:DOC_DIR]);
//    
////    NSString * filePath = [NSBundle.mainBundle pathForResource:@"region" ofType:@"json"];
//    NSData * data = [NSData dataWithContentsOfFile:filePath];
//    NSDictionary * dict = [data object];
    
    NSDictionary * dict = LoadJSONFile(@"region");
    
    
    NSMutableArray * jsonArr = NSMutableArray.array;
    
    for (NSString * key in dict.allKeys) {
        
        [jsonArr addObject:@{kAreaName:key, kAreaList:[dict[key] componentsSeparatedByString:@","]}];
        
    }
    

//    // 读取文件内容
//    NSString * sourceString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"QD" ofType:@"properties"] encoding:NSUTF8StringEncoding error:nil];
//
//    // 分解为可变数组
//    NSMutableArray * sourceArr = [NSMutableArray arrayWithArray:[sourceString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\r"]]];
//    // 移除空项
//    [sourceArr removeObject:@""];
//
//    // 创建数组
//    NSMutableArray * jsonArr = [NSMutableArray array];
//
//    // 遍历数组
//    for (NSString * str in sourceArr) {
//
//        // 创建字典
//        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
//
//        // 分割为数组
//        NSArray * tempArr = [str componentsSeparatedByString:@"="];
//
//        // 向字典赋值
//        [dict setValue:tempArr[0] forKey:kAreaName];
//
//        // 分割列表为数组
//        NSArray * areaList = [tempArr[1] componentsSeparatedByString:@","];
//
//        // 向字典赋值
//        [dict setValue:areaList forKey:kAreaList];
//
//        // 添加到总数组
//        [jsonArr addObject:dict];
//
//    }
//
//    NSString * jsonStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:jsonArr options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
//
//    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
//
//
//    NSLog(@"%@", jsonStr);
//
//    jsonArr = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
//
    for (NSDictionary *dic in jsonArr) {
        if ([[NSString stringWithFormat:@"%@/",dic[@"areaName"]] isEqualToString:UserModel.domainCode]) {
            _regionTemp = [NSMutableArray arrayWithArray:dic[@"areaList"]];
            break;
        }
    }
    
}
//搜索数据
-(void)listChange
{
    [_dataArray removeAllObjects];
    if ([_searchTextField.text isEqualToString:@""]) {
        [_dataArray addObjectsFromArray:_regionTemp];
//        for (NSString *s in _regionTemp) {
//            [_dataArray addObject:s];
//        }
    }else{
        for (NSString *s in _regionTemp) {
            if ([s rangeOfString:_searchTextField.text].length > 0) {
                [_dataArray addObject:s];
            }
        }
    }
    [regionTableView reloadData];
    if (_dataArray.count == 0) {
        [YuanHUD HUDFullText:@"无数据"];
    }
}
- (void)btnClick:(id)sender
{
    [self listChange];
}
-(void)searchTextChange:(UITextField *)textField{
    [self listChange];
}

#pragma mark - UITableViewDateSource方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
    }
    
    cell.textLabel.text = _dataArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString * ID = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    cell.textLabel.text = _dataArray[indexPath.row];
    
    
    if (_regionSelectBlock) {    
        _regionSelectBlock(@{@"name":_dataArray[indexPath.row]});
        Pop(self);
        return;
    }
    
    
    //将选中的放入历史记录中
    NSString *hisStr;
    NSString *historyStr = [historys objectForKey:@"RegionHistorys"];
    if (historyStr!=nil) {
        //如果原来存有历史记录，判断原来历史记录中是否含有当前搜索项，如果都没有，再存入
        BOOL isHave = false;
        for (int i = 0; i <((NSArray *)[historyStr componentsSeparatedByString:@","]).count; i++) {
            NSString *strTemp = ((NSArray *)[historyStr componentsSeparatedByString:@","])[i];
            if ([strTemp rangeOfString:cell.textLabel.text].location != NSNotFound) {
                isHave = YES;
                break;
                
            }
        }
        if (!isHave) {
            //之前如果超过50条，把最后一条删去
            if (((NSArray *)[historyStr componentsSeparatedByString:@","]).count == 50) {
                NSString *subString =[NSString stringWithFormat:@",%@",((NSArray *)[historyStr componentsSeparatedByString:@","])[49]];
                NSRange range = [historyStr rangeOfString:subString];
                historyStr = [historyStr substringToIndex:range.location];
            }
            hisStr = [NSString stringWithFormat:@"%@,%@",cell.textLabel.text,historyStr];
        }else{
            hisStr = historyStr;
        }
    }else{
        hisStr = cell.textLabel.text;
    }
    [historys setObject:hisStr forKey:@"RegionHistorys"];
    //回传给上一个页面
    
    if ([self.delegate respondsToSelector:@selector(returnRegion:)] == YES) {
        [self.delegate returnRegion:cell.textLabel.text];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}


#pragma mark PassValue protocol
- (void)passValue:(NSString *)value{
    if (value) {
        _searchTextField.text = value;
        [self listChange];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self listChange];
    return YES;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //当捕捉到触摸事件时，取消UITextField的第一响应
    if ([_searchTextField isFirstResponder]) {
        [_searchTextField resignFirstResponder];
    }
}
-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
