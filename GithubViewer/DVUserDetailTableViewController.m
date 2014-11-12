//
//  DVUserDetailTableViewController.m
//  GithubViewer
//
//  Created by Dmitrii Vlasov on 11.11.14.
//  Copyright (c) 2014 Dmitry Vlasov. All rights reserved.
//

#import "DVUserDetailTableViewController.h"
#import "DVUserDetailTableViewCell.h"
#import "DVGitUser.h"
#import "DVGitRepo.h"
#import "UIImageView+AFNetworking.h"
#import "DVServerManager.h"

@interface DVUserDetailTableViewController ()

@property (strong, nonatomic) NSArray *repositories;
@property (strong, nonatomic) DVUserDetailTableViewCell *cell;

@end

@implementation DVUserDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getRepositoriesFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - API

- (void)getRepositoriesFromServer {
    
    [[DVServerManager sharedManager] getRepositoriesForUser:self.user success:^(NSArray *repositories) {
                
        self.repositories = [[NSArray alloc] initWithArray:repositories];
        
        NSMutableArray *newPaths = [NSMutableArray array];
        for (int i = 0; i < [self.repositories count]; i++) {
            [newPaths addObject:[NSIndexPath indexPathForItem:i inSection:1]];
        }
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
        
    } failure:^(NSError *error, NSInteger statusCode) {
        NSLog(@"%d: %@",  statusCode, [error localizedDescription]);
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    } else {
        return [self.repositories count];
    };
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        
        static NSString *identifier = @"DVUserDetailTableViewCell";
        DVUserDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

        cell.nameLabel.text = self.user.name;
        
        __weak DVUserDetailTableViewCell *weakCell = cell;
        NSURLRequest *request = [NSURLRequest requestWithURL:self.user.avatarURL];
        [cell.avatarImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakCell.avatarImageView.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"failed to get image");
        }];
        
        self.cell = cell;
        
        return cell;
        
    } else {
        
        static NSString *identifier = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        }
        
        DVGitRepo *currentRepo = [self.repositories objectAtIndex:indexPath.row];
        cell.textLabel.text = currentRepo.name;
        cell.detailTextLabel.text = currentRepo.repoDescription;
                
        return cell;
    }

    return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == 0) {
        return 135.f;
    }
    
    return 44.f;
}

@end
