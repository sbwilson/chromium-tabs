//
//  CTViewControllerTabContents.m
//  chromium-tabs
//
//  Created by Mark Aufflick on 20/05/2014.
//
//

#import "CTViewControllerTabContents.h"
#import "CTDocumentTabContents.h"
#import "CTTabStripModel.h"
#import "CTBrowser.h"

@implementation CTViewControllerTabContents
{
    BOOL isApp_;
	BOOL isLoading_;
	BOOL isWaitingForResponse_;
	BOOL isCrashed_;
	BOOL isVisible_;
	BOOL isActive_;
	BOOL isTeared_; // YES while being "teared" (dragged between windows)
	BOOL isPinned_;
	BOOL isBlocked_;
    BOOL hasIcon_;
	id delegate_;
	unsigned int closedByUserGesture_; // TabStripModel::CloseTypes
	NSString *title_; // title of this tab
	NSImage *icon_; // tab icon (nil means no or default icon)
	CTBrowser *browser_;
	id<CTTabContents> parentOpener_; // the tab which opened this tab (unless nil)
}


// changing any of these implies [browser_ updateTabStateForContent:self]

_synthAssign(BOOL, IsLoading, isLoading);
_synthAssign(BOOL, IsWaitingForResponse, isWaitingForResponse);
_synthAssign(BOOL, IsCrashed, isCrashed);
_synthAssign(BOOL, HasIcon, hasIcon);

_synthRetain(NSString*, Title, title);
_synthRetain(NSImage*, Icon, icon);

//@synthesize isLoading = isLoading_;
//@synthesize isWaitingForResponse = isWaitingForResponse_;
//@synthesize isCrashed = isCrashed_;
//@synthesize title = title_;
//@synthesize icon = icon_;

@synthesize delegate = delegate_;
@synthesize closedByUserGesture = closedByUserGesture_;
@synthesize browser = browser_;
@synthesize isApp = isApp_;
@synthesize isActive = isActive_;
@synthesize isTeared = isTeared_;
@synthesize isVisible = isVisible_;
@synthesize parentOpener = parentOpener_;

-(id)initWithBaseTabContents:(id<CTTabContents>)baseContents
       contentViewController:(NSViewController *)viewController
{
    if (nil == (self = [super init]))
        return nil;
    
    self.viewController = viewController;
    
    return self;
}

-(id)initWithBaseTabContents:(id<CTTabContents> )baseContents
{
    if (nil == (self = [super init]))
        return self;
    
    self.hasIcon = YES;
    self.parentOpener = baseContents;
    
    return self;
}

- (NSView *)view
{
    return self.viewController.view;
}

- (void)setParentOpener:(id<CTTabContents> )parentOpener
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    if (parentOpener_) {
        [nc removeObserver:self
                      name:CTTabContentsDidCloseNotification
                    object:parentOpener_];
    }
    [self willChangeValueForKey:@"parentOpener"];
    parentOpener_ = parentOpener;
    [self didChangeValueForKey:@"parentOpener"];
    if (parentOpener_) {
        [nc addObserver:self
               selector:@selector(tabContentsDidClose:)
                   name:CTTabContentsDidCloseNotification
                 object:parentOpener_];
    }
}

- (void)tabContentsDidClose:(NSNotification*)notification {
    // detach (NULLify) our parentOpener_ when it closes
    id<CTTabContents>  tabContents = [notification object];
    if (tabContents == parentOpener_) {
        parentOpener_ = nil;
    }
}

- (void)setVisible:(BOOL)visible {
    if (isVisible_ != visible && !isTeared_) {
        isVisible_ = visible;
        if (isVisible_) {
            [self tabDidBecomeVisible];
        } else {
            [self tabDidResignVisible];
        }
    }
}

- (void)setActive:(BOOL)active {
    if (isActive_ != active && !isTeared_) {
        isActive_ = active;
        if (isActive_) {
            [self tabDidBecomeActive];
        } else {
            [self tabDidResignActive];
        }
    }
}

- (void)setTeared:(BOOL)teared {
    if (isTeared_ != teared) {
        isTeared_ = teared;
        if (isTeared_) {
            [self tabWillBecomeTeared];
        } else {
            [self tabWillResignTeared];
            [self tabDidBecomeActive];
        }
    }
}

#pragma mark Actions

- (void)makeKeyAndOrderFront:(id)sender {
    if (browser_) {
        NSWindow *window = browser_.window;
        if (window)
            [window makeKeyAndOrderFront:sender];
        int index = [browser_ indexOfTabContents:self];
        assert(index > -1); // we should exist in browser
        [browser_ selectTabAtIndex:index];
    }
}


- (BOOL)becomeFirstResponder {
    if (isVisible_) {
        return [[self.view window] makeFirstResponder:self.view];
    }
    return NO;
}


#pragma mark Callbacks

-(void)closingOfTabDidStart:(CTTabStripModel *)closeInitiatedByTabStripModel {
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:CTTabContentsDidCloseNotification object:self];
}

// Called when this tab was inserted into a browser
- (void)tabDidInsertIntoBrowser:(CTBrowser*)browser
                        atIndex:(NSInteger)index
                   inForeground:(BOOL)foreground {
    self.browser = browser;
}

// Called when this tab replaced another tab
- (void)tabReplaced:(id<CTTabContents> )oldContents
          inBrowser:(CTBrowser*)browser
            atIndex:(NSInteger)index {
    self.browser = browser;
}

// Called when this tab is about to close
- (void)tabWillCloseInBrowser:(CTBrowser*)browser atIndex:(NSInteger)index {
    self.browser = nil;
}

// Called when this tab was removed from a browser. Will be followed by a
// |tabDidInsertIntoBrowser:atIndex:inForeground:|.
- (void)tabDidDetachFromBrowser:(CTBrowser*)browser atIndex:(NSInteger)index {
    self.browser = nil;
}

-(void)tabWillBecomeActive {}
-(void)tabWillResignActive {}

-(void)tabDidBecomeActive {
    [self becomeFirstResponder];
}

-(void)tabDidResignActive {}
-(void)tabDidBecomeVisible {}
-(void)tabDidResignVisible {}

-(void)tabWillBecomeTeared {
    // Teared tabs should always be visible and active since tearing is invoked
    // by the user selecting the tab on screen.
    assert(isVisible_);
    assert(isActive_);
}

-(void)tabWillResignTeared {
    assert(isVisible_);
    assert(isActive_);
}

// Unlike the above callbacks, this one is explicitly called by
// CTBrowserWindowController
-(void)tabDidResignTeared {
    [[self.view window] makeFirstResponder:self.view];
}

-(void)viewFrameDidChange:(NSRect)newFrame {
    [self.view setFrame:newFrame];
}

@end
