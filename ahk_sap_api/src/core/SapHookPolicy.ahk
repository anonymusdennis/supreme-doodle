#Requires AutoHotkey v2.0

class SapHookPolicy {
    static RECONNECT_COOLDOWN_MS := 3000
    static SAP_WINDOW_ID_PREFIX := "/wnd["
    static SESSION_MAIN_WINDOW_PATH := "wnd[0]"
    static MAX_PARENT_TRAVERSAL_STEPS := 15

    __New(reconnectCooldownMs := unset) {
        this._recentReconnectAttempts := Map()
        this._reconnectCooldownMs := IsSet(reconnectCooldownMs)
            ? reconnectCooldownMs
            : SapHookPolicy.RECONNECT_COOLDOWN_MS
    }

    On_Call(op, typeName, member, path, args, proxy) {
    }

    After_Call(op, typeName, member, path, result, proxy) {
    }

    On_Error(op, typeName, member, path, args, proxy) {
        ; MsgBox("SAP wrapper call failed.`n"
        ;     . "Operation: " op "`n"
        ;     . "Type: " typeName "`n"
        ;     . "Member: " member "`n"
        ;     . "Path: " path "`n"
        ;     . "LastError (may be unrelated for COM): " A_LastError)
        if (!IsObject(proxy)) {
            return false
        }

        ; Dismiss generic popup confirm first.
        if (this._TryCloseExpressPopup(proxy)) {
            return true
        }

        ; Then try one-time "do not show again" popup variant.
        if (this._TryCloseExpressPopup(proxy, true)) {
            return true
        }

        ; If SAP GUI/session vanished, offer manual replacement and retry once.
        if (this._TryReconnectProxy(proxy, typeName, path)) {
            return true
        }

        return false
    }

    _TryCloseExpressPopup(proxy, setNoMore := false) {
        try {
            if (setNoMore) {
                noMoreCheckbox := proxy.InvokeCall("FindById", "wnd[1]/usr/chkG_NO_MORE")
                noMoreCheckbox.InvokeSet("Selected", true)
            }

            okButton := proxy.InvokeCall("FindById", "wnd[1]/tbar[0]/btn[0]")
            okButton.InvokeCall("Press")
            ; If popup close succeeded, caller retries the original action.
            return true
        } catch {
            return false
        }
    }

    _TryReconnectProxy(proxy, typeName, path) {
        if (!this._ShouldAttemptReconnect(proxy, typeName, path)) {
            return false
        }

        attemptKey := this._BuildReconnectKey(proxy, path)
        if (this._IsReconnectCoolingDown(attemptKey)) {
            return false
        }

        replacementSession := this._PromptForReplacementSession()
        if (!IsObject(replacementSession)) {
            return false
        }

        replacementCom := this._ResolveReplacementCom(proxy, typeName, path, replacementSession)
        if (!IsObject(replacementCom)) {
            MsgBox("Could not map the current SAP object to the selected replacement session.")
            return false
        }

        try {
            proxy._com := replacementCom
            this._recentReconnectAttempts[attemptKey] := A_TickCount
            return true
        } catch {
            return false
        }
    }

    _ShouldAttemptReconnect(proxy, typeName, path) {
        if (!this._LooksLikeSessionPath(path)) {
            return false
        }

        if (!this._IsProxyComAvailable(proxy)) {
            return true
        }

        session := this._GetOwningSession(proxy, typeName)
        if (!IsObject(session)) {
            return true
        }

        return !this._IsSessionResponsive(session)
    }

    _LooksLikeSessionPath(path) {
        if (path = "") {
            return false
        }
        return InStr(path, SapHookPolicy.SAP_WINDOW_ID_PREFIX) > 0
    }

    _GetOwningSession(proxy, typeName) {
        if (!IsObject(proxy)) {
            return ""
        }

        try {
            raw := proxy.Raw()
        } catch {
            return ""
        }

        if (!IsObject(raw)) {
            return ""
        }

        if (typeName = "GuiSession") {
            return raw
        }

        try {
            current := raw
            step := 0
            maxTraversalSteps := SapHookPolicy.MAX_PARENT_TRAVERSAL_STEPS
            while (step < maxTraversalSteps && IsObject(current)) {
                try {
                    if (current.Type = "GuiSession") {
                        return current
                    }
                } catch {
                }
                try {
                    current := current.Parent
                } catch {
                    break
                }
                step += 1
            }
        } catch {
        }

        return ""
    }

    _IsSessionResponsive(session) {
        if (!IsObject(session)) {
            return false
        }

        try {
            wnd := session.FindById(SapHookPolicy.SESSION_MAIN_WINDOW_PATH, false)
            return IsObject(wnd)
        } catch {
            return false
        }
    }

    _BuildReconnectKey(proxy, path) {
        try {
            return ObjPtr(proxy) ":" path
        } catch {
            return path
        }
    }

    _IsReconnectCoolingDown(attemptKey) {
        if (!this._recentReconnectAttempts.Has(attemptKey)) {
            return false
        }
        elapsed := A_TickCount - this._recentReconnectAttempts[attemptKey]
        return elapsed < this._reconnectCooldownMs
    }

    _PromptForReplacementSession() {
        app := ""
        try {
            app := SapGuiBootstrap.GetScriptingEngineFromROT()
        } catch {
            app := ""
        }
        return this._ShowSessionSelectionDialog(app)
    }

    _EnumerateSessions(app) {
        sessions := []
        if (!IsObject(app)) {
            return sessions
        }

        conCount := this._TryGetCollectionCount(app.Children)
        if (conCount <= 0) {
            return sessions
        }

        conIdx := 0
        while (conIdx < conCount) {
            try {
                con := app.Children.Item(conIdx)
                sesCount := this._TryGetCollectionCount(con.Children)
                sesIdx := 0
                while (sesIdx < sesCount) {
                    try {
                        sessions.Push(con.Children.Item(sesIdx))
                    } catch {
                    }
                    sesIdx += 1
                }
            } catch {
            }
            conIdx += 1
        }

        return sessions
    }

    _TryGetCollectionCount(col) {
        try {
            return col.Count
        } catch {
            try {
                return col.Length
            } catch {
                return 0
            }
        }
    }

    _BuildSessionPrompt(sessions) {
        text := ""
        idx := 1
        for _, session in sessions {
            info := this._DescribeSession(session)
            text .= idx ") " info "`n"
            idx += 1
        }
        return text
    }

    _ShowSessionSelectionDialog(app) {
        context := {
            app: app,
            sessions: this._EnumerateSessions(app),
            selectedIndex: 0,
            resultSession: "",
            gui: "",
            sessionControls: []
        }

        reconnectGui := Gui("+Resize", "SAP GUI reconnect")
        reconnectGui.MarginX := 12
        reconnectGui.MarginY := 12
        reconnectGui.Add("Text", "xm w680", "Select replacement SAP session:")
        listContainer := reconnectGui.Add("GroupBox", "xm y+8 w680 h300", "Available sessions")
        btnRefresh := reconnectGui.Add("Button", "xm y+10 w90", "Refresh")
        btnOk := reconnectGui.Add("Button", "x+10 yp w90 Default", "OK")
        btnCancel := reconnectGui.Add("Button", "x+10 yp w90", "Cancel")

        context.gui := reconnectGui
        context.listContainer := listContainer
        context.btnOk := btnOk

        _RenderSessions(*) {
            for _, ctrl in context.sessionControls {
                try ctrl.Destroy()
            }
            context.sessionControls := []
            context.selectedIndex := 0

            context.sessions := this._EnumerateSessions(context.app)
            yPos := 52
            if (context.sessions.Length = 0) {
                msg := reconnectGui.Add("Text", "x24 y" yPos " w650 cRed", "No SAP sessions found. Open SAP GUI/login, then click Refresh.")
                context.sessionControls.Push(msg)
                context.btnOk.Enabled := false
                return
            }

            context.btnOk.Enabled := true
            idx := 1
            for _, session in context.sessions {
                label := idx ") " this._DescribeSession(session)
                opt := "x24 y" yPos " w650"
                if (idx = 1) {
                    opt .= " Checked"
                    context.selectedIndex := 1
                }
                radio := reconnectGui.Add("Radio", opt, label)
                radio.OnEvent("Click", ObjBindMethod(this, "_OnReconnectSessionRadioClick", context, idx))
                context.sessionControls.Push(radio)
                yPos += 24
                idx += 1
            }
        }

        _DoRefresh(*) {
            try {
                context.app := SapGuiBootstrap.GetScriptingEngineFromROT()
            } catch {
                context.app := ""
            }
            _RenderSessions()
        }

        _DoOk(*) {
            if (context.selectedIndex < 1 || context.selectedIndex > context.sessions.Length) {
                MsgBox("Please select a SAP session first.", "SAP GUI reconnect", "Icon!")
                return
            }
            context.resultSession := context.sessions[context.selectedIndex]
            reconnectGui.Destroy()
        }

        _DoCancel(*) {
            context.resultSession := ""
            reconnectGui.Destroy()
        }

        reconnectGui.OnEvent("Close", _DoCancel)
        btnRefresh.OnEvent("Click", _DoRefresh)
        btnOk.OnEvent("Click", _DoOk)
        btnCancel.OnEvent("Click", _DoCancel)
        _RenderSessions()
        reconnectGui.Show("w710 h420")
        WinWaitClose(reconnectGui)
        return context.resultSession
    }

    _OnReconnectSessionRadioClick(context, selectedIndex, *) {
        context.selectedIndex := selectedIndex
    }

    _IsProxyComAvailable(proxy) {
        if (!IsObject(proxy)) {
            return false
        }

        try {
            raw := proxy.Raw()
            if (!IsObject(raw)) {
                return false
            }
            _ := raw.Type
            return true
        } catch {
            return false
        }
    }

    _DescribeSession(session) {
        try {
            info := session.Info
            return "System=" info.SystemName
                . " Client=" info.Client
                . " User=" info.User
                . " Tx=" info.Transaction
        } catch {
            return "Session (details unavailable)"
        }
    }

    _ResolveReplacementCom(proxy, typeName, path, replacementSession) {
        if (!IsObject(replacementSession)) {
            return ""
        }

        if (typeName = "GuiSession") {
            return replacementSession
        }
        if (typeName = "GuiConnection") {
            try {
                return replacementSession.Parent
            } catch {
            }
        }
        if (typeName = "GuiApplication") {
            try {
                return replacementSession.Parent.Parent
            } catch {
            }
        }

        elementId := this._ExtractSapElementId(path)
        if (elementId != "") {
            try {
                return replacementSession.FindById(elementId, false)
            } catch {
            }
        }

        oldId := this._TryReadProxyElementId(proxy)
        if (oldId != "") {
            try {
                return replacementSession.FindById(oldId, false)
            } catch {
            }
        }

        return ""
    }

    _ExtractSapElementId(path) {
        if (path = "") {
            return ""
        }
        needle := SapHookPolicy.SAP_WINDOW_ID_PREFIX
        pos := InStr(path, needle)
        if (!pos) {
            return ""
        }
        return SubStr(path, pos)
    }

    _TryReadProxyElementId(proxy) {
        try {
            raw := proxy.Raw()
            return raw.Id
        } catch {
            return ""
        }
    }
}
