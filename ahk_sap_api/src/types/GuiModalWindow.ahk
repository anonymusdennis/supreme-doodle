#Requires AutoHotkey v2.0

class GuiModalWindow extends GuiFrameWindow {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, policy, strict, path == "" ? "GuiModalWindow" : path)
    }

    PopupDialogText {
        get {
            return this.InvokeGet("PopupDialogText")
        }
    }
}
