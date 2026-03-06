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
        try {
            proxy._com.FindById('wnd[1]//app/con[0]/ses[0]/wnd[1]/tbar[0]//app/con[0]/ses[0]/wnd[1]/tbar[0]/btn[0]').Press()
            ;dismiss popups that might be open due to se16xxl which makes an popup once the last batch is processed, and this popup blocks the next batch from being processed, and thus causes a cascade of errors
            return true

        } catch {
            ; If logging fails, there's not much we can do
            try {
                SapSession.FindById("wnd[1]/usr/chkG_NO_MORE").Selected(1)
                SapSession.FindById("wnd[1]/tbar[0]/btn[0]").Press()
                return true
                ;"se16xxl popup handled" => settings / one time popups
            }
            catch {
                return false
            }
        }
    }
}