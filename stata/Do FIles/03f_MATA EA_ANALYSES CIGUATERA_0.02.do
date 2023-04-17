*****************************************************************************
*   					Projet MATA'EA										*
* 			Cartographie de l'état de santé de la 							*
* 			population de la Polynésie française							*
*																			*
*					 		Fichier 03 B									*
*						 ANALYSES CIGUATERA 								*
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


************************************************************************
* CIGUATERA ET GENRE
tab gender ciguatera_freq ,expected row chi2 

logistic ciguatera_freq ib2.gender 

	
************************************************************************
* CIGUATERA ET AGE
tab age_cat ciguatera_freq2,expected row chi2 
bysort gender: tab age_cat ciguatera_freq2,expected row chi2 



xi: logistic ciguatera_freq2 i.age_cat
ERROR
* continuer à partir d'ici
* defnir variabel binaire ciguatera
	
************************************************************************
* COVID ET ARCHIPEL
tab archipelago covid_test_positif,expected row chi2 exact

	char archipelago[omit] "Société (Îles-du-vent)"
xi: logistic covid_test_positif i.archipelago 

	
************************************************************************
* COVID ET OBESITE
tab obesity_classif_who covid_test_positif,expected row chi2 exact 

	char obesity_classif_who[omit] "2"
xi: logistic covid_test_positif i.obesity_classif_who if obesity_classif_who!=.


************************************************************************
*COVID ET CANCER
tab cancer_or_malignant_tumor_medica covid_test_positif if cancer_or_malignant_tumor_medica !="Dont know",expected row chi2 exact

	char cancer_or_malignant_tumor_medica[omit] "No"
xi: logistic covid_test_positif i.cancer_or_malignant_tumor_medica if cancer_or_malignant_tumor_medica !="Dont know"
	
	
************************************************************************
* COVID ET NIVEAU D'ETUDE
tab max_school2 covid_test_positif,expected row chi2 exact

	char max_school2[omit] "End of lycee or equivalent"
xi: logistic covid_test_positif i.max_school2 


************************************************************************
* COVID ET ETAT CIVIL
tab civil_state2 covid_test_positif,expected row chi2 exact

	char civil_state2[omit] "Never married, separated, divorced or widower"
xi: logistic covid_test_positif i.civil_state2


************************************************************************
* COVID ET CATEGORIE PROFESSIONNELLE
tab pro_act_last_year covid_test_positif,expected row chi2

	char pro_act_last_year[omit] "Private employee"
xi: logistic covid_test_positif i.pro_act_last_year

  ** découpage en 4 classes**
tab pro_act_last_year2 covid_test_positif, row chi2

	char pro_act_last_year2[omit] "Private employee"
xi: logistic covid_test_positif i.pro_act_last_year2

************************************************************************
* COVID ET NOMBRE DE INDIVIDUS DANS LA MAISON
* création préliminaire de classes
gen nhouse_classif = recode(nhouse_people,1,2) 
	order nhouse_classif, after(nhouse_people)
	label define lbnhouseclassif 1 "vit seul" 2 "vit avec 1 personne ou plus"
	label values nhouse_classif lbnhouseclassif

tab nhouse_classif covid_test_positif,expected row chi2 exact
logistic covid_test_positif nhouse_classif


************************************************************************
* COVID ET TABAC
tab smoking_prst covid_test_positif,expected row chi2 exact
logistic covid_test_positif ib2.smoking_prst

tab smoking_classif covid_test_positif,expected row chi2 exact
logistic covid_test_positif ib0.smoking_classif
tabodds covid_test_positif smoking_classif

tab ntabaco_per_day_equ_class covid_test_positif,expected row chi2 exact
logistic covid_test_positif ib0.ntabaco_per_day_equ_class
tabodds covid_test_positif ntabaco_per_day_equ_class


************************************************************************
* COVID ET PAKA
tab paka covid_test_positif, row chi2
	logistic covid_test_positif ib2.paka


**********************************************************************
* COVID ET TYPES DE MAISONS
tab house_type covid_test_positif,expected row chi2 exact
	char house_type[omit] "House with a garden"
	xi: logistic covid_test_positif i.house_type
tab house_clim covid_test_positif,expected row chi2 exact
	xi: logistic covid_test_positif i.house_clim
tab house_clean_water covid_test_positif,expected row chi2 exact
tab mosquito_bites covid_test_positif,expected row chi2 exact
	char mosquito_bites[omit] "Rarely"
	xi: logistic covid_test_positif i.mosquito_bites

**********************************************************************
* COVID ET LANGUE MATERNELLE
replace native_language=5 if native_language==4
tab native_language covid_test_positif, row chi2
	logistic covid_test_positif ib2.native_language



