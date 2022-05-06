//
//  IWPPropertiesReader.m
//  Properties
//
//  Created by 王旭焜 on 2016/5/30.
//  Copyright © 2016年 王旭焜. All rights reserved.
//

#import "IWPPropertiesReader.h"




@interface IWPPropertiesReader ()

/**
 *  本地文件名
 */
@property (nonatomic, copy) NSString * fileName;

/**
 *  網絡文件地址
 */
@property (nonatomic, copy) NSString * url;
/**
 *  文件目錄類型
 */
@property (nonatomic, assign) IWPPropertiesReadDirectoryRef directoryType;

/**
 *  解析完成的字典
 */
@property (nonatomic, strong, readonly) NSDictionary <NSString *, NSString *>* result;
/**
 *  提取的所有key
 */
@property (nonatomic, strong, readonly) NSArray <NSString *>* keys;
@property (nonatomic, strong) NSArray <IWPViewModel *>* viewModels;
@property (nonatomic, strong) IWPPropertiesSourceModel * mainModel;
@property (nonatomic, strong) NSDictionary * md5Check;
@property (nonatomic, strong) NSMutableData * fileData;
@end



@implementation IWPPropertiesReader

#pragma mark 構造方法
// 從網絡讀取文件
-(NSMutableData *)fileData{
    if (_fileData == nil) {
        _fileData = [NSMutableData data];
    }
    return _fileData;
}

-(instancetype)initWithURL:(NSString *)url{
    if (self = [super init]) {
        _url = url;
    }
    [self loadNetFile];
    return self;
}

+(instancetype)proertiesReaderWithURL:(NSString *)url{
    return [[self alloc] initWithURL:url];
}

-(instancetype)initWithMD5FileURL:(NSString *)url{
    if (self = [super init]) {
        _url = url;
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
        NSString *retStr = [[NSString alloc] initWithData:data encoding:enc];
        [self createDictWithSourceString:retStr];
    }
    
    return self;
}
+(instancetype)proertiesReaderWithMD5FileURL:(NSString *)url{
    return [[self alloc] initWithMD5FileURL:url];
}

// 從本地文件初始化
// MARK: 袁全 --- 解析 步骤2
-(instancetype)initWithFileName:(NSString *)fileName withFileDirectoryType:(IWPPropertiesReadDirectoryRef)directoryType{
    if (self = [super init]) {
        
        _fileName = fileName;
        _directoryType = directoryType;
    }
    [self loadLocalFile];
    return self;
}

// MARK: 袁全 --- 解析 步骤1

+(instancetype)propertiesReaderWithFileName:(NSString *)fileName withFileDirectoryType:(IWPPropertiesReadDirectoryRef)directoryType{
    return [[self alloc] initWithFileName:fileName withFileDirectoryType:directoryType];
}

#pragma mark - 全工程只有 IWPPDTableViewController 使用

-(instancetype)initWithMD5FileName:(NSString *)fileName withFileDirectoryType:(IWPPropertiesReadDirectoryRef)directoryType{
    if (self = [super init]) {
        _fileName = fileName;
        _directoryType = directoryType;
    }
    [self createMD5Dict];
    return self;
}


+(instancetype)propertiesReaderWithMD5FileName:(NSString *)fileName withFileDirectoryType:(IWPPropertiesReadDirectoryRef)directoryType{
    return [[self alloc] initWithMD5FileName:fileName withFileDirectoryType:directoryType];
}
#pragma mark - -------



#pragma mark 讀取本地文件
// MARK: 袁全 解析 -- 步骤3
- (void)loadLocalFile{
    
    NSAssert(_fileName && _fileName.length != 0, @"未检测到你传入的resLogicName或FileName");
    
    NSString * searchPath;
    NSError * err;
    
    
    
    NSBundle * bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                  pathForResource:@"OSS2_Properties"
                                                  ofType:@"bundle"]];

    // 检测 是否存在 UNI_ , 此判断仅在智网通时使用
    if (![_fileName hasPrefix:@"UNI_"]) {
        _fileName = [NSString stringWithFormat:@"UNI_%@",_fileName];
    }
    
    
    searchPath = [bundle pathForResource:_fileName ofType:@"properties"];
    
    
    NSString *sourceString = [NSString stringWithContentsOfFile:searchPath encoding:NSISOLatin1StringEncoding error:&err];
    
    if (err && !sourceString) {
        [[Yuan_HUD shareInstance] HUDFullText:@"未找到对应的模板文件"];
    }
    
    if (err) {
        NSLog(@"文件讀取失敗:%@",err.localizedDescription);
        // download this file
        [self downloadFile];
        return;
    }

    //MARK: 证明下载的模板解析失败 从本地(工程里的文件)解析 -- 袁全新增 2020.12.18
    if ([sourceString containsString:@"<title>404"] && self.directoryType != IWPPropertiesReadDirectoryBundle) {
        
        [[Yuan_HUD shareInstance] HUDHide];
        [[Yuan_HUD shareInstance] HUDFullText:@"正在查找本地模板文件"];
        
        searchPath = [[NSBundle mainBundle] pathForResource:_fileName ofType:@"properties"];
        
        sourceString = [NSString stringWithContentsOfFile:searchPath encoding:NSISOLatin1StringEncoding error:&err];
        
    }
    
  [self analysisFileWithSourceString:sourceString];
}


// MARK: 袁全 解析 -- 步骤 4.1 如果没有在本地找到.properties文件 , 就去下载

-(void)downloadFile{
    
#ifdef BaseURL
    NSString * downloadLink = DOWNLOAD_LINK;
#else
    NSString * downloadLink = DOWNLOAD_LINK_Auto(([IWPServerService sharedService].link));
#endif
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@.properties",downloadLink,UserModel.domainCode,_fileName]];
    
    NSURLConnection * c = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:url] delegate:self];
    [c start];
}

-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data{
    [self.fileData appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection*)connection{
//    NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.properties",_fileName]];
    NSString * filePath = [NSString stringWithFormat:@"%@/%@/%@.properties",DOC_DIR,kPropertiesPath,_fileName];
    
    
    [self.fileData writeToFile:filePath atomically:NO];
}


+(NSArray<NSString *> *)newFileList{
    /* 获取更新文件列表 */
    /* 获取维护区域代码 */
    NSString * domainCode = UserModel.domainCode;

    if ([domainCode isEqualToString: @"0/"]) {
        domainCode = @"0D";
    }

#ifdef BaseURL
    NSString * downloadLink = DOWNLOAD_LINK;
#else
    NSString * downloadLink = DOWNLOAD_LINK_Auto(([IWPServerService sharedService].link));
#endif
    
    /* 读取新MD5信息 */
//    NSDictionary * newMD5 = [self MD5WithFile:[NSString stringWithFormat:@"%@/%@/resMD5.properties", downloadLink, domainCode] filePath:kPropertiesPath];
    
    //MARK:  袁全修改过的新地址
    NSDictionary * newMD5 = [self MD5WithFile:[NSString stringWithFormat:@"%@resMD5.properties", downloadLink] filePath:kPropertiesPath];
    
    /* 读取就MD5信息 */
    NSDictionary * oldMD5 = [self MD5WithFile:@"resMD5.properties" filePath:kPropertiesPath];
    
    /* 创建返回数组 */
    NSMutableArray * fileList = [NSMutableArray array];
    
    /* 遍历新的md5字典的allkeys，读取所有文件名 */
    for (NSString * fileName in newMD5.allKeys) {
        
        /* 判断验证：获取新的md5，再用相同文件名到旧MD5中读取md5值验证 */
        if (![newMD5[fileName] isEqualToString:oldMD5[fileName]] ||
            oldMD5[fileName] == nil/* 当取值为空时说明是新增文件 */) {
            [fileList addObject:fileName];
        }
    }
    
    if (fileList.count > 0) {
        [fileList addObject:@"resMD5.properties"];
    }
    
    return fileList;
    
}

#pragma mark 讀取網路文件
- (void)loadNetFile{
    NSURL *url = [NSURL URLWithString:_url];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
    NSString *retStr = [[NSString alloc] initWithData:data encoding:enc];
    [self analysisFileWithSourceString:retStr];
}
-(void)setReadType:(IWPPropertiesReadDirectoryRef)readType{
    _readType = readType;
    self.directoryType = readType;
}

#pragma mark MD5驗證相關
-(void)createMD5Dict{
    NSString * searchPath = nil;
    NSError * err = nil;
    if (self.directoryType == IWPPropertiesReadDirectoryBundle) {
        //
        searchPath = [[NSBundle mainBundle] pathForResource:_fileName ofType:@"properties"];
    }else{
        if (self.directoryType == IWPPropertiesReadDirectoryDocuments) {
            searchPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        }else if (self.directoryType == IWPPropertiesReadDirectoryLibrary){
            searchPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
        }else{
            searchPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        }
        searchPath = [searchPath stringByAppendingString:[NSString stringWithFormat:@"/%@/%@.properties",kPropertiesPath,_fileName]];
    }
    
    NSString *sourceString = [NSString stringWithContentsOfFile:searchPath encoding:NSISOLatin1StringEncoding error:&err];
    if (err) {
        NSLog(@"文件讀取失敗:%@",err.localizedDescription);

        return;
    }
    
    [self createDictWithSourceString:sourceString];
}



-(void)createDictWithSourceString:(NSString *)sourceString{
    
    if (sourceString.length == 0) {
        self.md5Check = [NSDictionary dictionary];
        return;
    }
    NSMutableArray * sourceArray = [NSMutableArray arrayWithArray:[sourceString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\r"]]];
    
    for (int j = 0; j < 5; j++) {
        for (int i = 0; i < sourceArray.count; i++) {
            
            
            NSLog(@"%@", sourceArray[i]);
            if ([sourceArray[i] length] == 0 ||
                [sourceArray[i] hasPrefix:@"#"]) {
            
                [sourceArray removeObjectAtIndex:i];
            }
        }
    }
    
    NSLog(@"%@",sourceArray);
    
    BOOL isMaoHao = [self isMaoHaoWithString:sourceArray[0]];
    
    NSString * cutStr = @"=";
    
    if (isMaoHao) {
        cutStr = @":";
    }
    
    
    
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    
    for (NSString * string in sourceArray) {
        
        NSLog(@"%@", string);
        
        NSArray * arr = [string componentsSeparatedByString:cutStr];
        
        NSString * fileName = arr[0];
        NSString * MD5 = arr[1];
        
        [result setValue:MD5 forKey:fileName];
    }
    self.md5Check = result;
}


#pragma mark 通用解析方法s
// MARK: 袁全 解析 -- 步骤4.2 如果有.properties文件 , 解析他
- (void)analysisFileWithSourceString:(NSString *)sourceString{
    
    // sourceString
    if ([sourceString rangeOfString:[NSString stringWithFormat:@"%@.properties", _fileName]].length > 0) {
    
        
        [self downloadFile];// 文件读取出错时，重新下载
    }else{
        
        //MARK: 袁全 -- 通常走这个分支
        NSMutableArray * sourceArray = [NSMutableArray arrayWithArray:[sourceString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\r"]]];
        
        
        
        
        for (int j = 0; j < 5; j++) {  //这个 i < 5 的循环 , 是什么意义?
            for (int i = 0; i < sourceArray.count; i++) {
                if ([sourceArray[i] length] == 0 ||
                    [sourceArray[i] hasPrefix:@"#"]) {
                    [sourceArray removeObjectAtIndex:i];
                }
            }
        }
        [self createDictionayWithSourceArray:sourceArray];
    }
    
    
}


// MARK: 袁全 解析 -- 步骤5 通过sourceArray 创建一个键值对
-(void)createDictionayWithSourceArray:(NSArray *)sourceArray{
    
    
    if (!sourceArray || sourceArray.count == 0) {
//        [YuanHUD HUDFullText:@"未检测到对应模板"];
        return;
    }
    
    BOOL isMaoHao = [self isMaoHaoWithString:sourceArray[0]];
    
    NSString * cutStr = @"=";
    
    if (isMaoHao) {
        cutStr = @":";
    }
    
    NSMutableArray * keys = [NSMutableArray array];
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    
    for (NSString * string in sourceArray) {
        NSArray * arr = [string componentsSeparatedByString:cutStr];
        
        NSString * key = arr[0];
        NSString * object = arr[1];
        
        if (isMaoHao) {
            NSArray * specialKeys = @[@"view"];
            for (NSString * SPK in specialKeys) {
                if ([key isEqualToString:SPK]) {
                    NSArray * tmp = [string componentsSeparatedByString:[NSString stringWithFormat:@"%@%@",SPK,cutStr]];
                    object = [tmp lastObject];
                }
            }
            
        }
        [result setValue:object forKey:key];
        [keys addObject:key];
    }
    
    NSString * s = [NSMutableString stringWithString:@"{"];
    for (NSString * key in keys) {
        if ([key isEqualToString:@"view"]) {
            s = [s stringByAppendingString:[NSString stringWithFormat:@"\"%@\":%@,",key,[result valueForKey:key]]];;
            continue;
        }
        NSString * strTmp = [result valueForKey:key];
        s = [s stringByAppendingString:[NSString stringWithFormat:@"\"%@\":\"%@\",",key,strTmp]];
    }
    
    NSMutableString * str = [s mutableCopy];
    NSRange range = {str.length - 1,1};
    s = [str stringByReplacingCharactersInRange:range withString:@"}"];
    
    NSData * data = [s dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    _keys = keys;
    _result = dict;
    
    // 取解析结果
    self.mainModel = [IWPPropertiesSourceModel modelWithDict:_result];
    
    // 创建viewModel
    NSMutableArray * arrr = [NSMutableArray array];
    for (NSDictionary * dict in self.mainModel.view) {
        IWPViewModel * viewModel = [IWPViewModel modelWithDict:dict];
        [arrr addObject:viewModel];
    }
    self.viewModels = arrr;

    
}

-(BOOL)isMaoHaoWithString:(NSString *)string{
    
    NSLog(@"%@",[string componentsSeparatedByString:@"="]);
    
    NSLog(@"%@", _fileName);
    
    if ([string componentsSeparatedByString:@"="].count < 2) {
        return YES;
    }
    return NO;
}
#pragma mark - 图片下载更新

+ (NSArray *)getMainNewFileList{
    
#ifdef BaseURL
    NSString * downloadLink = MenuProps_MainPage_Download_Link;
#else
    NSString * downloadLink = MenuProps_MainPage_Download_Link_Auto(([IWPServerService sharedService].link));
#endif
    
    /* 获取更新文件列表 */
    
    /* 读取新MD5信息 */
    NSDictionary * newMD5 = [self MD5WithFile:[NSString stringWithFormat:@"%@/%@.properties", downloadLink, MenuProps_Mainpage_MD5FileName] filePath:nil];
    
    /* 读取就MD5信息 */
    NSDictionary * oldMD5 = [self MD5WithFile:[NSString stringWithFormat:@"%@.properties",MenuProps_Mainpage_MD5FileName] filePath:kResourceMainProps];
    
    /* 创建返回数组 */
    NSMutableArray * fileList = [NSMutableArray array];
    
    /* 遍历新的md5字典的allkeys，读取所有文件名 */
    for (NSString * fileName in newMD5.allKeys) {
//        NSLog(@"%@", fileName);
        /* 判断验证：获取新的md5，再用相同文件名到旧MD5中读取md5值验证 */
        if (![newMD5[fileName] isEqualToString:oldMD5[fileName]] ||
            oldMD5[fileName] == nil/* 当取值为空时说明是新增文件 */) {
            [fileList addObject:fileName];
        }
    }
    
    
    if (fileList.count > 0) {
        [fileList addObject:[NSString stringWithFormat:@"%@.properties",MenuProps_Mainpage_MD5FileName]];
    }
    
    
    
    return fileList;
}

#pragma mark - 模板文件MD5验证相关方法

+ (NSArray *)newEqutPropsFileList{
    
#ifdef BaseURL
    NSString * downloadLink = EqutProps_Download_Link;
#else
    NSString * downloadLink = EqutProps_Download_Link_Auto(([IWPServerService sharedService].link));
#endif
    
    /* 获取更新文件列表 */
    
    /* 读取新MD5信息 */
    NSDictionary * newMD5 = [self MD5WithFile:[NSString stringWithFormat:@"%@%@.properties", downloadLink, EqueProps_MD5_FileName] filePath:nil];

    /* 读取就MD5信息 */
    NSDictionary * oldMD5 = [self MD5WithFile:[NSString stringWithFormat:@"%@.properties",EqueProps_MD5_FileName] filePath:kEqutProps];
    
    /* 创建返回数组 */
    NSMutableArray * fileList = [NSMutableArray array];
    
    /* 遍历新的md5字典的allkeys，读取所有文件名 */
    for (NSString * fileName in newMD5.allKeys) {
        NSLog(@"%@", fileName);
        /* 判断验证：获取新的md5，再用相同文件名到旧MD5中读取md5值验证 */
        if (![newMD5[fileName] isEqualToString:oldMD5[fileName]] ||
            oldMD5[fileName] == nil/* 当取值为空时说明是新增文件 */) {
            [fileList addObject:fileName];
        }
    }
    
    return fileList;
  
}
+(NSDictionary *)MD5WithFile:(NSString *)file filePath:(NSString *)filePath{
    
    NSLog(@"%@", file);
    
    /* 将文件读取为字符串 */
    NSString * sourceString = [self sourceStringWithFile:file filePath:filePath];
    /* 创建字典并返回 */
    
    
    NSDictionary * dict = [self propertiesToDict:sourceString];
    
    if ([file rangeOfString:cardModelPropsMD5_FileName].length > 0) {
         NSLog(@"%@", dict);
    }
    
    
    NSString * str = dict.json;

    str = [str stringByReplacingOccurrencesOfString:@"\\\\u" withString:@"\\u"];

    NSDictionary * newDict = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    
    return newDict;
}
+ (NSString *)sourceStringWithFile:(NSString *)file filePath:(NSString *)filePath{
    
    NSData * data = nil;
    /* 区分传入字符串 */
    if ([file rangeOfString:@"http://"].length ||
        [file rangeOfString:@"https://"].length > 0) {
        /* 读取网络文件 */
        data = [NSData dataWithContentsOfURL:[NSURL URLWithString:file]];

        NSLog(@"%@", file);
        
    }else{
        /* 读取本地文件 */

        data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/%@", DOC_DIR, filePath, file]];
    }
    
    /* 创建字符串并返回 */
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
+ (NSDictionary *)propertiesToDict:(NSString *)sourceString{
    
    /* 以行为单位，将字符串分割维数组 */
    NSMutableArray * arr = [NSMutableArray arrayWithArray:[sourceString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\r"]]];
    /* 移除所有空项 */
    [arr removeObject:@""];
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    
    for (NSString * str in arr) {
        
        /* 判断是否为注释行 */
        if (![self isHideLine:str]) {
            /* 获取该行分割文版 */
            NSString * cutChar = [self keyValueCutChar:str];
            
            /* 如果是view字段的内容，进行特殊处理 */
            if ([str rangeOfString:[NSString stringWithFormat:@"view%@",cutChar]].length > 0) {
                /* 分割 */
                NSArray * a = [str componentsSeparatedByString:[NSString stringWithFormat:@"view%@",cutChar]];
                /* 将内容转为数组 */
                NSArray * arr = [NSJSONSerialization JSONObjectWithData:[a[1] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
                /* 将数组加入到字典中 */
                [dict setValue:arr forKey:@"view"];
            }else{
                /* 分割 */
                NSArray * a = [str componentsSeparatedByString:cutChar];
                /* 存入 */
                [dict setValue:a[1] forKey:a[0]];
            }
        }
    }
    return dict;
}
+ (BOOL)isHideLine:(NSString *)str{
    
    /* 判断是否为注释行 */
    if ([str hasPrefix:@"#"] ||
        [str hasPrefix:@"//"] ||
        [str hasPrefix:@"/*"] ||
        [str hasSuffix:@"*/"] ||
        [str hasPrefix:@"<--"] ||
        [str hasSuffix:@"-->"] ||
        [str hasPrefix:@"=="] ||
        [str hasSuffix:@"=="]) {
        return true;
    }
    return false;
    
}
+ (NSString *)keyValueCutChar:(NSString *)str{
    
    /* 判断分割文本 */
    if ([str rangeOfString:@"="].length > 0) {
        return @"=";
    }
    return @":";
}
+ (BOOL)isHasRetion:(NSString *)fileName{
    NSError * err = nil;
    NSString * searchPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    searchPath = [searchPath stringByAppendingString:[NSString stringWithFormat:@"/%@/%@.properties",kPropertiesPath,fileName]];
    
    NSString * sourceString = [NSString stringWithContentsOfFile:searchPath encoding:NSISOLatin1StringEncoding error:&err];
    
    NSLog(@"%@ --- %@", sourceString, err.localizedDescription);
    
    if ([sourceString rangeOfString:@"retion"].length > 0) {
        return YES;
    }
    
    return NO;
}
+(BOOL)isHasCoordinate:(NSString *)fileName{
    
    NSString * searchPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    searchPath = [searchPath stringByAppendingString:[NSString stringWithFormat:@"/%@/%@.properties",kPropertiesPath,fileName]];
    
    NSString * sourceString = [NSString stringWithContentsOfFile:searchPath encoding:NSISOLatin1StringEncoding error:nil];
    
    NSLog(@"%@", sourceString);
    
    if ([sourceString rangeOfString:@"lon"].length > 0 &&
        [sourceString rangeOfString:@"lat"].length > 0) {
        return YES;
    }
    
    return NO;
}
@end

@implementation IWPPropertiesSourceModel

- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        if (dict) {
            [self setValuesForKeysWithDictionary:dict];
        }
    }
    return self;
}

+ (instancetype)modelWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}



@end

@implementation IWPViewModel

- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+ (instancetype)modelWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}

-(NSString *)description{
    /**
     *  @property (nonatomic, copy) NSString * tv1_Text;
     @property (nonatomic, copy) NSString * tv1_Required;
     @property (nonatomic, copy) NSString * name1;
     @property (nonatomic, copy) NSString * name2;
     @property (nonatomic, copy) NSString * name4;
     @property (nonatomic, copy) NSString * name3;
     @property (nonatomic, copy) NSString * type;
     @property (nonatomic, copy) NSString * ed1_Ed;
     @property (nonatomic, copy) NSString * ed1_Hint;
     @property (nonatomic, copy) NSString * ed2_Ed;
     @property (nonatomic, copy) NSString * ed2_Hint;
     @property (nonatomic, copy) NSString * sp_text;
     @property (nonatomic, copy) NSString * btn1_text;
     @property (nonatomic, copy) NSString * text1;
     @property (nonatomic, copy) NSString * temp_text;
     @property (nonatomic, copy) NSString * text2;
     */
//    _tv1_Text,_tv1_Required,_name1,_name2,_name3,_name4,_type,_ed1_Ed,_ed1_Hint,_ed2_Ed,_ed2_Hint,_sp_text,_btn1_text,_text1,_temp_text,_text2
    NSString * des = [NSString stringWithFormat:@"_tv1_Text = %@,_tv1_Required = %@,_name1 = %@,_name2 = %@,_name3 = %@,_name4 = %@,_type = %@,_ed1_Ed = %@,_ed1_Hint = %@,_ed2_Ed = %@,_ed2_Hint = %@,_sp_text = %@,_btn1_text = %@,_text1v = %@,_temp_text = %@,_text2 = %@",_tv1_Text,_tv1_Required,_name1,_name2,_name3,_name4,_type,_ed1_Ed,_ed1_Hint,_ed2_Ed,_ed2_Hint,_sp_text,_btn1_text,_text1,_temp_text,_text2];
    
    return des;
}



#pragma mark -  袁全新增


- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    
    
}


- (id)valueForUndefinedKey:(NSString *)key {
    
    return nil;
    
}


@end

