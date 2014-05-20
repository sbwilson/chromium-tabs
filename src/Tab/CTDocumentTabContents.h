#pragma once
#import <Cocoa/Cocoa.h>
#import "CTTabContents.h"

@class CTTabStripModel;
@class CTBrowser;

@interface CTDocumentTabContents : NSDocument <CTTabContents> {
	BOOL isApp_;
	BOOL isLoading_;
	BOOL isWaitingForResponse_;
	BOOL isCrashed_;
	BOOL isVisible_;
	BOOL isActive_;
	BOOL isTeared_; // YES while being "teared" (dragged between windows)
	BOOL isPinned_;
	BOOL isBlocked_;
	id delegate_;
	unsigned int closedByUserGesture_; // TabStripModel::CloseTypes
	NSView *view_; // the actual content
	NSString *title_; // title of this tab
	NSImage *icon_; // tab icon (nil means no or default icon)
	CTBrowser *browser_;
	id<CTTabContents> parentOpener_; // the tab which opened this tab (unless nil)
}

@property(retain, nonatomic) NSView *view;

@end


