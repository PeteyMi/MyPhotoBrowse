//
//  MyPhotoBrowse.m
//  MyLibrary
//
//  Created by Petey on 5/16/14.
//  Copyright (c) 2014 Petey. All rights reserved.
//

#import "MyPhotoBrowser.h"
#import "MyPhotoPageView.h"

#define PADDING                  10

@interface MyPhotoBrowser ()<UIScrollViewDelegate>
{
    NSInteger _numberOfPages;
    NSMutableArray*   _numberOfGroup;
    
    UIScrollView*   _scrollView;
    
    NSInteger   _pageIndex;
    
    NSMutableSet*   _visiblePages;
    NSMutableSet*   _recycledPages;
    
    BOOL  _reloadDataIfNeeded;
}

@end

@implementation MyPhotoBrowser
@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        
        //Setup paging scrolling view
        CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
        _scrollView = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
        _scrollView.pagingEnabled = YES;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.contentSize = CGSizeZero;
        [self addSubview:_scrollView];
        
        _visiblePages = [[NSMutableSet alloc] init];
        _recycledPages = [[NSMutableSet alloc] init];
        _reloadDataIfNeeded = YES;
        
        self.backgroundColor = [UIColor blackColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationSingleTap:) name:notficationPhotoPageViewSingleTap object:nil];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:notficationPhotoPageViewSingleTap];
}

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    _scrollView.backgroundColor = backgroundColor;
}

-(id<MyPhotoBrowserDelegate>)delegate
{
    return (id<MyPhotoBrowserDelegate>)_scrollView.delegate;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    if ([self reloadDataIfNeeded]) {
        [self performSelector:@selector(reloadData)];
        _reloadDataIfNeeded = NO;
    }
}


-(void)moveToPageAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    NSInteger index = [self indexPathToIndex:indexPath];
    NSAssert(index < _numberOfPages && index >= 0, @"Page index passed out of bounds");
    _pageIndex = index;
    
    [self enqueuePageViewAtIndex:index];
    
    [self loadScrollViewWithPage:[self indexToIndexPath:index - 1]];
    [self loadScrollViewWithPage:[self indexToIndexPath:index]];
    [self loadScrollViewWithPage:[self indexToIndexPath:index + 1]];
    
    CGRect visibleFrame = [self frameForPageAtIndex:index];
    [_scrollView scrollRectToVisible:visibleFrame animated:animated];
    
    if (index + 1 < _numberOfPages) {
        MyPhotoPageView* page = [self findPageViewByIndex:index + 1];
        [page setMaxMinZoomScalesForCurrentBounds];
    }
    
    if (index - 1 >= 0) {
        MyPhotoPageView* page = [self findPageViewByIndex:index - 1];
        [page setMaxMinZoomScalesForCurrentBounds];
    }
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(photoBrowser:didDisplayPhotoAtIndexPath:)]) {
        [_delegate photoBrowser:self didDisplayPhotoAtIndexPath:indexPath];
    }    
}
-(void)reloadData
{
    for (MyPhotoPageView* item in _visiblePages) {
        [item removeFromSuperview];
    }
    [_visiblePages removeAllObjects];
    [_recycledPages removeAllObjects];
    
    while (_scrollView.subviews.count) {
        [[_scrollView.subviews lastObject] removeFromSuperview];
    }
    
    _numberOfGroup = [[NSMutableArray alloc] init];
    _numberOfPages = 0;
    _pageIndex = 0;
    NSInteger groupCount = 1;
    
    if (_dataSource != nil) {
        if ([_dataSource respondsToSelector:@selector(numberOfGroupInPhotoBrowser:)]) {
            groupCount = [_dataSource numberOfGroupInPhotoBrowser:self];
        }
        for (NSInteger index = 0; index < groupCount; index++) {
            NSInteger numberOfGroup = [_dataSource photoBrowse:self numberOfPagesInGroup:index];
            [_numberOfGroup addObject:[NSIndexPath indexPathForRow:numberOfGroup inSection:index]];
             _numberOfPages += numberOfGroup;
        }
    }
    
    //Upate current page index    
    _scrollView.contentSize = [self contentSizeForPagingeScrollView];
    
    if (_numberOfPages > 0) {
        [self moveToPageAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO];
    }    
}
- (void)deletePageAtIndexPath:(NSIndexPath *)indexPath
{
    [self reloadData];
    
    NSInteger index = [self indexPathToIndex:indexPath];
    if (index >= _numberOfPages) {
        index = _numberOfPages - 1;
    }
    NSIndexPath* tmpIndexPath = [self indexToIndexPath:index];
    if (tmpIndexPath != nil) {
        [self moveToPageAtIndexPath:tmpIndexPath animated:NO];
    } else {
        
    }
}

-(MyPhotoPageView*)dequeueReusablePages
{
    MyPhotoPageView* page = [_recycledPages anyObject];
    if (page) {
        [_recycledPages removeObject:page];
    }
    return page;
}
-(void)enqueuePageViewAtIndex:(NSInteger)index{
    for (MyPhotoPageView* page in _visiblePages) {
        if (page.index < index - 1 || page.index > index + 1) {
            [_recycledPages addObject:page];
            [page removeFromSuperview];
        }
    }
    
    [_visiblePages minusSet:_recycledPages];
    while (_recycledPages.count > 2) {  // Only keep 2 recycled pages
        [_recycledPages removeObject:[_recycledPages anyObject]];
    }
}
-(BOOL)isDisplayingPageForIndex:(NSInteger)index
{
    for (MyPhotoPageView* page in _visiblePages) {
        if (page.index == index) {
            return YES;
        }
    }
    return NO;
}

-(MyPhotoPageView*)findPageViewByIndex:(NSInteger)index
{
    for (MyPhotoPageView* view in _visiblePages) {
        if (view.index == index) {
            return view;
        }
    }
    return nil;
}

-(void)loadScrollViewWithPage:(NSIndexPath*) indexPath
{
    if (indexPath == nil) {
        return;
    }
    NSInteger index = [self indexPathToIndex:indexPath];
    if (index < 0 || index >= _numberOfPages ) {
        return;
    }
    
    MyPhotoPageView* page = [self findPageViewByIndex:index];
    
    if (page == nil) {
        if (_dataSource) {
            page = [_dataSource photoBrowser:self photoAtIndexPath:indexPath];
        }
        [_visiblePages addObject:page];
    }
    
    [self configurePage:page forIndex:index];
    
    if (page.superview == nil) {
        [_scrollView addSubview:page];
    }
}
-(void)layoutScrooViewSubView{
    NSIndexPath* indexPath = [self currentPageIndexPath];
    
    NSInteger index = [self indexPathToIndex:indexPath];
    [self enqueuePageViewAtIndex:index];
    
    for (NSInteger page = index - 1; page < index + 2; page++) {
        if (page >= 0 && page < _numberOfPages) {
            if (![self isDisplayingPageForIndex:page]) {
                [self loadScrollViewWithPage:[self indexToIndexPath:page]];
            }
        }
    }
}
-(BOOL)reloadDataIfNeeded
{
    return _reloadDataIfNeeded;
}
-(void)notificationSingleTap:(NSNotification*)notification
{
    NSIndexPath* indexPath = [self indexToIndexPath:_pageIndex];
    if (_delegate != nil && [_delegate respondsToSelector:@selector(photoBrowser:singleTapAtIndexpath:)]) {
        [_delegate photoBrowser:self singleTapAtIndexpath:indexPath];
    }
    
}
#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger index = [self centerPageIndex];
    if (index < 0 || index >= _numberOfPages ) {
        return;
    }
    
    if (_pageIndex != index) {
        _pageIndex = index;
        
        if (![scrollView isTracking]) {
            [self layoutScrooViewSubView];
        }
    }
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = [self centerPageIndex];
    if (index >= _numberOfPages || index < 0) {
        return;
    }
    NSIndexPath* indexPath = [self indexToIndexPath:index];
    [self moveToPageAtIndexPath:indexPath animated:NO];
}

#pragma mark - Frame Calculations

-(NSIndexPath*)indexToIndexPath:(NSInteger)anIndex
{
    NSInteger sum = 0;
    for (NSInteger index = 0; index < _numberOfGroup.count; index++) {
        NSIndexPath* indexPath = [_numberOfGroup objectAtIndex:index];
        if (sum <= anIndex && anIndex < sum + indexPath.row) {
            return [NSIndexPath indexPathForRow:anIndex - sum inSection:indexPath.section];
        }
        sum += indexPath.row;
    }
    return nil;
}
-(NSInteger)indexPathToIndex:(NSIndexPath*)indexPath
{
    NSInteger result = 0;
    for (NSInteger index = 0; index < indexPath.section; index++) {
        NSIndexPath* tmpIndex = [_numberOfGroup objectAtIndex:index];
        result += tmpIndex.row;
    }
    result += indexPath.row;
    return result;
}
-(CGSize)contentSizeForPagingeScrollView
{
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = _scrollView.bounds;
    return CGSizeMake(bounds.size.width * _numberOfPages, bounds.size.width);
}

- (CGRect)frameForPagingScrollView {
    CGRect frame = self.bounds;// [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return CGRectIntegral(frame);
}

-(NSInteger)centerPageIndex{
    CGFloat pageWidth = _scrollView.bounds.size.width;
    return floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

-(NSIndexPath*)currentPageIndexPath
{
    return [self indexToIndexPath:_pageIndex];
}
-(CGRect)frameForPageAtIndex:(NSUInteger)index{
    CGRect bounds = _scrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return CGRectIntegral(pageFrame);
}

-(void)configurePage:(MyPhotoPageView*)page forIndex:(NSUInteger)index
{
    page.frame = [self frameForPageAtIndex:index];
    page.index = index;
}

@end


             
             
