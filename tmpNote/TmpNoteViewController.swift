//
//  TmpNoteViewController.swift
//  tmpNote
//
//  Created by BUDDAx2 on 9/24/17.
//  Copyright © 2017 BUDDAx2. All rights reserved.
//

import Cocoa

class TmpNoteViewController: NSViewController {

    static private let kPreviousSessionTextKey = "PreviousSessionText"
    
    @IBOutlet var textView: NSTextView! {
        didSet {
            setupTextView()
            loadPreviousText()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupTextView), name: Notification.Name(rawValue: "PlainTextDidChange"), object: nil)
    }
    
    func willAppear() {
        // make textview focused
        textView?.window?.makeKeyAndOrderFront(self)
    }
    
    @objc fileprivate func setupTextView() {

        // Will back to this later
        // Need to fix some style issues while using RTF
        
//        let isPlainTextOn = UserDefaults.standard.bool(forKey: "PlainText")
//        textView.isRichText = !isPlainTextOn
    }
    
    func loadPreviousText() {
        if let prevText = UserDefaults.standard.string(forKey: TmpNoteViewController.kPreviousSessionTextKey)  {
            textView.string = prevText
        }
        else {
            textView.string = ""
        }
    }
    
    func saveText() {
        UserDefaults.standard.set(textView.string, forKey: TmpNoteViewController.kPreviousSessionTextKey)
    }
    
    ///Close popover if Esc key is pressed
    override func cancelOperation(_ sender: Any?) {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.closePopover()
    }
}

extension TmpNoteViewController {
    
    static func freshController() -> TmpNoteViewController {
        
        let storyBoard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("TmpNoteViewController")
        guard let vc = storyBoard.instantiateController(withIdentifier: identifier) as? TmpNoteViewController else {
            
            fatalError("Can't instantiate TmpNoteViewController. Check Main.storyboard")
        }
        
        return vc
    }
}
