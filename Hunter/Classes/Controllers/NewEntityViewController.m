//
//  RegisterUserViewController.m
//  Hunter
//
//  Created by Joy Tao on 3/3/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "NewEntityViewController.h"

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
    if (self.objectType == SCSCreateObjectTypeUser)
    {
        self.navigationItem.title = @"Register";
        self.descriptionLabel.text = @"Enter User Name";
        self.navigationItem.rightBarButtonItem.title = @"Start";

    }
    else if (self.objectType == SCSCreateObjectTypeTeam)
    {
        self.navigationItem.title = @"New Team";
        self.descriptionLabel.text = @"Enter Team Name";
        self.navigationItem.rightBarButtonItem.title = @"Add";

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerUserSaved:(id)sender
{
    NSString * nameFieldText = self.nameField.text;
    if (self.objectType == SCSCreateObjectTypeUser)
    {
        if (nameFieldText != nil || [nameFieldText length] > 0)
        {
            [[NSUserDefaults standardUserDefaults]setObject:nameFieldText forKey:@"current_player"];
            if([self.delegate respondsToSelector:@selector(didRegisterUser)])
                [self.delegate didRegisterUser];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else
    {
        if (nameFieldText != nil || [nameFieldText length] > 0)
        {
            if([self.delegate respondsToSelector:@selector(willValidateNewTeam:completion:)])
                [self.delegate willValidateNewTeam:nameFieldText completion:^(BOOL exists){
                    if (exists == false) {
                        if ([self.delegate respondsToSelector:@selector(willCreateNewTeam:)])
                            [self.delegate willCreateNewTeam:nameFieldText];
                    }
                    else
                    {
                        NSLog(@"EXISTS");
                    }
                }];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
}

- (IBAction)registerUserCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
