#import "MyBrowser.h"
#import "MyTabContents.h"
#import "TestViewController.h"

@implementation MyBrowser

// This method is called when a new tab is being created. We need to return a
// new CTTabContents object which will represent the contents of the new tab.

static int tabIdx = 0;

-(id<CTTabContents>)createBlankTabBasedOn:(id<CTTabContents>)baseContents
{
    // Create a new instance of our tab type
    
    if (tabIdx++ %2 == 0)
    {
        return [[MyTabContents alloc]
                initWithBaseTabContents:baseContents];
    }
    else
    {
        TestViewController * vc = [[TestViewController alloc] initWithNibName:@"TestViewController" bundle:nil];
        return [[CTViewControllerTabContents alloc] initWithBaseTabContents:baseContents contentViewController:vc];
    }
}

@end
