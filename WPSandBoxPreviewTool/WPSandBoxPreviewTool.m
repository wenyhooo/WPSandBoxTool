//
//  LJ_FileTool.m
//  FileDirectoryTool
//
//  Created by nuomi on 2017/2/7.
//  Copyright © 2017年 xgyg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPSandBoxPreviewTool.h"
#import "WPDirToolNavigatorController.h"
#define kWPApplicationRootVC [UIApplication sharedApplication].keyWindow.rootViewController

@interface WPSandBoxPreviewTool ()

@property (nonatomic,strong)WPDirToolNavigatorController * navVC;

@end

@implementation WPSandBoxPreviewTool

static WPSandBoxPreviewTool *_singleton;

+ (instancetype)sharedTool{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleton = [[self alloc] init];;
    });
    return _singleton;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleton = [super allocWithZone:zone];
    });
    return _singleton;
}

#pragma mark 打开或关闭应用磁盘目录面板
- (void)autoOpenCloseApplicationDiskDirectoryPanel
{
    UIViewController *root = kWPApplicationRootVC;
    if (root.presentedViewController) {
        root = root.presentedViewController;
    }
    BOOL isEqual = (root == _navVC);
    if (isEqual) {
        [_navVC dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self presentNav];
    }
}

- (void)presentNav{
    
    UIViewController *rootVC = kWPApplicationRootVC;
    if (rootVC.presentedViewController) {
        rootVC = kWPApplicationRootVC.presentedViewController;
    }
    
    if (_navVC) {
        [rootVC presentViewController:_navVC animated:YES completion:nil];
    }else{
        WPDirToolNavigatorController * vc = [WPDirToolNavigatorController create];
        vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [rootVC presentViewController:vc animated:YES completion:nil];
        _navVC = vc;
    }
}

- (UIViewController *)topPresentedViewController
{
    UIViewController *vc = kWPApplicationRootVC;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    return vc;
}

@end
