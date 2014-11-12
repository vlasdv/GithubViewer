//
//  DVUserDetailTableViewCell.h
//  GithubViewer
//
//  Created by Dmitrii Vlasov on 11.11.14.
//  Copyright (c) 2014 Dmitry Vlasov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DVUserDetailTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@end
