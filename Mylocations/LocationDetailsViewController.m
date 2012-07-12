//
//  LocationDetailsViewController.m
//  Mylocations
//
//  Created by vinguyen on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocationDetailsViewController.h"
#import "CategoryPickerViewController.h"
#import "HudView.h"
#import "Location.h"
#import "NSMutableString+AddText.h"
@interface LocationDetailsViewController ()

@end

@implementation LocationDetailsViewController
@synthesize descriptionTextView,categoryLabel,latitudeLabel,longitudeLabel,addressLabel,dateLabel;
@synthesize coordinate,placemark;
@synthesize managedObjectContext;
@synthesize locationEdit;
@synthesize imageView,photoLabel;
  NSString *descriptionText;
  NSString *categoryName;
  NSDate *date;
  UIImage *image;
  UIActionSheet *actionSheet;
  UIImagePickerController *imagePicker;
  double DBLatitude, DBLongitute;


- (void)applicationDidEnterBackground
{
    if (imagePicker != nil) {
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
        imagePicker = nil;
    }
    
    if (actionSheet != nil) {
        [actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex animated:NO];
        actionSheet = nil;
    }
    
    [self.descriptionTextView resignFirstResponder];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        descriptionText = @"";
        categoryName = @"No Category";
        date = [NSDate date];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];    
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)showImage:(UIImage*)theImage{
    self.imageView.image = theImage;
    self.imageView.hidden = NO;
    self.imageView.frame = CGRectMake(10, 10, 260,260);
    self.photoLabel.hidden = YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.locationEdit != nil) {
        self.title = @"Edit Location";
       
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
//                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
//                                                  target:self
//                                                  action:@selector(done:)];
        UIBarButtonItem *editBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonItemStyleDone target:self action:@selector(done:)];
        self.navigationItem.rightBarButtonItem = editBtn;
        self.view.backgroundColor = [UIColor blackColor];
                
        descriptionTextView.text = locationEdit.locationDescription;
        categoryLabel.text = locationEdit.category;
        latitudeLabel.text = [NSString stringWithFormat:@"%.8f", [locationEdit.latitude doubleValue]];
        longitudeLabel.text = [NSString stringWithFormat:@"%.8f", [locationEdit.longitude doubleValue]];
        addressLabel.text = [NSString stringWithFormat:@"%@ %@, %@",
                             locationEdit.placemark.subThoroughfare,
                             locationEdit.placemark.thoroughfare,
                             locationEdit.placemark.locality];
        dateLabel.text = [self formatDate:locationEdit.date];
       // NSLog(@"category %@", locations.category);
        //[self.tableView reloadData];
        if ([self.locationEdit hasPhoto] && image == nil) {
            UIImage *existingImage = [self.locationEdit photoImage];
            if (existingImage != nil) {
                [self showImage:existingImage];
            }
        }
    }
    else {
            
    
    self.descriptionTextView.text = @"";
    self.categoryLabel.text =@"";
    NSString *strLatitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"];
    NSString *strLongitute = [[NSUserDefaults standardUserDefaults] objectForKey:@"longitute"];
    NSString *address = [[NSUserDefaults standardUserDefaults] objectForKey:@"address"];
    self.latitudeLabel.text= [NSString stringWithFormat:@"%@", strLatitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%@", strLongitute];
    DBLatitude = [strLatitude doubleValue];
    DBLongitute = [strLongitute doubleValue];
    
    
#ifdef  DEBUG    
    //NSLog(@"latitude = %@", self.coordinate.latitude);
   // NSLog(@"longitute = %@", self.coordinate.longitude);
#endif
    
/*    if (self.placemark !=nil) {
        self.addressLabel.text = [self stringFromPlacemark : self.placemark];
    }
    else {
        self.addressLabel.text = @"Address not found";
    }
*/
    
    self.addressLabel.text = [NSString stringWithFormat:@"%@",address];
    self.dateLabel.text = [self formatDate:date];
    self.descriptionTextView.text = descriptionText;
    self.categoryLabel.text = categoryName;
    }
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self action:@selector(hideKeyboard:)];
    
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
    if (image!=nil) {
        [self showImage:image];
    }
 
}



- (NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark
{
//    return [NSString stringWithFormat:@"%@ %@\n%@ %@ %@", self.placemark.subThoroughfare,self.placemark.thoroughfare,self.placemark.locality, self.placemark.administrativeArea,
//            self.placemark.postalCode, self.placemark.country];
    NSMutableString *line = [NSMutableString stringWithCapacity:100];
    
    [line addText:thePlacemark.subThoroughfare withSeparator:@""];
    [line addText:thePlacemark.thoroughfare withSeparator:@" "];
    [line addText:thePlacemark.locality withSeparator:@", "];
    [line addText:thePlacemark.administrativeArea withSeparator:@", "];
    [line addText:thePlacemark.postalCode withSeparator:@" "];
    [line addText:thePlacemark.country withSeparator:@", "];
    
    return line;
}


- (NSString *)formatDate:(NSDate *)theDate
{
    static NSDateFormatter *formatter = nil;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
    }
    
    return [formatter stringFromDate:theDate];
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    self.descriptionTextView=nil;
    self.categoryLabel = nil;
    self.latitudeLabel = nil;
    self.longitudeLabel = nil;
    self.addressLabel = nil;
    self.dateLabel= nil;
    self.imageView = nil;
    self.photoLabel = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//- (void)setLocationToEdit:(Location *)newLocationToEdit
//  {
//    if (locationEdit != newLocationToEdit) {
//       locationEdit = newLocationToEdit;
//       
//        descriptionText = locationEdit.locationDescription;
//        categoryName = locationEdit.category;
//        coordinate = CLLocationCoordinate2DMake([locationEdit.latitude doubleValue], [locationEdit.longitude doubleValue]);
//        placemark = locationEdit.placemark;
//        date = locationEdit.date;
//        
//    }
// }


- (int)nextPhotoId
{
    int photoId = [[NSUserDefaults standardUserDefaults] integerForKey:@"PhotoID"];
    [[NSUserDefaults standardUserDefaults] setInteger:photoId+1 forKey:@"PhotoID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return photoId;
}


- (IBAction)done:(id)sender
{
    
   // NSLog(@"location %@", categoryName);
    HudView *hudView = [HudView hudInView:self.navigationController.view animated:YES];
    Location *location = nil;
    
    if (self.locationEdit != nil) {
        hudView.text = @"Updated";
        location = self.locationEdit;
        location.locationDescription = self.descriptionTextView.text;
        location.placemark = locationEdit.placemark;
        location.latitude = [NSNumber numberWithDouble:[locationEdit.latitude doubleValue] ];
        location.longitude = [NSNumber numberWithDouble:[locationEdit.longitude doubleValue] ];
        } 
    else {
        hudView.text = @"Tagged";
        location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
        location.locationDescription = self.descriptionTextView.text;
        location.placemark = self.placemark;
        location.latitude = [NSNumber numberWithDouble:DBLatitude];
        location.longitude = [NSNumber numberWithDouble:DBLongitute];
        location.photoId =[NSNumber numberWithInt:-1];
        
    }
    
    location.category = categoryName;
    location.date = date;
    
    if (image!=nil) {
        if (![location hasPhoto]) {
            location.photoId = [NSNumber numberWithInt:[self nextPhotoId]];
        }
        
        NSData *data = UIImagePNGRepresentation(image);
        NSError *error;
        if (![data writeToFile:[location photoPath] options:NSDataWritingAtomic error:&error]) {
            NSLog(@"Error writing file: %@", error);
        }
    }
    
    
    
    
    //NSLog(@"placemark ===%@", [self stringFromPlacemark:location.placemark]);
//    NSError *error;
//    if (![self.managedObjectContext save:&error]) {
//        NSLog(@"Error: %@", error);
//        abort();
//    }
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
    [self performSelector:@selector(closeScreen) withObject:nil afterDelay:0.6];    
}
- (IBAction)cancel:(id)sender
{
    [self closeScreen];
}

- (void)hideKeyboard:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    
    if (indexPath != nil && indexPath.section == 0 && indexPath.row == 0) {
        return;
    }
    
    [self.descriptionTextView resignFirstResponder];
}
  

-(void)closeScreen 
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    if (self.locationEdit != nil)
//    {
//        CategoryPickerViewController *controller = [[CategoryPickerViewController alloc]init];
//        controller.selectedCategoryName = locationEdit.category;
//        
//    }
//    else {
        if ([segue.identifier isEqualToString:@"PickCategory"]) {
            CategoryPickerViewController *controller = segue.destinationViewController;
            controller.delegate = self;
            controller.selectedCategoryName = categoryName;
//            controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//            [self presentViewController:controller animated:YES completion:nil];
        }
//    }
    
}

- (void)takePhoto
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
}


- (void)choosePhotoFromLibrary
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
}

- (void)showPhotoMenu
{

    //if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    if (YES) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"Take Photo", @"Choose From Library", nil];
        
        [actionSheet showInView:self.view];
    } else {
        [self choosePhotoFromLibrary];
    }
}

#pragma mark - Table view delegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 1) {
        return indexPath;
    } else {
        return nil;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self.descriptionTextView becomeFirstResponder];
    }else if (indexPath.section == 1 && indexPath.row == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self showPhotoMenu];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==0 && indexPath.row==0) {
        return 88;
    }
    else if (indexPath.section == 1) {
        if (self.imageView.hidden) {
            return 44;
        } else {
            return 280;
        }
    }else if (indexPath.section==2 && indexPath.row ==2) {
        //CGRect rect = CGRectMake(268, 22, 190, 1000);
        CGRect rect = CGRectMake(100, 10, 190, 1000);
        self.addressLabel.frame = rect; 
        [self.addressLabel sizeToFit];
        rect.size.height = self.addressLabel.frame.size.height;
        self.addressLabel.frame = rect;
        
        return self.addressLabel.frame.size.height + 20;
    
    }else {
        return 44;
    }
}

#pragma mark - TextView delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    descriptionText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    //NSLog(@"descriptionText===%@",descriptionText);
    return YES;
}


- (void)textViewDidEndEditing:(UITextView *)textView {
    
    descriptionText = textView.text;
    //NSLog(@"descriptionTextttttt%@",descriptionText);
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)theActionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self takePhoto];
    } else if (buttonIndex == 1) {
        [self choosePhotoFromLibrary];
    }
    actionSheet = nil;
}



#pragma  mark - CategoryPickerViewControllerDelegate

- (void)categoryPicker:(CategoryPickerViewController *)picker didPickCategory:(NSString *)categoryNames {
     
    categoryName = categoryNames;
    self.categoryLabel.text = categoryName;
        [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    image = [info objectForKey:UIImagePickerControllerEditedImage];
    //if (self isViewLoaded) {
        [self showImage:image];
        [self.tableView reloadData];
    //}
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    imagePicker = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    imagePicker = nil;
}
@end
