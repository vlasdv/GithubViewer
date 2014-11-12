//
//  DVServerManager.m
//  GithubViewer
//
//  Created by Dmitrii Vlasov on 11.11.14.
//  Copyright (c) 2014 Dmitry Vlasov. All rights reserved.
//

#import "DVServerManager.h"
#import "AFNetworking.h"
#import "DVGitUser.h"
#import "DVGitRepo.h"

@interface DVServerManager ()

@property (strong, nonatomic) AFHTTPRequestOperationManager *requestOperationManager;
@property (strong, nonatomic) NSMutableArray *lastFiveViewedUsers;

@end

@implementation DVServerManager

+ (DVServerManager *)sharedManager {
    static DVServerManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DVServerManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURL *url = [NSURL URLWithString:@"https://api.github.com"];
        self.requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
        self.lastFiveViewedUsers = [NSMutableArray array];
    }
    return self;
}

- (NSArray *)getLastFiveViewedUsers {
    return self.lastFiveViewedUsers;
}

#pragma mark - Private Methods

- (void)addUserToLastFive:(DVGitUser *)user {
    
    if ([self.lastFiveViewedUsers containsObject:user]) {
        [self.lastFiveViewedUsers removeObject:user];
    }
    
    [self.lastFiveViewedUsers addObject:user];
    
    if ([self.lastFiveViewedUsers count] > 5) {
        [self.lastFiveViewedUsers removeObjectAtIndex:0];
    }

}

#pragma mark - API

- (void)getAllUsersSince:(NSInteger)since success:(void(^)(NSArray *users))success failure:(void(^)(NSError *error, NSInteger statusCode))failure {
    
    NSString *stringSince = [NSString stringWithFormat:@"%d", since];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                stringSince, @"since",
                                nil];
    
    [self.requestOperationManager GET:@"/users" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *dictionariesArray = responseObject;
        NSMutableArray *usersArray = [NSMutableArray array];
        
        for (NSDictionary *dictionary in dictionariesArray) {
            DVGitUser *gitUser = [[DVGitUser alloc] initWithDictionary:dictionary];
            [usersArray addObject:gitUser];
        }
        
        if (success) {
            success(usersArray);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error, operation.response.statusCode);
        }
    }];
    
}

- (void)getRepositoriesForUser:(DVGitUser *)user success:(void(^)(NSArray *repositories))success failure:(void(^)(NSError *error, NSInteger statusCode))failure {
    
    NSString *request = [NSString stringWithFormat:@"/users/%@/repos", user.name];
    [self.requestOperationManager GET:request parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *dictionariesArray = responseObject;
        NSMutableArray *reposArray = [NSMutableArray array];
        
        for (NSDictionary *dictionary in dictionariesArray) {
            DVGitRepo *gitRepo = [[DVGitRepo alloc] initWithDictionary:dictionary];
            [reposArray addObject:gitRepo];
        }
        
        if (success) {
            success(reposArray);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error, operation.response.statusCode);
        }
    }];
    
    [self addUserToLastFive:user];
}

- (void)getSearchResultForUsername:(NSString *)name success:(void(^)(NSArray *users))success failure:(void(^)(NSError *error, NSInteger statusCode))failure {

    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                name, @"q",
                                nil];
    
    [self.requestOperationManager GET:@"/search/users" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *dictionariesArray = [responseObject objectForKey:@"items"];
        NSMutableArray *usersArray = [NSMutableArray array];
        
        for (NSDictionary *dictionary in dictionariesArray) {
            DVGitUser *gitUser = [[DVGitUser alloc] initWithDictionary:dictionary];
            [usersArray addObject:gitUser];
        }
        
        if (success) {
            success(usersArray);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error, operation.response.statusCode);
        }
    }];
}

@end
