//
//  MyPhotoPage.h
//  MyLibrary
//
//  Created by Petey on 5/18/14.
//  Copyright (c) 2014 Petey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyPhotoPageView : UIScrollView

@property(nonatomic, assign) NSInteger index;
@property(nonatomic, retain) UIImageView* imageView;

- (void)setMaxMinZoomScalesForCurrentBounds;
@end

UIKIT_EXTERN  NSString* const notficationPhotoPageViewSingleTap;