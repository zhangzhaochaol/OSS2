//
//  IWPUniversalTextView.h
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2016/6/20.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^handler) (NSString * text);



@interface IWPUniversalTextView : UIView
@property (nonatomic, assign) handler handle;
@property (nonatomic, copy) NSString * text;
@property (nonatomic, assign) BOOL isSecu;
/**
 *  //////
 */
@property (nonatomic, copy) NSString * placeHolder;
@property (nonatomic, weak) __kindof UIView * textEditor;
@property (nonatomic, assign) CGPoint contentOffset;
//-(instancetype)initWithFrame:(CGRect)frame withBlock:(handler)handle;
@end
