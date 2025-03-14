// regressions_authors_shapley_papers.do
// This file conducts analyses necessary to reproduce the shapley-owen decomposition.

*****************
* PRELIMINARIES *
*****************

// clear open data
clear
clear matrix

// turn more off
set more off

// load .dta
use "data/analytical/wos_2017_authors_df_for_regressions.dta", replace

**********************
* VARIABLES + SAMPLE *
**********************

// make uniform names
rename subject_extended_r1 subfield_id
rename dais_id author_id

// make numeric ids
egen nsubfield_id = group(subfield_id)
egen nauthor_id = group(author_id)
egen npubyear = group(pubyear)

**********
* MODELS *
**********

// variables
global vars nsubfield_id nauthor_id npubyear
local tolerance tolerance(1e-6)

// sample indicator
capture drop touse
mark touse
markout touse cd_5 $vars

// BEGIN SHAPLEY CODE //////////////////////////////////////////////////////////

// run regressions over combinations
capture drop rsq
capture drop predictors
capture drop p
gen rsq = .
gen predictors = ""
tuples $vars
quietly forvalues i = 1/`ntuples' {
  reghdfe cd_5 if touse == 1, absorb(`tuple`i'') keepsingletons `tolerance' verbose(3)
  replace rsq = e(r2_a) in `i'
  replace predictors = "`tuple`i''" in `i'
}
generate p = wordcount(predictors) if predictors != ""
sort p rsq
list predictors rsq in 1/`ntuples'

// save to file
export delimited predictors rsq using "data/analytical/papers_shapley_data_raw.csv", replace

// END SHAPLEY CODE ////////////////////////////////////////////////////////////

