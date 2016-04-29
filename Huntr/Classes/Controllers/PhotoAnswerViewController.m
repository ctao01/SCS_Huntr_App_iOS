//
//  PhotoAnswerViewController.m
//  Huntr
//
//  Created by Joy Tao on 4/27/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "PhotoAnswerViewController.h"

@interface PhotoAnswerViewController()< UINavigationControllerDelegate, UIImagePickerControllerDelegate >
@end

@implementation PhotoAnswerViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.clueTypeImageView.image = [UIImage imageNamed:@"Camera"];
    self.descriptionTextView.text = self.clueToAnswer.clueDescription;
    self.pointLabel.text = [NSString stringWithFormat:@"%i points",[self.clueToAnswer.pointValue intValue]];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.clueToAnswer.didSubmit) {
        [self.takePhotoButton setTitle:@"Retake Photo" forState:UIControlStateNormal];
        
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.clueToAnswer.submittedAnswer.answerImageUrl]];
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
    if (self.clueToAnswer.didSubmit && self.clueToAnswer.submittedAnswer.isPending)
    {
        
    }
    else
    {
        [[SCSHuntrClient sharedClient]postAnswer:self.answerImageView.image withClue:self.clueToAnswer.clueID type:@"Picture" successBlock:nil failureBlock:nil];
    }
    
}

#pragma mark - UIImagePickerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        self.answerImageView.image = image;

    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
