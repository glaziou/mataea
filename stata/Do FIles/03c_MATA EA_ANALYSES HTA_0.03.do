*****************************************************************************
*   					Projet MATA'EA										*
* 			Cartographie de l'état de santé de la 							*
* 			population de la Polynésie française							*
*																			*
*					 		Fichier 03 C									*
*				   ANALYSES HYPERTENSION ARTERIELLE							*
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



tab  age_cat art_tension_measured, chi2 row m

tab  age_cat hypertension_measured, chi2 row m

tab  age_cat hypertension_measured_last_year, chi2 row m


bysort gender : tab age_cat hypertension, row 
	tab age_cat hypertension, row 
	
tab hypertension gender, col chi2 
bysort age_cat : tab hypertension gender, col chi2	
	
bysort gender : tab age_cat art_tension_medic_last_2weeks

bysort gender : tab age_cat art_tension_medic_last_2weeks if hypertension_clin==1

**Breakdown des cas de HTA 
tab art_tension_measured hypertension, row
tab hypertension_measured hypertension
tab hypertension_measured_last_year hypertension

tab art_tension_medic_last_2weeks hypertension
gen art_tension_medic_last_2weeks2 = art_tension_medic_last_2weeks
	replace art_tension_medic_last_2weeks2 =2 if drug_for_hypertension==2
	replace art_tension_medic_last_2weeks2 =1 if drug_for_hypertension==1 | art_tension_medic_last_2weeks==1
	label values art_tension_medic_last_2weeks2  lbyesno

tab art_tension_medic_last_2weeks2 hypertension

tab art_tension_medic_last_2weeks2 hypertension_clin


* Mofification de la variable expliquée pour reg logistic
replace hypertension=0 if hypertension==2

************************************************************************
* HTA ET GENRE
tab gender hypertension, row chi2 
ttest hypertension, by(gender)

logistic hypertension ib2.gender 

	
************************************************************************
* HTA ET AGE
tab age_cat hypertension, row chi2 

xi: logistic hypertension i.age_cat

tabodds hypertension age_cat

************************************************************************
* HTA ET ARCHIPEL
tab archipelago hypertension, row chi2 

	char archipelago[omit] "Société (Îles-du-vent)"
xi: logistic hypertension i.archipelago 

	
************************************************************************
* HTA ET OBESITE
tab obesity_classif_who hypertension, row chi2  expected

	char obesity_classif_who[omit] "2"
xi: logistic hypertension i.obesity_classif_who if obesity_classif_who!=.

tabodds hypertension obesity_classif_who

	
************************************************************************
* HTA ET NIVEAU D'ETUDE
tab max_school2 hypertension, row chi2 

	char max_school2[omit] "End of lycee or equivalent"
xi: logistic hypertension i.max_school2 

* codage variable max_school2 en numerique pour test de tendance
replace max_school2="1" if max_school2=="End of primary or before"
replace max_school2="2" if max_school2=="End of secundary school"
replace max_school2="3" if max_school2=="End of lycee or equivalent"
replace max_school2="4" if max_school2=="University or after"
	destring max_school2, replace

tabodds hypertension max_school2


************************************************************************
* HTA ET ETAT CIVIL
tab civil_state3 hypertension, row chi2 

	char civil_state3[omit] "Married"
xi: logistic hypertension i.civil_state3


************************************************************************
* HTA ET CATEGORIE PROFESSIONNELLE
tab pro_act_last_year hypertension, row chi2 

	char pro_act_last_year[omit] "Private employee"
xi: logistic hypertension i.pro_act_last_year

  ** découpage en 4 classes**
tab pro_act_last_year2 hypertension, row chi2

	char pro_act_last_year2[omit] "Private employee"
xi: logistic hypertension i.pro_act_last_year2


************************************************************************
* HTA ET TABAC
tab smoking_prst hypertension, row chi2 
logistic hypertension ib2.smoking_prst
*xi: logistic hypertension ib2.smoking_prst i.age_cat i.geo_strate

bysort age_cat: tab smoking_prst hypertension, row chi2 

tab smoking_classif hypertension,expected row chi2 exact
logistic hypertension ib0.smoking_classif
tabodds hypertension smoking_classif

tab ntabaco_per_day_equ_class hypertension,expected row chi2 exact
logistic hypertension ib0.ntabaco_per_day_equ_class
tabodds hypertension ntabaco_per_day_equ_class








************************************************************************
* HTA ET PAKA
tab paka hypertension if paka !=88, row chi2 
	logistic hypertension ib2.paka if paka !=88

************************************************************************

