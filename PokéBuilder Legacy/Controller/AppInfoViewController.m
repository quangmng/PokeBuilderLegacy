//
//  AppInfoViewController.m
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 29/06/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import "AppInfoViewController.h"

@interface AppInfoViewController ()

@end

@implementation AppInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)hyperlinkQuang {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/quangmng/PokeBuilderLegacy"]];
}

- (IBAction)hyperlinkOG {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/TianLangHin/PokeCalc"]];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
