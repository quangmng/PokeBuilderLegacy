//
//  AddPokemonViewController.h
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 10/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Team.h"

@interface AddPokemonViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

// The team we are currently adding a Pokémon to
@property (nonatomic, strong) Team *targetTeam;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

// This will hold the raw list of Pokémon names and API URLs we get from the internet
@property (nonatomic, strong) NSMutableArray *apiPokemonList;
@property (nonatomic, strong) NSMutableArray *filteredApiPokemonList;

@end