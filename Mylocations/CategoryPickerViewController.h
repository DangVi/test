//
//  CategoryPickerViewController.h
//  Mylocations
//
//  Created by vinguyen on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CategoryPickerViewController;
@protocol CategoryPickerViewControllerDelegate <NSObject>
- (void)categoryPicker:(CategoryPickerViewController *)picker didPickCategory:(NSString *)categoryName;
@end
@interface CategoryPickerViewController : UITableViewController
@property (nonatomic, weak) id <CategoryPickerViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *selectedCategoryName;

- (IBAction)addCategories:(id)sender;
@end
