//
//  Inc_ShareListVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/7/14.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_ShareListVC.h"
#import "Inc_ShareListCell.h"
#import "Inc_Share_HttpModel.h"


// AES 解密
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
@interface Inc_ShareListVC ()
<
    UITableViewDelegate ,
    UITableViewDataSource
>

/** tableView */
@property (nonatomic , strong) UITableView * tableView;

@end

@implementation Inc_ShareListVC
{
    
    NSArray *_datas;
    
    NSDictionary * _passLoginDict;
}

#pragma mark - 初始化构造方法

- (instancetype)initWithPassLogin:(NSDictionary *) passLoginDict {
    
    if (self = [super init]) {
        _passLoginDict = passLoginDict;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"分享列表";
    
    _tableView = [UIView tableViewDelegate:self
                             registerClass:[Inc_ShareListCell class]
                       CellReuseIdentifier:@"Yuan_ShareListCell"];
    
    _tableView.separatorStyle = 0;
    
    [self.view addSubviews:@[_tableView]];
    [_tableView Yuan_Edges:UIEdgeInsetsMake(NaviBarHeight, 0, BottomZero, 0)];

    
    
    [self http_SelectShareList];
    
}


#pragma mark - http ---

- (void) http_SelectShareList {
    
    NSDictionary * dict = @{@"type" : @"2"};
    
    
    if (_passLoginDict && _passLoginDict.count > 0) {
        NSString * msg = _passLoginDict[@"msg"];
        
        if ([msg containsString:@"%5BQDQR%5D"]) {
            msg = [msg stringByReplacingOccurrencesOfString:@"%5BQDQR%5D" withString:@""];
        }
        
        if ([msg containsString:@"[QDQR]"]) {
            msg = [msg stringByReplacingOccurrencesOfString:@"[QDQR]" withString:@""];
        }
        
        NSString * aes_Decode = [self aesDecrypt:msg key:@"abcdsxyzhkj12345"];
        
        if (!aes_Decode) {
            [YuanHUD HUDFullText:@"解析失败"];
            return;
        }
        
        NSData *jsonData = [aes_Decode dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
        
        NSString * resId = dic[@"resId"];
        
        if (resId && ![resId obj_IsNull]) {
            dict = @{@"type" : @"2",@"resId":resId};
        }
    }
    
    
    
    
    
    
    [Inc_Share_HttpModel http_SelectShareList:dict
                                       success:^(id  _Nonnull result) {
            
        
        if (![result isKindOfClass:NSDictionary.class]) {
            [YuanHUD HUDFullText:@"暂无数据"];
            return;
        }
        
        NSDictionary * dic = result;
        
        _datas = dic[@"content"];
        [_tableView reloadData];
        
        if (_datas.count == 0 || !_datas) {
            [YuanHUD HUDFullText:@"暂无数据"];
            
            return;
        }
    }];
    
}




#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"Yuan_ShareListCell";
    
    Inc_ShareListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[Inc_ShareListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.vc = self;
    
    cell.reloadHttpList = ^{
        [self http_SelectShareList];
    };
    
    NSDictionary * cellDict = _datas[indexPath.row];
    
    [cell reloadWithDict:cellDict];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return Vertical(180);
    
}



#pragma mark - AES 解密 ---
- (NSString *)aesDecrypt:(NSString *)secretStr
                     key:(NSString *)key{
    
    
    //先对加密的字符串进行base64解码
    NSData *decodeData = [[NSData alloc] initWithBase64EncodedString:secretStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
     
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
     
    NSUInteger dataLength = [decodeData length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding | kCCOptionECBMode, keyPtr, kCCBlockSizeAES128, NULL, [decodeData bytes], dataLength, buffer, bufferSize, &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return result;
    } else {
        free(buffer);
        return nil;
    }

    
}
@end
