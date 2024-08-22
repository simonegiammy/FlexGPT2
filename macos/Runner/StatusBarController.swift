//
//  StatusBarController.swift
//  Runner
//
//  Created by Ken Lee on 11/3/2022.
//

import AppKit

class StatusBarController {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    
    init(_ popover: NSPopover) {
        self.popover = popover
        statusBar = NSStatusBar.init()
        statusItem = statusBar.statusItem(withLength: 28.0)
        popover.contentSize = NSSize(width: 600, height: 900) // Imposta la dimensione desiderata del popover

       if let statusBarButton = statusItem.button {
    statusBarButton.image = NSImage(named: "AppIcon") // Assicurati che "AppIcon" sia trasparente
    statusBarButton.image?.size = NSSize(width: 18.0, height: 18.0)
    statusBarButton.image?.isTemplate = true // Usa l'immagine come template
    statusBarButton.action = #selector(togglePopover(sender:))
    statusBarButton.target = self
}

    }
    
    @objc func togglePopover(sender: AnyObject) {
        if popover.isShown {
            hidePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
 func showPopover(_ sender: AnyObject) {
    if let screen = NSScreen.main {
        let screenFrame = screen.visibleFrame
        
        // Calcola l'origine del popover in modo che appaia dal lato destro dello schermo
        let popoverOrigin = NSPoint(
            x: screenFrame.maxX , // Posiziona il popover all'estrema destra dello schermo
            y: screenFrame.maxY // Posiziona il popover in alto, allineato al bordo superiore
        )
        
        // Mostra il popover
        if let popoverWindow = popover.contentViewController?.view.window {
            popoverWindow.setFrameOrigin(popoverOrigin)
        }
        
        popover.show(relativeTo: NSZeroRect, of: statusItem.button!, preferredEdge: .minX)
    }
}

    func hidePopover(_ sender: AnyObject) {
        popover.performClose(sender)
    }
}
