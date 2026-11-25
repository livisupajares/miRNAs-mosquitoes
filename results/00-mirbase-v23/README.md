# miRBase v22.1 → v23.1 reconciliation

Made by three scripts in `scripts/00-mirbase-scrapping/` (run from the
project root, in this order). Table S1 is only read, never changed.

1. `02-compare-mirbase-v22-v23.R`: miRBase v22.1 vs v23.1 only (no S1).
2. `03-reconcile-s1-v23.R`: Table S1 vs miRBase v23.1.
3. `04-build-aae-mirna-v23.R`: builds `databases/01-isolating-mature-sequences/aae-mirna-v23.csv`.

Shared functions live in `mirbase-helpers.R`.

Matching rule: **mature sequence first** (exact, then containment = isomiR),
accession and normalised name second. A mature product is the pair
(accession, sequence), because one accession can carry two sequences in v23
(MIMAT0014223 is 21 nt on aae-mir-276-1 and 22 nt on aae-mir-276-2).

| File | What it holds |
|---|---|
| `aae-mirbase-v22-vs-v23-precursors.csv` | Precursor (hairpin) level: unchanged, renamed, hairpin sequence changed, new, removed |
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

## Literature check against the DENV-2 papers (2026-11-25)

Two more scripts, run after the three above:

4. `05-literature-vs-v23.R`: every DENV-2 finding extracted from the papers in
   the Zotero group *pasantia-upch*, matched to miRBase v23.1 by sequence and
   then checked against Table S1 for the same study.
5. `06-build-s1-literature-tab.R`: drafts the findings that are missing from
   Table S1 as rows in the Table S1 column layout.

Hand-curated input (one row per study x miRNA x condition, each with a page or
figure locator):

- `databases/00-mirbase-scrapping/literature/paper-de-extract.tsv`
- `databases/00-mirbase-scrapping/literature/su2017-additional-file1-seqs.tsv`
  (sequences from Su et al. 2017 Additional file 1, the Drive copy)

| File | What it holds |
|---|---|
| `literature-denv2-vs-v23-vs-s1.csv` | 122 findings from 9 papers, each with its v23 match, whether that v23 miRNA is new, and whether Table S1 already has it |
| `new-v23-mirnas-denv2-evidence.csv` | The reverse view: each of the 97 new or changed v23 mature products, with any DENV-2 evidence for it |
| `s1-new-tab-denv2-literature.csv` | 53 draft rows in the Table S1 layout for findings S1 does not have, with `curation_status` ADD / CHECK / EXCLUDED and the review columns after the S1 columns |

Headline: only **aae-miR-276-2-5p** is matched to a new v23 accession by a
paper's own sequence. Twelve more new v23 arms are candidates where the paper
named a locus but not the arm (miR-100-3p for Yan's "miR-100*" is the most
likely). The other ~84 are new to miRBase, not to this literature.

In the other direction, 33 distinct miRNAs (53 study rows) are differentially
expressed under DENV-2 in a paper but absent from Table S1; most are Campbell
2014 Table 1 entries and the Yan 2014 adult-female experiment.

Seven papers were set aside with the reason recorded: Miesen 2016 (nothing
significant after multiple-testing correction), Etebari 2015 (isomiR ratios,
not differential expression), Azlan 2022 (DENV-1), She 2024 (Wolbachia),
Hess 2011 (no miRNA DE list), Skalsky 2010 (no infection), Smith 2017 (human
cells).
