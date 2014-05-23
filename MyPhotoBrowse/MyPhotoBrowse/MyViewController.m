//
//  MyViewController.m
//  MyLibrary
//
//  Created by Petey on 5/16/14.
//  Copyright (c) 2014 Petey. All rights reserved.
//

#import "MyViewController.h"
#import "MyPhotoBrowser.h"
#import "MyPhotoPageView.h"

@interface MyViewController ()<MyPhotoBrowserDataSource>
{
    NSMutableArray* _dataSource;
}
@end

@implementation MyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    MyPhotoBrowser*    tableView = [[MyPhotoBrowser alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:tableView];
    tableView.dataSource = self;
    
    _dataSource = [[NSMutableArray alloc] init];
    UIImageView* imageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo1.jpg"]];
    UIImageView* imageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo2.jpg"]];
    UIImageView* imageView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo3.jpg"]];
    UIImageView* imageView4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo4.jpg"]];
    UIImageView* imageView5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo5.jpg"]];
    UIImageView* imageView6 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo6.jpg"]];
    UIImageView* imageView7 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo7.jpg"]];
    UIImageView* imageView8 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo8.jpg"]];
    
    [_dataSource addObjectsFromArray:@[@[imageView1,imageView2],@[imageView3,imageView4,imageView5],@[imageView6],@[imageView7,imageView8]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)photoBrowse:(MyPhotoBrowser*)photoBrowsef numberOfPagesInGroup:(NSInteger)group
{
    NSArray* array = [_dataSource objectAtIndex:group];
    return array.count;
}
- (MyPhotoPageView*)photoBrowser:(MyPhotoBrowser *)photoBrowser photoAtIndexPath:(NSIndexPath*)indexPath
{
    MyPhotoPageView* page = [photoBrowser dequeueReusablePages];
    if (page == nil) {
        page = [[MyPhotoPageView alloc] init];
    }
    
    NSArray* array = [_dataSource objectAtIndex:indexPath.section];
    UIImageView* imageView = [array objectAtIndex:indexPath.row];
    page.imageView.image = imageView.image;
    
    return page;
}

- (NSInteger)numberOfGroupInPhotoBrowser:(MyPhotoBrowser *)photoBrowser
{
    return _dataSource.count;
}


@end
