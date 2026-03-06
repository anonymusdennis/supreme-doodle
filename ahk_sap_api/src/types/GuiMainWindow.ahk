#Requires AutoHotkey v2.0

class GuiMainWindow extends GuiFrameWindow {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, policy, strict, path == "" ? "GuiMainWindow" : path)
    }

    ButtonbarVisible {
        get {
            return this.InvokeGet("ButtonbarVisible")
        }
        set {
            return this.InvokeSet("ButtonbarVisible", value)
        }
    }

    StatusbarVisible {
        get {
            return this.InvokeGet("StatusbarVisible")
        }
        set {
            return this.InvokeSet("StatusbarVisible", value)
        }
    }

    TitlebarVisible {
        get {
            return this.InvokeGet("TitlebarVisible")
        }
        set {
            return this.InvokeSet("TitlebarVisible", value)
        }
    }

    ToolbarVisible {
        get {
            return this.InvokeGet("ToolbarVisible")
        }
        set {
            return this.InvokeSet("ToolbarVisible", value)
        }
    }

    ResizeWorkingPane(width, height, throwOnFail := unset) {
        if IsSet(throwOnFail) {
            return this.InvokeCall("ResizeWorkingPane", width, height, throwOnFail)
        }
        return this.InvokeCall("ResizeWorkingPane", width, height)
    }

    ResizeWorkingPaneEx(width, height, throwOnFail := unset) {
        if IsSet(throwOnFail) {
            return this.InvokeCall("ResizeWorkingPaneEx", width, height, throwOnFail)
        }
        return this.InvokeCall("ResizeWorkingPaneEx", width, height)
    }
}
