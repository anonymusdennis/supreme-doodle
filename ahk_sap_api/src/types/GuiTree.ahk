#Requires AutoHotkey v2.0

class GuiTree extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiTree", path == "" ? "GuiTree" : path, policy, strict)
    }

    ColumnOrder {
        get {
            return this.InvokeGet("ColumnOrder")
        }
        set {
            return this.InvokeSet("ColumnOrder", value)
        }
    }

    SelectedNode {
        get {
            return this.InvokeGet("SelectedNode")
        }
        set {
            return this.InvokeSet("SelectedNode", value)
        }
    }

    TopNode {
        get {
            return this.InvokeGet("TopNode")
        }
        set {
            return this.InvokeSet("TopNode", value)
        }
    }

    SelectNode(nodeKey) {
        return this.InvokeCall("SelectNode", nodeKey)
    }

    ExpandNode(nodeKey) {
        return this.InvokeCall("ExpandNode", nodeKey)
    }

    CollapseNode(nodeKey) {
        return this.InvokeCall("CollapseNode", nodeKey)
    }

    DoubleClickNode(nodeKey) {
        return this.InvokeCall("DoubleClickNode", nodeKey)
    }

    GetNodeTextByPath(path) {
        return this.InvokeCall("GetNodeTextByPath", path)
    }

    GetNodeKeyByPath(path) {
        return this.InvokeCall("GetNodeKeyByPath", path)
    }

    GetSelectedNodes() {
        return this.InvokeCall("GetSelectedNodes")
    }

    PressButton(buttonId) {
        return this.InvokeCall("PressButton", buttonId)
    }
}
