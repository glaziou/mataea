*****************************************************************************
*   					Projet MATA'EA										*
* 			Cartographie de l'état de santé de la 							*
* 			population de la Polynésie française							*
*																			*
*					 		Fichier 03 B									*
*						 ANALYSES COVID-19									*
*																			*
*																			*
*																			*
* 	auteur : Vincent Mendiboure												*
* 	dernier update : 31 octobre 2022										*
*																			*
*****************************************************************************

*cd "Z:\donnees\Stata"
cd "C:\Users\Mendiboure\Documents\Master PH\Stage Pasteur\image\donnees\Stata"

use "02_MATAEA_final.dta", clear

**********************************************************************
**# 		I. INTRODUCTION - PREPARATIONS SPECIFIQUES 				**
**********************************************************************

* Suppression des obseration du 1er groupe d'inclusion avant questionnaire COVID
drop if consent_read=="Yes_STEP1;Yes_STEP3;NA_STEP6"
	
** SEPARATION DES VARIABLES DES GESTES BARRIERES

gen covid_behavior_mask =	0
	replace 	 covid_behavior_mask =1 if strpos(covid_safety_behavior, "mask")
	replace 	 covid_behavior_mask =99 if  covid_safety_behavior =="NA"
	order 		 covid_behavior_mask, after(covid_safety_behavior)
	label values covid_behavior_mask lbbooleen	
	label var	 covid_behavior_mask "Wore masks as barrier gestures"
	
gen covid_behavior_safety_distance =	0
	replace 	 covid_behavior_safety_distance =1 if strpos(covid_safety_behavior, "distance")
	replace 	 covid_behavior_safety_distance =99 if  covid_safety_behavior =="NA"
	order 		 covid_behavior_safety_distance, after(covid_safety_behavior)
	label values covid_behavior_safety_distance lbbooleen
	label var	 covid_behavior_safety_distance "Kept safety distance as barrier gestures"
	
gen covid_behavior_cough_elbow =	0
	replace 	 covid_behavior_cough_elbow =1 if strpos(covid_safety_behavior, "elbow")
	replace 	 covid_behavior_cough_elbow =99 if  covid_safety_behavior =="NA"
	order 		 covid_behavior_cough_elbow, after(covid_safety_behavior)
	label values covid_behavior_cough_elbow lbbooleen
	label var	 covid_behavior_cough_elbow "Coughed in elbow as barrier gestures"
	
gen covid_behavior_hand_shaking =	0
	replace 	 covid_behavior_hand_shaking =1 if strpos(covid_safety_behavior, "shaking")
	replace 	 covid_behavior_hand_shaking =99 if  covid_safety_behavior =="NA"
	order 		 covid_behavior_hand_shaking, after(covid_safety_behavior)
	label values covid_behavior_hand_shaking lbbooleen
	label var	 covid_behavior_hand_shaking "Did not shake hands as barrier gestures"
	
gen covid_behavior_hand_washing =	0
	replace 	 covid_behavior_hand_washing =1 if strpos(covid_safety_behavior, "Hand washing")
	replace 	 covid_behavior_hand_washing =99 if  covid_safety_behavior =="NA"
	order 		 covid_behavior_hand_washing, after(covid_safety_behavior)
	label values covid_behavior_hand_washing lbbooleen
	label var	 covid_behavior_hand_washing "Washed hands as barrier gestures"

* CREATION VARIABLE DATE DE DEPISTAGE (au 1er du mois concerné)
generate double covid_test_positif_date2 = date(substr(covid_test_positif_date,1,7),"YM") 
	format  covid_test_positif_date2 %d
	order   covid_test_positif_date2, after(covid_test_positif_date)	
	
	* Modification #69 : remplacer la valeur aberrante de date covid ("2019-03-XX" | subjid ="TA8664ILM" ) en 2020
	replace covid_test_positif_date2=. if substr(covid_test_positif_date,1,4)=="2019"

	*browse subjid date_interview_step1 covid_test_positif_date2 if dofc(date_interview_step1) < covid_test_positif_date2 & covid_test_positif_date2 !=.
	* Modification #70 :TA8375ILM avec interview le 13 juillet 2021 et date test COVID-19 + en oct 2021
	replace covid_test_positif_date2=. if subjid=="TA8375ILM"

	* Modification #71 : "TA8465ILM" avec une date de test positif en janvier 2020 et ne revenant pas de l'étranger 
	replace covid_test_positif_date2=. if subjid =="TA8465ILM"
	
* CREATION PREMIER OUTCOME COVID-19, BASE SUR IgG TOTAUX ET LA DECLARATION DE DESPISTAGE POSITIF
gen covid_outcome_a =0 
	replace covid_outcome_a =1 if covid_test_positif ==1
	replace covid_outcome_a =1 if covid_test_positif ==2 & coser ==1 & covid_vaccination !=1 // si Ac POS, et pas vacciné (infection asymptomatique)
	label var covid_outcome_a "Infection COVID-19 (basée sur Wanti-anti S- et déclaratif)"
	label values covid_outcome_a lbbooleen
	order covid_outcome_a, after(covid_second_injection_date)

* CREATION DEUXIEME OUTCOME COVID-19, BASE SUR LES Ac ANTI-N 
gen 			 covid_outcome_b =covid_anti_n
	order 		 covid_outcome_b, after(covid_outcome_a)
	label 		 var covid_outcome_b "Infection COVID-19 (basée sur Ac anti-N)"
	label values covid_outcome_b lbbooleen
	
* STRATIFICATION DU RECRUTEMENT EN 2 GROUPES SUIVANT DATE INCLUSION : 1/ AVRIL-JUIN 2021 2/ JUILLET-DEC 2021
gen 		group_date_itw1  = 1 if dofc(date_interview_step1) <= date("30June2021", "DMY")
	replace group_date_itw1  =2 if dofc(date_interview_step1) > date("30June2021", "DMY") & dofc(date_interview_step1) !=.
	order 	group_date_itw1 , after(mois_interview_step1)
	label variable group_date_itw1  "Groupe inclusion COVID-19"
	label define lbgroupdateitw 1 "Group 1: april to june-21" 2 "Group 2: july to dec-21"
	label values group_date_itw1 lbgroupdateitw 	
	
* DUREE EN MOIS ENTRE VACCINATION ET INFECTION (DEPISTAGE)
* attention 0 (mois) ne garantit pas l'antériorité de la vaccination sur l'infection 
* (covid_test_positif_date indique un mois ; covid_test_positif_date2 est définie au 15 du mois // covid_first_injection_date peut donner la date précise, mais peut être définie au 1er du mois quand seul le mois est connue )
gen duration_vacci_infection = month(covid_test_positif_date2)- month(covid_first_injection_date) if year(covid_test_positif_date2) ==2021 & covid_test_positif ==1 & month(covid_test_positif_date2) >= month(covid_first_injection_date)
	order duration_vacci_infection , after(covid_second_injection_date)
	label var duration_vacci_infection "Duration (in months) between vaccination & infection"

* DUREE EN MOIS ENTRE DEPISTAGE ET PRELEVEMENT SANGUIN
gen duration_test_draw =  (date_prlvt - covid_test_positif_date2 - 14) if  covid_test_positif ==1  // '-14' en moyenne car 'covid_test_positif_date2' a été défini au 1er du mois du dépistage
	order duration_test_draw , after(covid_test_positif_date2)
	label var duration_test_draw "Duration (in days) between Pos testing & blood draw"
gen duration_test_draw180 =  recode(duration_test_draw, 180,181)
	order duration_test_draw180 , after(duration_test_draw)
	recode duration_test_draw180 (180=1) (181=2)
	label var duration_test_draw180 "Duration between Pos testing & blood draw"
	label define lbdurationtestdraw180 1 "Tested CoViD Pos less than 180 days before blood draw" 2 "Tested CoViD Pos more than 180 days before blood draw" 
	label values duration_test_draw180 lbdurationtestdraw180
gen duration_test_draw90 =  recode(duration_test_draw, 180,181)
	order duration_test_draw90 , after(duration_test_draw)
	recode duration_test_draw90 (180=1) (181=2)
	label var duration_test_draw90 "Duration between Pos testing & blood draw"
	label define lbdurationtestdraw90 1 "Tested CoViD Pos less than 90 days before blood draw" 2 "Tested CoViD Pos more than 90 days before blood draw" 
	label values duration_test_draw90 lbdurationtestdraw90
	
	// Association entre anti-N et durée depuis dépistage
	// cut-off à 180 jours
	bysort duration_test_draw180 : sum covid_anti_n_his_tag
	ttest 		covid_anti_n_his_tag, by(duration_test_draw180)
	ranksum 	covid_anti_n_his_tag, by(duration_test_draw180)
	*hist covid_anti_n_his_tag, by(duration_test_draw180) width(1000)

	// cut-off à 90 jours
	bysort duration_test_draw90 : sum covid_anti_n_his_tag
	ttest 		covid_anti_n_his_tag, by(duration_test_draw90)
	ranksum 	covid_anti_n_his_tag, by(duration_test_draw90)
	*hist covid_anti_n_his_tag, by(duration_test_draw90) width(1000)
		
* STATUT VACCINAL COVID AU MOMENT DU DEPISTAGE / DE L INTERVIEW (2 CLASSES)
gen 	covid_vaccination_explicative=0 if covid_outcome_a!=.
replace covid_vaccination_explicative=1 if covid_outcome_a==1 & covid_test_positif_date2!=. & covid_first_injection_date!=. & covid_first_injection_date<covid_test_positif_date2 & month(covid_test_positif_date2)!=month(covid_first_injection_date) 
replace covid_vaccination_explicative=1  if covid_outcome_a==0 & covid_first_injection_date!=. & covid_first_injection_date<dofc(date_interview_step1)
replace covid_vaccination_explicative=1  if covid_outcome_a==0 & covid_first_injection_date==. & covid_vaccination==1
replace covid_vaccination_explicative=99 if covid_outcome_a==1 & (covid_test_positif_date2==.  & covid_test_positif_date=="") 
replace covid_vaccination_explicative=99 if covid_vaccination==. | covid_vaccination==88
	label variable covid_vaccination_explicative "Statut vaccinal au moment du dépistage ou si pas dépisté pos au moment de l'interview"
	order covid_vaccination_explicative, after(duration_vacci_infection)
	label define lbcovidvaccinationexplicative 0 "Not vaccinated at itw / testing" 1 "Vaccinated at itw / testing" 99 "Missing data"
	label values covid_vaccination_explicative lbcovidvaccinationexplicative 

	* CREATION VARIABLE VACCINATION BIS QUI CONSIDERE LES 43 "NE VEUT PAS REPONDRE" A LA QUESTION VACCINATION COVID-19 COMME NON-VACCINES 
	* Les 43 sujets présents dans Groupe 1 uniquement
	gen 			covid_vaccination_explicativebis =covid_vaccination_explicative
	replace 		covid_vaccination_explicativebis = 0 if covid_vaccination_explicative==99
	label variable  covid_vaccination_explicativebis "Statut vaccinal au moment de l'infection ou si pas infecte au moment de l'interview"
	order 			covid_vaccination_explicativebis, after(covid_vaccination_explicative)
	label values 	covid_vaccination_explicativebis lbcovidvaccinationexplicative 
		
*** SCHEMA VACCINAL COMPLET	
* 1/ VARIABLE STATUT VACCINAL A L'INTERVIEW (4 CLASSES)
gen covid_vaccination_complete = 0
	label define lbcovidvaccinationcomplete 0 "Not vaccinated" 1 "Uncompleted vaccination" 2 "Vaccinated, completeness unknown" 3 "Fully vaccinated" 99 "Missing data"
	label values covid_vaccination_complete lbcovidvaccinationcomplete 
	label variable covid_vaccination_complete "Vaccination status at time of interview"
	order covid_vaccination_complete, after (covid_second_injection_date)
	replace covid_vaccination_complete = 3 if covid_vaccination ==1 & covid_vaccination_name ==3 & (covid_first_injection_date <dofc(date_interview_step1) | covid_first_injection_date==.)
	replace covid_vaccination_complete = 3 if covid_vaccination ==1 & covid_vaccination_name !=3 & covid_second_injection_date !=. & covid_second_injection_date <dofc(date_interview_step1)
	replace covid_vaccination_complete = 2 if covid_vaccination ==1 & covid_vaccination_name !=3 & covid_first_injection_date ==.
	replace covid_vaccination_complete = 1 if covid_vaccination ==1 & covid_vaccination_name !=3 & covid_second_injection_date ==. & covid_first_injection_date !=. & covid_first_injection_date <dofc(date_interview_step1)
	replace covid_vaccination_complete = 1 if covid_vaccination ==1 & covid_vaccination_name !=3 & covid_second_injection_date !=. &  covid_second_injection_date >= dofc(date_interview_step1) 
	replace covid_vaccination_complete = 0 if covid_vaccination ==2 	
	replace covid_vaccination_complete = 99 if covid_vaccination ==88 | covid_vaccination ==99

* 2/ VARIABLE STATUT VACCINAL A L'INTERVIEW (3 CLASSES)	
gen 				covid_vaccination_complete2 = covid_vaccination_complete
	label define lbcovidvaccinationcomplete2 0 "Not vaccinated" 1 "Vaccinated, uncompleted or completeness unknown" 2 "Fully vaccinated" 99 "Missing data"
	recode 			covid_vaccination_complete2 (2=1) (3=2)
	order  			covid_vaccination_complete2, after (covid_vaccination_complete)
	label values 	covid_vaccination_complete2 lbcovidvaccinationcomplete2 
	label variable 	covid_vaccination_complete2 "Vaccination status at time of interview"

* 3/ VARIABLE STATUT VACCINAL A L'INTERVIEW (2 CLASSES)	
gen 				covid_vaccination_complete3 = covid_vaccination_complete
	label define lbcovidvaccinationcomplete3 0 "Not vaccinated" 1 "Vaccinated" 99 "Missing data"
	recode 			covid_vaccination_complete3 (2=1) (3=1)
	order  			covid_vaccination_complete3, after (covid_vaccination_complete2)
	label values 	covid_vaccination_complete3 lbcovidvaccinationcomplete3 
	label variable 	covid_vaccination_complete3 "Vaccination status at time of interview"
	
* 4/ VARIABLE VACCINE AVANT 2EME VAGUE (VAGUE DELTA)	
gen 		covid_vaccination_complete_delta = covid_vaccination_complete3
	replace covid_vaccination_complete_delta  = 0 if covid_vaccination_complete3==1 & covid_first_injection_date >=date("01July2021", "DMY") & covid_first_injection_date !=.
	replace covid_vaccination_complete_delta  =99 if covid_vaccination_complete3==1 & covid_first_injection_date ==.

	* 24 vaccinés sans date vacci
	order  			covid_vaccination_complete_delta, after (covid_vaccination_complete3)
	label values 	covid_vaccination_complete_delta lbbooleen
	label variable 	covid_vaccination_complete_delta "Vaccination status before start of delta wave (July 1st)"
		
* 4/ DATE UPDATE STATUT VACCINAL
gen date_covid_vaccination_complete = 0
	format date_covid_vaccination_complete  %td
	order date_covid_vaccination_complete, after(covid_vaccination_complete)
	label var date_covid_vaccination_complete "Date of vaccination status"
	replace date_covid_vaccination_complete = covid_second_injection_date if covid_vaccination_complete ==3 &  covid_vaccination_name !=3
	replace date_covid_vaccination_complete = covid_first_injection_date if covid_vaccination_complete ==3 & covid_vaccination_name ==3
	replace date_covid_vaccination_complete = covid_first_injection_date if covid_vaccination_complete == 1
	
* 5/ STATUT VACCINAL OU MOMENT DE L'INTERVIEW SI PERTINENT AU MOMENT DE L'INFECTION (4 CLASSES)
gen 				covid_vaccination_explicative2 =covid_vaccination_explicative
	label variable  covid_vaccination_explicative2 "Statut vaccinal au moment de l'infection ou si pas infecte au moment de l'interview (4 classes)"
	order 			covid_vaccination_explicative2, after(covid_vaccination_explicative)
	label values 	covid_vaccination_explicative2 lbcovidvaccinationcomplete 
	replace 		covid_vaccination_explicative2 =3 if covid_vaccination_explicative==1 & covid_vaccination_name ==3
	replace 		covid_vaccination_explicative2 =2 if covid_vaccination_explicative==1 & covid_vaccination_name ==99
	replace 		covid_vaccination_explicative2 =1 if covid_vaccination_explicative==1 & (covid_vaccination_name ==1 | covid_vaccination_name ==2) & covid_vaccination_complete ==1
	replace 		covid_vaccination_explicative2 =2 if covid_vaccination_explicative==1 & (covid_vaccination_name ==1 | covid_vaccination_name ==2) & covid_vaccination_complete ==2
	replace 		covid_vaccination_explicative2 =3 if covid_vaccination_explicative==1 & (covid_vaccination_name ==1 | covid_vaccination_name ==2) & covid_vaccination_complete ==3 & covid_outcome_a==0 
	replace 		covid_vaccination_explicative2 =3 if covid_vaccination_explicative==1 & (covid_vaccination_name ==1 | covid_vaccination_name ==2) & covid_vaccination_complete ==3 & covid_outcome_a==1 & covid_test_positif_date2 > date_covid_vaccination_complete
	replace 		covid_vaccination_explicative2 =1 if covid_vaccination_explicative==1 & (covid_vaccination_name ==1 | covid_vaccination_name ==2) & covid_vaccination_complete ==3 & covid_outcome_a==1 & covid_test_positif_date2 < date_covid_vaccination_complete  // pas d'occurence
	
	
************************************************************************
**# 		II. DESCRIPTION DU SOUS-ECHANTILLON VOLET COVID (N=1,148) **
************************************************************************
tab gender
tab archipelago gender, col

tab consent_read gender, chi2 row column exact
	bysort geo_strate : tab consent_read gender, chi2 row column exact
gen groupe1=1
	replace groupe1=0 if consent_read=="NA_STEP1;NA_STEP3;Yes_STEP6"
	tab groupe1 geo_strate,chi2 m col
	drop groupe1
	
sum age, d
tab age_cat gender, chi2 col 

tab civil_state2 gender, m col
tab civil_state3 gender, m col
tab civil_state4 gender, m col

tab max_school2 gender, m chi2 col

tab socio_cultural gender,m  col

tab pro_act_last_year2 gender,m chi2 col

bysort 	mois_interview_step1 :  tab archipelago covid_outcome_b if covid_outcome_b !=99, row chi2
tab mois_interview_step1 covid_outcome_b if covid_outcome_b !=99 & (mois_interview_step1 ==4 | mois_interview_step1 ==5), row chi2 exp
tab mois_interview_step1 covid_outcome_b if covid_outcome_b !=99 & (mois_interview_step1 ==6 | mois_interview_step1 ==5), row chi2 exp
tab mois_interview_step1 covid_outcome_b if covid_outcome_b !=99 & (mois_interview_step1 ==6 | mois_interview_step1 ==7), row chi2 exp
tab mois_interview_step1 covid_outcome_b if covid_outcome_b !=99 & (mois_interview_step1 ==7 | mois_interview_step1 ==10), row chi2 exp
tab mois_interview_step1 covid_outcome_b if covid_outcome_b !=99 & (mois_interview_step1 ==10 | mois_interview_step1 ==11), row chi2 exp
tab mois_interview_step1 covid_outcome_b if covid_outcome_b !=99 & (mois_interview_step1 ==11 | mois_interview_step1 ==12), row chi2 exp exact
	
tab mois_interview_step1 covid_outcome_b if covid_outcome_b !=99 & (mois_interview_step1 ==4 | mois_interview_step1 ==5 | mois_interview_step1 ==6 ), row chi2 exp
	
	
**********************************************************************
**# 		II. DEFINITION DU PLAN D'ECHANTILLONAGE	 				**
**********************************************************************

// tirage ausort des participants après stratification par archipel.
// Correction age et genre en post-stratification
svyset [pweight=weighting], strata(archipelago)
		

**************************************************************************
**# III. ANALYSE UNIVARIEE OUTCOME COVID A (ANTI-S WANTAI ET DECLARATIF)	**
**************************************************************************
	
*hist mois_interview_step1 if covid_outcome_a==1, width(1) xtitle("mois d'interview") xmtick(#1) xlabel(,labsize(small)) freq title("{bf:Nombre de cas de COVID-19 par mois d'interview}",size(medium) ) 

* COVID ET MOIS DE L'ITW
*tab mois_interview_step1 covid_outcome_a,expected row chi2 exact
bysort group_date_itw1 : tab mois_interview_step1 covid_outcome_a,expected row chi2 exact
		char mois_interview_step1[omit] "4"
xi: logistic covid_outcome_a i.mois_interview_step1 if group_date_itw1==1
		char mois_interview_step1[omit] "7"
xi: logistic covid_outcome_a i.mois_interview_step1 if group_date_itw1==2
	
* COVID ET GENRE
bysort group_date_itw1 : tab gender covid_outcome_a,expected row chi2
bysort group_date_itw1 : logistic covid_outcome_a ib2.gender 

* COVID ET AGE
bysort group_date_itw1 : tab age_cat covid_outcome_a,expected row chi2
xi: logistic covid_outcome_a i.age_cat if group_date_itw1==1
xi: logistic covid_outcome_a i.age_cat if group_date_itw1==2

* COVID ET LANGUE MATERNELLE
bysort group_date_itw1 : tab native_language2 covid_outcome_a, row chi2
	char native_language2[omit] "2"
xi: logistic covid_outcome_a i.native_language2 if group_date_itw1==1
xi: logistic covid_outcome_a i.native_language2 if group_date_itw1==2
testparm _Inative_la_1 _Inative_la_5	// p=0.51

* COVID ET ARCHIPEL
bysort group_date_itw1 : tab archipelago covid_outcome_a,expected row chi2 exact
	*char archipelago[omit] "1"
	char archipelago[omit] "2"
xi: logistic covid_outcome_a i.archipelago if group_date_itw1==1

* ILE DE RESIDENCE
bysort group_date_itw1 : tab island  covid_outcome_a, row chi2 
	char island[omit] "3"
xi : firthlogit covid_outcome_a i.island if group_date_itw1==1, or
	char island[omit] "1"
xi : logistic covid_outcome_a i.island if group_date_itw1==2

* VILLAGE DE RESIDENCE
tab town_name covid_outcome_a if group_date_itw1==2, row expected chi2 
	char town_name[omit] "PAPEETE"
xi : logistic covid_outcome_a i.town_name if group_date_itw1==2

tab town_classif_1 covid_outcome_a if group_date_itw1==2, row expected chi2 
	char town_classif_1[omit] "zone urbaine"
xi : logistic covid_outcome_a i.town_classif_1 if group_date_itw1==2

tab town_classif_2 covid_outcome_a if group_date_itw1==2, row expected chi2 
	char town_classif_2[omit] "Eau potable sur tout le territoire"
xi : logistic covid_outcome_a i.town_classif_2 if group_date_itw1==2

tab town_classif_3 covid_outcome_a if group_date_itw1==2, row expected chi2 
	char town_classif_3[omit] "Classes 2 et 3"
xi : logistic covid_outcome_a i.town_classif_3 if group_date_itw1==2

* COVID ET NIVEAU D'ETUDE
bysort group_date_itw1 : tab max_school2 covid_outcome_a,expected row chi2
	char max_school2[omit] "3"
xi: firthlogit covid_outcome_a i.max_school2  if group_date_itw1==1,or
xi: logistic covid_outcome_a i.max_school2  if group_date_itw1==2

* COVID ET ETAT CIVIL
bysort group_date_itw1 : tab civil_state3 covid_outcome_a,expected row chi2 exact
	char civil_state3[omit] "2"
xi: firthlogit covid_outcome_a i.civil_state3 if group_date_itw1==1, or
xi: firthlogit covid_outcome_a i.civil_state3 if group_date_itw1==2, or

* COVID ET CATEGORIE PROFESSIONNELLE
  ** avec variable découpée en en 4 classes
bysort group_date_itw1 :tab pro_act_last_year2 covid_outcome_a,expected row chi2 
	char pro_act_last_year2[omit] "2"
xi: logistic covid_outcome_a i.pro_act_last_year2 if group_date_itw1==1
xi: logistic covid_outcome_a i.pro_act_last_year2 if group_date_itw1==2

* COVID ET NOMBRE DE INDIVIDUS MAJEURS DANS LA MAISON
bysort group_date_itw1 : tab nhouse_classif covid_outcome_a,expected row chi2 exact
		char nhouse_classif[omit] "2"
xi : logistic covid_outcome_a i.nhouse_classif if group_date_itw1==1
xi : logistic covid_outcome_a i.nhouse_classif if group_date_itw1==2

* COVID ET NOMBRE TOTAL DE PERSONNES DANS LE FOYER
bysort group_date_itw1 : tab nhouse_tot_classif covid_outcome_a,expected row chi2 exact
			char nhouse_tot_classif[omit] "4"
xi : logistic covid_outcome_a i.nhouse_tot_classif if group_date_itw1==1
xi : logistic covid_outcome_a i.nhouse_tot_classif if group_date_itw1==2

	*avec 3 classes
	bysort group_date_itw1 : tab nhouse_tot_classif2 covid_outcome_a,expected row chi2 exact
				char nhouse_tot_classif2[omit] "2"
	xi : logistic covid_outcome_a i.nhouse_tot_classif2 if group_date_itw1==1
	xi : logistic covid_outcome_a i.nhouse_tot_classif2 if group_date_itw1==2
	
	*avec 4 classes
	bysort group_date_itw1 : tab nhouse_tot_classif3 covid_outcome_a,expected row chi2 exact
				char nhouse_tot_classif3[omit] "2"
	xi : logistic covid_outcome_a i.nhouse_tot_classif3 if group_date_itw1==1
	xi : logistic covid_outcome_a i.nhouse_tot_classif3 if group_date_itw1==2
	
	
* COVID ET TYPES DE MAISONS
bysort group_date_itw1 : tab house_type covid_outcome_a,expected row chi2 exact
	char house_type[omit] "1"
	xi: logistic covid_outcome_a i.house_type

bysort group_date_itw1 : tab house_clim covid_outcome_a,expected row chi2 exact
	xi: logistic covid_outcome_a i.house_clim  if group_date_itw1==1
	xi: logistic covid_outcome_a i.house_clim  if group_date_itw1==2

bysort group_date_itw1 : tab house_clean_water covid_outcome_a,expected row chi2 exact
		char house_clean_water[omit] "1"
	xi: logistic covid_outcome_a i.house_clean_water  if group_date_itw1==1
	xi: logistic covid_outcome_a i.house_clean_water  if group_date_itw1==2

bysort group_date_itw1 : tab mosquito_bites covid_outcome_a,expected row chi2 exact
	char mosquito_bites[omit] "4"
	xi: firthlogit covid_outcome_a i.mosquito_bites if group_date_itw1==1, or
	xi: logistic covid_outcome_a i.mosquito_bites if group_date_itw1==2

* COVID ET OBESITE
* IMC / OBESITE - 6 CLASSES
bysort group_date_itw1 : tab obesity_classif_who covid_outcome_a,expected row chi2 exact
	char obesity_classif_who[omit] "2"
xi: firthlogit covid_outcome_a i.obesity_classif_who if group_date_itw1==1,or
xi: logistic covid_outcome_a i.obesity_classif_who if group_date_itw1==2

* IMC / OBESITE - 3 CLASSES
bysort group_date_itw1 : tab obesity_classif_who3 covid_outcome_a,expected row chi2
xi: firthlogit covid_outcome_a i.obesity_classif_who3 if group_date_itw1==1, or
xi: logistic covid_outcome_a i.obesity_classif_who3 if group_date_itw1==2

* IMC / OBESITE - 2 CLASSES
bysort group_date_itw1 : tab obesity_who_bool covid_outcome_a,expected row chi2
xi: firthlogit covid_outcome_a i.obesity_who_bool if group_date_itw1==1, or
xi: logistic covid_outcome_a i.obesity_who_bool if group_date_itw1==2

* HTA
bysort group_date_itw1 : tab hypertension_bool covid_outcome_a,expected row chi2 
	xi: logistic covid_outcome_a i.hypertension_bool if group_date_itw1==1
	xi: firthlogit covid_outcome_a i.hypertension_bool if group_date_itw1==2, or
	
* DIABETE
bysort group_date_itw1 : tab diabete_bool covid_outcome_a,expected row chi2 exact
	xi: firthlogit covid_outcome_a i.diabete_bool if group_date_itw1==1, or
	xi: logistic covid_outcome_a i.diabete_bool if group_date_itw1==2

* ALLERGIES RESPIRATOIRES
bysort group_date_itw1 : tab respi_allergy_medical covid_outcome_a,expected row chi2 exact
	char respi_allergy_medical[omit] "2"
xi: firthlogit covid_outcome_a i.respi_allergy_medical if group_date_itw1==1, or
xi: logistic covid_outcome_a i.respi_allergy_medical if group_date_itw1==2

* ALLERGIES ALIMENTAIRE
bysort group_date_itw1 : tab alim_allergy_medical covid_outcome_a if alim_allergy_medical !=77,expected row chi2 exact
	char alim_allergy_medical[omit] "2"
xi: logistic covid_outcome_a i.alim_allergy_medical if group_date_itw1==1
xi: logistic covid_outcome_a i.alim_allergy_medical if group_date_itw1==2

* ALLERGIES CUTANEES
bysort group_date_itw1 : tab skin_allergy_medical covid_outcome_a if skin_allergy_medical !=77,expected row chi2 exact
	char skin_allergy_medical[omit] "2"
xi: logistic covid_outcome_a i.skin_allergy_medical if group_date_itw1==1
xi: logistic covid_outcome_a i.skin_allergy_medical if group_date_itw1==2

* ASTHME
bysort group_date_itw1 : tab asthma_medical covid_outcome_a,expected row chi2 
	char asthma_medical[omit] "2"
xi: firthlogit covid_outcome_a i.asthma_medical if group_date_itw1==1, or
xi: firthlogit covid_outcome_a i.asthma_medical if group_date_itw1==2, or

* RESPIRATION SIFFLANTE
bysort group_date_itw1 : tab  hissing_respi_last_year covid_outcome_a if hissing_respi_last_year !="Dont know",expected row chi2 
	char hissing_respi_last_year[omit] "No"
xi: logistic covid_outcome_a i.hissing_respi_last_year if group_date_itw1==1
xi: logistic covid_outcome_a i.hissing_respi_last_year if group_date_itw1==2
* p= 0.50 / 0.55

* ALD
bysort group_date_itw1 : tab chronic_ald covid_outcome_a,expected row chi2
xi: logistic covid_outcome_a i.chronic_ald if group_date_itw1==1
xi: logistic covid_outcome_a i.chronic_ald if group_date_itw1==2
*p= 0.75 / 0.55
	
* CANCER
bysort group_date_itw1 : tab cancer_or_malignant_tumor_medica covid_outcome_a,expected row chi2 exact
	
	char cancer_or_malignant_tumor_medica[omit] 2
xi : firthlogit covid_outcome_a i.cancer_or_malignant_tumor_medica if group_date_itw1==1, or
xi: logistic covid_outcome_a i.cancer_or_malignant_tumor_medica if group_date_itw1==2

* ACTIVITE PHYSIQUE
bysort group_date_itw1 : tab phys_act_level covid_outcome_a,expected row chi2 exact
xi: logistic covid_outcome_a i.phys_act_level if group_date_itw1==1
xi: logistic covid_outcome_a i.phys_act_level if group_date_itw1==2

* ALCOOL
bysort group_date_itw1 : tab alcool_30d_bool covid_outcome_a,expected row chi2 
	xi: logistic covid_outcome_a i.alcool_30d_bool if group_date_itw1==1
	xi: logistic covid_outcome_a i.alcool_30d_bool if group_date_itw1==2

* TABAC
bysort group_date_itw1 : tab smoking_prst covid_outcome_a,expected row chi2 exact
	*xi : logistic covid_outcome_a ib2.smoking_prst i.age_cat
	bysort group_date_itw1 : logistic covid_outcome_a ib2.smoking_prst

bysort group_date_itw1 : tab smoking_classif covid_outcome_a,expected row chi2 exact
bysort group_date_itw1 : logistic covid_outcome_a ib0.smoking_classif

bysort group_date_itw1 : tab smoking_everyday_bool covid_outcome_a,expected row chi2 
bysort group_date_itw1 : logistic covid_outcome_a ib0.smoking_everyday_bool

bysort group_date_itw1 : tab ntabaco_per_day_equ_class covid_outcome_a,expected row chi2 exact
bysort group_date_itw1 : logistic covid_outcome_a ib0.ntabaco_per_day_equ_class

* PAKA
bysort group_date_itw1 : tab paka_weekly_bool  covid_outcome_a, row chi2
	*p=0.31 & 0.54
bysort group_date_itw1 : logistic covid_outcome_a ib2.paka_weekly_bool 

* COVID & HYGIENE ALIMENTAIRE
bysort group_date_itw1 : tab reco_fruit_vege covid_outcome_a,expected row chi2 exact
bysort group_date_itw1 : logistic covid_outcome_a ib0.reco_fruit_vege
	*p=0.56 & 0.98

* GESTES BARRIERES
bysort group_date_itw1 : tab covid_behavior_hand_washing 	covid_outcome_a,expected row chi2 exact
bysort group_date_itw1 : tab covid_behavior_hand_shaking 	covid_outcome_a,expected row chi2 exact
bysort group_date_itw1 : tab covid_behavior_cough_elbow 	covid_outcome_a,expected row chi2 exact
bysort group_date_itw1 : tab covid_behavior_safety_distance covid_outcome_a,expected row chi2 exact
bysort group_date_itw1 : tab covid_behavior_mask 			covid_outcome_a,expected row chi2 exact

logistic covid_outcome_a covid_behavior_hand_washing 	if group_date_itw1==1
logistic covid_outcome_a covid_behavior_hand_shaking 	if group_date_itw1==1
logistic covid_outcome_a covid_behavior_cough_elbow 		if group_date_itw1==1
logistic covid_outcome_a covid_behavior_safety_distance  if group_date_itw1==1
logistic covid_outcome_a covid_behavior_mask 			if group_date_itw1==1
	
xi: firthlogit covid_outcome_a i.covid_behavior_hand_washing 	if group_date_itw1==2, or
xi: firthlogit covid_outcome_a i.covid_behavior_hand_shaking 	if group_date_itw1==2, or
xi: firthlogit covid_outcome_a i.covid_behavior_cough_elbow 		if group_date_itw1==2, or
xi: firthlogit covid_outcome_a i.covid_behavior_safety_distance  if group_date_itw1==2, or
xi: firthlogit covid_outcome_a i.covid_behavior_mask 			if group_date_itw1==2, or

	
* VACCINATION - 3 CLASSES (VACCINE / NON VACCINE / manqants)
bysort group_date_itw1 : tab covid_vaccination_explicative covid_outcome_a,expected row chi2 exact
xi : firthlogit covid_outcome_a i.covid_vaccination_explicative  if group_date_itw1==1 ,or
xi : logistic   covid_outcome_a i.covid_vaccination_explicative  if group_date_itw1==2

* VACCINATION - 2 CLASSES (VACCINE / NON VACCINE)
bysort group_date_itw1 : tab covid_vaccination_explicativebis covid_outcome_a,expected row chi2 exact
xi : firthlogit covid_outcome_a i.covid_vaccination_explicativebis  if group_date_itw1==1 ,or
xi : logistic   covid_outcome_a i.covid_vaccination_explicativebis  if group_date_itw1==2

	
******************************************************************************
**# IV. ANALYSE MULTIVARIEE OUTCOME COVID A (ANTI-S WANTAI ET DECLARATIF)	**
******************************************************************************

*---------------------------------------------------------------------
**# 4.1. Analyse Multivariée sur la 1ère période : Avril à Juin 2021 |
*---------------------------------------------------------------------
// 4.1.1 Stratégie sélection descendante (backward selection) - Periode 1
		char mois_interview_step1[omit] "4"
		char gender[omit] "2"
		char archipelago[omit] "2"

xi: firthlogit covid_outcome_a i.mois_interview_step1 i.gender i.native_language2 i.archipelago i.house_clim alcool_30d_bool smoking_everyday_bool i.covid_vaccination_explicative if group_date_itw1==1, or
	testparm _Imois*						/* p=0.33		*/
	testparm _Igender*						/* p=0.15 		*/
	testparm _Inative*						/* p=0.77		*/	
	testparm _Iarchip*						/* p=0.56		*/
	testparm _Ihouse_cli*					/* p=0.037		*/
	testparm alcool_30d_bool				/* p=0.35		*/
	testparm smoking_everyday_bool			/* p=0.43		*/
	testparm _Icovid_vac*					/* p=0.036		*/
/* Native language (native_language2) variable moins significative (p=0.77)	*/

xi: firthlogit covid_outcome_a i.mois_interview_step1 i.gender i.archipelago i.house_clim alcool_30d_bool smoking_everyday_bool i.covid_vaccination_explicative if group_date_itw1==1, or
	testparm _Imois*						/* p=0.36		*/
	testparm _Igender*						/* p=0.14 		*/
	testparm _Iarchip*						/* p=0.31		*/
	testparm _Ihouse_cli*					/* p=0.027		*/
	testparm alcool_30d_bool				/* p=0.40		*/
	testparm smoking_everyday_bool			/* p=0.46		*/
	testparm _Icovid_vac*					/* p=0.036		*/
/* Fumeur quotidien (smoking_everyday_bool) variable moins significative (p=0.46)	*/
	
xi: firthlogit covid_outcome_a i.mois_interview_step1 i.gender i.archipelago i.house_clim alcool_30d_bool i.covid_vaccination_explicative if group_date_itw1==1, or
	testparm _Imois*						/* p=0.37		*/
	testparm _Igender*						/* p=0.13 		*/
	testparm _Iarchip*						/* p=0.25		*/
	testparm _Ihouse_cli*					/* p=0.017		*/
	testparm alcool_30d_bool				/* p=0.34		*/
	testparm _Icovid_vac*					/* p=0.037		*/
/* Mois d'interview (mois_interview_step1) variable moins significative (p=0.37)	*/
	
xi: firthlogit covid_outcome_a i.gender i.archipelago i.house_clim alcool_30d_bool i.covid_vaccination_explicative if group_date_itw1==1, or
	testparm _Igender*						/* p=0.086 		*/
	testparm _Iarchip*						/* p=0.13		*/
	testparm _Ihouse_cli*					/* p=0.005		*/
	testparm alcool_30d_bool				/* p=0.32		*/
	testparm _Icovid_vac*					/* p=0.034		*/
/* Consommation d'alcool dans les 30 derniers jours (alcool_30d_bool) variable moins significative (p=0.32)	*/
	
xi: firthlogit covid_outcome_a i.gender i.archipelago i.house_clim i.covid_vaccination_explicative if group_date_itw1==1, or
	testparm _Igender*						/* p=0.051 		*/
	testparm _Iarchip*						/* p=0.092		*/
	testparm _Ihouse_cli*					/* p=0.006		*/
	testparm _Icovid_vac*					/* p=0.037		*/
/* Archipel de résidence (archipelago) variable moins significative (p=0.092)	*/	
	
xi: firthlogit covid_outcome_a i.gender i.house_clim i.covid_vaccination_explicative if group_date_itw1==1, or
	testparm _Igender*						/* p=0.047 		*/
	testparm _Ihouse_cli*					/* p=0.010		*/
	testparm _Icovid_vac*					/* p=0.024		*/
/* Toutes les variables significatives 
--------------------------------------------------------------------------------
    covid_outcome_a | Odds ratio   Std. err.      z    P>|z|     [95% conf. interval]
---------------+----------------------------------------------------------------
    _Igender_1 |    .456139   .1798219    -1.99   0.046     .2106353    .9877865
 _Ihouse_cli_2 |   4.886102   3.007595     2.58   0.010     1.462222     16.3272
 _Icovid_vac_1 |   .0203042   .0291403    -2.72   0.007     .0012189     .338236
_Icovid_vac_99 |     .78474   .4674341    -0.41   0.684     .2441764    2.522017
         _cons |   .1500406   .0351735    -8.09   0.000     .0947686    .2375489
--------------------------------------------------------------------------------*/	


// 4.1.2. Stratégie sélection ascendante (forward selection) - Periode 1
//----------------------------------------------------------
xi: firthlogit covid_outcome_a i.covid_vaccination_explicative if group_date_itw1==1, or
	testparm _Icovid_vac*					/* p=0.049		*/

xi: firthlogit covid_outcome_a i.covid_vaccination_explicative i.archipelago if group_date_itw1==1, or
	testparm _Icovid_vac*					/* p=0.045		*/
	testparm _Iarchi*						/* p=0.11		*/

*	test avec "distance de sécurité"
xi: firthlogit covid_outcome_a i.covid_vaccination_explicative i.archipelago covid_behavior_safety_distance if group_date_itw1==1, or
	testparm _Icovid_vac*					/* p=0.045		*/
	testparm _Iarchi*						/* p=0.20		*/
	testparm covid_behavior_safety_distance	/* p=0.26		*/
	* distance de sécu pas retenue
	
// 2eme variable vaccination (sans données manquantes)
xi: firthlogit covid_outcome_a i.covid_vaccination_explicativebis if group_date_itw1==1, or
	testparm _Icovid_vac*					/* p=0.010		*/

xi: firthlogit covid_outcome_a i.covid_vaccination_explicativebis i.archipelago if group_date_itw1==1, or
	testparm _Icovid_vac*					/* p=0.014		*/
	testparm _Iarchi*						/* p=0.081		*/

*	test avec "distance de sécurité"
xi: firthlogit covid_outcome_a i.covid_vaccination_explicativebis i.archipelago covid_behavior_safety_distance if group_date_itw1==1, or
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
   covid_outcome_a | Odds ratio   Std. err.      z    P>|z|     [95% conf. interval]
--------------+----------------------------------------------------------------
_Icovid_vac_1 |   .0293649   .0421003    -2.46   0.014     .0017679    .4877419
_Iarchipela_1 |   .4504027   .2405362    -1.49   0.135     .1581319     1.28287
_Iarchipela_2 |   .3201377   .1527821    -2.39   0.017      .125635    .8157613
_Iarchipela_3 |          1  (omitted)
_Iarchipela_5 |   .4469858   .2151031    -1.67   0.094     .1740483    1.147936
        _cons |   .2282498   .0664278    -5.08   0.000     .1290281    .4037725
------------------------------------------------------------------------------- */

	

*---------------------------------------------------------------------------		
**# 4.2. Analyse Multivariée sur la 2ème période : Juillet à Décembre 2021 |
*---------------------------------------------------------------------------
**# 4.2.A/ METHODE REGRESSION LOGISTIQUE (firthlogit) descendante (manuelle)
* (pour rappel 'langue maternelle' pas retenue car non significative sans 'autres')
* avec classification des communes (rural / urbain)
	char mois_interview_step1[omit] "10"
	char gender[omit] "2"
	char town_classif_1[omit] "zone urbaine"
	char pro_act_last_year2[omit] "2"	
	char nhouse_tot_classif3[omit] "2"

* #1
xi: firthlogit covid_outcome_a i.mois_interview_step1 i.gender i.age_cat i.town_classif_1 i.pro_act_last_year2 i.nhouse_tot_classif3 i.house_clean_water i.mosquito_bites i.obesity_who_bool i.hypertension_bool cancer_or_malignant_tumor_medica i.covid_behavior_mask i.covid_vaccination_explicative if group_date_itw1==2, or
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
xi: firthlogit covid_outcome_a i.mois_interview_step1 i.age_cat i.town_classif_1 i.pro_act_last_year2 i.nhouse_tot_classif3 i.house_clean_water i.mosquito_bites i.obesity_who_bool i.hypertension_bool cancer_or_malignant_tumor_medica i.covid_behavior_mask i.covid_vaccination_explicative if group_date_itw1==2, or
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
xi: firthlogit covid_outcome_a i.mois_interview_step1 i.age_cat i.pro_act_last_year2 i.nhouse_tot_classif3 i.house_clean_water i.mosquito_bites i.obesity_who_bool i.hypertension_bool cancer_or_malignant_tumor_medica i.covid_behavior_mask i.covid_vaccination_explicative if group_date_itw1==2, or
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
xi: firthlogit covid_outcome_a i.mois_interview_step1 i.pro_act_last_year2 i.nhouse_tot_classif3 i.house_clean_water i.mosquito_bites i.obesity_who_bool i.hypertension_bool cancer_or_malignant_tumor_medica i.covid_behavior_mask i.covid_vaccination_explicative if group_date_itw1==2, or
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
xi: firthlogit covid_outcome_a i.mois_interview_step1 i.pro_act_last_year2 i.nhouse_tot_classif3 i.house_clean_water i.mosquito_bites i.obesity_who_bool  cancer_or_malignant_tumor_medica  i.covid_behavior_mask i.covid_vaccination_explicative if group_date_itw1==2, or
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
xi: firthlogit covid_outcome_a i.mois_interview_step1 i.pro_act_last_year2 i.nhouse_tot_classif3 i.house_clean_water i.mosquito_bites i.obesity_who_bool i.covid_behavior_mask  i.covid_vaccination_explicative if group_date_itw1==2, or
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
xi: firthlogit covid_outcome_a i.mois_interview_step1 i.pro_act_last_year2 i.nhouse_tot_classif3 i.mosquito_bites i.obesity_who_bool i.covid_behavior_mask i.covid_vaccination_explicative if group_date_itw1==2, or
	testparm _Imois_inte*		/* p<0.001	*/
	testparm _Ipro_act*			/* p=0.006	*/
	testparm _Inhouse_to*		/* p=0.020	*/
	testparm _Imosquito*		/* p=0.17	*/
	testparm _Iobesity*			/* p=0.21	*/
	testparm _Icovid_beh*		/* p=0.13	*/
	testparm _Icovid_vac*		/* p<0.001	*/
/* Obésité (obesity_who_bool) variable moins significative (p=0.21)	*/	

* #8
xi: firthlogit covid_outcome_a i.mois_interview_step1 i.pro_act_last_year2 i.nhouse_tot_classif3 i.mosquito_bites i.covid_behavior_mask i.covid_vaccination_explicative if group_date_itw1==2, or
	testparm _Imois_inte*		/* p<0.001	*/
	testparm _Ipro_act*			/* p=0.009	*/
	testparm _Inhouse_to*		/* p=0.020	*/
	testparm _Imosquito*		/* p=0.23	*/
	testparm _Icovid_beh*		/* p=0.11	*/
	testparm _Icovid_vac*		/* p<0.001	*/
/* Fréquence des piqures de moustique (mosquito_bites) variable moins significative (p=0.23)	*/	

* #9
xi: firthlogit covid_outcome_a i.mois_interview_step1 i.pro_act_last_year2 i.nhouse_tot_classif3 i.covid_behavior_mask i.covid_vaccination_explicative if group_date_itw1==2, or
	testparm _Imois_inte*		/* p<0.001	*/
	testparm _Ipro_act*			/* p=0.009	*/
	testparm _Inhouse_to*		/* p=0.027	*/
	testparm _Icovid_beh*		/* p=0.17	*/
	testparm _Icovid_vac*		/* p<0.001	*/
/* Geste barrière / masque (covid_behavior_mask) variable moins significative (p=0.17)	*/	

* #10, logistic peut être utilisé
xi: logistic covid_outcome_a i.mois_interview_step1 i.pro_act_last_year2 i.nhouse_tot_classif3 i.covid_vaccination_explicative if group_date_itw1==2
	testparm _Imois_inte*		/* p<0.001	*/
	testparm _Ipro_act*			/* p=0.006	*/
	testparm _Inhouse_to*		/* p=0.022	*/
	testparm _Icovid_vac*		/* p<0.001	*/	
/*Logistic regression                                     Number of obs =    652
                                                        LR chi2(10)   = 465.00
                                                        Prob > chi2   = 0.0000
Log likelihood = -210.11061                             Pseudo R2     = 0.5253

--------------------------------------------------------------------------------
    covid_outcome_a | Odds ratio   Std. err.      z    P>|z|     [95% conf. interval]
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


**# 4.2.B/ METHODE REGRESSION LOGISTIQUE (firthlogit) descendante (manuelle) - Periode 2 
* PAS REFAITE AVEC VARIABLE GESTE BARRIERE covid_behavior_mask
* pour rappel 'langue maternelle' pas retenue car non significative sans 'autres'
* Variable de commune (town_classif_1), non retenue car association mois / commune trop fort due au séquençage
xi: firthlogit covid_outcome_a i.mois_interview_step1 i.gender i.age_cat i.pro_act_last_year2 i.nhouse_tot_classif3 i.house_clean_water i.mosquito_bites i.obesity_who_bool i.hypertension_bool cancer_or_malignant_tumor_medica i.covid_vaccination_explicative if group_date_itw1==2, or
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

xi: firthlogit covid_outcome_a i.mois_interview_step1 i.age_cat i.pro_act_last_year2 i.nhouse_tot_classif3 i.house_clean_water i.mosquito_bites i.obesity_who_bool i.hypertension_bool cancer_or_malignant_tumor_medica i.covid_vaccination_explicative if group_date_itw1==2, or
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
	
xi: firthlogit covid_outcome_a i.mois_interview_step1 i.pro_act_last_year2 i.nhouse_tot_classif3 i.house_clean_water i.mosquito_bites i.obesity_who_bool i.hypertension_bool cancer_or_malignant_tumor_medica i.covid_vaccination_explicative if group_date_itw1==2, or
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


********************************************************************************
**# V. ANALYSE UNIVARIEE OUTCOME COVID B (Ac anti-N LUMINEX) DANS ECHANTILLON **
********************************************************************************
	
char gender[omit] "2"
char age_cat[omit] "2"
char native_language2[omit] "2"
char socio_cultural[omit]"1"
char max_school2 [omit] "3"
char pro_act_last_year2[omit] "2"
char pro_act_last_year3[omit] "2"
char birth_location[omit] "987"
char civil_state4[omit] "2"
char age_first_sex_cat [omit] "2"
char nhouse_classif[omit] "2"
char nhouse_tot_classif[omit] "4"
char nhouse_tot_classif2[omit] "2"
char nhouse_tot_classif3[omit] "2"
char house_type[omit] "1"
char house_clean_water[omit] "1"
char house_clim[omit] "1"
char health_status2[omit] "2"
char mosquito_bites[omit] "4"
char obesity_classif_who[omit] "2"
char respi_allergy_medical[omit] "2"
char asthma_medical[omit] "2"
char chronic_ald[omit] "2"
char cancer_or_malignant_tumor_medica[omit] "2"
char phys_act_level[omit] "2"
char smoking_prst[omit] "2"
char covid_test_positif[omit] "2"

char town_name[omit] "PAPEETE"
char town_classif_1[omit] "zone urbaine"
char town_classif_2[omit] "Eau potable sur tout le territoire"
char town_classif_3[omit] "Classes 2 et 3"

capture drop tp_*

gen tp_a_var		=""
gen tp_a_var_lb		=""
gen tp_a_modalite	=""
gen tp_a_modalite_lb=""
gen tp_a_nmod		=.
gen tp_a_npos 		=.
gen tp_a_posperc 	=.
gen tp_a_pos_final	=""
gen tp_a_pval		=.
gen tp_a_methode	=""
gen tp_a_check_or	=""
gen tp_a_or			=.
gen tp_a_ormin		=.
gen tp_a_ormax		=.
gen tp_a_or_final	=""

// Definir la selection de données (outcome non manquant et 2nde période)
capture drop selection
gen selection = 0

replace selection = 1 if  group_date_itw1==2 & covid_outcome_b !=99
	char mois_interview_step1[omit] "7"
	char archipelago[omit] "1"
	char island[omit]"1"

*replace selection = 1 if  group_date_itw1==1 & covid_outcome_b !=99
*	char mois_interview_step1[omit] "4"
*	char archipelago[omit] "2"
*	char island[omit]"3"
	
local varlist mois_interview_step1 gender age_cat native_language2 socio_cultural archipelago island max_school2 civil_state4 pro_act_last_year3 nhouse_tot_classif2 nhouse_tot_classif3 house_type house_clim house_clean_water mosquito_bites obesity_classif_who obesity_classif_who3 obesity_who_bool hypertension_bool diabete_bool respi_allergy_medical asthma_medical chronic_ald cancer_or_malignant_tumor_medica phys_act_level smoking_prst smoking_everyday_bool covid_behavior_hand_washing covid_behavior_hand_shaking covid_behavior_cough_elbow covid_behavior_safety_distance covid_behavior_mask covid_vaccination_explicative covid_vaccination_explicativebis covid_vaccination_complete covid_vaccination_complete2 covid_vaccination_complete3 covid_vaccination_complete_delta covid_test_positif town_name town_classif_1  town_classif_2 town_classif_3


* pro_act_last_year2 nhouse_classif

browse tp_*
local ligne	2	
// références spécifiques à la 2nde période


foreach var in `varlist' {
	display ""
	display "*****************************"
	display "Association Infection COVID-19 avec `var'"	
	quietly tab `var' covid_outcome_b if selection ==1, matcell(tableau)
		local effectif_tot=r(N)
	quietly levelsof `var' if selection ==1, local(mod_var) // modalités de la variable explicative stockées dans la macro locale mod_var
		local nb_mod_var = r(r)							 		// nbre de modalités stocké ds la macro locale nb_mod_var	
	quietly estpost tab `var' covid_outcome_b if selection ==1
		matrix effectifs =e(b)		

/* p-value finalement extraites des reg log et non plus du Chi2
	{	// Calcul des p-values par Chi2 de Pearson ou Fisher exact : 
		//tous les expected sont ils supérieurs à 5? (si oui Fisher = 0, sinon Fisher =1)
		quietly estpost tab `var' covid_outcome_b if selection ==1
			matrix pourcent  =e(pct)	
			matrix effectifs =e(b)
		local fisher 0
		forvalues i = 1 / 2 { 	// boucle qui renvoie fisher =0 si tous les expected > 5
			forvalues j = 1 / `nb_mod_var' {
				local expect = pourcent[1,`i' * (`nb_mod_var'+1)] * pourcent[1,2 *(`nb_mod_var'+1)+`j'] * `effectif_tot'/10000
				if `expect' <=5 {
					local fisher 1
				}	
			}
		}
			
		if `fisher'==0 {		// Calcul p-value Chi2 Pearson
			display "`var' vs covid_outcome_b tous les effectifs expected supérieurs à 5"
			tab `var' covid_outcome_b if selection ==1,  chi2 expected
			replace tp_a_pval=r(p) if _n==`ligne'
		}
		else {					// Calcul p-value de Fisher exact
			display "`var' vs covid_outcome_b test fisher exactnécessaire"
			tab `var' covid_outcome_b if selection ==1,  chi2 expected exact
			replace tp_a_pval=r(p_exact) if _n==`ligne'
		}
	}	
*/	

	{	// Régression logistique (utilisation de firthlogit si un effetif nul) - stockage des résultats dans Matric or
		// Y a t'il un effectif nul ? un effectif nul conduirait à utiliser 'firthlogit' à la place de 'logistic'
		// Calcul du produit des effectifs ; une seule valeure nulle conduira à un produit nul
		local produit 1
		forvalues j=1/2{	// calcul du produit des effectifs par itération
			forvalues i=1/`nb_mod_var' {	
				local produit = `produit' * tableau[`i',`j']
			}
		}
		if 	`produit' ==0 {							// si au moins un effectif nul, usage de firthlogit
			display "Au moins un effectif nul : Usage de FIRTHLOGIT"
			xi: firthlogit covid_outcome_b i.`var' if selection ==1, or
			replace tp_a_pval 	 =e(p) if _n==`ligne'
			replace tp_a_methode = "FIRTHLOGIT" if _n==`ligne'
			matrix or =r(table)
		}
			
		if 	`produit' !=0 {							// si pas d'effectif nul, usage de logistic
			display "Pas d'effectif nul : Usage de LOGISTIC classique"
			xi: logistic covid_outcome_b i.`var' if selection ==1
			replace tp_a_pval =e(p) if _n==`ligne'
			replace tp_a_methode = "LOGISTIC" if _n==`ligne'
			matrix or =r(table)
		}
	}
		
	local num_modalite 1 								// compteur de la modalité	
	local num_or 1										// compteur OR
	foreach modj of local mod_var  { 	// saise des effectifs, % et ORs
		* traitement de la modalité modj, num_modalite ème modalité de la liste mod 
		replace tp_a_var			="`var'"	 				if _n==`ligne'
		replace tp_a_var_lb 		="`: var label `var''"		if _n==`ligne'
		replace tp_a_modalite		="`:label (`var') `modj''"  if _n==`ligne'
		replace tp_a_modalite_lb	="`modj'" 					if _n==`ligne'
		replace tp_a_nmod	=effectifs[1,2*(`nb_mod_var'+1)+ `num_modalite'] if _n==`ligne'
		replace tp_a_npos 	=effectifs[1,1*(`nb_mod_var'+1)+ `num_modalite'] if _n==`ligne'
		replace tp_a_posperc=effectifs[1,1*(`nb_mod_var'+1)+ `num_modalite']*100/effectifs[1,2*(`nb_mod_var'+1)+ `num_modalite'] if _n==`ligne'
			local a = effectifs[1,1*(`nb_mod_var'+1)+ `num_modalite']*100/effectifs[1,2*(`nb_mod_var'+1)+ `num_modalite']
			local a1 = string(`a',"%3.1f")
			local b = effectifs[1,1*(`nb_mod_var'+1)+ `num_modalite'] 
		replace tp_a_pos_final	= "`b' (`a1')"			 if _n==`ligne'
		if strpos("`: word `num_or' of `: colnames or''", "o.") ==1 {			// si la colonne num_or renvoie sur une variable omise
			while strpos("`: word `num_or' of `: colnames or''", "o.") ==1 {	// recherche de la prochaine colonne dans la matrice des OR avec dummy variable pertinente (non omise)	
				local num_or = `num_or' +1		
			}		
		}
		if "`: word `num_or' of `: colnames or''" != "_cons" {		// extraction des ORs si la colonne de la matrice ne porte pas sur la constante de la reg log
					display "balise 4"
			replace tp_a_or 	  = el("or",1,`num_or') 					if _n==`ligne'
			replace tp_a_ormin	  = el("or",5,`num_or') 					if _n==`ligne'
			replace tp_a_ormax	  = el("or",6,`num_or') 					if _n==`ligne'
			replace tp_a_check_or = "`: word `num_or' of `: colnames or''"	if _n==`ligne'
				local a  =el("or",1,`num_or')
					local a1 = string(`a',"%3.2f")
				local b  =el("or",5,`num_or')
					local b1 = string(`b',"%3.2f")
				local c=el("or",6,`num_or')
					local c1 = string(`c',"%3.2f")
				replace tp_a_or_final ="`a1' [`b1'-`c1']" 					if _n==`ligne'
		}		
					
		local num_or = `num_or' +1	
		local num_modalite = `num_modalite' +1
		local ligne=`ligne'+1
	}
	local ligne = `ligne'+1 			// espace entre 2 variables
}

/*
* Tests manuels, variable par variable (même chose que manip automatique précédente) - NE PAS CONSIDERER LES DONNEES MANQUANTES SUR L'OUTCOME (if covid_outcome_b !=99)
* COVID ET MOIS DE L'ITW
*tab mois_interview_step1 covid_outcome_b,expected row chi2 exact
bysort group_date_itw1 : tab mois_interview_step1 covid_outcome_b if covid_outcome_b !=99,expected row chi2 exact
		char mois_interview_step1[omit] "4"
xi: logistic covid_outcome_b i.mois_interview_step1 if group_date_itw1==1 & covid_outcome_b !=99
		char mois_interview_step1[omit] "7"
xi: logistic covid_outcome_b i.mois_interview_step1 if group_date_itw1==2 & covid_outcome_b !=99
	
* COVID ET GENRE
bysort group_date_itw1 : tab gender covid_outcome_b if covid_outcome_b !=99,expected row chi2 
bysort group_date_itw1 : logistic covid_outcome_b ib2.gender if covid_outcome_b !=99

* COVID ET AGE
bysort group_date_itw1 : tab age_cat covid_outcome_b if covid_outcome_b !=99,expected row chi2
xi: logistic covid_outcome_b i.age_cat if group_date_itw1==1 & covid_outcome_b !=99
xi: logistic covid_outcome_b i.age_cat if group_date_itw1==2 & covid_outcome_b !=99

* COVID ET LANGUE MATERNELLE
bysort group_date_itw1 : tab native_language2 covid_outcome_b if covid_outcome_b !=99, row chi2
xi: logistic covid_outcome_b i.native_language2 if group_date_itw1==1 & covid_outcome_b !=99
xi: logistic covid_outcome_b i.native_language2 if group_date_itw1==2 & covid_outcome_b !=99
testparm _Inative_la_1 _Inative_la_5	// p=0.51

* COVID ET ARCHIPEL
bysort group_date_itw1 : tab archipelago covid_outcome_b if covid_outcome_b !=99,expected row chi2 exact
	*char archipelago[omit] "1"
	char archipelago[omit] "2"
xi: logistic covid_outcome_b i.archipelago if group_date_itw1==1 & covid_outcome_b !=99

* ILE DE RESIDENCE
bysort group_date_itw1 : tab island  covid_outcome_b if covid_outcome_b !=99, row chi2 
	char island[omit] "3"
xi : firthlogit covid_outcome_b i.island if group_date_itw1==1 & covid_outcome_b !=99, or
	char island[omit] "1"
xi : logistic covid_outcome_b i.island if group_date_itw1==2 & covid_outcome_b !=99

* VILLAGE DE RESIDENCE
tab town_name covid_outcome_b if group_date_itw1==2 & covid_outcome_b !=99, row expected chi2 
xi : logistic covid_outcome_b i.town_name if group_date_itw1==2 & covid_outcome_b !=99

tab town_classif_1 covid_outcome_b if group_date_itw1==2 & covid_outcome_b !=99, row expected chi2 
xi : logistic covid_outcome_b i.town_classif_1 if group_date_itw1==2 & covid_outcome_b !=99

tab town_classif_2 covid_outcome_b if group_date_itw1==2 & covid_outcome_b !=99, row expected chi2 
xi : logistic covid_outcome_b i.town_classif_2 if group_date_itw1==2 & covid_outcome_b !=99

tab town_classif_3 covid_outcome_b if group_date_itw1==2 & covid_outcome_b !=99, row expected chi2 
xi : logistic covid_outcome_b i.town_classif_3 if group_date_itw1==2 & covid_outcome_b !=99

* COVID ET NIVEAU D'ETUDE
bysort group_date_itw1 : tab max_school2 covid_outcome_b if covid_outcome_b !=99,expected row chi2
xi: firthlogit covid_outcome_b i.max_school2  if group_date_itw1==1 & covid_outcome_b !=99,or
xi: logistic covid_outcome_b i.max_school2  if group_date_itw1==2 & covid_outcome_b !=99

* COVID ET ETAT CIVIL
bysort group_date_itw1 : tab civil_state4 covid_outcome_b if covid_outcome_b !=99,expected row chi2 exact
xi: firthlogit covid_outcome_b i.civil_state4 if group_date_itw1==1 & covid_outcome_b !=99, or
xi: firthlogit covid_outcome_b i.civil_state4 if group_date_itw1==2 & covid_outcome_b !=99, or

* COVID ET CATEGORIE PROFESSIONNELLE
  ** avec variable découpée en en 4 classes
bysort group_date_itw1 :tab pro_act_last_year2 covid_outcome_b if covid_outcome_b !=99,expected row chi2 
xi: logistic covid_outcome_b i.pro_act_last_year2 if group_date_itw1==1 & covid_outcome_b !=99
xi: logistic covid_outcome_b i.pro_act_last_year2 if group_date_itw1==2 & covid_outcome_b !=99

* COVID ET NOMBRE DE INDIVIDUS MAJEURS DANS LA MAISON
bysort group_date_itw1 : tab nhouse_classif covid_outcome_b if covid_outcome_b !=99,expected row chi2 exact
xi : logistic covid_outcome_b i.nhouse_classif if group_date_itw1==1 & covid_outcome_b !=99
xi : logistic covid_outcome_b i.nhouse_classif if group_date_itw1==2 & covid_outcome_b !=99

* COVID ET NOMBRE TOTAL DE PERSONNES DANS LE FOYER
bysort group_date_itw1 : tab nhouse_tot_classif covid_outcome_b if covid_outcome_b !=99,expected row chi2 exact
xi : logistic covid_outcome_b i.nhouse_tot_classif if group_date_itw1==1 & covid_outcome_b !=99
xi : logistic covid_outcome_b i.nhouse_tot_classif if group_date_itw1==2 & covid_outcome_b !=99

	*avec 3 classes
	bysort group_date_itw1 : tab nhouse_tot_classif2 covid_outcome_b if covid_outcome_b !=99,expected row chi2 exact
	xi : logistic covid_outcome_b i.nhouse_tot_classif2 if group_date_itw1==1 & covid_outcome_b !=99
	xi : logistic covid_outcome_b i.nhouse_tot_classif2 if group_date_itw1==2 & covid_outcome_b !=99
	
	*avec 4 classes
	bysort group_date_itw1 : tab nhouse_tot_classif3 covid_outcome_b if covid_outcome_b !=99,expected row chi2 exact
	xi : logistic covid_outcome_b i.nhouse_tot_classif3 if group_date_itw1==1 & covid_outcome_b !=99
	xi : logistic covid_outcome_b i.nhouse_tot_classif3 if group_date_itw1==2 & covid_outcome_b !=99
	
	
* COVID ET TYPES DE MAISONS
bysort group_date_itw1 : tab house_type covid_outcome_b if covid_outcome_b !=99 ,expected row chi2 exact
	xi: logistic covid_outcome_b i.house_type if group_date_itw1==1 & covid_outcome_b !=99
	xi: logistic covid_outcome_b i.house_type if group_date_itw1==2 & covid_outcome_b !=99

bysort group_date_itw1 : tab house_clim covid_outcome_b if covid_outcome_b !=99,expected row chi2 exact
	xi: logistic covid_outcome_b i.house_clim  if group_date_itw1==1 & covid_outcome_b !=99
	xi: logistic covid_outcome_b i.house_clim  if group_date_itw1==2 & covid_outcome_b !=99

bysort group_date_itw1 : tab house_clean_water covid_outcome_b if covid_outcome_b !=99,expected row chi2 exact
	xi: logistic covid_outcome_b i.house_clean_water  if group_date_itw1==1 & covid_outcome_b !=99
	xi: logistic covid_outcome_b i.house_clean_water  if group_date_itw1==2 & covid_outcome_b !=99

bysort group_date_itw1 : tab mosquito_bites covid_outcome_b if covid_outcome_b !=99,expected row chi2 exact
	xi: firthlogit covid_outcome_b i.mosquito_bites if group_date_itw1==1 & covid_outcome_b !=99, or
	xi: logistic covid_outcome_b i.mosquito_bites if group_date_itw1==2 & covid_outcome_b !=99

* COVID ET OBESITE
* IMC / OBESITE - 6 CLASSES
bysort group_date_itw1 : tab obesity_classif_who covid_outcome_b if covid_outcome_b !=99,expected row chi2 exact
xi: firthlogit covid_outcome_b i.obesity_classif_who if group_date_itw1==1 & covid_outcome_b !=99,or
xi: logistic covid_outcome_b i.obesity_classif_who if group_date_itw1==2 & covid_outcome_b !=99

* IMC / OBESITE - 3 CLASSES
bysort group_date_itw1 : tab obesity_classif_who3 covid_outcome_b 			 if covid_outcome_b !=99,expected row chi2
xi: firthlogit covid_outcome_b i.obesity_classif_who3 	if group_date_itw1==1 & covid_outcome_b !=99, or
xi: logistic covid_outcome_b i.obesity_classif_who3 	if group_date_itw1==2 & covid_outcome_b !=99

* IMC / OBESITE - 2 CLASSES
bysort group_date_itw1 : tab obesity_who_bool covid_outcome_b 			 if covid_outcome_b !=99,expected row chi2
xi: firthlogit covid_outcome_b i.obesity_who_bool 	if group_date_itw1==1 & covid_outcome_b !=99, or
xi: logistic covid_outcome_b i.obesity_who_bool 	if group_date_itw1==2 & covid_outcome_b !=99

* HTA
bysort group_date_itw1 : tab hypertension_bool covid_outcome_b 				 if covid_outcome_b !=99,expected row chi2 
	xi: logistic covid_outcome_b i.hypertension_bool 	if group_date_itw1==1 & covid_outcome_b !=99
	xi: firthlogit covid_outcome_b i.hypertension_bool 	if group_date_itw1==2 & covid_outcome_b !=99, or
	
* DIABETE
bysort group_date_itw1 : tab diabete_bool covid_outcome_b 				 if covid_outcome_b !=99,expected row chi2 exact
	xi: firthlogit covid_outcome_b i.diabete_bool 	if group_date_itw1==1 & covid_outcome_b !=99, or
	xi: logistic covid_outcome_b i.diabete_bool 	if group_date_itw1==2 & covid_outcome_b !=99

* ALLERGIES RESPIRATOIRES
bysort group_date_itw1 : tab respi_allergy_medical covid_outcome_b 			 if covid_outcome_b !=99,expected row chi2 exact
xi: firthlogit covid_outcome_b i.respi_allergy_medical 	if group_date_itw1==1 & covid_outcome_b !=99, or
xi: logistic covid_outcome_b i.respi_allergy_medical 	if group_date_itw1==2 & covid_outcome_b !=99

* ASTHME
bysort group_date_itw1 : tab asthma_medical covid_outcome_b 		 if covid_outcome_b !=99,expected row chi2 
xi: firthlogit covid_outcome_b i.asthma_medical if group_date_itw1==1 & covid_outcome_b !=99, or
xi: firthlogit covid_outcome_b i.asthma_medical if group_date_itw1==2 & covid_outcome_b !=99, or

* ALD
bysort group_date_itw1 : tab chronic_ald covid_outcome_b 		if covid_outcome_b !=99,expected row chi2
xi: logistic covid_outcome_b i.chronic_ald if group_date_itw1==1 & covid_outcome_b !=99
xi: logistic covid_outcome_b i.chronic_ald if group_date_itw1==2 & covid_outcome_b !=99
*p= 0.75 / 0.55
	
* CANCER
bysort group_date_itw1 : tab cancer_or_malignant_tumor_medica covid_outcome_b 			if  covid_outcome_b !=99,expected row chi2 exact
xi : firthlogit covid_outcome_b i.cancer_or_malignant_tumor_medica 	if group_date_itw1==1 & covid_outcome_b !=99, or
xi: logistic covid_outcome_b i.cancer_or_malignant_tumor_medica 	if group_date_itw1==2 & covid_outcome_b !=99

* ACTIVITE PHYSIQUE
bysort group_date_itw1 : tab phys_act_level covid_outcome_b 	   if covid_outcome_b !=99,expected row chi2 exact
xi: logistic covid_outcome_b i.phys_act_level if group_date_itw1==1 & covid_outcome_b !=99
xi: logistic covid_outcome_b i.phys_act_level if group_date_itw1==2 & covid_outcome_b !=99

* ALCOOL
bysort group_date_itw1 : tab alcool_30d_bool covid_outcome_b 			if covid_outcome_b !=99,expected row chi2 
	xi: logistic covid_outcome_b i.alcool_30d_bool if group_date_itw1==1 & covid_outcome_b !=99
	xi: logistic covid_outcome_b i.alcool_30d_bool if group_date_itw1==2 & covid_outcome_b !=99

* TABAC
bysort group_date_itw1 : tab smoking_prst covid_outcome_b 				if covid_outcome_b !=99,expected row chi2 exact
	*xi : logistic covid_outcome_b ib2.smoking_prst i.age_cat 			if covid_outcome_b !=99
	bysort group_date_itw1 : logistic covid_outcome_b ib2.smoking_prst 	if covid_outcome_b !=99

bysort group_date_itw1 : tab smoking_classif covid_outcome_b 		  if covid_outcome_b !=99,expected row chi2 exact
bysort group_date_itw1 : logistic covid_outcome_b ib0.smoking_classif if covid_outcome_b !=99

bysort group_date_itw1 : tab smoking_everyday_bool covid_outcome_b 			if covid_outcome_b !=99,expected row chi2 
bysort group_date_itw1 : logistic covid_outcome_b ib0.smoking_everyday_bool if covid_outcome_b !=99

bysort group_date_itw1 : tab ntabaco_per_day_equ_class covid_outcome_b 			if covid_outcome_b !=99,expected row chi2 exact
bysort group_date_itw1 : logistic covid_outcome_b ib0.ntabaco_per_day_equ_class if covid_outcome_b !=99

* PAKA
bysort group_date_itw1 : tab paka_weekly_bool covid_outcome_b 		   if covid_outcome_b !=99, row chi2
	*p=0.31 & 0.54
bysort group_date_itw1 : logistic covid_outcome_b ib2.paka_weekly_bool if covid_outcome_b !=99

* COVID & HYGIENE ALIMENTAIRE
bysort group_date_itw1 : tab reco_fruit_vege covid_outcome_b 		  if covid_outcome_b !=99,expected row chi2 exact
bysort group_date_itw1 : logistic covid_outcome_b ib0.reco_fruit_vege if covid_outcome_b !=99
	*p=0.56 & 0.98

* GESTES BARRIERES
bysort group_date_itw1 : tab covid_behavior_hand_washing 	covid_outcome_b if covid_outcome_b !=99,expected row chi2 exact
bysort group_date_itw1 : tab covid_behavior_hand_shaking 	covid_outcome_b if covid_outcome_b !=99,expected row chi2 exact
bysort group_date_itw1 : tab covid_behavior_cough_elbow 	covid_outcome_b if covid_outcome_b !=99,expected row chi2 exact
bysort group_date_itw1 : tab covid_behavior_safety_distance covid_outcome_b if covid_outcome_b !=99,expected row chi2 exact
bysort group_date_itw1 : tab covid_behavior_mask 			covid_outcome_b,expected row chi2 exact

logistic covid_outcome_b covid_behavior_hand_washing 	if group_date_itw1==1 & covid_outcome_b !=99
logistic covid_outcome_b covid_behavior_hand_shaking 	if group_date_itw1==1 & covid_outcome_b !=99
logistic covid_outcome_b covid_behavior_cough_elbow 	if group_date_itw1==1 & covid_outcome_b !=99
logistic covid_outcome_b covid_behavior_safety_distance if group_date_itw1==1 & covid_outcome_b !=99
logistic covid_outcome_b covid_behavior_mask 			if group_date_itw1==1 & covid_outcome_b !=99
	
xi: firthlogit covid_outcome_b i.covid_behavior_hand_washing 	if group_date_itw1==2 & covid_outcome_b !=99, or
xi: firthlogit covid_outcome_b i.covid_behavior_hand_shaking 	if group_date_itw1==2 & covid_outcome_b !=99, or
xi: firthlogit covid_outcome_b i.covid_behavior_cough_elbow 	if group_date_itw1==2 & covid_outcome_b !=99, or
xi: firthlogit covid_outcome_b i.covid_behavior_safety_distance if group_date_itw1==2 & covid_outcome_b !=99, or
xi: firthlogit covid_outcome_b i.covid_behavior_mask 			if group_date_itw1==2 & covid_outcome_b !=99, or

	
* VACCINATION - 3 CLASSES (VACCINE / NON VACCINE / manqants)
bysort group_date_itw1 : tab covid_vaccination_explicative covid_outcome_b 			if   covid_outcome_b !=99,expected row chi2 exact
xi : firthlogit covid_outcome_b i.covid_vaccination_explicative  if group_date_itw1==1 & covid_outcome_b !=99,or
xi : logistic   covid_outcome_b i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99

* VACCINATION - 2 CLASSES (VACCINE / NON VACCINE)
bysort group_date_itw1 : tab covid_vaccination_explicativebis covid_outcome_b 			if  covid_outcome_b !=99,expected row chi2 exact
xi : firthlogit covid_outcome_b i.covid_vaccination_explicativebis  if group_date_itw1==1 & covid_outcome_b !=99,or
xi : logistic   covid_outcome_b i.covid_vaccination_explicativebis  if group_date_itw1==2 & covid_outcome_b !=99
*/



**********************************************************************************
**# VI. ANALYSE MULTIVARIEE OUTCOME COVID B (Ac anti-N LUMINEX) DANS ECHANTILLON **
**********************************************************************************

*---------------------------------------------------------------------
**# 6.1. Analyse Multivariée sur la 1ère période : Avril à Juin 2021 |
*---------------------------------------------------------------------
// Methode ascendante
	char mois_interview_step1[omit] "4"
	char archipelago[omit] "2"
	char island[omit]"3"
xi : logistic covid_outcome_b i.island  if group_date_itw1==1 & covid_outcome_b !=99
est store a
estat ic
testparm _Iisl* 		//p=0.0556

xi : logistic covid_outcome_b i.island i.covid_behavior_safety_distance  if group_date_itw1==1 & covid_outcome_b !=99
est store b
estat ic
testparm _Iisl*			//p=0.0532
testparm _Icov*			//p=0.0805

lrtest b a

xi : logistic covid_outcome_b i.island i.smoking_prst if group_date_itw1==1 & covid_outcome_b !=99
testparm _Iisl*			//p=0.0608
testparm _Ismok*		//p=0.1480
estat ic

/*	MODELE FINAL SUR PERIODE 1********************************************************
. xi : logistic covid_outcome_b i.island  if group_date_itw1==1 & covid_outcome_b !=99
i.island          _Iisland_1-18       (naturally coded; _Iisland_3 omitted)
note: _Iisland_1 omitted because of collinearity.
note: _Iisland_2 omitted because of collinearity.

Logistic regression                                     Number of obs =    479
                                                        LR chi2(9)    =  18.54
                                                        Prob > chi2   = 0.0294
Log likelihood = -242.6377                              Pseudo R2     = 0.0368

---------------------------------------------------------------------------------
covid_outcome_b | Odds ratio   Std. err.      z    P>|z|     [95% conf. interval]
----------------+----------------------------------------------------------------
     _Iisland_1 |          1  (omitted)
     _Iisland_2 |          1  (omitted)
     _Iisland_6 |   .3979592   .1800531    -2.04   0.042     .1639532    .9659556
     _Iisland_8 |       .455   .2423996    -1.48   0.139     .1601537    1.292665
     _Iisland_9 |    .203125   .1401359    -2.31   0.021     .0525436    .7852483
    _Iisland_11 |   .5958333   .2827566    -1.09   0.275     .2350615    1.510317
    _Iisland_12 |   .3765244   .1533098    -2.40   0.016     .1695151    .8363301
    _Iisland_13 |   .2708333   .1300539    -2.72   0.007      .105671     .694142
    _Iisland_14 |   .5833333   .2595874    -1.21   0.226      .243852    1.395428
    _Iisland_17 |   .0902782   .0970863    -2.24   0.025     .0109696    .7429779
    _Iisland_18 |   .7824074   .3627213    -0.53   0.597      .315369    1.941096
          _cons |   .6153846    .195535    -1.53   0.127     .3301278    1.147126
--------------------------------------------------------------------------------- */

// Methode descendante
	char mois_interview_step1[omit] "4"
	char archipelago[omit] "2"
	char island[omit]"3"

xi : sw logistic covid_outcome_b (i.gender) (i.island) (i.smoking_prst) (i.covid_behavior_safety_distance) (i.covid_vaccination_complete) if group_date_itw1==1 & covid_outcome_b !=99,pr(0.05) lr
	
/* MEME RESULTAT QUE ASCENDANTE :

Logistic regression                                     Number of obs =    479
                                                        LR chi2(9)    =  18.54
                                                        Prob > chi2   = 0.0294
Log likelihood = -242.6377                              Pseudo R2     = 0.0368

---------------------------------------------------------------------------------
covid_outcome_b | Odds ratio   Std. err.      z    P>|z|     [95% conf. interval]
----------------+----------------------------------------------------------------
     _Iisland_6 |   .3979592   .1800531    -2.04   0.042     .1639532    .9659556
     _Iisland_8 |       .455   .2423996    -1.48   0.139     .1601537    1.292665
     _Iisland_9 |    .203125   .1401359    -2.31   0.021     .0525436    .7852483
    _Iisland_11 |   .5958333   .2827566    -1.09   0.275     .2350615    1.510317
    _Iisland_12 |   .3765244   .1533098    -2.40   0.016     .1695151    .8363301
    _Iisland_13 |   .2708333   .1300539    -2.72   0.007      .105671     .694142
    _Iisland_14 |   .5833333   .2595874    -1.21   0.226      .243852    1.395428
    _Iisland_17 |   .0902782   .0970863    -2.24   0.025     .0109696    .7429779
    _Iisland_18 |   .7824074   .3627213    -0.53   0.597      .315369    1.941096
          _cons |   .6153846    .195535    -1.53   0.127     .3301278    1.147126
--------------------------------------------------------------------------------- */
	
	
*---------------------------------------------------------------------------
**# 6.2. Analyse Multivariée sur la 2ème période : Juillet à Décembre 2021 |
**# Bookmark #2 avec varibable 'native_language2'
*---------------------------------------------------------------------

	char mois_interview_step1[omit] "7"
	char archipelago[omit] "1"
	char island[omit]"1"
// STEP 1		
xi : firthlogit covid_outcome_b i.mois_interview_step1 i.age_cat i.native_language2 i.max_school2 i.pro_act_last_year3 i.nhouse_tot_classif3 i.house_clean_water i.obesity_who_bool i.hypertension_bool i.diabete_bool i.respi_allergy_medical i.cancer_or_malignant_tumor_medica i.covid_behavior_hand_washing i.covid_behavior_mask i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Iage*			//p=0.8665
testparm _Inative*
testparm _Imax*
testparm _Ipro*
testparm _Inhouse*
testparm _Ihouse_cl*
testparm _Iobesity*
testparm _Ihypertens*
testparm _Idiabete*
testparm _Irespi*
testparm _Icancer*
testparm _Icovid_beh_*
testparm _Icovid_beha*
testparm _Icovid_vac*

// STEP 2
xi : firthlogit covid_outcome_b i.mois_interview_step1 i.native_language2 i.max_school2 i.pro_act_last_year3 i.nhouse_tot_classif3 i.house_clean_water i.obesity_who_bool i.hypertension_bool i.diabete_bool i.respi_allergy_medical i.cancer_or_malignant_tumor_medica i.covid_behavior_hand_washing i.covid_behavior_mask i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Inative*
testparm _Imax*
testparm _Ipro*
testparm _Inhouse*
testparm _Ihouse_cl*
testparm _Iobesity*
testparm _Ihypertens*
testparm _Idiabete*
testparm _Irespi*
testparm _Icancer*
testparm _Icovid_beh_*
testparm _Icovid_beha*	//p=0.8242
testparm _Icovid_vac*

//STEP 3
xi : firthlogit covid_outcome_b i.mois_interview_step1 i.native_language2 i.max_school2 i.pro_act_last_year3 i.nhouse_tot_classif3 i.house_clean_water i.obesity_who_bool i.hypertension_bool i.diabete_bool i.respi_allergy_medical i.cancer_or_malignant_tumor_medica i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Inative*
testparm _Imax*		//p=0.7249
testparm _Ipro*
testparm _Inhouse*
testparm _Ihouse_cl*
testparm _Iobesity*
testparm _Ihypertens*
testparm _Idiabete*
testparm _Irespi*
testparm _Icancer*
testparm _Icovid_beh_*
testparm _Icovid_vac*

xi : firthlogit covid_outcome_b i.mois_interview_step1 i.native_language2 i.pro_act_last_year3 i.nhouse_tot_classif3 i.house_clean_water i.obesity_who_bool i.hypertension_bool i.diabete_bool i.respi_allergy_medical i.cancer_or_malignant_tumor_medica i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Inative*
testparm _Ipro*
testparm _Inhouse*
testparm _Ihouse_cl*
testparm _Iobesity*
testparm _Ihypertens*
testparm _Idiabete*		//p=0.3789
testparm _Irespi*
testparm _Icancer*
testparm _Icovid_beh_*
testparm _Icovid_vac*

xi : firthlogit covid_outcome_b i.mois_interview_step1 i.native_language2 i.pro_act_last_year3 i.nhouse_tot_classif3 i.house_clean_water i.obesity_who_bool i.hypertension_bool i.respi_allergy_medical i.cancer_or_malignant_tumor_medica i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Inative*
testparm _Ipro*
testparm _Inhouse*
testparm _Ihouse_cl*		//p=0.4012
testparm _Iobesity*
testparm _Ihypertens*
testparm _Irespi*
testparm _Icancer*
testparm _Icovid_beh_*
testparm _Icovid_vac*

xi : firthlogit covid_outcome_b i.mois_interview_step1 i.native_language2 i.pro_act_last_year3 i.nhouse_tot_classif3 i.obesity_who_bool i.hypertension_bool i.respi_allergy_medical i.cancer_or_malignant_tumor_medica i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Inative*
testparm _Ipro*
testparm _Inhouse*
testparm _Iobesity*		//p=0.2331
testparm _Ihypertens*
testparm _Irespi*
testparm _Icancer*
testparm _Icovid_beh_*
testparm _Icovid_vac*

xi : firthlogit covid_outcome_b i.mois_interview_step1 i.native_language2 i.pro_act_last_year3 i.nhouse_tot_classif3 i.hypertension_bool i.respi_allergy_medical i.cancer_or_malignant_tumor_medica i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Inative*
testparm _Ipro*
testparm _Inhouse*
testparm _Ihypertens*
testparm _Irespi*
testparm _Icancer*		//p= 0.1913
testparm _Icovid_beh_*
testparm _Icovid_vac*

xi : firthlogit covid_outcome_b i.mois_interview_step1 i.native_language2 i.pro_act_last_year3 i.nhouse_tot_classif3 i.hypertension_bool i.respi_allergy_medical i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Inative*
testparm _Ipro*
testparm _Inhouse*
testparm _Ihypertens*		//p= 0.1112
testparm _Irespi*
testparm _Icovid_beh_*
testparm _Icovid_vac*

xi : firthlogit covid_outcome_b i.mois_interview_step1 i.native_language2 i.pro_act_last_year3 i.nhouse_tot_classif3 i.respi_allergy_medical i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Inative*
testparm _Ipro*		//p=0.1452
testparm _Inhouse*
testparm _Irespi*
testparm _Icovid_beh_*
testparm _Icovid_vac*

xi : firthlogit covid_outcome_b i.mois_interview_step1 i.native_language2 i.nhouse_tot_classif3 i.respi_allergy_medical i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Inative*
testparm _Inhouse*		//p=0.0971
testparm _Irespi*
testparm _Icovid_beh_*
testparm _Icovid_vac*

xi : firthlogit covid_outcome_b i.mois_interview_step1 i.native_language2 i.respi_allergy_medical i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Inative*		//p=0.0631
testparm _Irespi*
testparm _Icovid_beh*
testparm _Icovid_vac*

xi : firthlogit covid_outcome_b i.mois_interview_step1 i.respi_allergy_medical i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*		//p<0.0001
testparm _Irespi*		//p=0.0080
testparm _Icovid_beh*	//p=0.0364
testparm _Icovid_vac*	//p<0.0001
/*                                                      Number of obs =    641
                                                        Wald chi2(8)  =  90.42
Penalized log likelihood = -356.9853                    Prob > chi2   = 0.0000

--------------------------------------------------------------------------------
covid_outcom~b | Odds ratio   Std. err.      z    P>|z|     [95% conf. interval]
---------------+----------------------------------------------------------------
 _Imois_inte_4 |          1  (omitted)
 _Imois_inte_5 |          1  (omitted)
 _Imois_inte_6 |          1  (omitted)
_Imois_inte_10 |   4.966951   1.094078     7.28   0.000      3.22548    7.648658
_Imois_inte_11 |   5.639115   1.460585     6.68   0.000     3.394232    9.368723
_Imois_inte_12 |   1.925239   1.018448     1.24   0.216     .6826534    5.429613
 _Irespi_all_1 |   .4593914   .1303562    -2.74   0.006     .2634191    .8011586
_Irespi_all_77 |   10.22337   16.65101     1.43   0.153     .4199761    248.8648
 _Icovid_beh_1 |   .3496016   .1592198    -2.31   0.021     .1431887    .8535676
_Icovid_beh_99 |   .0532249   .0939458    -1.66   0.097     .0016737    1.692572
 _Icovid_vac_1 |   .2721512   .0532085    -6.66   0.000     .1855202    .3992356
_Icovid_vac_99 |          1  (omitted)
         _cons |   3.252959   1.538409     2.49   0.013     1.287429    8.219282
-------------------------------------------------------------------------------- */

*---------------------------------------------------------------------
**# 6.3. Analyse Multivariée sur la 2ème période : Juillet à Décembre 2021 |
**# Bookmark #2 Sans varibable 'native_language2'
*---------------------------------------------------------------------
	char mois_interview_step1[omit] "7"
	char archipelago[omit] "1"
	char island[omit]"1"
// STEP 1		
xi : firthlogit covid_outcome_b i.mois_interview_step1 i.age_cat i.max_school2 i.pro_act_last_year3 i.nhouse_tot_classif3 i.house_clean_water i.obesity_who_bool i.hypertension_bool i.diabete_bool i.respi_allergy_medical i.cancer_or_malignant_tumor_medica i.covid_behavior_hand_washing i.covid_behavior_mask i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Iage*			//p=  0.9339
testparm _Imax*
testparm _Ipro*
testparm _Inhouse*
testparm _Ihouse_cl*
testparm _Iobesity*
testparm _Ihypertens*
testparm _Idiabete*
testparm _Irespi*
testparm _Icancer*
testparm _Icovid_beh_*
testparm _Icovid_beha*
testparm _Icovid_vac*

// STEP 2	
xi : firthlogit covid_outcome_b i.mois_interview_step1 i.max_school2 i.pro_act_last_year3 i.nhouse_tot_classif3 i.house_clean_water i.obesity_who_bool i.hypertension_bool i.diabete_bool i.respi_allergy_medical i.cancer_or_malignant_tumor_medica i.covid_behavior_hand_washing i.covid_behavior_mask i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Imax*
testparm _Ipro*
testparm _Inhouse*
testparm _Ihouse_cl*
testparm _Iobesity*
testparm _Ihypertens*
testparm _Idiabete*
testparm _Irespi*
testparm _Icancer*
testparm _Icovid_beh_*
testparm _Icovid_beha*		//p=  0.8814
testparm _Icovid_vac*

// STEP 3
xi : firthlogit covid_outcome_b i.mois_interview_step1 i.max_school2 i.pro_act_last_year3 i.nhouse_tot_classif3 i.house_clean_water i.obesity_who_bool i.hypertension_bool i.diabete_bool i.respi_allergy_medical i.cancer_or_malignant_tumor_medica i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Imax*			//p=  0.7121
testparm _Ipro*
testparm _Inhouse*
testparm _Ihouse_cl*
testparm _Iobesity*
testparm _Ihypertens*
testparm _Idiabete*
testparm _Irespi*
testparm _Icancer*
testparm _Icovid_beh_*
testparm _Icovid_vac*

// STEP 4
xi : firthlogit covid_outcome_b i.mois_interview_step1 i.pro_act_last_year3 i.nhouse_tot_classif3 i.house_clean_water i.obesity_who_bool i.hypertension_bool i.diabete_bool i.respi_allergy_medical i.cancer_or_malignant_tumor_medica i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Ipro*
testparm _Inhouse*
testparm _Ihouse_cl*
testparm _Iobesity*
testparm _Ihypertens*
testparm _Idiabete*			//p=  0.4011
testparm _Irespi*
testparm _Icancer*
testparm _Icovid_beh_*
testparm _Icovid_vac*

// STEP 5
xi : firthlogit covid_outcome_b i.mois_interview_step1 i.pro_act_last_year3 i.nhouse_tot_classif3 i.house_clean_water i.obesity_who_bool i.hypertension_bool i.respi_allergy_medical i.cancer_or_malignant_tumor_medica i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Ipro*
testparm _Inhouse*
testparm _Ihouse_cl*	//p=  0.3760
testparm _Iobesity*
testparm _Ihypertens*
testparm _Irespi*
testparm _Icancer*
testparm _Icovid_beh_*
testparm _Icovid_vac*

// STEP 6
xi : firthlogit covid_outcome_b i.mois_interview_step1 i.pro_act_last_year3 i.nhouse_tot_classif3 i.obesity_who_bool i.hypertension_bool i.respi_allergy_medical i.cancer_or_malignant_tumor_medica i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Ipro*
testparm _Inhouse*
testparm _Iobesity*
testparm _Ihypertens*
testparm _Irespi*
testparm _Icancer*			//p=  0.3069
testparm _Icovid_beh_*
testparm _Icovid_vac*

// STEP 7
xi : firthlogit covid_outcome_b i.mois_interview_step1 i.pro_act_last_year3 i.nhouse_tot_classif3 i.obesity_who_bool i.hypertension_bool i.respi_allergy_medical i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Ipro*
testparm _Inhouse*
testparm _Iobesity*
testparm _Ihypertens*		//p= 0.1772
testparm _Irespi*
testparm _Icovid_beh_*
testparm _Icovid_vac*

// STEP 8
xi : firthlogit covid_outcome_b i.mois_interview_step1 i.pro_act_last_year3 i.nhouse_tot_classif3 i.obesity_who_bool i.respi_allergy_medical i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Ipro*
testparm _Inhouse*
testparm _Iobesity*			//p= 0.2452
testparm _Irespi*
testparm _Icovid_beh_*
testparm _Icovid_vac*

// STEP 9
xi : firthlogit covid_outcome_b i.mois_interview_step1 i.pro_act_last_year3 i.nhouse_tot_classif3 i.respi_allergy_medical i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Ipro*				//p=  0.1176
testparm _Inhouse*
testparm _Irespi*
testparm _Icovid_beh_*
testparm _Icovid_vac*

// STEP 10
xi : firthlogit covid_outcome_b i.mois_interview_step1 i.nhouse_tot_classif3 i.respi_allergy_medical i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Inhouse*		//p= 0.0956
testparm _Irespi*
testparm _Icovid_beh_*
testparm _Icovid_vac*

// STEP 11
xi : firthlogit covid_outcome_b i.mois_interview_step1 i.respi_allergy_medical i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*			//p< 0.0001
testparm _Irespi*			//p= 0.0080
testparm _Icovid_beh_*		//p= 0.0364
testparm _Icovid_vac*		//p< 0.0001

/*                                                      Number of obs =    641
                                                        Wald chi2(8)  =  90.42
Penalized log likelihood = -356.9853                    Prob > chi2   = 0.0000

--------------------------------------------------------------------------------
covid_outcom~b | Odds ratio   Std. err.      z    P>|z|     [95% conf. interval]
---------------+----------------------------------------------------------------
 _Imois_inte_4 |          1  (omitted)
 _Imois_inte_5 |          1  (omitted)
 _Imois_inte_6 |          1  (omitted)
_Imois_inte_10 |   4.966951   1.094078     7.28   0.000      3.22548    7.648658
_Imois_inte_11 |   5.639115   1.460585     6.68   0.000     3.394232    9.368723
_Imois_inte_12 |   1.925239   1.018448     1.24   0.216     .6826534    5.429613
 _Irespi_all_1 |   .4593914   .1303562    -2.74   0.006     .2634191    .8011586
_Irespi_all_77 |   10.22337   16.65101     1.43   0.153     .4199761    248.8648
 _Icovid_beh_1 |   .3496016   .1592198    -2.31   0.021     .1431887    .8535677
_Icovid_beh_99 |   .0532249   .0939458    -1.66   0.097     .0016737    1.692572
 _Icovid_vac_1 |   .2721512   .0532085    -6.66   0.000     .1855202    .3992356
_Icovid_vac_99 |          1  (omitted)
         _cons |   3.252959   1.538409     2.49   0.013     1.287429    8.219283
-------------------------------------------------------------------------------- */



*---------------------------------------------------------------------------
**# 6.4. Analyse Multivariée sur la 2ème période : Juillet à Décembre 2021 |
**# Bookmark #2 avec varibable 'native_language2' milieu socio culturels et town classif
*---------------------------------------------------------------------

	char mois_interview_step1[omit] "7"
	char archipelago[omit] "1"
	char island[omit]"1"
	char town_name[omit] "PAPEETE"
	char town_classif_1[omit] "zone urbaine"
	char town_classif_2[omit] "Eau potable sur tout le territoire"
	char town_classif_3[omit] "Classes 2 et 3"	
	
*i.town_classif_1 i.town_classif_2 i.town_classif_3 
	
// STEP 1		
xi : firthlogit covid_outcome_b i.mois_interview_step1 i.age_cat i.native_language2 i.socio_cultural i.town_classif_3 i.max_school2 i.pro_act_last_year3 i.nhouse_tot_classif3 i.house_clean_water i.obesity_who_bool i.hypertension_bool i.diabete_bool i.respi_allergy_medical i.cancer_or_malignant_tumor_medica i.covid_behavior_hand_washing i.covid_behavior_mask i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Iage*		
testparm _Inative*
testparm _Isocio*
testparm _Itown*
testparm _Imax*		//	p=0.8226
testparm _Ipro*		
testparm _Inhouse*
testparm _Ihouse_cl*
testparm _Iobesity*
testparm _Ihypertens*
testparm _Idiabete*
testparm _Irespi*
testparm _Icancer*
testparm _Icovid_beh_*
testparm _Icovid_beha*
testparm _Icovid_vac*

// STEP 2
xi : firthlogit covid_outcome_b i.mois_interview_step1 i.age_cat i.native_language2 i.socio_cultural i.town_classif_3 i.pro_act_last_year3 i.nhouse_tot_classif3 i.house_clean_water i.obesity_who_bool i.hypertension_bool i.diabete_bool i.respi_allergy_medical i.cancer_or_malignant_tumor_medica i.covid_behavior_hand_washing i.covid_behavior_mask i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Iage*			//p=0.8130
testparm _Inative*
testparm _Isocio*
testparm _Itown*
testparm _Ipro*
testparm _Inhouse*
testparm _Ihouse_cl*
testparm _Iobesity*
testparm _Ihypertens*
testparm _Idiabete*
testparm _Irespi*
testparm _Icancer*
testparm _Icovid_beh_*
testparm _Icovid_beha*
testparm _Icovid_vac*

// STEP 3
xi : firthlogit covid_outcome_b i.mois_interview_step1 i.native_language2 i.socio_cultural i.town_classif_3 i.pro_act_last_year3 i.nhouse_tot_classif3 i.house_clean_water i.obesity_who_bool i.hypertension_bool i.diabete_bool i.respi_allergy_medical i.cancer_or_malignant_tumor_medica i.covid_behavior_hand_washing i.covid_behavior_mask i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Inative*
testparm _Isocio*
testparm _Itown*
testparm _Ipro*
testparm _Inhouse*
testparm _Ihouse_cl*
testparm _Iobesity*
testparm _Ihypertens*
testparm _Idiabete*
testparm _Irespi*
testparm _Icancer*
testparm _Icovid_beh_*
testparm _Icovid_beha*			//p= 0.7815
testparm _Icovid_vac*

// STEP 4
xi : firthlogit covid_outcome_b i.mois_interview_step1 i.native_language2 i.socio_cultural i.town_classif_3 i.pro_act_last_year3 i.nhouse_tot_classif3 i.house_clean_water i.obesity_who_bool i.hypertension_bool i.diabete_bool i.respi_allergy_medical i.cancer_or_malignant_tumor_medica i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Inative*
testparm _Isocio*
testparm _Itown*
testparm _Ipro*
testparm _Inhouse*
testparm _Ihouse_cl*
testparm _Iobesity*
testparm _Ihypertens*
testparm _Idiabete*		//p=0.4911
testparm _Irespi*
testparm _Icancer*
testparm _Icovid_beh_*
testparm _Icovid_vac*

// STEP 5
xi : firthlogit covid_outcome_b i.mois_interview_step1 i.native_language2 i.socio_cultural i.town_classif_3 i.pro_act_last_year3 i.nhouse_tot_classif3 i.house_clean_water i.obesity_who_bool i.hypertension_bool i.respi_allergy_medical i.cancer_or_malignant_tumor_medica i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Inative*
testparm _Isocio*
testparm _Itown*
testparm _Ipro*
testparm _Inhouse*
testparm _Ihouse_cl*
testparm _Iobesity*			//p=0.5061
testparm _Ihypertens*
testparm _Irespi*
testparm _Icancer*
testparm _Icovid_beh_*
testparm _Icovid_vac*

// STEP 6
xi : firthlogit covid_outcome_b i.mois_interview_step1 i.native_language2 i.socio_cultural i.town_classif_3 i.pro_act_last_year3 i.nhouse_tot_classif3 i.house_clean_water i.hypertension_bool i.respi_allergy_medical i.cancer_or_malignant_tumor_medica i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Inative*
testparm _Isocio*
testparm _Itown*
testparm _Ipro*
testparm _Inhouse*
testparm _Ihouse_cl*		//p=0.3537
testparm _Ihypertens*
testparm _Irespi*
testparm _Icancer*
testparm _Icovid_beh_*
testparm _Icovid_vac*

// STEP 7
xi : firthlogit covid_outcome_b i.mois_interview_step1 i.native_language2 i.socio_cultural i.town_classif_3 i.pro_act_last_year3 i.nhouse_tot_classif3 i.hypertension_bool i.respi_allergy_medical i.cancer_or_malignant_tumor_medica i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Inative*
testparm _Isocio*
testparm _Itown*
testparm _Ipro*
testparm _Inhouse*
testparm _Ihypertens*
testparm _Irespi*
testparm _Icancer*		//p= 0.3015
testparm _Icovid_beh_*
testparm _Icovid_vac*

// STEP 8
xi : firthlogit covid_outcome_b i.mois_interview_step1 i.native_language2 i.socio_cultural i.town_classif_3 i.pro_act_last_year3 i.nhouse_tot_classif3 i.hypertension_bool i.respi_allergy_medical i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Inative*
testparm _Isocio*		//p=0.1731
testparm _Itown*
testparm _Ipro*
testparm _Inhouse*
testparm _Ihypertens*
testparm _Irespi*
testparm _Icovid_beh_*
testparm _Icovid_vac*

// STEP 9
xi : firthlogit covid_outcome_b i.mois_interview_step1 i.native_language2 i.town_classif_3 i.pro_act_last_year3 i.nhouse_tot_classif3 i.hypertension_bool i.respi_allergy_medical i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Inative*
testparm _Itown*
testparm _Ipro*
testparm _Inhouse*
testparm _Ihypertens*		//p=0.1576
testparm _Irespi*
testparm _Icovid_beh_*
testparm _Icovid_vac*

// STEP 10
xi : firthlogit covid_outcome_b i.mois_interview_step1 i.native_language2 i.town_classif_3 i.pro_act_last_year3 i.nhouse_tot_classif3 i.respi_allergy_medical i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Inative*
testparm _Itown*
testparm _Ipro*		//p=0.1767
testparm _Inhouse*
testparm _Irespi*
testparm _Icovid_beh_*
testparm _Icovid_vac*

// STEP 11
xi : firthlogit covid_outcome_b i.mois_interview_step1 i.native_language2 i.town_classif_3 i.nhouse_tot_classif3 i.respi_allergy_medical i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Inative*
testparm _Itown*
testparm _Inhouse*		//p= 0.1044
testparm _Irespi*
testparm _Icovid_beh_*
testparm _Icovid_vac*

// STEP 12
xi : firthlogit covid_outcome_b i.mois_interview_step1 i.native_language2 i.town_classif_3 i.respi_allergy_medical i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Inative*
testparm _Itown*		//p= 0.0579
testparm _Irespi*
testparm _Icovid_beh_*
testparm _Icovid_vac*

// STEP 13
xi : firthlogit covid_outcome_b i.mois_interview_step1 i.native_language2 i.respi_allergy_medical i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*
testparm _Inative*		//p= 0.0631
testparm _Irespi*
testparm _Icovid_beh_*
testparm _Icovid_vac*

// STEP 14
xi : firthlogit covid_outcome_b i.mois_interview_step1 i.respi_allergy_medical i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99,or
testparm _Imois_*			// p<0.0001
testparm _Irespi*			// p=0.0080
testparm _Icovid_beh_*		// p=0.0364
testparm _Icovid_vac*		// p<0.0001

/*                                                      Number of obs =    641
                                                        Wald chi2(8)  =  90.42
Penalized log likelihood = -356.9853                    Prob > chi2   = 0.0000

--------------------------------------------------------------------------------
covid_outcom~b | Odds ratio   Std. err.      z    P>|z|     [95% conf. interval]
---------------+----------------------------------------------------------------
 _Imois_inte_4 |          1  (omitted)
 _Imois_inte_5 |          1  (omitted)
 _Imois_inte_6 |          1  (omitted)
_Imois_inte_10 |   4.966951   1.094078     7.28   0.000      3.22548    7.648658
_Imois_inte_11 |   5.639115   1.460585     6.68   0.000     3.394232    9.368723
_Imois_inte_12 |   1.925239   1.018448     1.24   0.216     .6826534    5.429613
 _Irespi_all_1 |   .4593914   .1303562    -2.74   0.006     .2634191    .8011586
_Irespi_all_77 |   10.22337   16.65101     1.43   0.153     .4199761    248.8648
 _Icovid_beh_1 |   .3496016   .1592198    -2.31   0.021     .1431887    .8535678
_Icovid_beh_99 |   .0532249   .0939458    -1.66   0.097     .0016737    1.692572
 _Icovid_vac_1 |   .2721512   .0532085    -6.66   0.000     .1855202    .3992356
_Icovid_vac_99 |          1  (omitted)
         _cons |   3.252959   1.538409     2.49   0.013     1.287429    8.219283
-------------------------------------------------------------------------------- */



****************************************************************************************
**# VII. ANALYSES OUTCOME COVID B (Ac anti-N LUMINEX) DANS POPULATION SOURCE **
****************************************************************************************

*---------------------------------------------------------------------
**# 7.1. Analyses Univariée 
*---------------------------------------------------------------------

capture drop selection
	gen selection = 0
	replace selection = 1 if group_date_itw1==1 & covid_outcome_b !=99
	char mois_interview_step1[omit] "4"
	char island[omit] "3"

xi: logistic covid_outcome_b i.island  if selection ==1
xi: svy, subpop(selection): logistic covid_outcome_b i.island if selection ==1
tab  island  covid_outcome_b if selection ==1


*---------------------------------------------------------------------
**# 7.2. Analyse Multivariée sur la 1ère période : Avril à Juin 2021 |
*---------------------------------------------------------------------
capture drop selection
	gen selection = 0
	replace selection = 1 if group_date_itw1==1 & covid_outcome_b !=99
	char mois_interview_step1[omit] "4"
	char island[omit] "3"

svy, subpop(selection): 	tab  mois_interview_step1 covid_outcome_b if selection ==1, ci 
xi: svy, subpop(selection): logistic covid_outcome_b i.mois_interview_step1  //p=0.7390
	
xi: svy, subpop(selection): logistic covid_outcome_b i.gender // p=0.2017

xi: svy, subpop(selection): logistic covid_outcome_b i.age_cat //p=0.8186

xi: svy, subpop(selection): logistic covid_outcome_b i.native_language2 //p=0.5602

xi: svy, subpop(selection): logistic covid_outcome_b i.archipelago // p=0.4136
 
svy, subpop(selection): 	tab island covid_outcome_b if selection ==1, row ci
xi: svy, subpop(selection): logistic covid_outcome_b i.island	// p=0.0507

xi: svy, subpop(selection): logistic covid_outcome_b i.smoking_prst		// p=0.0683
 
xi: svy, subpop(selection): logistic covid_outcome_b i.smoking_everyday_bool	// p= 0.0730
 
xi: svy, subpop(selection): logistic covid_outcome_b i.covid_behavior_safety_distance // p=0.2411
 
xi: svy, subpop(selection): logistic covid_outcome_b i.covid_vaccination_complete 	//p=0.3590
 
xi: svy, subpop(selection): logistic covid_outcome_b i.covid_test_positif		// p=  0.0003
 
xi: svy, subpop(selection): logistic covid_outcome_b i.covid_vaccination_explicativebis	//p=0.4439
 
xi: svy, subpop(selection): logistic covid_outcome_b i.covid_vaccination_explicative	//p=0.7360

*---------------------------------------------------------------------
**# 7.3. Analyse Multivariée sur la 2ème période : Juillet à Décembre 2021 |
*---------------------------------------------------------------------
capture drop selection
	gen selection = 0
	replace selection = 1 if group_date_itw1==2 & covid_outcome_b !=99
	char mois_interview_step1[omit] "7"
	char island[omit] "1"
		
svy : 	tab covid_vaccination, ci 
svy, subpop(if covid_vaccination<10): tab covid_vaccination, ci 
svy, subpop(if covid_vaccination<10): tab archipelago covid_vaccination, ci row

	replace selection = 0
	replace selection =1 if covid_vaccination==1 & covid_anti_s<10
	svy, subpop(selection): 	tab covid_vaccination covid_anti_s, ci row

replace selection = 0
replace selection =1 if covid_anti_n<10
svy, subpop(selection): tab archipelago covid_anti_n, ci row
	tab archipelago covid_anti_n if selection ==1, row

	
	svy, subpop(selection): 	tab  mois_interview_step1 covid_outcome_b if selection ==1, ci row
xi: svy, subpop(selection): logistic covid_outcome_b i.mois_interview_step1  //p=  0.0000
	
xi: svy, subpop(selection): logistic covid_outcome_b i.gender // p=  0.6108

xi: svy, subpop(selection): logistic covid_outcome_b i.age_cat //p= 0.0011

xi: svy, subpop(selection): logistic covid_outcome_b i.native_language2 //p=  0.0050
 
	svy, subpop(selection): 	tab island covid_outcome_b if selection ==1, row ci
xi: svy, subpop(selection): logistic covid_outcome_b i.island	// p=  0.6409

xi: svy, subpop(selection): logistic covid_outcome_b i.smoking_prst		// p=  0.7227
 
xi: svy, subpop(selection): logistic covid_outcome_b i.smoking_everyday_bool	// p=  0.4964
 
xi: svy, subpop(selection): logistic covid_outcome_b i.covid_behavior_safety_distance // p=  0.5853**
 
xi: svy, subpop(selection): logistic covid_outcome_b i.covid_behavior_hand_washing // p= 0.0228
 

 
	svy, subpop(selection): 	tab  covid_vaccination_complete covid_outcome_b if selection ==1, ci row
xi: svy, subpop(selection): logistic covid_outcome_b i.covid_vaccination_complete 	//p= 0.0035
 
xi: svy, subpop(selection): logistic covid_outcome_b i.covid_test_positif		// p=  0.0000
 
xi: svy, subpop(selection): logistic covid_outcome_b i.covid_vaccination_explicative	//p= 0.0000
	
	
	
	
	***
	
xi: svy, subpop(selection): logistic covid_outcome_b i.mois_interview_step1 i.covid_vaccination_explicative i.native_language2 i.age_cat 	//p= 0.0000
testparm _Imois*	
testparm _Icovid_vac*
testparm _Inative*
testparm _Iage*		// p=0.7686

xi: svy, subpop(selection): logistic covid_outcome_b i.mois_interview_step1 i.covid_vaccination_explicative i.native_language2 //p= 0.0000
testparm _Imois*	
testparm _Icovid_vac*
testparm _Inative*


****BAC A SABLE

gen duree_vacci_itw =.
	replace duree_vacci_itw = dofc(date_interview_step1) - covid_first_injection_date if covid_first_injection_date!=.
	replace duree_vacci_itw =. if duree_vacci_itw <0		// 1 sujet a donné sa date de vaccination à venir ; il est considéré ici comme non vacciné

	sum duree_vacci_itw if covid_outcome_b !=99, d
	sum duree_vacci_itw , d
	bysort group_date_itw1: 	sum duree_vacci_itw if covid_outcome_b !=99, d
	bysort group_date_itw1: 	sum duree_vacci_itw , d
	sum duree_vacci_itw if covid_outcome_b !=99 & group_date_itw1==1 ,d
	sum duree_vacci_itw if covid_outcome_b !=99 & group_date_itw1==1 & covid_outcome_b ==1,d

	*************************

xi : logistic covid_outcome_b i.mois_interview_step1 i.respi_allergy_medical i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99 & respi_allergy_medical <10 & covid_behavior_hand_washing < 10
/*
Logistic regression                                     Number of obs =    636
                                                        LR chi2(6)    = 115.79
                                                        Prob > chi2   = 0.0000
Log likelihood = -364.60642                             Pseudo R2     = 0.1370

---------------------------------------------------------------------------------
covid_outcome_b | Odds ratio   Std. err.      z    P>|z|     [95% conf. interval]
----------------+----------------------------------------------------------------
  _Imois_inte_4 |          1  (omitted)
  _Imois_inte_5 |          1  (omitted)
  _Imois_inte_6 |          1  (omitted)
 _Imois_inte_10 |   5.072455    1.12551     7.32   0.000     3.283583    7.835892
 _Imois_inte_11 |   5.806896   1.517847     6.73   0.000     3.478974    9.692526
 _Imois_inte_12 |   1.952782   1.059159     1.23   0.217      .674489    5.653697
  _Irespi_all_1 |    .454437   .1303435    -2.75   0.006     .2590172    .7972944
 _Irespi_all_77 |          1  (omitted)
  _Icovid_beh_1 |   .3290176   .1541437    -2.37   0.018     .1313511    .8241466
 _Icovid_beh_99 |          1  (omitted)
  _Icovid_vac_1 |   .2667922   .0525893    -6.70   0.000     .1812954    .3926084
 _Icovid_vac_99 |          1  (omitted)
          _cons |   3.456953   1.678716     2.55   0.011     1.334582    8.954508
--------------------------------------------------------------------------------- */

gen july = 0
	replace july = 1 if mois_interview_step1==7


xi : logistic covid_outcome_b i.july i.respi_allergy_medical i.covid_behavior_hand_washing i.covid_vaccination_explicative  if group_date_itw1==2 & covid_outcome_b !=99 & respi_allergy_medical <10 & covid_behavior_hand_washing < 10
**********

xi : sw logistic covid_outcome_b (i.july) (i.age_cat) (i.native_language2) (i.socio_cultural) (i.town_classif_3) (i.max_school2) (i.pro_act_last_year3) (i.nhouse_tot_classif3) (i.house_clean_water) (i.obesity_who_bool) (i.hypertension_bool) (i.diabete_bool) (i.respi_allergy_medical) (i.cancer_or_malignant_tumor_medica) (i.covid_behavior_hand_washing) (i.covid_behavior_mask) (i.covid_vaccination_explicative)  if group_date_itw1==2 & covid_outcome_b !=99 & obesity_who_bool <10 & hypertension_bool <10 & respi_allergy_medical <10 & covid_behavior_hand_washing < 10 & covid_behavior_mask<10 & group_date_itw1==2,pr(0.05) lr	


// town_classif_3 et sans native languague
xi : sw logistic covid_outcome_b (i.july) (i.age_cat) (i.socio_cultural) (i.town_classif_3) (i.max_school2) (i.pro_act_last_year3) (i.nhouse_tot_classif3) (i.house_clean_water) (i.obesity_who_bool) (i.hypertension_bool) (i.diabete_bool) (i.respi_allergy_medical) (i.cancer_or_malignant_tumor_medica) (i.covid_behavior_hand_washing) (i.covid_behavior_mask) (i.covid_vaccination_explicative)  if group_date_itw1==2 & covid_outcome_b !=99 & obesity_who_bool <10 & hypertension_bool <10 & respi_allergy_medical <10 & covid_behavior_hand_washing < 10 & covid_behavior_mask<10 ,pr(0.05) lr	


/*Logistic regression                                     Number of obs =    630
                                                        LR chi2(9)    = 124.96
                                                        Prob > chi2   = 0.0000
Log likelihood = -355.68522                             Pseudo R2     = 0.1494

---------------------------------------------------------------------------------
covid_outcome_b | Odds ratio   Std. err.      z    P>|z|     [95% conf. interval]
----------------+----------------------------------------------------------------
       _Ijuly_1 |   .2089621   .0426697    -7.67   0.000     .1400405    .3118039
  _Icovid_beh_1 |   .3552501    .168823    -2.18   0.029     .1399664    .9016638
  _Isocio_cul_2 |   .4891964   .2044252    -1.71   0.087     .2156669    1.109642
  _Isocio_cul_3 |   .2027156   .1773522    -1.82   0.068     .0364911    1.126128
  _Isocio_cul_4 |   .6094426   .1270401    -2.38   0.018     .4050395    .9169979
  _Isocio_cul_5 |   2.156909   2.503321     0.66   0.508     .2217802    20.97689
 _Isocio_cul_77 |   .3089615   .2404564    -1.51   0.131     .0672105    1.420272
  _Irespi_all_1 |   .4748782   .1395244    -2.53   0.011     .2669869    .8446457
  _Icovid_vac_1 |   .2839711   .0567883    -6.30   0.000     .1918897    .4202393
          _cons |   18.92802   9.502126     5.86   0.000     7.076044    50.63141
---------------------------------------------------------------------------------*/





 *export excel using "03b_MATA EA_ANALYSES COVID.xlsx", firstrow(variables)
