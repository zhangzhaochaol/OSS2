//
//  ResourceTYKTableViewCell.m
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/6/28.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "ResourceTYKTableViewCell.h"
#import "IWPPropertiesReader.h"

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT self.contentView.frame.size.height
@implementation ResourceTYKTableViewCell
{
    UILabel *_name;//资源名称
    UIImageView *_image;//资源类型图
    UILabel *_addr;//资源地址
    UIImageView * _jianTou; //箭头
    
    
    // 段
    UIButton * _sectionBtn;
    
    // 下属资源
    UIButton * _subResBtn;
    
    // 定位
    UIButton * _locationBtn;
    
    
    IWPPropertiesReader * reader;
    IWPPropertiesSourceModel * model;
    
    
    NSLayoutConstraint * _subResConstraint;
    NSLayoutConstraint * _locationConstraint;
    
    NSString * _myResLogicName;
    
    BOOL _isHaveHandles;
    
}
@synthesize backView;



#pragma mark - 初始化构造方法

- (instancetype) initWithStyle:(UITableViewCellStyle)style
               reuseIdentifier:(NSString *)reuseIdentifier
               isHaveHandleBtn:(BOOL) isHaveHandle{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
            
        _isHaveHandles = isHaveHandle;
        
        [self create_NewUI];
    }
    return self;
}



#pragma mark -  method  ---


- (void) configBtns:(NSString *)resLogicName {
    
    
    if (!resLogicName) {
        return;
    }
    
    _myResLogicName = resLogicName;
    
    [self configFromResLogicName];
}



- (void) configFromResLogicName {
    
    
    if (EquName(@"route",_myResLogicName)) {
        [self sectionName:@"光缆段"];
        [self subResHide];
        [self locationHide];
    }
    
    // 杆路
    else if (EquName(@"poleline", _myResLogicName)) {
        [self sectionName:@"杆路段"];
        [self subResName:@"电杆"];
    }
    
    // 管道
    else if (EquName(@"pipe", _myResLogicName)) {
        [self sectionName:@"管道段"];
        [self subResName:@"井"];
    }
    
    // 管道段
    else if (EquName(@"pipeSegment", _myResLogicName)) {
        
        [self sectionName:@"管孔"];
        [self subResHide];
        [self locationHide];
    }
    
    // 标石段
    else if (EquName(@"markStonePath", _myResLogicName)) {
        
        [self sectionName:@"标石段"];
        [self subResName:@"标石"];
        
    }
}


BOOL EquName (NSString * name , NSString * resLogicName)  {
    
    if ([name isEqualToString:resLogicName]) {
        return true;
    }
    
    return false;
}


- (void) sectionName:(NSString *) name {
    
    [_sectionBtn setTitle:name forState:UIControlStateNormal];
}

- (void) subResName : (NSString *) name {
    
    [_subResBtn setTitle:name forState:UIControlStateNormal];
}


- (void) subResHide {
    
    _subResConstraint.active = NO;
    _subResConstraint = [_subResBtn autoSetDimension:ALDimensionWidth
                                              toSize:0];
    
}


- (void) locationHide {
    
    _locationConstraint.active = NO;
    _locationConstraint = [_locationBtn autoSetDimension:ALDimensionWidth
                                                  toSize:0];
}


#pragma mark -  UI  ---


- (void)createUI
{
    backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 85)];
    backView.backgroundColor = UIColor.whiteColor;
    [self.contentView addSubview:backView];
    
    _image = [[UIImageView alloc] initWithFrame:CGRectMake(2, 25, 40, 40)];
    [self.contentView addSubview:_image];
    
    _name = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, WIDTH-70, 40)];
    [_name setTextColor:[UIColor colorWithHexString:@"#000000"]];
    _name.numberOfLines = 0;
    [_name setFont:[UIFont systemFontOfSize:16.0]];
    _name.lineBreakMode = NSLineBreakByTruncatingHead;
    [self.contentView addSubview:_name];
    
    _addr = [[UILabel alloc] initWithFrame:CGRectMake(50, 45, WIDTH-70, 40)];
    [_addr setTextColor:[UIColor colorWithHexString:@"#888888"]];
    [_addr setFont:[UIFont systemFontOfSize:14.0]];
    _addr.numberOfLines = 0;
    _addr.lineBreakMode = NSLineBreakByTruncatingHead;
    [self.contentView addSubview:_addr];
}



// 袁全新UI
- (void) create_NewUI {
    
    backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 70)];
    [self.contentView addSubview:backView];
    
    _image = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"other"]
                                frame:CGRectNull];
    
    _name = [UIView labelWithTitle:@" "
                             frame:CGRectNull];
    _name.textColor = [UIColor colorWithHexString:@"#333333"];
    _name.font = Font_Yuan(14);
    _name.numberOfLines = 0;
    _name.lineBreakMode = NSLineBreakByTruncatingHead;
    
    _jianTou = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"Bulid_icon_you"] frame:CGRectNull];
    
    [backView addSubviews:@[_image,_name, _jianTou]];
    
    [self yuan_layoutAllSubViews];
    

    if (_isHaveHandles) {
        // 创建下部控制台
        [self create_NewHandle];
    }
    
    
}


- (void) create_NewHandle {
    
    
    float radius = 10;
    
    _handleView = [UIView viewWithColor:UIColor.whiteColor];
    
    _sectionBtn = [UIView buttonWithTitle:@"名称"
                                responder:self
                                      SEL:@selector(sectionClick)
                                    frame:CGRectNull];
    
    [_sectionBtn cornerRadius:radius borderWidth:1 borderColor:[UIColor mainColor]];
    [_sectionBtn setTitleColor:[UIColor mainColor] forState:UIControlStateNormal];
    
    
    _subResBtn = [UIView buttonWithTitle:@"资源"
                               responder:self
                                     SEL:@selector(subResClick)
                                   frame:CGRectNull];
    
    [_subResBtn cornerRadius:radius borderWidth:1 borderColor:[UIColor mainColor]];
    [_subResBtn setTitleColor:[UIColor mainColor] forState:UIControlStateNormal];
    
    _locationBtn = [UIView buttonWithTitle:@"定位" responder:self SEL:@selector(locationClick) frame:CGRectNull];
    
    [_locationBtn cornerRadius:radius borderWidth:1 borderColor:[UIColor mainColor]];
    [_locationBtn setTitleColor:[UIColor mainColor] forState:UIControlStateNormal];
    
    
    [self.contentView addSubview:_handleView];
    
    NSArray * btnsArr = @[_sectionBtn,_subResBtn,_locationBtn];
    
    [_handleView addSubviews:btnsArr];
    
    [self yuan_layout_HandleView];
        
    
    
}


#pragma mark - 屏幕适配

- (void) yuan_layoutAllSubViews {
    
    float limit = Horizontal(15);
    
    [_image autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    [_image YuanAttributeHorizontalToView:backView];
    [_image autoSetDimensionsToSize:CGSizeMake(40, 40)];
    
    
    [_name YuanAttributeHorizontalToView:backView];
    [_name autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_image withOffset:limit ];
    [_name autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit * 2];
    
    
    [_jianTou YuanAttributeHorizontalToView:backView];
    [_jianTou autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit /2 ];
    
    
    [backView bringSubviewToFront:_jianTou];
}


#pragma mark - 屏幕适配

- (void) yuan_layout_HandleView{
    
    float limit = Horizontal(15);
    
    [_handleView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_handleView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [_handleView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_handleView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:backView withOffset:1];
    
    
    [_sectionBtn YuanAttributeHorizontalToView:_handleView];
    [_sectionBtn autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    
    [_subResBtn autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_sectionBtn withOffset:limit];
    [_subResBtn YuanAttributeHorizontalToView:_handleView];
    
    [_locationBtn autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_subResBtn withOffset:limit];
    [_locationBtn YuanAttributeHorizontalToView:_handleView];
    
    NSArray * btnsArr = @[_sectionBtn,_subResBtn,_locationBtn];
    
    
    [_sectionBtn autoSetDimension:ALDimensionWidth toSize:Horizontal(70)];
    _subResConstraint = [_subResBtn autoSetDimension:ALDimensionWidth toSize:Horizontal(70)];
    _locationConstraint =  [_locationBtn autoSetDimension:ALDimensionWidth toSize:Horizontal(70)];
    
    for (UIButton * btn in btnsArr) {
        [btn autoSetDimension:ALDimensionHeight toSize:Vertical(30)];
    }
    
    
    
}


#pragma mark -  btnClick  ---

// 段
- (void) sectionClick {
    
    if (_ResourceTYK_HandleBlock) {
        _ResourceTYK_HandleBlock(ResourceTYKCellEnum_Section);
    }
    
}


// 下属资源
- (void) subResClick {
    
    if (_ResourceTYK_HandleBlock) {
        _ResourceTYK_HandleBlock(ResourceTYKCellEnum_SubRes);
    }
    
}


// 定位
- (void) locationClick {
    
    if (_ResourceTYK_HandleBlock) {
        _ResourceTYK_HandleBlock(ResourceTYKCellEnum_Location);
    }
    
}



- (void) NoBtns {
    
    _handleView.hidden = YES;
    
}


#pragma mark -  dict  ---

- (void)setDict:(NSDictionary *)dict{
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@/%@",DOC_DIR,kResourceMainProps,dict[@"resLogicName"]];
    UIImage *imageTemp = [UIImage imageWithContentsOfFile:imagePath];
    if (imageTemp == nil) {
        //如果沙盒里没有这个图的时候
        imageTemp = [UIImage Inc_imageNamed:dict[@"resLogicName"]];
        if ([dict[@"resLogicName"] isEqualToString:@"GIDandRFIDrelation"]) {
            imageTemp = [UIImage Inc_imageNamed:@"rfidInfo"];
        }
        
        if ([dict[kResLogicName] isEqualToString:@"unicomMarkStonePath"]) {
            imageTemp = [UIImage Inc_imageNamed:@"markStonePath"];
        }
        
        if (imageTemp == nil) {
            imageTemp = [UIImage Inc_imageNamed:@"other"];
        }
        
        
    }
    if (self.isGeneratorSSSB) {
        //机房下属设备
        _name.text = dict[@"equipmentName"];
        _addr.text = dict[@"eqpNo"];
    }else{
        /*name.text = dict[[NSString stringWithFormat:@"%@Name",dict[@"resLogicName"]]];
        if ([dict[@"resLogicName"] isEqualToString:@"route"]) {
             name.text = dict[[NSString stringWithFormat:@"%@name",dict[@"resLogicName"]]];
        }else if ([dict[@"resLogicName"] isEqualToString:@"shelf"]) {
            name.text = dict[@"jkName"];
        }else if ([dict[@"resLogicName"] isEqualToString:@"ODF_Equt"]) {
            name.text = dict[@"rackName"];
        }else if ([dict[@"resLogicName"] isEqualToString:@"cnctShelf"]) {
            name.text = dict[@"shelfName"];
        }else if ([dict[@"resLogicName"] isEqualToString:@"opticTerm"]) {
            name.text = dict[@"termName"];
        }else if ([dict[@"resLogicName"] isEqualToString:@"OCC_Equt"]) {
            name.text = dict[@"occName"];
        }else if ([dict[@"resLogicName"] isEqualToString:@"ODB_Equt"]) {
            name.text = dict[@"odbName"];
        }else if ([dict[@"resLogicName"] isEqualToString:@"poleline"]) {
            name.text = dict[@"poleLineName"];
        }else if ([dict[@"resLogicName"] isEqualToString:@"pole"]) {
            name.text = dict[@"poleSubName"];
        }else if ([dict[@"resLogicName"] isEqualToString:@"pipeSegment"]) {
            name.text = dict[@"pipeSegName"];
        }else if ([dict[@"resLogicName"] isEqualToString:@"well"]) {
            name.text = dict[@"wellSubName"];
        }else if ([dict[@"resLogicName"] isEqualToString:@"markStoneSegment"]) {
            name.text = dict[@"markStoneSgName"];
        }else if ([dict[@"resLogicName"] isEqualToString:@"supportingPoints"]) {
            name.text = dict[@"supportPSubName"];
        }else if ([dict[@"resLogicName"] isEqualToString:@"ledUp"]) {
            name.text = dict[@"ledupName"];
        }else if ([dict[@"resLogicName"] isEqualToString:@"markStone"]) {
            name.text = dict[@"markName"];
        }else if ([dict[@"resLogicName"] isEqualToString:@"GIDandRFIDrelation"]) {
            name.text = dict[@"rfid"];
        }else if ([dict[@"resLogicName"] isEqualToString:@"stationBase"]) {
            name.text = dict[@"stationName"];
        }
        addr.text = dict[@"addr"];
        if ([dict[@"resLogicName"] isEqualToString:@"port"]) {
            addr.text = dict[@"portNo"];
        }else if ([dict[@"resLogicName"] isEqualToString:@"opticTerm"]){
            addr.text = dict[@"termNo"];
        }else if ([dict[@"resLogicName"] isEqualToString:@"module"]){
            addr.text = dict[@"shelfName"];
        }else if ([dict[@"resLogicName"] isEqualToString:@"poleline"]){
            addr.text = dict[@"retion"];
        }else if ([dict[@"resLogicName"] isEqualToString:@"poleLineSegment"]){
            addr.text = dict[@"poleLineSegmentCode"];
        }else if ([dict[@"resLogicName"] isEqualToString:@"pole"]){
            addr.text = dict[@"poleLine"];
        }else if ([dict[@"resLogicName"] isEqualToString:@"pipeSegment"]) {
            addr.text = dict[@"pipeSegmentCode"];
        }else if ([dict[@"resLogicName"] isEqualToString:@"well"]||([dict[@"resLogicName"] isEqualToString:@"supportingPoints"])||([dict[@"resLogicName"] isEqualToString:@"ledUp"])||([dict[@"resLogicName"] isEqualToString:@"markStone"])) {
            addr.text = dict[@"retion"];
        }else if ([dict[@"resLogicName"] isEqualToString:@"markStoneSegment"]) {
            addr.text = dict[@"markStoneSgCode"];
        }*/
        //动态

        reader = [IWPPropertiesReader propertiesReaderWithFileName:dict[@"resLogicName"] withFileDirectoryType:IWPPropertiesReadDirectoryDocuments];
        
#ifdef DEBUG
        if ([dict[kResLogicName] isEqualToString:@"markStonePath"]) {
            
            reader = [IWPPropertiesReader propertiesReaderWithFileName:@"markStonePath" withFileDirectoryType:IWPPropertiesReadDirectoryDocuments];
            
        }

#endif
        
        model = [IWPPropertiesSourceModel modelWithDict:reader.result];
        
        NSLog(@"%@", dict);
        
        _name.text = dict[model.list_item_title_name];
        
        if (_addr) {
            _addr.text = dict[model.list_item_note_name];
        }
        if ([dict[@"resLogicName"] isEqualToString:@"GIDandRFIDrelation"]) {
            _name.text = dict[@"rfid"];
        }
    }
    
    _image.image = imageTemp;
    CGSize nameTextSize = [_name.text boundingRectWithSize:CGSizeMake(_name.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16.0]} context:nil].size;
    CGRect nameFrame = _name.frame;
    if (nameTextSize.height>40) {
        nameFrame.size.height = nameTextSize.height;
        _name.frame = nameFrame;
    }
    
    CGRect addrFrame = _addr.frame;
    addrFrame.origin.y = nameFrame.origin.y+nameFrame.size.height;
    CGSize addrTextSize = [_addr.text boundingRectWithSize:CGSizeMake(_addr.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.0]} context:nil].size;
    if (addrTextSize.height>40) {
        addrFrame.size.height = addrTextSize.height;
    }
    _addr.frame = addrFrame;
    
    if ((nameFrame.size.height + addrFrame.size.height)>85) {
        CGRect backViewFrame = backView.frame;
        backViewFrame.size.height = nameFrame.size.height + addrFrame.size.height;
        backView.frame = backViewFrame;
        
        CGRect imageFrame = _image.frame;
        imageFrame.origin.y = backViewFrame.size.height/2-20;
        _image.frame = imageFrame;
    }
    
    if (_name.text.length > 30) {
        _name.font = Font_Yuan(12);
    }
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
-(float)getBackGroundHeignt{
    return backView.frame.size.height;
}
/// 重写指示视图setter
/// 适配iOS13
/// @param accessoryType 指示视图类型
-(void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType{
    
    if (accessoryType == UITableViewCellAccessoryDisclosureIndicator){
        // 该类型存在显示错误的问题，采用指定图片的方式适配
        
        UIImageView * accessoryView = [UIImageView.alloc initWithImage:[UIImage Inc_imageNamed:@"icon_defaultAccessoryView"]];
        accessoryView.frame = CGRectMake(0, 0, 15, 15);
        
        self.accessoryView = accessoryView;
        
        
    }else{
        [super setAccessoryType:accessoryType];
    }
    
    
}
@end
