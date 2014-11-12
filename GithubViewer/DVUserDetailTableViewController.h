//
//  DVUserDetailTableViewController.h
//  GithubViewer
//
//  Created by Dmitrii Vlasov on 11.11.14.
//  Copyright (c) 2014 Dmitry Vlasov. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DVGitUser;

@interface DVUserDetailTableViewController : UITableViewController

@property (strong, nonatomic) DVGitUser *user;

@end
