#!/usr/bin/env python3
import argparse
import json
import os
import re
import sys
from pathlib import Path
from urllib.parse import parse_qs, urlencode, urlparse


def supabase_url():
    query = {"read_only": "true"}
    if os.environ.get("SUPABASE_PROJECT_REF"):
        query["project_ref"] = os.environ["SUPABASE_PROJECT_REF"]
    if os.environ.get("SUPABASE_MCP_FEATURES"):
        query["features"] = os.environ["SUPABASE_MCP_FEATURES"]
    return "https://mcp.supabase.com/mcp?" + urlencode(query)


PROFILES = {
    "vercel": {"url": "https://mcp.vercel.com"},
    "supabase": {"url": supabase_url()},
    "stripe": {"command": "npx", "args": ["-y", "@stripe/mcp@latest"], "env_vars": ["STRIPE_SECRET_KEY"]},
}
KNOWN = sorted(PROFILES)


def profile_names(name):
    if name == "all":
        return KNOWN
    if name in PROFILES:
        return [name]
    sys.exit("unknown profile: %s\nknown profiles: %s, all" % (name, ", ".join(KNOWN)))


def codex_without(names):
    path = Path(".codex/config.toml")
    kept, lines, i = [], path.read_text().splitlines() if path.exists() else [], 0
    while i < len(lines):
        match = re.match(r"\[mcp_servers\.([^\]]+)\]", lines[i])
        if match and match.group(1) in names:
            i += 1
            while i < len(lines) and not lines[i].startswith("["):
                i += 1
            continue
        kept.append(lines[i])
        i += 1
    return "\n".join(kept).rstrip()


def codex_block(name, entry):
    lines = ["[mcp_servers.%s]" % name]
    if "url" in entry:
        lines.append("url = " + json.dumps(entry["url"]))
    else:
        lines += ["command = " + json.dumps(entry["command"]), "args = " + json.dumps(entry["args"])]
        if entry.get("env_vars"):
            lines.append("env_vars = " + json.dumps(entry["env_vars"]))
    return "\n".join(lines)


def mutate(args, action):
    names = profile_names(args.profile.lower())
    base = codex_without(set(names))
    blocks = [] if action == "remove" else [codex_block(name, PROFILES[name]) for name in names]
    body = "\n\n".join(part for part in [base, "\n\n".join(blocks)] if part.strip()).rstrip()
    if args.dry_run:
        print("DRY RUN .codex/config.toml")
        print(body)
    else:
        Path(".codex").mkdir(exist_ok=True)
        Path(".codex/config.toml").write_text((body + "\n") if body else "")
        print("  wrote .codex/config.toml")


def check(args):
    profile = (args.profile or "").lower()
    if profile and profile not in KNOWN + ["all"]:
        sys.exit("unknown profile: %s\nknown profiles: %s, all" % (profile, ", ".join(KNOWN)))
    codex_text = Path(".codex/config.toml").read_text() if Path(".codex/config.toml").exists() else ""
    codex = set(re.findall(r"^\[mcp_servers\.([^\].]+)\]", codex_text, re.M))
    expected = set(KNOWN if profile == "all" else [profile] if profile else [name for name in KNOWN if name in codex])
    if not expected:
        print("PASS no optional profiles installed\n\nProfile check passed: 0 warning(s)")
        return

    failures, warnings, checks = [], [], []
    for name in sorted(expected):
        if name not in codex:
            failures.append("Codex profile missing: " + name)
            continue
        if name == "stripe" and "STRIPE_SECRET_KEY" not in os.environ:
            (failures if args.strict_auth else warnings).append("Stripe profile needs STRIPE_SECRET_KEY in environment before use")
        if name == "supabase":
            match = re.search(r"^\[mcp_servers\.supabase\]\n(?P<body>.*?)(?=^\[|\Z)", codex_text, re.M | re.S)
            url_match = re.search(r'url = "([^"]+)"', match.group("body") if match else "")
            query = parse_qs(urlparse(url_match.group(1) if url_match else "").query)
            if query.get("read_only", [""])[0] != "true":
                failures.append("Supabase profile must be read_only=true")
            if "project_ref" not in query:
                warnings.append("Supabase profile has no project_ref; set SUPABASE_PROJECT_REF before applying when you want one project pinned")
        if name == "vercel":
            checks.append("Vercel profile uses hosted OAuth MCP; run the client MCP auth flow if prompted")
        print("PASS profile present in Codex config: " + name)

    for item in checks:
        print("CHECK " + item)
    for item in warnings:
        print("WARN " + item)
    for item in failures:
        print("FAIL " + item)
    print()
    if failures:
        print("Profile check failed: %s failure(s), %s warning(s)" % (len(failures), len(warnings)))
        sys.exit(1)
    print("Profile check passed: %s warning(s)" % len(warnings))


def main():
    root = argparse.ArgumentParser()
    sub = root.add_subparsers(dest="cmd", required=True)
    for cmd in ("apply", "remove"):
        parser = sub.add_parser(cmd)
        parser.add_argument("profile")
        parser.add_argument("--tool", choices=("codex",), default="codex")
        parser.add_argument("--dry-run", action="store_true")
    parser = sub.add_parser("check")
    parser.add_argument("profile", nargs="?")
    parser.add_argument("--strict-auth", action="store_true")
    ns = root.parse_args()
    mutate(ns, ns.cmd) if ns.cmd in {"apply", "remove"} else check(ns)


if __name__ == "__main__":
    main()
