//
//  HCYPhotoBrowser.m
//  FriendCircle
//
//  Created by hcy on 15/12/14.
//  Copyright © 2015年 hcy. All rights reserved.
//

#import "HCYPhotoBrowser.h"
#import "HCYPhoto.h"
#import "HCYScrollView.h"
#import "HCYPhotoBrowserUtil.h"
@interface HCYPhotoBrowser()<UIScrollViewDelegate,HCYScrollViewDelegate>
@property(strong,nonatomic)UIScrollView *scrollView;
@property(strong,nonatomic)UIPageControl *pageControl;

//@property(strong,nonatomic)NSArray *photos;


@property(strong,nonatomic)NSMutableSet *cacheSubViewSet;

@property(strong,nonatomic)NSMutableArray *loadedIndexArr;
@property(assign,nonatomic,getter=isCleaning)BOOL clean;
@end
@implementation HCYPhotoBrowser
static CGFloat   HCYPhotoBrowserScrollViewOffset=8;
static NSInteger HCYPhotoBrowserCleanCount=5;
static NSInteger HCYPhotoBrowserTagMin=10000;


-(void)viewDidLoad{
    [super viewDidLoad];
    [self setupData];
    if ([_browserDelegate respondsToSelector:@selector(browserDidLoad:)]) {
        [_browserDelegate browserDidLoad:self];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([_browserDelegate respondsToSelector:@selector(browserWillAppear:)]) {
        [_browserDelegate browserWillAppear:self];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([_browserDelegate respondsToSelector:@selector(browserWillDisappear:)]) {
        [_browserDelegate browserWillDisappear:self];
    }
}
-(void)setupData{
    self.view.backgroundColor=[UIColor clearColor];
    _scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(-HCYPhotoBrowserScrollViewOffset, 0, HCYPHOTOBROWSERSCREENWIDTH+HCYPhotoBrowserScrollViewOffset*2, HCYPHOTOBROWSERSCREENHEIGHT)];
    _scrollView.backgroundColor=[UIColor blackColor];
    _scrollView.pagingEnabled=YES;
    _scrollView.showsVerticalScrollIndicator=NO;
    _scrollView.showsHorizontalScrollIndicator=NO;
    _scrollView.alwaysBounceVertical=YES;
    _scrollView.directionalLockEnabled=YES;
    
    NSUInteger dataCount=[self dataCount];
    if (dataCount) {
        HCYPhoto *photo=[self dataWithIndex:_currentIndex];
        
        HCYScrollView *subScrollView=[HCYScrollView new];
        [subScrollView refreshWithPhoto:photo];
        subScrollView.tag=_currentIndex+HCYPhotoBrowserTagMin;
        subScrollView.hcyDelegate=self;
        subScrollView.frame=[self subContentRectWithIndex:_currentIndex offset:0];
        
        [_scrollView addSubview:subScrollView];
        [self.view addSubview:_scrollView];
        _scrollView.contentSize=CGSizeMake((HCYPHOTOBROWSERSCREENWIDTH+HCYPhotoBrowserScrollViewOffset*2)*dataCount, HCYPHOTOBROWSERSCREENHEIGHT);
        _scrollView.contentOffset=CGPointMake([self subContentWidth]*_currentIndex, 0);
        
        [self.loadedIndexArr addObject:@(_currentIndex)];
        _scrollView.delegate=self;
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:( void *)contextInfo{
}

-(HCYPhoto *)dataWithIndex:(NSUInteger)index{
    if (_browserDataSource) {
        HCYPhoto *photo=[_browserDataSource photoWithIndex:index];
        return photo;
     }
    return nil;
}
-(NSUInteger)dataCount{
    if (_browserDataSource) {
        return [_browserDataSource numberOfPhotosInBrowser:self];
    }
    return 0;
}
-(void)hcyScrollViewTaped:(HCYScrollView *)scrollView{
    if (scrollView.tag>HCYPhotoBrowserTagMin) {
       self.currentIndex=scrollView.tag-HCYPhotoBrowserTagMin;
    }
    if ([self.browserDelegate respondsToSelector:@selector(browser:TapPhoto:)]) {
        [self.browserDelegate browser:self TapPhoto:[self currentPhoto]];
    }
}
-(void)hcyScrollViewLongPressed:(HCYScrollView *)scrollView{
    if (scrollView.tag>HCYPhotoBrowserTagMin) {
        self.currentIndex=scrollView.tag-HCYPhotoBrowserTagMin;
    }
    if ([self.browserDelegate respondsToSelector:@selector(browser:LongPressedPhoto:)]) {
        [self.browserDelegate browser:self LongPressedPhoto:[self currentPhoto]];
    }
}
-(HCYPhoto *)currentPhoto{
    return [self dataWithIndex:_currentIndex];
}
#pragma mark scrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat width = [self subContentWidth];
    CGFloat offsetX = scrollView.contentOffset.x;

    CGFloat fIndex=offsetX/width;
    NSInteger intIndex=roundf(offsetX/width);
    if (fIndex>intIndex && _currentIndex!=intIndex){
        self.currentIndex=intIndex;
    }
    if (fIndex==intIndex) {
        self.currentIndex=intIndex;
        return;
    }
    NSInteger willShowIndex;
    if (fIndex>_currentIndex) {
        willShowIndex=_currentIndex+1;
    }else{
        willShowIndex=_currentIndex-1;
    }
    if (willShowIndex >= 0 && willShowIndex< [self dataCount])
    {
        if (_currentIndex == willShowIndex) {
            return;
        }
        [self loadViewForIndex:willShowIndex];
    }
}
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    CGPoint p=*targetContentOffset;
    NSInteger index=p.x/[self subContentWidth];
    if ([_browserDelegate respondsToSelector:@selector(browser:showPhotoAtIndex:)]) {
        [_browserDelegate browser:self showPhotoAtIndex:index];
    }
    
}
#pragma mark view处理
-(HCYScrollView *)dequeScrollView{
    if ([self.cacheSubViewSet count] && !_clean) {
        HCYScrollView *view= [_cacheSubViewSet anyObject];
        [_cacheSubViewSet removeObject:view];
        return view;
    }
    HCYScrollView *scrollView=[HCYScrollView new];
    scrollView.hcyDelegate=self;
    return scrollView;
    
}
-(void)loadViewForIndex:(NSInteger)index{
    if ([self.loadedIndexArr containsObject:@(index)]) {
        return;
    }
    [self.loadedIndexArr addObject:@(index)];
  
    HCYScrollView *addedScrollView=[self dequeScrollView];
    addedScrollView.tag=index+HCYPhotoBrowserTagMin;
    HCYPhoto *photo=[self dataWithIndex:index];
    [addedScrollView refreshWithPhoto:photo];
    addedScrollView.frame=[self subContentRectWithIndex:index offset:0];
    [_scrollView addSubview:addedScrollView];
    NSLog(@"正式loadEnd");
    [self clean];
}
-(void)clean{
    if (self.loadedIndexArr.count<=HCYPhotoBrowserCleanCount) {
        return;
    }
    _clean=YES;
    NSLog(@"clean start");
    for (int i=0; i<self.loadedIndexArr.count; i++) {
        NSNumber *loadedNumber=self.loadedIndexArr[i];
        NSInteger number=[loadedNumber integerValue];
        if (labs(number-_currentIndex)>=5) {
            HCYScrollView *subScrollView=[_scrollView viewWithTag:number+HCYPhotoBrowserTagMin];
            if (subScrollView) {
                NSLog(@"移除view:%@",loadedNumber);
                [self.cacheSubViewSet addObject:subScrollView];
                [self.loadedIndexArr removeObject:loadedNumber];
                [subScrollView removeFromSuperview];
                i=-1;
            }
        }
    }
    NSLog(@"clean -end");
    _clean=NO;
}
#pragma mark 常用方法
-(CGRect)subContentRectWithIndex:(NSInteger)index offset:(CGFloat)offset{
    return CGRectMake(HCYPhotoBrowserScrollViewOffset+(HCYPHOTOBROWSERSCREENWIDTH+HCYPhotoBrowserScrollViewOffset*2)*index+offset, 0, HCYPHOTOBROWSERSCREENWIDTH, HCYPHOTOBROWSERSCREENHEIGHT);
}
-(NSInteger)index{
    CGFloat x=self.scrollView.contentOffset.x;
    NSInteger index=x/[UIScreen mainScreen].bounds.size.width;
    return index;
}
-(UIView *)currentView{
    UIViewController *vc=[[[UIApplication sharedApplication] keyWindow] rootViewController];
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navi=(UINavigationController *)vc;
        return navi.viewControllers[0].view;
    }else{
        return vc.view;
    }
}
-(CGFloat)subContentWidth{
    return HCYPHOTOBROWSERSCREENWIDTH+HCYPhotoBrowserScrollViewOffset*2;
}

#pragma mark public Events
-(void)show{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.scrollView.alpha=0;
    self.pageControl.alpha=0;
    UIViewController *rootVC=window.rootViewController;
    [rootVC addChildViewController:self];
    [rootVC.view addSubview:self.view];
    [rootVC.view bringSubviewToFront:self.view];
    
    
    [self showAnimation];
}
-(void)hide{
    [self hideAnimation];
}

#pragma mark animation
-(void)showAnimation{
    HCYPhoto *photo=[self dataWithIndex:_currentIndex];
    self.view.backgroundColor=[UIColor blackColor];
    UIImageView *sourceImageView=photo.sourceImageView;
    if(sourceImageView){
        CGRect targetRect=[HCYPhotoBrowserUtil hcyPhotoNewRectForImage:sourceImageView.image maxScale:nil contentSize:nil autoResize:NO];
        
        self.scrollView.alpha=0;
        self.pageControl.alpha=0;
        UIView *currentView=[self currentView];
        CGRect sourceRect=[sourceImageView convertRect:sourceImageView.bounds toView:currentView];
        UIImageView *animateImageView=[[UIImageView alloc] initWithImage:sourceImageView.image];
        animateImageView.contentMode=UIViewContentModeScaleAspectFit;
        animateImageView.frame=sourceRect;
        [self.view addSubview:animateImageView];
        [UIView animateWithDuration:0.25 animations:^{
            animateImageView.frame=targetRect;
        } completion:^(BOOL finished) {
            [animateImageView removeFromSuperview];
            self.scrollView.alpha=1;
            self.pageControl.alpha=1;
        }];
    }else{
        
    }
  
}

-(void)hideAnimation{

    HCYPhoto *photo=[self dataWithIndex:_currentIndex];
    UIImageView *sourceImageView=photo.sourceImageView;
    if (sourceImageView) {
        CGRect sourceRect=[HCYPhotoBrowserUtil hcyPhotoNewRectForImage:sourceImageView.image maxScale:nil contentSize:nil autoResize:NO];
        HCYScrollView *scrollView=[_scrollView viewWithTag:HCYPhotoBrowserTagMin+_currentIndex];
        UIImageView *animateImageView=scrollView.imageView;
        animateImageView.contentMode=sourceImageView.contentMode;
        [self.view addSubview:animateImageView];
        animateImageView.frame=sourceRect;
        [self.scrollView removeFromSuperview];
        [self.pageControl removeFromSuperview];
        [sourceImageView convertRect:sourceImageView.bounds toView:self.view];
        UIView *currentView=[self currentView];
        CGRect targetRect=[sourceImageView convertRect:sourceImageView.bounds toView:currentView];
        [UIView animateWithDuration:0.25 animations:^{
            animateImageView.frame=targetRect;
            self.view.alpha=0;
        } completion:^(BOOL finished) {
            [self removeFromParentViewController];
            [self.view removeFromSuperview];
        }];
    }else{
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
    }
  }
-(void)dealloc{
    NSLog(@"browserDealloc");
}
#pragma mark vars
-(void)setCurrentIndex:(NSInteger)currentIndex{
    if (_currentIndex==currentIndex) {
        return;
    }
    HCYScrollView *scrollView=[_scrollView viewWithTag:HCYPhotoBrowserTagMin+_currentIndex];
    if (scrollView) {
        [scrollView willHide];
    }
    _currentIndex=currentIndex;
    
}
-(NSMutableSet *)cacheSubViewSet{
    if (!_cacheSubViewSet) {
        _cacheSubViewSet=[NSMutableSet set];
    }
    return _cacheSubViewSet;
}
-(NSMutableArray *)loadedIndexArr{
    if (!_loadedIndexArr) {
        _loadedIndexArr=[NSMutableArray array];
    }
    return _loadedIndexArr;
}

@end

