//
//  DVGitUser.h
//  GithubViewer
//
//  Created by Dmitrii Vlasov on 11.11.14.
//  Copyright (c) 2014 Dmitry Vlasov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DVGitUser : NSObject

@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) NSURL *avatarURL;

- (DVGitUser *)initWithDictionary:(NSDictionary *)dictionary;

@end
