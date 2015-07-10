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
#import "DVUserDetailTableViewController.h"

@interface DVMainTableViewController ()

@property (strong, nonatomic) NSMutableArray *gitUsers;
@property (strong, nonatomic) NSMutableArray *lastUsers;
@property (assign, nonatomic) BOOL loadingData;

@end

@implementation DVMainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gitUsers = [NSMutableArray array];
    self.lastUsers = [NSMutableArray array];
    
    [self getUsersFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
        NSLog(@"%ld: %@",  (long)statusCode, [error localizedDescription]);
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
    
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    DVGitUser *gitUser = [self.gitUsers objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.lastUsers addObject:[self.gitUsers objectAtIndex:indexPath.row]];
    [self performSegueWithIdentifier:@"showUserDetail" sender:[tableView cellForRowAtIndexPath:indexPath]];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height / 1.3f) {
        if (!self.loadingData) {
            self.loadingData = YES;
            [self getUsersFromServer];
        }
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"showUserDetail"]) {

        DVUserDetailTableViewController *vc = [segue destinationViewController];

        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        DVGitUser *user = [self.gitUsers objectAtIndex:indexPath.row];
        vc.user = user;
    }
    
}

@end
