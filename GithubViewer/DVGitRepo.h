//
//  DVGitRepo.h
//  GithubViewer
//
//  Created by Dmitrii Vlasov on 12.11.14.
//  Copyright (c) 2014 Dmitry Vlasov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DVGitRepo : NSObject

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *repoDescription;

- (DVGitRepo *)initWithDictionary:(NSDictionary *)dictionary;

@end
