//
//  MyPhotoPage.m
//  MyLibrary
//
//  Created by Petey on 5/18/14.
//  Copyright (c) 2014 Petey. All rights reserved.
//

#import "MyPhotoPageView.h"

#define MYPHOTO_ZOOM_SCALE 2.5


NSString* const notficationPhotoPageViewSingleTap = @"notficationPhotoPageViewSingleTap";

@interface MyPhotoPageView ()<UIScrollViewDelegate>

@end

@implementation MyPhotoPageView
@synthesize index;
@synthesize imageView = _imageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Setup
		self.backgroundColor = [UIColor clearColor];
		self.delegate = self;
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
		self.decelerationRate = UIScrollViewDecelerationRateFast;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    }
    return self;
}
-(void)dealloc
{
    [self removeObserver:self forKeyPath:@"frame"];
    if (_imageView) {
        [_imageView removeObserver:self forKeyPath:@"image"];
    }
}


-(UIImageView*)imageView
{
    if (_imageView == nil) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.opaque = YES;
        _imageView.contentMode = UIViewContentModeCenter;
    }
    return _imageView;
}
-(void)setImageView:(UIImageView *)imageView
{
    [_imageView removeObserver:self forKeyPath:@"image"];
    [_imageView removeFromSuperview];
    _imageView = imageView;
    if (_imageView != nil) {
        [imageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:NULL];
        [self addSubview:_imageView];
    }
}

-(void)displayImage
{
    self.maximumZoomScale = 1.0f;
    self.minimumZoomScale = 1.0f;
    self.zoomScale = 1.0f;
    self.contentSize = CGSizeZero;
    
    if (_imageView.image != nil) {
        // Reset        
        // Setup photo frame
        CGRect imageViewFrame;
        imageViewFrame.origin = CGPointZero;
        imageViewFrame.size = _imageView.image.size;
        _imageView.frame = imageViewFrame;
        self.contentSize = imageViewFrame.size;
        
        [self setMaxMinZoomScalesForCurrentBounds];
    }
    
    [self setNeedsLayout];
}
- (CGFloat)initialZoomScaleWithMinScale {
    CGFloat zoomScale = self.minimumZoomScale;
    if (_imageView ) {
        // Zoom image to fill if the aspect ratios are fairly similar
        CGSize boundsSize = self.bounds.size;
        CGSize imageSize = _imageView.image.size;
        CGFloat boundsAR = boundsSize.width / boundsSize.height;
        CGFloat imageAR = imageSize.width / imageSize.height;
        CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
        CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
        // Zooms standard portrait images on a 3.5in screen but not on a 4in screen.
        if (ABS(boundsAR - imageAR) < 0.17) {
            zoomScale = MAX(xScale, yScale);
            // Ensure we don't zoom in or out too far, just in case
            zoomScale = MIN(MAX(self.minimumZoomScale, zoomScale), self.maximumZoomScale);
        }
    }
    return zoomScale;
}
- (void)setMaxMinZoomScalesForCurrentBounds {
	
	// Reset
	self.maximumZoomScale = 1;
	self.minimumZoomScale = 1;
	self.zoomScale = 1;
	
	// Bail if no image
	if (_imageView.image == nil) return;
    
	// Reset position
	_imageView.frame = CGRectMake(0, 0, _imageView.frame.size.width, _imageView.frame.size.height);
	
	// Sizes
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _imageView.image.size;
    
    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    
    // Calculate Max
	CGFloat maxScale = 3;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Let them go a bit bigger on a bigger screen!
        maxScale = 4;
    }
    
    // Image is smaller than screen so no zooming!
	if (xScale >= 1 && yScale >= 1) {
		minScale = 1.0;
	}
	
	// Set min/max zoom
	self.maximumZoomScale = maxScale;
	self.minimumZoomScale = minScale;
    
    // Initial zoom
    self.zoomScale = [self initialZoomScaleWithMinScale];
    
    // If we're zooming to fill then centralise
    if (self.zoomScale != minScale) {
        // Centralise
        self.contentOffset = CGPointMake((imageSize.width * self.zoomScale - boundsSize.width) / 2.0,
                                         (imageSize.height * self.zoomScale - boundsSize.height) / 2.0);
        // Disable scrolling initially until the first pinch to fix issues with swiping on an initally zoomed in photo
        self.scrollEnabled = NO;
    }
    
    // Layout
	[self setNeedsLayout];
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _imageView.frame;
    
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    
    //Center
    if (!CGRectEqualToRect(_imageView.frame, frameToCenter)) {
        _imageView.frame = frameToCenter;
    }
}



- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
	return _imageView;
}
-(void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    self.scrollEnabled = YES;
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"image"]) {
            [self displayImage];
    } else if ([keyPath isEqualToString:@"frame"]){
        CGRect newRect = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
        CGRect oldRect = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
        if (!CGRectEqualToRect(oldRect, newRect)) {
            [self setMaxMinZoomScalesForCurrentBounds];
        }
        
    }
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    NSUInteger tapCount = touch.tapCount;
    switch (tapCount) {
        case 1:
            [self handleSingleTap:[touch locationInView:_imageView]];
            break;
        case 2:
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            break;
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    NSUInteger tapCount = touch.tapCount;
    switch (tapCount) {
        case 2:
            [self handleDoubleTap:[touch locationInView:_imageView]];
            break;
    }
}
-(void)sendSingleTapNotification:(MyPhotoPageView*)pathotPageView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notficationPhotoPageViewSingleTap object:self];
}
-(void)handleSingleTap:(CGPoint)touchPoint
{
    [self performSelector:@selector(sendSingleTapNotification:) withObject:self afterDelay:0.5];
}
-(void)handleDoubleTap:(CGPoint)touchPoint
{
    // Zoom
	if (self.zoomScale != self.minimumZoomScale && self.zoomScale != [self initialZoomScaleWithMinScale]) {
		
		// Zoom out
		[self setZoomScale:self.minimumZoomScale animated:YES];
		
	} else {
		
		// Zoom in to twice the size
        CGFloat newZoomScale = ((self.maximumZoomScale + self.minimumZoomScale) / 2);
        CGFloat xsize = self.bounds.size.width / newZoomScale;
        CGFloat ysize = self.bounds.size.height / newZoomScale;
        [self zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
        
	}
}
@end



