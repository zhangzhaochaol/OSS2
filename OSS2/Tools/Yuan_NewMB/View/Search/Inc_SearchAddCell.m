//
//  Inc_SearchAddCell.m
//  科信光缆
//
//  Created by zzc on 2021/3/23.
//

#import "Inc_SearchAddCell.h"


@interface Inc_SearchAddCell ()


@end

@implementation Inc_SearchAddCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupUI];
    }
    return self;
}
#pragma mark -inti

- (void)setupUI {
    
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.font = Font_Yuan(14);
    _titleLabel.textColor = [UIColor darkGrayColor];
    [self.contentView addSubview:_titleLabel];
    
    _textView= [[UITextField alloc]init];
    _textView.font = Font_Yuan(14);
    _textView.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_textView];

}


- (void)setTitleString:(NSString *)titleString {
    _titleString = titleString;
    _titleLabel.text = titleString;
    [self Zhang_layoutViews];

}


//屏幕适配
- (void)Zhang_layoutViews{
    
    float nameWidth = [_titleLabel.text boundingRectWithSize:CGSizeMake(ScreenWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_titleLabel.font} context:nil].size.width;
    
    
    float textFieldHeight = [_titleLabel.text?:@"" boundingRectWithSize:CGSizeMake(ScreenWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_titleLabel.font} context:nil].size.height;

    _titleLabel.frame = CGRectMake(10, 0, nameWidth, self.frame.size.height);

    if (textFieldHeight > self.frame.size.height) {
        textFieldHeight = self.frame.size.height;
    }

    _textView.frame = CGRectMake(nameWidth + 10 + 10, 0, ScreenWidth - (nameWidth + 10 + 10) , MAX(textFieldHeight, self.frame.size.height));


}
@end
