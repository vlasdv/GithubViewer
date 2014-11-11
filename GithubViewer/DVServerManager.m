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

@interface DVServerManager ()

@property (strong, nonatomic) AFHTTPRequestOperationManager *requestOperationManager;

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
    }
    return self;
}

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
        
//        NSLog(@"%@", [dictionariesArray objectAtIndex:2]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error, operation.response.statusCode);
        }
    }];
    
}

@end
