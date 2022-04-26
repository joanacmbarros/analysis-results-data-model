Analysis Results Data Model
================

It is commonly overlooked that analyzing data also produces data in the form of results. For example, aggregated summaries, descriptive statistics, and model predictions are data. Although integrating and putting findings into context is a cornerstone of scientific work, analysis results are often neglected as a data source.The analysis results data model (ARDM) is one solution to support analysis results management and stewardship by combining analysis standards with a common data model. The ARDM re-frames the target of analyses from static representations of the results (e.g., tables and figures) to a data model with applications in a variety of contexts, including knowledge discovery. To showcase the ARDM, we focus on its application in a clinical setting.

## How to use

This repository exemplifies how to create the ARDM. It should be viewed as a work in progress. This can be used in two ways:

1.  Applying the database - Utilizes the pre-existing database which can be immediately queried and applied using the application examples in `summary.Rmd`.

2.  Creating a new database - Utilizes the pre-existing standards and schema; the new data must follow the CDISC ADaM format. To initialize the new database run `initialize_ardm.R`.

### Technical details

The data utilized corresponds to the CDISC Pilot Project ADaM data sets (CDISC, 2013) for subject-level (ASDL), adverse events (ADAE), and time-to-event (ADTTE) analysis data sets. The ARDM is implemented using a relational SQLite database (Hipp 2022) through the R programming language with dependencies on the libraries `haven 2.4.3`, `here 1.0.1`, `tidyverse 1.3.1`, `DBI 1.1.1`, `RSQLite 2.2.9`, `survival 3.2.10`, `stringr 1.4.0`, `scales 1.1.1`, and `reactable 0.2.3`. However, these choices can be revisited as the ARDM can be implemented using a variety of languages and databases. 

## Implementation

The ARDM is adaptive and expandable. For example, with each analysis standard, we can adapt or create new tables to the schema and expand the modules supporting a variety outputs. With respect to the inspection and visualization of the results, there is also the flexibility to create a variety of outputs, independent from the analysis standard. In the following sections, we show how to construct the proposed analysis results data model utilizing three analysis standards: descriptive statistics, safety, and survival analysis. 

### Database set-up

Prior to ingesting clinical data, the algorithm first creates empty tables with specifications on the column names and data types. These tables are grouped in metadata, intermediate data, and results. The metadata tables are created to record additional information such as variables types and measurement units. Table 1 shows an example for the creation of the *demographics* metadata table. As part of the metadata tables, the algorithm also creates an *analysis standards* table (table 2) requiring information on the analysis standard name, function call and its parameters.

<br>
<p align="center">
    Table 1. Example for the <i>demographics</i> metadata table.
</p>
<p align="center">
  <img src="README_files/figures/table1_md.png", width="400"/>
</p>

<br>
<p align="center">
    Table 2. Example for the <i>analysis standards</i> table.
 </p>
<p align="center">
  <img src="README_files/figures/table2_as.png", width="800"/>
</p>

Following, it creates intermediate data tables that aggregate information at the subject-level. Table 3, shows an example for the *demographics per subject* intermediate data table. The algorithm continues with the creation of the results tables with specifications on the analysis results information that will be stored. 

The metadata tables are created to record additional information such as variables types and measurement units while the intermediate data tables are useful to avoid repeated data transformations (e.g., repeated aggregations), reducing potential errors and computational execution time during the analysis. The results tables specify the analysis results information that will be stored. Note that the creation of the metadata, intermediate data, and result tables require upfront planning to identify which information should be recorded. 

<br>
<p align="center">
    Table 3. Example for the <i>demographics per subject</i> table.
 </p>
<p align="center">
  <img src="README_files/figures/table3_id.png", width="600"/>
</p>

Although it is possible to create tables ad hoc, a fundamental part of the ARDM is to generalize and remove redundancies rather than creating a multitude of fit-for-purpose solutions. Hence, creating a successful ARDM requires understanding the clinical development pipeline to effectively plan the analysis by taking into account the downstream applications of the results (e.g., the analysis standard or the creation of a  boxplot to visualize the data distribution). A comparable way of planning analyses is to look at estimands (Akacha et al., 2021). With estimands the question to answer is clearly defined so we know what to estimate. With an analysis standard we can clearly specify the analysis workflow by leveraging a grammar. Since these steps are clearly defined, the analysis is reproducible and transparent.

### Analysis standards

To create the analysis standard, we examined clinical study reports and relevant literature to identify key analysis and results applications. Although there is a degree of variability according to the disease or target population, we found overlaps which we used to build this ARDM prototype. We focus on three analysis standards:

-   Descriptive statistics: This standard provides a quantitative description of the data. In this prototype, we calculate descriptive statistics on demographics and baselines data.

-   Safety analysis: Targeting the general safety profile, the results from this standard are used to inform on the collection of adverse events and the respective incidence rates (e.g, per severity and of treatment emergent adverse events).

-   Survival analysis: Estimates the time for a group of individuals to experience an event of interest (e.g., hospitalization).

With this breakdown we then create three workflows to identify the instructions required to perform each step of the analysis. This process brings clear benefits for reproducibility. The standard follows systematic and immutable steps where otherwise undocumented choices would alter the analysis results. For simplicity, the rest of the section will focus on the results from the *descriptive analysis standard*. However, through the public ARDM implementation repository one can view how the results for the reaming standards are handled.

### Populating the database

To begin populating the database, the clinical data must follow a consistent standard. In this implementation we utilize data sets following the CDISC ADaM format. Starting with ADaM subject-level (ADSL), adverse events (ADAE), and time-to-event analysis datasets (ADTTE), the algorithm populates the metadata and intermediate data tables. Next, the user selects the analysis standard and provides the necessary information to successfully run the analysis. The function calls and the required parameters are shown by querying the *analysis standards* table. An example for an analysis on demographics measurements is present below.

<br>
<p align="center">
   Table 4. Results table example for descriptive statistics from demographic data.
 </p>
<p align="center">
  <img src="README_files/figures/table4_result.png", width="2000"/>
</p>

### Querying and applying the analysis results

The results for the descriptive statistics analysis are stored in four tables: *descriptive demographics categorical*, *descriptive baselines categorical*, *descriptive demographics continuous*, and *descriptive baselines continuous*. Further, as the information stored in the results tables is dictated by the analysis standard, it is possible to inspect the results by querying the database and creating visualizations to better interpret the results. The modular nature of the ARDM separates the results generation from the downstream outputs hence, updates on the visualizations do not affect the approach to get the results.

The results summary example with a variety of plots and a table is available [here](https://joanacmbarros.github.io/analysis-results-data-model/).

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-akacha2021estimands" class="csl-entry">

Akacha, Mouna, Christian Bartels, Björn Bornkamp, Frank Bretz, Neva Coello, Thomas Dumortier, Michael Looby, et al. 2021. “[Estimands—What They Are and Why They Are Important for Pharmacometricians.](https://ascpt.onlinelibrary.wiley.com/doi/full/10.1002/psp4.12617)” *CPT: Pharmacometrics & Systems Pharmacology* 10 (4): 279.

</div>

<div id="ref-cdiscpilotdata" class="csl-entry">

CDISC. 2013. “CDISCPilot01.” <https://github.com/phuse-org/phuse-scripts/tree/master/data/adam/cdiscpilot01>.

</div>

<div id="ref-sqlite2022hipp" class="csl-entry">

Hipp, Richard D. 2022. “SQLite.” <https://www.sqlite.org/index.html>.

</div>

</div>
