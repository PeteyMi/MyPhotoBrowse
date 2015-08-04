//
//  MyShow2ViewController.m
//  MyPhotoBrowse
//
//  Created by Petey Mi on 8/4/15.
//  Copyright © 2015 Petey. All rights reserved.
//

#import "MyShow2ViewController.h"

@interface MyShow2ViewController ()
{
    UIView* middleView;
    UINavigationBar* bar;
}
@end

@implementation MyShow2ViewController

-(void)loadView
{
    [super loadView];
    middleView = [[UIView alloc] initWithFrame:self.view.bounds];
    middleView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:middleView];
    self.view.backgroundColor = [UIColor clearColor];

    bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, middleView.bounds.size.width, 64)];
    [middleView addSubview:bar];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(back:)];
    
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tap];
    UIPinchGestureRecognizer* pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    [self.view addGestureRecognizer:pinch];
    UINavigationItem* item = [[UINavigationItem alloc] init];
    [bar pushNavigationItem:item animated:NO];
    item = [[UINavigationItem alloc] init];
    [bar pushNavigationItem:item animated:NO];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view addSubview:self.imageView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)tap:(UIGestureRecognizer*)tap
{
    self.navigationController.view.opaque = YES;
    self.view.opaque = YES;
    [UIView beginAnimations:nil context:NULL];
    self.view.alpha = 0;
    _imageView.frame = self.rect;
    [UIView commitAnimations];
}
-(void)back:(id)sender
{
    
}
-(void)pinch:(UIPinchGestureRecognizer*)pinch
{
    middleView.alpha = pinch.scale;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
