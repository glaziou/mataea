*****************************************************************************
*   					Projet MATA'EA										*
* 			Cartographie de l'état de santé de la 							*
* 			population de la Polynésie française							*
*																			*
*					 	 Fichier 03 E										*
*				   		   DIABETE											*
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

***** REFORMULATION VARIABLE DIABETE EN VARIABLE BINAIRE****
gen diabete_yn = diabete
	recode diabete_yn (1=0) (2=1)
************************************************************
	
tab  age_cat diabete, chi2 row expected
	tabodds diabete_yn age_cat

tab  gender diabete, chi2 row expected
tab  gender diabete_yn, chi2 row expected

bysort age_cat : tab diabete gender, col chi2	
	
	
*Breakdown des cas de diabte
tab glycemia_measured diabete_yn, row
tab diabete_measured diabete_yn
tab diabete_measured_last_year diabete_yn
tab diabete_medic_last_2weeks diabete_yn
tab diabete_insulin diabete_yn

tab diabete_medic_last_2weeks res_hba1g_cat
tab diabete_insulin res_hba1g_cat



************************************************************************
* Diabete ET GENRE
tab gender diabete_yn, row chi2 
ttest diabete_yn, by(gender)

logistic diabete_yn ib2.gender 

	
************************************************************************
* Diabete ET AGE
tab age_cat diabete_yn, row chi2 
xi: logistic diabete_yn i.age_cat
tabodds diabete_yn age_cat

bysort gender : tab  age_cat diabete, chi2 row expected
	tabodds diabete_yn age_cat if gender==1
	tabodds diabete_yn age_cat if gender==2

************************************************************************
* DIABETE ET ARCHIPEL / STRATE GEOGRAPHIQUE
tab archipelago diabete_yn, row chi2 

	char archipelago[omit] "Société (Îles-du-vent)"
xi: logistic diabete_yn i.archipelago 

tab geo_strate diabete_yn, row chi2 

	
************************************************************************
* DIABETE ET OBESITE
tab obesity_classif_who diabete_yn, row chi2  expected
*Un expected à 1.5 : regroupement de Underweight et Normal
gen obesity_classif_who_temp=obesity_classif_who
	recode obesity_classif_who_temp (1=2)
	label define lbobesityclassifwhotemp 2 "Normal & Underweight" 3 Overweight 4 "Obesity Class I" 5 "Obesity Class II" 6 "Obesity Class III"
	label values obesity_classif_who_temp lbobesityclassifwhotemp

tab obesity_classif_who_temp diabete_yn, row chi2  expected
	
	char obesity_classif_who_temp[omit] "2"
xi: logistic diabete_yn i.obesity_classif_who_temp if obesity_classif_who!=.

tabodds diabete_yn obesity_classif_who_temp

	
************************************************************************
* DIABETE ET NIVEAU D'ETUDE
tab max_school2 diabete_yn, row chi2 

	char max_school2[omit] "End of lycee or equivalent"
xi: logistic diabete_yn i.max_school2 

* codage variable max_school2 en numerique pour test de tendance
replace max_school2="1" if max_school2=="End of primary or before"
replace max_school2="2" if max_school2=="End of secundary school"
replace max_school2="3" if max_school2=="End of lycee or equivalent"
replace max_school2="4" if max_school2=="University or after"
	destring max_school2, replace

tabodds diabete_yn max_school2


************************************************************************
* DIABETE ET ETAT CIVIL
tab civil_state3 diabete_yn, row chi2 

	char civil_state3[omit] "Married"
xi: logistic diabete_yn i.civil_state3 


************************************************************************
* DIABETE ET CATEGORIE PROFESSIONNELLE
tab pro_act_last_year2 diabete_yn, row chi2

	char pro_act_last_year2[omit] "Private employee"
xi: logistic diabete_yn i.pro_act_last_year2


************************************************************************
* DIABETE  ET TABAC
tab smoking_prst diabete_yn, row chi2 
logistic diabete_yn ib2.smoking_prst

tab smoking_classif diabete_yn,expected row chi2 exact
logistic diabete_yn ib0.smoking_classif
tabodds diabete_yn smoking_classif

tab ntabaco_per_day_equ_class diabete_yn,expected row chi2 exact
logistic diabete_yn ib0.ntabaco_per_day_equ_class
tabodds diabete_yn ntabaco_per_day_equ_class


************************************************************************
* DIABETE ET PAKA
tab paka diabete_yn if paka !=88, row chi2 
	logistic diabete_yn ib2.paka if paka !=88

************************************************************************

