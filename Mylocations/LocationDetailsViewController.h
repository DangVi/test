//
//  LocationDetailsViewController.h
//  Mylocations
//
//  Created by vinguyen on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryPickerViewController.h"
//#import "CoreLocation/CoreLocation.h"
@class Location;
@interface LocationDetailsViewController : UITableViewController <UITableViewDelegate,UITextViewDelegate,CategoryPickerViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
@property (nonatomic, strong) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, strong) IBOutlet UILabel *categoryLabel;
@property (nonatomic, strong) IBOutlet UILabel *latitudeLabel;
@property (nonatomic, strong) IBOutlet UILabel *longitudeLabel;
@property (nonatomic, strong) IBOutlet UILabel *addressLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) CLPlacemark *placemark;
//@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Location *locationEdit;

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *photoLabel;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;
@end
