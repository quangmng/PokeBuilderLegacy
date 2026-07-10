//
//  MyTeamsViewController.m
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 8/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import "MyTeamsViewController.h"
#import "DatabaseController.h" 
#import "TeamDetailsViewController.h"
#define kAlertTagAddTeam 101 
#define kAlertTagRenameTeam 102
#define kAlertTagDeleteTeam 103

@implementation MyTeamsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"My Teams";
    // search array init
    self.filteredTeams = [[NSMutableArray alloc] init];
    self.dbController = [[DatabaseController alloc] initWithDBName:@"PokemonData.sqlite"];
    
    // Load Team objects from SQLite
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
    
    self.navigationItem.leftBarButtonItem = backButton;
    
    // Create the standard "+" button
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(addNewTeam)];
    
    addButton.tintColor = buttonTint;
    self.navigationItem.rightBarButtonItem = addButton;

}

- (void)updateEmptyState {
    if (self.myTeams.count == 0) {
        // No teams? Show img, hide table
        self.emptyStateImageView.hidden = NO;
        self.tableView.hidden = YES;
    } else {
        // Teams exist! Hide img, show table
        self.emptyStateImageView.hidden = YES;
        self.tableView.hidden = NO;
    }
}

// This method is triggered when the button is tapped
- (void)returnToMainMenu {
    // This tells the app to dismiss the current modal (the Tab Bar) and flip back to what is underneath it
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Search Display Delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self.filteredTeams removeAllObjects];
    
    for (Team *team in self.myTeams) {
        // Search by team name, ignoring uppercase/lowercase
        NSRange range = [team.name rangeOfString:searchString options:NSCaseInsensitiveSearch];
        if (range.location != NSNotFound) {
            [self.filteredTeams addObject:team];
        }
    }
    return YES; // Tells the search table to reload
}

#pragma mark - Add teams

// Handling the "+" button tap
- (void)addNewTeam {
    UIAlertView *addAlert = [[UIAlertView alloc] initWithTitle:@"New Team"
                                                       message:@"Enter team name:"
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"OK", nil];
    
    addAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    addAlert.tag = kAlertTagAddTeam; // Tag it!
    [addAlert show];
}

#pragma mark - Action Sheet handling

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return; // Do nothing
    }
    
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        // Show Confirmation Alert
        UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:@"Delete Team"
                                                              message:@"Are you sure you want to delete this team?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:@"Delete", nil];
        deleteAlert.tag = kAlertTagDeleteTeam;
        [deleteAlert show];
        
    } else if (buttonIndex == 1) {
        // TEAM DETAILS TAPPED (Index 1) -> Push View Controller
        TeamDetailsViewController *detailVC = [[TeamDetailsViewController alloc] initWithNibName:@"TeamDetailsViewController" bundle:nil];
        detailVC.currentTeam = self.selectedTeam;
        
        [self.navigationController pushViewController:detailVC animated:YES];
        
    } else if (buttonIndex == 2) {
        // RENAME TAPPED (Index 2) -> Show Rename Alert
        UIAlertView *renameAlert = [[UIAlertView alloc] initWithTitle:@"Rename Team"
                                                              message:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:@"Save", nil];
        
        renameAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [renameAlert textFieldAtIndex:0].text = self.selectedTeam.name;
        renameAlert.tag = kAlertTagRenameTeam;
        [renameAlert show];
    }
}


#pragma mark - Table View Data Source (Displaying Teams)

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.filteredTeams.count;
    }
    return self.myTeams.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Teams";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        // Where the "Edit" button graphically lives
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // WHICH array do we pull from?
    Team *team = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        team = self.filteredTeams[indexPath.row];
    } else {
        team = self.myTeams[indexPath.row];
    }
    // Pull Team object out of array
    cell.textLabel.text = team.name;
    
    return cell;
    
}

#pragma mark - Renaming a Team (SQLite UPDATE)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Grab the correct team depending on if we are searching or not
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        self.selectedTeam = self.filteredTeams[indexPath.row];
    } else {
        self.selectedTeam = self.myTeams[indexPath.row];
    }
    
    // Create the Action Sheet
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Team Options"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete"
                                                    otherButtonTitles:@"Team Details", @"Rename", nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    // If they tapped Cancel on ANY alert, just bail out immediately.
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    
    if (alertView.tag == kAlertTagAddTeam) {
        // Adding
        NSString *newName = [alertView textFieldAtIndex:0].text;
        
        if (newName.length > 0) {
            NSInteger uniqueID = (NSInteger)[[NSDate date] timeIntervalSince1970];
            Team *newTeam = [[Team alloc] initWithID:uniqueID name:newName pokemonIDs:[[NSMutableArray alloc] init]];
            
            if ([self.dbController insertTeam:newTeam]) {
                [self.myTeams addObject:newTeam];
                [self.tableView reloadData];
                [self updateEmptyState];
            }
        }
        
    } else if (alertView.tag == kAlertTagRenameTeam) {
        // Renaming
        NSString *newName = [alertView textFieldAtIndex:0].text;
        Team *teamToRename = self.selectedTeam;
        
        if (newName.length > 0 && ![newName isEqualToString:teamToRename.name]) {
            teamToRename.name = newName;
            
            if ([self.dbController updateTeam:teamToRename]) {
                [self.tableView reloadData];
            }
        }
        
    } else if (alertView.tag == kAlertTagDeleteTeam) {
        // Deleting
        Team *teamToDelete = self.selectedTeam;
        
        if ([self.dbController deleteTeamByID:teamToDelete.teamID]) {
            
            // Ask array what number index this specific team at?
            NSUInteger rowNumber = [self.myTeams indexOfObject:teamToDelete];
            
            if (rowNumber != NSNotFound) {
                // Safely remove it using row number
                [self.myTeams removeObjectAtIndex:rowNumber];
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowNumber inSection:0];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            
            [self updateEmptyState];
        }
    }
}

@end