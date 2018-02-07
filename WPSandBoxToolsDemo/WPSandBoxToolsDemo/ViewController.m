//
//  ViewController.m
//  WPSandBoxToolsDemo
//
//  Created by liwenhao on 2017/10/23.
//  Copyright © 2017年 liwenhaopro. All rights reserved.
//

#import "ViewController.h"
#import "WPSandBoxPreviewTool.h"
#import <WPPrintLogFile/WPPrintLogFile.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self testWriteLog];
}
- (IBAction)clickaction:(id)sender {
    [[WPSandBoxPreviewTool sharedTool] openLog];
    [[WPSandBoxPreviewTool sharedTool] autoOpenCloseApplicationDiskDirectoryPanel];
}

- (void)testWriteLog {
    NSLog(@"start");
    for (NSInteger index = 0; index < 1000 ; index ++) {
        
        WPPrintFileLog1(@"testLog", @"asss");
    }
    NSLog(@"end");
}



@end
