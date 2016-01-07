//
//  DownLoadViewController.m
//  test2
//
//  Created by 姚君 on 16/1/7.
//  Copyright © 2016年 coco. All rights reserved.
//

#import "DownLoadViewController.h"
#import <dlfcn.h>
#import <ZipArchive/ZipArchive.h>

#define downloadurl @"https://codeload.github.com/helloyaojun/SelectPhoto.framework/zip/master"

@interface DownLoadViewController () {

    NSURLSessionDownloadTask *task;
    NSData *data;
    NSURLSession *session;
    NSURLRequest *request;
    UIProgressView *pro;
    UIImageView *imageView;

}

@end

@implementation DownLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 120, 300, 300)];
    imageView.center = self.view.center;
    [self.view addSubview:imageView];
    
    pro = [[UIProgressView alloc]initWithFrame:CGRectMake(CGRectGetMinX(imageView.frame), 100, 300, 40)];
    [self.view addSubview:pro];

    
    UIButton * startbutton=[[UIButton alloc] initWithFrame:CGRectMake(50, 300+20, 50, 40)];
    startbutton.backgroundColor=[UIColor orangeColor];
    [startbutton setTitle:@"开始" forState:UIControlStateNormal];
    [startbutton addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    startbutton.layer.borderWidth=1;
    startbutton.layer.borderColor=[UIColor orangeColor].CGColor;
    startbutton.layer.cornerRadius=5;
    [self.view addSubview:startbutton];
    
    UIButton * pausebutton=[[UIButton alloc] initWithFrame:CGRectMake(150, 300+20, 50, 40)];
    pausebutton.backgroundColor=[UIColor orangeColor];
    [pausebutton setTitle:@"暂停" forState:UIControlStateNormal];
    [pausebutton addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    pausebutton.layer.borderWidth=1;
    pausebutton.layer.borderColor=[UIColor orangeColor].CGColor;
    pausebutton.layer.cornerRadius=5;
    [self.view addSubview:pausebutton];
    
    UIButton * resumebutton=[[UIButton alloc] initWithFrame:CGRectMake(250, 300+20, 50, 40)];
    resumebutton.backgroundColor=[UIColor orangeColor];
    [resumebutton setTitle:@"恢复" forState:UIControlStateNormal];
    [resumebutton addTarget:self action:@selector(resume) forControlEvents:UIControlEventTouchUpInside];
    resumebutton.layer.borderWidth=1;
    resumebutton.layer.borderColor=[UIColor orangeColor].CGColor;
    resumebutton.layer.cornerRadius=5;
    [self.view addSubview:resumebutton];

//    UIButton * pushbutton=[[UIButton alloc] initWithFrame:CGRectMake(50, 300+100, 250, 40)];
//    pushbutton.backgroundColor=[UIColor orangeColor];
//    [pushbutton setTitle:@"解压跳转到压缩包的内容" forState:UIControlStateNormal];
//    [pushbutton addTarget:self action:@selector(unZipArchive) forControlEvents:UIControlEventTouchUpInside];
//    pushbutton.layer.borderWidth=1;
//    pushbutton.layer.borderColor=[UIColor orangeColor].CGColor;
//    pushbutton.layer.cornerRadius=5;
//    [self.view addSubview:pushbutton];

}

#pragma mark - download

- (void)start {

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    session = [NSURLSession sessionWithConfiguration:config delegate:(id<NSURLSessionDelegate>)self delegateQueue:nil];
    NSURL *url = [NSURL URLWithString:downloadurl];
    request = [NSURLRequest requestWithURL:url];
    task = [session downloadTaskWithRequest:request];
    NSLog(@"开始下载");
    pro.progress = 0.0f;
    [task resume];
    
}

- (void)pause {
    NSLog(@"暂停下载");
    [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        data = resumeData;
    }];
    task = nil;
}

- (void)resume {
    NSLog(@"暂停下载");
    if (!data) {
        NSURL *url = [NSURL URLWithString:downloadurl];
        request = [NSURLRequest requestWithURL:url];
        task = [session downloadTaskWithRequest:request];
    }else {
        task = [session downloadTaskWithResumeData:data];
    }

}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {

    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Documents/SelectPhoto.framework.zip",NSHomeDirectory()]];
    NSFileManager *manger = [NSFileManager defaultManager];
    [manger moveItemAtURL:location toURL:url error:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self unZipArchive];
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {

    CGFloat progress = (totalBytesWritten*1.0)/totalBytesExpectedToWrite;
    dispatch_async(dispatch_get_main_queue(), ^{
        pro.progress = progress;
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - unzip

- (void)unZipArchive {
    
    ZipArchive *zArchive = [[ZipArchive alloc]init];
    
    NSString *zipPath = [NSString stringWithFormat:@"%@/Documents/SelectPhoto.framework.zip",NSHomeDirectory()];
    NSString *unZipPath = [NSString stringWithFormat:@"%@/Documents/SelectPhoto",NSHomeDirectory()];
    
    if ([zArchive UnzipOpenFile:zipPath]) {
        
        BOOL result = [zArchive UnzipFileTo:unZipPath overWrite:YES];
        
        if (result) {
            
            NSLog(@"unZip success!");
            [self handleFrameWork:[NSString stringWithFormat:@"%@/SelectPhoto.framework-master/SelectPhoto.framework",unZipPath]];
            
        }else {
            NSLog(@"unZip faile!");
        }
        [zArchive UnzipCloseFile];
    }
}

#pragma mark - readFW

- (void)handleFrameWork:(NSString *)path {
    
    void *libHandel = NULL;
    NSString *path1 =[path stringByAppendingPathComponent:@"SelectPhoto"];
    NSLog(@"path1--%@!",path1);
    
    libHandel = dlopen([[path stringByAppendingPathComponent:@"SelectPhoto/"] cStringUsingEncoding:NSUTF8StringEncoding], RTLD_NOW);
    
    if (libHandel == NULL) {
        NSLog(@"FrameWork UNopen!");
        return;
    }
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    if (![bundle load]) {
        NSLog(@"NSBundle UNload!");
        return;
    }
    Class SelectPhotoVC = [bundle classNamed:@"SelectPhotoViewController"];
    if (!SelectPhotoVC) {
        NSLog(@"SelectPhotoVC notfound!");
    }
    dlclose(libHandel);
    
    UIViewController *obj = [[SelectPhotoVC alloc]init];
    [self.navigationController pushViewController:obj animated:YES];
    
    
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
