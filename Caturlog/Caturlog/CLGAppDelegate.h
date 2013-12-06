//
//  CLGAppDelegate.h
//  Caturlog
//
//  Created by Jonathon Rubin on 12/6/13.
//  Copyright (c) 2013 Jonathon Rubin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CLGAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end
