//
//  ViewController.m
//  Hunter
//
//  Created by Joy Tao on 2/9/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "ViewController.h"
#import "NewEntityViewController.h"
#import "GamesListViewController.h"
#import "SCSEnvironment.h"
@interface ViewController () <NewEntityControllerDelegate>

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.registerButton.hidden = ([[SCSEnvironment sharedInstance] hasRegisteredPlayer]) ? true :false;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if ([[SCSEnvironment sharedInstance] hasStartedGame] == true) {
//        [self.navigationController performSegueWithIdentifier:@"EnterGameSceneSegue" sender: self];
//    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions 

- (IBAction)startGame:(id)sender
{
    if ([[SCSEnvironment sharedInstance] hasRegisteredPlayer] == false)
        [self performSegueWithIdentifier:@"RegisterUserSegue" sender: self];
    else
        
        [self performSegueWithIdentifier:@"GetGamesSegue" sender: self];
}

- (IBAction)registerUser:(id)sender
{
    [self performSegueWithIdentifier:@"RegisterUserSegue" sender: self];

}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"RegisterUserSegue"])
    {
        NewEntityViewController * registeredUserViewController = [((UINavigationController*)segue.destinationViewController).viewControllers objectAtIndex:0];
        
        registeredUserViewController.delegate = self;
        registeredUserViewController.objectType = SCSCreateObjectTypeUser;
    }
}

#pragma mark -

- (void) didRegisterUser
{
    [self performSegueWithIdentifier:@"GetGamesSegue" sender: self];

}
@end
