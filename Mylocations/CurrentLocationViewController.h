//
//  FirstViewController.h
//  Mylocations
//
//  Created by vinguyen on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
//#import "CoreLocation/CoreLocation.h"
@interface CurrentLocationViewController : UIViewController <CLLocationManagerDelegate> {
      
}

@property (nonatomic, strong) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) IBOutlet UILabel *latitudeLabel;
@property (nonatomic, strong) IBOutlet UILabel *longitudeLabel;
@property (nonatomic, strong) IBOutlet UILabel *addressLabel;
@property (nonatomic, strong) IBOutlet UIButton *tagButton;
@property (nonatomic, strong) IBOutlet UIButton *getButton;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) IBOutlet UIView *panelView;
- (IBAction)getLocation:(id)sender;
- (void)startLocationManager;
- (void)updatelabels;
- (void)stopLocationMagager;
- (void)configureGetButton;
@end

