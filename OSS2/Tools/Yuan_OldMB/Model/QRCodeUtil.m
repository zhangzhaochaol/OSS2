//
//  QRCodeUtil.m
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/11/8.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "QRCodeUtil.h"

@implementation QRCodeUtil
/**
 *    @brief    将二进制数据转化为用字符表示的16进制数
 *
 *    @param     data 二进制数据
 *
 *    @return    字符表示的16进制数
 */
-(NSString *)HexStringWithData:(NSData *)data{
    Byte *bytes = (Byte *)[data bytes];
    
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    hexStr = [hexStr uppercaseString];
    return hexStr;
}

-(Byte)toByte:(char)c {
    Byte b = (Byte)[@"0123456789ABCDEF" rangeOfString:[NSString stringWithFormat:@"%c", c]].location;
    return b;
}
/**
 *  演算CRC
 *  @param str
 */
-(NSString *)generateCRC:(NSString *)str{
    //把16进制字符串转换成字节数组
    long len = ([str length]/   2);
    Byte result[len];
    char achar[[str length]];
    memcpy(achar, [[str uppercaseString] cStringUsingEncoding:NSASCIIStringEncoding], 2*[[str uppercaseString] length]);
    for (int i = 0; i<len; i++) {
        int pos = i *2;
        result[i] = (Byte)([self toByte:achar[pos]] <<   4 | [self toByte:achar[pos+1]]);
        NSLog(@"result[i]:%d",result[i]);
    }
    
    Byte check[1];
    NSString *hexStr=@"";
    for (int i = 0; i<len; i++) {
        if (i == 0) {
            check[0] = result[0];
        }else{
            check[0] ^=result[i];
        }
    }
    NSLog(@"check[0]:%d",check[0]);
    
    NSData *adata = [[NSData alloc] initWithBytes:check length:1];
    hexStr = [self HexStringWithData:adata];
    hexStr = [hexStr uppercaseString];
    return hexStr;
}
@end
