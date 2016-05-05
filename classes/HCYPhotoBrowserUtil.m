//
//  HCYPhotoBrowserUtil.m
//  dfgdf
//
//  Created by hcy on 16/3/31.
//  Copyright © 2016年 hcy. All rights reserved.
//

#import "HCYPhotoBrowserUtil.h"

@implementation HCYPhotoBrowserUtil
+(CGRect)hcyPhotoNewRectForImage:(UIImage *)image maxScale:(CGFloat *)maxScale contentSize:(CGSize *)contentSize autoResize:(BOOL)autoResize{
    CGSize size=image.size;
    CGRect imageRect=CGRectZero;
        //宽图居中
    if (size.width>=HCYPHOTOBROWSERSCREENWIDTH && size.height<=HCYPHOTOBROWSERSCREENHEIGHT) {
        imageRect=CGRectMake(0, (HCYPHOTOBROWSERSCREENHEIGHT-size.height)*.5, HCYPHOTOBROWSERSCREENWIDTH, size.height);
        if (maxScale) {
            *maxScale=HCYPHOTOBROWSERSCREENHEIGHT/size.height;
        }
    }
    //长图居中
    if (size.height>=HCYPHOTOBROWSERSCREENHEIGHT && size.width<=HCYPHOTOBROWSERSCREENWIDTH) {
        imageRect=CGRectMake((HCYPHOTOBROWSERSCREENWIDTH-size.width)*.5, 0, size.width, size.height);
        if (maxScale) {
            *maxScale=(HCYPHOTOBROWSERSCREENWIDTH)/size.width;
        }
    }
    //小图缩放
    if (size.width<=HCYPHOTOBROWSERSCREENWIDTH && size.height<=HCYPHOTOBROWSERSCREENHEIGHT) {
        CGFloat widthScale=HCYPHOTOBROWSERSCREENWIDTH/size.width;
        CGFloat heightScale=HCYPHOTOBROWSERSCREENHEIGHT/size.height;
        CGFloat scale=MIN(widthScale, heightScale);
        if (scale==widthScale) {
            imageRect=CGRectMake(0, (HCYPHOTOBROWSERSCREENHEIGHT-size.height*scale)*.5, HCYPHOTOBROWSERSCREENWIDTH, size.height*scale);
            if (maxScale) {
                *maxScale=HCYPHOTOBROWSERSCREENHEIGHT/imageRect.size.height;
            }
        }else{
            imageRect=CGRectMake((HCYPHOTOBROWSERSCREENWIDTH-size.width*scale)*.5, 0, size.width*scale, HCYPHOTOBROWSERSCREENHEIGHT);
            if (maxScale) {
                *maxScale=HCYPHOTOBROWSERSCREENWIDTH/imageRect.size.width;
            }
        }
    }
    if (contentSize!=nil) {
        *contentSize=imageRect.size;
    }
    
    //大图不动
    if (autoResize) {
        CGSize imageSize = CGSizeMake(size.width / image.scale,
                                      size.height / image.scale);
        
        CGFloat widthRatio = imageSize.width / HCYPHOTOBROWSERSCREENWIDTH;
        CGFloat heightRatio = imageSize.height /HCYPHOTOBROWSERSCREENHEIGHT;
        
        if (widthRatio > heightRatio) {
             imageSize= CGSizeMake(imageSize.width / widthRatio, imageSize.height / widthRatio);
            imageRect=CGRectMake(0, (HCYPHOTOBROWSERSCREENHEIGHT-imageSize.height)*.5, imageSize.width, imageSize.height);
        } else {
            imageSize = CGSizeMake(imageSize.width / heightRatio, imageSize.height / heightRatio);
          imageRect=CGRectMake(0, (HCYPHOTOBROWSERSCREENHEIGHT-imageSize.height)*.5, imageSize.width, imageSize.height);
        }
        if (contentSize!=nil) {
            *contentSize=imageSize;
        }
    }else{
        imageRect=CGRectMake(0, 0, size.width, size.height);
    }
    if (maxScale!=nil) {
        *maxScale=2;
    }
    return imageRect;
}

+(HCYPhotoBrowserAdjustType)adjustTypeForImage:(UIImage *)image{
    CGSize size=image.size;
    if (size.width>=HCYPHOTOBROWSERSCREENWIDTH && size.height>=HCYPHOTOBROWSERSCREENHEIGHT) {
        CGRect trueRect=[self hcyPhotoNewRectForImage:image maxScale:nil contentSize:nil autoResize:YES];
        size=trueRect.size;
        return [self adjustTypeForSize:size];
    }else{
        return [self adjustTypeForSize:image.size];
    }
}
+(HCYPhotoBrowserAdjustType)adjustTypeForSize:(CGSize)size{
    if (size.width>=HCYPHOTOBROWSERSCREENWIDTH && size.height<=HCYPHOTOBROWSERSCREENHEIGHT) {
        return HCYPhotoBrowserAdjustTypeY;
    }
    if (size.height>=HCYPHOTOBROWSERSCREENHEIGHT && size.width<=HCYPHOTOBROWSERSCREENWIDTH) {
        return HCYPhotoBrowserAdjustTypeX;
    }
    if (size.width<=HCYPHOTOBROWSERSCREENWIDTH && size.height<=HCYPHOTOBROWSERSCREENHEIGHT) {
        return HCYPhotoBrowserAdjustTypeY;
    }
    if (size.width>=HCYPHOTOBROWSERSCREENWIDTH && size.height>=HCYPHOTOBROWSERSCREENHEIGHT) {
        return HCYPhotoBrowserAdjustTypeAll;
    }
    return HCYPhotoBrowserAdjustTypeNone;
}
static int HCYPhotoBrowserFileSizeMax=1024;
+(NSString *)fileSizeStrWithByteLength:(long long)length{
    int i=0;
    while (length>HCYPhotoBrowserFileSizeMax*0.98) {
        length=length/HCYPhotoBrowserFileSizeMax;
        i++;
    }
    NSString *suffix=@"GB";
    if ([[self fileSizeExtDict] objectForKey:@(i)]) {
        suffix=[[self fileSizeExtDict] objectForKey:@(i)];
        NSString *str=[NSString stringWithFormat:@"%.2f%@",(float)length,suffix];
        return str;
    }
    return @"";
}

+(NSDictionary *)fileSizeExtDict{
    static NSDictionary *fileSizeExtDict;
    fileSizeExtDict=@{@(0):@"B",
                      @(1):@"KB",
                      @(2):@"MB",
                      @(3):@"GB"};
    return fileSizeExtDict;
}
@end
