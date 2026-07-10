//
//  TeamDetailsViewController.h
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 9/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Team.h"

@interface TeamDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

// The data passed in from the My Teams screen
@property (nonatomic, strong) Team *currentTeam;

// UI Elements
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIImageView *emptyStateImageView;

// This will hold the actual Pokemon objects for this team
@property (nonatomic, strong) NSMutableArray *teamPokemon;

@end
