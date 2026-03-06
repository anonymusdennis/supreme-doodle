#Requires AutoHotkey v2.0

class GuiTableControl extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiTableControl", path = "" ? "GuiTableControl" : path, policy, strict)
    }

    Columns {
        get {
            return this.InvokeGet("Columns")
        }
    }

    Rows {
        get {
            return this.InvokeGet("Rows")
        }
    }

    HorizontalScrollbar {
        get {
            return this.InvokeGet("HorizontalScrollbar")
        }
    }

    VerticalScrollbar {
        get {
            return this.InvokeGet("VerticalScrollbar")
        }
    }

    RowCount {
        get {
            return this.InvokeGet("RowCount")
        }
    }

    VisibleRowCount {
        get {
            return this.InvokeGet("VisibleRowCount")
        }
    }

    CurrentCol {
        get {
            return this.InvokeGet("CurrentCol")
        }
        set {
            return this.InvokeSet("CurrentCol", value)
        }
    }

    CurrentRow {
        get {
            return this.InvokeGet("CurrentRow")
        }
        set {
            return this.InvokeSet("CurrentRow", value)
        }
    }

    GetCell(row, col) {
        return this.InvokeCall("GetCell", row, col)
    }

    GetAbsoluteRow(row) {
        return this.InvokeCall("GetAbsoluteRow", row)
    }

    SelectAllColumns() {
        return this.InvokeCall("SelectAllColumns")
    }

    DeselectAllColumns() {
        return this.InvokeCall("DeselectAllColumns")
    }

    ReorderTable(fromCol, toCol) {
        return this.InvokeCall("ReorderTable", fromCol, toCol)
    }

    ConfigureLayout(layoutName := unset) {
        if IsSet(layoutName) {
            return this.InvokeCall("ConfigureLayout", layoutName)
        }
        return this.InvokeCall("ConfigureLayout")
    }
}
