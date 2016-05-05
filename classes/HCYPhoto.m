//
//  HCYPhoto.m
//  FriendCircle
//
//  Created by hcy on 15/12/14.
//  Copyright © 2015年 hcy. All rights reserved.
//

#import "HCYPhoto.h"
 NSString *PhotoIdentifierKey=@"PhotoIdentifierKey";
@implementation HCYPhoto

-(void)localImageWithCompletion:(HCYPhotoImageRefreshBlock)completion{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *sourceImage=self.sourceBlock();
            if (completion) {
                if(self.autoResize){
                }
                completion(sourceImage,@{PhotoIdentifierKey:_photoIdentifier});
            }
        });
}
@end
