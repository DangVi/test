//
//  FirstViewController.m
//  Mylocations
//
//  Created by vinguyen on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CurrentLocationViewController.h"
#import "LocationDetailsViewController.h"

@interface CurrentLocationViewController ()
- (void)loadSoundEffect;
- (void)unloadSoundEffect;
- (void)playSoundEffect;

- (void)showLogoView;
- (void)hideLogoViewAnimated:(BOOL)animated;
@end

@implementation CurrentLocationViewController{
    CLLocationManager *locationManager; 
    CLLocation *location;
    BOOL updatingLocation;
    NSError *lastLocationError;
    
    // geocoder
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    BOOL performingReverseGeocoding;
    NSError *lastGeocodingError;
    //(void)updatelabels;
    //UIActivityIndicatorView *spinner;
    UInt32 soundID;
    
    
    UIImageView *logoImageView;
    BOOL firstTime;
}
@synthesize messageLabel,latitudeLabel,longitudeLabel,addressLabel,tagButton,getButton;
@synthesize managedObjectContext;
@synthesize spinner,panelView;
-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        locationManager = [[CLLocationManager alloc]init];
        geocoder = [[CLGeocoder alloc]init ];
        firstTime = YES;
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updatelabels];
    [self configureGetButton];
    [self loadSoundEffect];
    if (firstTime) {
        [self showLogoView];
    }else {
        [self hideLogoViewAnimated:NO];
    }
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.messageLabel =nil;
    self.latitudeLabel = nil;
    self.longitudeLabel = nil;
    self.addressLabel = nil;
    self.tagButton = nil;
    self.getButton = nil;
    self.spinner = nil;
    [self unloadSoundEffect];
    logoImageView = nil;
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation = UIInterfaceOrientationPortrait);
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender 
{
    
    
    if ([segue.identifier isEqualToString:@"TagLocation"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        LocationDetailsViewController * controller = (LocationDetailsViewController *)navigationController.topViewController;
        //controller.coordinate = location.coordinate;
        controller.placemark = placemark;
        
        //NSLog(@"dia chi == %@",[self stringFromPlacemark:controller.placemark]);
        controller.managedObjectContext = self.managedObjectContext;
        
    }
}

- (void)addText:(NSString *)text toLine:(NSMutableString *)line withSeparator:(NSString *)separator
{
    if (text != nil) {
        if ([line length] > 0) {
            [line appendString:separator];
        }
        [line appendString:text];
    }
}


- (NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark
{
//    return [NSString stringWithFormat:@"%@ %@\n%@ %@ %@",
//            thePlacemark.subThoroughfare, thePlacemark.thoroughfare,
//            thePlacemark.locality, thePlacemark.administrativeArea,
//            thePlacemark.postalCode];
    
    NSMutableString *line1 = [NSMutableString stringWithCapacity:100];
    [self addText:thePlacemark.subThoroughfare toLine:line1 withSeparator:@""];
    [self addText:thePlacemark.thoroughfare toLine:line1 withSeparator:@" "];
    NSMutableString *line2 = [NSMutableString stringWithCapacity:100];
    [self addText:thePlacemark.locality toLine:line2 withSeparator:@""];
    [self addText:thePlacemark.administrativeArea toLine:line2 withSeparator:@" "];
    [self addText:thePlacemark.postalCode toLine:line2 withSeparator:@" "];
    if ([line1 length] == 0) {
        [line2 appendString:@"\n "];
        return line2;
    } else {
        [line1 appendString:@"\n"];
        [line1 appendString:line2];
        return line1;
    }
    return line1;
}

-(void)updatelabels {
    if (location !=nil) {
        
        self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f", location.coordinate.latitude];
        self.longitudeLabel.text = [NSString stringWithFormat:@"%.8f", location.coordinate.longitude];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%.8f", location.coordinate.latitude] forKey:@"latitude"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%.8f", location.coordinate.longitude] forKey:@"longitute"];
        

        tagButton.hidden= NO;
        
        if (placemark !=nil) {
            self.addressLabel.text = [self stringFromPlacemark:placemark];
        }else if (performingReverseGeocoding) {
            self.addressLabel.text =@"searching address";
        }else if(lastGeocodingError !=nil) {
            self.addressLabel.text = @"Error finding address";
        }else {
            self.addressLabel.text = @"Not found address";
        }
        [[NSUserDefaults standardUserDefaults] setObject:self.addressLabel.text forKey:@"address"];
    }
    else {
        self.messageLabel.text =@"press button to get location";
        self.latitudeLabel.text = @"";
        self.longitudeLabel.text = @"";
        self.addressLabel.text =@"";
        tagButton.hidden =YES;
        
        NSString *statusMessage;
        if (lastLocationError != nil) {
            if ([lastLocationError.domain isEqualToString:kCLErrorDomain] && lastLocationError.code == kCLErrorDenied) {
                statusMessage = @"Location Services Disabled";
            } else {
                statusMessage = @"Error Getting Location";
            }
        } else if (![CLLocationManager locationServicesEnabled]) {
            statusMessage = @"Location Services Disabled";
        } else if (updatingLocation) {
            statusMessage = @"Searching...";
        } else {
            statusMessage = @"Press the Button to Start";
        }
        
        self.messageLabel.text = statusMessage;
    }
}


- (void)configureGetButton {
    
    if (updatingLocation) {
        [self.getButton setTitle:@"Stop" forState:UIControlStateNormal];
//        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//        spinner.center = CGPointMake(self.getButton.bounds.size.width - spinner.bounds.size.width/2.0f - 10, self.getButton.bounds.size.height / 2.0f);
//        [spinner startAnimating];
//        [self.getButton addSubview:spinner];
        spinner.hidden = NO;
        [spinner startAnimating];
        
    }
    else {
        [self.getButton setTitle:@"Get My location" forState:UIControlStateNormal];
//        [spinner stopAnimating];
//        [spinner removeFromSuperview];
//        spinner = nil;
        spinner.hidden = YES;
        [spinner stopAnimating];
    }
}

- (void)startLocationManager
{
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        [locationManager startUpdatingLocation];
        updatingLocation = YES;
        [self performSelector:@selector(didTimeOut:) withObject:nil afterDelay:60];
    }
}

-(void)stopLocationMagager {
    
    if (updatingLocation) {
       [ NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTimeOut:) object:nil];
        [locationManager stopUpdatingLocation];
        locationManager.delegate = self;
        updatingLocation =NO;
    }
    
}


- (void)didTimeOut:(id)obj
{
#ifdef DEBUG    
    NSLog(@"*** Time out");
#endif
    
    if (location == nil) {
        [self stopLocationMagager];
        
        lastLocationError = [NSError errorWithDomain:@"MyLocationsErrorDomain" code:1 userInfo:nil];
        
        [self updatelabels];
        [self configureGetButton];
    }
}
-(IBAction)getLocation:(id)sender{
    if (firstTime) {
        firstTime = NO;
        [self hideLogoViewAnimated:YES];
    }
    if (updatingLocation) {
        [self stopLocationMagager];
    }else {
        location =nil;
        lastLocationError = nil;
        placemark = nil;
        lastGeocodingError=nil;
        [self startLocationManager];

    }
    [self updatelabels];
    [self configureGetButton];
    }

#pragma mark CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
   // NSLog(@"didFailWithError  %@",error);
    if (error.code == kCLErrorLocationUnknown) {
        return;
    }
   [self stopLocationMagager];
   lastLocationError=error;
   [self configureGetButton];
    
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;
{
    //NSLog(@"newLocation  %@", newLocation);
    if ([newLocation.timestamp timeIntervalSinceNow] < -5.0) {
        return;
    }
     if (newLocation.horizontalAccuracy <0){
        return;
        
    }
    CLLocationDistance distance =MAXFLOAT;
    if (location!=nil) {
        distance = [newLocation distanceFromLocation:location];
    }
     if (location ==nil || (location.horizontalAccuracy > newLocation.horizontalAccuracy)) {
        lastLocationError =nil;
        location = newLocation;
        [self updatelabels];
        if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
            
           // NSLog(@"we were done");
            [self stopLocationMagager];
            [self configureGetButton];
            
            if (distance >0) {
                performingReverseGeocoding = NO;
            }
        }
        
         if (!performingReverseGeocoding) {
             //NSLog(@"going to geocode");
             performingReverseGeocoding = YES;
             [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                  //NSLog(@"*** Found placemarks: %@, error: %@", placemarks, error);
                 lastGeocodingError = error;
                 if (error == nil && [placemarks count] > 0) {
                     if (placemark == nil) {
                         NSLog(@"FIRST TIME!");
                         [self playSoundEffect];
                     }
                     placemark = [placemarks lastObject];
                 } else {
                     placemark = nil;
                 }
                 
                 performingReverseGeocoding = NO;
                 [self updatelabels];
             }];
         }
     } else if (distance < 1.0) {
         NSTimeInterval timeInterval = [newLocation.timestamp timeIntervalSinceDate:location.timestamp];
         if (timeInterval > 10) {
             NSLog(@"*** Force done!");
             [self stopLocationMagager];
             [self updatelabels];
             [self configureGetButton];
           }
     }
    
}

#pragma mark soundEffect

-(void) loadSoundEffect 
{
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"Sound.caf" ofType:nil];
//    
//    NSURL *fileURL = [NSURL fileURLWithPath:path isDirectory:NO];
//    if (fileURL == nil) {
//        NSLog(@"NSURL is nil for path: %@", path);
//        return;
//    }
//    
//    OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &soundID);
//    if (error != kAudioServicesNoError) {
//        NSLog(@"Error code %ld loading sound at path: %@", error, path);
//        return;
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFURLRef soundFileURLRef;
    soundFileURLRef = CFBundleCopyResourceURL(mainBundle, (CFStringRef)@"Sound", CFSTR("caf"), NULL);
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundID);

}
- (void)unloadSoundEffect
{
    AudioServicesDisposeSystemSoundID(soundID);
    soundID = 0;
}

- (void)playSoundEffect
{
    AudioServicesPlaySystemSound(soundID);
}



#pragma mark - Logo View

- (void)showLogoView
{
    self.panelView.hidden = YES;
    
    logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    logoImageView.center = CGPointMake(160.0f, 140.0f);
    [self.view addSubview:logoImageView];
}

- (void)hideLogoViewAnimated:(BOOL)animated
{
    self.panelView.hidden = NO;
    
    [logoImageView removeFromSuperview];
    logoImageView = nil;
}
@end
