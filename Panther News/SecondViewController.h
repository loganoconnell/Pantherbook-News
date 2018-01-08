//
//  SecondViewController.h
//  Panther News
//
//  Created by Logan O'Connell on 10/25/17.
//  Copyright © 2017 Logan O'Connell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) NSString *imageLink;
@property (strong, nonatomic) NSAttributedString *titleText;
@property (strong, nonatomic) NSString *authorText;
@property (strong, nonatomic) NSAttributedString *text;
@property (strong, nonatomic) NSString *postLink;
@end
