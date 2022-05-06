//
//  IWPPopverView.m
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2017/10/9.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "IWPPopverView.h"
#import "IWPPopverOperationTableViewCell.h"

#import "IWPTools.h"
#import "IWPPopverViewItem.h"
#import <QuartzCore/QuartzCore.h>
@interface IWPPopverView () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) UITableView * tableView;
@property (nonatomic, weak) UIImageView * pointerView;

@property (nonatomic, weak) UIView * shadowView;

@end

@implementation IWPPopverView

- (instancetype)initWithFrame:(CGRect)frame items:(NSArray<__kindof IWPPopverViewItem *> *)items mode:(IWPPopverViewShowingMode)mode{

    if (self = [super initWithFrame:frame]) {
        
        [self configSubViews];
        
        self.alpha = 0.f;
        
        self.mode = mode;
        self.items = items;
        
        self.backgroundColor = [UIColor clearColor];
        
        
    }
    
    return self;
}

+ (instancetype)popverViewWithItems:(NSArray<__kindof IWPPopverViewItem *> *)items mode:(IWPPopverViewShowingMode)mode{
    return [[self alloc] initWithFrame:CGRectMake(0, 0, 1, 1) items:items mode:mode];
}

- (void)configSubViews{
    
    UIImageView * pointerView = [[UIImageView alloc] init];
    pointerView.image = [UIImage Inc_imageNamed:@"options_pointer"];
    _pointerView = pointerView;
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 1, 1) style:UITableViewStylePlain];
    _tableView = tableView;
    
    if (@available(iOS 15.0, *)) {
        tableView.sectionHeaderTopPadding = 0;
    }
    
    tableView.layer.masksToBounds = true;
    tableView.layer.cornerRadius = 3.f;
    
    tableView.dataSource = self;
    tableView.delegate = self;
    
    tableView.estimatedSectionFooterHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedRowHeight = Vertical(44);
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.scrollEnabled = NO;
    tableView.backgroundColor = [UIColor colorWithHexString:@"#49494b"];
    
    
    [self addSubviews:@[tableView,pointerView]];
    
    
    pointerView.frame = CGRectMake(0, 0, Horizontal(23), Vertical(11));
    pointerView.contentMode = UIViewContentModeScaleAspectFill;
    
    [tableView YuanToSuper_Left:0];
    [tableView YuanToSuper_Right:0];
    [tableView YuanToSuper_Bottom:0];
    [tableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:pointerView];

//    tableView.sd_layout.leftSpaceToView(self, 0.f)
//    .rightSpaceToView(self, 0.f)
//    .topSpaceToView(pointerView, 0.f)
//    .bottomSpaceToView(self, 0.f);

}

-(IWPPopverViewItem *)itemWithTitle:(NSString *)title{
    
    IWPPopverViewItem * ret = nil;
    
    for (IWPPopverViewItem * item in self.items) {
        
        if ([item.title isEqualToString:title]) {
            
            ret = item;
            
            break;
            
        }
    }
    
    return ret;
    
}

-(void)selectItem:(IWPPopverViewItem *)item{
    
    NSInteger index = [_items indexOfObject:item];
    
    NSMutableArray * items = [NSMutableArray arrayWithArray:self.items];
    
    item.selected = true;
    
    [items replaceObjectAtIndex:index withObject:item];
    
    _items = items;
    
    [self.tableView reloadData];
    
    
}

-(void)deSelectItem:(IWPPopverViewItem *)item{
    
    
    NSInteger index = 0;
    
    NSMutableArray * items = [NSMutableArray arrayWithArray:self.items];
    
    
    for (IWPPopverViewItem * itemTemp in _items) {
        
        if ([itemTemp.title isEqualToString:item.title]) {
            break;
        }
        index++;
        
    }
    
    
    IWPPopverViewItem * temp = item;
    temp.selected = false;
    
    [items replaceObjectAtIndex:index withObject:temp];
    
    _items = items;
    
    [self.tableView reloadData];
    
}

-(void)setItems:(NSArray<__kindof IWPPopverViewItem *> *)items{
    _items = items;
    
    self.height = _items.count * Vertical(44) + _pointerView.height;
    
    [self.tableView reloadData];
    
    
}

- (void)removeItem:(IWPPopverViewItem *)item{
    
    NSMutableArray * dataSource = [NSMutableArray arrayWithArray:self.items];
    
    NSInteger index = 0;
    for (IWPPopverViewItem * itemTemp in _items) {
    
        if ([itemTemp.title isEqualToString:item.title]) {
        
            
            
            [dataSource removeObject:itemTemp];
            
            break;
            
        }
        index++;
        
    }
    
    
    if (index < _items.count) {
        _items = dataSource;
        
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        
        
        
        
    }
    
   
    
    
    
    
    
    
}

- (void)setMode:(IWPPopverViewShowingMode)mode{
    _mode = mode;
    
    _pointerView.hidden = false;
    if (_mode == IWPPopverViewShowingModeTopRight) {
        
        self.x = ScreenWidth - self.width - 10.f;
        self.y = 10.f;
        
        _pointerView.x = self.width * .7f;
    }else if (_mode == IWPPopverViewShowingModeTopLeft){
    
        self.x = 60.f;
        self.y = 0.f;
        
        _pointerView.x = self.width * .2f;
    
    }else if (_mode == IWPPopverViewShowingModeFree){
        
        _pointerView.x = self.width * .07f;
        
//        _pointerView.hidden = true;
        
    }else if (_mode == IWPPopverViewShowingModeBottomLeft){
        
        self.x = 10.f;
        self.y = ScreenHeight - self.height - 10.f;
        
        self.tableView.y = 0.f;
        _pointerView.y = self.height - _pointerView.y;
        
    }else if (_mode == IWPPopverViewShowingModeZz){
        
        _pointerView.x = Horizontal(100) * .7f;
    }
    
    
    [self.tableView reloadData];
}
-(void)show{
    self.height = _items.count * Vertical(44) + _pointerView.height;
    
    
    
//    self.height = _pointerView.height * 2.f + self.tableView.contentSize.height;
//    for (NSInteger i = 0; i < self.items.count; i++) {
//        IWPPopverOperationTableViewCell * cell = (IWPPopverOperationTableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.items.count - 1 inSection:0]];
//
//        NSLog(@"%@", @(cell.height));
//
//
//
//    }
    
    
    
    if (_shadowView == nil) {
        UIView * shadowView = [[UIView alloc] initWithFrame:self.superview.bounds];
        [self.superview addSubview:shadowView];
        _shadowView = shadowView;
        
        
//        shadowView.backgroundColor = [UIColor anyColor];
        [self.superview bringSubviewToFront:self];
    }
    

    
    // 防止底部出框
    
    CGRect vframe = self.frame;
    
    NSLog(@"%f", CGRectGetMaxY(vframe));
    
    if (CGRectGetMaxY(vframe) > self.superview.frame.size.height) {
        vframe.origin.y -= CGRectGetMaxY(vframe) - self.superview.frame.size.height;
        
    }
    
    // 防止左侧出框
    if (CGRectGetMinX(vframe) < 0) {
        vframe.origin.x = 0;
    }
    
    // 防止右侧出框
    
    if (CGRectGetMaxX(vframe) > self.superview.frame.size.width) {
        
        vframe.origin.x = self.superview.width - vframe.size.width;
        
    }
    
    [UIView animateWithDuration:.3f animations:^{
        
        if (!CGRectEqualToRect(self.frame, vframe)) {
            _pointerView.hidden = true;
            self.frame = vframe;
        }else{
            _pointerView.hidden = false;
        }
        
        self.alpha =
        self.shadowView.alpha = 1.f;
    }];
    
    _isShowing = true;
    
}
-(void)hide{
    
    
    [UIView animateWithDuration:.3f animations:^{
       
        self.alpha =
        self.shadowView.alpha = 0.f;
       
        CGRect frame = self.frame;
        frame.size.height = _pointerView.height;
    } completion:^(BOOL finished) {
        [self.shadowView removeFromSuperview];
        self.shadowView = nil;
    }];
    
    _isShowing = false;
    
}
// MARK: tableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.items.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    IWPPopverOperationTableViewCell * cell = [IWPPopverOperationTableViewCell operationCellInTableView:tableView item:self.items[indexPath.row] indexPath:indexPath];
    
    
    
    return cell;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.000000000001;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.000000000001;
}
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return Vertical(44.f);
//}
// MARK: tableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    IWPPopverViewItem * item = self.items[indexPath.row];
    if (true) {
        
        if (item.selected) {
            if (item.handlerSelected != nil) {
                item.handlerSelected(indexPath.row, item.actionSelected);
                
            }
        }else{
            if (item.handler != nil) {
                item.handler(indexPath.row, item.action);
                
            }
        }
        
        [self hide];
    }
    
}

-(void)setItemEnableState:(BOOL)state withTitle:(NSString *)title{
    
    
    NSMutableArray * items = [NSMutableArray arrayWithArray:self.items];
    
    NSInteger index = 0;
    for (IWPPopverViewItem * item in self.items) {
        
        if ([item.title isEqualToString:title]) {
            
//            item.canBeSelected = state;
            [items replaceObjectAtIndex:index withObject:item];
            break;
            
        }
        index++;
    }
    
}



@end
