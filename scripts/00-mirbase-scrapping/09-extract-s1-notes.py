#!/usr/bin/env python3
# ~~~~~ EXTRACT THE CELL NOTES FROM TABLE S1 ~~~~~
#
# Table S1 carries hand-written notes on individual cells (the yellow corner in
# Google Sheets). They hold curation decisions that exist nowhere else: why a
# name was changed, where a value came from, what a paper actually reported.
# This script pulls every note out into a flat CSV so the notes can be read,
# searched and joined to the literature tables.
#
# One row per note, with:
#   - where it is          : sheet, cell, row, column letter, column name
#   - what it is attached to: the cell's own value
#   - the row's context    : mirna_name, acc_mirb, species, citation_exp,
#                            doi_exp, infection
#   - the note text
#   - row_mirna_in_note    : TRUE  the note names the same miRNA as its row
#                            FALSE the note names a different miRNA
#                            NA    the note names no miRNA
#     FALSE is worth checking by hand: the usual cause is that the sheet was
#     sorted after the note was written, so the note no longer sits on the row
#     it was about.
#
# Google Sheets has two kinds of annotation and only one of them is a "note":
# notes (Insert > Note) export to xlsx and are read here. Threaded COMMENTS
# (Insert > Comment, with replies) do not survive the xlsx export and are not
# in this CSV.
#
# Input  : an .xlsx export of Table S1. Default is the copy in this repo;
#          pass a path to use a fresh export of the Google Sheet instead
#          (File > Download > Microsoft Excel).
# Output : results/00-mirbase-v23/s1-cell-notes.csv
#
# Run from the project root:
#   python3 scripts/00-mirbase-scrapping/09-extract-s1-notes.py
#   python3 scripts/00-mirbase-scrapping/09-extract-s1-notes.py <in.xlsx> <out.csv>

import csv
import os
import re
import sys

import openpyxl
from openpyxl.utils import get_column_letter

IN_DEFAULT = "databases/00-mirbase-scrapping/table-s1-sheet-export-2026-11-26.xlsx"
OUT_DEFAULT = "results/00-mirbase-v23/s1-cell-notes.csv"

# Columns of the row that give a note its context, when the sheet has them.
CONTEXT = ["mirna_name", "acc_mirb", "species", "citation_exp", "doi_exp", "infection"]

# miRNA names as they are written in the notes: miR-276-3p, let-7-5p, bantam,
# mir-2940, miR-11900. Deliberately loose, then normalised below.
MIRNA_RE = re.compile(r"\b(?:(?:aae|aal|bmo|cqu|dme|hsa)-)?"
                      r"(?:miR|mir|let|bantam|lin)-?[0-9a-zA-Z]*"
                      r"(?:-[0-9]+)*(?:-[35]p)?\b")


def norm(name):
    """miRNA name -> comparable core: lowercase, no species prefix, no arm."""
    if not name:
        return ""
    n = name.strip().lower()
    n = re.sub(r"^(aae|aal|bmo|cqu|dme|hsa)-", "", n)
    n = re.sub(r"-[35]p$", "", n)
    n = n.replace("mir-", "mir").replace("let-", "let")
    return n


#  Keep "mir276", "let7", "bantam"; drop the words the regex also catches
#  ("miRNA", "miRBase", "letra", "letter", a bare "miR").
KEEP_RE = re.compile(r"^(?:mir\d|let\d|lin\d|bantam$)")


def mirnas_in(text):
    out = []
    for m in MIRNA_RE.findall(text or ""):
        c = norm(m)
        if KEEP_RE.match(c):
            out.append(c)
    return out


def main():
    src = sys.argv[1] if len(sys.argv) > 1 else IN_DEFAULT
    out = sys.argv[2] if len(sys.argv) > 2 else OUT_DEFAULT
    os.makedirs(os.path.dirname(out), exist_ok=True)

    wb = openpyxl.load_workbook(src, data_only=True)
    rows = []
    for ws in wb.worksheets:
        # Header row 1 gives the column names; the metadata sheet has none.
        hdr = {}
        for c in range(1, ws.max_column + 1):
            v = ws.cell(row=1, column=c).value
            if v is not None:
                hdr[c] = str(v).strip()
        col_of = {name: idx for idx, name in hdr.items()}
        if "mirna_name" not in col_of:
            continue

        for r in range(2, ws.max_row + 1):
            for c in range(1, ws.max_column + 1):
                cell = ws.cell(row=r, column=c)
                if cell.comment is None:
                    continue
                note = (cell.comment.text or "").replace("\r\n", "\n").strip()
                if not note:
                    continue

                ctx = {}
                for k in CONTEXT:
                    i = col_of.get(k)
                    v = ws.cell(row=r, column=i).value if i else None
                    ctx[k] = "" if v is None else str(v).strip()

                named = mirnas_in(note)
                row_core = norm(ctx["mirna_name"])
                if not named:
                    flag = "NA"
                else:
                    flag = "TRUE" if row_core and row_core in named else "FALSE"

                val = cell.value
                rows.append({
                    "sheet": ws.title,
                    "cell": f"{get_column_letter(c)}{r}",
                    "row": r,
                    "column_letter": get_column_letter(c),
                    "column_name": hdr.get(c, ""),
                    "cell_value": "" if val is None else str(val).strip(),
                    "mirna_name": ctx["mirna_name"],
                    "acc_mirb": ctx["acc_mirb"],
                    "species": ctx["species"],
                    "citation_exp": ctx["citation_exp"],
                    "doi_exp": ctx["doi_exp"],
                    "infection": ctx["infection"],
                    "row_mirna_in_note": flag,
                    "mirnas_named_in_note": "; ".join(sorted(set(named))),
                    "note": note,
                })

    rows.sort(key=lambda x: (x["sheet"], x["row"], x["column_letter"]))

    # The same note text sitting on several cells is usually a copy that was
    # left behind when the sheet was sorted or rows were moved. List the other
    # cells so the right one can be kept and the stale one deleted.
    where = {}
    for r in rows:
        where.setdefault(r["note"], []).append(f"{r['sheet']}!{r['cell']}")
    for r in rows:
        others = [w for w in where[r["note"]] if w != f"{r['sheet']}!{r['cell']}"]
        r["same_note_on_cells"] = "; ".join(others)

    fields = ["sheet", "cell", "row", "column_letter", "column_name",
              "cell_value", "mirna_name", "acc_mirb", "species", "citation_exp",
              "doi_exp", "infection", "row_mirna_in_note",
              "mirnas_named_in_note", "same_note_on_cells", "note"]
    with open(out, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fields)
        w.writeheader()
        w.writerows(rows)

    print(f"{len(rows)} notes from {src} -> {out}")
    from collections import Counter
    print("\nNotes per sheet:")
    for k, v in sorted(Counter(r["sheet"] for r in rows).items()):
        print(f"  {k}: {v}")
    print("\nNotes per column:")
    for k, v in Counter(r["column_name"] for r in rows).most_common():
        print(f"  {k}: {v}")
    print("\nDoes the note name the miRNA of its own row?")
    for k, v in Counter(r["row_mirna_in_note"] for r in rows).most_common():
        print(f"  {k}: {v}")


if __name__ == "__main__":
    main()
