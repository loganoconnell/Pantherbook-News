//
//  TableViewCell.m
//  Panther News
//
//  Created by Logan O'Connell on 8/9/17.
//  Copyright © 2017 Logan O'Connell. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self shadows:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)shadows:(BOOL)yes {
    if (yes) {
        self.layer.cornerRadius = 10;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.3;
        self.layer.shadowOffset = CGSizeMake(0, 5);
        self.layer.masksToBounds = NO;
    }
    
    else {
        self.layer.shadowOpacity = 0.3;
        self.layer.shadowOffset = CGSizeMake(0, 1);
    }
}
@end
