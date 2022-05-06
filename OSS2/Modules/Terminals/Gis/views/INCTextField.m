//
//  INCTextField.m
//  INCP&EManager
//
//  Created by 王旭焜 on 2018/9/18.
//  Copyright © 2018年 Tsingtao Increase S&T SY co., ltd. All rights reserved.
//

#import "INCTextField.h"

@implementation INCTextField

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addLongPressG];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self addLongPressG];
    }
    
    return self;
}

- (void)addLongPressG{
    
    
    for (UIGestureRecognizer * ges in self.gestureRecognizers) {
        if ([ges isKindOfClass:UILongPressGestureRecognizer.class]) {
            [self removeGestureRecognizer:ges];
        }
    }
    
    
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(voiceListener:)];
    
    [self addGestureRecognizer:longPress];
    
    
}

- (void)voiceListener:(UILongPressGestureRecognizer *)longPress{
 
    if (self.disableVoiceListener == false && self.inputView == nil) {
        if (longPress.state == UIGestureRecognizerStateBegan) {
            
            
            
        }
    }
    
}

@end
