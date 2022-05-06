//
//  IWPTextView.h
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2016/6/6.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IWPTextView : UITextView


@property (nonatomic, copy) NSString * placeholder;

/* 老版本声明需求的属性 */
@property (nonatomic, assign) NSUInteger hiddenTag;
@property (nonatomic, copy) NSString * key;
@property (nonatomic, copy) NSString * name2;
@property (nonatomic, copy) NSString * name3;
@property (nonatomic, copy) NSString * name4;
@property (nonatomic, strong) NSArray <NSDictionary *>* Type11Name4;
@property (nonatomic, assign) BOOL isType11;
@property (nonatomic, assign) NSUInteger type11Tag;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) BOOL shouldEdit;
@property (nonatomic, assign) BOOL isType9;
@property (nonatomic, copy) NSString * hintString;
@end
