//
//  TeamDetailsViewController.m
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 9/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import "TeamDetailsViewController.h"
#import "AddPokemonViewController.h" 

@implementation TeamDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Title should be set from previous screen, but let's be safe
    if (self.currentTeam) {
        self.title = self.currentTeam.name;
    }
    
    // Initialise the array (For now, it's empty. Later we load from DB)
    self.teamPokemon = [[NSMutableArray alloc] init];
    
    // Set up Nav Bar and Empty State check
    [self updateUIState];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // This ensures the table and background check themselves every time you
    // navigate back to this screen from the Add/Edit screens!
    [self.tableView reloadData];
    [self updateUIState];
}


// Handles the Empty State & the 6 Pokémon limit
- (void)updateUIState {
    
    // Handle the Empty State Image vs Table
    if (self.teamPokemon.count == 0) {
        self.tableView.hidden = YES;
        self.emptyStateImageView.hidden = NO;
    } else {
        self.tableView.hidden = NO;
        self.emptyStateImageView.hidden = YES;
    }
    
    // Handle the Navigation Bar Button (+ vs Edit)
    if (self.teamPokemon.count >= 6) {
        // Swap to an Edit button when full
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    } else {
        // Show the + button if they have room
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                   target:self
                                                                                   action:@selector(addPokemonTapped)];
        self.navigationItem.rightBarButtonItem = addButton;
    }
}

- (void)addPokemonTapped {
    AddPokemonViewController *addVC = [[AddPokemonViewController alloc] initWithNibName:@"AddPokemonViewController" bundle:nil];
    // Pass the team forward so it knows who to add the Pokemon to later!
    addVC.targetTeam = self.currentTeam;
    [self.navigationController pushViewController:addVC animated:YES];
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.teamPokemon.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PokemonCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        // Using UITableViewCellStyleDefault, which supports image + text
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Set the text
    cell.textLabel.text = @"Placeholder Pokemon";
    
    // Set the thumbnail image
    // (Make sure you drag a small 40x40 pixel placeholder PNG into your Xcode project)
    cell.imageView.image = [UIImage imageNamed:@"placeholder_sprite.png"];
    
    return cell;
}

#pragma mark - Deleting a Pokemon

// 1. Allow the rows to be swiped
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// 2. Handle the red "Delete" button tap
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // A. Remove the Pokemon from your RAM array
        [self.teamPokemon removeObjectAtIndex:indexPath.row];
        
        // B. (LATER) Run the SQLite update to clear this slot in the database!
        // [self.dbController updateTeam:self.currentTeam];
        
        // C. Animate the row disappearing
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        // D. Check the count!
        // If that was the last Pokemon, this instantly shows your background image.
        // If it dropped from 6 to 5, this instantly changes the 'Edit' button back to a '+'.
        [self updateUIState];
    }
}

@end
