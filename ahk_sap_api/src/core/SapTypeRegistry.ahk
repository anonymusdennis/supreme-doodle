#Requires AutoHotkey v2.0

class SapTypeRegistry {
    static _allowlists := SapGeneratedAllowlists.GetAllowlists()
    static _inherits := SapGeneratedAllowlists.GetInheritance()
    static _resolved := Map()
    static _proxyTypeMap := ""
    static _typeAliases := Map(
        "GuiCtrlGridView", "GuiGridView"
    )

    static DetectTypeName(comObj, fallback := "GuiUnknown") {
        try {
            typeName := comObj.Type
            if (typeName != "") {
                return typeName
            }
        } catch {
        }
        return fallback
    }

    static GetAllowlist(typeName) {
        if (this._resolved.Has(typeName)) {
            return this._resolved[typeName]
        }

        out := Map()
        this._MergeAllowlist(typeName, out)
        this._resolved[typeName] := out
        return out
    }

    static GetProxyClass(typeName) {
        if (!IsObject(this._proxyTypeMap)) {
            this._proxyTypeMap := Map(
                "GuiAbapEditor", GuiAbapEditor,
                "GuiApoGrid", GuiApoGrid,
                "GuiApplication", GuiApplication,
                "GuiBarChart", GuiBarChart,
                "GuiBox", GuiBox,
                "GuiButton", GuiButton,
                "GuiCTextField", GuiCTextField,
                "GuiCalendar", GuiCalendar,
                "GuiChart", GuiChart,
                "GuiCheckBox", GuiCheckBox,
                "GuiCollection", GuiCollection,
                "GuiColorSelector", GuiColorSelector,
                "GuiComboBox", GuiComboBox,
                "GuiComboBoxControl", GuiComboBoxControl,
                "GuiComboBoxEntry", GuiComboBoxEntry,
                "GuiComponent", GuiComponent,
                "GuiComponentCollection", GuiComponentCollection,
                "GuiConnection", GuiConnection,
                "GuiContainer", GuiContainer,
                "GuiContainerShell", GuiContainerShell,
                "GuiContextMenu", GuiContextMenu,
                "GuiCustomControl", GuiCustomControl,
                "GuiDialogShell", GuiDialogShell,
                "GuiEAIViewer2D", GuiEAIViewer2D,
                "GuiEAIViewer3D", GuiEAIViewer3D,
                "GuiEnum", GuiEnum,
                "GuiFrameWindow", GuiFrameWindow,
                "GuiGOSShell", GuiGOSShell,
                "GuiGraphAdapt", GuiGraphAdapt,
                "GuiGridView", GuiGridView,
                "GuiHTMLViewer", GuiHTMLViewer,
                "GuiInputFieldControl", GuiInputFieldControl,
                "GuiLabel", GuiLabel,
                "GuiMainWindow", GuiMainWindow,
                "GuiMap", GuiMap,
                "GuiMenu", GuiMenu,
                "GuiMenubar", GuiMenubar,
                "GuiMessageWindow", GuiMessageWindow,
                "GuiModalWindow", GuiModalWindow,
                "GuiNetChart", GuiNetChart,
                "GuiOfficeIntegration", GuiOfficeIntegration,
                "GuiOkCodeField", GuiOkCodeField,
                "GuiPasswordField", GuiPasswordField,
                "GuiPicture", GuiPicture,
                "GuiRadioButton", GuiRadioButton,
                "GuiSapChart", GuiSapChart,
                "GuiScrollContainer", GuiScrollContainer,
                "GuiScrollbar", GuiScrollbar,
                "GuiSession", GuiSession,
                "GuiSessionInfo", GuiSessionInfo,
                "GuiShell", GuiShell,
                "GuiSimpleContainer", GuiSimpleContainer,
                "GuiSplit", GuiSplit,
                "GuiSplitterContainer", GuiSplitterContainer,
                "GuiStage", GuiStage,
                "GuiStatusPane", GuiStatusPane,
                "GuiStatusbar", GuiStatusbar,
                "GuiTab", GuiTab,
                "GuiTabStrip", GuiTabStrip,
                "GuiTableColumn", GuiTableColumn,
                "GuiTableControl", GuiTableControl,
                "GuiTableRow", GuiTableRow,
                "GuiTextedit", GuiTextedit,
                "GuiTitlebar", GuiTitlebar,
                "GuiToolbar", GuiToolbar,
                "GuiTree", GuiTree,
                "GuiUserArea", GuiUserArea,
                "GuiUtils", GuiUtils,
                "GuiVComponent", GuiVComponent,
                "GuiVContainer", GuiVContainer,
                "GuiVHViewSwitch", GuiVHViewSwitch
            )
        }

        normalized := this.NormalizeTypeName(typeName)
        if (this._proxyTypeMap.Has(normalized)) {
            return this._proxyTypeMap[normalized]
        }
        return ""
    }

    static NormalizeTypeName(typeName) {
        if (typeName == "") {
            return typeName
        }
        if (this._typeAliases.Has(typeName)) {
            return this._typeAliases[typeName]
        }
        return typeName
    }

    static _MergeAllowlist(typeName, out) {
        if (this._allowlists.Has(typeName)) {
            allow := this._allowlists[typeName]
            for memberName, _ in allow {
                out[memberName] := true
            }
        }

        if (this._inherits.Has(typeName)) {
            baseType := this._inherits[typeName]
            if (baseType != "") {
                this._MergeAllowlist(baseType, out)
            }
        }
    }
}
