//
//  PokemonDetailsViewController.m
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 10/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import "PokemonDetailsViewController.h"
#import "TeamDetailsViewController.h"

@implementation PokemonDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.pokemonName;
    // Force the backgrounds to be pure white so the overscroll bounce is clean
    self.view.backgroundColor = [UIColor whiteColor];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.contentSize = CGSizeMake(320, 800);
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
