//
//  MainMenuViewController.m
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 8/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import "MainMenuViewController.h"
#import "AppInfoViewController.h"
#import "MyTeamsViewController.h"
#import "AnalysisViewController.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialisation
    }
    return self;
    
}
- (IBAction) appInfo:(id)sender {
    // Ensure the XIB name string EXACTLY matches the physical file name in Xcode
    AppInfoViewController *infoVC = [[AppInfoViewController alloc] initWithNibName:@"AppInfoViewController" bundle:nil];
    
    // Set style to partial curl
    infoVC.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    
    // Present the controller
    [self presentViewController:infoVC animated:YES completion:nil];
}

- (IBAction)helpPopup:(id)sender {
    // Create the classic iOS alert
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Any questions?"
                                                    message:@"I'm right here! Just ask me :)"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    // Display it on the screen
    [alert show];
}

- (IBAction)toHomeView:(id)sender{
    // Initialise individual screens from their now-linked XIBs
    MyTeamsViewController *teamsVC = [[MyTeamsViewController alloc] initWithNibName:@"MyTeamsViewController" bundle:nil];
    teamsVC.title = @"My Teams";
    
    // Set the Tab Bar Icon for My Teams
    teamsVC.tabBarItem.image = [UIImage imageNamed:@"tab-pokeball.png"];
    
    // Initialise Analysis
    AnalysisViewController *analysisVC = [[AnalysisViewController alloc] initWithNibName:@"AnalysisViewController" bundle:nil];
    analysisVC.title = @"Analysis";
    
    // Set the Tab Bar Icon for Analysis
    analysisVC.tabBarItem.image = [UIImage imageNamed:@"tab-analysis.png"];
    
    // Wrap MyTeams in a Navigation Controller so it has a top bar for the "Back" button
    UINavigationController *teamsNav = [[UINavigationController alloc] initWithRootViewController:teamsVC];
    
    // Create Tab Bar Controller and assign the tabs
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[teamsNav, analysisVC];
    
    // Set the Flip transition
    tabBarController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    // Present the Tab Bar over the Main Menu
    [self presentViewController:tabBarController animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
