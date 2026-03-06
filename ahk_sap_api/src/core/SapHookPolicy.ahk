#Requires AutoHotkey v2.0

class SapHookPolicy {
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
}
