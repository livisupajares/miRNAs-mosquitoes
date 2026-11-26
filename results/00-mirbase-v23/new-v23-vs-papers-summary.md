# Are the new miRBase v23.1 miRNAs differentially expressed in the papers?

Checked against every infection Table S1 covers: **DENV-2, ZIKV, CHIKV and
Wolbachia** (DENV-2 on 2026-11-25, the other three on 2026-11-26).

Short answer: **still almost none of them have direct evidence**. Of the 97 aae
mature products that are new or changed in v23.1, **nine** are matched by a
paper's own reported sequence, and only **three of those nine are genuinely new
accessions**; the other six are accessions that already existed in v22.1 and had
their sequence changed. Forty-eight more new arms are only *candidates*, because
the paper named a locus without saying which arm it measured.

Full table: `new-v23-mirnas-literature-evidence.csv`, one row per new or changed
v23 mature product (rebuilt by `08-new-v23-vs-literature.R`).

## Matched by a paper's own reported sequence

| v23 miRNA | New or changed | Evidence |
|---|---|---|
| **aae-miR-276-2-5p** | new accession | DENV-2: Campbell 2014 "mir-276-5p" AGCGAGGUAUAGAGUUCCUAU, down 9 dpe (logFC −1.94, p = 0.017), a 3′-extended isomiR of it |
| **aae-miR-927-5p** | new accession | CHIKV: Shrinet 2014 "miR-927a" UUUAGAAUUCCUACGCUUUACC, up in CHIKV-infected cells — an **exact** match |
| **aae-miR-2796-3p** | new accession | CHIKV: Maharaj 2015 novel "aae-mir-309"/"aal-mir-309" GUAGGCCGGCGGAAACUACUUGC, up in infected saliva of both species — an **exact** match |
| aae-miR-276-3p | sequence changed | DENV-2: Su 2017 and Su 2019 miR-276-3p up (exact); CHIKV: Maharaj 2015 novel "mir-5" up (exact) |
| aae-miR-998-3p | sequence changed | DENV-2: Su 2017 miR-998 up 2.1-fold — the trimmed form |
| aae-miR-124-3p | sequence changed | DENV-2: Campbell 2014 "mir-124-5p" down; Avila-Bonilla 2017 aal-miR-124 down |
| aae-miR-210-3p | sequence changed | DENV-2: Campbell 2014 "mir-210-5p" down; Avila-Bonilla 2017 aal-miR-210 up |
| aae-miR-281-5p | sequence changed | DENV-2: Campbell 2014 "mir-281a-5p" down |
| aae-miR-308-3p | sequence changed | DENV-2: Campbell 2014 "mir-308-3p" down |

The two CHIKV hits are both new since the DENV-2-only pass. Note how they were
found: Maharaj 2015 and Shrinet 2014 list **novel** miRNAs under their own
names, so the only way to recognise them is by sequence, not by name.

## New v23 arms where a paper named the locus but not the arm

Forty-eight of the new arms sit at a locus some paper reports, without the paper
saying which arm it measured. They are candidates to check in the paper's
supplement, not evidence. The ones with the strongest case:

| New v23 arm | Papers (infection) | Why it is worth checking |
|---|---|---|
| aae-miR-100-3p | Yan 2014 (denv) "miR-100\*", Maharaj 2015 (chikv), Mayoral 2014 (wolbachia) | a "star" arm is the minor arm by definition, and v23 has just added 100-3p next to the existing 100-5p |
| aae-miR-927-5p | Liu 2015, Avila-Bonilla 2020 (denv) | already confirmed by sequence from Shrinet 2014, so these two are very likely the same arm |
| aae-miR-989-5p | Liu 2016 (denv), Saldaña 2017 (zika), Maharaj 2015 (chikv), Mayoral 2014 and She 2024 (wolbachia) | the most reported locus in the whole set, and the 5p arm is new |
| aae-miR-2946-5p | Yan 2014 (denv), Saldaña 2017 (zika), Bishop 2022 (wolbachia) | reported in three infections, arm never stated |
| aae-miR-2941-1-5p, -2-5p | Hussain 2011, Bishop 2022 (wolbachia), Saldaña 2017 (zika) | Bishop names 3p arms, the 5p arms are new |
| aae-let-7-3p | Liu 2015, Yan 2014 (denv), Maharaj 2015 (chikv) | |
| aae-miR-33-3p, -957-5p, -9b-3p, -993-3p, -1890-5p, -1891-3p, -10-3p | Liu 2015, Yan 2014 (denv), Maharaj 2015 (chikv) | the DENV-2-only candidates from the first pass, now also reported under CHIKV |

The full list of 48 is the `name_only_evidence` column of
`new-v23-mirnas-literature-evidence.csv`.

## The other 41 new v23 miRNAs

No paper in the library reports them under any of the four infections. Most are
the 1189x / 2944 / 2946 family and newly annotated passenger arms. They are new
to miRBase, not new to this literature, so they add nothing to Table S1 on their
own.

## What is missing from Table S1 (the other direction)

Checking the papers *into* Table S1 rather than the reverse found **177 study
rows** that are differentially expressed in a paper but absent from Table S1 for
that study and that infection. Drafted in `s1-new-tab-literature.csv` with
`curation_status = ADD`:

| Infection | Study | ADD rows | Distinct miRNAs |
|---|---|---|---|
| wolbachia | Bishop et al., 2022 | 47 | 44 |
| wolbachia | She et al., 2024 | 11 | 11 |
| wolbachia | Mayoral et al., 2014 | 11 | 9 |
| wolbachia | Hussain et al., 2011 | 7 | 5 |
| wolbachia | Hussain et al., 2013 | 5 | 5 |
| wolbachia | Zhang et al., 2014 | 1 | 1 |
| chikv | Maharaj et al., 2015 | 31 | 24 |
| chikv | Shrinet et al., 2014 | 10 | 10 |
| chikv | Dubey et al., 2017 | 2 | 1 |
| denv | Campbell et al., 2014 | 16 | 14 |
| denv | Yan et al., 2014 | 10 | 5 |
| denv | Su et al., 2017 | 7 | 7 |
| denv | Su et al., 2019 | 6 | 6 |
| denv | Liu et al., 2015 | 5 | 5 |
| zika | Saldaña et al., 2017 | 8 | 6 |

Two whole studies are absent from Table S1: **Bishop 2022** (wAlbB vs
tetracycline-cleared females) and **Zhang 2014** (the AaArgM3 follow-up). The
rest are miRNAs a study already in Table S1 reports but Table S1 does not list.

A further **26 rows** are flagged `CHECK` rather than `ADD` (10 denv, 9 chikv,
5 wolbachia, 2 zika): Table S1 already holds a close name for that study, for
example Campbell "mir-34-3p" vs S1 "miR-34-5p" or Yan "miR-33" vs S1
"miR-33b-5p", so a human has to decide whether they are one entry or two.

One row is `EXCLUDED` (Avila-Bonilla 2017 miR-210, p = 0.1665 vs mock).

## Three Table S1 rows worth a second look

Found while matching; no script changes Table S1.

1. The **Maharaj et al., 2015** rows carry `doi_exp = 10.1371/journal.pone.0096107`,
   which is Mayoral 2014's DOI. Maharaj 2015 is `10.1371/journal.pntd.0003386`.
2. Table S1 has a `chikv` row for **Etebari et al., 2015** (miR-100-5p, down) and
   one for **Zhang et al., 2017**. Neither study is about CHIKV.
3. Table S1 has two `wolbachia` rows for **Maharaj et al., 2015**, a CHIKV saliva
   study with no Wolbachia arm.
