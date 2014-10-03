//
//  CaturlogWindowController.swift
//  Caturlog
//
//  Created by Jonathon Rubin on 7/18/14.
//  Copyright (c) 2014 Jonathon Rubin. All rights reserved.
//

import Foundation
import AppKit
import CoreData

class CaturlogWindowController: NSWindowController {

    @IBOutlet var imageView:    CaturlogImageView!
    @IBOutlet var tagField:     NSTokenField!
    @IBOutlet var itemList:     NSTableView!
    @IBOutlet var tagViewController: TagViewController!
    @IBOutlet var toolbar: NSToolbar!
    @IBOutlet var spinner: NSProgressIndicator!
    
    var moc: NSManagedObjectContext? {
        return (NSApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    }
    
    var viewModel: CaturlogWindowViewModel? = nil

    
    override init() {
        super.init()
    }
    
    override init(window: NSWindow!) {
        super.init(window: window)
        //Initialization code here.
    }
    
    required init?(coder: NSCoder){
        super.init(coder: coder);
    }
    
    override func awakeFromNib()  {
        super.awakeFromNib()
        if (self.window!.respondsToSelector(NSSelectorFromString("titleVisibility"))) {
            self.window!.titleVisibility = .Hidden
            self.window!.titlebarAppearsTransparent = true;
            self.window!.styleMask = self.window!.styleMask | NSFullSizeContentViewWindowMask;

        }
        viewModel = CaturlogWindowViewModel()
        self.tagViewController.bindTagField()
    }
    
    override func windowWillLoad() {
        super.windowWillLoad()
    }
     
    override func windowDidLoad() {
        super.windowDidLoad()


        if let column: NSTableColumn = itemList.tableColumns[itemList.columnWithIdentifier("ItemImageColumnID")]
            as? NSTableColumn
        {
            column.bind(NSValueBinding,
                toObject: viewModel!.itemEntityController,
                withKeyPath: "arrangedObjects",
                options: [
                    NSValueTransformerNameBindingOption: "Caturlog.ItemToNSImageTransformer",
                    NSConditionallySetsEnabledBindingOption: false
                ]
            )
        }
        
        imageView.bind(NSValueBinding,
            toObject: viewModel!.itemEntityController,
            withKeyPath: "selection.self",
            options: [
                NSValueTransformerNameBindingOption: "Caturlog.ItemToNSImageTransformer",
                NSConditionallySetsEnabledBindingOption: false
            ]
        )
        
        
    }    
    
    func downloadBegan() {
        self.toolbar.insertItemWithItemIdentifier("spinner", atIndex: 1)
        spinner.startAnimation(self)
    }
    
    func downloadCompleted() {
        spinner.stopAnimation(self)
        self.toolbar.removeItemAtIndex(1)
        self.viewModel?.itemEntityController.rearrangeObjects()
        self.itemList.reloadData()
        self.itemList.selectRowIndexes( NSIndexSet(index: self.itemList.numberOfRows-1), byExtendingSelection: false)
    }
}

extension CaturlogWindowController: NSMenuDelegate {
    
    func menuNeedsUpdate(menu:NSMenu) {
        menu.removeAllItems()
        
        if let itemURLs = self.viewModel?.urlsForSelectedItem() {
            for url: String in itemURLs {
                let host = NSURL(string:url)!.host
                let linkItem = NSMenuItem(title: "Copy link from \(host)", action: Selector("clickedCopyLinkFrom:"), keyEquivalent: "")
                linkItem.toolTip = url
                menu.addItem(linkItem)
            }
        }
        
        let deleteItem = NSMenuItem(title: "Delete", action: NSSelectorFromString("clickedDeleteItem"), keyEquivalent: "d")
        menu.addItem(deleteItem)

    }
    
    func clickedDeleteItem() {
        self.viewModel?.deleteSelectedItem()
        self.tagViewController.oldTokens = Array<String>()
    }
    
    func clickedCopyLinkFrom(sender: AnyObject) {
        let menuItem = sender as? NSMenuItem
        let url = menuItem?.toolTip
        let pasteBoard = NSPasteboard.generalPasteboard()
        pasteBoard.declareTypes([NSStringPboardType], owner: nil)
        pasteBoard.setString(url!, forType: NSStringPboardType)
    }

}

