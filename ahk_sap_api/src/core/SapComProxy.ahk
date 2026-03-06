#Requires AutoHotkey v2.0

class SapComProxy {
    static _typeClassMap := ""

    __New(comObj, typeName := "GuiUnknown", path := "", policy := "", strict := false) {
        this.DefineProp("_com", {Value: comObj})
        this.DefineProp("_typeName", {Value: typeName})
        this.DefineProp("_path", {Value: path = "" ? typeName : path})
        this.DefineProp("_policy", {Value: IsObject(policy) ? policy : SapHookPolicy()})
        this.DefineProp("_strict", {Value: strict})
        this.DefineProp("_allow", {Value: SapTypeRegistry.GetAllowlist(typeName)})
    }

    __Get(name, params) {
        if (SubStr(name, 1, 1) = "_") {
            if (this.HasOwnProp(name)) {
                return this.GetOwnPropDesc(name).Value
            }
            throw PropertyError("Unknown internal property.", -1, name)
        }
        value := this.InvokeGet(name)
        if (params.Length > 0) {
            return value[params*]
        }
        return value
    }

    __Set(name, params, value) {
        if (SubStr(name, 1, 1) = "_") {
            throw PropertyError("Internal property is read-only.", -1, name)
        }
        if (params.Length > 0) {
            target := this.InvokeGet(name)
            target[params*] := value
            return value
        }
        return this.InvokeSet(name, value)
    }

    __Call(name, params) {
        return this.InvokeCall(name, params*)
    }

    Raw() {
        return this._com
    }

    InvokeGet(member) {
        this._EnsureMemberAllowed(member)
        args := []
        this._CallPolicy("On_Call", "get", member, args)

        retries := 0
        maxRetries := this._GetMaxRetries()

        while true {
            try {
                result := this._com.%member%
                break
            } catch {
                retries += 1
                if (this._HandleError("get", member, args, retries, maxRetries)) {
                    continue
                }
                throw Error(this._BuildError("get", member))
            }
        }

        wrapped := this._WrapResult(member, "get", result, args)
        this._CallPolicy("After_Call", "get", member, wrapped)
        return wrapped
    }

    InvokeSet(member, value) {
        this._EnsureMemberAllowed(member)
        args := [value]
        this._CallPolicy("On_Call", "set", member, args)

        retries := 0
        maxRetries := this._GetMaxRetries()

        while true {
            try {
                this._com.%member% := value
                break
            } catch {
                retries += 1
                if (this._HandleError("set", member, args, retries, maxRetries)) {
                    continue
                }
                throw Error(this._BuildError("set", member))
            }
        }

        this._CallPolicy("After_Call", "set", member, value)
        return value
    }

    InvokeCall(member, args*) {
        this._EnsureMemberAllowed(member)
        this._CallPolicy("On_Call", "call", member, args)

        retries := 0
        maxRetries := this._GetMaxRetries()

        while true {
            try {
                result := this._com.%member%(args*)
                break
            } catch {
                retries += 1
                if (this._HandleError("call", member, args, retries, maxRetries)) {
                    continue
                }
                throw Error(this._BuildError("call", member))
            }
        }

        wrapped := this._WrapResult(member, "call", result, args)
        this._CallPolicy("After_Call", "call", member, wrapped)
        return wrapped
    }
    _GetMaxRetries() {
        try {
            if (IsObject(this._policy) && this._policy.HasProp("MaxRetries"))
                return this._policy.MaxRetries
        } catch {
        }
        return 25
    }
     ; now returns boolean: true=retry, false=stop
     _HandleError(op, member, args, retries := 0, maxRetries := 0) {
        if (maxRetries && retries > maxRetries) {
            ; stop retrying
            return false
        }

        retry := false
        r := this._CallPolicy("On_Error", op, member, args)

        ; policy can return true/false (or empty)
        if (r = true) {
            retry := true
        }
        return retry
    }

    _WrapResult(member, op, value, args) {
        if (!this._IsComObject(value)) {
            return value
        }

        typeName := SapTypeRegistry.DetectTypeName(value)
        childPath := this._BuildPath(member, op, args)
        if (!IsObject(SapComProxy._typeClassMap)) {
            SapComProxy._typeClassMap := Map(
                "GuiCollection", GuiCollection,
                "GuiComponentCollection", GuiComponentCollection,
                "GuiApplication", GuiApplication,
                "GuiConnection", GuiConnection,
                "GuiSession", GuiSession,
                "GuiFrameWindow", GuiFrameWindow,
                "GuiVComponent", GuiVComponent
            )
        }
        if (SapComProxy._typeClassMap.Has(typeName)) {
            proxyClass := SapComProxy._typeClassMap[typeName]
            return proxyClass(value, this._policy, this._strict, childPath)
        }

        return SapComProxy(value, typeName, childPath, this._policy, this._strict)
    }

    _BuildPath(member, op, args) {
        if (op = "call" && member = "FindById" && args.Length >= 1) {
            childId := args[1]
            return this._JoinPath(this._path, childId)
        }
        if (op = "call" && member = "Item" && args.Length >= 1) {
            return this._JoinPath(this._path, "[" args[1] "]")
        }
        return this._JoinPath(this._path, member)
    }

    _JoinPath(basePath, child) {
        left := RTrim(basePath, "/")
        right := LTrim(child, "/")
        if (left = "") {
            return right
        }
        if (right = "") {
            return left
        }
        return left "/" right
    }

    _IsComObject(value) {
        try {
            t := ComObjType(value)
            return t != ""
        } catch {
            return false
        }
    }

    _EnsureMemberAllowed(member) {
        if (!this._strict) {
            return
        }
        if (this._allow.Has(member)) {
            return
        }
        throw Error("Member not allowlisted: " this._typeName "." member)
    }

    _BuildError(op, member) {
        return "SAP COM " op " failed: " this._typeName "." member " @ " this._path
            . " (LastError=" A_LastError ", may be unrelated for COM)"
    }



    ; IMPORTANT: return policy return values instead of discarding them
    _CallPolicy(methodName, op, member, data) {
        try {
            if (methodName = "After_Call") {
                return this._policy.After_Call(op, this._typeName, member, this._path, data, this)
            } else if (methodName = "On_Error") {
                return this._policy.On_Error(op, this._typeName, member, this._path, data, this)
            } else {
                return this._policy.On_Call(op, this._typeName, member, this._path, data, this)
            }
        } catch {
            return false
        }
    }
}
