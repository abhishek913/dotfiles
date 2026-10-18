#!/usr/bin/env python3
"""Merge the keys from vscode/terminal.json into VS Code's settings.json.

Used by install.sh so the VS Code terminal always matches Ghostty, without
touching any of your other settings. Safe to run again and again.

settings.json may contain comments and trailing commas (VS Code allows them);
they're handled here. If the file changes, it's rewritten as plain JSON, so
comments in it are not kept.

Usage: merge-settings.py <settings.json> <terminal.json>
"""
import json
import sys


def strip_jsonc(text):
    """Remove // and /* */ comments and trailing commas, leaving strings alone."""
    out = []
    i, n = 0, len(text)
    in_str = False
    while i < n:
        c = text[i]
        if in_str:
            out.append(c)
            if c == "\\" and i + 1 < n:
                out.append(text[i + 1])
                i += 2
                continue
            if c == '"':
                in_str = False
            i += 1
            continue
        if c == '"':
            in_str = True
            out.append(c)
            i += 1
        elif text.startswith("//", i):
            while i < n and text[i] != "\n":
                i += 1
        elif text.startswith("/*", i):
            end = text.find("*/", i + 2)
            i = n if end == -1 else end + 2
        else:
            out.append(c)
            i += 1
    cleaned = "".join(out)
    # trailing commas before } or ] (outside strings, which are already intact)
    result = []
    in_str = False
    i, n = 0, len(cleaned)
    while i < n:
        c = cleaned[i]
        if in_str:
            result.append(c)
            if c == "\\" and i + 1 < n:
                result.append(cleaned[i + 1])
                i += 2
                continue
            if c == '"':
                in_str = False
            i += 1
            continue
        if c == '"':
            in_str = True
        elif c == ",":
            j = i + 1
            while j < n and cleaned[j] in " \t\r\n":
                j += 1
            if j < n and cleaned[j] in "}]":
                i += 1
                continue
        result.append(c)
        i += 1
    return "".join(result)


def main():
    settings_path, overlay_path = sys.argv[1], sys.argv[2]
    try:
        with open(settings_path, encoding="utf-8") as f:
            raw = f.read()
    except FileNotFoundError:
        raw = "{}"
    settings = json.loads(strip_jsonc(raw) or "{}")
    with open(overlay_path, encoding="utf-8") as f:
        overlay = json.loads(strip_jsonc(f.read()))

    merged = dict(settings)
    for key, value in overlay.items():
        if isinstance(value, dict) and isinstance(merged.get(key), dict):
            merged[key] = {**merged[key], **value}  # e.g. colorCustomizations: keep yours, add terminal colors
        else:
            merged[key] = value

    if merged == settings:
        print("unchanged")
        return
    with open(settings_path, "w", encoding="utf-8") as f:
        json.dump(merged, f, indent=2, ensure_ascii=False)
        f.write("\n")
    print("updated")


if __name__ == "__main__":
    main()
