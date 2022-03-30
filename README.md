Analysis Results Data Model
================

It is commonly overlooked that analyzing data also produces data in the
form of results. For example, aggregated summaries, descriptive
statistics, and model predictions are data. Although integrating and
putting findings into context is a cornerstone of scientific work,
analysis results are often neglected as a data source.The analysis
results data model (ARDM) is one solution to support analysis results
management and stewardship by combining analysis standards with a common
data model. The ARDM re-frames the target of analyses from static
representations of the results (e.g., tables and figures) to a data
model with applications in a variety of contexts, including knowledge
discovery.

To showcase the ARDM, we focus on its application in a clinical setting.
The development and approval of new treatments generates large volumes
of results, such as summaries of efficacy and safety from supporting
clinical trials. Submission dossiers can contain analysis outputs
spanning thousands of pages; hence, the management and stewardship of
clinical data can greatly benefit from the ARDM.

## How to use

The repository can be used in two ways:

1.  Applying the database - Utilizes the pre-existing database which can
    be immediately queried and applied using the application examples in
    `summary.Rmd`. The database table names and respective entities are
    shown in figure X.

2.  Creating a new database - Utilizes the pre-existing standards and
    schema; the new data must follow the CDISC ADaM format. To
    initialize the new database run `initialize_ardm.R`.

In addition, this document also provides the implementation steps to
create the ARDM (section @ref(implementation)).

### Technical details

The data utilized corresponds to the CDISC Pilot Project ADaM data sets
(CDISC 2013) for subject-level (ASDL), adverse events (ADAE), and
time-to-event (ADTTE) analysis data sets. The ARDM is implemented using
a relational SQLite database (Hipp 2022) through the R programming
language with dependencies on the libraries `haven 2.4.3`, `here 1.0.1`,
`tidyverse 1.3.1`, `DBI 1.1.1`, `RSQLite 2.2.9`, `survival 3.2.10`,
`stringr 1.4.0`, `scales 1.1.1`, and `reactable 0.2.3`.

### Repository structure

**FIGURE HERE** . \* [tree-md](./tree-md) \* [dir2](./dir2) \*
[file21.ext](./dir2/file21.ext) \* [file22.ext](./dir2/file22.ext) \*
[file23.ext](./dir2/file23.ext) \* [dir1](./dir1) \*
[file11.ext](./dir1/file11.ext) \* [file12.ext](./dir1/file12.ext) \*
[file\_in\_root.ext](./file_in_root.ext) \* [README.md](./README.md) \*
[dir3](./dir3)

## Implementation

The ARDM is adaptive and expandable. With each analysis standard, we can
include new tables to the schema. With respect to the inspection and
visualization of the results, there is also the flexibility to create a
variety of outputs, independent from the analysis standard. In the
following subsections, we show how we constructed the proposed analysis
results data model utilizing three analysis standards: descriptive
statistics, safety, and survival analysis.

### Database set-up

Prior to providing clinical data, the algorithm first creates metadata
tables with specifications on the columns names and data type. Table 1,
shows an example for the creation of the *demographics* metadata table.
Similarly, the algorithm creates an *analysis standards* table requiring
information on the analysis standard name, function call and its
parameters, as shown in table 2.

<div id="mtsmljdhoz" style="overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#mtsmljdhoz .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#mtsmljdhoz .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#mtsmljdhoz .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#mtsmljdhoz .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#mtsmljdhoz .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#mtsmljdhoz .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#mtsmljdhoz .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#mtsmljdhoz .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#mtsmljdhoz .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#mtsmljdhoz .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#mtsmljdhoz .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#mtsmljdhoz .gt_group_heading {
  padding: 8px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
}

#mtsmljdhoz .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#mtsmljdhoz .gt_from_md > :first-child {
  margin-top: 0;
}

#mtsmljdhoz .gt_from_md > :last-child {
  margin-bottom: 0;
}

#mtsmljdhoz .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#mtsmljdhoz .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 12px;
}

#mtsmljdhoz .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#mtsmljdhoz .gt_first_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
}

#mtsmljdhoz .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#mtsmljdhoz .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#mtsmljdhoz .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#mtsmljdhoz .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#mtsmljdhoz .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#mtsmljdhoz .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding: 4px;
}

#mtsmljdhoz .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#mtsmljdhoz .gt_sourcenote {
  font-size: 90%;
  padding: 4px;
}

#mtsmljdhoz .gt_left {
  text-align: left;
}

#mtsmljdhoz .gt_center {
  text-align: center;
}

#mtsmljdhoz .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#mtsmljdhoz .gt_font_normal {
  font-weight: normal;
}

#mtsmljdhoz .gt_font_bold {
  font-weight: bold;
}

#mtsmljdhoz .gt_font_italic {
  font-style: italic;
}

#mtsmljdhoz .gt_super {
  font-size: 65%;
}

#mtsmljdhoz .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 65%;
}
</style>
<table class="gt_table">
  <caption>Table 1. <em>demographics</em> metadata table.</caption>
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">parameter_id</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">name</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">adam_column</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">unit</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">var_type</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td class="gt_row gt_left">DEMOG1</td>
<td class="gt_row gt_left">Age</td>
<td class="gt_row gt_left">AGE</td>
<td class="gt_row gt_left">years</td>
<td class="gt_row gt_left">continuous</td></tr>
    <tr><td class="gt_row gt_left">DEMOG2</td>
<td class="gt_row gt_left">Sex</td>
<td class="gt_row gt_left">SEX</td>
<td class="gt_row gt_left">NA</td>
<td class="gt_row gt_left">categorical</td></tr>
    <tr><td class="gt_row gt_left">DEMOG3</td>
<td class="gt_row gt_left">Race</td>
<td class="gt_row gt_left">RACE</td>
<td class="gt_row gt_left">NA</td>
<td class="gt_row gt_left">categorical</td></tr>
  </tbody>
  
  
</table>
</div>
<div id="vnmsfsdghg" style="overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#vnmsfsdghg .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#vnmsfsdghg .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#vnmsfsdghg .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#vnmsfsdghg .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#vnmsfsdghg .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#vnmsfsdghg .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#vnmsfsdghg .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#vnmsfsdghg .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#vnmsfsdghg .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#vnmsfsdghg .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#vnmsfsdghg .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#vnmsfsdghg .gt_group_heading {
  padding: 8px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
}

#vnmsfsdghg .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#vnmsfsdghg .gt_from_md > :first-child {
  margin-top: 0;
}

#vnmsfsdghg .gt_from_md > :last-child {
  margin-bottom: 0;
}

#vnmsfsdghg .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#vnmsfsdghg .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 12px;
}

#vnmsfsdghg .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#vnmsfsdghg .gt_first_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
}

#vnmsfsdghg .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#vnmsfsdghg .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#vnmsfsdghg .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#vnmsfsdghg .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#vnmsfsdghg .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#vnmsfsdghg .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding: 4px;
}

#vnmsfsdghg .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#vnmsfsdghg .gt_sourcenote {
  font-size: 90%;
  padding: 4px;
}

#vnmsfsdghg .gt_left {
  text-align: left;
}

#vnmsfsdghg .gt_center {
  text-align: center;
}

#vnmsfsdghg .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#vnmsfsdghg .gt_font_normal {
  font-weight: normal;
}

#vnmsfsdghg .gt_font_bold {
  font-weight: bold;
}

#vnmsfsdghg .gt_font_italic {
  font-style: italic;
}

#vnmsfsdghg .gt_super {
  font-size: 65%;
}

#vnmsfsdghg .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 65%;
}
</style>
<table class="gt_table">
  <caption>Table 2. <em>analysis standards</em> metadata table.</caption>
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">analysis_id</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">name</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">function_call</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">options</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">var_type</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">default</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td class="gt_row gt_left">AS1</td>
<td class="gt_row gt_left">descriptive_analysis</td>
<td class="gt_row gt_left">store_analysis_results_continuous()</td>
<td class="gt_row gt_left">connection, group_by_treatment, parameter</td>
<td class="gt_row gt_left">continuous</td>
<td class="gt_row gt_left">Y</td></tr>
    <tr><td class="gt_row gt_left">AS2</td>
<td class="gt_row gt_left">descriptive_analysis</td>
<td class="gt_row gt_left">store_analysis_results_categorical()</td>
<td class="gt_row gt_left">connection, group_by_treatment, parameter</td>
<td class="gt_row gt_left">categorical</td>
<td class="gt_row gt_left">Y</td></tr>
    <tr><td class="gt_row gt_left">AS3</td>
<td class="gt_row gt_left">safety_analysis()</td>
<td class="gt_row gt_left">store_analysis_safety()</td>
<td class="gt_row gt_left">connection, aes_interest</td>
<td class="gt_row gt_left"></td>
<td class="gt_row gt_left">Y</td></tr>
  </tbody>
  
  
</table>
</div>

Following, it creates intermediate data tables that aggregate
information at the subject-level. Table 3, shows an example for the
creation of the *demographics per subject* intermediate data table. The
metadata tables are created to record additional information such as
variables types and measurement units. The intermediate data tables are
useful to avoid repeated data transformations (e.g., repeated
aggregations) thus, reducing potential errors and computational
execution time during the analysis.

<div id="ouucvuurli" style="overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#ouucvuurli .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#ouucvuurli .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#ouucvuurli .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#ouucvuurli .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#ouucvuurli .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#ouucvuurli .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#ouucvuurli .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#ouucvuurli .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#ouucvuurli .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#ouucvuurli .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#ouucvuurli .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#ouucvuurli .gt_group_heading {
  padding: 8px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
}

#ouucvuurli .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#ouucvuurli .gt_from_md > :first-child {
  margin-top: 0;
}

#ouucvuurli .gt_from_md > :last-child {
  margin-bottom: 0;
}

#ouucvuurli .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#ouucvuurli .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 12px;
}

#ouucvuurli .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#ouucvuurli .gt_first_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
}

#ouucvuurli .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#ouucvuurli .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#ouucvuurli .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#ouucvuurli .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#ouucvuurli .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#ouucvuurli .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding: 4px;
}

#ouucvuurli .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#ouucvuurli .gt_sourcenote {
  font-size: 90%;
  padding: 4px;
}

#ouucvuurli .gt_left {
  text-align: left;
}

#ouucvuurli .gt_center {
  text-align: center;
}

#ouucvuurli .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#ouucvuurli .gt_font_normal {
  font-weight: normal;
}

#ouucvuurli .gt_font_bold {
  font-weight: bold;
}

#ouucvuurli .gt_font_italic {
  font-style: italic;
}

#ouucvuurli .gt_super {
  font-size: 65%;
}

#ouucvuurli .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 65%;
}
</style>
<table class="gt_table">
  <caption>Table 3. <em>demographics per subject</em> table.</caption>
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">subject_id</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">parameter_id</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">name</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">value</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">unit</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">var_type</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td class="gt_row gt_left">01-701-1015</td>
<td class="gt_row gt_left">DEMOG1</td>
<td class="gt_row gt_left">Age</td>
<td class="gt_row gt_left">63</td>
<td class="gt_row gt_left">years</td>
<td class="gt_row gt_left">continuous</td></tr>
    <tr><td class="gt_row gt_left">01-701-1015</td>
<td class="gt_row gt_left">DEMOG2</td>
<td class="gt_row gt_left">Sex</td>
<td class="gt_row gt_left">F</td>
<td class="gt_row gt_left">NA</td>
<td class="gt_row gt_left">categorical</td></tr>
    <tr><td class="gt_row gt_left">01-701-1015</td>
<td class="gt_row gt_left">DEMOG3</td>
<td class="gt_row gt_left">Race</td>
<td class="gt_row gt_left">White</td>
<td class="gt_row gt_left">NA</td>
<td class="gt_row gt_left">categorical</td></tr>
  </tbody>
  
  
</table>
</div>

The algorithm continues with the creation of the results tables with
specifications on the analysis results information that will be stored.
Note that the creation of the metadata, intermediate data, and result
tables require upfront planning to identify which information should be
recorded.

Although it is possible to create tables ad hoc, a fundamental part of
the ARDM is to generalize and remove redundancies rather than creating a
multitude of fit-for-purpose solutions. Hence, creating a successful
ARDM requires understanding the clinical development pipeline to
effectively plan the analysis by taking into account the downstream
applications of the results (e.g., the analysis standard or the creation
of a boxplot to visualize the data distribution).

A comparable way of planning analyses is to look at estimands (Akacha et
al. 2021). With estimands the question to answer is clearly defined so
we know what to estimate. With an analysis standard we can clearly
specify the analysis workflow by leveraging a grammar. Since these steps
are clearly defined, the analysis is reproducible and transparent.

### Analysis standards

To create the analysis standard, we examined clinical study reports and
relevant literature to identify key analysis and results applications.
Although there is a degree of variability according to the disease or
target population, we found overlaps which we used to build this ARDM
prototype. We focus on three analysis standards:

-   Descriptive statistics: This standard provides a quantitative
    description of the data. In this prototype, we calculate descriptive
    statistics on demographics and baselines data.

-   Safety analysis: Targeting the general safety profile, the results
    from this standard are used to inform on the collection of adverse
    events and the respective incidence rates (e.g, per severity and of
    treatment emergent adverse events).

-   Survival analysis: Estimates the time for a group of individuals to
    experience an event of interest (e.g., hospitalization).

With this breakdown we then create three workflows to identify the
instructions required to perform each step of the analysis. This process
brings clear benefits for reproducibility. The standard follows
systematic and immutable steps where otherwise undocumented choices
would alter the analysis results. For simplicity, the rest of the
document focus on the results from the *descriptive analysis standard*.
However, by exploring the repository one can view how the results for
the remaining standards are handled.

### Populating the database

To begin populating the database, the clinical data must follow a
consistent standard. In this implementation we utilize data sets
following the CDISC ADaM format. Starting with ADaM subject-level
(ADSL), adverse events (ADAE), and time-to-event analysis datasets
(ADTTE), the algorithm populates the metadata and intermediate data
tables (e.g., Table 1).

Following, the user selects the analysis standard and provides the
necessary information to successfully run the analysis. The function
calls and the required parameters are shown by querying the *analysis
standards* table (Table 2). An results example for the descriptive
statistics on categorical demographics measurements is present below.

<div id="lctuvesdbu" style="overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#lctuvesdbu .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#lctuvesdbu .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#lctuvesdbu .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#lctuvesdbu .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#lctuvesdbu .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#lctuvesdbu .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#lctuvesdbu .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#lctuvesdbu .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#lctuvesdbu .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#lctuvesdbu .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#lctuvesdbu .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#lctuvesdbu .gt_group_heading {
  padding: 8px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
}

#lctuvesdbu .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#lctuvesdbu .gt_from_md > :first-child {
  margin-top: 0;
}

#lctuvesdbu .gt_from_md > :last-child {
  margin-bottom: 0;
}

#lctuvesdbu .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#lctuvesdbu .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 12px;
}

#lctuvesdbu .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#lctuvesdbu .gt_first_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
}

#lctuvesdbu .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#lctuvesdbu .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#lctuvesdbu .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#lctuvesdbu .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#lctuvesdbu .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#lctuvesdbu .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding: 4px;
}

#lctuvesdbu .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#lctuvesdbu .gt_sourcenote {
  font-size: 90%;
  padding: 4px;
}

#lctuvesdbu .gt_left {
  text-align: left;
}

#lctuvesdbu .gt_center {
  text-align: center;
}

#lctuvesdbu .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#lctuvesdbu .gt_font_normal {
  font-weight: normal;
}

#lctuvesdbu .gt_font_bold {
  font-weight: bold;
}

#lctuvesdbu .gt_font_italic {
  font-style: italic;
}

#lctuvesdbu .gt_super {
  font-size: 65%;
}

#lctuvesdbu .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 65%;
}
</style>
<table class="gt_table">
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">analysis_id</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">study_id</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">treatment_id</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">parameter_id</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">value</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1">N</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1">distinct</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1">missing</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1">frequency</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1">proportion</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">var_type</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td class="gt_row gt_left">AS6</td>
<td class="gt_row gt_left">CDISCPILOT01</td>
<td class="gt_row gt_left">TREAT1</td>
<td class="gt_row gt_left">DEMOG2</td>
<td class="gt_row gt_left">F</td>
<td class="gt_row gt_right">86</td>
<td class="gt_row gt_right">2</td>
<td class="gt_row gt_right">0</td>
<td class="gt_row gt_right">53</td>
<td class="gt_row gt_right">0.61627907</td>
<td class="gt_row gt_left">categorical</td></tr>
    <tr><td class="gt_row gt_left">AS6</td>
<td class="gt_row gt_left">CDISCPILOT01</td>
<td class="gt_row gt_left">TREAT1</td>
<td class="gt_row gt_left">DEMOG2</td>
<td class="gt_row gt_left">M</td>
<td class="gt_row gt_right">86</td>
<td class="gt_row gt_right">2</td>
<td class="gt_row gt_right">0</td>
<td class="gt_row gt_right">33</td>
<td class="gt_row gt_right">0.38372093</td>
<td class="gt_row gt_left">categorical</td></tr>
    <tr><td class="gt_row gt_left">AS6</td>
<td class="gt_row gt_left">CDISCPILOT01</td>
<td class="gt_row gt_left">TREAT1</td>
<td class="gt_row gt_left">DEMOG3</td>
<td class="gt_row gt_left">Black Or African American</td>
<td class="gt_row gt_right">86</td>
<td class="gt_row gt_right">3</td>
<td class="gt_row gt_right">0</td>
<td class="gt_row gt_right">8</td>
<td class="gt_row gt_right">0.09302326</td>
<td class="gt_row gt_left">categorical</td></tr>
  </tbody>
  
  
</table>
</div>

### Querying and applying the analysis results

The results for the descriptive statistics analysis are stored in four
tables: *descriptive demographics categorical*, *descriptive baselines
categorical*, *descriptive demographics continuous*, and *descriptive
baselines continuous*. Further, as the information stored in the results
tables is dictated by the analysis standard, it is possible to inspect
the results by querying the database and creating visualizations to
better interpret the results. Below, we show an example using the
results from *descriptive demographics categorical* table. The modular
nature of the ARDM separates the results generation from the downstream
outputs hence, updates on the visualizations do not affect the approach
to get the results.

![](README_files/figure-gfm/applications-1.png)<!-- -->

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-akacha2021estimands" class="csl-entry">

Akacha, Mouna, Christian Bartels, Björn Bornkamp, Frank Bretz, Neva
Coello, Thomas Dumortier, Michael Looby, et al. 2021. “Estimands—What
They Are and Why They Are Important for Pharmacometricians.” *CPT:
Pharmacometrics & Systems Pharmacology* 10 (4): 279.

</div>

<div id="ref-cdiscpilotdata" class="csl-entry">

CDISC. 2013. “CDISCPilot01.”
<https://github.com/phuse-org/phuse-scripts/tree/master/data/adam/cdiscpilot01>.

</div>

<div id="ref-sqlite2022hipp" class="csl-entry">

Hipp, Richard D. 2022. “SQLite.” <https://www.sqlite.org/index.html>.

</div>

</div>
