//
//  FirstViewController.m
//  Panther News
//
//  Created by Logan O'Connell on 8/8/17.
//  Copyright © 2017 Logan O'Connell. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation FirstViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UISearchController *controller = [[UISearchController alloc] initWithSearchResultsController:nil];
    controller.searchBar.tintColor = [UIColor whiteColor];
    self.navigationItem.searchController = controller;
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor whiteColor];
    [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = refresh;
    
    [self.tableView setBackgroundView:nil];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    self.navigationItem.title = @"PANTHERBOOK";
    
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
        self.navigationController.navigationBar.largeTitleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor] };
    } else {
        self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor] };
    }
    
    [self downloadTestData];
}

- (void)downloadTestData {
    NSLog(@"Inside");
    NSURL *url = [NSURL URLWithString:@"https://franklinpanthers.us/wp-json/wp/v2/posts"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask * task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(data);
    }];
    
    [task resume];
}

- (void)refresh:(id)sender {
    [(UIRefreshControl *)sender endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleRefresh:(id)sender {
    [_refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:1];
}

// Delegate & Data Source methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell"];

    if (!cell) {
        [self.tableView registerNib:[UINib nibWithNibName:@"TableViewCell" bundle:nil] forCellReuseIdentifier:@"TableViewCell"];
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"TableViewCell"];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Recent Posts";
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TableViewCell *cell = (TableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell shadows:NO];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TableViewCell *cell = (TableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell shadows:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = (TableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell performSelector:@selector(shadows:) withObject:@YES afterDelay:0.1];
}
@end
