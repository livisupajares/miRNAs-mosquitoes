# Are the new miRBase v23.1 miRNAs differentially expressed under DENV-2?

Short answer: **almost none of them have direct evidence**. Of the 97 aae mature
products that are new or changed in v23.1, exactly **one** is matched by a
DENV-2 paper's own reported sequence, and **twelve more** are only *candidates*
because the paper named a locus without saying which arm it measured.

Full table: `new-v23-mirnas-denv2-evidence.csv` (one row per new v23 mature product).

## Matched by a paper's reported sequence

| v23 miRNA | Evidence | In Table S1? |
|---|---|---|
| aae-miR-276-2-5p (MIMAT0057362, new accession) | Campbell 2014 "mir-276-5p" AGCGAGGUAUAGAGUUCCUAU, down 9 dpe (logFC −1.94, p = 0.017) is a 3′-extended isomiR of it | Yes, as miR-276-5p (aae sheet) |
| aae-miR-998-3p (same accession, sequence extended in v23) | Su 2017 miR-998 TAGCACCATGAGATTCAGC up 2.1-fold (Table 5, p.10) is the trimmed form | Yes (aal sheet) |
| aae-miR-2796-3p (new in v23) | Liu 2015 miR-2796-3p up-regulated (already curated) | Yes (aal sheet) |
| aae-miR-927-5p (new in v23) | Liu 2015 down; Avila-Bonilla 2017 and 2020 up — all three already curated | Only in "Removed studies" |

(The other accessions whose sequence changed in v23 — 124-3p, 210-3p, 281-5p, 308-3p,
276-3p, 1175-3p/5p — already have S1 entries; those are sequence updates, not new miRNAs.)

## New v23 arms where a paper named the locus but not the arm

These are the ones worth checking against the papers' supplements, because the new
v23 arm may be exactly what the paper measured:

| New v23 arm | Paper | Direction |
|---|---|---|
| aae-let-7-3p | Liu 2015 (down), Yan 2014 (up) | ambiguous |
| aae-miR-10-3p | Liu 2015 "miR-10" | down |
| aae-miR-100-3p | Yan 2014 "miR-100*" (a star arm — likely this one) | up in C6/36, up in females |
| aae-miR-1890-5p | Liu 2015 "miR-1890" | down |
| aae-miR-1891-3p | Yan 2014 "miR-1891" | down |
| aae-miR-2946-5p | Yan 2014 "miR-2946" | up in C6/36, down in females |
| aae-miR-33-3p | Yan 2014 "miR-33" | up |
| aae-miR-957-5p | Liu 2015 "miR-957" | down |
| aae-miR-989-5p | Liu 2016 "miR-989" | down |
| aae-miR-993-3p | Liu 2015 "miR-993" | up |
| aae-miR-9b-3p | Liu 2015 "miR-9b" | down |
| aae-miR-927-5p | Liu 2015, Avila-Bonilla 2020 "miR-927" | down / mixed |

`miR-100*` is the strongest of these: a "star" arm by definition is the minor arm,
and v23 has just added aae-miR-100-3p next to the existing 100-5p.

## The other ~80 new v23 miRNAs

No DENV-2 paper in the library reports them at all. Most are the 1189x/2944/2946 family
and newly annotated passenger arms. They are new to miRBase, not new to the DENV-2
literature, so they add nothing to Table S1 on their own.

## What is missing from Table S1 (the other direction)

Checking the papers *into* Table S1 rather than the reverse found **33 distinct miRNAs
in 53 study rows** that are differentially expressed under DENV-2 in a paper but absent
from Table S1. Drafted in `s1-new-tab-denv2-literature.csv`:

- Campbell 2014: 16 rows missing (Table 1 has 35 entries, S1 had 18) — mostly the
  281a/b/c, 79a/b/c, 2b, 8-5p, 87-5p, 988-5p, 9c-5p, 33-5p, iab, 1890 and 317 entries.
- Yan 2014: 10 rows — miR-100*, 263b, 2941, 2944a, 2946 in both C6/36 and females;
  the female (7 dpi) experiment was not represented in S1 at all.
- Liu 2015: 5 rows — miR-263a-5p, 263b-5p, 9b, 9c-5p, 1890.
- Su 2017: 5 rows — miR-1000-5p, 15b, 3811e-5p, 6134, 92a.
- Su 2019: 6 rows — miR-1420b-5p, 19c, 276-3p, 3811e-5p, 6134, 1273f.
- Avila-Bonilla 2017: 1 row, miR-210 — but **excluded**, p = 0.1665 vs mock.

10 further rows are flagged `CHECK` rather than `ADD`: S1 already holds a close name
(for example Campbell "mir-34-3p" vs S1 "miR-34-5p", Yan "miR-33" vs S1 "miR-33b-5p"),
so a human has to decide whether they are the same entry or two.
