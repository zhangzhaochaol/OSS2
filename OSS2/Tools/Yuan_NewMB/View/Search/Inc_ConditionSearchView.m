//
//  Inc_ConditionSearchView.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/8/13.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_ConditionSearchView.h"
#import "Inc_SearchAddCell.h"

#define rowHeight  44

@interface Inc_ConditionSearchView ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UITextFieldDelegate>{
    
    //存放输入数据
    NSMutableDictionary *_textfieldDic;
    
    //需要显示的搜索项
    NSMutableArray *_sourceArr;
    
}

@property (nonatomic, strong) UITableView *tableView;


@end


@implementation Inc_ConditionSearchView


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
      
        self.backgroundColor = [UIColor colorWithRed:30/255.0 green:30/255.0 blue:30/255.0 alpha:0.3];
//        self.userInteractionEnabled = YES;
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewClick)];
//
//        [self addGestureRecognizer:tap];
        
        [self createUI];
    }
    return self;
}

- (void)createUI {
    
    _sourceArr  = NSMutableArray.array;
    _textfieldDic = NSMutableDictionary.dictionary;
        
}

- (void)setResLogicName:(NSString *)resLogicName {
    _resLogicName = resLogicName;
    
    NSArray *array  = [self getJsonDataJsonname:@"ConditionSearch2"];
    if (array.count>0) {
        for (NSDictionary *dic in array) {
            
            if ([dic[@"resLogicName"] isEqualToString:_resLogicName]) {
                
                [_sourceArr addObjectsFromArray:dic[@"params"]];
                
            }
            
        }
    }
    
    [self addSubview:self.tableView];

}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.width,(_sourceArr.count + 1)*rowHeight)];
        
        if (_tableView.height < self.height) {
            _tableView.scrollEnabled = NO;
        }else{
            _tableView.scrollEnabled = YES;
        }
        
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
        _tableView.tableFooterView = [self tableFooterView];
    }
    return _tableView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _sourceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"Inc_SearchAddCell";
    
    Inc_SearchAddCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil) {
        
        cell = [[Inc_SearchAddCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textView.tag = indexPath.row;
    [cell.textView addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    cell.textView.delegate = self;
    cell.textView.text = [_textfieldDic objectForKey:_sourceArr[indexPath.row][@"key"]];
    
    cell.titleString = _sourceArr[indexPath.row][@"title"];

    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

//值班规则高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return rowHeight;
}

//值班规则
- (UIView *)tableFooterView {
    
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.width, rowHeight)];
    footerView.backgroundColor = UIColor.groupTableViewBackgroundColor;

    UIButton *resetBtn = [UIView buttonWithTitle:@"重置" responder:self SEL:@selector(btnClick:) frame:CGRectMake(0, 1, footerView.width/2, footerView.height - 1)];
    resetBtn.backgroundColor = UIColor.whiteColor;
    resetBtn.titleLabel.font = Font_Yuan(16);
    
    UIButton *quryBtn = [UIView buttonWithTitle:@"查询" responder:self SEL:@selector(btnClick:) frame:CGRectMake(footerView.width/2 + 1, 1, footerView.width/2 - 2, footerView.height - 1)];
    [quryBtn setTitleColor:[UIColor colorWithHexString:@"#ad0100"]
                  forState:UIControlStateNormal];
    quryBtn.backgroundColor = UIColor.whiteColor;
    quryBtn.titleLabel.font = Font_Yuan(16);

    [footerView addSubviews:@[resetBtn,quryBtn]];
    return footerView;
}

#pragma mark -UITextFieldDelegate

- (void)textFieldDidChange:(UITextField *)textField{
    //    NSString * textIndexPath = [NSString stringWithFormat:@"%ld",(long)textView.tag];
        NSString * text = textField.text;
        NSDictionary *dic = _sourceArr[textField.tag];
        [_textfieldDic setObject:text forKey:dic[@"key"]];
}


//////编辑过程中，将输入框的内容保存到一个字典里，也可以保存到本地，key是输入框的tag
//- (void)textViewDidChange:(UITextView *)textView{
////    NSString * textIndexPath = [NSString stringWithFormat:@"%ld",(long)textView.tag];
//    NSString * text = textView.text;
//    NSDictionary *dic = _sourceArr[textView.tag];
//    [_textfieldDic setObject:text forKey:dic[@"key"]];
//}


- (BOOL)textViewShouldBeginEditing:(UITextField *)textView{
//    [self endEditing:YES];
//    [self handlerTextViewSelect:textView];
    return YES;
}

#pragma mark - 处理点击事件
- (void)handlerTextViewSelect:(UITextField *)textView {

        
}

//获取本地可选类型的json数据
- (id)getJsonDataJsonname:(NSString *)jsonname
{
    NSString *path = [[NSBundle mainBundle] pathForResource:jsonname ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:path];
    NSError *error;
    id jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (!jsonData || error) {
        //DLog(@"JSON解码失败");
        return nil;
    } else {
        return jsonObj;
    }
}



- (void)btnClick:(UIButton *)btn {
    
    if ([btn.titleLabel.text isEqualToString:@"重置"]) {
        
        [_textfieldDic removeAllObjects];
        [self.tableView reloadData];

    }else{
        if (self.btnBlock) {
            self.btnBlock(_textfieldDic);
        }
    }
   
}

- (void)viewClick {
    
    //隐藏键盘收起
//    if (self.viewBlock) {
//        self.viewBlock();
//    }
    
}

- (void)reloadData {
   
    [self.tableView reloadData];
    
}

@end
