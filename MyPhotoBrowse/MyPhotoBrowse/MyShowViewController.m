//
//  MyShowViewController.m
//  MyPhotoBrowse
//
//  Created by Petey Mi on 8/4/15.
//  Copyright © 2015 Petey. All rights reserved.
//

#import "MyShowViewController.h"
#import "MyShow2ViewController.h"

@interface MyShowViewController ()
{
    MyShow2ViewController* controller;
    UINavigationController* nvc;
}
@end

@implementation MyShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    UIPinchGestureRecognizer* pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    [_imageView addGestureRecognizer:tap];
    [_imageView addGestureRecognizer:pinch];
    _imageView.userInteractionEnabled = YES;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Test" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)tapGesture:(id)sender
{
    controller = [[MyShow2ViewController alloc] init];
    controller.rect = _imageView.frame;
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage:_imageView.image];
    imageView.frame = _imageView.frame;
    
    CGSize boundSize = self.view.bounds.size;
    CGFloat boundWidth = boundSize.width;
    CGFloat boundHeight = boundSize.height;
    CGSize imageSize = _imageView.image.size;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
    
    CGRect imageFrame = CGRectMake(0, 0, boundWidth, boundWidth * imageHeight / imageWidth);
    if (imageFrame.size.height < boundHeight) {
        imageFrame.origin.y = floorf((boundHeight - imageFrame.size.height) / 2.0);
    } else {
        imageFrame.origin.y = 0;
    }
    
//    _imageView.hidden = YES;
    controller.imageView = imageView;
    
    [self.view addSubview:imageView];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(show)];
    imageView.frame = imageFrame;
    [UIView commitAnimations];
//    UINavigationItem* item = [[UINavigationItem alloc] initWithTitle:@"test"];
//    item.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"aa" style:UIBarButtonItemStylePlain target:nil action:nil];
//    [self.navigationController.navigationBar pushNavigationItem:item animated:YES];
    
}
-(void)show
{
//    nvc = [[UINavigationController alloc] initWithRootViewController:controller];
//    [[UIApplication sharedApplication].keyWindow addSubview:nvc.view];
//    [self.view addSubview:controller.view];
    [[UIApplication sharedApplication].keyWindow addSubview:controller.view];
}
-(void)pinchGesture:(UIPinchGestureRecognizer*)sender
{
//    NSLog(@"%f", sender.scale);
//    self.navigationController.navigationBar.backItem.titleView.alpha = sender.scale;
}

@end
