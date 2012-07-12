//
//  MapViewController.h
//  Mylocations
//
//  Created by vinguyen on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKit/Mapkit.h"
@interface MapViewController : UIViewController <MKMapViewDelegate>


@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
- (IBAction)showUser;
- (IBAction)showLocations;
@end
