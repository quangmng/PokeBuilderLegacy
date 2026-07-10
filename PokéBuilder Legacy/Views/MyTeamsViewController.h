//
//  MyTeamsViewController.h
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 8/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseController.h"
#import "Team.h"

@interface MyTeamsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UISearchDisplayDelegate, UISearchBarDelegate>

// Create hooks for UI elements
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIImageView *emptyStateImageView;

@property (nonatomic, strong) NSMutableArray *myTeams;

@property (nonatomic, strong) DatabaseController *dbController;

@property (nonatomic, assign) Team *selectedTeam;

@property (nonatomic, strong) NSMutableArray *filteredTeams;


@end
