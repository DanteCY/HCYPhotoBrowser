//
//  HCYPhoto.h
//  FriendCircle
//
//  Created by hcy on 15/12/14.
//  Copyright © 2015年 hcy. All rights reserved.
//

#import <UIKit/UIKit.h>
extern NSString *PhotoIdentifierKey;
typedef  UIImage *(^HCYPhotoSourceBlock)();
typedef  void(^HCYPhotoImageRefreshBlock)(UIImage *image,NSDictionary *userInfo);
typedef NS_ENUM(NSInteger,HCYPhotoType){
    HCYPhotoTypeSync=0,
    HCYPhotoTypeAsync
};

/**
 *  照片模型类
 *  加载照片顺序
 *  1.sourceImageView.image
 *  2.sourePath处的image
 *  3.
 *
 */
@interface HCYPhoto : UIView
#pragma mark 通用属性
/**
 *  用来表示模型唯一性
 */
@property(copy,nonatomic)NSString *photoIdentifier;
/**
 *用来做动画用
 */
@property(strong,nonatomic)UIImageView *sourceImageView;

@property(assign,nonatomic)HCYPhotoType photoType;
#pragma mark mode1 以同步形式获取资源,支持远程下载
/**
 *本地图片路径
 */
@property(copy,nonatomic)NSString *sourcePath;

/**
 *  是否需要自动缩放
 */
@property(assign,nonatomic,getter=isAutoResize)BOOL autoResize;
/**
 *  是否需要下载
 */
@property(assign,nonatomic)BOOL needDownload;
/*
 *下载地址
 */
@property(copy,nonatomic)NSString *downloadUrl;
@property(assign,nonatomic)NSInteger fileLength;//nim使用


#pragma mark mode 2 以block形式加载本地图片
//不支持下载,用于支持类似Photos.framework这种异步返回资源用
@property(copy,nonatomic)HCYPhotoSourceBlock sourceBlock;
-(void)localImageWithCompletion:(HCYPhotoImageRefreshBlock)completion;
@end
