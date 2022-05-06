//
//  IWPUniversalTextView.m
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2016/6/20.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "IWPUniversalTextView.h"

@interface IWPUniversalTextView () <UITextViewDelegate>
@property (nonatomic, weak) UITextView * texrField;
@property (nonatomic, weak) UILabel * label;
@property (nonatomic, weak) UIButton * closeButton;
@end
@implementation IWPUniversalTextView
-(void)setIsSecu:(BOOL)isSecu{
    _isSecu = isSecu;
    _texrField.secureTextEntry = isSecu;
}
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UITextView * textField = [UITextView new];
        textField.layer.borderWidth = .5f;
        textField.layer.borderColor = [UIColor colorWithHexString:@"#999"].CGColor;
        textField.layer.cornerRadius = 5.f;
        textField.layer.masksToBounds = YES;
        self.texrField = textField;
        self.backgroundColor = [UIColor colorWithHexString:@"#ccc"];
        textField.backgroundColor = [UIColor whiteColor];
        textField.delegate = self;
        textField.font = [UIFont systemFontOfSize:17.f];
        
        UILabel * label = [UILabel new];
        self.label = label;
        label.font = [UIFont boldSystemFontOfSize:17.f];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithHexString:@"#5d5e5f"];
        [self addSubview:label];
        [self addSubview:textField];
        
        CGFloat x , y , w , h,margin = 5.f;
        
        x = y = 0;
        w = ScreenWidth;
        h = self.frame.size.height * .4f;
        
        self.label.frame = CGRectMake(x,y,w,h);
        
        x = margin;
        y = CGRectGetMaxY(self.label.frame);
        w = ScreenWidth - 2 * margin;
        h = self.frame.size.height * .5f;
        self.texrField.frame = CGRectMake(x,y,w,h);
        
        
        self.alpha = 0.f;
    }
    return self;
}
-(void)setPlaceHolder:(NSString *)placeHolder{
    _placeHolder = placeHolder;
    
    [UIView animateWithDuration:.3f animations:^{
        self.label.alpha = 0.f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.5f animations:^{
            self.label.text = [NSString stringWithFormat:@"\t%@",placeHolder];
            self.label.alpha = 1.f;
        }];
    }];
    
}

-(void)setContentOffset:(CGPoint)contentOffset{
    [_texrField setContentOffset:contentOffset animated:YES];
}

-(void)setTextEditor:(__kindof UIView *)textEditor{
    _textEditor = nil;
    _textEditor = textEditor;
    
    if (_closeButton == nil) {
        CGRect frame = self.texrField.frame;
        
        frame.size.width *= .9f;
        
        [UIView animateWithDuration:.1f animations:^{
            self.texrField.frame = frame;
        }];
        
        CGFloat x = 0, y = 0, w = 0, h = 0;
        
        x = CGRectGetMaxX(self.texrField.frame);
        y = CGRectGetMaxY(self.label.frame);
        w = self.frame.size.width - x;
        h = CGRectGetMaxY(_texrField.frame) - y;
        
        
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(x, y, w, h);
        _closeButton = button;
        [self addSubview:button];
        
        [button addTarget:self action:@selector(closeKeyboard) forControlEvents:UIControlEventTouchUpInside];
        
        [button setImage:[UIImage Inc_imageNamed:@"hideKeyboard"] forState:UIControlStateNormal];
    }
    
    
    
    
}

-(void)closeKeyboard{
    
    if ([_textEditor respondsToSelector:@selector(resignFirstResponder)]) {
        [_textEditor resignFirstResponder];
        _textEditor = nil;
    }
    
}

-(void)textViewDidChange:(UITextView *)textView{
    self.handle(textView.text);
}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return NO;
//    return YES;
}

-(void)setText:(NSString *)text{
    _text = text;
    self.texrField.text = text;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"%@", NSStringFromCGPoint(scrollView.contentOffset));
}

-(void)dealloc{
    NSLog(@"%@释放", self.class);
}
//
//-(void)layoutSubviews{
//    
//
//}
@end
