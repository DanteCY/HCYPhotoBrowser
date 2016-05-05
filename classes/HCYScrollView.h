//
//  HCYScrollView.h
//  FriendCircle
//
//  Created by hcy on 15/12/14.
//  Copyright © 2015年 hcy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HCYPhoto,HCYScrollView;
@protocol HCYScrollViewDelegate <NSObject>
-(void)hcyScrollViewTaped:(HCYScrollView *)scrollView;
-(void)hcyScrollViewDoubleTaped:(HCYScrollView *)scrollView;
-(void)hcyScrollViewLongPressed:(HCYScrollView *)scrollView;
@end

@interface HCYScrollView : UIScrollView
@property(strong,nonatomic)UIImageView *imageView;
-(void)refreshWithPhoto:(HCYPhoto *)photo;
@property(weak,nonatomic)id<HCYScrollViewDelegate> hcyDelegate;

-(void)willHide;
@end
