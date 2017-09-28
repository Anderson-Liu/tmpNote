//
//  AppDelegate.swift
//  tmpNote
//
//  Created by BUDDAx2 on 9/23/17.
//  Copyright © 2017 BUDDAx2. All rights reserved.
//

import Cocoa
import ServiceManagement


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {

    fileprivate let launcherIdentifier = "io.github.buddax2.tmpNote.LauncherApplication"
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let popover = NSPopover()
    var eventMonitor: EventMonitor?
    let preferences = PreferencesWindowController.freshController()
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        setupLaunchOnStartup()
        killLauncher()
        
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover()
            }
        }
        
        createStatusBarMenu()
        popover.contentViewController = TmpNoteViewController.freshController()
        popover.animates = false
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    private func createStatusBarMenu() {
        
        if let button = statusItem.button {
            button.image = #imageLiteral(resourceName: " Compose")
            button.action = #selector(AppDelegate.togglePopover(_:))
        }

        let menu = NSMenu()
        menu.delegate = self
        addMenuItems(to: menu)
        statusItem.menu = menu
    }
    
    fileprivate func killLauncher() {
        var startAtLogin = false
        for app in NSWorkspace.shared.runningApplications {
            if app.bundleIdentifier == launcherIdentifier {
                startAtLogin = true
            }
        }
        
        if startAtLogin == true {
            DistributedNotificationCenter.default().post(name: Notification.Name(rawValue: "killme"), object: Bundle.main.bundleIdentifier)
        }
    }
    
    private func addMenuItems(to menu: NSMenu) {
        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(openPreferences), keyEquivalent: "P"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit tmpNote", action: #selector(quitAction), keyEquivalent: ""))
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        menu.removeAllItems() // TODO: re-work this piece of shit

        if (NSEvent.pressedMouseButtons == 1) {
            togglePopover(menu)
            return
        }
        else {
            addMenuItems(to: menu)
        }
    }
    
    //MARK: Menu actions
    @objc func togglePopover(_ sender: Any?) {
        popover.isShown == true ? closePopover() : showPopover()
    }
    
    @objc func openPreferences() {
        NSApplication.shared.activate(ignoringOtherApps: true)
        preferences.window?.makeKeyAndOrderFront(self)
    }
    
    @objc func quitAction() {
        NSApp.terminate(self)
    }
    
    //MARK: Popover Show/Hide
    func showPopover() {
        if let button = statusItem.button {
            (popover.contentViewController as! TmpNoteViewController).willAppear()
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            NSApplication.shared.activate(ignoringOtherApps: true)
            eventMonitor?.start()
        }
    }
    
    func closePopover() {
        popover.performClose(self)
        (popover.contentViewController as! TmpNoteViewController).saveText()
        eventMonitor?.stop()
    }
    
    
    func setupLaunchOnStartup() {
        
        var shouldLaunch = true
        if let _ = UserDefaults.standard.object(forKey: "LaunchOnStartup") {
            shouldLaunch = UserDefaults.standard.bool(forKey: "LaunchOnStartup")
        }
        else {
            UserDefaults.standard.set(true, forKey: "LaunchOnStartup")
        }
        
        SMLoginItemSetEnabled(launcherIdentifier as CFString, shouldLaunch)
    }
}
