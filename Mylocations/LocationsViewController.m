//
//  LocationsViewController.m
//  Mylocations
//
//  Created by vinguyen on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocationsViewController.h"
#import "Location.h"
#import "LocationCell.h"
#import "LocationDetailsViewController.h"
#import "UIImage+Resize.h"
#import "NSMutableString+AddText.h"
@interface LocationsViewController ()

@end

@implementation LocationsViewController {
    //NSArray *locations;
    NSFetchedResultsController *fetchedResultsController;
}

@synthesize managedObjectContext;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController == nil) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
        NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"category" ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil]];
        [fetchRequest setFetchBatchSize:20];
        
        fetchedResultsController = [[NSFetchedResultsController alloc]
                                    initWithFetchRequest:fetchRequest
                                    managedObjectContext:self.managedObjectContext
                                    sectionNameKeyPath:@"category"
                                    cacheName:@"Locations"];
        
        fetchedResultsController.delegate = self;
    }
    return fetchedResultsController;
}


- (void)performFetch
{
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
//    [fetchRequest setEntity:entity];
//    
//   NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
//    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
//    
//    NSError *error;
//    NSArray *foundObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    if (foundObjects == nil) {
//        FATAL_CORE_DATA_ERROR(error);
//        return;
//    }
//    
//    locations = foundObjects;
    
//    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
//    {
//        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bt.png"]
//                                                      forBarMetrics:UIBarMetricsDefault];
//    }
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
   [self performFetch];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    //locations =nil;
    fetchedResultsController = nil;
    fetchedResultsController.delegate = nil;
}

- (void)dealloc {
    
    fetchedResultsController.delegate = nil;
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexpath{
    LocationCell *locationCell = (LocationCell *)cell;
    Location *location =[fetchedResultsController objectAtIndexPath:indexpath];
    if ([location.locationDescription length] > 0) {
        locationCell.descriptionLabel.text = location.locationDescription;
    } else {
        locationCell.descriptionLabel.text = @"(No Description)";
    }
    
    if (location.placemark != nil) {
//        locationCell.addressLabel.text = [NSString stringWithFormat:@"%@ %@, %@",
//                                          location.placemark.subThoroughfare,
//                                          location.placemark.thoroughfare,
//                                          location.placemark.locality];
        NSMutableString *string = [NSMutableString stringWithCapacity:100];
        
        [string addText:location.placemark.subThoroughfare withSeparator:@""];
        [string addText:location.placemark.thoroughfare withSeparator:@" "];
        [string addText:location.placemark.locality withSeparator:@", "];
        locationCell.addressLabel.text = string;
    } else {
        locationCell.addressLabel.text = [NSString stringWithFormat:
                                          @"Lat: %.8f, Long: %.8f",
                                          [location.latitude doubleValue],
                                          [location.longitude doubleValue]];
    }
    
    UIImage *image = nil;
    if ([location hasPhoto]) {
        image = [location photoImage];
        if (image != nil) {
            image = [image resizedImageWithBounds:CGSizeMake(66, 66)];
        }
    }
    locationCell.imageView.image = image;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EditLocation"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        LocationDetailsViewController *controller = (LocationDetailsViewController *)navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
        
        NSIndexPath *indexpath = [self.tableView indexPathForCell:sender];
        Location *location = [fetchedResultsController objectAtIndexPath:indexpath];
        controller.locationEdit = location;
       
        
        
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Location"];
    [self configureCell:cell atIndexPath:indexPath];
    //[tableView reloadData];
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Location *location = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [location removePhotoFile];
        [self.managedObjectContext deleteObject:location];
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            FATAL_CORE_DATA_ERROR(error);
            return;
        }
    }
}
// PUSH DOWN TO RELOAD DATA
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    [self.tableView reloadData];
//}




#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    //NSLog(@"*** controllerWillChangeContent");
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            //NSLog(@"*** controllerDidChangeObject - NSFetchedResultsChangeInsert");
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            //NSLog(@"*** controllerDidChangeObject - NSFetchedResultsChangeDelete");
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            //NSLog(@"*** controllerDidChangeObject - NSFetchedResultsChangeUpdate");
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            //NSLog(@"*** controllerDidChangeObject - NSFetchedResultsChangeMove");
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
           // NSLog(@"*** controllerDidChangeSection - NSFetchedResultsChangeInsert");
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
           // NSLog(@"*** controllerDidChangeSection - NSFetchedResultsChangeDelete");
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
   // NSLog(@"*** controllerDidChangeContent");
    [self.tableView endUpdates];
}

@end
