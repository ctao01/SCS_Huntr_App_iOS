//
//  PhotoAnswerViewController.m
//  Huntr
//
//  Created by Joy Tao on 4/27/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "PhotoAnswerViewController.h"

@interface PhotoAnswerViewController()< UINavigationControllerDelegate, UIImagePickerControllerDelegate >
@property (nonatomic , strong) UIImage * answerPicture;
@end

@implementation PhotoAnswerViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.clueTypeImageView.image = [UIImage imageNamed:@"Camera"];
    self.descriptionTextView.text = self.selectedClue.clueDescription;
    self.pointLabel.text = [NSString stringWithFormat:@"%i points",[self.selectedClue.pointValue intValue]];
    self.takePhotoButton.hidden = (self.selectedGame.status == GameStatusInProgress) ? false : true;
    if (self.selectedClue.submittedAnswer.isCorrect)
    {
        self.pointLabel.textColor = [UIColor colorWithRed:76.0/255.0f green:217.0/255.0f blue:100.0/255.0 alpha:1];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.selectedClue.submittedAnswer.answerImageUrl]];
        [self.answerImageView setImage:[UIImage imageWithData:imageData]];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.selectedClue.didSubmit) {
        [self.takePhotoButton setTitle:@"Retake Photo" forState:UIControlStateNormal];
        
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.selectedClue.submittedAnswer.answerImageUrl]];
        [self.answerImageView setImage:[UIImage imageWithData:imageData]];
    }
    else
    {
        [self.takePhotoButton setTitle:@"Take Photo" forState:UIControlStateNormal];
    }

}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (IBAction)takePhoto:(id)sender
{
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
#if TARGET_IPHONE_SIMULATOR
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
#else
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
#endif
    imagePickerController.editing = YES;
    imagePickerController.delegate = (id)self;
    [self  presentViewController:imagePickerController animated:YES completion:nil];

}

- (IBAction)submitAnswer:(id)sender
{
    if (self.selectedClue.didSubmit && self.selectedClue.submittedAnswer.isPending)
    {
        UIAlertController * ac = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Your previous answer is still pending for review, if you re-submit an answer, the previous answer will be overwritten." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * actionContinue = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *  action) {
            [[SCSHuntrClient sharedClient]postAnswer:self.answerPicture withClue:self.selectedClue.clueID type:@"Picture" successBlock:nil failureBlock:nil];
            [ac dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertAction * actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *  action) {
            [ac dismissViewControllerAnimated:YES completion:nil];

        }];
        [ac addAction:actionContinue];
        [ac addAction:actionCancel];

    }
    else
    {
        NSLog(@"%@",[self.answerPicture description]);
        [[SCSHuntrClient sharedClient]postAnswer:self.answerPicture withClue:self.selectedClue.clueID type:@"Picture" successBlock:nil failureBlock:nil];
    }
    
}

#pragma mark - UIImagePickerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.answerPicture = [info objectForKey:UIImagePickerControllerOriginalImage];

    [picker dismissViewControllerAnimated:YES completion:^{
        self.answerImageView.image = self.answerPicture;

    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
