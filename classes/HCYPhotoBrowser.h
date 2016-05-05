//
//  HCYPhotoBrowser.h
//  FriendCircle
//
//  Created by hcy on 15/12/14.
//  Copyright © 2015年 hcy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HCYPhotoBrowser,HCYPhoto;
@protocol HCYPhotoBrowserDelegate <NSObject>
@optional
-(void)browser:(HCYPhotoBrowser *)browser TapPhoto:(HCYPhoto *)photo;
-(void)browser:(HCYPhotoBrowser *)browser LongPressedPhoto:(HCYPhoto *)photo;
-(void)browser:(HCYPhotoBrowser *)browser showPhotoAtIndex:(NSInteger)index;
-(void)browserDidLoad:(HCYPhotoBrowser *)browser;
-(void)browserWillAppear:(HCYPhotoBrowser *)browser;
-(void)browserWillDisappear:(HCYPhotoBrowser *)browser;
@end
@protocol HCYPhotoBrowserDataSource <NSObject>
-(NSUInteger)numberOfPhotosInBrowser:(HCYPhotoBrowser *)browser;
-(HCYPhoto *)photoWithIndex:(NSUInteger)index;
@end
@interface HCYPhotoBrowser : UIViewController
@property(weak,nonatomic)id<HCYPhotoBrowserDelegate> browserDelegate;
@property(weak,nonatomic)id<HCYPhotoBrowserDataSource> browserDataSource;
@property(assign,nonatomic)NSInteger currentIndex;
-(void)show;
-(void)hide;
@end
