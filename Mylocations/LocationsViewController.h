//
//  LocationsViewController.h
//  Mylocations
//
//  Created by vinguyen on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationsViewController : UITableViewController <NSFetchedResultsControllerDelegate> {

}
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
