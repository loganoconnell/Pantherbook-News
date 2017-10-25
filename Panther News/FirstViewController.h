//
//  FirstViewController.h
//  Panther News
//
//  Created by Logan O'Connell on 8/8/17.
//  Copyright © 2017 Logan O'Connell. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TableViewCell.h"
#import "SecondViewController.h"

@interface FirstViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
