#Requires AutoHotkey v2.0

class GuiComponentCollection extends SapCollectionProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiComponentCollection", path = "" ? "GuiComponentCollection" : path, policy, strict)
    }

    Item(index) {
        return this.InvokeCall("Item", index)
    }

    ElementAt(index) {
        return this.InvokeCall("ElementAt", index)
    }
}
