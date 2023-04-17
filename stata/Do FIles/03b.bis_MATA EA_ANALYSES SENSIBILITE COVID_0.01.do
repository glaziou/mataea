*****************************************************************************
*   					Projet MATA'EA										*
* 			Cartographie de l'état de santé de la 							*
* 			population de la Polynésie française							*
*																			*
*					 		Fichier 03 B - bis								*
*					ANALYSES SENSIBILITE COVID-19							*
*																			*
*		10 sujets avec même mois de vacci et dépistage Covid-19				*
*				   considérés vaccinés (puis positif)						*
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
* LES 10 SUJETS AVEC MOIS VACCI = MOIS TEST COVID-19 POSITIF => CONSIDERES COMME VACCINES (A PRIORI VACCINATION PUIS INFECTION)
* list subjid date_interview_step1 covid_vaccination_explicative covid_test_positif_date2  covid_first_injection_date if covid_bool==1 & covid_test_positif_date2!=.  & covid_first_injection_date!=. & month(covid_test_positif_date2)==month(covid_first_injection_date) & year(covid_test_positif_date2)==year(covid_first_injection_date)
	replace covid_vaccination_explicative=1 if covid_bool==1 & covid_test_positif_date2!=. & covid_first_injection_date!=. & month(covid_test_positif_date2)==month(covid_first_injection_date) & year(covid_test_positif_date2)==year(covid_first_injection_date)
	
* ET LA VARIABLE VACCINATION BIS QUI CONSIDERE LES 43 "NE VEUT PAS REPONDRE" A LA QUESTION VACCINATION COVID-19 COMME NON-VACCINES 
* Les 43 sujets présents dans Groupe 1 uniquement
drop 			covid_vaccination_explicativebis		
gen 			covid_vaccination_explicativebis =covid_vaccination_explicative
	replace 		covid_vaccination_explicativebis = 0 if covid_vaccination_explicative==99
	label variable  covid_vaccination_explicativebis "Statut vaccinal au moment de l'infection ou si pas infecte au moment de l'interview"
	order 			covid_vaccination_explicativebis, after(covid_vaccination_explicative)
	label values 	covid_vaccination_explicativebis lbcovidvaccinationexplicative 		
		

**********************************************************************
**# 			II. ANALYSE UNIVARIEE OUTCOME COVID 				**
**********************************************************************	
	
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

	
	
	
