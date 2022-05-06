//
//  PassValueDelegate.h
//  DropDownList
//
//  Created by kingyee on 11-9-8.
//  Copyright 2011 Kingyee. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol PassValueDelegate

- (void)passValue:(NSString *)value;
- (void)selectedRow:(NSInteger)row;

@end
