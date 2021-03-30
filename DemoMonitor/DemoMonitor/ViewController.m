//
//  ViewController.m
//  DemoMonitor
//
//  Created by Herman on 2021/2/23.
//  Copyright © 2021 Herman. All rights reserved.
//

#import "ViewController.h"
#import "SYMonitorTools.h"
#import "MonitorViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) UILabel *label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"监控";
    //
    UIBarButtonItem *sendItem = [[UIBarButtonItem alloc] initWithTitle:@"send" style:UIBarButtonItemStyleDone target:self action:@selector(sendClick)];
    UIBarButtonItem *readItem = [[UIBarButtonItem alloc] initWithTitle:@"read" style:UIBarButtonItemStyleDone target:self action:@selector(readClick)];
    self.navigationItem.leftBarButtonItems = @[sendItem, readItem];
    //
    UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithTitle:@"next" style:UIBarButtonItemStyleDone target:self action:@selector(nextClick)];
    UIBarButtonItem *logItem = [[UIBarButtonItem alloc] initWithTitle:@"log" style:UIBarButtonItemStyleDone target:self action:@selector(logClick)];
    self.navigationItem.rightBarButtonItems = @[nextItem, logItem];
    //
    [self setUI];
}

- (void)dealloc
{
    NSLog(@"%@ 被释放了~", self.class);
}

- (void)sendClick
{

}
- (void)readClick
{
//    SYMonitorRead(^(NSArray <SYMonitorModel *>* _Nonnull array) {
//        for (SYMonitorModel *model in array) {
//            NSString *message = [NSString stringWithFormat:@"%@, %ld, %@, %@", model.time, model.type, model.title, model.content];
//            NSLog(@"model = %@", message);
//        }
//    });
    
    MonitorViewController *nextVC = [MonitorViewController new];
    [self.navigationController pushViewController:nextVC animated:YES];
}

- (void)nextClick
{
    ViewController *nextVC = [ViewController new];
    [self.navigationController pushViewController:nextVC animated:YES];
}

- (void)logClick
{
    NSArray *array = [SYMonitorTools.share refreshMonitor];
    NSMutableString *text = [[NSMutableString alloc] init];
    for (SYMonitorModel *model in array) {
        [text appendFormat:@"%@,%ld,%@,%@\n", model.time, model.type, model.typeName, model.content];
    }
    self.label.text = text;
}

#pragma mark - crash

- (void)setUI
{
    UITableView *table = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:table];
    table.delegate = self;
    table.dataSource = self;
    table.tableFooterView = [UIView new];
    //
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, table.frame.size.width, 100)];
    self.label.numberOfLines = 0;
    table.tableHeaderView = self.label;
}

- (NSArray *)array
{
    return @[@"数组越界", @"数组nil值", @"未定义方法"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    NSString *test = self.array[indexPath.row];
    cell.textLabel.text = test;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:{
            [self crashOutofSize];
        } break;
        case 1:{
            [self crashNilValue];
        } break;
        case 2:{
            [self crashSelector];
        } break;
        default: break;
    }
}

- (void)crashOutofSize
{
    NSString *text = self.array[100];
}

- (void)crashNilValue
{
    NSString *text = nil;
    NSArray *list = @[@"1",text];
}

- (void)crashSelector
{
    [self performSelector:@selector(pushClick)];
}


@end
