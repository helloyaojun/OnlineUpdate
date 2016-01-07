//
//  DetailViewController.m
//  OnlineUpdate
//
//  Created by 姚君 on 16/1/7.
//  Copyright © 2016年 coco. All rights reserved.
//

#import "DetailViewController.h"
#import "DownLoadViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"timeStamp"] description];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    UIButton * pausebutton=[[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame)-40, 80, 80, 40)];
    pausebutton.backgroundColor=[UIColor orangeColor];
    [pausebutton setTitle:@"去下载" forState:UIControlStateNormal];
    [pausebutton addTarget:self action:@selector(push:) forControlEvents:UIControlEventTouchUpInside];
    pausebutton.layer.borderWidth=1;
    pausebutton.layer.borderColor=[UIColor orangeColor].CGColor;
    pausebutton.layer.cornerRadius=5;
    [self.view addSubview:pausebutton];

}

- (void)push:(id)sender {
    
    DownLoadViewController *vc = [[DownLoadViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
