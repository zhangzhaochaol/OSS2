//
//  Inc_SynchronousView.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/6/24.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_SynchronousView.h"


//业务变更tablecell
#import "Inc_SynchronousCell.h"


@interface Inc_SynchronousView ()<UITableViewDelegate,UITableViewDataSource>

//zzc 20221-6-15
//同步变更 table
@property (nonatomic, strong) UITableView *tableView;



@end

@implementation Inc_SynchronousView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        self.backgroundColor = [UIColor clearColor];
        [self setupUI];
      
        
    }
    return self;
}

- (void)setupUI {
    
    [self addSubview:self.tableView];
    [self zhang_layouts];
}


// 业务同步变更table
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectNull style:UITableViewStyleGrouped];
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView setCornerRadius:10 borderColor:UIColor.clearColor borderWidth:1];
    }
    return _tableView;
}

#pragma mark tableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
 
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height;
    
    NSDictionary *dic = self.dataArray[indexPath.row];
    
    CGFloat title1Hight1 = [dic[@"relateResName"] boundingRectWithSize:CGSizeMake(ScreenWidth - 120, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:Font_Yuan(15)} context:nil].size.height;
    
    CGFloat title1Hight2 = [dic[@"eptName"] boundingRectWithSize:CGSizeMake(ScreenWidth - 120, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:Font_Yuan(15)} context:nil].size.height;
    
    
    height = MAX(30, title1Hight1+1) + MAX(30, title1Hight2+1) + 10;
    
    return height;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.dataArray.count;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *cellIdentifier = @"Inc_SynchronousCell";
    
    Inc_SynchronousCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[Inc_SynchronousCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.dic = self.dataArray[indexPath.row];
    
    return cell;
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 80;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 64;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *sectionHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 80)];
    sectionHeadView.backgroundColor = UIColor.whiteColor;
    
    UIView *lineLabel = [UIView viewWithColor:Color_V2Red];
    lineLabel.frame = CGRectMake(10, 14, 3, 16);
    
    [sectionHeadView addSubview:lineLabel];
    
    UILabel *contentLabel = [UIView labelWithTitle:@"业务状态同步变更" frame:CGRectMake(20, 0, 200 , 40)];
    contentLabel.textColor = UIColor.blackColor;
    contentLabel.font = Font_Bold_Yuan(15);
    
    UILabel *tipLabel = [UIView labelWithTitle:@"*检测到业务状态发生了变更，会同步变更以下资源的状态" isZheH:YES];
    tipLabel.frame = CGRectMake(10, 40, _tableView.frame.size.width  -20, 39);
    tipLabel.textColor = ColorR_G_B(250, 124, 125);
    tipLabel.font = Font_Yuan(13);
    
    [sectionHeadView addSubview:contentLabel];
    [sectionHeadView addSubview:tipLabel];
    
    return sectionHeadView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 64)];
    UIButton *sureBtn = [UIView buttonWithTitle:@"确认修改" responder:self SEL:@selector(sureBtnClick:) frame:CGRectMake(15, 10, (footerView.frame.size.width - 40)*2/3, 44)];
    [sureBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [sureBtn setBackgroundColor:Color_V2Red];
    [sureBtn setCornerRadius:8 borderColor:UIColor.clearColor borderWidth:1];
    
    UIButton *cancelBtn = [UIView buttonWithTitle:@"取消" responder:self SEL:@selector(cancelBtnClick:) frame:CGRectMake(sureBtn.width + sureBtn.x + 10, 10, (footerView.frame.size.width - 40)/3, 44)];
    [cancelBtn setTitleColor:UIColor.lightGrayColor forState:UIControlStateNormal];
    [cancelBtn setBackgroundColor:ColorR_G_B(228, 229, 230)];
    [cancelBtn setCornerRadius:8 borderColor:UIColor.clearColor borderWidth:1];
    
    
    [footerView addSubview:sureBtn];
    [footerView addSubview:cancelBtn];
    
    return footerView;
    
}




- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


-(void)sureBtnClick:(UIButton *)btn {
    if (self.btnSureBlock) {
        self.btnSureBlock(btn);
    }
}


-(void)cancelBtnClick:(UIButton *)btn {
    if (self.btnCancelBlock) {
        self.btnCancelBlock(btn);
    }
}


- (void)reloadData {
    [self zhang_layouts];
    [self.tableView reloadData];
}


- (void)zhang_layouts {
    
    [_tableView  YuanToSuper_Top:0];
    [_tableView  YuanToSuper_Bottom:0];
    [_tableView  YuanToSuper_Right:0];
    [_tableView  YuanToSuper_Left:0];

}

@end
