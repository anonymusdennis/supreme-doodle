#Requires AutoHotkey v2.0

class GuiBox extends GuiVComponent {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiBox", path = "" ? "GuiBox" : path, policy, strict)
    }
}

class GuiButton extends GuiVComponent {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiButton", path = "" ? "GuiButton" : path, policy, strict)
    }
}

class GuiCTextField extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiCTextField", path = "" ? "GuiCTextField" : path, policy, strict)
    }
}

class GuiChart extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiChart", path = "" ? "GuiChart" : path, policy, strict)
    }
}

class GuiCheckBox extends GuiVComponent {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiCheckBox", path = "" ? "GuiCheckBox" : path, policy, strict)
    }
}

class GuiComboBox extends GuiVComponent {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiComboBox", path = "" ? "GuiComboBox" : path, policy, strict)
    }
}

class GuiComboBoxControl extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiComboBoxControl", path = "" ? "GuiComboBoxControl" : path, policy, strict)
    }
}

class GuiComboBoxEntry extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiComboBoxEntry", path = "" ? "GuiComboBoxEntry" : path, policy, strict)
    }
}

class GuiContainerShell extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiContainerShell", path = "" ? "GuiContainerShell" : path, policy, strict)
    }
}

class GuiCustomControl extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiCustomControl", path = "" ? "GuiCustomControl" : path, policy, strict)
    }
}

class GuiDialogShell extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiDialogShell", path = "" ? "GuiDialogShell" : path, policy, strict)
    }
}

class GuiEnum extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiEnum", path = "" ? "GuiEnum" : path, policy, strict)
    }
}

class GuiGOSShell extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiGOSShell", path = "" ? "GuiGOSShell" : path, policy, strict)
    }
}

class GuiGraphAdapt extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiGraphAdapt", path = "" ? "GuiGraphAdapt" : path, policy, strict)
    }
}

class GuiInputFieldControl extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiInputFieldControl", path = "" ? "GuiInputFieldControl" : path, policy, strict)
    }
}

class GuiLabel extends GuiVComponent {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiLabel", path = "" ? "GuiLabel" : path, policy, strict)
    }
}

class GuiMainWindow extends GuiFrameWindow {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiMainWindow", path = "" ? "GuiMainWindow" : path, policy, strict)
    }
}

class GuiMap extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiMap", path = "" ? "GuiMap" : path, policy, strict)
    }
}

class GuiMenu extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiMenu", path = "" ? "GuiMenu" : path, policy, strict)
    }
}

class GuiMenubar extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiMenubar", path = "" ? "GuiMenubar" : path, policy, strict)
    }
}

class GuiMessageWindow extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiMessageWindow", path = "" ? "GuiMessageWindow" : path, policy, strict)
    }
}

class GuiModalWindow extends GuiFrameWindow {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiModalWindow", path = "" ? "GuiModalWindow" : path, policy, strict)
    }
}

class GuiNetChart extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiNetChart", path = "" ? "GuiNetChart" : path, policy, strict)
    }
}

class GuiOfficeIntegration extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiOfficeIntegration", path = "" ? "GuiOfficeIntegration" : path, policy, strict)
    }
}

class GuiOkCodeField extends GuiVComponent {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiOkCodeField", path = "" ? "GuiOkCodeField" : path, policy, strict)
    }
}

class GuiPasswordField extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiPasswordField", path = "" ? "GuiPasswordField" : path, policy, strict)
    }
}

class GuiRadioButton extends GuiVComponent {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiRadioButton", path = "" ? "GuiRadioButton" : path, policy, strict)
    }
}

class GuiSapChart extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiSapChart", path = "" ? "GuiSapChart" : path, policy, strict)
    }
}

class GuiScrollContainer extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiScrollContainer", path = "" ? "GuiScrollContainer" : path, policy, strict)
    }
}

class GuiScrollbar extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiScrollbar", path = "" ? "GuiScrollbar" : path, policy, strict)
    }
}

class GuiSessionInfo extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiSessionInfo", path = "" ? "GuiSessionInfo" : path, policy, strict)
    }
}

class GuiShell extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiShell", path = "" ? "GuiShell" : path, policy, strict)
    }
}

class GuiSimpleContainer extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiSimpleContainer", path = "" ? "GuiSimpleContainer" : path, policy, strict)
    }
}

class GuiSplit extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiSplit", path = "" ? "GuiSplit" : path, policy, strict)
    }
}

class GuiSplitterContainer extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiSplitterContainer", path = "" ? "GuiSplitterContainer" : path, policy, strict)
    }
}

class GuiStage extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiStage", path = "" ? "GuiStage" : path, policy, strict)
    }
}

class GuiStatusPane extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiStatusPane", path = "" ? "GuiStatusPane" : path, policy, strict)
    }
}

class GuiStatusbar extends GuiVComponent {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiStatusbar", path = "" ? "GuiStatusbar" : path, policy, strict)
    }
}

class GuiTab extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiTab", path = "" ? "GuiTab" : path, policy, strict)
    }
}

class GuiTabStrip extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiTabStrip", path = "" ? "GuiTabStrip" : path, policy, strict)
    }
}

class GuiTableColumn extends GuiComponentCollection {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiTableColumn", path = "" ? "GuiTableColumn" : path, policy, strict)
    }
}

class GuiTableControl extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiTableControl", path = "" ? "GuiTableControl" : path, policy, strict)
    }
}

class GuiTableRow extends GuiComponentCollection {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiTableRow", path = "" ? "GuiTableRow" : path, policy, strict)
    }
}

class GuiTextedit extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiTextedit", path = "" ? "GuiTextedit" : path, policy, strict)
    }
}

class GuiTitlebar extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiTitlebar", path = "" ? "GuiTitlebar" : path, policy, strict)
    }
}

class GuiToolbar extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiToolbar", path = "" ? "GuiToolbar" : path, policy, strict)
    }
}

class GuiTree extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiTree", path = "" ? "GuiTree" : path, policy, strict)
    }
}

class GuiUserArea extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiUserArea", path = "" ? "GuiUserArea" : path, policy, strict)
    }
}

class GuiUtils extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiUtils", path = "" ? "GuiUtils" : path, policy, strict)
    }
}

class GuiVHViewSwitch extends GuiVComponent {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiVHViewSwitch", path = "" ? "GuiVHViewSwitch" : path, policy, strict)
    }
}

class GuiAbapEditor extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiAbapEditor", path = "" ? "GuiAbapEditor" : path, policy, strict)
    }
}

class GuiApoGrid extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiApoGrid", path = "" ? "GuiApoGrid" : path, policy, strict)
    }
}

class GuiBarChart extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiBarChart", path = "" ? "GuiBarChart" : path, policy, strict)
    }
}

class GuiCalendar extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiCalendar", path = "" ? "GuiCalendar" : path, policy, strict)
    }
}

class GuiColorSelector extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiColorSelector", path = "" ? "GuiColorSelector" : path, policy, strict)
    }
}

class GuiContextMenu extends GuiMenu {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiContextMenu", path = "" ? "GuiContextMenu" : path, policy, strict)
    }
}

class GuiEAIViewer2D extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiEAIViewer2D", path = "" ? "GuiEAIViewer2D" : path, policy, strict)
    }
}

class GuiEAIViewer3D extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiEAIViewer3D", path = "" ? "GuiEAIViewer3D" : path, policy, strict)
    }
}

class GuiGridView extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiGridView", path = "" ? "GuiGridView" : path, policy, strict)
    }
}

class GuiHTMLViewer extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiHTMLViewer", path = "" ? "GuiHTMLViewer" : path, policy, strict)
    }
}

class GuiPicture extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiPicture", path = "" ? "GuiPicture" : path, policy, strict)
    }
}
