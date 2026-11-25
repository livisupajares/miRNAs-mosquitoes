# miRBase v22.1 → v23.1 reconciliation

Made by `scripts/00-mirbase-scrapping/02-reconcile-v22-v23-s1.R`. Table S1 is
only read, never changed.

Matching rule: **mature sequence first** (exact, then containment = isomiR),
accession and normalised name second. A mature product is the pair
(accession, sequence), because one accession can carry two sequences in v23
(MIMAT0014223 is 21 nt on aae-mir-276-1 and 22 nt on aae-mir-276-2).

| File | What it holds |
|---|---|
| `aae-mirbase-v22-vs-v23.csv` | Every aae mature miRNA: unchanged, renamed, sequence changed (with seed flag), extra sequence on same accession, new in v23, removed |
| `s1-aae-vs-mirbase-v23.csv` | Every distinct S1 aae entry (name + acc + sequence) mapped to v23, with a `status` to act on and the S1 Excel rows it came from |
| `s1-aae-denv-vs-mirbase-v23.csv` | Same, only entries with DENV evidence (feeds target prediction) |
| `s1-aal-vs-aae-mirbase-v23.csv` | aal S1 sequences vs aae v23 (naming hint only; no aal in miRBase) |
| `aae-mirbase-v23-in-s1.csv` | Reverse view: every v23 mature miRNA, whether it was in v22, and whether (and in which S1 Excel rows) it appears in S1 |

## Status values in the S1 files

- `OK: unchanged`, `OK: rename only` – nothing to do except update the name/arm.
- `UPDATE: v23 changed sequence (S1 has v22 seq)` – S1 copied v22; miRBase now
  gives a longer/shorter sequence. Decide which sequence to use.
- `FIX: ...` – accession in S1 is a precursor (MI) or missing.
- `CHECK: ...` – sequence and accession/name disagree, or study sequence is an
  isomiR of the miRBase one. Needs a human look at the original paper.
- `NOT IN miRBase v23` – study-only sequence; the update does not affect it.

## Why the earlier test script (`01-diff-mirbasev22-v23.R`) over-reported "new"

It reported 263 rows as "New in v23 (Not found in table_s1)". Checking them:

- 173 already existed in miRBase v22.1, so they are not new to miRBase at all.
- 77 of those are in Table S1, just not under DENV infection.
- Only 90 rows (79 distinct mature miRNAs after collapsing duplicate
  precursors) have accessions that are actually new in v23.

Causes: it compared all of v23 against **only the DENV rows** of S1, it never
compared against v22, it matched on accession or name but never on sequence,
and it did not collapse precursors that share one mature miRNA.
