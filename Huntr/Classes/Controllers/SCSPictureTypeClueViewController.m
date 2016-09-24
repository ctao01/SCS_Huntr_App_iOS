//
//  SCSPictureTypeClueViewController.m
//  Huntr
//
//  Created by Joy Tao on 8/23/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "SCSPictureTypeClueViewController.h"
#import "SCSCameraViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface SCSPictureTypeClueViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate>
{
    BOOL retakePhotoAction;
    BOOL pickingPhotoFromLocalLibrary;
}

@property (nonatomic, weak) IBOutlet UIButton * flashButton;
@property (nonatomic, weak) IBOutlet UIButton * switchButton;
@property (nonatomic, weak) IBOutlet UIButton * getPhotoButton;

@property (nonatomic, weak) IBOutlet UIView * cameraView;
@property (nonatomic, strong) SCSCameraViewController * vcCustomCamera;

@property (nonatomic, weak) IBOutlet UIScrollView * answerScrollView;
@property (nonatomic, weak) IBOutlet UIImageView * answerImageView;


@end

@implementation SCSPictureTypeClueViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self.navigationController.navigationBar setTransparentStyle];
    
    self.automaticallyAdjustsScrollViewInsets = NO; // Key
        
    self.answerScrollView.maximumZoomScale = 6.0;
    self.answerScrollView.delegate = self;
    
    self.answerImageView.contentMode = UIViewContentModeScaleAspectFill;
//    if (self.selectedClue.clueState == SCSClueStateUnawswered || self.selectedClue.clueState == SCSClueStateUnknown)
//    {
//        [self performSegueWithIdentifier:kGetCustomCamera sender:self];
//    }
    retakePhotoAction = false;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.selectedClue.clueState == SCSClueStateAnswerPendingReview ||
        self.selectedClue.clueState == SCSClueStateAnswerAccepted ||
        self.selectedClue.clueState == SCSClueStateAnswerRejected) {
        
        [SVProgressHUD show];
        [self displayCamaraCaptureScreen:false withAnimated:false withCompletion:^{
            if (pickingPhotoFromLocalLibrary == NO) {
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.selectedClue.submittedAnswer.answerImageUrl]];
                [self.answerImageView setImage:[UIImage imageWithData:imageData]];
            }
            pickingPhotoFromLocalLibrary = NO;
            [SVProgressHUD dismiss];
        }];
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

#pragma mark - Segue Methods

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kGetCustomCamera]) {
        self.vcCustomCamera = segue.destinationViewController;
    }
}


#pragma mark - Button Actions

- (IBAction) flashButtonPressed:(UIButton *)button
{
    if(self.vcCustomCamera.camera.flash == LLCameraFlashOff) {
        BOOL done = [self.vcCustomCamera.camera updateFlashMode:LLCameraFlashOn];
        if(done) {
            self.flashButton.selected = YES;
            self.flashButton.tintColor = [UIColor yellowColor];
        }
    }
    else {
        BOOL done = [self.vcCustomCamera.camera updateFlashMode:LLCameraFlashOff];
        if(done) {
            self.flashButton.selected = NO;
            self.flashButton.tintColor = [UIColor whiteColor];
        }
    }
}

- (IBAction) switchButtonPressed:(UIButton *)button
{
    [self.vcCustomCamera.camera togglePosition];
}

- (void) chooseFromGallery:(id)sender
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = (id)self;
    
    pickingPhotoFromLocalLibrary = YES;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (IBAction)getPhotoButtonPressed:(id)sender
{
    if (self.cameraView.alpha == 1)
    {
        // choose from lib
        [self chooseFromGallery:sender];

        
    }
    else
    {
        if ((self.selectedClue.clueState == SCSClueStateAnswerRejected && retakePhotoAction == false) || (self.selectedClue.clueState == SCSClueStateAnswerPendingReview && retakePhotoAction == false)) {
            [UIAlertController showAlertInViewController:self withTitle:@"Huntr" message:@"Are you sure to resubmit the answer." cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@[@"Yes"] tapBlock:^(UIAlertController * controller, UIAlertAction * action, NSInteger buttonIndex) {
                if (buttonIndex == controller.firstOtherButtonIndex) {
                    retakePhotoAction = true;
                    [self.vcCustomCamera.camera start];
                    [self displayCamaraCaptureScreen:true withAnimated:true withCompletion:nil];
                }
            }];
        }
        else
        {
            [self.vcCustomCamera.camera start];
            [self displayCamaraCaptureScreen:true withAnimated:true withCompletion:nil];
        }
        
    }
}

- (IBAction) buttonPressed:(UIButton *)buttton
{
    if (self.cameraView.alpha == 1)
    {
        [self snapButtonPressed: buttton];
    }
    else
    {
        [self submitButtonPressed:buttton];
    }
}


- (void)snapButtonPressed:(UIButton *)button
{
    [self.vcCustomCamera.camera capture:^(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
        if(!error) {
            
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            self.answerImageView.contentMode = UIViewContentModeScaleAspectFill;
            self.answerImageView.image = image;
            
            [self displayCamaraCaptureScreen:false withAnimated:true withCompletion:^{
                self.roundButton.backgroundColor = [UIColor colorWithRed:246.0f/255.0f green:78.0f/255.0f blue:77.0f/255.0f alpha:0.8f];
                [self.roundButton setTitle:@"Submit" forState:UIControlStateNormal];
                [self.roundButton setTintColor:[UIColor whiteColor]];
                
            }];
        }
        else {
            NSLog(@"An error has occured: %@", error);
        }
    } exactSeenImage:YES];
    
}

- (void) submitButtonPressed:(UIButton *)button
{
    [UIAlertController showAlertInViewController:self withTitle:@"Huntr Notification" message:@"Are you sure to submit the answer?"  cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@[@"Yes"] tapBlock:^(UIAlertController * controller, UIAlertAction * action, NSInteger buttonIndex) {
        if( buttonIndex == controller.firstOtherButtonIndex )
        {
            [SVProgressHUD show];
            [[SCSHuntrClient sharedClient] postAnswer:[self.answerImageView image]
                                             withClue:self.selectedClue successBlock:^(id response) {
                                                 [SVProgressHUD dismiss];
                                                 [self.navigationController popViewControllerAnimated: YES];

                                             } failureBlock:^(NSString * errorString) {
                                                 [SVProgressHUD dismiss];

                                                 [UIAlertController showAlertInViewController:self withTitle:@"Error" message:@"Oops! Something wrong" cancelButtonTitle:@"Ok" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:nil];
                                             }];
        }
    }];
}

- (void) displayCamaraCaptureScreen:(BOOL)willDisplay withAnimated:(BOOL)isAnimated withCompletion:(void (^)(void))completion
{
    NSTimeInterval duration = (isAnimated) ? 0.4f: 0.0f;
    
    if ( willDisplay == true )
    {
        [UIView animateWithDuration:duration animations:^{
            
            self.answerScrollView.alpha = 0;
            self.roundButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
            [self.roundButton setTitle:@"" forState:UIControlStateNormal];
            self.roundButton.alpha = 1;
            
            self.cameraView.alpha = 1;
            self.flashButton.alpha = 1;
            self.switchButton.alpha = 1;
//            self.getPhotoButton.alpha = 1;
            [self.getPhotoButton setImage:[UIImage imageNamed:@"photo-gallery"]
                                 forState:UIControlStateNormal];
            
        }];
    }
    else
    {
        [UIView animateWithDuration:duration animations:^{

            self.cameraView.alpha = 0;
            self.flashButton.alpha = 0;
            self.switchButton.alpha = 0;
//            self.getPhotoButton.alpha = 0;
            
            if (self.selectedClue.clueState != SCSClueStateUnawswered) {
                self.roundButton.alpha = 0;
                if (retakePhotoAction == true) {
                    self.roundButton.alpha = 1;
                }
            }
            
            if (self.selectedClue.clueState == SCSClueStateAnswerAccepted || self.selectedGame.status == SCSGameStatusCompleted) {
                self.getPhotoButton.alpha = 0;
            }
            
            self.answerScrollView.contentSize = self.answerImageView.image.size;
            self.answerScrollView.alpha = 1;
            [self.getPhotoButton setImage:[UIImage imageNamed:@"camera_mode"] forState:UIControlStateNormal];

        } completion:^(BOOL finished) {
            if (completion)
                completion();
        }];
        
    }
}

#pragma mark - UIScrollView Delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.answerImageView;
}

#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSLog(@"Choose a picture from gallery: %@", info);
    self.answerImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.answerImageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self displayCamaraCaptureScreen:false withAnimated:true withCompletion:^{
            self.roundButton.backgroundColor = [UIColor colorWithRed:246.0f/255.0f green:78.0f/255.0f blue:77.0f/255.0f alpha:0.8f];
            [self.roundButton setTitle:@"Submit" forState:UIControlStateNormal];
            [self.roundButton setTintColor:[UIColor whiteColor]];
        }];
        
        pickingPhotoFromLocalLibrary = NO;
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        pickingPhotoFromLocalLibrary = NO;
    }];
}

@end
