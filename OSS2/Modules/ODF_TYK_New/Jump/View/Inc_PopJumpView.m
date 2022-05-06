//
//  Inc_PopJumpView.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/6/24.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_PopJumpView.h"
#import "Inc_PopJumpCell.h"

@interface Inc_PopJumpView ()<UITableViewDelegate,UITableViewDataSource>

//zzc 20221-6-15
//同步变更 table
@property (nonatomic, strong) UITableView *tableView;



@end

@implementation Inc_PopJumpView


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
//
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//
//    CGFloat height;
//
//    NSDictionary *dic = self.dataArray[indexPath.section][indexPath.row];
//
//    CGFloat title1Hight1 = [dic[@"relateResName"] boundingRectWithSize:CGSizeMake(ScreenWidth - 120, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:Font_Yuan(15)} context:nil].size.height;
//
//    CGFloat title1Hight2 = [dic[@"eptName"] boundingRectWithSize:CGSizeMake(ScreenWidth - 120, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:Font_Yuan(15)} context:nil].size.height;
//
//
//    height = MAX(30, title1Hight1+1) + MAX(30, title1Hight2+1) + 10;
//
//    return height;
//
//}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return 1;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *cellIdentifier = @"Inc_PopJumpCell";
    
    Inc_PopJumpCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[Inc_PopJumpCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [cell setDic:self.dataArray[indexPath.section] integer:indexPath.section];
    
    return cell;
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    NSString *nameStr = self.dataArray[section][@"eqName"];
    if (nameStr.length > 0) {
        return 40;
    }else{
        return 0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return 90;
    }else{
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *sectionHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 40)];
    sectionHeadView.backgroundColor = UIColor.whiteColor;
    
    UILabel *nameLabel = [UIView labelWithTitle:self.dataArray[section][@"eqName"] isZheH:YES];
    nameLabel.frame = CGRectMake(10, 0, _tableView.frame.size.width  -20, 39);
    nameLabel.textColor = UIColor.blackColor;
    nameLabel.font = Font_Bold_Yuan(13);
    
    UIView *lineView = [UIView viewWithColor:UIColor.groupTableViewBackgroundColor];
    lineView.frame = CGRectMake(0, nameLabel.height, ScreenWidth, 1);
    
    
    [sectionHeadView addSubview:nameLabel];
    [sectionHeadView addSubview:lineView];
    
    return sectionHeadView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 70)];
    
    

    UILabel *tipLabel = [UIView labelWithTitle:@"*该操作会解除现有跳纤关系" frame:CGRectMake(10, 0, _tableView.width - 20, 30)];
    tipLabel.textColor = UIColor.redColor;
    if (!_isHaveJump) {
        tipLabel.text = @"";
    }
    NSString *btnTitle;
    if ([_type isEqualToString:@"1"]) {
        btnTitle = @"关联";
    }else {
        btnTitle = @"解除关联";
    }
    
    UIButton *button = [UIView buttonWithTitle: btnTitle responder:self SEL:@selector(btnClick:) frame:CGRectMake(10, tipLabel.height, footerView.frame.size.width - 20, 40)];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [button setBackgroundColor:Color_V2Red];
    [button setCornerRadius:8 borderColor:UIColor.clearColor borderWidth:1];
    
    
    [footerView addSubview:tipLabel];
    [footerView addSubview:button];
    
    return footerView;
    
}




- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


- (void)reloadData {
    [self zhang_layouts];
    [self.tableView reloadData];
}


#pragma mark -btnClick

-(void)btnClick:(UIButton *)btn {
    if (self.btnBlock) {
        self.btnBlock(btn);
    }
    
}


//适配
- (void)zhang_layouts {
    
    [_tableView  YuanToSuper_Top:0];
    [_tableView  YuanToSuper_Bottom:0];
    [_tableView  YuanToSuper_Right:0];
    [_tableView  YuanToSuper_Left:0];

}


@end
