//
//  CTViewControllerTabContents.h
//  chromium-tabs
//
//  Created by Mark Aufflick on 20/05/2014.
//
//

#import <Cocoa/Cocoa.h>
#import "CTTabContents.h"

@interface CTViewControllerTabContents : NSObject<CTTabContents>

@property (nonatomic, strong) NSViewController * viewController;
@property (nonatomic) BOOL hasIcon;

-(id)initWithBaseTabContents:(id<CTTabContents>)baseContents
       contentViewController:(NSViewController *)viewController;

@end
