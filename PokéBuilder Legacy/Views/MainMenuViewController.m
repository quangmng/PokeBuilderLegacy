//
//  MainMenuViewController.m
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 8/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import "MainMenuViewController.h"
#import "AppInfoViewController.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    // If your project doesn't use ARC, release it:
    // [infoVC release];
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
