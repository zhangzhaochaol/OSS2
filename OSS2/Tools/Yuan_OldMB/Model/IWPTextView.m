//
//  IWPTextView.m
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2016/6/6.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "IWPTextView.h"

@interface IWPTextView ()
@property (nonatomic, weak) UILabel * hintLabel;
@end

@implementation IWPTextView



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel * hintLabel = [[UILabel alloc] initWithFrame:frame];
        self.hintLabel = hintLabel;
        
        
//        self.backgroundColor = UIColor.anyColor;
//        hintLabel.userInteractionEnabled = YES;
        hintLabel.textColor = [UIColor colorWithHexString:@"#ccc"];
//        hintLabel.font = [UIFont systemFontOfSize:18.f];
        hintLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:hintLabel];
        
        [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.edges.equalTo(self).insets(UIEdgeInsetsZero);
            
        }];
        
//        hintLabel.backgroundColor = [UIColor anyColor];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:self];
        
    }
    return self;
}


- (UIViewController *)viewController {
    for (UIView * next = [self superview]; next != nil; next = next.superview) {
        UIResponder * nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

-(void)setText:(NSString *)text{
    [super setText:text];

    self.contentOffset = CGPointZero;
    
    [self textDidChange];
}

-(void)textDidChange{
    self.hintLabel.hidden = self.text.length > 0;
    
//    NSLog(@"%@ - i'm in %@",self.text, [[self viewController] class]);
}
-(void)setHintString:(NSString *)hintString{
    _hintString = hintString;

    _hintLabel.text = hintString.length > 0 && ![hintString isEqualToString:@"null"]?hintString:(_shouldEdit ? @"请输入" :@"");
    
    
}

-(void)setPlaceholder:(NSString *)placeholder{
    _placeholder = placeholder;
    self.hintString = placeholder;
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    CGRect frame = self.hintLabel.frame;
    frame.origin.x = 5;
    frame.size.width=self.bounds.size.width - frame.origin.x * 2.0;
    CGSize maxSize =CGSizeMake(frame.size.width, MAXFLOAT);
    
    frame.size.height= [self.hintString boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.hintLabel.font} context:nil].size.height;
    
    frame.origin.y = (self.frame.size.height - frame.size.height) / 2.f;
    self.hintLabel.frame = frame;
    
}
@end
