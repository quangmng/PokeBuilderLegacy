//
//  PokemonDetailsViewController.m
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 10/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import "PokemonDetailsViewController.h"
#import "TeamDetailsViewController.h"
#define kTagNatureActionSheet 101
#define kTagAbilityActionSheet 102

@interface PokemonDetailsViewController () <UIActionSheetDelegate>

@end

@implementation PokemonDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.pokemonName;
    // Force the backgrounds to be pure white so the overscroll bounce is clean
    self.view.backgroundColor = [UIColor whiteColor];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.contentSize = CGSizeMake(320, 800);
    [self fetchDeepPokemonStats];
    // Add the "Save" button to the top right
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(savePokemonToTeam)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
    // Populate text placeholders
    self.type1Label.text = @"Element";
    self.type2Label.text = @"Type";
    self.levelTextField.text = @"50";
    
    [self.abilityButton setTitle:@"Ability..." forState:UIControlStateNormal];
    [self.natureButton setTitle:@"Nature..." forState:UIControlStateNormal];
    [self.move1Button setTitle:@"Move 1..." forState:UIControlStateNormal];
    [self.move2Button setTitle:@"Move 2..." forState:UIControlStateNormal];
    [self.move3Button setTitle:@"Move 3..." forState:UIControlStateNormal];
    [self.move4Button setTitle:@"Move 4..." forState:UIControlStateNormal];
    
    // Set up EV text fields and sliders
    self.evHpTextField.text = @"0";
    self.evHpSlider.value = 0.0;
    self.evAtkTextField.text = @"252";
    self.evAtkSlider.value = 252.0;
    self.evAtkSlider.maximumValue = 252.0;
    self.evDefTextField.text = @"0";
    self.evDefSlider.value = 0.0;
    self.evSpATextField.text = @"0";
    self.evSpASlider.value = 0.0;
    self.evSpDTextField.text = @"4";
    self.evSpDSlider.value = 4.0;
    self.evSpeTextField.text = @"252";
    self.evSpeSlider.value = 252.0;
    self.evSpeSlider.maximumValue = 252.0;
    
    // Fetch the deep stats
    // [self fetchDeepPokemonStatsFromAPI];
    
    // BIND THE SPRITE IMAGE ASYNCHRONOUSLY
    [self loadAndBindSpriteForID:self.pokemonID];
}

#pragma mark - Ability Button & Picker Animations

- (IBAction)abilityButtonTapped:(id)sender {
    if (self.availableAbilities.count == 0) {
        NSLog(@"API data hasn't loaded yet, or failed!");
        return;
    }
    
    NSDictionary *firstAbility = self.availableAbilities[0];
    self.temporarySelectedAbility = [firstAbility[@"ability"][@"name"] capitalizedString];
    
    [self.abilityPickerView reloadAllComponents];
    [self.abilityPickerView selectRow:0 inComponent:0 animated:NO];
    
    // 1. Attach it to the Navigation Controller's view so it hovers over the glass!
    UIView *glassView = self.navigationController.view;
    
    if (!self.pickerContainerView.superview) {
        [glassView addSubview:self.pickerContainerView];
    }
    
    // 2. Base the math on the glassView, not the scrollView
    CGRect startFrame = self.pickerContainerView.frame;
    startFrame.origin.y = glassView.frame.size.height;
    self.pickerContainerView.frame = startFrame;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect endFrame = self.pickerContainerView.frame;
        endFrame.origin.y = glassView.frame.size.height - endFrame.size.height;
        self.pickerContainerView.frame = endFrame;
    }];
}

- (IBAction)cancelPickerTapped:(id)sender {
    UIView *glassView = self.navigationController.view;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.pickerContainerView.frame;
        frame.origin.y = glassView.frame.size.height; // Slide back down off the glass
        self.pickerContainerView.frame = frame;
    }];
}

- (IBAction)donePickerTapped:(id)sender {
    // Update the button title with the confirmed selection
    [self.abilityButton setTitle:self.temporarySelectedAbility forState:UIControlStateNormal];
    
    // Slide the picker back down off-screen
    [self cancelPickerTapped:nil];
}

#pragma mark - Picker View Data Source & Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1; // Just one single spinning column
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.availableAbilities.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSDictionary *abilityDict = self.availableAbilities[row];
    return [abilityDict[@"ability"][@"name"] capitalizedString];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    // Track the row the user stopped scrolling on
    NSDictionary *abilityDict = self.availableAbilities[row];
    self.temporarySelectedAbility = [abilityDict[@"ability"][@"name"] capitalizedString];
}

#pragma mark - Text Field Delegate (Keyboard Handling)

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    // When a text field is tapped, scroll it up by 216 pixels so the keyboard doesn't hide it
    CGPoint scrollPoint = CGPointMake(0, textField.frame.origin.y - 150); // 150 gives it a nice buffer
    [self.scrollView setContentOffset:scrollPoint animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // When the user hits "Return" on the keyboard, hide the keyboard
    [textField resignFirstResponder];
    
    // Scroll back to the top (or wherever looks best)
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    
    return YES;
}

#pragma mark - SQLite saving

- (void)savePokemonToTeam {
    // TODO: Build the final Pokemon object and save it to SQLite via DatabaseController
    NSLog(@"Saving %@ to Team: %@", self.pokemonName, self.targetTeam.name);
    
    // The Custom Pop: Skip the search screen and go straight back to TeamDetails
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[TeamDetailsViewController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
            return; // We found it and popped, so exit the method
        }
    }
    
    // Fallback just in case the stack is weird
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadAndBindSpriteForID:(NSInteger)pokemonID {
    // Determine local cache path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDir = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"sprite_%ld.png", (long)pokemonID];
    NSString *filePath = [cacheDir stringByAppendingPathComponent:fileName];
    
    // Load instantly from cache if available
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        self.spriteImageView.image = [UIImage imageWithContentsOfFile:filePath];
        return;
    }
    
    // Fallback to async download if not cached yet
    NSString *imageURLString = [NSString stringWithFormat:@"https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/%ld.png", (long)pokemonID];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURLString]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               if (connectionError) {
                                   NSLog(@"Detail View Sprite Download Error: %@", connectionError.localizedDescription);
                                   return;
                               }
                               
                               if (data) {
                                   UIImage *downloadedImage = [UIImage imageWithData:data];
                                   if (downloadedImage) {
                                       // Save to local cache for next time
                                       [data writeToFile:filePath atomically:YES];
                                       
                                       // Bind to UIImageView
                                       self.spriteImageView.image = downloadedImage;
                                       
                                       // Force UI layout pass to show the image cleanly
                                       [self.spriteImageView setNeedsLayout];
                                   }
                               }
                           }];
}

- (void)fetchDeepPokemonStats {
    // Hit the specific endpoint for this Pokémon
    NSString *urlString = [NSString stringWithFormat:@"https://pokeapi.co/api/v2/pokemon/%ld/", (long)self.pokemonID];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               if (connectionError) {
                                   NSLog(@"Deep Stats Error: %@", connectionError.localizedDescription);
                                   return;
                               }
                               
                               if (data) {
                                   NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                   
                                   if (json) {
                                       // Parse Types array and update UI labels
                                       NSArray *types = json[@"types"];
                                       if (types.count > 0) {
                                           NSString *firstType = types[0][@"type"][@"name"];
                                           [self styleTypeLabel:self.type1Label withType:firstType];
                                           
                                           if (types.count > 1) {
                                               NSString *secondType = types[1][@"type"][@"name"];
                                               [self styleTypeLabel:self.type2Label withType:secondType];
                                           } else {
                                               [self styleTypeLabel:self.type2Label withType:@""]; // Hide the second label if it's a pure type
                                           }
                                       }
                                       
                                       // Store the Abilities and Moves in RAM so our buttons can use them later
                                       self.availableAbilities = json[@"abilities"];
                                       self.availableMoves = json[@"moves"];
                                       
                                       NSLog(@"Successfully fetched deep stats! Found %lu moves.", (unsigned long)self.availableMoves.count);
                                   }
                               }
                           }];
}

// Returns the official colour for a given type
- (UIColor *)colorForPokemonType:(NSString *)type {
    NSString *lowerType = [type lowercaseString];
    
    if ([lowerType isEqualToString:@"normal"])   return [UIColor colorWithRed:0.66 green:0.65 blue:0.48 alpha:1.0];
    if ([lowerType isEqualToString:@"fire"])     return [UIColor colorWithRed:0.93 green:0.51 blue:0.19 alpha:1.0];
    if ([lowerType isEqualToString:@"water"])    return [UIColor colorWithRed:0.40 green:0.56 blue:0.94 alpha:1.0];
    if ([lowerType isEqualToString:@"grass"])    return [UIColor colorWithRed:0.47 green:0.78 blue:0.31 alpha:1.0];
    if ([lowerType isEqualToString:@"electric"]) return [UIColor colorWithRed:0.97 green:0.82 blue:0.17 alpha:1.0];
    if ([lowerType isEqualToString:@"ice"])      return [UIColor colorWithRed:0.59 green:0.85 blue:0.84 alpha:1.0];
    if ([lowerType isEqualToString:@"fighting"]) return [UIColor colorWithRed:0.76 green:0.18 blue:0.16 alpha:1.0];
    if ([lowerType isEqualToString:@"poison"])   return [UIColor colorWithRed:0.64 green:0.24 blue:0.63 alpha:1.0];
    if ([lowerType isEqualToString:@"ground"])   return [UIColor colorWithRed:0.89 green:0.75 blue:0.40 alpha:1.0];
    if ([lowerType isEqualToString:@"flying"])   return [UIColor colorWithRed:0.66 green:0.56 blue:0.95 alpha:1.0];
    if ([lowerType isEqualToString:@"psychic"])  return [UIColor colorWithRed:0.98 green:0.33 blue:0.53 alpha:1.0];
    if ([lowerType isEqualToString:@"bug"])      return [UIColor colorWithRed:0.66 green:0.73 blue:0.12 alpha:1.0];
    if ([lowerType isEqualToString:@"rock"])     return [UIColor colorWithRed:0.71 green:0.62 blue:0.22 alpha:1.0];
    if ([lowerType isEqualToString:@"ghost"])    return [UIColor colorWithRed:0.45 green:0.34 blue:0.59 alpha:1.0];
    if ([lowerType isEqualToString:@"dragon"])   return [UIColor colorWithRed:0.44 green:0.21 blue:0.99 alpha:1.0];
    if ([lowerType isEqualToString:@"dark"])     return [UIColor colorWithRed:0.44 green:0.34 blue:0.27 alpha:1.0];
    if ([lowerType isEqualToString:@"steel"])    return [UIColor colorWithRed:0.71 green:0.71 blue:0.81 alpha:1.0];
    if ([lowerType isEqualToString:@"fairy"])    return [UIColor colorWithRed:0.92 green:0.59 blue:0.65 alpha:1.0];
    
    return [UIColor lightGrayColor]; // Fallback
}

// Styles the label with a coloured background, white text, and rounded corners
- (void)styleTypeLabel:(UILabel *)label withType:(NSString *)type {
    if (type.length == 0) {
        label.hidden = YES;
        return;
    }
    
    label.hidden = NO;
    label.text = [type capitalizedString];
    label.backgroundColor = [self colorForPokemonType:type];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    // The QuartzCore magic for rounded corners
    label.layer.cornerRadius = 6.0f;
    label.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
