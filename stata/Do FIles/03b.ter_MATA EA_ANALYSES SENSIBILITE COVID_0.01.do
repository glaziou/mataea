*****************************************************************************
*   					Projet MATA'EA										*
* 			Cartographie de l'état de santé de la 							*
* 			population de la Polynésie française							*
*																			*
*					 		Fichier 03 B - ter								*
*					ANALYSES SENSIBILITE COVID-19							*
*																			*
*		10 sujets avec même mois de vacci et dépistage Covid-19				*
*				   supprimés de l'analyse						*
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
* STATUT VACCINAL COVID AU MOMENT DE L INFECTION / DE L INTERVIEW (2 CLASSES) 
* POUR ANALYSE DE SENSIBILITE
* LES 10 SUJETS AVEC MOIS VACCI = MOIS TEST COVID-19 POSITIF => SUPPRIMES DE L'ANALYSE
* list subjid date_interview_step1 covid_vaccination_explicative covid_test_positif_date2  covid_first_injection_date if covid_bool==1 & covid_test_positif_date2!=.  & covid_first_injection_date!=. & month(covid_test_positif_date2)==month(covid_first_injection_date) & year(covid_test_positif_date2)==year(covid_first_injection_date)
drop if covid_bool==1 & covid_test_positif_date2!=. & covid_first_injection_date!=. & month(covid_test_positif_date2)==month(covid_first_injection_date) & year(covid_test_positif_date2)==year(covid_first_injection_date)


**********************************************************************
**# 			II. ANALYSE UNIVARIEE OUTCOME COVID 				**
**********************************************************************	

// 2.1 1ère période***************************************************
* VACCINATION - 3 CLASSES (VACCINE / NON VACCINE / manqants)
bysort group_date_itw1 : tab covid_vaccination_explicative covid_bool,expected row chi2 exact
xi : firthlogit covid_bool i.covid_vaccination_explicative  if group_date_itw1==1 ,or

* VACCINATION - 2 CLASSES (VACCINE / NON VACCINE)
bysort group_date_itw1 : tab covid_vaccination_explicativebis covid_bool,expected row chi2 exact
xi : firthlogit covid_bool i.covid_vaccination_explicativebis  if group_date_itw1==1 ,or

// 2ème période *******************************************************
/*
* COVID ET MOIS DE L'ITW
*tab mois_interview_step1 covid_bool,expected row chi2 exact
bysort group_date_itw1 : tab mois_interview_step1 covid_bool,expected row chi2 exact
		char mois_interview_step1[omit] "7"
xi: logistic covid_bool i.mois_interview_step1 if group_date_itw1==2
	
* COVID ET GENRE
bysort group_date_itw1 : tab gender covid_bool,expected row chi2
bysort group_date_itw1 : logistic covid_bool ib2.gender 

* COVID ET AGE
bysort group_date_itw1 : tab age_cat covid_bool,expected row chi2
xi: logistic covid_bool i.age_cat if group_date_itw1==2

* COVID ET LANGUE MATERNELLE
bysort group_date_itw1 : tab native_language2 covid_bool, row chi2
	char native_language2[omit] "2"
xi: logistic covid_bool i.native_language2 if group_date_itw1==2
testparm _Inative_la_1 _Inative_la_5	// p=0.47

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

	ddddd



	
**********************************************************************
**# 		III. ANALYSE MULTIVARIEE OUTCOME COVID 					**
**********************************************************************	

*---------------------------------------------------------------------
**# 3.1. Analyse Multivariée sur la 1ère période : Avril à Juin 2021 |
*---------------------------------------------------------------------
*pas de changement sur la 1ère période
	

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
	testparm _Imois_inte*		
	testparm _Igender*			
	testparm _Iage_cat* 		
	testparm _Itown_cla*		
	testparm _Ipro_act*			
	testparm _Inhouse_to*		
	testparm _Ihouse_cle*		
	testparm _Imosquito*		
	testparm _Iobesity*			
	testparm _Ihypertens*		
	testparm cancer* 			
	testparm _Icovid_beh*		
	testparm _Icovid_vac*		
/* Genre (gender) variable moins significative (p=0.88)	*/	

* #2
xi: firthlogit covid_bool i.mois_interview_step1 i.age_cat i.town_classif_1 i.pro_act_last_year2 i.nhouse_tot_classif3 i.house_clean_water i.mosquito_bites i.obesity_who_bool i.hypertension_bool cancer_or_malignant_tumor_medica i.covid_behavior_mask i.covid_vaccination_explicative if group_date_itw1==2, or
	testparm _Imois_inte*		
	testparm _Iage_cat* 		
	testparm _Itown_cla*		
	testparm _Ipro_act*			
	testparm _Inhouse_to*		
	testparm _Ihouse_cle*		
	testparm _Imosquito*		
	testparm _Iobesity*			
	testparm _Ihypertens*		
	testparm cancer* 			
	testparm _Icovid_beh*		
	testparm _Icovid_vac*		
/* Hypertension variable moins significative (p=0.87)	*/	

* #3
xi: firthlogit covid_bool i.mois_interview_step1 i.age_cat i.town_classif_1 i.pro_act_last_year2 i.nhouse_tot_classif3 i.house_clean_water i.mosquito_bites i.obesity_who_bool cancer_or_malignant_tumor_medica i.covid_behavior_mask i.covid_vaccination_explicative if group_date_itw1==2, or
	testparm _Imois_inte*		
	testparm _Iage_cat* 		
	testparm _Itown_cla*		
	testparm _Ipro_act*			
	testparm _Inhouse_to*		
	testparm _Ihouse_cle*		
	testparm _Imosquito*		
	testparm _Iobesity*					
	testparm cancer* 			
	testparm _Icovid_beh*		
	testparm _Icovid_vac*		
/* Classification des communes variable moins significative (p=0.71)	*/	

* #4
xi: firthlogit covid_bool i.mois_interview_step1 i.age_cat i.pro_act_last_year2 i.nhouse_tot_classif3 i.house_clean_water i.mosquito_bites i.obesity_who_bool cancer_or_malignant_tumor_medica i.covid_behavior_mask i.covid_vaccination_explicative if group_date_itw1==2, or
	testparm _Imois_inte*		
	testparm _Iage_cat* 				
	testparm _Ipro_act*			
	testparm _Inhouse_to*		
	testparm _Ihouse_cle*		
	testparm _Imosquito*		
	testparm _Iobesity*					
	testparm cancer* 			
	testparm _Icovid_beh*		
	testparm _Icovid_vac*		
/* Fréquence de piqures de moustiques variable moins significative (p=0.40)	*/	

* #5
xi: firthlogit covid_bool i.mois_interview_step1 i.age_cat i.pro_act_last_year2 i.nhouse_tot_classif3 i.house_clean_water i.obesity_who_bool cancer_or_malignant_tumor_medica i.covid_behavior_mask i.covid_vaccination_explicative if group_date_itw1==2, or
	testparm _Imois_inte*		
	testparm _Iage_cat* 				
	testparm _Ipro_act*			
	testparm _Inhouse_to*		
	testparm _Ihouse_cle*		
	testparm _Iobesity*					
	testparm cancer* 			
	testparm _Icovid_beh*		
	testparm _Icovid_vac*		
/* Catégories d'age variable moins significative (p=0.40)	*/	

* #6
xi: firthlogit covid_bool i.mois_interview_step1 i.pro_act_last_year2 i.nhouse_tot_classif3 i.house_clean_water i.obesity_who_bool cancer_or_malignant_tumor_medica i.covid_behavior_mask i.covid_vaccination_explicative if group_date_itw1==2, or
	testparm _Imois_inte*		
	testparm _Ipro_act*			
	testparm _Inhouse_to*		
	testparm _Ihouse_cle*		
	testparm _Iobesity*					
	testparm cancer* 			
	testparm _Icovid_beh*		
	testparm _Icovid_vac*		
/* Historique de cancer variable moins significative (p=0.51)	*/	

* #7
xi: firthlogit covid_bool i.mois_interview_step1 i.pro_act_last_year2 i.nhouse_tot_classif3 i.house_clean_water i.obesity_who_bool i.covid_behavior_mask i.covid_vaccination_explicative if group_date_itw1==2, or
	testparm _Imois_inte*		
	testparm _Ipro_act*			
	testparm _Inhouse_to*		
	testparm _Ihouse_cle*		
	testparm _Iobesity*							
	testparm _Icovid_beh*		
	testparm _Icovid_vac*		
/* Eau courante variable moins significative (p=0.21)	*/	

* #8
xi: firthlogit covid_bool i.mois_interview_step1 i.pro_act_last_year2 i.nhouse_tot_classif3 i.obesity_who_bool i.covid_behavior_mask i.covid_vaccination_explicative if group_date_itw1==2, or
	testparm _Imois_inte*		
	testparm _Ipro_act*			
	testparm _Inhouse_to*		
	testparm _Iobesity*							
	testparm _Icovid_beh*		
	testparm _Icovid_vac*		
/* Nombre de personnes dans le foyer moins significative (p=0.16)	*/	

* #9
xi: firthlogit covid_bool i.mois_interview_step1 i.pro_act_last_year2 i.obesity_who_bool i.covid_behavior_mask i.covid_vaccination_explicative if group_date_itw1==2, or
	testparm _Imois_inte*		
	testparm _Ipro_act*			
	testparm _Iobesity*							
	testparm _Icovid_beh*		
	testparm _Icovid_vac*		
/* Geste barrière / usage du masque dans le foyer moins significative (p=0.13)	*/	

* #10
xi: firthlogit covid_bool i.mois_interview_step1 i.pro_act_last_year2 i.obesity_who_bool i.covid_vaccination_explicative if group_date_itw1==2, or
	testparm _Imois_inte*		
	testparm _Ipro_act*			
	testparm _Iobesity*							
	testparm _Icovid_vac*		
/* Obésité dans le foyer moins significative (p=0.099)	*/	

* #11
xi: firthlogit covid_bool i.mois_interview_step1 i.pro_act_last_year2 i.covid_vaccination_explicative if group_date_itw1==2, or
	testparm _Imois_inte*		/* p<0.0001 */
	testparm _Ipro_act*			/* p=0.010  */
	testparm _Icovid_vac*		/* p<0.0001 */
/*                                                      Number of obs =    652
                                                        Wald chi2(7)  = 195.47
Penalized log likelihood = -229.36885                   Prob > chi2   = 0.0000

--------------------------------------------------------------------------------
    covid_bool | Odds ratio   Std. err.      z    P>|z|     [95% conf. interval]
---------------+----------------------------------------------------------------
 _Imois_inte_4 |          1  (omitted)
 _Imois_inte_5 |          1  (omitted)
 _Imois_inte_6 |          1  (omitted)
 _Imois_inte_7 |   .0597314   .0194884    -8.64   0.000     .0315125    .1132198
_Imois_inte_11 |   1.070317   .3758771     0.19   0.847     .5377559    2.130296
_Imois_inte_12 |   .8042139   .7157247    -0.24   0.807     .1405495    4.601653
 _Ipro_act_l_1 |   2.179536   .8362622     2.03   0.042     1.027467    4.623384
 _Ipro_act_l_2 |   .8565757   .3442914    -0.39   0.700     .3896138    1.883203
 _Ipro_act_l_4 |   .6750908   .1906403    -1.39   0.164     .3881411     1.17418
 _Icovid_vac_1 |   .0120411   .0038826   -13.71   0.000     .0064003    .0226535
_Icovid_vac_99 |          1  (omitted)
         _cons |    11.5367   3.928697     7.18   0.000     5.918537     22.4879
--------------------------------------------------------------------------------*/

	
	
	
*/

