//
//  TableViewCell.h
//  Panther News
//
//  Created by Logan O'Connell on 8/9/17.
//  Copyright © 2017 Logan O'Connell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
- (void)shadows:(BOOL)yes;
@end
