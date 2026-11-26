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

## Literature check against the papers (DENV-2 2026-11-25; ZIKV, CHIKV, Wolbachia 2026-11-26)

Four more scripts, run after the three above (shared code for 06 and 07 is in
`scripts/00-mirbase-scrapping/literature-helpers.R`). They cover all four
infections Table S1 uses: **denv, zika, chikv and wolbachia**. Each finding is
checked against Table S1 for the same study *and the same infection*, and each
drafted row fills its own infection's S1 columns (`exp_DENV` / `exp_ZIKA` /
`exp_CHIKV` / `exp_wolbachia` with their location and cell-line columns). Only
DENV has metric/value/validation columns in Table S1, so for the other three the
paper's fold change and p value stay in the review columns.

4. `05-literature-vs-v23.R`: every finding extracted from the papers in
   the Zotero group *pasantia-upch*, matched to miRBase v23.1 by sequence and
   then checked against Table S1 for the same study and infection.
5. `06-build-s1-literature-tab.R`: drafts the findings that are missing from
   Table S1 as rows in the Table S1 column layout.
6. `07-build-literature-s1-combined.R`: one table with every finding, all
   Table S1 columns filled in, and the study evidence (finding, exact quote,
   locator, source coverage, support). Papers that were read but set aside get
   one row each so the reason stays visible.
7. `08-new-v23-vs-literature.R`: the reverse view, one row per new or changed
   v23 mature product with any paper evidence for it (direct sequence match, or
   candidate by name when the paper gave no arm).

Hand-curated input (one row per study x miRNA x condition, each with a page or
figure locator):

- `databases/00-mirbase-scrapping/literature/paper-de-extract.tsv`
- `databases/00-mirbase-scrapping/literature/su2017-additional-file1-seqs.tsv`
  (sequences from Su et al. 2017 Additional file 1, the Drive copy; the subset
  needed here, not the whole table)
- `databases/00-mirbase-scrapping/literature/study-evidence.tsv` (one row per
  paper: finding, exact quotation, locator, source coverage, support, whether
  it was included or set aside, and what could not be checked)

| File | What it holds |
|---|---|
| `literature-all-vs-v23-vs-s1.csv` | 462 findings from 22 papers across denv, zika, chikv and wolbachia, each with its v23 match, whether that v23 miRNA is new, and whether Table S1 already has it for that study and infection |
| `new-v23-mirnas-literature-evidence.csv` | The reverse view: each of the 97 new or changed v23 mature products, with any paper evidence for it (script 08) |
| `literature-evidence-table.md` | Readable evidence table: each paper with its quote, locator, coverage and support, the visible gaps, the Table S1 rows worth a second look, and the Vancouver reference list |
| `new-v23-vs-papers-summary.md` | Plain-language answer: which new v23 miRNAs the papers support, and what S1 is missing |
| `literature-s1-combined.csv` | **The full table.** 462 findings + 8 set-aside papers. All Table S1 columns first, then `s1_status`, the v23 match, sequence source and coverage, and the study evidence |
| `s1-new-tab-literature.csv` | 204 draft rows in the Table S1 layout for findings S1 does not have, with `curation_status` ADD / CHECK / EXCLUDED and the review columns after the S1 columns |

### Counts per infection (findings, script 07)

| Infection | Papers | Findings | IN S1 | ONLY IN REMOVED | ADD | CHECK | EXCLUDED |
|---|---|---|---|---|---|---|---|
| denv | 9 | 122 | 52 | 15 | 44 | 10 | 1 |
| chikv | 3 | 190 | 133 | 5 | 43 | 9 | 0 |
| wolbachia | 9 | 127 | 40 | 0 | 82 | 5 | 0 |
| zika | 1 | 23 | 12 | 1 | 8 | 2 | 0 |

ADD rows are missing from Table S1 and significant in the paper: 35 distinct
miRNAs for denv, 41 for chikv, 72 for wolbachia and 6 for zika.

Headline: with all four infections in, **three** accessions that are genuinely
new in v23.1 are matched by a paper's own sequence - aae-miR-276-2-5p (Campbell
2014, DENV-2), aae-miR-927-5p (Shrinet 2014, CHIKV) and aae-miR-2796-3p
(Maharaj 2015, CHIKV) - plus six accessions whose sequence changed in v23.
Another 48 new v23 arms are candidates where the paper named a locus but not
the arm. The rest are new to miRBase, not to this literature.

In the other direction, 177 study rows are differentially expressed in a paper
but absent from Table S1 for that study and infection: 154 distinct
miRNA-per-infection entries (35 denv, 41 chikv, 72 wolbachia, 6 zika). The
biggest blocks are Bishop 2022 (44 Wolbachia miRNAs, a study Table S1 does not
have at all), Maharaj 2015 (24 CHIKV saliva miRNAs) and Campbell 2014 (14
DENV-2 miRNAs).

Eight papers were set aside with the reason recorded: Miesen 2016 (nothing
significant after multiple-testing correction), Etebari 2015 (isomiR ratios,
not differential expression), Azlan 2022 (DENV-1), Hess 2011 (no miRNA DE
list), Skalsky 2010 (no infection), Smith 2017 (human cells), Dubey 2019 (no DE
experiment of its own) and Fiorillo 2022 (no significant CHIKV change in saliva
or salivary glands, which contradicts Maharaj 2015). She 2024 was set aside
while this table covered DENV-2 only; it is now included under wolbachia.

### Columns added after the Table S1 columns in `literature-s1-combined.csv`

| Column | Meaning |
|---|---|
| `s1_status` | `IN S1`, `ONLY IN REMOVED`, `ADD` (missing and significant), `CHECK: …` (S1 has a close name), `EXCLUDED: …` (p > 0.05), `STUDY SET ASIDE` |
| `s1_names` | The Table S1 name(s) and sheet that matched, if any |
| `mirna_name_paper`, `direction`, `logFC`, `p` | As printed in the paper |
| `v23_match`, `v23_relation` | `exact` / `isomiR` / `no match` / `name only`, and how the paper sequence differs from v23 |
| `v23_new` | `yes` if the matched v23 miRNA is new in v23; `possible, arm not given (…)` when the paper named only the locus |
| `seq_source`, `sequence_coverage` | Where `mat_seq` came from: `passage retrieved` (paper table), `passage retrieved (paper supplement)`, `guess (another paper's supplement)`, `unavailable` |
| `finding`, `exact_quote`, `quote_locator` | Study-level evidence, quoted verbatim from the PDF |
| `source_coverage` | `passage retrieved`, `abstract only` or `unavailable` |
| `study_support`, `finding_support` | `supported`, `contradicted` or `uncertain` (finding-level is `uncertain` when the paper's own p > 0.05) |
| `scope`, `coverage_gap` | `included` or `set aside`, and what could not be checked |

Values from the paper (`exp_denv_value`, `logFC`) are copied as printed. Every
Table S1 column with no information is the text `NA`, as in Table S1.
