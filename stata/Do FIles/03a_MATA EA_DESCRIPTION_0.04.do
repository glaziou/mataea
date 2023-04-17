*****************************************************************************
*   					Projet MATA'EA										*
* 			Cartographie de l'état de santé de la 							*
* 			population de la Polynésie française							*
*																			*
*					 		Fichier 03a										*
*					DESCRIPTION ECHANTILLON									*
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


codebook subjid

tab geo_strate gender, chi2 row column exact

tab archipelago gender, chi2 col

tab consent_read gender, chi2 row column exact
	bysort geo_strate : tab consent_read gender, chi2 row column exact
gen groupe1=1
	replace groupe1=0 if consent_read=="NA_STEP1;NA_STEP3;Yes_STEP6"
	tab groupe1 geo_strate,chi2 m col
	drop groupe1
	
sum age, d
	by geo_strate : sum age, d
	kwallis age, by(geo_strate)

	bysort gender: sum age,d
	ttest age, by(gender)
	ranksum age, by(gender)
	
	bysort geo_strate gender : sum age, d
	bysort geo_strate : ttest age, by(gender)
	bysort geo_strate : ranksum age, by(gender)		
	
tab age_cat gender, chi2 col 
	bysort geo_strate : tab age_cat gender, chi2 col

tab civil_state2 gender, m chi2 col
tab civil_state3 gender, m chi2 col
	bysort geo_strate : tab civil_state3 gender, m chi2 col

tab max_school2 gender, m chi2 col
	bysort geo_strate : tab max_school2 gender, m chi2 col

tab socio_cultural gender,m chi2 col
	bysort geo_strate : tab socio_cultural gender, m chi2 col

tab socio_cultural_prec if socio_cultural=="Other",m

tab pro_act_last_year2 gender,m chi2 col
	bysort geo_strate : tab pro_act_last_year2 gender, m chi2 col

tab sensi_questions_mental_health_co gender, m chi2 col

tab sensi_question_sex_consent gender, m chi2 col

tab sensi_questions_woman gender, m chi2 col

*** CONSO TABAC****
tab smoking_prst gender, chi2 row col

	gen smoking_everyday_temp = smoking_everyday
	recode smoking_everyday_temp (.=0) (2=0)
tab smoking_everyday_temp gender, chi2 row col

bysort age_cat: tab smoking_prst gender, chi2 col
tab age_cat smoking_prst, chi2 row
	recode smoking_prst (2=0)
	tabodds smoking_prst age_cat
	recode smoking_prst (0=2)
	
bysort age_cat: tab smoking_everyday_temp gender, chi2 col
tab smoking_everyday_temp gender, chi2 row col
tab age_cat smoking_everyday_temp, chi2 row
	tabodds smoking_prst age_cat

bysort age_cat : tab smoking_type gender, chi2 col
	tab smoking_type gender, chi2 col
	
bysort age_cat : sum ntabaco_per_day_equ if smoking_prst==1,d
bysort age_cat : sum ntabaco_per_day_equ if smoking_prst==1 & gender==1,d
bysort age_cat : sum ntabaco_per_day_equ if smoking_prst==1 & gender==2,d
sum ntabaco_per_day_equ if smoking_prst==1 & gender==2,d
sum ntabaco_per_day_equ if smoking_prst==1 & gender==1,d
sum ntabaco_per_day_equ if smoking_prst==1,d

ranksum ntabaco_per_day_equ if smoking_prst==1, by (gender)
kwallis ntabaco_per_day_equ if smoking_prst==1, by(age_cat)
nptrend ntabaco_per_day_equ if smoking_prst==1, group(age_cat) cuzick

bysort geo_strate : tab smoking_prst gender, chi2 row col
tab geo_strate smoking_prst, chi2 row exact

bysort geo_strate : sum ntabaco_per_day_equ if smoking_prst==1,d
bysort geo_strate : sum ntabaco_per_day_equ if smoking_prst==1 & gender==1,d
bysort geo_strate : sum ntabaco_per_day_equ if smoking_prst==1 & gender==2,d
sum ntabaco_per_day_equ if smoking_prst==1 & gender==2,d
sum ntabaco_per_day_equ if smoking_prst==1 & gender==1,d
sum ntabaco_per_day_equ if smoking_prst==1,d

kwallis ntabaco_per_day_equ, by(geo_strate)
