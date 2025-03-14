// regression_analysis.do
// This file conducts analyses necessary to reproduce the main regression analyses.

////////////////////////////////////////////////////////////////////////////////
// PATENTS /////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

*****************
* PRELIMINARIES *
*****************

// clear open data
clear
clear matrix

// turn more off
set more off

// load .dta
use "data/analytical/patentsview_df_for_regressions.dta", replace

*************
* VARIABLES *
*************

// encode strings
encode field_nber_subcategory_id, generate(nfield_nber_subcategory_id)

// make uniform names
rename nfield_nber_subcategory_id subfield_id
rename nsc_upatents_cited_nentropy_t cited_nentropy_t
rename grant_year pubyear
rename invs_crr_age_mean_t team_crr_age_mean_t
rename invs_crr_npatent_ids_mean_t team_crr_experience_mean_t

// cited_self/cited_total
gen cited_self_to_total = cited_self/cited_total

label variable cd_5 "CD$\textsubscript{5}$ index"
label variable cited_nentropy_t "Diversity of work cited" 
label variable cited_self_to_total "Ratio of self-citations to total work cited" 
label variable cited_age_mean "Mean age of work cited" 
label variable cited_age_sd "Dispersion in age of work cited" 
label variable pubyear "Publication year"
label variable subfield_id "NBER technology subcategory"
label variable team_crr_age_mean_t "Mean age of team members"
label variable team_crr_experience_mean_t "Mean number of prior works produced by team members"

// set very old teams to missing
replace team_crr_age_mean_t = . if team_crr_age_mean_t > 80

*******************
* NOTES ON LEVELS *
*******************
note cited_nentropy_t: Field $\times$ year 
note cited_self_to_total: Publication 
note cited_age_mean: Publication
note cited_age_sd: Publication
note pubyear: Year
note subfield_id: Field
note cd_5: Publication  
note team_crr_age_mean_t: Publication
note team_crr_experience_mean_t: Publication

**********
* MODELS *
**********

// sample indicator
mark touse_patents
markout touse_patents cited_nentropy_t cited_self_to_total cited_age_mean cited_age_sd team_crr_age_mean_t team_crr_experience_mean_t

// condition
global condition "if touse_patents == 1"

// cd index ////////////////////////////////////////////////////////////////////
		   
reghdfe cd_5 cited_nentropy_t                                                      $condition, absorb(pubyear subfield_id) vce(robust)
eststo PM1

reghdfe cd_5 cited_nentropy_t cited_self_to_total                                  $condition, absorb(pubyear subfield_id) vce(robust)
eststo PM2

reghdfe cd_5 cited_nentropy_t cited_self_to_total c.cited_age_mean c.cited_age_sd  $condition, absorb(pubyear subfield_id) vce(robust)
eststo PM3

reghdfe cd_5 cited_nentropy_t cited_self_to_total c.cited_age_mean##c.cited_age_sd $condition, noabsorb vce(robust)
eststo PM4

reghdfe cd_5 cited_nentropy_t cited_self_to_total c.cited_age_mean##c.cited_age_sd $condition, absorb(pubyear subfield_id) vce(robust)
eststo PM5

reghdfe cd_5 cited_nentropy_t cited_self_to_total c.cited_age_mean##c.cited_age_sd team_crr_age_mean_t team_crr_experience_mean_t $condition, absorb(pubyear subfield_id) vce(robust)
eststo PM6

// descriptive statistics (patents) ////////////////////////////////////////////

// open file for writing
file close _all
file open summary_statistics_file using results/raw/supplementary_table_3_patents.tex, write replace

// list of variables to include in summary table
local utilization_vars cited_nentropy_t ///
                       cited_self_to_total ///
					   cited_age_mean ///
					   cited_age_sd

local control_vars team_crr_age_mean_t ///
                   team_crr_experience_mean_t
					   
local outcome_vars    cd_5 

// list of fixed effects variables to include in summary table
local fixed_effects_vars pubyear subfield_id

// summary loop program
capture program drop sumloop
program define sumloop
syntax varlist

// loop over topological variables
foreach v of varlist `varlist' {
    
	// get type of v
	local vtype: type `v'
	
	// compute N_total/N_unique
	unique `v'
		
	// extract N_unique
	local unique = r(sum)
	
	// compute descriptives 
	quietly sum `v'

	// extract observations
	local observations = r(N)
	
	// extract mean
	local mean = r(mean)
	local mean =  string(`mean',"%9.2f")

	// extract sd 
	local sd = r(sd)
	local sd = string(`sd',"%9.2f")

    // extract min	
	local min = r(min)
	if substr("`vtype'",1,5)== "float" | substr("`vtype'",1,6)== "double" {
		local min = string(`min',"%9.2f")
	}
	
	// extract max
	local max = r(max)
	if substr("`vtype'",1,5)== "float" | substr("`vtype'",1,6)== "double" {
		local max = string(`max',"%9.2f")
	}
	
	// extract variable label
	local labelofvariable: variable label `v'
	
	// write line to file	
    file write summary_statistics_file " `labelofvariable' &  `observations' & `unique' & `mean' & `sd' & `min' & `max' & ``v'[note1]' \\  " _n
 
 // end loop
 }
end

// utilization variables
file write summary_statistics_file " Use of existing knowledge & \\   " _n
sumloop `utilization_vars'
file write summary_statistics_file " \midrule   " _n

// control variables
file write summary_statistics_file " Controls & \\   " _n
sumloop `control_vars'
file write summary_statistics_file " \midrule   " _n

// outcome variables
file write summary_statistics_file " Outcomes & \\   " _n
sumloop `outcome_vars'
file write summary_statistics_file " \midrule   " _n

// fixed effects header
file write summary_statistics_file " Fixed effects & \\   " _n


// loop over fixed effects variables
foreach v of varlist `fixed_effects_vars' {
    
	// compute N_total/N_unique
	unique `v'
		
	// extract N_unique
	local unique = r(sum)
	
	// compute descriptives 
	quietly sum `v'

	// extract observations
	local observations = r(N)
	
	// extract mean
	local mean = "--"

	// extract sd 
	local sd = "--"

    // extract min	
	local min = "--"
	
	// extract max
	local max = "--"
	
	// extract variable label
	local labelofvariable: variable label `v'
	
	// write line to file	
    file write summary_statistics_file " `labelofvariable' &  `observations' & `unique' & `mean' & `sd' & `min' & `max' & ``v'[note1]' \\  " _n
 
 // end loop
 }

 
// close the file
file close summary_statistics_file


///////////////////////////////////////////////////////////////////////////////
// PAPERS /////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

*****************
* PRELIMINARIES *
*****************

// load .dta
use "data/analytical/wos_2017_df_for_regressions.dta", replace

*************
* VARIABLES *
*************

// encode strings
encode subject_extended_r1, generate(nsubject_extended_r1)

// make uniform names
rename nsubject_extended_r1 subfield_id
rename se_articles_cited_nentropy_t cited_nentropy_t
rename auths_crr_age_mean_t team_crr_age_mean_t
rename auths_crr_nrecord_ids_mean_t team_crr_experience_mean_t


// cited_self/cited_total
gen cited_self_to_total = cited_self/cited_total

// labels
label variable cd_5 "CD$\textsubscript{5}$ index"
label variable cited_nentropy_t "Diversity of work cited" 
label variable cited_self_to_total "Ratio of self-citations to total work cited" 
label variable cited_age_mean "Mean age of work cited" 
label variable cited_age_sd "Dispersion in age of work cited" 
label variable pubyear "Publication year"
label variable subfield_id "WoS extended subject" 
label variable team_crr_age_mean_t "Mean age of team members"
label variable team_crr_experience_mean_t "Mean number of prior works produced by team members"

// set very old teams to missing
replace team_crr_age_mean_t = . if team_crr_age_mean_t > 80

*******************
* NOTES ON LEVELS *
*******************
note cited_nentropy_t: Field $\times$ year 
note cited_self_to_total: Publication 
note cited_age_mean: Publication
note cited_age_sd: Publication
note pubyear: Year
note subfield_id: Field
note cd_5: Publication  
note team_crr_age_mean_t: Publication
note team_crr_experience_mean_t: Publication

**********
* MODELS *
**********

// sample indicator
mark touse_papers
markout touse_papers cited_nentropy_t cited_self_to_total cited_age_mean cited_age_sd team_crr_age_mean_t team_crr_experience_mean_t

// condition
global condition "if touse_papers == 1"
		   
reghdfe cd_5 cited_nentropy_t                                                      $condition, absorb(pubyear subfield_id) vce(robust)
eststo WM1

reghdfe cd_5 cited_nentropy_t cited_self_to_total                                  $condition, absorb(pubyear subfield_id) vce(robust)
eststo WM2

reghdfe cd_5 cited_nentropy_t cited_self_to_total c.cited_age_mean c.cited_age_sd  $condition, absorb(pubyear subfield_id) vce(robust)
eststo WM3

reghdfe cd_5 cited_nentropy_t cited_self_to_total c.cited_age_mean##c.cited_age_sd $condition, noabsorb vce(robust)
eststo WM4

reghdfe cd_5 cited_nentropy_t cited_self_to_total c.cited_age_mean##c.cited_age_sd $condition, absorb(pubyear subfield_id) vce(robust)
eststo WM5

reghdfe cd_5 cited_nentropy_t cited_self_to_total c.cited_age_mean##c.cited_age_sd team_crr_age_mean_t team_crr_experience_mean_t $condition, absorb(pubyear subfield_id) vce(robust)
eststo WM6


// descriptive statistics (papers) /////////////////////////////////////////////

// open file for writing
file close _all
file open summary_statistics_file using results/raw/supplementary_table_3_papers.tex, write replace

// list of variables to include in summary table
local utilization_vars cited_nentropy_t ///
                       cited_self_to_total ///
					   cited_age_mean ///
					   cited_age_sd

local control_vars team_crr_age_mean_t ///
                   team_crr_experience_mean_t
					   
local outcome_vars    cd_5 

// list of fixed effects variables to include in summary table
local fixed_effects_vars pubyear subfield_id

// summary loop program
capture program drop sumloop
program define sumloop
syntax varlist

// loop over topological variables
foreach v of varlist `varlist' {
    
	// get type of v
	local vtype: type `v'
	
	// compute N_total/N_unique
	unique `v'
		
	// extract N_unique
	local unique = r(sum)
	
	// compute descriptives 
	quietly sum `v'

	// extract observations
	local observations = r(N)
	
	// extract mean
	local mean = r(mean)
	local mean =  string(`mean',"%9.2f")

	// extract sd 
	local sd = r(sd)
	local sd = string(`sd',"%9.2f")

    // extract min	
	local min = r(min)
	if substr("`vtype'",1,5)== "float" | substr("`vtype'",1,6)== "double" {
		local min = string(`min',"%9.2f")
	}
	
	// extract max
	local max = r(max)
	if substr("`vtype'",1,5)== "float" | substr("`vtype'",1,6)== "double" {
		local max = string(`max',"%9.2f")
	}
	
	// extract variable label
	local labelofvariable: variable label `v'
	
	// write line to file	
    file write summary_statistics_file " `labelofvariable' &  `observations' & `unique' & `mean' & `sd' & `min' & `max' & ``v'[note1]' \\  " _n
 
 // end loop
 }
end

// utilization variables
file write summary_statistics_file " Use of existing knowledge & \\   " _n
sumloop `utilization_vars'
file write summary_statistics_file " \midrule   " _n

// control variables
file write summary_statistics_file " Controls & \\   " _n
sumloop `control_vars'
file write summary_statistics_file " \midrule   " _n

// outcome variables
file write summary_statistics_file " Outcomes & \\   " _n
sumloop `outcome_vars'
file write summary_statistics_file " \midrule   " _n

// fixed effects header
file write summary_statistics_file " Fixed effects & \\   " _n


// loop over fixed effects variables
foreach v of varlist `fixed_effects_vars' {
    
	// compute N_total/N_unique
	unique `v'
		
	// extract N_unique
	local unique = r(sum)
	
	// compute descriptives 
	quietly sum `v'

	// extract observations
	local observations = r(N)
	
	// extract mean
	local mean = "--"

	// extract sd 
	local sd = "--"

    // extract min	
	local min = "--"
	
	// extract max
	local max = "--"
	
	// extract variable label
	local labelofvariable: variable label `v'
	
	// write line to file	
    file write summary_statistics_file " `labelofvariable' &  `observations' & `unique' & `mean' & `sd' & `min' & `max' & ``v'[note1]' \\  " _n
 
 // end loop
 }

 
// close the file
file close summary_statistics_file


///////////////////////////////////////////////////////////////////////////////
// OUTPUT /////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////


// label fixed effects   
estfe WM1 /*   
   */ WM2 /*
   */ WM3 /*
   */ WM4 /*
   */ WM5 /*
   */ WM6 /*
   */ PM1 /*   
   */ PM2 /*
   */ PM3 /*
   */ PM4 /*
   */ PM5 /*
   */ PM6, labels(pubyear "\midrule Year fixed effects" subfield_id "Field fixed effects" _cons "%")

// for keeping most formatting in LaTeX	
// output table
esttab WM1 /*   
   */ WM2 /*
   */ WM3 /*
   */ WM4 /*
   */ WM5 /*
   */ WM6 /*
   */ PM1 /*   
   */ PM2 /*
   */ PM3 /*
   */ PM4 /*
   */ PM5 /*
   */ PM6 using "results/raw/extended_data_table_1.tex", /*
*/ replace booktabs nolegend nonotes nobase label nogaps compress /* nogaps compress
*/ b(4) se(4) /*
*/ stats(N r2, fmt(%20.0g %9.2f) labels("N" "R2")) /*  
*/ varwidth(45) modelwidth(15) noabbrev /* 
*/ interaction(" $\times$ ") /*
*/ indicate(`r(indicate_fe)') /*
*/ nomtitles /*
*/ starlevels(+ 0.1 * 0.05 ** 0.01 *** 0.001) /*
*/ keep(cited_nentropy_t cited_self_to_total cited_age_mean cited_age_sd c.cited_age_mean#c.cited_age_sd team_crr_age_mean_t team_crr_experience_mean_t) /*
*/ mgroups("\shortstack{Sample: Web of Science}" "\shortstack{Sample: Patents View}", pattern(1 0 0 0 0 0 1 0 0 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) /*
*/ varlabels(_cons Constant, elist(_cons \midrule ) ) prehead(" ") postfoot(" ")





