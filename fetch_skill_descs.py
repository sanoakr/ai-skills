#!/usr/bin/env python3
"""
Fetch SKILL.md descriptions from a GitHub repo via GraphQL and print as TSV.
Usage: python3 fetch_skill_descs.py <owner> <repo_name> <tree_json_file>
Output: TSV lines of "skill_name\tdescription" to stdout
"""
import sys
import json
import subprocess
import re

data = json.load(open(sys.argv[3]))
owner, name = sys.argv[1], sys.argv[2]
paths = [t["path"] for t in data.get("tree", [])
         if t["path"].endswith("/SKILL.md") or t["path"] == "SKILL.md"]

aliases, fields = [], []
for p in paths:
    alias = re.sub(r"[^a-zA-Z0-9]", "_", p.replace("/SKILL.md", "").replace("SKILL.md", "_root"))
    if alias[0].isdigit():
        alias = "s_" + alias
    aliases.append((alias, p))
    fields.append(f'{alias}: object(expression: "HEAD:{p}") {{ ... on Blob {{ text }} }}')

query = (
    '{repository(owner:"' + owner + '",name:"' + name + '"){'
    + " ".join(fields)
    + "}}"
)
result = subprocess.run(
    ["gh", "api", "graphql", "-f", f"query={query}"],
    stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True,
)
try:
    rdata = json.loads(result.stdout)
    repo_data = rdata["data"]["repository"]
except Exception:
    sys.exit(1)

rows = []
for alias, path in aliases:
    parts = path.split("/")
    skill = parts[-2] if len(parts) >= 2 else name
    obj = repo_data.get(alias)
    if obj and obj.get("text"):
        lines = obj["text"].split("\n")
        desc = ""
        in_block = False
        for line in lines:
            if line.startswith("description:"):
                val = line[len("description:"):].strip().strip('"').strip("'")
                if val == ">":
                    in_block = True
                else:
                    desc = val
                    break
            elif in_block:
                s = line.strip()
                if s and not s.startswith("-"):
                    desc = s
                    break
        rows.append(f"{skill}\t{desc[:120]}")

print("\n".join(rows))
