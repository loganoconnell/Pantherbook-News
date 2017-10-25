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
@property (strong, nonatomic) NSArray *posts;
@property (strong, nonatomic) NSMutableDictionary *images;
@property (strong, nonatomic) NSMutableDictionary *imageData;
@property (strong, nonatomic) NSMutableArray *titles;
@property (strong, nonatomic) NSMutableArray *subtitles;
@end

@implementation FirstViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor whiteColor];
    [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = refresh;
    
    [self.tableView setBackgroundView:nil];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    self.navigationItem.title = @"PANTHERBOOK";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
        self.navigationController.navigationBar.largeTitleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor] };
    }
    
    else {
        self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor] };
    }
    
    self.images = [NSMutableDictionary dictionary];
    self.imageData = [NSMutableDictionary dictionary];
    self.titles = [NSMutableArray array];
    self.subtitles = [NSMutableArray array];
    
    [self downloadMainData];
}

- (void)downloadMainData {
    NSURL *url = [NSURL URLWithString:@"https://franklinpanthers.us/wp-json/wp/v2/posts"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (!error) {
            self.posts = (NSArray *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            for (NSDictionary *post in self.posts) {
                NSString *renderedTitle = post[@"title"][@"rendered"];
                NSAttributedString *title = [[NSAttributedString alloc] initWithData:[renderedTitle dataUsingEncoding:NSUTF8StringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding), NSForegroundColorAttributeName: [UIColor darkGrayColor] } documentAttributes:nil error:nil];
                
                [self.titles addObject:title];
                
                NSString *renderedSubtitle = post[@"content"][@"rendered"];
                NSAttributedString *subtitle = [[NSAttributedString alloc] initWithData:[renderedSubtitle dataUsingEncoding:NSUTF8StringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding), NSForegroundColorAttributeName: [UIColor darkGrayColor] } documentAttributes:nil error:nil];
                
                [self.subtitles addObject:subtitle];
            }
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.tableView reloadData];
                
                [self.tableView.refreshControl endRefreshing];
            }];
            
            [self downloadImageMetadata];
        }
    }];
    
    [task resume];
}

- (void)downloadImageMetadata {
    for (NSDictionary *post in self.posts) {
        NSString *urlString = [NSString stringWithFormat:@"https://franklinpanthers.us/wp-json/wp/v2/media/%@", post[@"featured_media"]];
        
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *imageData, NSURLResponse *response, NSError *error) {
            NSDictionary *imageDictionary = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:imageData options:0 error:nil];
            
            NSString *imageLink = imageDictionary[@"guid"][@"rendered"];
            
            NSString *key = [NSString stringWithFormat:@"%@", post[@"featured_media"]];
            
            [self.images setObject:imageLink forKey:key];
            
            [self downloadImageData:[imageLink copy] forKey:key];
        }];
        
        [task resume];
    }
}

- (void)downloadImageData:(NSString *)imageLink forKey:(NSString *)key {
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageLink]];
    UIImage *image = [UIImage imageWithData:imageData];
    
    [self.imageData setObject:image forKey:key];
    
    if (self.imageData.count == self.posts.count) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.tableView reloadData];
        }];
    }
}

- (void)refresh:(id)sender {
    self.tableView.refreshControl.tintColor = [UIColor whiteColor];
    [self downloadMainData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Delegate & Data Source methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.posts.count;
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
    
    if (self.posts) {
        TableViewCell *customCell = (TableViewCell *)cell;
        
        customCell.titleLabel.attributedText = self.titles[indexPath.section];
        customCell.titleLabel.font = [UIFont systemFontOfSize:25];
        customCell.titleLabel.textColor = [UIColor blackColor];
        
        customCell.subtitleLabel.attributedText = self.subtitles[indexPath.section];
        customCell.subtitleLabel.textColor = [UIColor darkGrayColor];
        customCell.subtitleLabel.adjustsFontSizeToFitWidth = NO;
        customCell.subtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        if (self.imageData.count > 0 && self.imageData.count - 1 >= indexPath.section) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *key = [NSString stringWithFormat:@"%@", self.posts[indexPath.section][@"featured_media"]];
                UIImage *image = self.imageData[key];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([[self.tableView indexPathsForVisibleRows] containsObject:indexPath]) {
                        UITableViewCell *correctCell = [self.tableView cellForRowAtIndexPath:indexPath];
                        ((TableViewCell *)correctCell).topImageView.image = image;
                        [correctCell setNeedsLayout];
                    }
                });
            });
         }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 300;
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
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SecondViewController *vc = (SecondViewController *)[sb instantiateViewControllerWithIdentifier:@"secondVC"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = (TableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell performSelector:@selector(shadows:) withObject:@YES afterDelay:0.1];
}
@end
