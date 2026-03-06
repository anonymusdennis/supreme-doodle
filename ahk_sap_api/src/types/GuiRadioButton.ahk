#Requires AutoHotkey v2.0

class GuiRadioButton extends GuiVComponent {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, policy, strict, path = "" ? "GuiRadioButton" : path)
    }
}
