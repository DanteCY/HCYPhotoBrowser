//
//  HCYPhotoDownloadManager.h
//  dfgdf
//
//  Created by hcy on 16/4/17.
//  Copyright © 2016年 hcy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class HCYPhotoDownloadManager;
@protocol HCYPhotoDownloadManagerDelegate <NSObject>
/**
 *  下载进度回调
 *
 *  @param manager  管理器
 *  @param url      地址
 *  @param progress 进度
 */
-(void)hcyManager:(HCYPhotoDownloadManager *)manager downloadFromUrl:(NSURL *)url withProgress:(CGFloat)progress;
/**
 *  下载完成回调
 *
 *  @param manager    管理器
 *  @param url        地址
 *  @param completion 完成回调
 */
-(void)hcyManager:(HCYPhotoDownloadManager *)manager downloadFromUrl:(NSURL *)url withCompletion:(void(NSData *fileData,NSError *error))completion;
@end

@interface HCYPhotoDownloadManager : NSObject
+(instancetype)sharedManager;
/**
 *  如果多次调用情况
 *  如果有该地址正在下载中，则会合并任务。
 *  如果下载完成的话，无法判断会重新下载，所以调用者需要先判断是否已经下载完成
 *  @param url
 */
-(void)downLoadFromUrl:(NSURL *)url;
-(void)addDelegate:(id)delegate;
-(void)removeDelegate:(id)delegate;
@end
