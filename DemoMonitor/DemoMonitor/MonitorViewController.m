//
//  MonitorViewController.m
//  DemoMonitor
//
//  Created by zhangshaoyu on 2021/2/24.
//  Copyright © 2021 Herman. All rights reserved.
//

#import "MonitorViewController.h"
#import "SYMonitorTools.h"

@interface MonitorTableCell : UITableViewCell

/// 类型，状态，时间，标题
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation MonitorTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat origin = 20;
        CGFloat heightText = 40;
        //
        self.typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(origin, 0, ((self.frame.size.width - origin * 2) / 3), heightText)];
        [self.contentView addSubview:self.typeLabel];
        self.typeLabel.textAlignment = NSTextAlignmentLeft;
        self.typeLabel.font = [UIFont systemFontOfSize:12];
        self.typeLabel.textColor = UIColor.blackColor;
        
        UIView *currentView = self.typeLabel;
        //
        self.stateLabel = [[UILabel alloc] initWithFrame:CGRectMake((currentView.frame.origin.x + currentView.frame.size.width), currentView.frame.origin.y, currentView.frame.size.width, currentView.frame.size.height)];
        [self.contentView addSubview:self.stateLabel];
        self.stateLabel.textAlignment = NSTextAlignmentLeft;
        self.stateLabel.font = [UIFont systemFontOfSize:12];
        self.stateLabel.textColor = UIColor.blackColor;
        
        currentView = self.stateLabel;
        //
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake((currentView.frame.origin.x + currentView.frame.size.width), currentView.frame.origin.y, currentView.frame.size.width, currentView.frame.size.height)];
        [self.contentView addSubview:self.timeLabel];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        self.timeLabel.font = [UIFont systemFontOfSize:12];
        self.timeLabel.textColor = UIColor.blackColor;
        
        currentView = self.timeLabel;
        //
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(origin, (currentView.frame.origin.y + currentView.frame.size.height), (self.frame.size.width - origin * 2), currentView.frame.size.height)];
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        self.titleLabel.textColor = UIColor.blackColor;
    }
    return self;
}

+ (CGFloat)heightMonitorTableCell
{
    return 40 + 40;
}

@end

@interface MonitorViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *array;

@end

@implementation MonitorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"监控平台";
    [self loadData];
}

- (UIActivityIndicatorView *)activityView
{
    if (_activityView == nil) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.view addSubview:_activityView];
        _activityView.color = UIColor.redColor;
        _activityView.center = self.view.center;
        _activityView.hidesWhenStopped = YES;
    }
    return _activityView;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [self.view addSubview:_tableView];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MonitorTableCell heightMonitorTableCell];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MonitorTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        cell = [[MonitorTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    SYServerModel *model = self.array[indexPath.row];
    NSString *time = model.logTime;
    NSString *text = model.logTitle;
    NSString *type = model.logTypeName;
    NSString *state = model.logStateName;
    //
    cell.typeLabel.text = type;
    cell.stateLabel.text = state;
    cell.timeLabel.text = time;
    cell.titleLabel.text = text;
    
    return cell;
}

- (void)loadData
{
    [self.activityView startAnimating];
    [SYMonitorTools.share monitorReadWithPage:1 size:500 complete:^(NSArray<SYServerModel *> * _Nonnull array, NSError * _Nonnull error) {
        [self.activityView stopAnimating];
        //
        self.array = array;
        [self.tableView reloadData];
    }];
}

@end
