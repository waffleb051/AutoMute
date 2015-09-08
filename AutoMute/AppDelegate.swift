//
//  AppDelegate.swift
//  AutoMute
//
//  Created by Lorenzo Gentile on 2015-08-30.
//  Copyright © 2015 Lorenzo Gentile. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, WifiManagerDelegate {
    private let storyboard = NSStoryboard(name: Storyboards.setupWindow, bundle: nil)
    private var windowController: NSWindowController?
    private let wifiManager = WifiManager()
    private let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    private let menu = NSMenu()
    private let currentNetworkItem = NSMenuItem(title: "", action: "", keyEquivalent: "")
    private let infoItem = NSMenuItem(title: "", action: "", keyEquivalent: "")
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        wifiManager.delegate = self
        wifiManager.startWifiScanning()
        LaunchAtLoginController().setLaunchAtLogin(true, forURL: NSURL(fileURLWithPath: NSBundle.mainBundle().bundlePath))
        configureStatusBarMenu()
        showSetupIfFirstLaunch()
    }
    
    private func configureStatusBarMenu() {
        statusItem.button?.image = NSImage(named: "StatusBarIcon")
        statusItem.button?.sendActionOn(Int(NSEventMask.LeftMouseDownMask.rawValue))
        statusItem.button?.action = Selector("pressedStatusIcon")
        menu.addItem(currentNetworkItem)
        menu.addItem(infoItem)
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Preferences...", action: Selector("showSetupWindow"), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Quit", action: Selector("terminate:"), keyEquivalent: ""))
    }
    
    private func showSetupIfFirstLaunch() {
        if !NSUserDefaults.standardUserDefaults().boolForKey(DefaultsKeys.launchedBefore) {
            showSetupWindow()
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: DefaultsKeys.launchedBefore)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    // MARK: Button Handling
    
    func pressedStatusIcon() {
        if currentNetworkItem.title.isEmpty {
            currentNetworkItem.title = "Current wifi network: \(wifiManager.currentNetwork())"
        }
        if infoItem.title.isEmpty {
            infoItem.title = "Next time you connect to this network, AutoMute will: \(wifiManager.currentAction().description)"
        }
        statusItem.popUpStatusItemMenu(menu)
    }
    
    func showSetupWindow() {
        windowController = storyboard.instantiateInitialController() as? NSWindowController
        windowController?.showWindow(self)
    }
    
    // MARK: WifiManagerDelegate
    
    func performAction(action: Action) {
        switch action {
        case .Mute: NSSound.applyMute(true)
        case .Unmute: NSSound.applyMute(false)
        default: break
        }
        
        let actionDescription: String
        switch action {
        case .Mute: actionDescription = "Muted volume"
        case .Unmute: actionDescription = "Unmuted volume"
        default: actionDescription = "Last connected"
        }
        
        currentNetworkItem.title = "Current wifi network: \(wifiManager.currentNetwork())"
        infoItem.title = "\(actionDescription) \(NSDate().formattedDate)"
    }
    
}

extension NSDate {
    private static var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone.defaultTimeZone()
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .MediumStyle
        return formatter
    }()
    
    private static var timeFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
    
    var formattedDate: String {
        let dateString = NSDate.dateFormatter.stringFromDate(self)
        if dateString == "Today" {
            return "at \(NSDate.timeFormatter.stringFromDate(self))"
        }
        return "\(dateString) at \(NSDate.timeFormatter.stringFromDate(self))"
    }
}
