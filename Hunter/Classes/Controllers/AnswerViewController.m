//
//  AnswerViewController.m
//  Hunter
//
//  Created by Joy Tao on 3/8/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "AnswerViewController.h"
#import "SCSHuntrClient.h"

@interface AnswerViewController () <UIImagePickerControllerDelegate , UINavigationControllerDelegate, CLLocationManagerDelegate , UIActionSheetDelegate>

@property (nonatomic , strong) CLLocationManager * locationManager;
@end

@implementation AnswerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if([self.theClue.type isEqualToString:@"Picture"])
    {
        self.clueTypeImageView.image = [UIImage imageNamed:@"Camera"];
        [self.answerButton setTitle:@"Take the picture" forState:UIControlStateNormal];
        [self.answerButton addTarget:self action:@selector(takeThePicture:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([self.theClue.type isEqualToString:@"Location"])
    {
        self.clueTypeImageView.image = [UIImage imageNamed:@"location"];
        [self.answerButton setTitle:@"I am here" forState:UIControlStateNormal];
        [self.answerButton addTarget:self action:@selector(checkInHere:) forControlEvents:UIControlEventTouchUpInside];
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        // For foreground access
        // [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization]; // For background access
        [self.locationManager startUpdatingLocation];

    }

    self.descriptionTextView.text = self.theClue.clueDescription;
    self.pointLabel.text = [NSString stringWithFormat:@"%i points",[self.theClue.pointValue intValue]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void) takeThePicture:(id)sender{
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
#if TARGET_IPHONE_SIMULATOR
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
#else
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
#endif
    imagePickerController.editing = YES;
    imagePickerController.delegate = (id)self;
    [self  presentViewController:imagePickerController animated:YES completion:^{
    }];
}

- (void) checkInHere:(id)sender
{
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - UIImagePickerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        [[SCSHuntrClient sharedClient]postAnswer:image withClue:self.theClue.clueID type:@"Picture" successBlock:nil failureBlock:nil];
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to get user location" );
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"didUpdateToLocation: %@,", locations);
    CLLocation *currentLocation = locations.lastObject;
    if (currentLocation != nil)
    {
        BOOL rightAnswer = [self isUserInTheLocation:currentLocation];
        if (rightAnswer)
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"You found the location." preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                
                NSDictionary * answer = @{@"latitude": [NSNumber numberWithDouble:currentLocation.coordinate.latitude], @"longitude": [NSNumber numberWithDouble:currentLocation.coordinate.longitude]};
                
                [[SCSHuntrClient sharedClient] postAnswer:answer withClue:self.theClue.clueID type:@"Location" successBlock:nil failureBlock:nil];
                
            }];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}


#pragma mark - UIAlertViewDelegate

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Private Methods

- (BOOL) isUserInTheLocation:(CLLocation*)userLocation{
    
    CLLocationDistance distance = [userLocation distanceFromLocation:self.theClue.clueLocation];
    
    NSLog(@"%f",distance);
    
    NSString *distanceReturned = [NSString stringWithFormat:@"%f",distance];
    
    if([distanceReturned doubleValue] <= 500 && [distanceReturned doubleValue]>0){
        return YES;
    }
    else{
        return NO;
    }
}

@end
