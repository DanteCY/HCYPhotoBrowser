//
//  HCYScrollView.m
//  FriendCircle
//
//  Created by hcy on 15/12/14.
//  Copyright © 2015年 hcy. All rights reserved.
//

#import "HCYScrollView.h"
#import "HCYPhoto.h"
#import "HCYPhotoBrowserUtil.h"
//#import "UIImageView+WebCache.h"
@interface HCYScrollView()<UIScrollViewDelegate,UIGestureRecognizerDelegate>
//subviews
@property(strong,nonatomic)UIView *hcyScollContainerView;
@property(strong,nonatomic)UIActivityIndicatorView *activityView;
//gestures
@property(strong,nonatomic) UITapGestureRecognizer *tapGesture;
@property(strong,nonatomic) UITapGestureRecognizer *doubleTapGesture;
@property(strong,nonatomic) UILongPressGestureRecognizer *longPressGesture;

@property(assign,nonatomic)CGFloat fillScale;
@property(strong,nonatomic)HCYPhoto *photo;
@end
@implementation HCYScrollView

- (instancetype)init
{
    self = [super init];
    if (self) {
         self.delegate=self;
        [self setupSubviews];
        [self setupGestures];
    }
    return self;
}
#pragma mark prepare
-(void)setupSubviews{
    _hcyScollContainerView=[[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:_hcyScollContainerView];
    self.alwaysBounceHorizontal=YES;

    _imageView=[[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.contentMode=UIViewContentModeScaleAspectFit;
    _imageView.userInteractionEnabled=YES;
    [_hcyScollContainerView addSubview:_imageView];
    
    _activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_activityView sizeToFit];
    [self addSubview:_activityView];
}
-(void)setupGestures{
    SEL selector=@selector(handleGesture:);
    _tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:selector];
    _tapGesture.numberOfTapsRequired=1;
    [self addGestureRecognizer:_tapGesture];
    
    _doubleTapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:selector];
    _doubleTapGesture.numberOfTapsRequired=2;
    _doubleTapGesture.delegate=self;
    [self addGestureRecognizer:_doubleTapGesture];
    
    _longPressGesture=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:selector];
    _longPressGesture.minimumPressDuration=1.5;
    [self addGestureRecognizer:_longPressGesture];
}
#pragma mark publicEvents
-(void)refreshWithPhoto:(HCYPhoto *)photo{
    if (!photo) return;
    _photo=photo;
#warning  取消上个view的操作
    _activityView.center=self.center;
    if (photo.photoType==HCYPhotoTypeSync) {
        UIImage  *image=photo.sourceImageView.image;
        if (!image) {
            image=[UIImage imageWithContentsOfFile:photo.sourcePath];
        }
        if (!image) {
            return;
        }
        [self refreshImage:image];
        
    }else if(photo.photoType==HCYPhotoTypeAsync){
        __weak typeof(self) wself=self;
        [photo localImageWithCompletion:^(UIImage *image, NSDictionary *userInfo) {
            if (wself) {
                NSString *photoidenfiter=userInfo[PhotoIdentifierKey];
                if ([photoidenfiter isEqualToString:_photo.photoIdentifier]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [wself refreshImage:image];
                    });
                }
            }
        }];
    }
}
-(void)refreshImage:(UIImage *)image{
    self.zoomScale=1;
    self.minimumZoomScale=1;
    self.zoomScale=1;
    _imageView.image=image;
    CGFloat maxScale;
    CGSize contentSize;
    _hcyScollContainerView.frame=[HCYPhotoBrowserUtil hcyPhotoNewRectForImage:image maxScale:&maxScale contentSize:&contentSize autoResize:_photo.autoResize];
    _imageView.frame=_hcyScollContainerView.bounds;
    
    self.maximumZoomScale=maxScale;
    self.contentSize=contentSize;
}
-(void)willHide{
    self.zoomScale=1;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _activityView.center=self.center;
}
#pragma mark scrollViewDelegate
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _hcyScollContainerView;
}
-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    [self resetCenter];
}
-(void)resetCenter{
    HCYPhotoBrowserAdjustType type= [HCYPhotoBrowserUtil adjustTypeForImage:_imageView.image];
    switch (type) {
        case HCYPhotoBrowserAdjustTypeX:
        {
            CGPoint p=_hcyScollContainerView.center;
            p.x=HCYPHOTOBROWSERSCREENWIDTH*.5;
            _hcyScollContainerView.center=p;
        }
            break;
        case HCYPhotoBrowserAdjustTypeY:
        {
            CGPoint p=_hcyScollContainerView.center;
            p.y=HCYPHOTOBROWSERSCREENHEIGHT*.5;
            _hcyScollContainerView.center=p;
        }
            break;
        case HCYPhotoBrowserAdjustTypeAll:
        {
            CGPoint p=_hcyScollContainerView.center;
            p.x=HCYPHOTOBROWSERSCREENWIDTH*.5;
            p.y=HCYPHOTOBROWSERSCREENHEIGHT*.5;
            _hcyScollContainerView.center=p;
        }
            break;
        default:
            break;
    }
}

#pragma mark gestureDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer==_doubleTapGesture && otherGestureRecognizer==_tapGesture) {
        return YES;
    }else{
        return NO;
    }
}
#pragma mark gestureEvents
-(void)handleGesture:(UIGestureRecognizer *)gesture{
    SEL delegteSelector=nil;
    if (gesture==_tapGesture) {
        delegteSelector=@selector(hcyScrollViewTaped:);
    }else if (gesture==_doubleTapGesture){
        delegteSelector=@selector(hcyScrollViewDoubleTaped:);
        [self fillOrReset:(UITapGestureRecognizer *)gesture];
    }else if (gesture==_longPressGesture){
        if (_longPressGesture.state==UIGestureRecognizerStateBegan) {
            delegteSelector=@selector(hcyScrollViewLongPressed:);
        }
    }
    if (_hcyDelegate && delegteSelector && [_hcyDelegate respondsToSelector:delegteSelector]) {
        [_hcyDelegate performSelector:delegteSelector withObject:self];
    }
}
-(void)fillOrReset:(UITapGestureRecognizer *)tap{
    if (self.zoomScale==self.minimumZoomScale) {
        CGPoint p=[tap locationInView:tap.view];
        CGRect targetRect=CGRectZero;
        CGPoint containerPoint=CGPointZero;
//        if (CGRectContainsPoint(_hcyScollContainerView.frame, p)) {
//            containerPoint=[self convertPoint:p toView:_hcyScollContainerView];
//        }else{
//            containerPoint=[self convertPoint:p toView:_hcyScollContainerView];
//            CGFloat containerHeight=  _hcyScollContainerView.frame.size.height;
//            if (containerPoint.y<0) {
//                  containerPoint.y=_hcyScollContainerView.frame.origin.y+containerHeight*0.8;
//            }else{
//                containerPoint.y=_hcyScollContainerView.frame.origin.y+containerHeight*0.2;
//            }
//        }
//        targetRect=CGRectMake(containerPoint.x, containerPoint.y, 1, 1);
//        [self zoomToRect:targetRect animated:YES];
//        self.zoomScale=self.maximumZoomScale;
        [self setZoomScale:self.maximumZoomScale animated:YES];
    }else{
        [self setZoomScale:self.minimumZoomScale animated:YES];
    }
}
@end
