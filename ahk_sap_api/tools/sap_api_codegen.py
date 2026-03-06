#!/usr/bin/env python3
"""Generate SAP GUI scripting VSCode snippets and lint wrapper members."""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path


@dataclass
class InterfaceDef:
    name: str
    base: str = ""
    methods: set[str] = field(default_factory=set)
    properties: set[str] = field(default_factory=set)


INTERFACE_RE = re.compile(r"^\s*interface\s+([A-Za-z0-9_]+)(?:\s+extends\s+([A-Za-z0-9_]+))?\s*\{")
METHOD_RE = re.compile(r"^\s*([A-Za-z0-9_]+)\s*\(")
PROPERTY_RE = re.compile(r"^\s*(?:readonly\s+)?([A-Za-z0-9_]+)\s*:")
INVOKE_RE = re.compile(r'Invoke(?:Call|Get|Set)\("([A-Za-z0-9_]+)"')
CLASS_RE = re.compile(r"^\s*class\s+([A-Za-z0-9_]+)\s+extends\s+[A-Za-z0-9_]+")
CLASS_EXTENDS_RE = re.compile(r"^\s*class\s+([A-Za-z0-9_]+)\s+extends\s+([A-Za-z0-9_]+)")
RAW_COM_RE = re.compile(r"\b[A-Za-z][A-Za-z0-9_]*\._com\.[A-Za-z][A-Za-z0-9_]*\b")
RAW_ESCAPE_RE = re.compile(r"\.Raw\s*\(")
RETURN_RAW_RE = re.compile(r"^\s*return\s+.*(?:_com|\.Raw\s*\()", re.IGNORECASE)
DOC_BASENAME = "sap_gui_scripting_api_760_condensed_index.md"
CORE_BASE_CLASSES = {"SapComProxy", "SapCollectionProxy"}
KEY_WRAPPER_MEMBERS: dict[str, set[str]] = {
    "GuiApplication": {"ActiveSession", "Connections", "OpenConnection", "OpenConnectionByConnectionString", "CreateGuiCollection"},
    "GuiConnection": {"Sessions", "CloseConnection", "CloseSession", "ConnectionString"},
    "GuiSession": {"FindById", "ActiveWindow", "Info", "Busy", "StartTransaction", "SendCommand", "CreateSession"},
    "GuiSessionInfo": {"SystemName", "Transaction", "User", "Client"},
    "GuiContainer": {"Children", "FindById"},
    "GuiVContainer": {"FindByName", "FindAllByName", "FindAllByNameEx"},
    "GuiFrameWindow": {"SendVKey", "Maximize", "Restore", "Close"},
    "GuiMainWindow": {"ResizeWorkingPane", "ResizeWorkingPaneEx", "ToolbarVisible", "StatusbarVisible"},
    "GuiCollection": {"Item", "ElementAt"},
    "GuiComponentCollection": {"Item", "ElementAt"},
}
DECLARATION_ONLY_CLASSES = {"SapGuiBootstrap", "GuiComponentType"}

def find_repo_root(script_path: Path) -> Path:
    for current in [script_path.parent, *script_path.parents]:
        # Both checks ensure we found ahk_sap_api (not a parent monorepo folder):
        # the API document and the wrapper source directory must exist together.
        if (current / DOC_BASENAME).exists() and (current / "src").is_dir():
            return current
    raise FileNotFoundError(
        f"Could not locate ahk_sap_api repository root. Expected '{DOC_BASENAME}' and 'src/' in the same folder."
    )


def parse_interfaces(doc_path: Path) -> dict[str, InterfaceDef]:
    interfaces: dict[str, InterfaceDef] = {}
    current: InterfaceDef | None = None
    in_block = False

    for raw_line in doc_path.read_text(encoding="utf-8").splitlines():
        line = raw_line.rstrip()
        if line.strip().startswith("```ts"):
            in_block = True
            current = None
            continue
        if line.strip().startswith("```"):
            in_block = False
            current = None
            continue
        if not in_block:
            continue

        m = INTERFACE_RE.match(line)
        if m:
            name = m.group(1)
            base = m.group(2) or ""
            current = InterfaceDef(name=name, base=base)
            interfaces[name] = current
            continue

        if current is None or line.strip().startswith("//"):
            continue
        if line.strip() == "}":
            current = None
            continue

        mm = METHOD_RE.match(line)
        if mm:
            current.methods.add(mm.group(1))
            continue

        mp = PROPERTY_RE.match(line)
        if mp:
            current.properties.add(mp.group(1))

    return interfaces


def merged_members(type_name: str, interfaces: dict[str, InterfaceDef], stack: set[str] | None = None) -> tuple[set[str], set[str]]:
    """Resolve all members for an interface, including inherited members.

    The stack set tracks the current recursion chain to avoid cycles in inheritance
    definitions and to keep traversal safe if malformed docs introduce loops.

    Returns a tuple of (methods, properties) merged with inherited interfaces.
    """
    if stack is None:
        stack = set()
    if type_name in stack or type_name not in interfaces:
        return set(), set()

    stack.add(type_name)
    idef = interfaces[type_name]
    methods = set(idef.methods)
    properties = set(idef.properties)

    if idef.base:
        base_methods, base_properties = merged_members(idef.base, interfaces, stack)
        methods.update(base_methods)
        properties.update(base_properties)

    return methods, properties


def generate_snippets(interfaces: dict[str, InterfaceDef], out_path: Path) -> None:
    snippets: dict[str, dict[str, object]] = {}

    for type_name in sorted(interfaces):
        methods, properties = merged_members(type_name, interfaces)
        for member in sorted(methods):
            key = f"SAP {type_name}.{member}()"
            snippets[key] = {
                "prefix": f"sap.{type_name}.{member}",
                "body": [f"${{1:obj}}.{member}(${{2}})"],
                "description": f"{type_name}.{member}() from SAP GUI scripting docs",
            }
        for member in sorted(properties):
            key = f"SAP {type_name}.{member}"
            snippets[key] = {
                "prefix": f"sap.{type_name}.{member}",
                "body": [f"${{1:obj}}.{member}"],
                "description": f"{type_name}.{member} property from SAP GUI scripting docs",
            }

    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(snippets, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def lint_wrapper_members(repo_root: Path, interfaces: dict[str, InterfaceDef]) -> int:
    types_dir = repo_root / "src" / "types"
    errors: list[str] = []

    for file_path in sorted(types_dir.glob("*.ahk")):
        type_name = ""
        lines = file_path.read_text(encoding="utf-8").splitlines()
        for line in lines:
            m_class = CLASS_RE.match(line)
            if m_class:
                type_name = m_class.group(1)
                break

        if not type_name or type_name not in interfaces:
            continue

        methods, properties = merged_members(type_name, interfaces)
        allowed = methods | properties

        for idx, line in enumerate(lines, start=1):
            if "sap-lint:ignore" in line:
                continue
            for m_call in INVOKE_RE.finditer(line):
                member = m_call.group(1)
                if member not in allowed:
                    errors.append(f"{file_path}:{idx}: unknown SAP member '{member}' for {type_name}")

    if errors:
        for err in errors:
            print(err)
        return 1

    print("SAP wrapper member lint passed.")
    return 0


def lint_wrapper_coverage(repo_root: Path, interfaces: dict[str, InterfaceDef]) -> int:
    errors: list[str] = []
    types_dir = repo_root / "src" / "types"
    sap_wrapper_path = repo_root / "src" / "SapWrapper.ahk"
    sap_source_root = repo_root / "src"

    wrapper_classes: set[str] = set()
    wrapper_extends: dict[str, str] = {}
    class_files: dict[str, Path] = {}
    duplicate_classes: dict[str, list[Path]] = {}
    for file_path in sorted(types_dir.glob("*.ahk")):
        for line in file_path.read_text(encoding="utf-8").splitlines():
            m_class = CLASS_EXTENDS_RE.match(line)
            if m_class:
                class_name = m_class.group(1)
                duplicate_classes.setdefault(class_name, []).append(file_path)
                wrapper_classes.add(class_name)
                wrapper_extends[class_name] = m_class.group(2)
                class_files[class_name] = file_path

    for class_name, files in sorted(duplicate_classes.items()):
        if len(files) > 1:
            refs = ", ".join(str(p) for p in files)
            errors.append(f"duplicate wrapper class definition for {class_name}: {refs}")

    documented_gui_types = {name for name in interfaces if name.startswith("Gui")}
    missing_types = sorted(documented_gui_types - wrapper_classes)
    for type_name in missing_types:
        errors.append(f"missing wrapper class for documented SAP type: {type_name}")

    if sap_wrapper_path.exists():
        include_lines = [
            line.split("#Include", 1)[1].strip()
            for line in sap_wrapper_path.read_text(encoding="utf-8").splitlines()
            if line.strip().startswith("#Include ")
        ]
        includes = set(include_lines)
        for type_file in sorted(types_dir.glob("*.ahk")):
            expected = f"types/{type_file.name}"
            if expected not in includes:
                errors.append(f"SapWrapper.ahk missing include: {expected}")

        include_index = {name: idx for idx, name in enumerate(include_lines)}
        for class_name, base_name in wrapper_extends.items():
            # Core bases are loaded before all type includes, so they do not
            # participate in inter-type include ordering checks.
            if base_name in CORE_BASE_CLASSES:
                continue
            class_include = f"types/{class_files[class_name].name}"
            base_file = class_files.get(base_name)
            if base_file is None:
                continue
            base_include = f"types/{base_file.name}"
            if include_index.get(base_include, -1) > include_index.get(class_include, -1):
                errors.append(f"SapWrapper.ahk include order risk: {base_include} must come before {class_include}")
    else:
        errors.append("SapWrapper.ahk not found in src/")

    for file_path in sorted(sap_source_root.rglob("*.ahk")):
        if file_path.name == "SapComProxy.ahk":
            continue
        in_block_comment = False
        for idx, line in enumerate(file_path.read_text(encoding="utf-8").splitlines(), start=1):
            source_line = line
            if in_block_comment:
                if "*/" in source_line:
                    source_line = source_line.split("*/", 1)[1]
                    in_block_comment = False
                else:
                    continue

            while "/*" in source_line:
                before, after = source_line.split("/*", 1)
                if "*/" in after:
                    after = after.split("*/", 1)[1]
                    source_line = before + " " + after
                else:
                    source_line = before
                    in_block_comment = True
                    break

            source_line = source_line.split(";", 1)[0]
            if RAW_COM_RE.search(source_line):
                errors.append(f"{file_path}:{idx}: direct raw COM member access bypasses proxy pipeline")

    for file_path in sorted(types_dir.glob("*.ahk")):
        for idx, line in enumerate(file_path.read_text(encoding="utf-8").splitlines(), start=1):
            if RAW_ESCAPE_RE.search(line):
                errors.append(f"{file_path}:{idx}: Raw() usage inside wrapper internals bypasses proxy pipeline")
            if RETURN_RAW_RE.search(line):
                errors.append(f"{file_path}:{idx}: wrapper may return raw COM object instead of wrapped proxy")

    d_path = repo_root / "src" / "SapWrapper.d.ahk"
    if d_path.exists():
        d_classes = set()
        for line in d_path.read_text(encoding="utf-8").splitlines():
            m_class = CLASS_RE.match(line)
            if m_class:
                d_classes.add(m_class.group(1))
        missing_decls = sorted(wrapper_classes - d_classes)
        extra_decls = sorted(d_classes - wrapper_classes - DECLARATION_ONLY_CLASSES)
        for class_name in missing_decls:
            errors.append(f"SapWrapper.d.ahk missing class declaration: {class_name}")
        for class_name in extra_decls:
            errors.append(f"SapWrapper.d.ahk has unknown class declaration: {class_name}")
    else:
        errors.append("SapWrapper.d.ahk not found in src/")

    for class_name, required_members in KEY_WRAPPER_MEMBERS.items():
        file_path = class_files.get(class_name)
        if file_path is None:
            continue
        content = file_path.read_text(encoding="utf-8")
        for member in sorted(required_members):
            if re.search(rf"\b{re.escape(member)}\b", content) is None:
                errors.append(f"{file_path}: missing expected documented member: {class_name}.{member}")

    bootstrap_file = repo_root / "src" / "core" / "SapGuiBootstrap.ahk"
    enum_file = repo_root / "src" / "generated" / "GuiComponentType.ahk"
    if not bootstrap_file.exists():
        errors.append("missing non-Gui bootstrap representation: src/core/SapGuiBootstrap.ahk")
    if not enum_file.exists():
        errors.append("missing non-Gui enum representation: src/generated/GuiComponentType.ahk")

    if errors:
        for err in errors:
            print(err)
        return 1

    print("SAP wrapper coverage lint passed.")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="SAP GUI API codegen helpers")
    parser.add_argument("--generate-snippets", action="store_true", help="generate VSCode snippets from API docs")
    parser.add_argument("--lint-wrappers", action="store_true", help="lint src/types wrappers against API docs")
    parser.add_argument("--lint-coverage", action="store_true", help="lint wrapper type coverage and include wiring")
    args = parser.parse_args()

    repo_root = find_repo_root(Path(__file__).resolve())
    doc_path = repo_root / DOC_BASENAME
    interfaces = parse_interfaces(doc_path)

    exit_code = 0
    if args.generate_snippets:
        snippets_path = repo_root / "vscode" / "sap-gui-scripting.code-snippets"
        generate_snippets(interfaces, snippets_path)
        print(f"Generated snippets: {snippets_path}")

    if args.lint_wrappers:
        exit_code = lint_wrapper_members(repo_root, interfaces)
    if args.lint_coverage:
        coverage_exit_code = lint_wrapper_coverage(repo_root, interfaces)
        exit_code = exit_code or coverage_exit_code

    if not args.generate_snippets and not args.lint_wrappers and not args.lint_coverage:
        parser.print_help()
        return 1

    return exit_code


if __name__ == "__main__":
    sys.exit(main())
