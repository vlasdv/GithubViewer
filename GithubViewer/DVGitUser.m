//
//  DVGitUser.m
//  GithubViewer
//
//  Created by Dmitrii Vlasov on 11.11.14.
//  Copyright (c) 2014 Dmitry Vlasov. All rights reserved.
//

#import "DVGitUser.h"

@implementation DVGitUser

- (DVGitUser *)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.name = [dictionary objectForKey:@"login"];
        NSString *avatarString = [dictionary objectForKey:@"avatar_url"];
        self.avatarURL = [NSURL URLWithString:avatarString];
    }
    return self;
}

@end
