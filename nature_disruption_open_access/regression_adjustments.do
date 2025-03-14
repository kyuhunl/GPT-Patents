// regression_adjustments.do
// Run regression adjustments of cd index trends.

*****************
* PRELIMINARIES *
*****************

// clear open data
clear
clear matrix

// turn more off
set more off

// set font
graph set window fontface "Arial"

///////////////////////////////////////////////////////////////////////////////
// PAPERS /////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

// load .dta
use "data/analytical/wos_2017_df_for_regressions.dta", replace

*************
* VARIABLES *
*************

// encode strings
encode subject_extended_r1, generate(nsubject_extended_r1)

// compute se_authors_total_mean
gen se_authors_total_mean = se_articles_authors_total_t/se_articles_t

// compute se_articles_cited_total_t_mean
gen se_articles_cited_total_t_mean = se_articles_cited_total_t/se_articles_t

// compute cited_total_unlinked
gen cited_total_unlinked = cited_total_wunlinked - cited_total

**********
* LABELS *
**********

// make uniform names
rename se_articles_t no_of_works
rename nsubject_extended_r1 subfield_id
rename se_articles_cited_total_t_mean no_cited_mean
rename se_authors_total_mean no_authors_mean

label variable cited_total_unlinked "Number of unlinked references"

**********
* MODELS *
**********

// controls
global field_controls no_of_works no_cited_mean no_authors_mean 
global paper_controls cited_total cited_total_unlinked

// base model
reghdfe cd_5 i.pubyear, noabsorb vce(robust)
est store pprM1
margins pubyear, nose saving("data/analytical/papers_regression_adjustments_m1", replace)
		 
// base model + subfield dummies
reghdfe cd_5 i.pubyear, absorb(subfield_id) vce(robust)
est store pprM2
margins pubyear, nose saving("data/analytical/papers_regression_adjustments_m2", replace)

// base model + subfield dummies + paper controls
reghdfe cd_5 $paper_controls i.pubyear , absorb(subfield_id) vce(robust)
est store pprM3
test $paper_controls
estadd scalar waldp=r(p): pprM3
estadd scalar waldf=r(F): pprM3
estadd scalar walddf=r(df): pprM3
margins pubyear, nose saving("data/analytical/papers_regression_adjustments_m3", replace)

// base model + subfield dummies + paper controls + field controls
reghdfe cd_5 $paper_controls $field_controls i.pubyear , absorb(subfield_id) vce(robust)
est store pprM4
test $paper_controls $field_controls
estadd scalar waldp=r(p): pprM4
estadd scalar waldf=r(F): pprM4
estadd scalar walddf=r(df): pprM4
margins pubyear, saving("data/analytical/papers_regression_adjustments_m4", replace)

// label fixed effects   
estfe pprM1 pprM2 pprM3 pprM4, labels(subfield_id "Subfield fixed effects" _cons "%")

*****************
* PRELIMINARIES *
*****************

////////////////////////////////////////////////////////////////////////////////
// PATENTS /////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// load .dta
use "data/analytical/patentsview_df_for_regressions.dta", replace

// subset years for consistency with plots
keep if grant_year <= 2010
keep if grant_year >= 1980

tab field_nber_category_id

// subset fields for consistency with plots
drop if field_nber_category_id == ""
drop if field_nber_category_id == "6"
drop if field_nber_category_id == "7"

*************
* VARIABLES *
*************

// encode strings
encode field_nber_subcategory_id, generate(nfield_nber_subcategory_id)

// compute nsc_inventors_total_mean
gen nsc_inventors_total_mean = nsc_upatents_inventors_total_t/nsc_upatents_t

// compute nsc_upatents_cited_total_t_mean
gen nsc_upatents_cited_total_t_mean = nsc_upatents_cited_total_t/nsc_upatents_t

**********
* LABELS *
**********

// make uniform names
rename nfield_nber_subcategory_id subfield_id
rename grant_year pubyear
rename nsc_upatents_t no_of_works
rename nsc_upatents_cited_total_t_mean no_cited_mean
rename nsc_inventors_total_mean no_authors_mean

label variable pubyear "Year"
label variable no_of_works "Number of new papers/patents (logged)"
label variable no_cited_mean "Mean number of papers/patents cited "
label variable no_authors_mean "Mean number of authors/inventors per paper/patent"
label variable cited_total "Number of papers/patents cited"

**********
* MODELS *
**********

// controls
global field_controls no_of_works no_cited_mean no_authors_mean 
global paper_controls cited_total

// base model
reghdfe cd_5 i.pubyear, noabsorb vce(robust)
est store patM1
margins pubyear, nose saving("data/analytical/patents_regression_adjustments_m1", replace)
		 
// base model + subfield dummies
reghdfe cd_5 i.pubyear, absorb(subfield_id) vce(robust)
est store patM2
margins pubyear, nose saving("data/analytical/patents_regression_adjustments_m2", replace)

// base model + subfield dummies + paper controls
reghdfe cd_5 $paper_controls i.pubyear , absorb(subfield_id) vce(robust)
est store patM3
test $paper_controls
estadd scalar waldp=r(p): patM3
estadd scalar waldf=r(F): patM3
estadd scalar walddf=r(df): patM3
margins pubyear, nose saving("data/analytical/patents_regression_adjustments_m3", replace)

// base model + subfield dummies + paper controls + field controls
reghdfe cd_5 $paper_controls $field_controls i.pubyear , absorb(subfield_id) vce(robust)
est store patM4
test $paper_controls $field_controls
estadd scalar waldp=r(p): patM4
estadd scalar waldf=r(F): patM4
estadd scalar walddf=r(df): patM4
margins pubyear, saving("data/analytical/patents_regression_adjustments_m4", replace)

// label fixed effects   
estfe patM1 patM2 patM3 patM4, labels(subfield_id "Subfield fixed effects" _cons "%")


// control indicators
global field_controls no_of_works no_cited_mean no_authors_mean 
global paper_controls cited_total cited_total_unlinked

// for keeping most formatting in LaTeX	
// output table
esttab pprM1 pprM2 pprM3 pprM4 patM1 patM2 patM3 patM4 using "results/raw/supplementary_table_1.tex", /*
*/ replace booktabs nolegend nonotes nobase label nogaps compress noomitted /*
*/ cells("b(star fmt(%9.2f)) se(fmt(%9.2f))") /*
*/ stats(N r2 wald_heading waldf walddf waldp, fmt(%20.0g %9.2f) labels("N" "R2" "\midrule Wald tests of controls" "F" "d.f." "p-value")) /* 
*/ varwidth(45) modelwidth(15) noabbrev /* 
*/ interaction(" $\times$ ") /*
*/ indicate(`r(indicate_fe)' "Paper/patent-level controls = $paper_controls" "Field $\times$ year-level controls = $field_controls") /*
*/ mlabels(   "\shortstack{(1)}" /* 
           */ "\shortstack{(2)}" /* 
           */ "\shortstack{(3)}" /* 
           */ "\shortstack{(4)}" /* 
           */ "\shortstack{(5)}" /* 
           */ "\shortstack{(6)}" /* 
           */ "\shortstack{(7)}" /* 
           */ "\shortstack{(8)}", span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule{@span})) /* 
*/ nonumbers /*
*/ starlevels(* 0.1 ** 0.05 *** 0.01) /*
*/ mgroups("\shortstack{Sample: Web of Science}" ///
		   "\shortstack{Sample: Patents View}", pattern(1 0 0 0 1 0 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) /*
*/ varlabels(_cons "\\Constant", elist(_cons \midrule ) ) prehead(" ") postfoot(" ")
