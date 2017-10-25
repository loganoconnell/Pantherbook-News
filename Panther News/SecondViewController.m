//
//  SecondViewController.m
//  Panther News
//
//  Created by Logan O'Connell on 10/25/17.
//  Copyright © 2017 Logan O'Connell. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];
    
    self.imageView.image = self.bannerImage;
    
    self.titleLabel.attributedText = self.titleText;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:25];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    NSMutableAttributedString *newText = [[NSMutableAttributedString alloc] initWithString:@"\n" attributes:@{}];
    [newText appendAttributedString:self.text];
    self.textView.attributedText = newText;
    self.textView.textColor = [UIColor darkGrayColor];
    self.textView.font = [UIFont systemFontOfSize:18];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)share:(id)sender {
    UIActivityViewController *shareVC = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL URLWithString:self.postLink]] applicationActivities:@[]];
    [self presentViewController:shareVC animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
