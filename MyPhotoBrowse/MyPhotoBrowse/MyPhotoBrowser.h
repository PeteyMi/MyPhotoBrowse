//
//  MyPhotoBrowse.h
//  MyLibrary
//
//  Created by Petey on 5/16/14.
//  Copyright (c) 2014 Petey. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyPhotoBrowserDataSource;
@class MyPhotoPageView;
@class MyPhotoBrowser;

@protocol MyPhotoBrowserDelegate<NSObject, UIScrollViewDelegate>

@optional
-(void)photoBrowser:(MyPhotoBrowser*)photoBrowser didDisplayPhotoAtIndexPath:(NSIndexPath*)indexPath;
-(void)photoBrowser:(MyPhotoBrowser *)photoBrowser singleTapAtIndexpath:(NSIndexPath*)indexPath;
@end


@interface MyPhotoBrowser : UIView


@property(nonatomic, assign) id<MyPhotoBrowserDataSource> dataSource;
@property(nonatomic, assign) id<MyPhotoBrowserDelegate> delegate;

-(NSIndexPath*)currentPageIndexPath;
-(void)reloadData;
-(MyPhotoPageView*)dequeueReusablePages;
-(void)moveToPageAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated;
- (void)deletePageAtIndexPath:(NSIndexPath *)indexPath;// withRowAnimation:(UITableViewRowAnimation)animation;
 
@end



@protocol MyPhotoBrowserDataSource<NSObject>

@required
-(NSInteger)photoBrowse:(MyPhotoBrowser*)photoBrowsef numberOfPagesInGroup:(NSInteger)group;
- (MyPhotoPageView*)photoBrowser:(MyPhotoBrowser *)photoBrowser photoAtIndexPath:(NSIndexPath*)indexPath;

@optional
- (NSInteger)numberOfGroupInPhotoBrowser:(MyPhotoBrowser *)photoBrowser;
@end


