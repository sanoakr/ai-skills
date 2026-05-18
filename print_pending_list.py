#!/usr/bin/env python3
"""
Print pending skill list from TSV, aligned with repo file tree.
Usage: python3 print_pending_list.py <repo_name> <tree_json_file> <tsv_file>
"""
import sys
import json

data = json.load(open(sys.argv[2]))
repo_name = sys.argv[1]
tsv_path = sys.argv[3]

desc_map = {}
with open(tsv_path) as f:
    for line in f:
        line = line.strip()
        if "\t" in line:
            k, v = line.split("\t", 1)
            desc_map[k.strip()] = v.strip()

paths = [t["path"] for t in data.get("tree", [])
         if t["path"].endswith("/SKILL.md") or t["path"] == "SKILL.md"]

cats = set()
for p in paths:
    parts = p.split("/")
    if len(parts) == 3:
        cats.add(parts[0])
use_category = len(cats) > 1

prev_cat = None
for path in sorted(paths):
    parts = path.split("/")
    if len(parts) == 1:
        skill = repo_name
        d = desc_map.get(skill, "")
        print(f"  [-]  {skill:<28}  {d}")
    elif len(parts) == 2:
        skill = parts[0]
        d = desc_map.get(skill, "")
        print(f"  [-]  {skill:<28}  {d}")
    elif len(parts) == 3:
        cat, skill = parts[0], parts[1]
        d = desc_map.get(skill, "")
        if use_category:
            if cat != prev_cat:
                print(f"  [{cat}]")
                prev_cat = cat
            print(f"    [-]  {skill:<26}  {d}")
        else:
            print(f"  [-]  {skill:<28}  {d}")
