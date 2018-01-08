//
//  FirstViewController.m
//  Panther News
//
//  Created by Logan O'Connell on 8/8/17.
//  Copyright © 2017 Logan O'Connell. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIView+WebCache.h>

#import "FirstViewController.h"

NSString *const kAPIEndpoint = @"https://franklinpanthers.us/wp-json/wp/v2";

@interface FirstViewController ()
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSArray *posts;
@property (strong, nonatomic) NSMutableDictionary *images;
@property (strong, nonatomic) NSMutableDictionary *authors;
@property (strong, nonatomic) NSMutableArray *titles;
@property (strong, nonatomic) NSMutableArray *subtitles;
@property (nonatomic) BOOL authorsDownloaded;
@end

@implementation FirstViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor blackColor];
    [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = refresh;
    
    [self.tableView setBackgroundView:nil];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    self.navigationItem.title = @"PANTHERBOOK";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
        self.navigationController.navigationBar.largeTitleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor] };
    }
    
    else {
        self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor] };
    }
    
    self.images = [NSMutableDictionary dictionary];
    self.authors = [NSMutableDictionary dictionary];
    self.titles = [NSMutableArray array];
    self.subtitles = [NSMutableArray array];
    
    [self downloadMainData];
}

- (void)downloadMainData {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/posts", kAPIEndpoint]];
    
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
                self.loadingIndicator.hidden = YES;
                
                [self.tableView reloadData];
                [self.tableView.refreshControl endRefreshing];
            }];
            
            [self downloadImageMetadata];
            [self downloadAuthorData];
        }
    }];
    
    [task resume];
}

- (void)downloadImageMetadata {
    for (NSDictionary *post in self.posts) {
        NSString *urlString = [NSString stringWithFormat:@"%@/media/%@", kAPIEndpoint, post[@"featured_media"]];
        
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *imageData, NSURLResponse *response, NSError *error) {
            NSDictionary *imageDictionary = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:imageData options:0 error:nil];
            
            NSString *imageLink = imageDictionary[@"guid"][@"rendered"];
            
            NSString *key = [NSString stringWithFormat:@"%@", post[@"featured_media"]];

            [self.images setObject:imageLink forKey:key];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:[self.posts indexOfObject:post]] withRowAnimation:UITableViewRowAnimationNone];
            }];
        }];
        
        [task resume];
    }
}

- (void)downloadAuthorData {
    for (NSDictionary *post in self.posts) {
        NSString *urlString = [NSString stringWithFormat:@"%@/users/%@", kAPIEndpoint,post[@"author"]];
        
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *imageData, NSURLResponse *response, NSError *error) {
            NSDictionary *authorDictionary = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:imageData options:0 error:nil];
            
            NSString *name = authorDictionary[@"name"];
            
            NSString *key = [NSString stringWithFormat:@"%@", post[@"author"]];
            
            [self.authors setObject:name forKey:key];
            
            if ([self.posts indexOfObject:post] == self.posts.count - 1) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    self.authorsDownloaded = YES;
                }];
            }
        }];
        
        [task resume];
    }
}

- (void)refresh:(id)sender {
    [self downloadMainData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// UITableViewDelegate & UITableViewDataSource
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
        customCell.subtitleLabel.font = [UIFont systemFontOfSize:18];
        customCell.subtitleLabel.textColor = [UIColor darkGrayColor];
        customCell.subtitleLabel.adjustsFontSizeToFitWidth = NO;
        customCell.subtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        NSString *key = [NSString stringWithFormat:@"%@", self.posts[indexPath.section][@"featured_media"]];
        if ([self.images objectForKey:key]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *key = [NSString stringWithFormat:@"%@", self.posts[indexPath.section][@"featured_media"]];
                NSString *imageLink = self.images[key];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    TableViewCell *correctCell = (TableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                    [correctCell.topImageView sd_setShowActivityIndicatorView:YES];
                    [correctCell.topImageView sd_setIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                    
                    [correctCell.topImageView sd_setImageWithURL:[NSURL URLWithString:imageLink] placeholderImage:nil options:0];
                    [correctCell setNeedsLayout];
                });
            });
         }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 300;
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
    
    NSString *key = [NSString stringWithFormat:@"%@", self.posts[indexPath.section][@"author"]];
    if ([self.authors objectForKey:key]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SecondViewController *vc = (SecondViewController *)[sb instantiateViewControllerWithIdentifier:@"secondVC"];
        
        NSString *imageKey = [NSString stringWithFormat:@"%@", self.posts[indexPath.section][@"featured_media"]];
        vc.imageLink = self.images[imageKey];
        
        vc.titleText = self.titles[indexPath.section];
        
        NSString *authorKey = [NSString stringWithFormat:@"%@", self.posts[indexPath.section][@"author"]];
        vc.authorText = self.authors[authorKey];
        
        vc.text = self.subtitles[indexPath.section];
        
        vc.postLink = self.posts[indexPath.section][@"link"];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = (TableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell performSelector:@selector(shadows:) withObject:@YES afterDelay:0.1];
}
@end
