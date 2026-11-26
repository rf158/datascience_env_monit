# Block 5 Assignment: Test one question with your towers and two more datasets

## Overview

In Block 5 you met eight datasets that describe the neighbourhood of a flux tower: climate, extremes, soil, plants, tree mortality, biodiversity and satellite greenness. In this assignment you use them to answer a question of your own.

You pick **one question**, choose **two datasets** in addition to your FLUXNET data, download the variables you need for your five towers, test the question, and **document every step** in a short report rendered from code.

Hand in two things on ILIAS **before Block 6 (Friday 27 November 2026, 8:30)**: the rendered HTML report and the link to your fork on GitHub that contains the report's source (`.qmd`, `.Rmd` or `.ipynb`).

| Part | What you do | Time |
| --- | --- | --- |
| 0 | Sync your fork and set up the Block 5 scripts | 15 min |
| A | Choose your question and your two datasets | 20 min |
| B | Download the data for your five towers | 30–60 min |
| C | Prepare and merge the data | 45 min |
| D | Test your question | 60 min |
| E | Write the report | 60 min |
| Hand-in | Check the list and submit on ILIAS | 10 min |

**Before you start, you need:**

- Your fork of the course repository and the Block 4 work: the five FLUXNET zips in `data/raw` and your `read_hh()` function or the daily files.
- `tower_sets_block4.csv` (ILIAS, folder DATA) in your project folder.
- R in Positron or Python in VS Code, and Quarto (as in Block 4).
- For ERA5-Land only: a free account at the [Copernicus Climate Data Store](https://cds.climate.copernicus.eu) with the dataset licence accepted. Do this first; it can take a while.

## Part 0: Sync your fork and set up the scripts (15 min)

Bring the new material from the course repository into your fork, as in Block 4 (commit or stash your own changes first):

```bash
git pull --no-rebase upstream main
git push
```

**Check:** your project now has the folder `scripts/block5/` with `01_era5land` … `09_merge` (each as `.R` and `.py`), `block5_sites.R`/`.py` and a `README.md`.

Open `scripts/block5/block5_sites.R` (or `block5_sites.py`) and set your student number **once**:

```r
my_student <- "07"     # your number from tower_sets_block4.csv
```

Install the packages listed in `scripts/block5/README.md` for your language. You only need the packages of the scripts you will run.

## Part A: Choose your question and your datasets (20 min)

### A1. Your question

Choose **one** of the six questions from the Block 5 slides, **or** ask your own question.

| # | Question | Datasets it needs (besides FLUXNET) | Works for |
| --- | --- | --- | --- |
| 1 | **Greenness and productivity.** Does EVI or NDVI follow GPP through the seasons? Which tower fits best, and when does the relationship break? | MODIS (08) | all towers |
| 2 | **Soil water limits.** Plot summer GPP against ERA5-Land soil moisture (`swvl2`). Is there a threshold below which GPP drops? | ERA5-Land (01) | all towers |
| 3 | **Extreme events.** Are NEE and GPP different on Dheed event days than on the same calendar days in other years? | Dheed (03) | towers with an event in their record |
| 4 | **Normal or not?** How far is each tower year's mean temperature and precipitation from the WorldClim 1970–2000 normal (BIO1, BIO12)? | WorldClim (02) | all towers |
| 5 | **Traits and soil.** Do leaf N, SLA or clay content explain the maximum GPP of a tower? | PlantTraits (05), SoilGrids (04) | all towers (n = 5, see below) |
| 6 | **Mortality.** Does standing deadwood per year relate to annual GPP? | deadtrees.earth (06) | European forest towers |

**Your own question** is welcome. It must be answerable with your flux data plus at least one of the Block 5 datasets, within this week. Write it in one sentence. Not sure it works? Post it in the ILIAS forum by Tuesday and you will get feedback.

Write down:

1. **Your question** in one sentence.
2. **Your hypothesis**: what do you expect, in which direction, and why (one or two sentences, with the ecological reason).

### A2. Your two datasets

Choose **two** datasets from the Block 5 list, in addition to your FLUXNET data. At least one must be the dataset your question needs (see the table). The second one can help to explain your result, describe your sites, or test the question a second way.

| Script | Dataset | Typical variables |
| --- | --- | --- |
| `01_era5land` | ERA5-Land (0.1°, hourly) | soil moisture `swvl1–3`, soil temperature, air temperature |
| `02_worldclim` | WorldClim 2.1 (5′) | BIO1–BIO19, monthly temperature and precipitation normals |
| `03_dheed` | Dheed (0.25°, daily) | compound dry-and-hot events: start, end, bounding box |
| `04_soilgrids` | SoilGrids 2.0 (250 m) | clay, sand, silt, SOC, pH, bulk density, N, CEC by depth |
| `05_planttraits` | PlantTraits (1 km) | SLA, leaf N, wood density, rooting depth … with uncertainty |
| `06_deadtrees` | deadtrees.earth (10 m, Europe) | tree cover and standing deadwood cover per year |
| `07_inaturalist` | iNaturalist | research-grade species observations within 5 km |
| `08_modis_ndvi_evi` | MODIS MOD13Q1 (250 m, 16 days) | red, NIR, blue reflectance → your own NDVI and EVI |

Example combinations: question 1 with MODIS + ERA5-Land (does soil water explain where EVI and GPP disagree?); question 3 with Dheed + MODIS (did the canopy brown during the event?); question 2 with ERA5-Land + SoilGrids (do sandy sites hit the threshold sooner?).

**Check:** before you download anything, you can say which variables of each dataset you need and why.

## Part B: Download the data for your towers (30–60 min)

Run the two scripts from your project folder:

```bash
Rscript scripts/block5/08_modis_ndvi_evi.R          # R
python3 scripts/block5/08_modis_ndvi_evi.py         # Python
```

Each script reads your five towers, downloads the data and writes a CSV with a `site_id` column to `data/external/<dataset>/`. Read the header of the script first: it says what is downloaded, how long it takes, and how to cite it.

You may change the scripts (other variables, a larger radius, more years, another trait). If you do, **say what you changed and why** in your report.

Keep a short log while you work, for Part E:

- the date you downloaded each dataset,
- the settings you used (years, variables, window or radius),
- anything that failed and what you did about it.

**Check:**

- `data/external/<dataset>/` holds a CSV for each of your two datasets, with all five towers (or a clear reason why a tower is missing, for example deadtrees.earth covers only Europe).
- `git status` lists nothing under `data/`.

## Part C: Prepare and merge the data (45 min)

Bring the flux data and your two datasets into tables you can analyse.

1. **Flux data.** Use the FLUXNET daily files (`FLUXMET_DD`) or aggregate your half-hourly data from Block 4. Read −9999 as missing.
2. **Match the time step.** Choose the coarsest common time step for your question: daily (ERA5-Land), 16-day (MODIS), yearly (deadtrees.earth, annual sums) or one value per tower (WorldClim, SoilGrids, PlantTraits, iNaturalist).
3. **Join** by `site_id`, and by `date` or `year` for time series. `scripts/block5/09_merge` builds `data/processed/site_static.csv` (one row per tower) and `site_daily.csv` (one row per tower and day). Use it, adapt it, or write your own join.
4. **Quality.** Apply the quality filters that matter for your question, for example MODIS pixel reliability 0–1 only, measured NEE only (`NEE_VUT_REF_QC`), only towers inside a Dheed event box.

**Check:**

- You know the unit of every column you use (GPP in the daily files is g C m⁻² d⁻¹).
- The number of rows per tower makes sense (one per day, per 16 days, per year or per tower).
- Missing values are `NA`, never filled by hand or copied from another tower.

## Part D: Test your question (60 min)

1. Make **at least one figure** that answers your question directly. Label the axes with units, and show which tower is which.
2. Add **one number** that summarises the answer: a correlation, the slope of a regression, a difference between event days and normal days, a threshold value, or the difference to the climate normal.
3. State **n**: how many towers, years, days or data points the number rests on.
4. Make **one figure or table that describes your two datasets at your five towers** (for example the MODIS NDVI time series per tower, or a table of soil texture and traits per tower).

Statistics should match the question. With five towers, a regression across towers rests on five points: show them, report the result, and say clearly what it can and cannot show. Within a tower, you have many days, but they are not independent of each other. You do not need a perfect test; you need an honest one.

## Part E: Write the report (60 min)

Create `reports/block5_question.qmd` (or `.ipynb`) in your fork. It must render to HTML from a fresh clone with the commands in your README, provided the data are in `data/raw` and `data/external`.

```yaml
---
title: "Block 5: <your question in a few words>"
author: "Your Name"
date: today
format:
  html:
    toc: true
    code-fold: true
    embed-resources: true
execute:
  warning: false
---
```

The report documents **the whole process**, not only the result. It has these sections:

### E1. Question and hypothesis

Your question in one sentence, your hypothesis with its direction and the ecological reason, and why your five towers are (or are not) a good test of it. If you chose your own question, say why it interests you.

### E2. Data

A **provenance table**, one row per dataset (FLUXNET plus your two):

| Dataset | Variables used | Spatial resolution | Time resolution and period | Downloaded on | Script and changes | Citation |
| --- | --- | --- | --- | --- | --- | --- |

Below the table, the description of your two datasets at your five towers (Part D, step 4).

### E3. Methods

Describe what you did, in enough detail that a classmate could repeat it:

- **Download:** which scripts, which settings, what you changed and why, what failed and how you solved it.
- **Extraction:** how each dataset was matched to the tower (nearest cell, window around the tower, point service) and in which coordinate system.
- **Processing:** units and conversions, quality filters, aggregation to a common time step, how you joined the tables, how you treated missing values.
- **Analysis:** what you computed to test the question, and on which n.

### E4. Results

Your figure(s) and the summary number from Part D, each with a caption that a reader understands without the text.

### E5. Discussion

5–10 sentences:

1. Does the result support your hypothesis? For which towers, and for which not?
2. **Scale:** for each of your two datasets, compare the pixel size with the flux footprint (about 100 m – 1 km). What does the mismatch mean for your answer?
3. The two most important limitations (data, n, method), and what you would do with more time or more data.

### E6. Data and citations

Each FLUXNET site citation (from your snapshot), Pastorello et al. (2020), *Scientific Data* 7, 225, the citations of your two datasets (in the header of each script and on the Block 5 slide "How to cite what you used"), and the FLUXNET acknowledgement from `flux4student/README.md`.

## Hand-in and checklist

Submit these two things on ILIAS before Block 6 (Friday 27 November 2026, 8:30):

1. The rendered HTML report.
2. The link to your fork on GitHub (`https://github.com/YOUR-USER/datascience_env_monit`) with the report's source and any scripts you changed.

Tick everything before you submit:

- [ ] My fork is synced with the course repository and contains `scripts/block5/`
- [ ] My question is written in one sentence, with a hypothesis and a reason
- [ ] I used FLUXNET data plus **two** Block 5 datasets, for all five towers (or I explain why a tower is missing)
- [ ] The provenance table lists source, variables, resolution, period, download date, script and citation for every dataset
- [ ] I described every change I made to a script, and every problem I ran into
- [ ] −9999 is read as missing; no value was filled by hand or copied from another tower
- [ ] Every figure has axis labels with units and a tower label
- [ ] My answer gives one summary number and states n
- [ ] The discussion compares each dataset's pixel size with the flux footprint
- [ ] `data/` is in `.gitignore`; nothing under `data/` is in Git
- [ ] The report renders from a fresh clone with the commands in my README

## Troubleshooting

| You see | Usually it means |
| --- | --- |
| `tower_sets_block4.csv not found` | Your working directory is not the project folder. In Positron: *Session → Set Working Directory*. |
| `No towers found for student …` | Set your student number in `scripts/block5/block5_sites.R` / `.py`, or pass it: `Rscript scripts/block5/04_soilgrids.R 07`. |
| ERA5-Land `401` or `403` | Token not set, or the dataset licence is not accepted on the CDS dataset page. |
| ERA5-Land waits a long time | Your request is queued at the CDS. Let it run and continue with your other dataset. |
| SoilGrids `429` or `503` | Too many requests, or the beta service is down. The script retries; otherwise try again later. |
| deadtrees.earth: none of your towers is in Europe | Expected: the satellite maps cover Europe only. Choose another dataset or another question. |
| Dheed finds no event at your towers | A valid result. For question 3, choose another question, or explain it and use the time to test a second dataset. |
| `NA` in SoilGrids or PlantTraits | The pixel is masked (water, urban, rock) or outside the model's area of applicability. Report it. |
| MODIS takes very long | Normal: the service sends 10 dates per request. Reduce `years_back` in the script for a first test. |
| A service is down on the day you work | Write it down, work on the other dataset, try again the next day. Report what happened. |

Stuck for more than 10 minutes? Post the exact command and the last lines of the error on ILIAS.

**Further reading**

- The `README.md` in `scripts/block5/` and the header of each script.
- Pastorello et al. (2020): The FLUXNET2015 dataset and the ONEFlux processing pipeline. *Scientific Data* 7, 225.
- Huete et al. (2002): Overview of the radiometric and biophysical performance of the MODIS vegetation indices. *Remote Sensing of Environment* 83, 195–213.
