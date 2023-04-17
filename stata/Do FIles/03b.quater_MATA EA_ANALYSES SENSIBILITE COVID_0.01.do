*****************************************************************************
*   					Projet MATA'EA										*
* 			Cartographie de l'état de santé de la 							*
* 			population de la Polynésie française							*
*																			*
*					 		Fichier 03 B - quater							*
*					ANALYSES SENSIBILITE COVID-19							*
*																			*
*		outcome infection covid-19 basé sur le déclaratif uniquement		*
*																			*
* 	auteur : Vincent Mendiboure												*
* 	dernier update : 31 aout 2022											*
*																			*
*****************************************************************************

*cd "Z:\donnees\Stata"
cd "C:\Users\Mendiboure\Documents\Master PH\Stage Pasteur\image\donnees\Stata"

use "03b_MATA EA_ANALYSES COVID.dta", clear



**********************************************************************
**# 		I. INTRODUCTION - PREPARATIONS SPECIFIQUES 				**
**********************************************************************
* MODIFICATION OUTCOME COVID-19
replace covid_bool = covid_test_positif 
	recode covid_bool (2=0)


**********************************************************************
**# 			II. ANALYSE UNIVARIEE OUTCOME COVID 				**
**********************************************************************	
	
*hist mois_interview_step1 if covid_bool==1, width(1) xtitle("mois d'interview") xmtick(#1) xlabel(,labsize(small)) freq title("{bf:Nombre de cas de COVID-19 par mois d'interview}",size(medium) ) 

* COVID ET MOIS DE L'ITW
*tab mois_interview_step1 covid_bool,expected row chi2 exact
bysort group_date_itw1 : tab mois_interview_step1 covid_bool,expected row chi2 exact
		char mois_interview_step1[omit] "4"
xi: logistic covid_bool i.mois_interview_step1 if group_date_itw1==1
		char mois_interview_step1[omit] "7"
xi: logistic covid_bool i.mois_interview_step1 if group_date_itw1==2
	
* COVID ET GENRE
bysort group_date_itw1 : tab gender covid_bool,expected row chi2
bysort group_date_itw1 : logistic covid_bool ib2.gender 

* COVID ET AGE
bysort group_date_itw1 : tab age_cat covid_bool,expected row chi2
xi: logistic covid_bool i.age_cat if group_date_itw1==1
xi: logistic covid_bool i.age_cat if group_date_itw1==2

* COVID ET LANGUE MATERNELLE
bysort group_date_itw1 : tab native_language2 covid_bool, row chi2
	char native_language2[omit] "2"
xi: logistic covid_bool i.native_language2 if group_date_itw1==1
xi: logistic covid_bool i.native_language2 if group_date_itw1==2
testparm _Inative_la_1 _Inative_la_5	// p=0.51

* COVID ET ARCHIPEL
bysort group_date_itw1 : tab archipelago covid_bool,expected row chi2 exact
	*char archipelago[omit] "Société (Îles-du-vent)"
	char archipelago[omit] "Société (Îles-sous-le-vent)"
xi: logistic covid_bool i.archipelago if group_date_itw1==1

* ILE DE RESIDENCE
bysort group_date_itw1 : tab island  covid_bool, row chi2 
	char island[omit] "Bora-Bora"
xi : firthlogit covid_bool i.island if group_date_itw1==1, or
	char island[omit] "Tahiti"
xi : logistic covid_bool i.island if group_date_itw1==2

* VILLAGE DE RESIDENCE
tab town_name covid_bool if group_date_itw1==2, row expected chi2 
	char town_name[omit] "PAPEETE"
xi : logistic covid_bool i.town_name if group_date_itw1==2

tab town_classif_1 covid_bool if group_date_itw1==2, row expected chi2 
	char town_classif_1[omit] "zone urbaine"
xi : logistic covid_bool i.town_classif_1 if group_date_itw1==2

tab town_classif_2 covid_bool if group_date_itw1==2, row expected chi2 
	char town_classif_2[omit] "Eau potable sur tout le territoire"
xi : logistic covid_bool i.town_classif_2 if group_date_itw1==2

tab town_classif_3 covid_bool if group_date_itw1==2, row expected chi2 
	char town_classif_3[omit] "Classes 2 et 3"
xi : logistic covid_bool i.town_classif_3 if group_date_itw1==2

* COVID ET NIVEAU D'ETUDE
bysort group_date_itw1 : tab max_school2 covid_bool,expected row chi2
	char max_school2[omit] "End of lycee or equivalent"
xi: firthlogit covid_bool i.max_school2  if group_date_itw1==1,or
xi: logistic covid_bool i.max_school2  if group_date_itw1==2

* COVID ET ETAT CIVIL
bysort group_date_itw1 : tab civil_state3 covid_bool,expected row chi2 exact
	char civil_state3[omit] "Married"
xi: firthlogit covid_bool i.civil_state3 if group_date_itw1==1, or
xi: firthlogit covid_bool i.civil_state3 if group_date_itw1==2, or

* COVID ET CATEGORIE PROFESSIONNELLE
  ** avec variable découpée en en 4 classes
bysort group_date_itw1 :tab pro_act_last_year2 covid_bool,expected row chi2 
	char pro_act_last_year2[omit] "Private employee"	
xi: logistic covid_bool i.pro_act_last_year2 if group_date_itw1==1
xi: logistic covid_bool i.pro_act_last_year2 if group_date_itw1==2

* COVID ET NOMBRE DE INDIVIDUS MAJEURS DANS LA MAISON
bysort group_date_itw1 : tab nhouse_classif covid_bool,expected row chi2 exact
		char nhouse_classif[omit] "2"
xi : logistic covid_bool i.nhouse_classif if group_date_itw1==1
xi : logistic covid_bool i.nhouse_classif if group_date_itw1==2

* COVID ET NOMBRE TOTAL DE PERSONNES DANS LE FOYER
bysort group_date_itw1 : tab nhouse_tot_classif covid_bool,expected row chi2 exact
			char nhouse_tot_classif[omit] "4"
xi : logistic covid_bool i.nhouse_tot_classif if group_date_itw1==1
xi : logistic covid_bool i.nhouse_tot_classif if group_date_itw1==2

	*avec 3 classes
	bysort group_date_itw1 : tab nhouse_tot_classif2 covid_bool,expected row chi2 exact
				char nhouse_tot_classif2[omit] "2"
	xi : logistic covid_bool i.nhouse_tot_classif2 if group_date_itw1==1
	xi : logistic covid_bool i.nhouse_tot_classif2 if group_date_itw1==2
	
	*avec 4 classes
	bysort group_date_itw1 : tab nhouse_tot_classif3 covid_bool,expected row chi2 exact
				char nhouse_tot_classif3[omit] "2"
	xi : logistic covid_bool i.nhouse_tot_classif3 if group_date_itw1==1
	xi : logistic covid_bool i.nhouse_tot_classif3 if group_date_itw1==2
	
	
* COVID ET TYPES DE MAISONS
bysort group_date_itw1 : tab house_type covid_bool,expected row chi2 exact
	char house_type[omit] "House with a garden"
	xi: logistic covid_bool i.house_type

bysort group_date_itw1 : tab house_clim covid_bool,expected row chi2 exact
	xi: logistic covid_bool i.house_clim  if group_date_itw1==1
	xi: logistic covid_bool i.house_clim  if group_date_itw1==2

bysort group_date_itw1 : tab house_clean_water covid_bool,expected row chi2 exact
		char house_clean_water[omit] "Yes"
	xi: logistic covid_bool i.house_clean_water  if group_date_itw1==1
	xi: logistic covid_bool i.house_clean_water  if group_date_itw1==2

bysort group_date_itw1 : tab mosquito_bites covid_bool,expected row chi2 exact
	char mosquito_bites[omit] "Everyday"
	xi: firthlogit covid_bool i.mosquito_bites if group_date_itw1==1, or
	xi: logistic covid_bool i.mosquito_bites if group_date_itw1==2

* COVID ET OBESITE
* IMC / OBESITE - 6 CLASSES
bysort group_date_itw1 : tab obesity_classif_who covid_bool,expected row chi2 exact
	char obesity_classif_who[omit] "2"
xi: firthlogit covid_bool i.obesity_classif_who if group_date_itw1==1,or
xi: logistic covid_bool i.obesity_classif_who if group_date_itw1==2

* IMC / OBESITE - 3 CLASSES
bysort group_date_itw1 : tab obesity_classif_who3 covid_bool,expected row chi2
xi: firthlogit covid_bool i.obesity_classif_who3 if group_date_itw1==1, or
xi: logistic covid_bool i.obesity_classif_who3 if group_date_itw1==2

* IMC / OBESITE - 2 CLASSES
bysort group_date_itw1 : tab obesity_who_bool covid_bool,expected row chi2
xi: firthlogit covid_bool i.obesity_who_bool if group_date_itw1==1, or
xi: logistic covid_bool i.obesity_who_bool if group_date_itw1==2

* HTA
bysort group_date_itw1 : tab hypertension_bool covid_bool,expected row chi2 
	xi: logistic covid_bool i.hypertension_bool if group_date_itw1==1
	xi: firthlogit covid_bool i.hypertension_bool if group_date_itw1==2, or
	
* DIABETE
bysort group_date_itw1 : tab diabete_bool covid_bool,expected row chi2 exact
	xi: firthlogit covid_bool i.diabete_bool if group_date_itw1==1, or
	xi: logistic covid_bool i.diabete_bool if group_date_itw1==2

* ALLERGIES RESPIRATOIRES
bysort group_date_itw1 : tab respi_allergy_medical covid_bool,expected row chi2 exact
	char respi_allergy_medical[omit] "No"
xi: firthlogit covid_bool i.respi_allergy_medical if group_date_itw1==1, or
xi: logistic covid_bool i.respi_allergy_medical if group_date_itw1==2

* ALLERGIES ALIMENTAIRE
bysort group_date_itw1 : tab alim_allergy_medical covid_bool if alim_allergy_medical !="Dont know",expected row chi2 exact
	char alim_allergy_medical[omit] "No"
xi: logistic covid_bool i.alim_allergy_medical if group_date_itw1==1
xi: logistic covid_bool i.alim_allergy_medical if group_date_itw1==2

* ALLERGIES CUTANEES
bysort group_date_itw1 : tab skin_allergy_medical covid_bool if skin_allergy_medical !="Dont know",expected row chi2 exact
	char skin_allergy_medical[omit] "No"
xi: logistic covid_bool i.skin_allergy_medical if group_date_itw1==1
xi: logistic covid_bool i.skin_allergy_medical if group_date_itw1==2

* ASTHME
bysort group_date_itw1 : tab asthma_medical covid_bool,expected row chi2 
	char asthma_medical[omit] "No"
xi: firthlogit covid_bool i.asthma_medical if group_date_itw1==1, or
xi: firthlogit covid_bool i.asthma_medical if group_date_itw1==2, or

* RESPIRATION SIFFLANTE
bysort group_date_itw1 : tab  hissing_respi_last_year covid_bool if hissing_respi_last_year !="Dont know",expected row chi2 
	char hissing_respi_last_year[omit] "No"
xi: logistic covid_bool i.hissing_respi_last_year if group_date_itw1==1
xi: logistic covid_bool i.hissing_respi_last_year if group_date_itw1==2
* p= 0.50 / 0.55

* ALD
bysort group_date_itw1 : tab chronic_ald covid_bool,expected row chi2
xi: logistic covid_bool i.chronic_ald if group_date_itw1==1
xi: logistic covid_bool i.chronic_ald if group_date_itw1==2
*p= 0.75 / 0.55
	
* CANCER
bysort group_date_itw1 : tab cancer_or_malignant_tumor_medica covid_bool,expected row chi2 exact
	
	char cancer_or_malignant_tumor_medica[omit] 2
xi : firthlogit covid_bool i.cancer_or_malignant_tumor_medica if group_date_itw1==1, or
xi: logistic covid_bool i.cancer_or_malignant_tumor_medica if group_date_itw1==2
/*
* ACTIVITE PHYSIQUE
bysort group_date_itw1 : tab phys_act_level covid_bool,expected row chi2 exact
xi: logistic covid_bool i.phys_act_level if group_date_itw1==1
xi: logistic covid_bool i.phys_act_level if group_date_itw1==2

* ALCOOL
bysort group_date_itw1 : tab alcool_30d_bool covid_bool,expected row chi2 
	xi: logistic covid_bool i.alcool_30d_bool if group_date_itw1==1
	xi: logistic covid_bool i.alcool_30d_bool if group_date_itw1==2

* TABAC
bysort group_date_itw1 : tab smoking_prst covid_bool,expected row chi2 exact
	*xi : logistic covid_bool ib2.smoking_prst i.age_cat
	bysort group_date_itw1 : logistic covid_bool ib2.smoking_prst

bysort group_date_itw1 : tab smoking_classif covid_bool,expected row chi2 exact
bysort group_date_itw1 : logistic covid_bool ib0.smoking_classif

bysort group_date_itw1 : tab smoking_everyday_bool covid_bool,expected row chi2 
bysort group_date_itw1 : logistic covid_bool ib0.smoking_everyday_bool

bysort group_date_itw1 : tab ntabaco_per_day_equ_class covid_bool,expected row chi2 exact
bysort group_date_itw1 : logistic covid_bool ib0.ntabaco_per_day_equ_class

* PAKA
bysort group_date_itw1 : tab paka_weekly_bool  covid_bool, row chi2
	*p=0.31 & 0.54
bysort group_date_itw1 : logistic covid_bool ib2.paka_weekly_bool 

* COVID & HYGIENE ALIMENTAIRE
bysort group_date_itw1 : tab reco_fruit_vege covid_bool,expected row chi2 exact
bysort group_date_itw1 : logistic covid_bool ib0.reco_fruit_vege
	*p=0.56 & 0.98

* GESTES BARRIERES
bysort group_date_itw1 : tab covid_behavior_hand_washing 	covid_bool,expected row chi2 exact
bysort group_date_itw1 : tab covid_behavior_hand_shaking 	covid_bool,expected row chi2 exact
bysort group_date_itw1 : tab covid_behavior_cough_elbow 	covid_bool,expected row chi2 exact
bysort group_date_itw1 : tab covid_behavior_safety_distance covid_bool,expected row chi2 exact
bysort group_date_itw1 : tab covid_behavior_mask 			covid_bool,expected row chi2 exact

logistic covid_bool covid_behavior_hand_washing 	if group_date_itw1==1
logistic covid_bool covid_behavior_hand_shaking 	if group_date_itw1==1
logistic covid_bool covid_behavior_cough_elbow 		if group_date_itw1==1
logistic covid_bool covid_behavior_safety_distance  if group_date_itw1==1
logistic covid_bool covid_behavior_mask 			if group_date_itw1==1
	
xi: firthlogit covid_bool i.covid_behavior_hand_washing 	if group_date_itw1==2, or
xi: firthlogit covid_bool i.covid_behavior_hand_shaking 	if group_date_itw1==2, or
xi: firthlogit covid_bool i.covid_behavior_cough_elbow 		if group_date_itw1==2, or
xi: firthlogit covid_bool i.covid_behavior_safety_distance  if group_date_itw1==2, or
xi: firthlogit covid_bool i.covid_behavior_mask 			if group_date_itw1==2, or

	
* VACCINATION - 3 CLASSES (VACCINE / NON VACCINE / manqants)
bysort group_date_itw1 : tab covid_vaccination_explicative covid_bool,expected row chi2 exact
xi : firthlogit covid_bool i.covid_vaccination_explicative  if group_date_itw1==1 ,or
xi : logistic   covid_bool i.covid_vaccination_explicative  if group_date_itw1==2

* VACCINATION - 2 CLASSES (VACCINE / NON VACCINE)
bysort group_date_itw1 : tab covid_vaccination_explicativebis covid_bool,expected row chi2 exact
xi : firthlogit covid_bool i.covid_vaccination_explicativebis  if group_date_itw1==1 ,or
xi : logistic   covid_bool i.covid_vaccination_explicativebis  if group_date_itw1==2

	
**********************************************************************
**# 		III. ANALYSE MULTIVARIEE OUTCOME COVID 					**
**********************************************************************	

*---------------------------------------------------------------------
**# 3.1. Analyse Multivariée sur la 1ère période : Avril à Juin 2021 |
*---------------------------------------------------------------------
// 3.1.1 Stratégie sélection descendante (backward selection) - Periode 1
		char mois_interview_step1[omit] "4"
		char gender[omit] "2"
		char archipelago[omit] "Société (Îles-sous-le-vent)"

xi: firthlogit covid_bool i.mois_interview_step1 i.gender i.native_language2 i.archipelago i.house_clim alcool_30d_bool smoking_everyday_bool i.covid_vaccination_explicative if group_date_itw1==1, or
	testparm _Imois*						/* p=0.33		*/
	testparm _Igender*						/* p=0.15 		*/
	testparm _Inative*						/* p=0.77		*/	
	testparm _Iarchip*						/* p=0.56		*/
	testparm _Ihouse_cli*					/* p=0.037		*/
	testparm alcool_30d_bool				/* p=0.35		*/
	testparm smoking_everyday_bool			/* p=0.43		*/
	testparm _Icovid_vac*					/* p=0.036		*/
/* Native language (native_language2) variable moins significative (p=0.77)	*/

xi: firthlogit covid_bool i.mois_interview_step1 i.gender i.archipelago i.house_clim alcool_30d_bool smoking_everyday_bool i.covid_vaccination_explicative if group_date_itw1==1, or
	testparm _Imois*						/* p=0.36		*/
	testparm _Igender*						/* p=0.14 		*/
	testparm _Iarchip*						/* p=0.31		*/
	testparm _Ihouse_cli*					/* p=0.027		*/
	testparm alcool_30d_bool				/* p=0.40		*/
	testparm smoking_everyday_bool			/* p=0.46		*/
	testparm _Icovid_vac*					/* p=0.036		*/
/* Fumeur quotidien (smoking_everyday_bool) variable moins significative (p=0.46)	*/
	
xi: firthlogit covid_bool i.mois_interview_step1 i.gender i.archipelago i.house_clim alcool_30d_bool i.covid_vaccination_explicative if group_date_itw1==1, or
	testparm _Imois*						/* p=0.37		*/
	testparm _Igender*						/* p=0.13 		*/
	testparm _Iarchip*						/* p=0.25		*/
	testparm _Ihouse_cli*					/* p=0.017		*/
	testparm alcool_30d_bool				/* p=0.34		*/
	testparm _Icovid_vac*					/* p=0.037		*/
/* Mois d'interview (mois_interview_step1) variable moins significative (p=0.37)	*/
	
xi: firthlogit covid_bool i.gender i.archipelago i.house_clim alcool_30d_bool i.covid_vaccination_explicative if group_date_itw1==1, or
	testparm _Igender*						/* p=0.086 		*/
	testparm _Iarchip*						/* p=0.13		*/
	testparm _Ihouse_cli*					/* p=0.005		*/
	testparm alcool_30d_bool				/* p=0.32		*/
	testparm _Icovid_vac*					/* p=0.034		*/
/* Consommation d'alcool dans les 30 derniers jours (alcool_30d_bool) variable moins significative (p=0.32)	*/
	
xi: firthlogit covid_bool i.gender i.archipelago i.house_clim i.covid_vaccination_explicative if group_date_itw1==1, or
	testparm _Igender*						/* p=0.051 		*/
	testparm _Iarchip*						/* p=0.092		*/
	testparm _Ihouse_cli*					/* p=0.006		*/
	testparm _Icovid_vac*					/* p=0.037		*/
/* Archipel de résidence (archipelago) variable moins significative (p=0.092)	*/	
	
xi: firthlogit covid_bool i.gender i.house_clim i.covid_vaccination_explicative if group_date_itw1==1, or
	testparm _Igender*						/* p=0.047 		*/
	testparm _Ihouse_cli*					/* p=0.010		*/
	testparm _Icovid_vac*					/* p=0.024		*/
/* Toutes les variables significatives 
--------------------------------------------------------------------------------
    covid_bool | Odds ratio   Std. err.      z    P>|z|     [95% conf. interval]
---------------+----------------------------------------------------------------
    _Igender_1 |    .456139   .1798219    -1.99   0.046     .2106353    .9877865
 _Ihouse_cli_2 |   4.886102   3.007595     2.58   0.010     1.462222     16.3272
 _Icovid_vac_1 |   .0203042   .0291403    -2.72   0.007     .0012189     .338236
_Icovid_vac_99 |     .78474   .4674341    -0.41   0.684     .2441764    2.522017
         _cons |   .1500406   .0351735    -8.09   0.000     .0947686    .2375489
--------------------------------------------------------------------------------*/	


// 4.1.2. Stratégie sélection ascendante (forward selection) - Periode 1
//----------------------------------------------------------
xi: firthlogit covid_bool i.covid_vaccination_explicative if group_date_itw1==1, or
	testparm _Icovid_vac*					/* p=0.049		*/

xi: firthlogit covid_bool i.covid_vaccination_explicative i.archipelago if group_date_itw1==1, or
	testparm _Icovid_vac*					/* p=0.045		*/
	testparm _Iarchi*						/* p=0.11		*/

*	test avec "distance de sécurité"
xi: firthlogit covid_bool i.covid_vaccination_explicative i.archipelago covid_behavior_safety_distance if group_date_itw1==1, or
	testparm _Icovid_vac*					/* p=0.045		*/
	testparm _Iarchi*						/* p=0.20		*/
	testparm covid_behavior_safety_distance	/* p=0.26		*/
	* distance de sécu pas retenue
	
// 2eme variable vaccination (sans données manquantes)
xi: firthlogit covid_bool i.covid_vaccination_explicativebis if group_date_itw1==1, or
	testparm _Icovid_vac*					/* p=0.010		*/

xi: firthlogit covid_bool i.covid_vaccination_explicativebis i.archipelago if group_date_itw1==1, or
	testparm _Icovid_vac*					/* p=0.014		*/
	testparm _Iarchi*						/* p=0.081		*/

*	test avec "distance de sécurité"
xi: firthlogit covid_bool i.covid_vaccination_explicativebis i.archipelago covid_behavior_safety_distance if group_date_itw1==1, or
	testparm _Icovid_vac*					/* p=0.015		*/
	testparm _Iarchi*						/* p=0.16		*/
	testparm covid_behavior_safety_distance	/* p=0.26		*/
	* distance de sécu pas retenue

	
/* RESULTAT FINAL PERIODE 1 - Avril à Juin 2021
-----------------------------------------------
                                                        Number of obs =    496
                                                        Wald chi2(4)  =  13.26
Penalized log likelihood = -100.20207                   Prob > chi2   = 0.0101

-------------------------------------------------------------------------------
   covid_bool | Odds ratio   Std. err.      z    P>|z|     [95% conf. interval]
--------------+----------------------------------------------------------------
_Icovid_vac_1 |   .0293649   .0421003    -2.46   0.014     .0017679    .4877419
_Iarchipela_1 |   .4504027   .2405362    -1.49   0.135     .1581319     1.28287
_Iarchipela_2 |   .3201377   .1527821    -2.39   0.017      .125635    .8157613
_Iarchipela_3 |          1  (omitted)
_Iarchipela_5 |   .4469858   .2151031    -1.67   0.094     .1740483    1.147936
        _cons |   .2282498   .0664278    -5.08   0.000     .1290281    .4037725
------------------------------------------------------------------------------- */

	

*---------------------------------------------------------------------------		
**# 3.2. Analyse Multivariée sur la 2ème période : Juillet à Décembre 2021 |
*---------------------------------------------------------------------------
**# 3.2.A/ METHODE REGRESSION LOGISTIQUE (firthlogit) descendante (manuelle)
* (pour rappel 'langue maternelle' pas retenue car non significative sans 'autres')
* avec classification des communes (rural / urbain)
	char mois_interview_step1[omit] "10"
	char gender[omit] "2"
	char town_classif_1[omit] "zone urbaine"
	char pro_act_last_year2[omit] "Private employee"	
	char nhouse_tot_classif3[omit] "2"

* #1
xi: firthlogit covid_bool i.mois_interview_step1 i.gender i.age_cat i.town_classif_1 i.pro_act_last_year2 i.nhouse_tot_classif3 i.house_clean_water i.mosquito_bites i.obesity_who_bool i.hypertension_bool cancer_or_malignant_tumor_medica i.covid_behavior_mask i.covid_vaccination_explicative if group_date_itw1==2, or
	testparm _Imois_inte*		/* p<0.001	*/
	testparm _Igender*			/* p=0.98	*/
	testparm _Iage_cat* 		/* p=0.76	*/
	testparm _Itown_cla*		/* p=0.84	*/
	testparm _Ipro_act*			/* p=0.006	*/
	testparm _Inhouse_to*		/* p=0.014	*/
	testparm _Ihouse_cle*		/* p=0.43	*/
	testparm _Imosquito*		/* p=0.15	*/
	testparm _Iobesity*			/* p=0.31	*/
	testparm _Ihypertens*		/* p=0.72	*/
	testparm cancer* 			/* p=0.40	*/
	testparm _Icovid_beh*		/* p=0.05	*/
	testparm _Icovid_vac*		/* p<0.001	*/
/* Genre (gender) variable moins significative (p=0.98)	*/	

* #2
xi: firthlogit covid_bool i.mois_interview_step1 i.age_cat i.town_classif_1 i.pro_act_last_year2 i.nhouse_tot_classif3 i.house_clean_water i.mosquito_bites i.obesity_who_bool i.hypertension_bool cancer_or_malignant_tumor_medica i.covid_behavior_mask i.covid_vaccination_explicative if group_date_itw1==2, or
	testparm _Imois_inte*		/* p<0.001	*/
	testparm _Iage_cat* 		/* p=0.76	*/
	testparm _Itown_cla*		/* p=0.84	*/
	testparm _Ipro_act*			/* p=0.006	*/
	testparm _Inhouse_to*		/* p=0.014	*/
	testparm _Ihouse_cle*		/* p=0.43	*/
	testparm _Imosquito*		/* p=0.15	*/
	testparm _Iobesity*			/* p=0.31	*/
	testparm _Ihypertens*		/* p=0.72	*/
	testparm cancer* 			/* p=0.40	*/
	testparm _Icovid_beh*		/* p=0.05	*/
	testparm _Icovid_vac*		/* p<0.001	*/
/* Classification des communes (town_classif_1) variable moins significative (p=0.84)	*/	

* #3
xi: firthlogit covid_bool i.mois_interview_step1 i.age_cat i.pro_act_last_year2 i.nhouse_tot_classif3 i.house_clean_water i.mosquito_bites i.obesity_who_bool i.hypertension_bool cancer_or_malignant_tumor_medica i.covid_behavior_mask i.covid_vaccination_explicative if group_date_itw1==2, or
	testparm _Imois_inte*		/* p<0.001	*/
	testparm _Iage_cat* 		/* p=0.76	*/
	testparm _Ipro_act*			/* p=0.006	*/
	testparm _Inhouse_to*		/* p=0.014	*/
	testparm _Ihouse_cle*		/* p=0.42	*/
	testparm _Imosquito*		/* p=0.15	*/
	testparm _Iobesity*			/* p=0.31	*/
	testparm _Ihypertens*		/* p=0.72	*/
	testparm cancer* 			/* p=0.40	*/
	testparm _Icovid_beh*		/* p=0.05	*/
	testparm _Icovid_vac*		/* p<0.001	*/
/* Catégorie d'age (age_cat) variable moins significative (p=0.76)	*/	

* #4
xi: firthlogit covid_bool i.mois_interview_step1 i.pro_act_last_year2 i.nhouse_tot_classif3 i.house_clean_water i.mosquito_bites i.obesity_who_bool i.hypertension_bool cancer_or_malignant_tumor_medica i.covid_behavior_mask i.covid_vaccination_explicative if group_date_itw1==2, or
	testparm _Imois_inte*		/* p<0.001	*/
	testparm _Ipro_act*			/* p=0.006	*/
	testparm _Inhouse_to*		/* p=0.016	*/
	testparm _Ihouse_cle*		/* p=0.41	*/
	testparm _Imosquito*		/* p=0.14	*/
	testparm _Iobesity*			/* p=0.33	*/
	testparm _Ihypertens*		/* p=0.57	*/
	testparm cancer* 			/* p=0.47	*/
	testparm _Icovid_beh*		/* p=0.05	*/
	testparm _Icovid_vac*		/* p<0.001	*/
/* Hypertension (hypertension_bool) variable moins significative (p=0.57)	*/	

* #5
xi: firthlogit covid_bool i.mois_interview_step1 i.pro_act_last_year2 i.nhouse_tot_classif3 i.house_clean_water i.mosquito_bites i.obesity_who_bool  cancer_or_malignant_tumor_medica  i.covid_behavior_mask i.covid_vaccination_explicative if group_date_itw1==2, or
	testparm _Imois_inte*		/* p<0.001	*/
	testparm _Ipro_act*			/* p=0.007	*/
	testparm _Inhouse_to*		/* p=0.019	*/
	testparm _Ihouse_cle*		/* p=0.41	*/
	testparm _Imosquito*		/* p=0.16	*/
	testparm _Iobesity*			/* p=0.22	*/
	testparm cancer* 			/* p=0.47	*/
	testparm _Icovid_beh*		/* p=0.14	*/
	testparm _Icovid_vac*		/* p<0.001	*/
/* Historique de cancer (cancer_or_malignant_tumor_medica) variable moins significative (p=0.47)	*/

* #6
xi: firthlogit covid_bool i.mois_interview_step1 i.pro_act_last_year2 i.nhouse_tot_classif3 i.house_clean_water i.mosquito_bites i.obesity_who_bool i.covid_behavior_mask  i.covid_vaccination_explicative if group_date_itw1==2, or
	testparm _Imois_inte*		/* p<0.001	*/
	testparm _Ipro_act*			/* p=0.006	*/
	testparm _Inhouse_to*		/* p=0.020	*/
	testparm _Ihouse_cle*		/* p=0.41	*/
	testparm _Imosquito*		/* p=0.18	*/
	testparm _Iobesity*			/* p=0.20	*/
	testparm _Icovid_beh*		/* p=0.13	*/
	testparm _Icovid_vac*		/* p<0.001	*/
/* Accès eau courante (house_clean_water) variable moins significative (p=0.41)	*/	

* #7
xi: firthlogit covid_bool i.mois_interview_step1 i.pro_act_last_year2 i.nhouse_tot_classif3 i.mosquito_bites i.obesity_who_bool i.covid_behavior_mask i.covid_vaccination_explicative if group_date_itw1==2, or
	testparm _Imois_inte*		/* p<0.001	*/
	testparm _Ipro_act*			/* p=0.006	*/
	testparm _Inhouse_to*		/* p=0.020	*/
	testparm _Imosquito*		/* p=0.17	*/
	testparm _Iobesity*			/* p=0.21	*/
	testparm _Icovid_beh*		/* p=0.13	*/
	testparm _Icovid_vac*		/* p<0.001	*/
/* Obésité (obesity_who_bool) variable moins significative (p=0.21)	*/	

* #8
xi: firthlogit covid_bool i.mois_interview_step1 i.pro_act_last_year2 i.nhouse_tot_classif3 i.mosquito_bites i.covid_behavior_mask i.covid_vaccination_explicative if group_date_itw1==2, or
	testparm _Imois_inte*		/* p<0.001	*/
	testparm _Ipro_act*			/* p=0.009	*/
	testparm _Inhouse_to*		/* p=0.020	*/
	testparm _Imosquito*		/* p=0.23	*/
	testparm _Icovid_beh*		/* p=0.11	*/
	testparm _Icovid_vac*		/* p<0.001	*/
/* Fréquence des piqures de moustique (mosquito_bites) variable moins significative (p=0.23)	*/	

* #9
xi: firthlogit covid_bool i.mois_interview_step1 i.pro_act_last_year2 i.nhouse_tot_classif3 i.covid_behavior_mask i.covid_vaccination_explicative if group_date_itw1==2, or
	testparm _Imois_inte*		/* p<0.001	*/
	testparm _Ipro_act*			/* p=0.009	*/
	testparm _Inhouse_to*		/* p=0.027	*/
	testparm _Icovid_beh*		/* p=0.17	*/
	testparm _Icovid_vac*		/* p<0.001	*/
/* Geste barrière / masque (covid_behavior_mask) variable moins significative (p=0.17)	*/	

* #10, logistic peut être utilisé
xi: logistic covid_bool i.mois_interview_step1 i.pro_act_last_year2 i.nhouse_tot_classif3 i.covid_vaccination_explicative if group_date_itw1==2
	testparm _Imois_inte*		/* p<0.001	*/
	testparm _Ipro_act*			/* p=0.006	*/
	testparm _Inhouse_to*		/* p=0.022	*/
	testparm _Icovid_vac*		/* p<0.001	*/	
/*Logistic regression                                     Number of obs =    652
                                                        LR chi2(10)   = 465.00
                                                        Prob > chi2   = 0.0000
Log likelihood = -210.11061                             Pseudo R2     = 0.5253

--------------------------------------------------------------------------------
    covid_bool | Odds ratio   Std. err.      z    P>|z|     [95% conf. interval]
---------------+----------------------------------------------------------------
 _Imois_inte_4 |          1  (omitted)
 _Imois_inte_5 |          1  (omitted)
 _Imois_inte_6 |          1  (omitted)
 _Imois_inte_7 |   .0513635   .0176995    -8.62   0.000     .0261419    .1009188
_Imois_inte_11 |   1.104211   .4458468     0.25   0.806     .5004526    2.436359
_Imois_inte_12 |   1.067173   .9875918     0.07   0.944     .1739841    6.545765
 _Ipro_act_l_1 |   3.188355   1.362943     2.71   0.007     1.379428    7.369436
 _Ipro_act_l_2 |   1.165321   .5150857     0.35   0.729      .490009     2.77132
 _Ipro_act_l_4 |   .8191563   .2527868    -0.65   0.518     .4473949    1.499832
 _Inhouse_to_1 |   .3630416    .135592    -2.71   0.007     .1745991    .7548673
 _Inhouse_to_3 |   .6899708   .2066048    -1.24   0.215     .3836604    1.240836
 _Inhouse_to_4 |   1.678177   .9214997     0.94   0.346     .5720535    4.923104
 _Icovid_vac_1 |   .0052273   .0020347   -13.50   0.000     .0024376      .01121
_Icovid_vac_99 |          1  (omitted)
         _cons |   14.07151   5.368277     6.93   0.000     6.662048    29.72172
--------------------------------------------------------------------------------*/


**# 3.2.B/ METHODE REGRESSION LOGISTIQUE (firthlogit) descendante (manuelle) - Periode 2 
* PAS REFAITE AVEC VARIABLE GESTE BARRIERE covid_behavior_mask
* pour rappel 'langue maternelle' pas retenue car non significative sans 'autres'
* Variable de commune (town_classif_1), non retenue car association mois / commune trop fort due au séquençage
xi: firthlogit covid_bool i.mois_interview_step1 i.gender i.age_cat i.pro_act_last_year2 i.nhouse_tot_classif3 i.house_clean_water i.mosquito_bites i.obesity_who_bool i.hypertension_bool cancer_or_malignant_tumor_medica i.covid_vaccination_explicative if group_date_itw1==2, or
	testparm _Imois_inte*		/* p<0.001	*/
	testparm _Igender*			/* p=0.98	*/
	testparm _Iage_cat* 		/* p=0.81	*/
	testparm _Ipro_act*			/* p=0.005	*/
	testparm _Inhouse_to*		/* p=0.014	*/
	testparm _Ihouse_cle*		/* p=0.42	*/
	testparm _Imosquito*		/* p=0.23	*/
	testparm _Iobesity*			/* p=0.36	*/
	testparm _Ihypertens*		/* p=0.71	*/
	testparm cancer* 			/* p=0.39	*/
	testparm _Icovid_vac*		/* p<0.001	*/
/* Genre (gender) variable moins significative (p=0.98)	*/	

xi: firthlogit covid_bool i.mois_interview_step1 i.age_cat i.pro_act_last_year2 i.nhouse_tot_classif3 i.house_clean_water i.mosquito_bites i.obesity_who_bool i.hypertension_bool cancer_or_malignant_tumor_medica i.covid_vaccination_explicative if group_date_itw1==2, or
	testparm _Imois_inte*		/* p<0.001	*/
	testparm _Iage_cat* 		/* p=0.81		*/
	testparm _Ipro_act*			/* p=0.005	*/
	testparm _Inhouse_to*		/* p=0.014	*/
	testparm _Ihouse_cle*		/* p=0.41	*/
	testparm _Imosquito*		/* p=0.22	*/
	testparm _Iobesity*			/* p=0.36	*/
	testparm _Ihypertens*		/* p=0.70	*/
	testparm cancer* 			/* p=0.38	*/
	testparm _Icovid_vac*		/* p<0.001	*/
/* Carégorie d'age (age_cat) variable moins significative (p=0.81)	*/	
	
xi: firthlogit covid_bool i.mois_interview_step1 i.pro_act_last_year2 i.nhouse_tot_classif3 i.house_clean_water i.mosquito_bites i.obesity_who_bool i.hypertension_bool cancer_or_malignant_tumor_medica i.covid_vaccination_explicative if group_date_itw1==2, or
	testparm _Imois_inte*		/* p<0.001	*/
	testparm _Ipro_act*			/* p=0.005	*/
	testparm _Inhouse_to*		/* p=0.016	*/
	testparm _Ihouse_cle*		/* p=0.41	*/
	testparm _Imosquito*		/* p=0.21	*/
	testparm _Iobesity*			/* p=0.38	*/
	testparm _Ihypertens*		/* p=0.55	*/
	testparm cancer* 			/* p=0.44	*/
	testparm _Icovid_vac*		/* p<0.001	*/
/* Hypertension (hypertension_bool) variable moins significative (p=0.55)	*/	

** Retour sur fin étape 4 du scénario précédent	
	


*/

