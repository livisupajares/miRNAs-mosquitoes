# Differential expression under DENV-2, ZIKV, CHIKV and Wolbachia: evidence table

Checked against the Zotero group library *pasantia-upch* (id 5557266): the DENV-2
papers on 2026-11-25, the ZIKV, CHIKV and Wolbachia papers on 2026-11-26.
Every row below was read from the paper's own PDF before it was written down.
Exact quotations are copied verbatim; page numbers are the PDF pages Zotero reports
(marked *approx.* when Zotero estimated them rather than re-parsing the page).

**Source coverage** is one of: `passage retrieved` (I read the sentence or table),
`abstract only`, `unavailable` (the number lives in a supplement I could not open).
**Support** is whether the paper supports the claim that the named miRNAs are
differentially expressed under its own infection: `supported`, `contradicted`,
`uncertain`.

Sections 1 to 3 cover the DENV-2 papers (the first pass); section 4 covers the
ZIKV, CHIKV and Wolbachia papers added afterwards. Row-level data for all four
infections is in `literature-s1-combined.csv`.

---

## 1. DENV-2: papers that support differential expression

| Study | Finding | Exact quotation | Locator | Source coverage | Support |
|---|---|---|---|---|---|
| Campbell et al., 2014 (aae, whole body, DENV2 JAM1409) | 35 miRNA entries modulated across 2, 4 and 9 dpe, with sequences and logFC in Table 1. | "The number of significantly modulated miRNAs increased from 5 or fewer at 2 and 4 dpe to 23 unique miRNAs by 9 dpe." | Abstract, p.1; Table 1, pp.14–15 | passage retrieved (full Table 1 transcribed) | supported |
| Su et al., 2017 (aal, midgut, D vs B) | 16 miRNAs with >2-fold change between DENV-2 blood and regular blood; 13 up, 3 down. | "Table 5 Significantly modulated miRNAs that displayed a < -2- or > 2-fold difference in expression between the midguts of mosquitoes that had ingested a DENV-2-infected blood meal (D) and those that had ingested a regular blood meal (B)" | Table 5, p.10 (exact page text) | passage retrieved | supported |
| Su et al., 2019 (aal, midgut, infected vs uninfected after the same meal) | 17 significant DE miRNAs: 15 up, 2 down. | "Of these miRNAs, 15 were upregulated (miR-1420b-5p, miR-1767, miR-193-5p, miR-1951, miR-19c, miR-276-3p, miR-2941, miR-3811e-5p, miR-4110-5p, miR-424-3p, miR-5706, miR-6134, miR-622, miR-976-5p and miR-989) and two were downregulated (miR-1273f and miR-4448)." | Results, p.6 (approx.); Fig. 1b | passage retrieved | supported |
| Liu et al., 2015 (aal, whole body, intrathoracic, 7 dpi) | 66 known DE miRNAs (15 up, 51 down) plus 4 novel; 12 named in the text. | "Based on p-value and log fold change, 66 known miRNAs (15 for up-regulated and 51 for down-regulated) and 4 novel candidate miRNAs (3 for up-regulated and 1 for down-regulated) were differentially expressed" | Results, p.3 (approx.); Fig. 3A–C | passage retrieved for the named miRNAs; the full list of 66 is **unavailable** (supplement not in Zotero) | supported (for the named ones), uncertain for the rest |
| Liu et al., 2015 — the >50-fold set | 9 strongly down, 3 strongly up. | "We also identified 9 known miRNAs (miR-263b-5p, miR-1889-5p, miR-9c-5p, miR-306-5p, miR-927, miR-957, miR-9b, miR-2940-3p, and miR-277-5p) to be significantly under-expressed and 3 (miR-993, miR-276-5p, and miR-2945-3p) to be overexpressed than 50-fold" | Results, p.3 (approx.) | passage retrieved | supported |
| Liu et al., 2016 (aal, midgut, 1 dpi) | Only 3 DE miRNAs. | "a total of 85 known miRNAs were identified, with three known miRNAs differentially expressed (Table S5)" and "the down-regulated miR-989 … one up-regulated miRNA, miR-2943 … Another down-regulated miR-2941" | Results, p.4 (approx.); Fig. 2 | passage retrieved for the three names; Table S5 **unavailable** | supported |
| Yan et al., 2014 (aal, C6/36 24 hpi and females 7 dpi, RT-qPCR) | 12 miRNAs measured; direction differs between cells and mosquitoes. | "After infection, only miR-1891 was down-regulated and the remaining miRNAs were up-regulated (Fig. 1)." and "Only four miRNAs expression levels were elevated, including miR-100 , miR-1889, miR-33, and let-7." | Results, p.4; Discussion, p.7 | passage retrieved; figure panels read as images (significance from asterisks) | supported |
| Zhou et al., 2014 (aal, midgut, 4/7 dpi) | miR-281 up after DENV-2. | "miR-281 has been found to be specifically expressed at a high level in the midgut of female adult mosquitoes and is up-regulated after DENV-2 infection." | Conclusion, p.9 (approx.) | passage retrieved | supported |
| Avila-Bonilla et al., 2017 (aal, C6/36 persistently infected C6-L) | 11 miRNAs DE vs both controls, plus 4 only vs acute infection; Tables 1–2 give sequences. | "some miRNAs were up-regulated in C6-L cells compared with both control conditions (miR-927, miR-87, miR-2a-3p, miR-190, and miR-970) or down-regulated (miR-263a-3p, miR-92b, miR-9a-1, miR-9a-5p, miR-286a, and miR-286b), but others were altered only compared with acutely infected C6/36-HT cells." | Section 3.2, p.5 (approx.); Tables 1–2, pp.141–142 | passage retrieved (both tables transcribed) | supported |
| Avila-Bonilla et al., 2020 (aal, C6/36-HT) | miR-927 down in acute infection, then up. | "in acutely infected C6/36 cells, miR-927 was downregulated, but its expression was gradually and directly increased as a function of the duration of infection and the m.o.i. used" | Discussion, p.9 (approx.); Fig. 1, p.5 | passage retrieved | supported |

## 2. DENV-2: papers that do **not** support differential expression (exclusions)

| Study | Finding | Exact quotation | Locator | Source coverage | Support |
|---|---|---|---|---|---|
| Miesen et al., 2016 (aae, Aag2, DENV2) | No miRNA change survives multiple-testing correction. | "After p-value correction for multiple testing, no change in miRNA expression is statistically significant." | Fig. 4 legend, p.11 (approx.) | passage retrieved | **contradicted** — this paper cannot support any DE call |
| Etebari et al., 2015 (aae) | Reports isomiR class shifts and arm switching, not differential expression of mature miRNAs. | "The 3′ multiple nucleotide extension (3MNE) class of isomiRs displayed statistically significant induction in response to DENV infection in miR-285-3p, miR-989-3p and miR-10-5p" | Results, p.4 (approx.); Figs. 2, 6 | passage retrieved | uncertain — the measurement is an isomiR ratio, not DE |
| Azlan et al., 2022 (aal, C6/36) | DENV**1**, not DENV-2. | "our newly annotated Ae. albopictus miRNAs in C6/36 cells were differentially expressed after 3 days post-infection with DENV1. A total of 143 miRNAs were found to be differentially expressed (p-value < 0.05)" | Section 3.4, p.7 (approx.) | passage retrieved; the DE list is in Supplemental Table S2, **unavailable** | out of scope (wrong serotype) |
| Hess et al., 2011 (aae, DENV2 JAM1409) | Profiles small RNAs mapped to transcripts, not miRNA DE. No miRNA DE list. | "sRNA profiles are altered early in DENV2 infection, and mRNA targets from mitochondrial, transcription/translation, and transport functional categories are affected." | Abstract, p.1 | passage retrieved | uncertain — no named DE miRNAs to extract |
| Skalsky et al., 2010 (aal, Culex) | miRNA discovery, no infection experiment. | "we provide evidence for over 60 conserved and seven novel mosquito miRNAs" | Background, p.1 | passage retrieved | out of scope (no DENV infection) |
| Smith et al., 2017 (human cells) | Human miRNA screen against flaviviruses, not mosquito. | "miR-34a transfection potently inhibited infection by all three flaviviruses compared to control miRNA (miR-Ct) transfection" | Results, p.3 (approx.) | passage retrieved | out of scope (host is human) |
| She et al., 2024 (aae, Wolbachia) — **now included under Wolbachia, see section 4** | DE miRNAs are *Wolbachia*-driven (W+ vs W− cells), not DENV-2 driven. | "The expression of 6 out of the top 15 up-regulated DE miRNAs was increased in whole-cell samples … from W+ cells in qPCR analysis." | Results, p.6 (approx.) | passage retrieved | out of scope (comparison is Wolbachia, not DENV-2) |

## 3. DENV-2: visible gaps

- **Liu et al., 2015** — only 12 of 66 DE miRNAs are named in the main text; Figure 3A is a
  heat map I read as an image, so the remaining names come from a figure, not a table.
  The full list with fold changes is in a supplement that is not in Zotero.
- **Liu et al., 2016** — Table S5 (the 3 DE miRNAs with values) is not available; only the
  names and directions in the text.
- **Azlan et al., 2022** — Supplemental Table S2 not available (and the serotype is DENV1).
- **Yan et al., 2014** — the 12 miRNA sequences/primers are in a supplementary TIFF on Drive
  that I did not transcribe. Direction and significance come from Figs. 1 and 2 (asterisks).
- **Su et al., 2019** — no sequences in the paper (Additional file 5). Sequences in the draft
  tab are **guesses** taken from Su et al., 2017 Additional file 1, where the same group used
  the same names. Each one is flagged `GUESS` in `seq_source`.
- **Su et al., 2019** — the main text does not say which day (5, 7 or 10) each of the 17
  miRNAs belongs to, so `DENV_pbm_time_d` is NA for the new rows.
- **Campbell et al., 2014** — sequences were mapped against miRBase 17 and named per release
  19, so several arm labels do not match the v23 sequence. Noted per row.
- miRBase.org itself is unreachable from this container, so every miRBase fact comes from the
  v22.1 and v23.1 scrapes already in the repository.

## 4. ZIKV, CHIKV and Wolbachia (added 2026-11-26)

| Study | Infection | Finding | Exact quotation | Page / locator | Source coverage | Support |
|---|---|---|---|---|---|---|
| Saldaña et al., 2017 (aae, whole body, oral ZIKV Mex 1–7) | ZIKV | 17 miRNAs DE across 2, 7 and 14 dpi, 23 study × miRNA × time rows, mostly depleted. | "only 17 miRNAs were identified as differentially modulated at all the time points, with the majority of them significantly depleted in response to ZIKV infection (Table 1)" | Results p.7; Table 1 p.7 | passage retrieved | supported |
| Shrinet et al., 2014 (aal, Singh's cell line, CHIKV MOI 10, 24 hpi) | CHIKV | 41 miRNAs significantly DE; 4 named over-expressed (miR-100, miR-283, miR-305-3p, miR-927), 4 under-expressed (miR-1000, miR-2b, miR-2c-3p, miR-190-5p), plus 7 significant novel miRNAs. | "revealed 41 miRNAs to be significant differentially expressed in Aedes (p value < 0.05). It is noteworthy that most of the miRNAs were down-regulated upon CHIKV infection." | Results p.4; sequences and TPM in Tables 2–4 pp.5–7 | passage retrieved | supported |
| Maharaj et al., 2015 (aae and aal saliva, intrathoracic CHIKV, 10 dpi) | CHIKV | Read counts for every miRNA in infected vs uninfected saliva of both species, including 55 novel miRNAs with sequences. | "The highly expressed miRNAs, aae-mir-bantam, aae-mir-263a, aae-mir-125 and aae-mir-285 were upregulated in CHIKV-infected Ae.aegypti saliva with counts of 18002 (2.0-fold), 20584 (2.6-fold), 15735 (3.0-fold) and 10006 (>100-fold)" | Tables 1–4 pp.7–11 | passage retrieved | uncertain — no replicates and no statistical test |
| Dubey et al., 2017 (aae Aag2 cells, CHIKV) | CHIKV | 13 miRNAs significantly regulated: 3 at 12 hpi, 11 at 24 hpi (miR-2b in both). | "Three miRNAs (miR-2b, miR-2951-5p, and miR-10-5p) were found to be significantly regulated (p ≤ 0.05) in the 12 h.p.i. library … eleven miRNAs were significantly regulated in the 24 h.p.i. library" | Results p.2 | passage retrieved | supported |
| Mayoral et al., 2014 (aae Aag2 vs Aag2.wMelPop-CLA cells) | Wolbachia | Most differentially expressed miRNAs, given separately for the nucleus (16) and the cytoplasm (29) with log2 fold changes. | "In the nucleus, miR-989 and miR-306-5p were down-regulated and miR-2765 and Bantam-5p were up-regulated." | Table 2 p.10; Table 1 p.7 | passage retrieved | supported |
| Bishop et al., 2022 (aae females, wAlbB2-F4 vs tetracycline-cleared) | Wolbachia | 44 miRNAs DE between lines across 2, 6 and 12 dpe (46 rows in Table 1), FDR < 0.05 and \|log2FC\| > 0.5. | "A total of 44 miRNAs met these criteria (Table 1). Log2 fold-changes ranged from − 2.05 to 1.57" | Results p.6; Table 1 pp.8–9 | passage retrieved | supported |
| She et al., 2024 (aae Aag2, wAlbB W+ vs W− cells) | Wolbachia | 55 DE miRNAs; 11 of the top 15 up or down confirmed by qPCR in whole-cell and cytoplasm samples. | "we identified a total of 55 DE miRNAs out of 164 mature miRNAs with annotations in miRBase, including 26 upregulated miRNAs and 26 downregulated miRNAs in W+ cells" | Results p.5; Fig 2C–D p.6 | passage retrieved | supported |
| Hussain et al., 2011 (aae females, wMelPop-CLA vs tetracycline-treated) | Wolbachia | 6 miRNAs induced at 4 dpe, 4 induced and 3 repressed at 12 dpe, by microarray plus Northern blot. | "We observed induction of aae-miR-2940, aae-miR-309a-2, aae-miR-2943-1, and aae-miR-970 at 4 d and 12 d after emergence and of aae-miR-308* and aae-miR-2941-2 at 4 d after emergence in Wolbachia-infected mosquitoes." | Results p.2; Discussion p.4; Figs 1–2 | passage retrieved | supported |
| Hussain et al., 2013 (aae females, blood meal ± Wolbachia) | Wolbachia | Seven blood-meal-induced miRNAs compared between +Wol and −Wol by Northern blot. | "Most of the miRNAs were also found in higher quantities in +Wol mosquitoes compared to −Wol mosquitoes (Fig. 1)." | Results 3.1 p.2; Fig 1 | passage retrieved | uncertain — the paper does not say *which* miRNAs, so the per-miRNA direction is read off Fig 1 |
| Asad et al., 2018 (aae tissues, wMelPop-CLA vs tetracycline) | Wolbachia | aae-miR-2940-5p induced in every tissue tested, most strongly midgut and fat body. | "Northern blot analysis of RNA isolated from various tissues … confirmed induction of aae-miR-2940-5p due to Wolbachia infection in all tissues, with substantial induction in the midgut and fat body (Fig 6A)." | Results p.10; Fig 6A | passage retrieved | supported |
| Zhang et al., 2013 (aae, wMelPop-CLA) | Wolbachia | aae-miR-2940 induction is the premise; the paper's own work is on the target AaDnmt2. | "altered the expression of a number of host miRNAs, including aae-miR-2940 in the host mosquito Ae. aegypti (18)" | Results/Discussion p.3 | passage retrieved | uncertain — the induction is cited from Hussain 2011, not measured here |
| Zhang et al., 2014 (aae, wMelPop-CLA) | Wolbachia | Same: aae-miR-2940 induction is the premise, the work is on the target AaArgM3. Not in Table S1 at all. | "we identified and confirmed that aae-miR-2940, which is induced in the presence of Wolbachia, enhances the expression of a protein arginine methyltransferase, AaArgM3" | Discussion p.6 | passage retrieved | uncertain |
| Osei-Amo et al., 2012 (aae Aag2 vs aag2-wMelPop-CLA) | Wolbachia | aae-miR-12 up-regulated in infected cells; the work is on the targets MCT1 and MCM6. | "the difference was concurrent with the up-regulation of aae-miR-12 in Wolbachia-infected (+Wol) mosquitoes based on further analysis of the microarray data [11]" | Results p.2 | passage retrieved | uncertain — re-analysis of the Hussain 2011 microarray |
| Dubey et al., 2019 (aae, CHIKV) — **set aside** | CHIKV | Functional follow-up on miR-2944b-5p and miR-2b; no DE experiment of its own. | "we identified two miRNAs, namely, miR-2944b-5p and miR-2b, that were most significantly regulated upon CHIKV infection in a previous study [23]" | Results p.7 | passage retrieved | uncertain |
| Fiorillo et al., 2022 (aae saliva and salivary glands, CHIKV) — **set aside** | CHIKV | No miRNA significantly changed in salivary glands, only 5 in saliva with weak support. | "we conclude that, at least in our experimental conditions, infection by the chikungunya virus does not significantly modulate miRNA expression profiles in Ae. aegypti saliva and salivary glands" | Results p.5 | passage retrieved | **contradicted** — directly contradicts the large Maharaj 2015 saliva list |

## 5. ZIKV, CHIKV and Wolbachia: visible gaps and things to check

- **Fold changes computed here, not printed in the paper.** Shrinet 2014 and
  Maharaj 2015 give read counts or TPM per library, not a log fold change, so
  `logFC` in the extract is `log2(infected / uninfected)` computed from those
  columns. Maharaj has no replicates and no test, so its `p` is `NA` throughout.
- **No sequences** in Saldaña 2017, Dubey 2017, Bishop 2022, She 2024 or any of
  the small Wolbachia papers, so those rows match miRBase v23.1 by name only and
  carry `sequence_coverage = unavailable`.
- **Maharaj 2015 names Ae. albopictus miRNAs with aae- prefixes**, because the
  reads were mapped to the Ae. aegypti miRNA set; the aal rows keep those names.
  Tables 1 and 3 list paralogous precursors (e.g. mir-276-1 and mir-276-2) with
  identical mature read counts; one row per mature miRNA was kept.
- **Mayoral 2014 Table 2** gives fold changes but no p values, and the minus
  signs of the negative fold changes come out as "2" in the extracted PDF text;
  directions were read from the sign of the log2 column.
- **Hussain 2013** is primarily a blood-meal study; its Wolbachia comparison is a
  sentence about "most of the miRNAs", not a per-miRNA result.
- **She 2024** only the 11 qPCR-confirmed miRNAs are extracted; the full list of
  55 is in S2 Table, which is not available.
- **Table S1 rows worth a second look** (found while matching, not changed by
  any script):
  - Maharaj et al., 2015 rows in Table S1 carry `doi_exp = 10.1371/journal.pone.0096107`,
    which is Mayoral 2014's DOI. Maharaj 2015 is `10.1371/journal.pntd.0003386`.
  - Table S1 has one `chikv` row for **Etebari et al., 2015** (miR-100-5p, down)
    and one for **Zhang et al., 2017** (`10.1073/pnas.1701474114`). Neither paper
    is a CHIKV study: Etebari 2015 is DENV isomiRs and Zhang 2017 is the
    gonadotrophic-cycle fat body series.
  - Table S1 has two `wolbachia` rows for **Maharaj et al., 2015**, a CHIKV
    saliva study with no Wolbachia arm.

## 6. References (Vancouver)

1. Hess AM, Prasad AN, Ptitsyn A, Ebel GD, Olson KE, Barbacioru C, et al. Small RNA profiling of Dengue virus-mosquito interactions implicates the PIWI RNA pathway in anti-viral defense. BMC Microbiol. 2011 Dec;11(1):45. doi:10.1186/1471-2180-11-45
2. Azlan A, Yunus MA, Abdul Halim M, Azzam G. Revised Annotation and Characterization of Novel Aedes albopictus miRNAs and Their Potential Functions in Dengue Virus Infection. Biology. 2022 Oct 19;11(10):1536. doi:10.3390/biology11101536
3. She L, Shi M, Cao T, Yuan H, Wang R, Wang W, et al. Wolbachia mediates crosstalk between miRNA and Toll pathways to enhance resistance to dengue virus in Aedes aegypti. PLoS Pathog. 2024 Jun 17;20(6):e1012296. doi:10.1371/journal.ppat.1012296
4. Smith JL, Jeng S, McWeeney SK, Hirsch AJ. A MicroRNA Screen Identifies the Wnt Signaling Pathway as a Regulator of the Interferon Response during Flavivirus Infection. J Virol. 2017 Apr 15;91(8):e02388-16. doi:10.1128/JVI.02388-16
5. Avila-Bonilla RG, Yocupicio-Monroy M, Marchat LA, Pérez-Ishiwara DG, Cerecedo-Mercado DA, Del Ángel RM, et al. miR-927 has pro-viral effects during acute and persistent infection with dengue virus type 2 in C6/36 mosquito cells. J Gen Virol. 2020 Aug 1;101(8):825–39. doi:10.1099/jgv.0.001441
6. Liu YX, Li FX, Liu ZZ, Jia ZR, Zhou YH, Zhang H, et al. Integrated analysis of miRNAs and transcriptomes in Aedes albopictus midgut reveals the differential expression profiles of immune-related genes during dengue virus serotype-2 infection. Insect Sci. 2016 Jun;23(3):377–85. doi:10.1111/1744-7917.12339
7. Zhou Y, Liu Y, Yan H, Li Y, Zhang H, Xu J, et al. miR-281, an abundant midgut-specific miRNA of the vector mosquito Aedes albopictus enhances dengue virus replication. Parasit Vectors. 2014 Dec;7(1):488. doi:10.1186/s13071-014-0488-4
8. Yan H, Zhou Y, Liu Y, Deng Y, Puthiyakunnon S, Chen X. miR-252 of the Asian tiger mosquito Aedes albopictus regulates dengue virus replication by suppressing the expression of the dengue virus envelope protein. J Med Virol. 2014 Aug;86(8):1428–36. doi:10.1002/jmv.23815
9. Etebari K, Osei-Amo S, Blomberg SP, Asgari S. Dengue virus infection alters post-transcriptional modification of microRNAs in the mosquito vector Aedes aegypti. Sci Rep. 2015 Oct 30;5(1):15968. doi:10.1038/srep15968
10. Avila-Bonilla RG, Yocupicio-Monroy M, Marchat LA, De Nova-Ocampo MA, Del Ángel RM, Salas-Benito JS. Analysis of the miRNA profile in C6/36 cells persistently infected with dengue virus type 2. Virus Res. 2017 Mar;232:139–51. doi:10.1016/j.virusres.2017.03.005
11. Skalsky RL, Vanlandingham DL, Scholle F, Higgs S, Cullen BR. Identification of microRNAs expressed in two mosquito vectors, Aedes albopictus and Culex quinquefasciatus. BMC Genomics. 2010 Dec;11(1):119. doi:10.1186/1471-2164-11-119
12. Su J, Li C, Zhang Y, Yan T, Zhu X, Zhao M, et al. Identification of microRNAs expressed in the midgut of Aedes albopictus during dengue infection. Parasit Vectors. 2017 Dec;10(1):63. doi:10.1186/s13071-017-1966-2
13. Liu Y, Zhou Y, Wu J, Zheng P, Li Y, Zheng X, et al. The expression profile of Aedes albopictus miRNAs is altered by dengue virus serotype-2 infection. Cell Biosci. 2015 Dec;5(1):16. doi:10.1186/s13578-015-0009-y
14. Su J, Wang G, Li C, Xing D, Yan T, Zhu X, et al. Screening for differentially expressed miRNAs in Aedes albopictus (Diptera: Culicidae) exposed to DENV-2 and their effect on replication of DENV-2 in C6/36 cells. Parasit Vectors. 2019 Dec;12(1):44. doi:10.1186/s13071-018-3261-2
15. Campbell CL, Harrison T, Hess AM, Ebel GD. MicroRNA levels are modulated in Aedes aegypti after exposure to Dengue-2. Insect Mol Biol. 2014 Feb;23(1):132–9. doi:10.1111/imb.12070
16. Miesen P, Ivens A, Buck AH, Van Rij RP. Small RNA Profiling in Dengue Virus 2-Infected Aedes Mosquito Cells Reveals Viral piRNAs and Novel Host miRNAs. PLoS Negl Trop Dis. 2016 Feb 25;10(2):e0004452. doi:10.1371/journal.pntd.0004452

17. Saldaña MA, Etebari K, Hart CE, Widen SG, Wood TG, Thangamani S, et al. Zika virus alters the microRNA expression profile and elicits an RNAi response in Aedes aegypti mosquitoes. PLoS Negl Trop Dis. 2017 Jul 17;11(7):e0005760. doi:10.1371/journal.pntd.0005760
18. Shrinet J, Jain S, Jain J, Bhatnagar RK, Sunil S. Next Generation Sequencing Reveals Regulation of Distinct Aedes microRNAs during Chikungunya Virus Development. PLoS Negl Trop Dis. 2014 Jan 9;8(1):e2616. doi:10.1371/journal.pntd.0002616
19. Maharaj PD, Widen SG, Huang J, Wood TG, Thangamani S. Discovery of Mosquito Saliva MicroRNAs during CHIKV Infection. PLoS Negl Trop Dis. 2015 Jan 22;9(1):e0003386. doi:10.1371/journal.pntd.0003386
20. Dubey SK, Shrinet J, Jain J, Ali S, Sunil S. Aedes aegypti microRNA miR-2b regulates ubiquitin-related modifier to control chikungunya virus replication. Sci Rep. 2017 Dec 15;7(1):17666. doi:10.1038/s41598-017-18043-0
21. Dubey SK, Shrinet J, Sunil S. Aedes aegypti microRNA, miR-2944b-5p interacts with 3'UTR of chikungunya virus and cellular target vps-13 to regulate viral replication. PLoS Negl Trop Dis. 2019 Jun 5;13(6):e0007429. doi:10.1371/journal.pntd.0007429
22. Fiorillo C, Yen PS, Colantoni A, Mariconti M, Azevedo N, Lombardo F, et al. MicroRNAs and other small RNAs in Aedes aegypti saliva and salivary glands following chikungunya virus infection. Sci Rep. 2022 Jun 9;12(1):9536. doi:10.1038/s41598-022-13780-3
23. Mayoral JG, Etebari K, Hussain M, Khromykh AA, Asgari S. Wolbachia Infection Modifies the Profile, Shuttling and Structure of MicroRNAs in a Mosquito Cell Line. PLoS ONE. 2014 Apr 23;9(4):e96107. doi:10.1371/journal.pone.0096107
24. Bishop C, Hussain M, Hugo LE, Asgari S. Analysis of Aedes aegypti microRNAs in response to Wolbachia wAlbB infection and their potential role in mosquito longevity. Sci Rep. 2022 Sep 9;12(1):15245. doi:10.1038/s41598-022-19574-x
25. Hussain M, Frentiu FD, Moreira LA, O'Neill SL, Asgari S. Wolbachia uses host microRNAs to manipulate host gene expression and facilitate colonization of the dengue vector Aedes aegypti. Proc Natl Acad Sci USA. 2011 May 31;108(22):9250–5. doi:10.1073/pnas.1105469108
26. Hussain M, Walker T, O'Neill SL, Asgari S. Blood meal induced microRNA regulates development and immune associated genes in the Dengue mosquito vector, Aedes aegypti. Insect Biochem Mol Biol. 2013 Feb;43(2):146–52. doi:10.1016/j.ibmb.2012.11.005
27. Zhang G, Hussain M, O'Neill SL, Asgari S. Wolbachia uses a host microRNA to regulate transcripts of a methyltransferase, contributing to dengue virus inhibition in Aedes aegypti. Proc Natl Acad Sci USA. 2013 Jun 18;110(25):10276–81. doi:10.1073/pnas.1303603110
28. Zhang G, Hussain M, Asgari S. Regulation of arginine methyltransferase 3 by a Wolbachia-induced microRNA in Aedes aegypti and its effect on Wolbachia and dengue virus replication. Insect Biochem Mol Biol. 2014 Oct;53:81–8. doi:10.1016/j.ibmb.2014.08.003
29. Osei-Amo S, Hussain M, O'Neill SL, Asgari S. Wolbachia-Induced aae-miR-12 miRNA Negatively Regulates the Expression of MCT1 and MCM6 Genes in Wolbachia-Infected Mosquito Cell Line. PLoS ONE. 2012 Nov 16;7(11):e50049. doi:10.1371/journal.pone.0050049
30. Asad S, Hussain M, Hugo L, Osei-Amo S, Zhang G, Watterson D, et al. Suppression of the pelo protein by Wolbachia and its effect on dengue virus in Aedes aegypti. PLoS Negl Trop Dis. 2018 Apr 11;12(4):e0006405. doi:10.1371/journal.pntd.0006405

*Rendered by Zotero in the NLM/Vancouver (nlm-citation-sequence) CSL style, from the
pasantia-upch group library.*
