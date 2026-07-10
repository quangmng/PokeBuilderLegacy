//
//  AddPokemonViewController.m
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 10/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import "AddPokemonViewController.h"
#import "PokemonDetailsViewController.h"

@interface AddPokemonViewController ()

@end

@implementation AddPokemonViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialisation
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Add Pokémon";
    
    // Initialise arrays
    self.apiPokemonList = [[NSMutableArray alloc] init];
    self.filteredApiPokemonList = [[NSMutableArray alloc] init];
    
    // Fetch the master list of 1000 names from the API
    [self fetchPokemonListFromAPI];
}

// HELPER: Chops the ID out of "https://pokeapi.co/api/v2/pokemon/25/"
- (NSInteger)extractPokemonIDFromURL:(NSString *)urlString {
    NSArray *components = [urlString componentsSeparatedByString:@"/"];
    if (components.count >= 2) {
        // The ID is always the second-to-last item before the final trailing slash
        NSString *idString = components[components.count - 2];
        return [idString integerValue];
    }
    return 0;
    
}

- (void)fetchPokemonListFromAPI {
    // Set the URL (Asking for 1000 Pokemon)
    NSURL *url = [NSURL URLWithString:@"https://pokeapi.co/api/v2/pokemon?limit=1000"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // Fire the asynchronous network request
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               if (connectionError) {
                                   // NETWORK FAILED: Show the user a warning
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                                                   message:@"Could not connect to PokéAPI. Please check your internet connection."
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"OK"
                                                                         otherButtonTitles:nil];
                                   [alert show];
                                   return;
                               }
                               
                               if (data) {
                                   // NETWORK SUCCESS: Parse the JSON
                                   NSError *jsonError;
                                   NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                                   
                                   if (!jsonError) {
                                       // PokéAPI puts the actual list inside an array called "results"
                                       NSArray *results = jsonDict[@"results"];
                                       
                                       // Store it in our RAM array
                                       self.apiPokemonList = [results mutableCopy];
                                       
                                       // Reload the table so the names appear
                                       [self.tableView reloadData];
                                   } else {
                                       NSLog(@"JSON Parsing Error: %@", jsonError.localizedDescription);
                                   }
                               }
                           }];
}

#pragma mark - Search Display Delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self.filteredApiPokemonList removeAllObjects];
    
    for (NSDictionary *pokemonDict in self.apiPokemonList) {
        NSString *name = pokemonDict[@"name"];
        
        // Check if the search string matches the name
        if ([name rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [self.filteredApiPokemonList addObject:pokemonDict];
        }
    }
    return YES;
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.filteredApiPokemonList.count;
    }
    return self.apiPokemonList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"AddPokemonCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Get the dictionary from the correct array
    NSDictionary *pokemonDict = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        pokemonDict = self.filteredApiPokemonList[indexPath.row];
    } else {
        pokemonDict = self.apiPokemonList[indexPath.row];
    }
    
    // Set the name (capitalised)
    cell.textLabel.text = [pokemonDict[@"name"] capitalizedString];
    
    // Set the placeholder and kick off the lazy load!
    UIImage *placeholder = [UIImage imageNamed:@"placeholder_sprite.png"];
    
    if (placeholder) {
        cell.imageView.image = placeholder;
    } else {
        // No file? Force iOS to draw a blank 40x40 box so it reserves the layout space
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(40, 40), NO, 0.0);
        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    NSInteger pkmnID = [self extractPokemonIDFromURL:pokemonDict[@"url"]];
    [self loadCachedOrFetchImageForID:pkmnID intoCell:cell];
    
    return cell;
}

- (void)loadCachedOrFetchImageForID:(NSInteger)pokemonID intoCell:(UITableViewCell *)cell {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDir = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"sprite_%ld.png", (long)pokemonID];
    NSString *filePath = [cacheDir stringByAppendingPathComponent:fileName];
    
    // Checking cache 1st
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        cell.imageView.image = [UIImage imageWithContentsOfFile:filePath];
        return;
    }
    
    // Network fetch
    NSString *imageURLString = [NSString stringWithFormat:@"https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/%ld.png", (long)pokemonID];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURLString]];
    
    // Use NSURLConnection to catch potential SSL/TLS errors
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               if (connectionError) {
                                   NSLog(@"Sprite Download Error for ID %ld: %@", (long)pokemonID, connectionError.localizedDescription);
                                   return;
                               }
                               
                               if (data) {
                                   // Save to disk
                                   [data writeToFile:filePath atomically:YES];
                                   
                                   // Update the UI
                                   cell.imageView.image = [UIImage imageWithData:data];
                                   
                                   // CRITICAL: Force the cell to recalculate its layout now that it has a real image
                                   [cell setNeedsLayout];
                               }
                           }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Figure out which dictionary we tapped
    NSDictionary *pokemonDict = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        pokemonDict = self.filteredApiPokemonList[indexPath.row];
    } else {
        pokemonDict = self.apiPokemonList[indexPath.row];
    }
    
    // Extract the ID
    NSInteger pkmnID = [self extractPokemonIDFromURL:pokemonDict[@"url"]];
    
    // Push to the new Details screen
    PokemonDetailsViewController *detailsVC = [[PokemonDetailsViewController alloc] initWithNibName:@"PokemonDetailsViewController" bundle:nil];
    
    // Pass the data forward
    detailsVC.pokemonID = pkmnID;
    detailsVC.pokemonName = [pokemonDict[@"name"] capitalizedString];
    detailsVC.targetTeam = self.targetTeam;
    
    [self.navigationController pushViewController:detailsVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
