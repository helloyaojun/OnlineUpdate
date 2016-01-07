//
//  DetailViewController.h
//  OnlineUpdate
//
//  Created by 姚君 on 16/1/7.
//  Copyright © 2016年 coco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

