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
    self.scrollView.clipsToBounds = YES;
    // Force the background to be white so the overscroll bounce is clean
    self.view.backgroundColor = [UIColor whiteColor];
    self.scrollView.contentSize = CGSizeMake(320, 765);
    UIView *glassView = self.navigationController.view;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.pickerContainerView.frame;
        frame.origin.y = glassView.frame.size.height; // Slide back down off the glass
        self.pickerContainerView.frame = frame;
    }];
    // Keyboard Toolbar Setup
    // Create a standard toolbar that matches the width of the screen
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    keyboardToolbar.barStyle = UIBarStyleBlackTranslucent; // Matches the iOS 6 aesthetic
    
    // Create a flexible space and a Done button
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)];
    
    // Add them to the toolbar
    keyboardToolbar.items = @[flexSpace, doneBtn];
    
    // Tap outside keypad to dismiss
    UITapGestureRecognizer *tapToDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.scrollView addGestureRecognizer:tapToDismiss];
    
    // Attach the toolbar to every single text field that uses a number pad
    self.levelTextField.inputAccessoryView = keyboardToolbar;
    self.evHpTextField.inputAccessoryView = keyboardToolbar;
    self.evAtkTextField.inputAccessoryView = keyboardToolbar;
    self.evDefTextField.inputAccessoryView = keyboardToolbar;
    self.evSpATextField.inputAccessoryView = keyboardToolbar;
    self.evSpDTextField.inputAccessoryView = keyboardToolbar;
    self.evSpeTextField.inputAccessoryView = keyboardToolbar;
    
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
    
    [self.abilityButton setTitle:@"Ability..." forState:UIControlStateNormal];
    [self.natureButton setTitle:@"Nature..." forState:UIControlStateNormal];
    [self.move1Button setTitle:@"Move 1..." forState:UIControlStateNormal];
    [self.move2Button setTitle:@"Move 2..." forState:UIControlStateNormal];
    [self.move3Button setTitle:@"Move 3..." forState:UIControlStateNormal];
    [self.move4Button setTitle:@"Move 4..." forState:UIControlStateNormal];
    
    // Group all the sliders together
    NSArray *evSliders = @[self.evHpSlider, self.evAtkSlider, self.evDefSlider,
                           self.evSpASlider, self.evSpDSlider, self.evSpeSlider];
    
    // Loop through and configure every slider identically in one sweep
    for (UISlider *slider in evSliders) {
        slider.minimumValue = 0.0f;
        slider.maximumValue = 252.0f;
        slider.value = 0.0f;
    }
    
    // Group all the text fields together
    NSArray *evTextFields = @[self.evHpTextField, self.evAtkTextField, self.evDefTextField,
                              self.evSpATextField, self.evSpDTextField, self.evSpeTextField];
    
    // Loop through and set the default starting text
    for (UITextField *textField in evTextFields) {
        textField.text = @"0";
    }
    
    // --- 2. SET UP THE LEVEL LIMITS ---
    // Level has no slider, so we just set its default text here
    self.levelTextField.text = @"50";
    
    self.staticNatures = @[
                           @"Adamant", @"Bashful", @"Bold", @"Brave", @"Calm",
                           @"Careful", @"Docile", @"Gentle", @"Hardy", @"Hasty",
                           @"Impish", @"Jolly", @"Lax", @"Lonely", @"Mild",
                           @"Modest", @"Naive", @"Naughty", @"Quiet", @"Quirky",
                           @"Rash", @"Relaxed", @"Sassy", @"Serious", @"Timid"
                           ];
    
    // Force the picker container completely off-screen downwards on launch
    CGRect pickerFrame = self.pickerContainerView.frame;
    pickerFrame.origin.y = 1000; // Throw it way down past the screen boundary
    self.pickerContainerView.frame = pickerFrame;
    
    [self loadAndBindSpriteForID:self.pokemonID];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 1. Force the controller's main view to match the full window frame
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self.view.frame = screenBounds;
    
    // 2. Force the scroll view to fill the entire physical screen area
    // This ensures its touch-intercepting frame isn't squished!
    self.scrollView.frame = self.view.bounds;
    
    // 3. Keep your massive scrollable paper height intact
    self.scrollView.contentSize = CGSizeMake(320, 850);
    
    // 4. Double check the picker container is completely out of the touch hierarchy on launch
    if (self.pickerContainerView.superview) {
        [self.pickerContainerView removeFromSuperview];
    }
}

#pragma mark - Text field
- (void)dismissKeyboard {
    // Tells iOS whatever text field currently active and stop edit
    [self.view endEditing:YES];
}

#pragma mark - EV Slider & Text Field Binding

// Triggers when user drags a slider
- (IBAction)evSliderValueChanged:(UISlider *)sender {
    // Float to integer, as EVs are whole
    NSInteger evValue = (NSInteger)sender.value;
    NSString *evString = [NSString stringWithFormat:@"%ld", (long)evValue];
    
    // Route the value to the corresponding text field
    if (sender == self.evHpSlider)       self.evHpTextField.text = evString;
    else if (sender == self.evAtkSlider) self.evAtkTextField.text = evString;
    else if (sender == self.evDefSlider) self.evDefTextField.text = evString;
    else if (sender == self.evSpASlider) self.evSpATextField.text = evString;
    else if (sender == self.evSpDSlider) self.evSpDTextField.text = evString;
    else if (sender == self.evSpeSlider) self.evSpeTextField.text = evString;
}

// Triggers real-time as user types in a text field
- (IBAction)evTextFieldEdited:(UITextField *)sender {
    NSInteger evValue = [sender.text integerValue];
    
    // Caps at 252 for competitive Pokémon
    if (evValue > 252) {
        evValue = 252;
        sender.text = @"252"; // overwrite typo
    } else if (evValue < 0) {
        evValue = 0;
        sender.text = @"0";
    }
    
    // Route typed value back to corresponding slider
    if (sender == self.evHpTextField)       self.evHpSlider.value = evValue;
    else if (sender == self.evAtkTextField) self.evAtkSlider.value = evValue;
    else if (sender == self.evDefTextField) self.evDefSlider.value = evValue;
    else if (sender == self.evSpATextField) self.evSpASlider.value = evValue;
    else if (sender == self.evSpDTextField) self.evSpDSlider.value = evValue;
    else if (sender == self.evSpeTextField) self.evSpeSlider.value = evValue;
}

#pragma mark - Universal Button & Picker Animations

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
    [self.activePickerButton setTitle:self.temporarySelectedString forState:UIControlStateNormal];
    
    // Slide away
    [self cancelPickerTapped:nil];
}

- (IBAction)openPickerForButton:(UIButton *)sender {
     [self.view endEditing:YES]; // Hides numpad (if editing text)

     // Safety checks for API data
     if (sender == self.abilityButton && self.availableAbilities.count == 0) return;
     if ((sender == self.move1Button || sender == self.move2Button || sender == self.move3Button || sender == self.move4Button) && self.availableMoves.count == 0) return;

     // Remember which button called us
     self.activePickerButton = sender;

     // Reload the wheel with the correct data and reset it to the top
     [self.unifiedPickerView reloadAllComponents];
     [self.unifiedPickerView selectRow:0 inComponent:0 animated:NO];

     // Force the temporary string to grab the very first item just in case the user doesn't spin the wheel
     [self pickerView:self.unifiedPickerView didSelectRow:0 inComponent:0];

     // Slide it up over the glass!
     UIView *glassView = self.navigationController.view;
     if (!self.pickerContainerView.superview) {
         [glassView addSubview:self.pickerContainerView];
     }

     CGRect startFrame = self.pickerContainerView.frame;
     startFrame.origin.y = glassView.frame.size.height;
     self.pickerContainerView.frame = startFrame;

     [UIView animateWithDuration:0.3 animations:^{
         CGRect endFrame = self.pickerContainerView.frame;
         endFrame.origin.y = glassView.frame.size.height - endFrame.size.height;
         self.pickerContainerView.frame = endFrame;
     }];
}

#pragma mark - Picker View Data Source & Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.activePickerButton == self.natureButton) return self.staticNatures.count;
    if (self.activePickerButton == self.abilityButton) return self.availableAbilities.count;
    return self.availableMoves.count; // For all 4 move buttons
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self textForActivePickerAtRow:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    // Save the text of whatever row they stop on
    self.temporarySelectedString = [self textForActivePickerAtRow:row];
}

- (NSString *)textForActivePickerAtRow:(NSInteger)row {
    if (self.activePickerButton == self.natureButton) {
        return self.staticNatures[row];
    } else if (self.activePickerButton == self.abilityButton) {
        return [self.availableAbilities[row][@"ability"][@"name"] capitalizedString];
    } else {
        // If it's not Nature or Ability, it MUST be one of the four Move buttons
        return [self.availableMoves[row][@"move"][@"name"] capitalizedString];
    }
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
    // 1. Gather the Basic Stats
    // Fallback to 50 if they left the level field blank
    NSInteger level = self.levelTextField.text.length > 0 ? [self.levelTextField.text integerValue] : 50;
    
    NSString *nature = self.natureButton.titleLabel.text;
    NSString *ability = self.abilityButton.titleLabel.text;
    
    // 2. Gather the Effort Values (EVs)
    // We cast the slider floats to integers since EVs are whole numbers
    NSInteger hpEV = (NSInteger)self.evHpSlider.value;
    NSInteger atkEV = (NSInteger)self.evAtkSlider.value;
    NSInteger defEV = (NSInteger)self.evDefSlider.value;
    NSInteger spaEV = (NSInteger)self.evSpASlider.value;
    NSInteger spdEV = (NSInteger)self.evSpDSlider.value;
    NSInteger speEV = (NSInteger)self.evSpeSlider.value;
    
    // 3. Gather the Moves (Assuming you wired these up similar to the Ability/Nature buttons!)
    NSString *move1 = self.move1Button.titleLabel.text;
    NSString *move2 = self.move2Button.titleLabel.text;
    NSString *move3 = self.move3Button.titleLabel.text;
    NSString *move4 = self.move4Button.titleLabel.text;
    
    // --- DEBUG LOGGING ---
    NSLog(@"💾 SAVING POKEMON TO TEAM: %@", self.targetTeam.name);
    NSLog(@"Name: %@ (Level %ld)", self.pokemonName, (long)level);
    NSLog(@"Ability: %@ | Nature: %@", ability, nature);
    NSLog(@"Moves: [%@, %@, %@, %@]", move1, move2, move3, move4);
    NSLog(@"EVs - HP:%ld Atk:%ld Def:%ld SpA:%ld SpD:%ld Spe:%ld", (long)hpEV, (long)atkEV, (long)defEV, (long)spaEV, (long)spdEV, (long)speEV);
    
    
    // 4. TODO: Execute your SQLite INSERT query here using your DatabaseController!
    // [DatabaseController insertPokemon:self.pokemonName level:level ... intoTeam:self.targetTeam.teamID];
    
    
    // 5. The Custom Pop: Skip the search screen and jump straight back to TeamDetails
    for (UIViewController *controller in self.navigationController.viewControllers) {
        // We use NSClassFromString to avoid having to #import TeamDetailsViewController.h if it causes a circular loop
        if ([controller isKindOfClass:NSClassFromString(@"TeamDetailsViewController")]) {
            [self.navigationController popToViewController:controller animated:YES];
            return; // Exit the loop and the method
        }
    }
    
    // Fallback if the navigation stack is weird
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
