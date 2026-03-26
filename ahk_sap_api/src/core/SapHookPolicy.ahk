#Requires AutoHotkey v2.0

class SapHookPolicy {
    static RECONNECT_COOLDOWN_MS := 3000
    static SAP_WINDOW_ID_PREFIX := "/wnd["

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
        loop {
            app := ""
            try {
                app := SapGuiBootstrap.GetScriptingEngineFromROT()
            } catch {
                app := ""
            }

            sessions := this._EnumerateSessions(app)
            if (sessions.Length > 0) {
                break
            }

            choice := MsgBox(
                "SAP GUI appears disconnected or closed.`n"
                . "Please open SAP GUI and log in, then click Yes to retry.",
                "SAP GUI reconnect required",
                "YN Icon!"
            )
            if (choice != "Yes") {
                return ""
            }
        }

        prompt := "Select replacement SAP session:`n`n" this._BuildSessionPrompt(sessions)
        while true {
            ib := InputBox(prompt, "SAP GUI reconnect", "w700 h420", "1")
            if (ib.Result != "OK") {
                return ""
            }
            try {
                idx := Integer(ib.Value)
            } catch {
                MsgBox("Invalid selection '" ib.Value "'. Please enter a valid number.")
                continue
            }
            if (idx >= 1 && idx <= sessions.Length) {
                return sessions[idx]
            }
            MsgBox("Invalid selection. Enter a number between 1 and " sessions.Length ".")
        }
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
