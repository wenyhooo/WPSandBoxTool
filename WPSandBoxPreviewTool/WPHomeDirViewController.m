//
//  WPHomeDirViewController.m
//  FileDirectoryTool
//
//  Created by nuomi on 2017/2/7.
//  Copyright © 2017年 xgyg. All rights reserved.
//

#import "WPHomeDirViewController.h"
#import "WPFileInfoController.h" //文件详情页面
#import "WPFileInfo.h"  //文件检查类

@interface WPHomeDirViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong)UITableView * tableView;
@property (nonatomic,strong)NSMutableArray * dataSource;

@end

@implementation WPHomeDirViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
}

- (void)close{
    if (self.navigationController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)setUpUI{
    
    if (self.isHomeDir) {
        self.title = @"应用沙盒文件目录";
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        // CFShow((__bridge CFTypeRef)(infoDictionary));
        NSString *executableFile = [infoDictionary objectForKey:(NSString *)kCFBundleExecutableKey]; //获取项目包文件
        if(executableFile){
            executableFile = [executableFile stringByAppendingString:@".app (包)"];
        }else{
            executableFile = @"app";
        }
        [_dataSource addObject:@{@"title":executableFile,@"isDir":@NO,@"canDel":@NO}];
        _filePath = NSHomeDirectory();
        UIBarButtonItem * left = [[UIBarButtonItem alloc]initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(close)];
        self.navigationItem.leftBarButtonItem = left;
    }else{
        self.title = self.fileName;
        UIBarButtonItem * right = [[UIBarButtonItem alloc]initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(findAllFileInfo)];
        self.navigationItem.rightBarButtonItem = right;
    }
    
    self.view.backgroundColor = [UIColor colorWithRed:0.945 green:0.945 blue:0.945 alpha:1];
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 60;
    self.tableView.separatorColor = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1];
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self findAllFileInfo];
}

- (void)findAllFileInfo{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.dataSource = [WPFileInfo searchAllFileFromRightDirPath:_filePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.dataSource.count) {
                self.tableView.hidden = NO;
                [self.tableView reloadData];
            }else{
                self.tableView.hidden = YES;
            }
        });
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * cellID = @"WPHomeDirViewController_tableViewCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    NSDictionary  *infoDict = _dataSource[indexPath.row];
    cell.textLabel.textColor = [UIColor colorWithRed:0.19 green:0.19 blue:0.19 alpha:1];
    cell.textLabel.text = [infoDict objectForKey:@"title"];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if ([[infoDict objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory] == NO) {
        //非文件夹
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        if ([infoDict[@"FileType"] hasPrefix:@"image"]) {
            //图片类型
            cell.imageView.image = [UIImage imageNamed:@"lj_Pictures"];
        }else{
            //unknow_icon  未知文件类型
            cell.imageView.image = [UIImage imageNamed:@"lj_unknow_icon"];
        }
    }else{
        //文件夹模式
        cell.imageView.image = [UIImage imageNamed:@"GenericFolderIcon.png"];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    NSNumber *fileSize = [infoDict objectForKey:NSFileSize];
    CGFloat kb = [fileSize floatValue]/1024;
    NSString *sizeContent = nil;
    if (kb < 1024) {
        sizeContent = [NSString stringWithFormat:@"~%.2f%@",kb,@"kb"];
    }else{
        sizeContent = [NSString stringWithFormat:@"~%.2f%@",kb/1024,@"M"];
    }
    
    if(infoDict[NSFileModificationDate]){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"MM-dd HH:mm:ss"];
        NSString *dateStr = [dateFormatter stringFromDate:infoDict[NSFileModificationDate]];
        cell.detailTextLabel.text = [dateStr stringByAppendingString:sizeContent];
    }else{
        cell.detailTextLabel.text = @" ";
    }
    for (UIGestureRecognizer *gesture in cell.gestureRecognizers) {
        [cell removeGestureRecognizer:gesture];
    }
    
    UILongPressGestureRecognizer *LongPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longAction:)];
    [cell addGestureRecognizer:LongPressGesture];
    return cell;
}

- (void)longAction:(UILongPressGestureRecognizer *)LongPressGesture
{
    UITableViewCell *cell = (UITableViewCell *) LongPressGesture.view;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSDictionary  *infoDict = _dataSource[indexPath.row];
    
    if ([[infoDict objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory]) {
        
    }else{
        NSString * fileName = infoDict[@"title"];
        NSString * filePath = [self.filePath stringByAppendingPathComponent:fileName];
        NSURL *urlToShare = [NSURL fileURLWithPath:filePath];
        if (!urlToShare) return;
        NSArray *activityItems = @[urlToShare];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
        [self.navigationController presentViewController:activityVC animated:YES completion:nil];
    }
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        return @[];
    }
    if (self.isHomeDir) {
        return @[];
    }
    
    BOOL canDelete = [[NSFileManager defaultManager] isDeletableFileAtPath:self.filePath];
    NSString * title = canDelete ? @"删除" : @"不可删除";
    UITableViewRowAction * delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:title handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if ([action.title isEqualToString:@"删除"]) {
            [self deleteOneRowWithIndexPath:indexPath];
        }else{
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        }
    }];
    
    return @[delete];
}
#pragma mark - 删除文件或者目录
- (void)deleteOneRowWithIndexPath:(NSIndexPath *)indexPath{
    
    //获取文件属性
    NSFileManager * filemager = [NSFileManager defaultManager];
    NSDictionary * info = _dataSource[indexPath.row];
    NSString * path = [self.filePath stringByAppendingPathComponent:info[@"title"]];
    NSError * error = nil;
    [filemager removeItemAtPath:path error:&error];
    if (error) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"删除文件失败" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self.navigationController presentViewController:alert animated:YES completion:nil];
        return ;
    }
    
    NSMutableArray * ds = [NSMutableArray arrayWithArray:self.dataSource];
    [ds removeObjectAtIndex:indexPath.row];
    self.dataSource = ds;
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary * infoDict = _dataSource[indexPath.row];
    if ([[infoDict objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory]) {
        WPHomeDirViewController * dirVC = [[WPHomeDirViewController alloc] init];
        dirVC.filePath = [self.filePath stringByAppendingPathComponent:infoDict[@"title"]];
        dirVC.fileName = infoDict[@"title"];
        [self.navigationController pushViewController:dirVC animated:YES];
    }else{
        NSString * fileName = infoDict[@"title"];
        NSString * filePath = [self.filePath stringByAppendingPathComponent:fileName];
        
        WPFileInfoController * infovc =[WPFileInfoController createWithFileName:fileName andFilePath:filePath andFileInfo:infoDict];
        [self.navigationController pushViewController:infovc animated:YES];
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
