//
//  DVMainTableViewController.m
//  GithubViewer
//
//  Created by Dmitrii Vlasov on 11.11.14.
//  Copyright (c) 2014 Dmitry Vlasov. All rights reserved.
//

#import "DVMainTableViewController.h"
#import "DVServerManager.h"
#import "DVGitUser.h"
#import "UIKit+AFNetworking.h"

@interface DVMainTableViewController ()

@property (strong, nonatomic) NSMutableArray *gitUsers;
@property (assign, nonatomic) BOOL loadingData;

@end

@implementation DVMainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gitUsers = [NSMutableArray array];
    
    [self getUsersFromServer];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - API

- (void)getUsersFromServer {
    
    [[DVServerManager sharedManager] getAllUsersSince:[self.gitUsers count] success:^(NSArray *users) {
    
        [self.gitUsers addObjectsFromArray:users];
        
        NSMutableArray *newPaths = [NSMutableArray array];
        for (int i = (int)[self.gitUsers count] - (int)[users count]; i < [self.gitUsers count]; i++) {
            [newPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
        }
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
        self.loadingData = NO;
        
    } failure:^(NSError *error, NSInteger statusCode) {
        NSLog(@"%d: %@",  statusCode, [error localizedDescription]);
    }];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.gitUsers count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    DVGitUser *gitUser = [self.gitUsers objectAtIndex:indexPath.row];
    cell.textLabel.text = gitUser.name;
    
    __weak UITableViewCell *weakCell = cell;
    NSURLRequest *request = [NSURLRequest requestWithURL:gitUser.avatarURL];
    
    cell.imageView.image = nil;
    
    [cell.imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakCell.imageView.image = image;
        [weakCell layoutSubviews];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"failed to load user image");
    }];
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height / 1.3f) {
        if (!self.loadingData) {
            self.loadingData = YES;
            [self getUsersFromServer];
        }
    }
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
//        if (!self.loadingData)
//        {
//            self.loadingData = YES;
//            [self getFriendsFromServer];
//        }
//    }
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
