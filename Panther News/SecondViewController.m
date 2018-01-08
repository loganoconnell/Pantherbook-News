//
//  SecondViewController.m
//  Panther News
//
//  Created by Logan O'Connell on 10/25/17.
//  Copyright © 2017 Logan O'Connell. All rights reserved.
//

#import <SafariServices/SafariServices.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "SecondViewController.h"

@interface SecondViewController ()
@end

@implementation SecondViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.imageLink] placeholderImage:nil options:0];
    
    self.titleLabel.attributedText = self.titleText;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:28];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.authorLabel.text = [NSString stringWithFormat:@"By %@", self.authorText];
    self.authorLabel.textColor = [UIColor lightGrayColor];
    self.authorLabel.font = [UIFont systemFontOfSize:20];
    self.authorLabel.textAlignment = NSTextAlignmentCenter;
    
    NSMutableAttributedString *newText = [[NSMutableAttributedString alloc] initWithString:@"\n" attributes:@{}];
    [newText appendAttributedString:self.text];
    self.textView.attributedText = newText;
    self.textView.textColor = [UIColor darkGrayColor];
    self.textView.font = [UIFont systemFontOfSize:18];
    self.textView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)share:(id)sender {
    UIActivityViewController *shareVC = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL URLWithString:self.postLink]] applicationActivities:@[]];
    [self presentViewController:shareVC animated:YES completion:nil];
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

// UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:URL];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self presentViewController:safariVC animated:YES completion:nil];
    
    return NO;
}
#pragma GCC diagnostic pop
@end
