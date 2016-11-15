//
//  ShowViewController.m
//  WebImageShow
//
//  Created by iZ on 13-8-30.
//  Copyright (c) 2013年 BW. All rights reserved.

// ARC 工程 
//iOS 中国开发者 QQ：262091386  欢迎加入交流
#import "ZBarSDK.h"
#import "ShowViewController.h"
#import "UIImageView+WebCache.h"

@interface ShowViewController ()<UIGestureRecognizerDelegate,ZBarReaderDelegate,ZBarReaderViewDelegate,ZBarHelpDelegate,UIWebViewDelegate>
{
    UIImageView *_img;
}

@property (nonatomic,retain) UIWebView *showWebView;

@end

@implementation ShowViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"点击查看网页中图片";
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"扫描" style:UIBarButtonItemStylePlain target:self action:@selector(touchRight:)];
        self.navigationItem.rightBarButtonItem = item;
    
        UIBarButtonItem *lefItem = [[UIBarButtonItem alloc] initWithTitle:@"识别" style:UIBarButtonItemStylePlain target:self action:@selector(touchleft:)];
        self.navigationItem.leftBarButtonItem = lefItem;
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _img=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    _img.backgroundColor=[UIColor redColor];
    [self.view addSubview:_img];
    
    _showWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 40, 320, [UIScreen mainScreen].bounds.size.height)];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://wap.quickwinner.cn/web/allyexplain?allyid=1000013"]];
    _showWebView.delegate=self;
    [_showWebView loadRequest:urlRequest];
    [self.view addSubview:_showWebView];
    
    [self addTapOnWebView];
 }
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
//        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://wap.quickwinner.cn/web/allyexplain?allyid=1000013"]];
//        [_showWebView loadRequest:urlRequest];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"viewDidDisappear");
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"shouldStartLoadWithRequest");
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://wap.quickwinner.cn/web/allyexplain?allyid=1000013"]];
//    [_showWebView loadRequest:urlRequest];
    return YES;
}
-(void)addTapOnWebView
{
//    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
//    [self.showWebView addGestureRecognizer:singleTap];
//    singleTap.delegate = self;
//    singleTap.cancelsTouchesInView = NO;
    
    
    UILongPressGestureRecognizer *longPressGR =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
    longPressGR.minimumPressDuration=0.48;
    longPressGR.delegate=self;
    [self.showWebView addGestureRecognizer:longPressGR];
    longPressGR.cancelsTouchesInView = NO;
}

#pragma mark- TapGestureRecognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    CGPoint pt = [sender locationInView:self.showWebView];
    NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", pt.x, pt.y];
    NSString *urlToSave = [self.showWebView stringByEvaluatingJavaScriptFromString:imgURL];
    NSLog(@"image url=%@", urlToSave);
    if (urlToSave.length > 0) {
//        [self showImageURL:urlToSave point:pt];
        NSString *turnString=[self decodeQRImageWith:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlToSave]]]];
//        NSString *turnString=@"https://itunes.apple.com/cn/app/zhuo-yue-hui/id1159685485?mt=8";
        NSLog(@"theturnimg---%@",turnString);
        if ([turnString hasPrefix:@"http"])
        {
            NSLog(@"是网址");

            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
            {
                NSLog(@"The \"Okay/Cancel\" alert's cancel action occured.");
            }];
            UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"保存图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
            {
                NSLog(@"The \"Okay/Cancel\" alert's other action occured.");
                UIImage *image=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlToSave]]];
                UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            }];
            UIAlertAction *otherActionTwo = [UIAlertAction actionWithTitle:@"识别图中的二维码" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
           {
                NSLog(@"识别图中的二维码");

               
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:turnString]];
           }];
            [alertController addAction:cancelAction];
            [alertController addAction:otherAction];
            [alertController addAction:otherActionTwo];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else
        {
            NSLog(@"不是网址");
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
               {
                   NSLog(@"The \"Okay/Cancel\" alert's cancel action occured.");
               }];
            UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"保存图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
              {
              
                  NSLog(@"The \"Okay/Cancel\" alert's other action occured.");
                  
                  UIImage *image=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlToSave]]];
                  UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
              }];
            
            [alertController addAction:cancelAction];
            [alertController addAction:otherAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }


    }
   
 
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    if (error)
    {
        NSLog(@"Error");
//        [SVProgressHUD showErrorWithStatus:@"保存失败"];
    }
    else
    {
        NSLog(@"OK");
//        [SVProgressHUD showSuccessWithStatus:@"成功保存"];
        
    }
    
}
//呈现图片
-(void)showImageURL:(NSString *)url point:(CGPoint)point
{
    UIImageView *showView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 470)];
    showView.center = point;
    [UIView animateWithDuration:0.5f animations:^{
        CGPoint newPoint = self.view.center;
        newPoint.y += 20;
        showView.center = newPoint;
    }];
    
    showView.backgroundColor = [UIColor blackColor];
    showView.alpha = 0.9;
    showView.userInteractionEnabled = YES;      
    [self.view addSubview:showView];
    [showView setImageWithURL:[NSURL URLWithString:url]];
    
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleViewTap:)];
    [showView addGestureRecognizer:singleTap];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}


//移除图片查看视图
-(void)handleSingleViewTap:(UITapGestureRecognizer *)sender
{    
    for (id obj in self.view.subviews) {
        if ([obj isKindOfClass:[UIImageView class]]) {
            [obj removeFromSuperview];
        }
    }
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 点击事件
-(void)touchRight:(id)sender
{
    NSLog(@"touchRight:");
    //初始化相机控制器
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    //设置代理
    reader.readerDelegate = self;
    //基本适配
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    //二维码/条形码识别设置
    ZBarImageScanner *scanner = reader.scanner;
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    //弹出系统照相机，全屏拍摄
//    [self presentModalViewController: reader animated: YES];
    [self presentViewController:reader animated:YES completion:nil];
}
#pragma mark - ZBarReaderDelegate 代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
    
    // EXAMPLE: do something useful with the barcode data
    self.title = symbol.data;
    
    // EXAMPLE: do something useful with the barcode image
    _img.image =
    [info objectForKey: UIImagePickerControllerOriginalImage];
    
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (YES);
}
#pragma mark - 识别
-(void)touchleft:(id)sender
{
    NSLog(@"touchleft");
    ZBarReaderView *readview = [ZBarReaderView new];
    //自定义大小
    readview.frame = CGRectMake(100, 100, 300, 300);
    //自定义添加相关指示.........发挥各自的APP的想象力
    //此处省略美化10000行代码...................
    //………………………..
    // 好进入正题—— 接着设置好代理
    readview.readerDelegate = self;
    //将其照相机拍摄视图添加到要显示的视图上
    [self.view addSubview:readview];
    //二维码/条形码识别设置
    ZBarImageScanner *scanner = readview.scanner;
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    //启动，必须启动后，手机摄影头拍摄的即时图像菜可以显示在readview上
    [readview start];
}
#pragma mark - ZBarReaderViewDelegate 代理方法
-(void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image
{
    ZBarSymbol *symbol =nil;
    for (symbol in symbols) {
        break;
    }
    NSString *text=symbol.data;
    NSLog(@"text---%@",text);
}

#pragma mark ------
- (NSString *)decodeQRImageWith:(UIImage*)aImage {
    NSString *qrResult = nil;
    
    //iOS8及以上可以使用系统自带的识别二维码图片接口，但此api有问题，在一些机型上detector为nil。
    
    //    if (iOS8_OR_LATER) {
    //        CIContext *context = [CIContext contextWithOptions:nil];
    //        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    //        CIImage *image = [CIImage imageWithCGImage:aImage.CGImage];
    //        NSArray *features = [detector featuresInImage:image];
    //        CIQRCodeFeature *feature = [features firstObject];
    //
    //        qrResult = feature.messageString;
    //    } else {
    
    ZBarReaderController* read = [ZBarReaderController new];
    CGImageRef cgImageRef = aImage.CGImage;
    ZBarSymbol* symbol = nil;
    for(symbol in [read scanImage:cgImageRef]) break;
    qrResult = symbol.data ;
    return qrResult;
}

#pragma mark ---actionsheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex---%d",buttonIndex);
}

@end
