



/* PS4 Do file */

clear


/* This tells Stata where the excel files are located are in our computer */
cd "/Users/Salman/Box Sync/Econ300_SPRING2020/Problem Sets"


/* Let's import the excel file into STATA */
import delimited "demo.csv", encoding(ISO-8859-1) clear 



****************************** PART 1 ***************************************

/* subpart 1 */

tab gender, m /* only 4 values so cleaning is easy */

replace gender ="M" if gender=="male"
replace gender ="F" if gender=="female"

/* subpart 2 */

encode race, g(race_gp)


g ethnicity=.
replace ethnicity=1 if inlist(race_gp,2,4)
replace ethnicity=0 if inlist(race_gp,1,3,5)

label define ethn 1 "HISPANIC" 0 "NONHISPANIC"
label val ethnicity ethn

recode race_gp (2/3=2) (4/5=3) 
label define race 1 "ASIAN" 2 "BLACK" 3"WHITE"
label val race_gp race

rename (race race_gp) (race1 race)
drop race1

save temp, replace 



/* subpart 3 */

import delimited "$path/case.csv", encoding(ISO-8859-1) clear

merge m:1 person_id using temp /* merge demographics with cases */


/* part iv) creating age variable */
g arrest_yr= substr(arrest_date,1,4)
g birth_yr=substr(bdate,1,4)

destring arrest_yr, replace
destring birth_yr, replace 

g age= arrest_yr - birth_yr

label var age "Age at time of arrest"

drop arrest_yr birth_yr



/* 1)	Describe the demographic characteristics of the study population based on the data available to you. (hint: the study population has 25,000 subjects). 

2)	Are the treatment and control groups balanced (on race, gender, etc.), or are their differences in the composition of the two groups?

3)	Did participating in the program reduce the likelihood of re-arrest before disposition? Explain your answer and your methodology. 

*/


****************************** PART 2 ***************************************

/* tabs for i) part */
tab race
tab ethnicity 
kdensity age 
tab gender

encode gender, g(sex)
recode sex (1=0) (2=1)

label define gndr 0 "Female" 1 "Male"
label val sex gndr

/* for ii) part */

g black=0
replace black=1 if race==2

g white=0
replace white=1 if race==3

graph twoway (kdensity age if treat==0, ms(O)) (kdensity age if treat==1, ms(Oh)), legend(order(1 "Control Group" 2 "Treatment")) xtitle("`: var label age'")

foreach var of varlist ethnicity age sex black white prior_arrests {
disp "`var'"
ttest `var', by(treat)
}


/* for iii) part */

reg re_arrest treat, cluster(person_id)

/* running regression of re-arrest on treat variable while controlling for prior arrests */
reg re_arrest treat prior_arrests,  cluster(person_id)
sum re_arrest if treat == 0
scalar n_1 = r(mean)
eststo, addscalars(n1 n_1)  

/* running regression of re-arrest on treat variable while controlling for prior arrests and age */
reg re_arrest treat prior_arrests age,  cluster(person_id)
sum re_arrest if treat== 0
scalar n_1 = r(mean)
eststo, addscalars(n1 n_1)  

/* running regression of re-arrest on treat variable while controlling for prior arrests, age, sex and race */
reg re_arrest treat prior_arrests age i.sex i.race,  cluster(person_id)
sum re_arrest if treat == 0
scalar n_1 = r(mean)
eststo, addscalars(n1 n_1)  

esttab using "Regression_Table.csv", replace  b(%4.3f) p label star(* 0.10 ** 0.05 *** 0.01) stats(n1 N r2_a, fmt(%9.3f %9.0g %9.3f) labels ("Control Mean" "Obs" "Adjusted R-Squared")) brackets drop(_cons) scalars(n1) nogap




