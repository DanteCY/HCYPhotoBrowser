//
//  HCYPhotoBrowserUtil.h
//  dfgdf
//
//  Created by hcy on 16/3/31.
//  Copyright © 2016年 hcy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define HCYPHOTOBROWSERSCREENWIDTH   [UIScreen mainScreen].bounds.size.width
#define HCYPHOTOBROWSERSCREENHEIGHT  [UIScreen mainScreen].bounds.size.height
typedef NS_ENUM(NSInteger,HCYPhotoBrowserAdjustType){
    HCYPhotoBrowserAdjustTypeNone=1,
    HCYPhotoBrowserAdjustTypeX,
    HCYPhotoBrowserAdjustTypeY,
    HCYPhotoBrowserAdjustTypeAll
};
@interface HCYPhotoBrowserUtil : NSObject
/**
 *  根据图片计算frame
 *
 *  @param image       图片
 *  @param maxScale    建议最大放大比例
 *  @param contentSize 建议contentSize
 *  @param autoResize  是否需要自动缩放
 *
 *  @return 图片frame
 */
+(CGRect)hcyPhotoNewRectForImage:(UIImage *)image maxScale:(CGFloat *)maxScale contentSize:(CGSize *)contentSize autoResize:(BOOL)autoResize;
+(HCYPhotoBrowserAdjustType)adjustTypeForImage:(UIImage *)image;
+(NSString *)fileSizeStrWithByteLength:(long long)filelength;
@end
