//
//  HCYPhotoDownloadManager.m
//  dfgdf
//
//  Created by hcy on 16/4/17.
//  Copyright © 2016年 hcy. All rights reserved.
//

#import "HCYPhotoDownloadManager.h"
@interface HCYPhotoDownloadManager(){
    NSMutableArray *_downloadArr;
    NSMutableArray *_delegateArr;
}

@end
@implementation HCYPhotoDownloadManager
#pragma mark 初始化
static HCYPhotoDownloadManager *downloadManager;
+(instancetype)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloadManager=[HCYPhotoDownloadManager new];
    });
    return downloadManager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _downloadArr=[NSMutableArray array];
        _delegateArr=[NSMutableArray array];
    }
    return self;
}
#pragma mark delegate
-(void)addDelegate:(id)delegate{
    if ([_delegateArr containsObject:delegate]) {
        return;
    }
    [_delegateArr addObject:delegate];
}
-(void)removeDelegate:(id)delegate{
    [_delegateArr removeObject:delegate];
}
#pragma mark download
@end
