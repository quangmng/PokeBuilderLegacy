//
//  PokemonDetailsViewController.h
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 10/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Team.h"
// #import "DatabaseController.h" // We will need this to save later!

// Add UITextFieldDelegate so keyboard can hide when user hits "Return"
@interface PokemonDetailsViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, assign) NSInteger pokemonID;
@property (nonatomic, strong) NSString *pokemonName;
@property (nonatomic, strong) Team *targetTeam;

// Main container
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

// Header
@property (nonatomic, weak) IBOutlet UIImageView *spriteImageView;
@property (nonatomic, weak) IBOutlet UILabel *type1Label;
@property (nonatomic, weak) IBOutlet UILabel *type2Label;
@property (nonatomic, weak) IBOutlet UITextField *levelTextField;

// Ability & Nature (Using Buttons to trigger a picker later)
@property (nonatomic, weak) IBOutlet UIButton *abilityButton;
@property (nonatomic, weak) IBOutlet UIButton *natureButton;

// Moves (2x2 Grid) ---
@property (nonatomic, weak) IBOutlet UIButton *move1Button;
@property (nonatomic, weak) IBOutlet UIButton *move2Button;
@property (nonatomic, weak) IBOutlet UIButton *move3Button;
@property (nonatomic, weak) IBOutlet UIButton *move4Button;

// Effort Values (EVs)
// Text Fields
@property (nonatomic, weak) IBOutlet UITextField *evHpTextField;
@property (nonatomic, weak) IBOutlet UITextField *evAtkTextField;
@property (nonatomic, weak) IBOutlet UITextField *evDefTextField;
@property (nonatomic, weak) IBOutlet UITextField *evSpATextField;
@property (nonatomic, weak) IBOutlet UITextField *evSpDTextField;
@property (nonatomic, weak) IBOutlet UITextField *evSpeTextField;

// Sliders
@property (nonatomic, weak) IBOutlet UISlider *evHpSlider;
@property (nonatomic, weak) IBOutlet UISlider *evAtkSlider;
@property (nonatomic, weak) IBOutlet UISlider *evDefSlider;
@property (nonatomic, weak) IBOutlet UISlider *evSpASlider;
@property (nonatomic, weak) IBOutlet UISlider *evSpDSlider;
@property (nonatomic, weak) IBOutlet UISlider *evSpeSlider;

@end
