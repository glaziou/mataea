*****************************************************************************
*   					Projet MATA'EA										*
* 			Cartographie de l'état de santé de la 							*
* 			population de la Polynésie française							*
*																			*
*					 	 Fichier 03 D										*
*				   		   OBESITE											*
*																			*
*																			*
*																			*
* 	auteur : Vincent Mendiboure												*
* 	dernier update : 08 Juillet 2022										*
*																			*
*****************************************************************************

*cd "Z:\donnees\Stata"
cd "C:\Users\Mendiboure\Documents\Master PH\Stage Pasteur\image\donnees\Stata"

use "02_MATAEA_final.dta", clear


tab  age_cat obesity_classif_who, chi2 row expected
tab  age_cat obesity_classif_who2, chi2 row expected 


***** REFORMULATION VARIABLE OBESITE EN VARIABLE BINAIRE****
gen obesity_yn = obesity_classif_who2
	recode obesity_yn (1=0) (2=0) (3=0) (4=1)
************************************************************
	
tab  age_cat obesity_classif_who2, chi2 row expected
	tabodds obesity_yn age_cat

tab  gender obesity_classif_who2, chi2 row expected
tab  gender obesity_yn, chi2 row expected

bysort gender : tab  age_cat obesity_classif_who2, row chi2	expected
* expected inférieur à 5 : regroupement de Underweight et Normal
gen obesity_classif_who_temp=obesity_classif_who2
	recode obesity_classif_who_temp (1=2)
	label define lbobesityclassifwhotemp 2 "Normal & Underweight" 3 Overweight 4 "Obesity Class I" 5 "Obesity Class II" 6 "Obesity Class III"
	label values obesity_classif_who_temp lbobesityclassifwhotemp
	bysort gender : tab  age_cat obesity_classif_who_temp, col chi2	expected



************************************************************************
* OBESITE ET GENRE
tab gender obesity_yn, row chi2 
ttest obesity_yn, by(gender)

logistic obesity_yn ib2.gender 

	
************************************************************************
* OBESITE ET AGE
tab age_cat obesity_yn, row chi2 
xi: logistic obesity_yn i.age_cat
tabodds obesity_yn age_cat

bysort gender : tab  age_cat obesity_classif_who, chi2 row expected
	tabodds obesity_yn age_cat if gender==1
	tabodds obesity_yn age_cat if gender==2

************************************************************************
* OBESITE ET ARCHIPEL / STRATE GEOGRAPHIQUE
tab archipelago obesity_yn, row chi2 

	char archipelago[omit] "Société (Îles-du-vent)"
xi: logistic obesity_yn i.archipelago 

tab geo_strate obesity_yn, row chi2 
	
************************************************************************
* OBESITE ET NIVEAU D'ETUDE
tab max_school2 obesity_yn, row chi2 

	char max_school2[omit] "End of lycee or equivalent"
xi: logistic obesity_yn i.max_school2 

* codage variable max_school2 en numerique pour test de tendance
replace max_school2="1" if max_school2=="End of primary or before"
replace max_school2="2" if max_school2=="End of secundary school"
replace max_school2="3" if max_school2=="End of lycee or equivalent"
replace max_school2="4" if max_school2=="University or after"
	destring max_school2, replace

tabodds obesity_yn max_school2


************************************************************************
* OBESITE ET ETAT CIVIL
tab civil_state3 obesity_yn, row chi2 

	char civil_state3[omit] "Married"
xi: logistic obesity_yn i.civil_state3 


************************************************************************
* OBESITE ET CATEGORIE PROFESSIONNELLE
tab pro_act_last_year2 obesity_yn, row chi2

	char pro_act_last_year2[omit] "Private employee"
xi: logistic obesity_yn i.pro_act_last_year2


************************************************************************
* OBESITE  ET TABAC
tab smoking_prst obesity_yn, row chi2 
logistic obesity_yn ib2.smoking_prst
xi: logistic obesity_yn ib2.smoking_prst i.age_cat

tab smoking_classif obesity_yn, row chi2
logistic obesity_yn ib0.smoking_classif
tabodds obesity_yn smoking_classif

tab ntabaco_per_day_equ_class obesity_yn,expected row chi2 exact
logistic obesity_yn ib0.ntabaco_per_day_equ_class
tabodds obesity_yn ntabaco_per_day_equ_class


************************************************************************
* OBESITE ET PAKA
tab paka obesity_yn if paka !=88, row chi2 
	logistic obesity_yn ib2.paka if paka !=88

************************************************************************
* OBESITE ET DIABETE
tab diabete obesity_yn, row chi2 

xi: logistic obesity_yn i.diabete if diabete!=.

tabodds obesity_yn diabete

************************************************************************

