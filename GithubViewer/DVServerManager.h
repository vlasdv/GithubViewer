//
//  DVServerManager.h
//  GithubViewer
//
//  Created by Dmitrii Vlasov on 11.11.14.
//  Copyright (c) 2014 Dmitry Vlasov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DVServerManager : NSObject

+ (DVServerManager *)sharedManager;

- (void)getAllUsersSince:(NSInteger)since success:(void(^)(NSArray *users))success failure:(void(^)(NSError *error, NSInteger statusCode))failure;

@end
