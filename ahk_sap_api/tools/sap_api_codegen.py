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
CLASS_RE = re.compile(r"^\s*class\s+([A-Za-z0-9_]+)\s+extends\s+SapComProxy")


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
        for line in file_path.read_text(encoding="utf-8").splitlines():
            m_class = CLASS_RE.match(line)
            if m_class:
                type_name = m_class.group(1)
                break

        if not type_name or type_name not in interfaces:
            continue

        methods, properties = merged_members(type_name, interfaces)
        allowed = methods | properties

        for idx, line in enumerate(file_path.read_text(encoding="utf-8").splitlines(), start=1):
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


def main() -> int:
    parser = argparse.ArgumentParser(description="SAP GUI API codegen helpers")
    parser.add_argument("--generate-snippets", action="store_true", help="generate VSCode snippets from API docs")
    parser.add_argument("--lint-wrappers", action="store_true", help="lint src/types wrappers against API docs")
    args = parser.parse_args()

    repo_root = Path(__file__).resolve().parents[1]
    doc_path = repo_root / "sap_gui_scripting_api_760_condensed_index.md"
    interfaces = parse_interfaces(doc_path)

    exit_code = 0
    if args.generate_snippets:
        snippets_path = repo_root / "vscode" / "sap-gui-scripting.code-snippets"
        generate_snippets(interfaces, snippets_path)
        print(f"Generated snippets: {snippets_path}")

    if args.lint_wrappers:
        exit_code = lint_wrapper_members(repo_root, interfaces)

    if not args.generate_snippets and not args.lint_wrappers:
        parser.print_help()
        return 1

    return exit_code


if __name__ == "__main__":
    sys.exit(main())
