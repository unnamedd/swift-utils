import Cocoa
/**
 * Simplifies interaction with the NSTextField
 * TODO: ⚠️️ Text carat is not showing. Try creating a bare NSTextField and figure it out, its probalt due to textattribution
 * characterIndexForPoint could be handy
 *
 */
class TextField:NSTextField,Trackable{
    var trackingArea:NSTrackingArea?
    var mouseDownOutsideHandler:Any?
    /**
     * NOTE: You must use InteractiveView as a parent for this class to work
     * NOTE: the hitTesting bellow is the only combination I found that will give a correct hit. 
     */
    override func hitTest(_ aPoint: NSPoint) -> NSView? {
        let retVal = super.hitTest(CGPoint(localPos().x,localPos().y))
        return retVal
    }
    override func mouseDown(with theEvent:NSEvent) {
//        Swift.print("TextField.mouseDown")
//      self.window!.makeFirstResponder(self)//resigns the NSTextField caret focus
        NSEvent.addMonitor(&mouseDownOutsideHandler,NSEvent.EventTypeMask.leftMouseDown,onMouseDownOutside)/*we add a global mouse move event listener*/
        super.mouseDown(with: theEvent)
    }
    func onMouseDownOutside(_ event:NSEvent) -> Void {
        let p = window?.mouseLocationOutsideOfEventStream//self.locationInWindow
        if hitTest(p!) == nil {/*if you click outside the NSTextField then this will take care of resiging the caret of the text*/
            NSEvent.removeMonitor(&self.mouseDownOutsideHandler)//we remove the evenListener as its done its job
            self.window!.makeFirstResponder(nil)//resigns the NSTextField caret focus,resignFirstResponder(), self.window?.selectNextKeyView(self.superview)
            if self.isEditable {
                window?.endEditing(for: nil)
            }
        }
    }
    override func mouseEntered(with event: NSEvent) {
        if self.isSelectable {
            addCursorRect(frame, cursor:NSCursor.iBeam)//sets the default text cursor
        }
        super.mouseEntered(with: event)
    }
    override func mouseExited(with event: NSEvent) {
        resetCursorRects()//reset to default mouse Cursor
        cursorUpdate(with: event)/*<-- ⚠️️ this is important to call or you might get stuck ibeam cursors*/
    }
    /**
     * NOTE: you should use bounds for the rect but we dont rotate the frame so we don't need to use bounds.
     * NOTE: the only way to update trackingArea is to remove it and add a new one
     * NOTE: we could keep the trackingArea in graphic so its always easy to access, but i dont think it needs to be easily accesible atm.
     * PARAM: owner is the instance that receives the interaction event
     * TODO: ⚠️️ you don't have to store the trackingarea in this class you can get and set the trackingarea from NSView
     */
    override func updateTrackingAreas() {
        self.createTrackingArea([NSTrackingArea.Options.activeAlways,NSTrackingArea.Options.mouseEnteredAndExited])
        super.updateTrackingAreas()
    }
    /**
     * NOTE: there is also related: textShouldBeginEditing,textShouldEndEditing,textDidBeginEditing,controlTextDidEndEditing,textDidEndEditing,textStorageDidProcessEditing,textStorageWillProcessEditing,becomeFirstResponder,resignFirstResponder
     */
    override func textDidChange(_ notification:Notification) {
        _ = self.stringValue/*for some strange reason you have to call this variable or the text will be reverted to init state*/
        if self.superview is EventSendable {/*superview is EventSendable*/
            (self.superview as! EventSendable).event(TextFieldEvent(Event.update,self))
        }/*else superview is NOT EventSendable*/
        super.textDidChange(notification)
    }
    /**
     * Support for copy/paste/undo/select all when you don't have an edit NSMenu
     */
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.type == NSEvent.EventType.keyDown {
            if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == NSEvent.ModifierFlags.command.rawValue {
                switch event.charactersIgnoringModifiers! {
                case "x" where NSApp.sendAction(#selector(NSText.cut(_:)), to:nil, from:self):return true
                case "c" where NSApp.sendAction(#selector(NSText.copy(_:)), to:nil, from:self):return true
                case "v" where NSApp.sendAction(#selector(NSText.paste(_:)), to:nil, from:self):return true
                case "z" where NSApp.sendAction(Selector(("undo:")), to:nil, from:self) :return true
                case "a" where NSApp.sendAction(#selector(NSResponder.selectAll(_:)), to:nil, from:self):return true
                default:
                    break
                }
            }
            else if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue {
                if event.charactersIgnoringModifiers == "Z" && NSApp.sendAction(Selector(("redo:")), to:nil, from:self) {
                    return true
                }
            }
        }
        return super.performKeyEquivalent(with: event)
    }
    
}

