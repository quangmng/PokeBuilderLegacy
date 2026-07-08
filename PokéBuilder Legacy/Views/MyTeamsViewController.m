//
//  MyTeamsViewController.m
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 8/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import "MyTeamsViewController.h"
#import "DatabaseController.h" 

@implementation MyTeamsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dbController = [[DatabaseController alloc] initWithDBName:@"PokemonData.sqlite"];
    
    // 2. Load the actual Team objects from SQLite!
    NSArray *dbTeams = [self.dbController selectAllTeams];
    
    if (dbTeams) {
        self.myTeams = [dbTeams mutableCopy];
    } else {
        self.myTeams = [[NSMutableArray alloc] init];
    }
    
    [self updateEmptyState];
    
    // Create a classic bordered Bar Button Item
    UIColor *pokedexRed = [UIColor colorWithRed:0.8 green:0.1 blue:0.1 alpha:1.0];
    self.navigationController.navigationBar.tintColor = pokedexRed;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(returnToMainMenu)];
    
    UIColor *buttonTint = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    backButton.tintColor = buttonTint;
    
    
    // Place it on the left side of the navigation bar
    self.navigationItem.leftBarButtonItem = backButton;
    
    // Create the standard "+" Add button for the RIGHT side
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(addNewTeam)];
    
    // Tint it the same dark color so it matches your Back button
    addButton.tintColor = buttonTint;
    self.navigationItem.rightBarButtonItem = addButton;
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

- (void)updateEmptyState {
    if (self.myTeams.count == 0) {
        // No teams? Show the graphic, hide the table
        self.emptyStateImageView.hidden = NO;
        self.tableView.hidden = YES;
    } else {
        // Teams exist! Hide the graphic, show the table
        self.emptyStateImageView.hidden = YES;
        self.tableView.hidden = NO;
    }
}

// This method is triggered when the button is tapped
- (void)returnToMainMenu {
    // This tells the app to dismiss the current modal (the Tab Bar) and flip back to what is underneath it
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Handling the "+" button tap
- (void)addNewTeam {
    NSInteger uniqueID = (NSInteger)[[NSDate date] timeIntervalSince1970];
    Team *newTeam = [[Team alloc] initWithID:uniqueID
                                        name:@"New Custom Team"
                                  pokemonIDs:[[NSMutableArray alloc] init]];
    
    BOOL success = [self.dbController insertTeam:newTeam];
    
    if (success) {
        [self.myTeams addObject:newTeam];
        
        [self.tableView reloadData];
        [self updateEmptyState];
    } else {
        NSLog(@"SQLite Error: Could not insert team.");
    }
}



#pragma mark - Table View Data Source (Displaying Teams)

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.myTeams.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Teams";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        // THIS is where the "Edit" button graphically lives!
        // It puts a blue circle with an arrow on the right side of the cell.
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    
    // Pull the Team object out of the array
    Team *team = self.myTeams[indexPath.row];
    cell.textLabel.text = team.name;
    
    return cell;
}

#pragma mark - Renaming a Team (SQLite UPDATE)

// This method ONLY fires when they tap the blue Detail Disclosure button
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    self.teamIndexBeingRenamed = indexPath.row;
    Team *teamToRename = self.myTeams[indexPath.row];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rename Team"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Save", nil];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].text = teamToRename.name;
    
    [alert show];
}

// Handling the Save tap on the Alert
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // "Save"
        
        NSString *newName = [alertView textFieldAtIndex:0].text;
        Team *team = self.myTeams[self.teamIndexBeingRenamed];
        
        if (newName.length > 0 && ![newName isEqualToString:team.name]) {
            
            // 1. Update the model in RAM
            team.name = newName;
            
            // 2. Save the change using YOUR exact method
            BOOL success = [self.dbController updateTeam:team];
            
            if (success) {
                [self.tableView reloadData];
            } else {
                NSLog(@"SQLite Error: Could not update team.");
            }
        }
    }
}

#pragma mark - Deleting a Team (SQLite DELETE)

// Tell the table that rows can be swiped
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Handle the deletion event
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Team *teamToDelete = self.myTeams[indexPath.row];
        
        BOOL success = [self.dbController deleteTeamByID:teamToDelete.teamID];
        
        if (success) {
            [self.myTeams removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self updateEmptyState];
        } else {
            NSLog(@"SQLite Error: Could not delete team.");
        }
    }

}

@end