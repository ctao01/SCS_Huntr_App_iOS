//
//  RegisterUserViewController.m
//  Hunter
//
//  Created by Joy Tao on 3/3/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "NewEntityViewController.h"
#import "EnvironmentConstants.h"
@interface NewEntityViewController ()

@end

@implementation NewEntityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.objectType == SCSCreateObjectTypeNewUser)
    {
        self.navigationItem.title = @"Register";
        self.descriptionLabel.text = @"Enter User Name";
        self.navigationItem.rightBarButtonItem.title = @"Submit";

    }
    else if (self.objectType == SCSCreateObjectTypeNewTeam)
    {
        self.navigationItem.title = @"New Team";
        self.descriptionLabel.text = @"Enter Team Name";
        self.navigationItem.rightBarButtonItem.title = @"Submit";

    }
    else if (self.objectType == SCSCreateObjectTypeUpdateUser)
    {
        self.navigationItem.title = @"Change User Name";
        self.descriptionLabel.text = @"Enter User Name";
        self.navigationItem.rightBarButtonItem.title = @"Submit";
        self.nameField.text = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentPlayerName];
        
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) saveBtnPressed :(id)sender
{
    NSString * nameFieldText = self.nameField.text;
    if (self.objectType == SCSCreateObjectTypeNewUser)
    {
        if (nameFieldText != nil && [nameFieldText length] > 0 && (![nameFieldText isEqualToString:@" "]))
        {
            if ([self.delegate respondsToSelector:@selector(registerUserDidSave:)]) {
                [self.delegate registerUserDidSave:self];
            }
        }
        else
        {
            [UIAlertController showAlertInViewController:self withTitle:@"Register" message:@"Player name can't be blank" cancelButtonTitle:@"Ok" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:nil];
        }
    }
    else if (self.objectType == SCSCreateObjectTypeNewTeam)
    {
        if (nameFieldText != nil && [nameFieldText length] > 0 && (![nameFieldText isEqualToString:@" "]))
        {
            if ([self.delegate respondsToSelector:@selector(newTeamWillAdd:completion:)]) {
                [self.delegate newTeamWillAdd:self completion:^(BOOL exist) {
                    if (!exist) {
                        if ([self.delegate respondsToSelector:@selector(newTeamDidAdd:)]) {
                            [self.delegate newTeamDidAdd:self];
                        }
                    }
                    else
                    {
                        [UIAlertController showAlertInViewController:self withTitle:@"Create Team" message:@"Team name has already taken." cancelButtonTitle:@"Ok" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:nil];
                    }
                }];
            }
        }
        
        else {
            [UIAlertController showAlertInViewController:self withTitle:@"Create Team" message:@"Team name can't be blank" cancelButtonTitle:@"Ok" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:nil];
        }
    }
    else if (self.objectType == SCSCreateObjectTypeUpdateUser)
    {
        if (nameFieldText != nil && [nameFieldText length] > 0 && (![nameFieldText isEqualToString:@" "]))
        {
            if ([self.delegate respondsToSelector:@selector(updateUserDidSave:)]) {
                [self.delegate updateUserDidSave:self];
            }
        }
        else
        {
            [UIAlertController showAlertInViewController:self withTitle:@"Change Name" message:@"Player name can't be blank" cancelButtonTitle:@"Ok" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:nil];
        }
    }
    
}

- (IBAction) cancelBtnPressed :(id)sender
{
    if (self.objectType == SCSCreateObjectTypeNewUser)
    {
        if ([self.delegate respondsToSelector:@selector(registerUserDidCancel:)]) {
            [self.delegate registerUserDidCancel:self];
        }
    }
    else if (self.objectType == SCSCreateObjectTypeNewTeam) {
        if ([self.delegate respondsToSelector:@selector(newTeamDidCancel:)]) {
            [self.delegate newTeamDidCancel:self];
        }
        
    }
    else if (self.objectType == SCSCreateObjectTypeUpdateUser) {
        if ([self.delegate respondsToSelector:@selector(updateUserDidCancel:)]) {
            [self.delegate updateUserDidCancel:self];
        }
        
    }
}

@end
