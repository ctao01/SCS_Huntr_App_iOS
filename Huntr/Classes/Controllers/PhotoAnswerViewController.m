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
    self.takePhotoButton.hidden = (self.selectedGame.status == SCSGameStatusInProgress) ? false : true;
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

    if (self.selectedGame.status == SCSGameStatusInProgress)
    {
        if (self.selectedClue.didSubmit) {
            {
                self.takePhotoButton.hidden = self.selectedClue.submittedAnswer.isCorrect;
                if (!self.selectedClue.submittedAnswer.isCorrect)
                {
                    [self.takePhotoButton setTitle:@"Retake Photo" forState:UIControlStateNormal];
                    
                }
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.selectedClue.submittedAnswer.answerImageUrl]];
                [self.answerImageView setImage:[UIImage imageWithData:imageData]];
            }
        }
        else
        {
            self.takePhotoButton.hidden = false;
            [self.takePhotoButton setTitle:@"Take Photo" forState:UIControlStateNormal];
        }
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
       [UIAlertController showAlertInViewController:self
                                            withTitle:@"Submit Answer"
                                              message:@"Your previous answer is still pending for review, if you re-submit an answer, the previous answer will be overwritten."
                                    cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@[@"Submit"] tapBlock:^(UIAlertController * controller, UIAlertAction * action, NSInteger buttonIndex) {
                                        if (buttonIndex == controller.cancelButtonIndex) {
                                            NSLog(@"cancel");
                                        }
                                        else {
                                            [[SCSHuntrClient sharedClient] postAnswer:self.answerPicture withClue:self.selectedClue successBlock:^(id response) {
                                                [self.navigationController popViewControllerAnimated:true];
                                            } failureBlock:nil];
                                        }
                                    }];
    }
    else
    {
        [[SCSHuntrClient sharedClient] postAnswer:self.answerPicture withClue:self.selectedClue successBlock:^(id response) {
            [self.navigationController popViewControllerAnimated:true];
        } failureBlock:nil];
    }
}

#pragma mark - UIImagePickerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.answerPicture = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        self.answerImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        self.answerImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.answerImageView.image = self.answerPicture;


    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
