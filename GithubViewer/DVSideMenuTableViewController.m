//
//  DVSideMenuTableViewController.m
//  GithubViewer
//
//  Created by Dmitrii Vlasov on 12.11.14.
//  Copyright (c) 2014 Dmitry Vlasov. All rights reserved.
//

#import "DVSideMenuTableViewController.h"
#import "DVServerManager.h"
#import "DVGitUser.h"
#import "MFSideMenuContainerViewController.h"
#import "UIImageView+AFNetworking.h"

@interface DVSideMenuTableViewController () <UISearchBarDelegate>

@property (strong, nonatomic) NSArray *lastFiveUsers;
@property (strong, nonatomic) NSArray *searchResult;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation DVSideMenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSlideMenuStateNotification:)
                                                 name:MFSideMenuStateNotificationEvent
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private methods

- (void)handleSlideMenuStateNotification:(NSNotification *)notification {
    
    if ([notification.userInfo objectForKey:@"eventType"] == [NSNumber numberWithInt:0]) {
        
        self.lastFiveUsers = [NSArray arrayWithArray:[[DVServerManager sharedManager] getLastFiveViewedUsers]];
        
        [self.tableView reloadData];
    }
}

#pragma mark - API

- (void)searchUserWithName:(NSString *)name {
    [[DVServerManager sharedManager] getSearchResultForUsername:name success:^(NSArray *users) {
        
        self.searchResult = [NSArray arrayWithArray:users];
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error, NSInteger statusCode) {
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.searchResult) {
        return [self.searchResult count];
    }
    
    return [self.lastFiveUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    DVGitUser *gitUser = nil;
    if (!self.searchResult) {
        gitUser = [self.lastFiveUsers objectAtIndex:indexPath.row];
    } else {
        gitUser = [self.searchResult objectAtIndex:indexPath.row];
    }
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

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    self.searchResult = nil;
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    [self searchUserWithName:self.searchBar.text];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    [self.searchBar setShowsCancelButton:NO animated:YES];
}

@end
