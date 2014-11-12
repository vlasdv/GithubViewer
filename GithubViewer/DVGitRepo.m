//
//  DVGitRepo.m
//  GithubViewer
//
//  Created by Dmitrii Vlasov on 12.11.14.
//  Copyright (c) 2014 Dmitry Vlasov. All rights reserved.
//

#import "DVGitRepo.h"

@implementation DVGitRepo

- (DVGitRepo *)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.name = [dictionary objectForKey:@"name"];
        
        if ([dictionary objectForKey:@"description"] != [NSNull null]) {
            self.repoDescription = [dictionary objectForKey:@"description"];
        } else {
            self.repoDescription = @"";
        }

    }
    
    return self;
}

@end
