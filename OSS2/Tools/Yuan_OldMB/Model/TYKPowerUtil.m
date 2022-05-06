//
//  TYKPowerUtil.m
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/10/27.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "TYKPowerUtil.h"

@implementation TYKPowerUtil
-(NSMutableArray *)getHaveTYKRes:(NSMutableArray *)powersArr{
    BOOL isHave = NO;
    NSMutableArray *powerTempArr = [[NSMutableArray alloc] init];
    for (NSString *s in powersArr) {
        /*if ([s isEqualToString:@"BasicSpace"]||[s isEqualToString:@"generator"]||[s isEqualToString:@"linePipe"]||
            [s isEqualToString:@"poleline"]||[s isEqualToString:@"poleLineSegment"]||[s isEqualToString:@"pole"]||
            [s isEqualToString:@"pipe"]||[s isEqualToString:@"pipeSegment"]||[s isEqualToString:@"well"]||
            [s isEqualToString:@"markStoneSegment"]||[s isEqualToString:@"markStone"]||[s isEqualToString:@"supportingPoints"]||
            [s isEqualToString:@"ledUp"]||[s isEqualToString:@"cableNet"]||[s isEqualToString:@"route"]||
            [s isEqualToString:@"cable"]||[s isEqualToString:@"OCC_Equt"]||[s isEqualToString:@"joint"]||
            [s isEqualToString:@"ODB_Equt"]||[s isEqualToString:@"ODF_Equt"]||[s isEqualToString:@"stationBase"]||[s isEqualToString:@"EquipmentPoint"]
            ) {
            isHave = YES;
        }*/
        isHave = [self isInTYKRes:s];
        if (isHave) {
            [powerTempArr addObject:s];
            isHave = NO;
        }
    }
    return powerTempArr;
}
-(BOOL)isInTYKRes:(NSString *)s{
    BOOL isHave = NO;
    if ([s isEqualToString:@"BasicSpace"]||[s isEqualToString:@"generator"]||[s isEqualToString:@"linePipe"]||
        [s isEqualToString:@"poleline"]||[s isEqualToString:@"poleLineSegment"]||[s isEqualToString:@"pole"]||
        [s isEqualToString:@"pipe"]||[s isEqualToString:@"pipeSegment"]||[s isEqualToString:@"well"]||
        [s isEqualToString:@"markStoneSegment"]||[s isEqualToString:@"markStone"]||[s isEqualToString:@"supportingPoints"]||
        [s isEqualToString:@"ledUp"]||[s isEqualToString:@"cableNet"]||[s isEqualToString:@"route"]||
        [s isEqualToString:@"cable"]||[s isEqualToString:@"OCC_Equt"]||[s isEqualToString:@"joint"]||
        [s isEqualToString:@"ODB_Equt"]||[s isEqualToString:@"ODF_Equt"]||[s isEqualToString:@"stationBase"]||[s isEqualToString:@"EquipmentPoint"]
        ) {
        isHave = YES;
    }
    return isHave;
}
@end
