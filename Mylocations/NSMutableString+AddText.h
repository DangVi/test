//
//  NSMutableString+AddText.h
//  Mylocations
//
//  Created by vinguyen on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (AddText)
- (void)addText:(NSString *)text withSeparator:(NSString *)separator;
@end
