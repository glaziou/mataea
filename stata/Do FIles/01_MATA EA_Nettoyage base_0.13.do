*****************************************************************************
*   			  		  Projet MATA'EA									*
* 			  Cartographie de l'état de santé de la 						*
* 			   population de la Polynésie française							*
*																			*
*					 		Fichier 01										*
*				Nettoyage et formattage de la base 							*
*																			*
*																			*
*																			*
* 	auteur : Vincent Mendiboure												*
* 	dernier update : 31 octobre 2022										*
*																			*
*****************************************************************************

*cd "Z:\donnees\Stata"
 cd "C:\Users\Mendiboure\Documents\Master PH\Stage Pasteur\image\donnees\Stata"

clear
import delimited using "mataea_full_database.tsv"


***************************************************************
**# SUPPRESSION DES 2 PARTICIPANTS SANS CONSENTEMENT #1
***************************************************************

tab consent_read	
	* 2 participants sans consentement
	* subjid = TA8279ILM (Refus)
	* subjid = TA8297ILM  (Refus)
	* 1,148 avec consentement STEP 6
	* 794 avec consentement STEP 1 et STEP 3
drop if consent_read=="NA_STEP1;NA_STEP3;No_STEP6" 


***************************************************************
**# RECHERCHE DES DONNEES MANQUANTES #2
***************************************************************
*cf. versions précédentes

***************************************************************
**# VERIFICATION DES 5 CONSENTEMENTS SECONDAIRES  #3
***************************************************************

*** phys_measure_consent
* variable utilisée que pour le 1er groupe
gen temp_filtre=0
	replace temp_filtre=1 if consent_read=="Yes_STEP1;Yes_STEP3;NA_STEP6" & phys_measure_consent=="NA"

gen temp_critere=0
	replace temp_critere=1 if tensiometer_id!= "NA" | armband_width!= "NA" | bp_systolic_1!= "NA" | bp_diastolic_1!= "NA" | bp_systolic_2!= "NA" | bp_diastolic_2!= "NA" | bp_systolic_3!= "NA" | bp_diastolic_3!= "NA" | drug_for_hypertension!= "NA" | bp_systolic_mean!= "NA" | bp_diastolic_mean!= "NA" | pregnancy!= "NA" | interviewer_id_step2_2!= "NA" | height_gauge_id!= "NA" | bathroom_scale_id!= "NA" | height!= "NA" | weight!= "NA" | bmi!= "NA" | tape_measure_id!= "NA" | abdocm!= "NA" 
	
		tab subjid if temp_filtre==1 & temp_critere==1 
		* pas d'incoherence consentemnt versus données physique 
		drop temp_critere
		drop temp_filtre
 
 
*** biochim_measure_consent
* variable utilisée que pour le 1er groupe
gen temp_filtre=0
	replace temp_filtre=1 if consent_read=="Yes_STEP1;Yes_STEP3;NA_STEP6" & biochim_measure_consent =="NA" | biochim_measure_consent=="No"

gen temp_critere=0
	replace temp_critere=1 if anything_except_water_12h!= "NA" | technical_staff_id!= "NA" | device_id_1!= "NA" | blood_harvesting_hour!= "NA" | drug_for_diabetes!= "NA" | glycemia!= "NA" | fasting_before_urine!= "NA" | urine_harvesting_hour!= "NA" 

		tab subjid if temp_filtre==1 & temp_critere==1
		* pas d'incoherence consentement versus données 
		* TECHNICAL_STAFF_ID et DEVICE_ID_1 renseignés pour RG0084ILM
		drop temp_critere
		drop temp_filtre


*** sensi_questions_mental_health_co
gen temp_filtre=0
	replace temp_filtre=1 if sensi_questions_mental_health_co =="NA" | sensi_questions_mental_health_co =="No"

gen temp_critere=0
	replace temp_critere=1 if no_pleasure_or_interest_doing_th!= "NA" | depressed!= "NA" | difficulty_sleeping!= "NA" | asthenia!= "NA" | apetite_perturbation!= "NA" | bad_self_opinion!= "NA" | difficulty_focusing!= "NA" | talk_speed_perturbation!= "NA" | self_injury_thinking!= "NA" | depression_impact!= "NA" 
	
	tab subjid if temp_filtre==1 & temp_critere==1
	*browse subjid no_pleasure_or_interest_doing_th depressed difficulty_sleeping asthenia apetite_perturbation bad_self_opinion difficulty_focusing talk_speed_perturbation self_injury_thinking depression_impact if temp_filtre==1 & temp_critere==1	
	* 20 observations avec consent = NA et des données sur la santé mentale
*Correction Journal#25-34
	replace sensi_questions_mental_health_co="Yes" if temp_filtre==1 & temp_critere==1
	drop temp_critere
	drop temp_filtre


*** sensi_question_sex_consent
gen temp_filtre=0
	replace temp_filtre=1 if sensi_question_sex_consent=="No" | sensi_question_sex_consent =="NA"

gen temp_critere=0
	replace temp_critere=1 if sex!= "NA" | age_first_sex!= "NA" | condom_during_first_sex!= "NA" | condom_during_occasional_sex!= "NA" | ist_mst!= "NA"

		tab subjid if temp_filtre==1 & temp_critere==1
		* pas d'incoherence consentement versus données 
		drop temp_critere
		drop temp_filtre


*** sensi_questions_woman
gen temp_filtre=0
	replace temp_filtre=1 if sensi_questions_woman=="No" | sensi_questions_woman =="NA"

gen temp_critere=0
	replace temp_critere=1 if age_first_menstrual_period!= "NA" | contraception!= "NA" | contraception_prec!= "NA" | menopause!= "NA" | menopause_age!= "NA" | npregnancies!= "NA" | n_miscarry!= "NA"
	
		tab subjid if temp_filtre==1 & temp_critere==1
		* pas d'incoherence consentement versus données 
		drop temp_critere
		drop temp_filtre

	
***************************************************************
**# MODIFICATIONS BASEES SUR FICHIER IOTEFA #4
***************************************************************

*1. Selon la période d'inclusion, la date d'entretien ne se trouve pas dans la même colonne. Il faudrait fusionner les deux colonnes pour que la date se trouve dans la même colonne.
replace date_interview_step1=date_interview if consent_read=="NA_STEP1;NA_STEP3;Yes_STEP6"
	drop date_interview

*2.	Idem pour :  INVESTIGATOR_ID_STEP1 et INVESTIGATOR_ID 
replace investigator_id_step1=investigator_id if consent_read=="NA_STEP1;NA_STEP3;Yes_STEP6"
	drop investigator_id

* "3.Il manque la donnée DATE_INTERVIEW_STEP1 pour le participant BO0141ILM : la valeur affichée devrait être 2019-11-15T14:43:00Z."
replace date_interview_step1="2019-11-15T14:43:00Z" if subjid=="BO0141ILM"

* 4. Modifier la valeur DATE_INTERVIEW_STEP1 pour le participant RA0167ILM en 2019-11-04T16:21:00Z au lieu de 2019-11-03T10:38:00Z. Cela a son importance car la toute première inclusion du projet a eu lieu le lundi 04/11/19.
tab date_interview_step1 if subjid =="RA0167ILM"
replace date_interview_step1="2019-11-04T16:21:00Z" if subjid=="RA0167ILM"

* 5. Uniformiser la variable GENDER
replace gender="Female" if gender=="Woman"
replace gender="Male" if gender=="Man"

* 8. Rectifier la question CONDOM_DURING_OCCASIONAL_SEX (#183 SH4)
replace condom_during_occasional_sex="Sometimes" if condom_during_occasional_sex=="Dont have occasional sex"
replace condom_during_occasional_sex="Dont have occasional sex" if condom_during_occasional_sex=="4"

	
***************************************************************
**# REVUE DES FORMATS, DES MODALITES ET DES DICTIONNAIRES #5
***************************************************************

label define lbyesno 2 No 1 Yes 77 "Dont know" 88 "Dont want to answer" 99 "Missing data"

* RECODAGE DATE INTERVIEW I4 date_interview_step1
generate double TEMP_VAR = clock(date_interview_step1,"YMD#hm#")
	format TEMP_VAR %tcDD-Mon-YY
	order TEMP_VAR, after(date_interview_step1)
	drop date_interview_step1
	rename TEMP_VAR date_interview_step1

** INFORMATIONS DEMOGRAPHIQUES 
encode language, gen(TEMP_VAR) label(lblanguage)
	order TEMP_VAR, after(language)
	drop language
	rename TEMP_VAR language
	
	* RECODAGE GENDER C1
label define lbgender 1 Male 2 Female
	encode gender, gen(TEMP_VAR) label(lbgender) noextend
		order TEMP_VAR, after(gender)
		drop gender
		rename TEMP_VAR gender

destring age, replace

replace nschool_years = "99" if nschool_years=="NA" 
	destring nschool_years, replace

	label define lbmaxschool 1 "No official instruction" 2 "Less than primary school" 3 "End of primary school" 4 "End of secundary school" 5 "End of lycee or equivalent" 6 "University or equivalent" 7 "Diploma after university" 88 "Dont want to answer"
encode max_school, gen(TEMP_VAR) label(lbmaxschool)
	order TEMP_VAR, after(max_school)
	drop max_school
	rename TEMP_VAR max_school

	label define lbbirthlocation 987 "French Polynesia" 1 "France but no Polynesia" 2 "Other"	
encode birth_location, gen(TEMP_VAR) label(lbbirthlocation)
	order TEMP_VAR, after(birth_location)
	drop birth_location
	rename TEMP_VAR birth_location

	label define lbcivil_state 1 "Never married" 2 "Married" 3 "Separated" 4 "Divorced" 5 "Widower" 6 "Cohabitation" 88 "Dont want to answer"
encode civil_state, gen(TEMP_VAR) label(lbcivil_state)
	order TEMP_VAR, after(civil_state)
	drop civil_state
	rename TEMP_VAR civil_state
	
	label define lbproactlastyear 1 "Administration employee" 2 "Private employee" 3 "Independant" 4 "Volunteer" 5 "Student" 6 "Housewive" 7 "Retired"  8 "Unemployed" 9 "Disabled" 
encode pro_act_last_year, gen(TEMP_VAR) label(lbproactlastyear)
	order TEMP_VAR, after(pro_act_last_year)
	drop pro_act_last_year
	rename TEMP_VAR pro_act_last_year
	
destring nhouse_people, replace

destring nhouse_people_tot, replace

** CONSOMMATION DE TABAC
encode smoking_prst, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(smoking_prst)
	drop smoking_prst
	rename TEMP_VAR smoking_prst

replace smoking_everyday="Missing data" if smoking_everyday=="NA"
encode smoking_everyday, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(smoking_everyday)
	drop smoking_everyday
	rename TEMP_VAR smoking_everyday

replace smoking_start_age="99" if smoking_start_age=="NA"
	replace smoking_start_age="77" if smoking_start_age=="Dont know"
	destring smoking_start_age, replace

* smoking_start_num - variable pas utilisée (groupe 1 uniquement)
* smoking_start_prec - variable pas utilisée (groupe 1 uniquement)

replace ncigaret_indust_per_day="" if ncigaret_indust_per_day=="NA"
	replace ncigaret_indust_per_day="77" if ncigaret_indust_per_day=="Dont know"
	destring ncigaret_indust_per_day, replace

	* ERREUR dans 12 observations de ncigaret_indust_per_week ('Dont know7' au lieu de 'Dont know')
* Corrections des town_name Journal#17
replace ncigaret_indust_per_week="Dont know" if ncigaret_indust_per_week=="Dont know7" 

replace ncigaret_indust_per_week="" if ncigaret_indust_per_week=="NA"
	replace ncigaret_indust_per_week="77" if ncigaret_indust_per_week=="Dont know"
	destring ncigaret_indust_per_week, replace

replace ncigaret_roll_per_day="" if ncigaret_roll_per_day=="NA"
	replace ncigaret_roll_per_day="77" if ncigaret_roll_per_day=="Dont know"
	destring ncigaret_roll_per_day, replace

* ERREUR 1 observations de ncigaret_roll_per_week ('Dont know7' au lieu de 'Dont know')
replace ncigaret_roll_per_week="Dont know" if ncigaret_roll_per_week=="Dont know7" 

replace ncigaret_roll_per_week="" if ncigaret_roll_per_week=="NA"
	replace ncigaret_roll_per_week="77" if ncigaret_roll_per_week=="Dont know"
	destring ncigaret_roll_per_week, replace

replace other_tabaco_per_day="" if other_tabaco_per_day=="NA"
	replace other_tabaco_per_day="77" if other_tabaco_per_day=="Dont know"
	destring other_tabaco_per_day, replace

replace other_tabaco_per_week="" if other_tabaco_per_week=="NA"
	replace other_tabaco_per_week="77" if other_tabaco_per_week=="Dont know"
	replace other_tabaco_per_week="77" if other_tabaco_per_week=="777"
	destring other_tabaco_per_week, replace
	
	*other_tabaco_prec
	*other_tabaco_prec_bis
	*smoking_stop_try_last_year
	*smoking_stop_advice_last_year
	*smoking_past
	*smoking_past_everyday
	*smoking_passive_home
	*smoking_passive_work

** CONSOMMATION DE PAKA
encode paka, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(paka)
	drop paka
	rename TEMP_VAR paka

replace paka_start_age="99" if paka_start_age=="NA"
	replace paka_start_age="77" if paka_start_age=="Dont know"
	destring paka_start_age, replace

replace paka_last_year="Missing data" if paka_last_year=="NA"
encode paka_last_year, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(paka_last_year)
	drop paka_last_year
	rename TEMP_VAR paka_last_year

	*paka_last_year_freq

replace paka_age_once_per_week="99" if paka_age_once_per_week=="NA"
	replace paka_age_once_per_week="77" if paka_age_once_per_week=="Dont know"
	replace paka_age_once_per_week="99" if paka_age_once_per_week=="Never"
	destring paka_age_once_per_week, replace

	*alcool_while_paka

** ALCOOL
encode alcool, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(alcool)
	drop alcool
	rename TEMP_VAR alcool

replace alcool_last_year="Missing data" if alcool_last_year=="NA"
encode alcool_last_year, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(alcool_last_year)
	drop alcool_last_year
	rename TEMP_VAR alcool_last_year

replace alcool_medical_stop="Missing data" if alcool_medical_stop=="NA"
encode alcool_medical_stop, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(alcool_medical_stop)
	drop alcool_medical_stop
	rename TEMP_VAR alcool_medical_stop

replace alcool_one_glass_last_year_freq="Missing data" if alcool_one_glass_last_year_freq=="NA"
label define lbalcooloneglass 1 Daily 2 "5 yo 6 days per week" 3 "3 to 4 days per week" 4 "1 to 2 days per week" 5 "1 to 3 days per month" 6 "Less than once a month" 7 "Never" 99 "Missing data"
encode alcool_one_glass_last_year_freq, gen(TEMP_VAR) label(lbalcooloneglass) noextend
	order TEMP_VAR, after(alcool_one_glass_last_year_freq)
	drop alcool_one_glass_last_year_freq
	rename TEMP_VAR alcool_one_glass_last_year_freq

replace alcool_last_month="Missing data" if alcool_last_month=="NA"
encode alcool_last_month, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(alcool_last_month)
	drop alcool_last_month
	rename TEMP_VAR alcool_last_month

replace nalcool_glass_last_month="" if nalcool_glass_last_month=="NA"
	replace nalcool_glass_last_month="77" if nalcool_glass_last_month=="Dont know"
	destring nalcool_glass_last_month, replace
	
replace nmax_alcool_glass_last_month="" if nmax_alcool_glass_last_month=="NA"
	replace nmax_alcool_glass_last_month="77" if nmax_alcool_glass_last_month=="Dont know"
	destring nmax_alcool_glass_last_month, replace

replace alcool_six_glass_last_month_freq="" if alcool_six_glass_last_month_freq=="NA"
	replace alcool_six_glass_last_month_freq="77" if alcool_six_glass_last_month_freq=="Dont know"
	destring alcool_six_glass_last_month_freq, replace

replace nalcool_glass_last_monday="" if nalcool_glass_last_monday=="NA"
	replace nalcool_glass_last_monday="77" if nalcool_glass_last_monday=="Dont know"
	destring nalcool_glass_last_monday, replace

replace nalcool_glass_last_tuesday="" if nalcool_glass_last_tuesday=="NA"
	replace nalcool_glass_last_tuesday="77" if nalcool_glass_last_tuesday=="Dont know"
	destring nalcool_glass_last_tuesday, replace

replace nalcool_glass_last_wednesday="" if nalcool_glass_last_wednesday=="NA"
	replace nalcool_glass_last_wednesday="77" if nalcool_glass_last_wednesday=="Dont know"
	destring nalcool_glass_last_wednesday, replace

replace nalcool_glass_last_thursday="" if nalcool_glass_last_thursday=="NA"
	replace nalcool_glass_last_thursday="77" if nalcool_glass_last_thursday=="Dont know"
	destring alcool_six_glass_last_month_freq, replace

replace nalcool_glass_last_friday="" if nalcool_glass_last_friday=="NA"
	replace nalcool_glass_last_friday="77" if nalcool_glass_last_friday=="Dont know"
	destring nalcool_glass_last_friday, replace

replace nalcool_glass_last_saturday="" if nalcool_glass_last_saturday=="NA"
	replace nalcool_glass_last_saturday="77" if nalcool_glass_last_saturday=="Dont know"
	destring nalcool_glass_last_saturday, replace

replace nalcool_glass_last_sunday="" if nalcool_glass_last_sunday=="NA"
	replace nalcool_glass_last_sunday="77" if nalcool_glass_last_sunday=="Dont know"
	destring nalcool_glass_last_sunday, replace

replace social_pb_alcool_last_year="Missing data" if social_pb_alcool_last_year=="NA"
label define lbsocialpb 1 "Yes, more than once a month" 2 "Yes, each month" 3 "Yes, many times but less than once a month" 4 "Yes, once or twice" 5 "No" 99 "Missing data"
encode social_pb_alcool_last_year, gen(TEMP_VAR) label(lbsocialpb) noextend
	order TEMP_VAR, after(social_pb_alcool_last_year)
	drop social_pb_alcool_last_year
	rename TEMP_VAR social_pb_alcool_last_year

** HYGIENE ALIMENTAIRE	
replace 	 fruit_nday_per_week ="" if fruit_nday_per_week =="Dont know"
	destring fruit_nday_per_week, replace

replace 	 nfruit_per_day ="0" if fruit_nday_per_week ==0
	replace  nfruit_per_day =""  if nfruit_per_day =="NA" | nfruit_per_day=="Dont know"
	destring nfruit_per_day, replace

replace 	 vege_nday_per_week ="" if vege_nday_per_week =="Dont know"
	destring vege_nday_per_week, replace

replace 	 nvege_per_day ="0" if vege_nday_per_week ==0
	replace  nvege_per_day ="" if nvege_per_day =="NA" | nvege_per_day=="Dont know"
	destring nvege_per_day, replace

replace 	 meat_nday_per_week ="" if meat_nday_per_week =="Dont know"
	destring meat_nday_per_week, replace

replace 	 nmeat_per_day ="0" if meat_nday_per_week ==0
	replace  nmeat_per_day ="" if nmeat_per_day =="NA" | nmeat_per_day=="Dont know"
	destring nmeat_per_day, replace

replace 	 fish_nday_per_week ="" if fish_nday_per_week =="Dont know"
	destring fish_nday_per_week, replace

replace 	 nfish_per_day ="0" if fish_nday_per_week ==0
	replace  nfish_per_day ="" if nfish_per_day =="NA" | nfish_per_day=="Dont know"
	destring nfish_per_day, replace

	label define lbsaltquantity 1 "Really too much" 2 "Too much" 3 "Just the right amount" 4 "Too few" 5 "Really too few" 77 "Dont know" 
encode salt_quantity, gen(TEMP_VAR) label(lbsaltquantity) noextend
	order TEMP_VAR, after(salt_quantity)
	drop salt_quantity
	rename TEMP_VAR salt_quantity

replace 	 nsweet_drink_glass_per_day ="99" if nsweet_drink_glass_per_day =="Dont know" | nsweet_drink_glass_per_day =="Dont want to answer" | nsweet_drink_glass_per_day =="NA"
	destring nsweet_drink_glass_per_day, replace	
		
** ACTIVITE PHYSIQUE
encode phys_act_hard_work, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(phys_act_hard_work)
	drop phys_act_hard_work
	rename TEMP_VAR phys_act_hard_work
replace phys_act_hard_per_week="" if phys_act_hard_per_week=="NA" | phys_act_hard_per_week == "Dont know"
	destring phys_act_hard_per_week, replace
replace phys_act_hard_hour="" if phys_act_hard_hour=="NA" | phys_act_hard_hour == "Dont know"
	destring phys_act_hard_hour, replace
replace phys_act_hard_minute="" if phys_act_hard_minute=="NA" | phys_act_hard_minute == "Dont know"
	destring phys_act_hard_minute, replace
	
encode phys_act_medium_work, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(phys_act_medium_work)
	drop phys_act_medium_work
	rename TEMP_VAR phys_act_medium_work
replace phys_act_medium_per_week="" if phys_act_medium_per_week=="NA" | phys_act_medium_per_week == "Dont know"
	destring phys_act_medium_per_week, replace
replace phys_act_medium_hour="" if phys_act_medium_hour=="NA" | phys_act_medium_hour == "Dont know"
	destring phys_act_medium_hour, replace
replace phys_act_medium_minute="" if phys_act_medium_minute=="NA" | phys_act_medium_minute == "Dont know"
	destring phys_act_medium_minute, replace

encode velo_or_walk, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(velo_or_walk)
	drop velo_or_walk
	rename TEMP_VAR velo_or_walk
replace velo_or_walk_freq="" if velo_or_walk_freq=="NA" | velo_or_walk_freq == "Dont know"
	destring velo_or_walk_freq, replace
replace velo_or_walk_hour="" if velo_or_walk_hour=="NA" | velo_or_walk_hour == "Dont know"
	destring velo_or_walk_hour, replace
replace velo_or_walk_minute="" if velo_or_walk_minute=="NA" | velo_or_walk_minute == "Dont know"
	destring velo_or_walk_minute, replace

encode phys_act_hard_leisure, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(phys_act_hard_leisure)
	drop phys_act_hard_leisure
	rename TEMP_VAR phys_act_hard_leisure
replace phys_act_hard_leisure_per_week="" if phys_act_hard_leisure_per_week=="NA" | phys_act_hard_leisure_per_week == "Dont know"
	destring phys_act_hard_leisure_per_week, replace
replace phys_act_hard_leisure_hour="" if phys_act_hard_leisure_hour=="NA" | phys_act_hard_leisure_hour == "Dont know"
	destring phys_act_hard_leisure_hour, replace
replace phys_act_hard_leisure_minute="" if phys_act_hard_leisure_minute=="NA" | phys_act_hard_leisure_minute == "Dont know"
	destring phys_act_hard_leisure_minute, replace

encode phys_act_medium_leisure, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(phys_act_medium_leisure)
	drop phys_act_medium_leisure
	rename TEMP_VAR phys_act_medium_leisure
replace phys_act_medium_leisure_per_week="" if phys_act_medium_leisure_per_week=="NA" | phys_act_medium_leisure_per_week == "Dont know"
	destring phys_act_medium_leisure_per_week, replace
replace phys_act_medium_leisure_hour="" if phys_act_medium_leisure_hour=="NA" | phys_act_medium_leisure_hour == "Dont know"
	destring phys_act_medium_leisure_hour, replace
replace phys_act_medium_leisure_minute="" if phys_act_medium_leisure_minute=="NA" | phys_act_medium_leisure_minute == "Dont know"
	destring phys_act_medium_leisure_minute, replace

** QUESTIONNAIRE DE QUALITE DE VIE
	label define lbexcellentbad 1 Excellent 2 "Very good" 3 "Good" 4 Bad 5 "Very bad"
encode health_status, gen(TEMP_VAR) label(lbexcellentbad) noextend
	order TEMP_VAR, after(health_status)
	drop health_status
	rename TEMP_VAR health_status
	label var health_status "Perception of one's health"
	
gen health_status2 = health_status
	recode health_status2 (2=1) (3=2) (4=3) (5=3)
	label define lbexcellentbad2 1 "Excellent to Very good" 2 "Good" 3 "Bad to Very bad"
	label values health_status2 lbexcellentbad2
	order health_status2, after(health_status)
	label var health_status2 "Perception of one's health"
	
** ANTECEDENTS DE TENSION ARTERIELLE ELEVEE 
encode art_tension_measured, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(art_tension_measured)
	drop art_tension_measured
	rename TEMP_VAR art_tension_measured

replace hypertension_measured="Missing data" if hypertension_measured=="NA"
encode hypertension_measured, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(hypertension_measured)
	drop hypertension_measured
	rename TEMP_VAR hypertension_measured

replace hypertension_measured_last_year="Missing data" if hypertension_measured_last_year=="NA"
encode hypertension_measured_last_year, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(hypertension_measured_last_year)
	drop hypertension_measured_last_year
	rename TEMP_VAR hypertension_measured_last_year
	
replace art_tension_medic_last_2weeks="Missing data" if art_tension_medic_last_2weeks=="NA"
encode art_tension_medic_last_2weeks, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(art_tension_medic_last_2weeks)
	drop art_tension_medic_last_2weeks
	rename TEMP_VAR art_tension_medic_last_2weeks

replace art_tension_tahua="Missing data" if art_tension_tahua=="NA"
encode art_tension_tahua, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(art_tension_tahua)
	drop art_tension_tahua
	rename TEMP_VAR art_tension_tahua
	
replace art_tension_tradi_medic="Missing data" if art_tension_tradi_medic=="NA"
encode art_tension_tradi_medic, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(art_tension_tradi_medic)
	drop art_tension_tradi_medic
	rename TEMP_VAR art_tension_tradi_medic	

** LONGUE MALADIE
encode chronic_ald, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(chronic_ald)
	drop chronic_ald
	rename TEMP_VAR chronic_ald	
	
** TENSION ARTERIELLE
replace armband_width = "Extra-large" if armband_width == "Extra large"

replace 	  bp_systolic_1="" if bp_systolic_1=="NA"
	label var bp_systolic_1 "Systolic BP (mmHg) #1"
	destring  bp_systolic_1, replace
replace 	  bp_diastolic_1="" if bp_diastolic_1=="NA"
	label var bp_diastolic_1 "Diastolic BP (mmHg) #1"
	destring  bp_diastolic_1, replace
replace 	  bp_systolic_2="" if bp_systolic_2=="NA"
	label var bp_systolic_2 "Systolic BP (mmHg) #2"
	destring  bp_systolic_2, replace
replace 	  bp_diastolic_2="" if bp_diastolic_2=="NA"
	label var bp_diastolic_2 "Diastolic BP (mmHg) #2"
	destring  bp_diastolic_2, replace
replace 	  bp_systolic_3="" if bp_systolic_3=="NA"
	label var bp_systolic_3 "Systolic BP (mmHg) #3"
	destring  bp_systolic_3, replace
replace 	  bp_diastolic_3="" if bp_diastolic_3=="NA"
	label var bp_diastolic_3 "Diastolic BP (mmHg) #3"
	destring  bp_diastolic_3, replace
replace 	  bp_systolic_mean="" if bp_systolic_mean=="NA"
	label var bp_systolic_mean "Mean systolic BP (mmHg)"
	destring  bp_systolic_mean, replace
replace 	  bp_diastolic_mean="" if bp_diastolic_mean=="NA"
	label var bp_diastolic_mean "Mean diastolic BP (mmHg)"
	destring  bp_diastolic_mean, replace

replace drug_for_hypertension="Missing data" if drug_for_hypertension=="NA"
encode drug_for_hypertension, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(drug_for_hypertension)
	drop drug_for_hypertension
	rename TEMP_VAR drug_for_hypertension

** TAILLE ET POIDS
replace pregnancy="Missing data" if pregnancy=="NA"
	encode pregnancy, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(pregnancy)
	drop pregnancy
	rename TEMP_VAR pregnancy

	*interviewer_id_step2_2
	*height_gauge_id
	*bathroom_scale_id
replace height = "" if height =="NA"
	label var height "Height (cm)"
	destring height, replace
replace weight = "" if weight == "NA" 
	label var weight "Weight (kg)"
	destring weight, replace
replace bmi = "" if bmi =="NA"
	destring bmi, replace

** TOUR DE TAILLE	
	*tape_measure_id
replace abdocm = "" if abdocm=="NA" 
	label var abdocm "Waist circumference (cm)"
	destring abdocm, replace
	
** GLYCEMIE
	*biochim_measure_consent
	*anything_except_water_12h
	*technical_staff_id
	*device_id_1
	*blood_harvesting_hour
replace drug_for_diabetes = "Missing data" if drug_for_diabetes=="NA"
encode drug_for_diabetes, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(drug_for_diabetes)
	drop drug_for_diabetes
	rename TEMP_VAR drug_for_diabetes

replace glycemia = "" if glycemia=="NA"
	label var glycemia "Glycémie à jeun (mg/dl)"
	destring glycemia, replace	
	*fasting_before_urine
	*urine_harvesting_hour

** VOLET IDENTIFICATION - STEP 3
	*home_id
	*investigator_id_step3
	*date_interview_step3

**INFORMATIONS DEMOGRAPHIQUES
	*socio_cultural
	replace socio_cultural = "Missing data" if socio_cultural=="NA"
	label define lbsocialcultural 1 "Polynesian" 2 "Popaa" 3 "Asian" 4 "Demi" 5 "Other" 6 "Marquisian" 77 "Dont know" 88 "Dont want to answer" 99 "Missing data"
encode socio_cultural, gen(TEMP_VAR) label(lbsocialcultural) noextend
	order TEMP_VAR, after(socio_cultural)
	drop socio_cultural
	rename TEMP_VAR socio_cultural

	** Correction Journal#58 & 59
	replace socio_cultural  		= 1 	if inlist(socio_cultural_prec,"Mangarevien","Maohi","Marquisien","Marquisienne","Tahitien")
		replace socio_cultural_prec = "NA"  if inlist(socio_cultural_prec,"Mangarevien","Maohi","Marquisien","Marquisienne","Tahitien")
	
	replace socio_cultural  		= 2 	if inlist(socio_cultural_prec,"Corsica","France")
		replace socio_cultural_prec = "NA"  if inlist(socio_cultural_prec,"Corsica","France")
	
	replace socio_cultural 			= 4 	if inlist(socio_cultural_prec,"Anglais  chinois  tahitien","Chinois  franÃ§ais (breton)  anglais  chilien  tahitien","Chinois  polynesien","Chinois  polynÃ©sien  americain","Chinois  polynÃ©sien  franÃ§ais","Chinois  vietnamienne  fran caise et paumotu","Chinois et polynesien")
		replace socio_cultural_prec = "NA" if inlist(socio_cultural_prec,"Anglais  chinois  tahitien","Chinois  franÃ§ais (breton)  anglais  chilien  tahitien","Chinois  polynesien","Chinois  polynÃ©sien  americain","Chinois  polynÃ©sien  franÃ§ais","Chinois  vietnamienne  fran caise et paumotu","Chinois et polynesien")

	replace socio_cultural 			= 4 if inlist(socio_cultural_prec,"Chinoise  tahitienne  anglaise","Demi chinoise  demi marquisienne","Espagnol  anglais  polynesien","Fran cais  chinois  polynesien","FranÃ§ais  polynesien","Half tahitiana and half chinese metis","HawaÃ¯en  polynÃ©sien  allemand")
		replace socio_cultural_prec = "NA" if inlist(socio_cultural_prec,"Chinoise  tahitienne  anglaise","Demi chinoise  demi marquisienne","Espagnol  anglais  polynesien","Fran cais  chinois  polynesien","FranÃ§ais  polynesien","Half tahitiana and half chinese metis","HawaÃ¯en  polynÃ©sien  allemand")
	
	replace socio_cultural 			= 4 if inlist(socio_cultural_prec,"Interculturel  polynesien-africain surtout","Marquisienne  americaine","NorvÃ©gien  polynÃ©sien  chinois","Nouvelle zelande  angleterre et polynesien","Polynesian but growth with chineses","PolynÃ©sien   rÃ©unionnais et chinois","PolynÃ©sien  popaa  chinois")
		replace socio_cultural_prec = "NA" if inlist(socio_cultural_prec,"Interculturel  polynesien-africain surtout","Marquisienne  americaine","NorvÃ©gien  polynÃ©sien  chinois","Nouvelle zelande  angleterre et polynesien","Polynesian but growth with chineses","PolynÃ©sien   rÃ©unionnais et chinois","PolynÃ©sien  popaa  chinois")
	
	replace socio_cultural 			= 4 if inlist(socio_cultural_prec,"PolynÃ©sien et amÃ©ricain","PolynÃ©sienne et espagnole","Polynesien-popaa","Tahitien  marquisien  neerlandais  rarotonga")
		replace socio_cultural_prec = "NA" if inlist(socio_cultural_prec,"PolynÃ©sien et amÃ©ricain","PolynÃ©sienne et espagnole","Polynesien-popaa","Tahitien  marquisien  neerlandais  rarotonga")
	
	* CREATION D'UNE NOUVELLE VARIABLE EN CLASSANT EN DONNEES MANQUANTES LES REPONSES "DONT KNOW" ET "DONT WANT TO ANSWER"
	gen socio_cultural2 = socio_cultural
		label variable socio_cultural2 "Socio-cultural environment"
		order socio_cultural2, after(socio_cultural)
		recode socio_cultural2 (77=99) (88=99)
		label values socio_cultural2 lbsocialcultural

**HISTORIQUE FAMILIAL
	label define lbbirthplace 1 "French polynesia" 2 "Outside french polynesia"
encode birth_place, gen(TEMP_VAR) label(lbbirthplace)
	order TEMP_VAR, after(birth_place)
	drop birth_place
	rename TEMP_VAR birth_place
	
replace birth_place_prec = "" if birth_place_prec=="NA" 
	destring birth_place_prec, replace

label define lbnativelanguage 1 French 2 Tahitian 3 English 4 Spanish 5 Other
	encode native_language, gen(TEMP_VAR) label(lbnativelanguage) noextend
	order TEMP_VAR, after(native_language)
	drop native_language
	rename TEMP_VAR native_language

/*
**HYGIENE ALIMENTAIRE
meat_nday_per_week
nmeat_per_day
no_more_meat
no_more_meat_prec
fish_nday_per_week
nfish_per_day
no_more_fish
no_more_fish_prec */

**ALLERGIES
encode alim_allergy_medical, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(alim_allergy_medical)
	drop alim_allergy_medical
	rename TEMP_VAR alim_allergy_medical

encode respi_allergy_medical, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(respi_allergy_medical)
	drop respi_allergy_medical
	rename TEMP_VAR respi_allergy_medical

encode skin_allergy_medical, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(skin_allergy_medical)
	drop skin_allergy_medical
	rename TEMP_VAR skin_allergy_medical

**MALADIES RESPIRATOIRES
encode asthma_medical, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(asthma_medical)
	drop asthma_medical
	rename TEMP_VAR asthma_medical

/*
hissing_respi_last_year
hissing_respi_phys_act_last_year
cough_during_3month
coughing_how_long
expectoration_during_3month
expectoration_how_long */

**CANCER
replace cancer_or_malignant_tumor_medica ="Missing data" if cancer_or_malignant_tumor_medica =="Dont know"
encode cancer_or_malignant_tumor_medica, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(cancer_or_malignant_tumor_medica)
	drop cancer_or_malignant_tumor_medica
	rename TEMP_VAR cancer_or_malignant_tumor_medica

	*cancer_type
	*cancer_type_prec

replace cancer_age = "" if cancer_age=="NA" 
replace cancer_age = "" if cancer_age=="Dont know" /*ou bien remplacer par 77 ?*/
	destring cancer_age, replace
	*family_cancer_or_malignant_tumor
	
**HANDICAP
	*limitation_phys_mental_feel
	*blind
	*deaf

**CIGATERA
	label define lbciguaterafreq 0 "Never" 1 "Once" 2 "Twice" 3 "Three times" 4 "Four times" 5 "Between five and nine times" 6 "Ten times or more" 77 "Dont know"
encode ciguatera_freq, gen(TEMP_VAR) label(lbciguaterafreq) noextend
		order TEMP_VAR, after(ciguatera_freq)
		drop ciguatera_freq
		rename TEMP_VAR ciguatera_freq

/*
ciguatera_consultation
ciguatera_no_consult
ciguatera_no_consult_prec
ciguatera_most_severe
ciguatera_how_long_sympt_stop
ciguatera_which_seafood
ciguatera_seafood_origin
ciguatera_warning
fish_consumption_change */

**BIOMARQUEURS DEXPOSITION AUX MOUSTIQUES
label define lbhousetype 1 "House with a garden" 2 "House without garden" 3 "Apartment with a terrace" 
	encode house_type, gen(TEMP_VAR) label(lbhousetype) noextend
	order TEMP_VAR, after(house_type)
	drop house_type
	rename TEMP_VAR house_type
	
encode house_clim, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(house_clim)
	drop house_clim
	rename TEMP_VAR house_clim

	replace house_clean_water ="Missing data" if house_clean_water =="NA"
encode house_clean_water, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(house_clean_water)
	drop house_clean_water
	rename TEMP_VAR house_clean_water

label define lbmosquitobites 1 Never 2 Rarely 3 Often 4 Everyday
	encode mosquito_bites, gen(TEMP_VAR) label(lbmosquitobites) noextend
	order TEMP_VAR, after(mosquito_bites)
	drop mosquito_bites
	rename TEMP_VAR mosquito_bites

* mosquito_protection

/*
**SANTE MENTALE
sensi_questions_mental_health_co
no_pleasure_or_interest_doing_th
depressed
difficulty_sleeping
asthenia
apetite_perturbation
bad_self_opinion
difficulty_focusing
talk_speed_perturbation
self_injury_thinking
depression_impact
*/

**SANTE SEXUELLE
	//sensi_question_sex_consent
	
	replace sex = "Missing data" if sex=="NA"
encode sex, gen(TEMP_VAR) label(lbyesno) noextend
	label variable sex "Sexual intercourse"
	order TEMP_VAR, after(sex)
	drop sex
	rename TEMP_VAR sex

gen sex2 = sex
	label variable sex2 "Sexual intercourse"
	recode sex2 (88=99)
	label values sex2 lbyesno
	order sex2, after(sex)

label variable age_first_sex "Age of 1st sexual intercourse"	
	
gen age_first_sex2 = age_first_sex
	label variable age_first_sex2 "Age of 1st sexual intercourse"
	order age_first_sex2, after(age_first_sex)
	replace age_first_sex2 = "" if age_first_sex == "Dont know" | age_first_sex == "Dont want to answer" | age_first_sex == "NA"
	destring age_first_sex2, replace

gen age_first_sex_cat = recode(age_first_sex2,15,19,20)
	label variable age_first_sex_cat "Age of 1st sexual intercourse
	order age_first_sex_cat, after(age_first_sex2)
	recode age_first_sex_cat (15=1) (19=2) (20=3) (.=99)
	label define lbagefirstsex 1 "15 y.o. or before" 2 "Between 16 and 19 y.o." 3 "20 y.o. or after" 99 "Missing data"
	label values age_first_sex_cat lbagefirstsex

	replace condom_during_first_sex = "Missing data" if condom_during_first_sex=="NA"
	label var condom_during_first_sex "Use of condom during 1st sexual intercourse"
encode condom_during_first_sex, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(condom_during_first_sex)
	drop condom_during_first_sex
	rename TEMP_VAR condom_during_first_sex

gen condom_during_first_sex2 = condom_during_first_sex
	label var condom_during_first_sex2 "Use of condom during 1st sexual intercourse"
	recode condom_during_first_sex2 (88=99) (77=99)
	label values condom_during_first_sex2 lbyesno
	order condom_during_first_sex2, after(condom_during_first_sex)	
	
	replace condom_during_occasional_sex = "Missing data" if condom_during_occasional_sex=="NA"
	label var condom_during_occasional_sex "Use of condom during casual sex"
	label define lbcondomoccasionalsex 1 Yes 2 Sometimes 3 No 9 "Dont have occasional sex" 77 "Dont know" 88 "Dont want to answer" 99 "Missing data"
encode condom_during_occasional_sex, gen(TEMP_VAR) label(lbcondomoccasionalsex) noextend
	order TEMP_VAR, after(condom_during_occasional_sex)
	drop condom_during_occasional_sex
	rename TEMP_VAR condom_during_occasional_sex
	
gen condom_during_occasional_sex2 = condom_during_occasional_sex
	label var condom_during_occasional_sex2 "Use of condom during casual sex"
	recode condom_during_occasional_sex2 (88=99) (77=99)
	label values condom_during_occasional_sex2 lbcondomoccasionalsex
	order condom_during_occasional_sex2, after(condom_during_occasional_sex)	

	replace ist_mst = "Missing data" if ist_mst=="NA"
	label var ist_mst "STI/D history"
encode ist_mst, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(ist_mst)
	drop ist_mst
	rename TEMP_VAR ist_mst

gen ist_mst2 = ist_mst
	label var ist_mst2 "STI/D history"
	recode ist_mst2 (88=99) (77=99)
	label values ist_mst2 lbyesno
	order ist_mst2, after(ist_mst)	
		
**SANTE FEMININE
	*sensi_questions_woman
	*age_first_menstrual_period
	*contraception
	*contraception_prec
	*menopause
	*menopause_age

replace npregnancies="99" if npregnancies=="NA"
	label var npregnancies "Nbr of pregnancies"
	replace npregnancies="77" if npregnancies=="Dont know"
	replace npregnancies="88" if npregnancies=="Dont want to answer"
	destring npregnancies, replace
	
gen npregnancies_cat = recode(npregnancies,0,4,50,99)		
	label var npregnancies_cat "Nbr of pregnancies"
	recode npregnancies_cat (0=1) (4=2) (50=3) (77=99) (88=99)
	label define lbnpregnancies 1 "0 pregnancy" 2 "1 to 4 pregnancies" 3 "5 pregnancies or more" 99 "Missing data"
	label value npregnancies_cat lbnpregnancies
	order npregnancies_cat, after(npregnancies)

replace n_miscarry="99" if n_miscarry=="NA"
	label var n_miscarry "Nb of miscarries"
	replace n_miscarry="77" if n_miscarry=="Dont know"
	replace n_miscarry="88" if n_miscarry=="Dont want to answer"
	destring n_miscarry, replace
	
gen n_miscarry_cat = recode(n_miscarry,0,50,99)
	label var n_miscarry_cat "Nb of miscarries"
	recode n_miscarry_cat (0=1) (50=2) 
	label define lbnmiscarry 1 "0 miscarry" 2 "1 miscarry or more" 99 "Missing data"
	label value n_miscarry_cat lbnmiscarry
	order n_miscarry_cat, after(n_miscarry)

**COVID
* RECODAGE DATES COVID date_prlvt 
generate double TEMP_VAR = dofc(clock(date_prlvt,"YMD"))
	format TEMP_VAR %d
	order TEMP_VAR, after(date_prlvt)
	drop date_prlvt
	rename TEMP_VAR date_prlvt

* RECODAGE DATES COVID covid_first_injection_date cov23a
generate double TEMP_VAR = dofc(clock(covid_first_injection_date,"YMD"))
	format TEMP_VAR %d
	order TEMP_VAR, after(covid_first_injection_date)
	drop covid_first_injection_date
	rename TEMP_VAR covid_first_injection_date

* RECODAGE covid_second_injection_date cov23b
generate double TEMP_VAR = dofc(clock(covid_second_injection_date,"DMY"))
	format TEMP_VAR %d
	order TEMP_VAR, after(covid_second_injection_date)
	drop covid_second_injection_date
	rename TEMP_VAR covid_second_injection_date
	
*cov1
replace covid_test_positif="Missing data" if covid_test_positif=="NA"
encode covid_test_positif, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(covid_test_positif)
	drop covid_test_positif
	rename TEMP_VAR covid_test_positif

*cov3
replace covid_isolation_duration="" if covid_isolation_duration=="NA"
	destring covid_isolation_duration, replace

*cov7	
replace covid_complications="Missing data" if covid_complications=="NA"
encode covid_complications, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(covid_complications)
	drop covid_complications
	rename TEMP_VAR covid_complications

*cov8	
* A FAIRE ? covid_complications_prec

*cov9
replace covid_foreign_country="Missing data" if covid_foreign_country=="NA"
encode covid_foreign_country, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(covid_foreign_country)
	drop covid_foreign_country
	rename TEMP_VAR covid_foreign_country
	
replace covid_contact="Missing data" if covid_contact=="NA"
	encode covid_contact, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(covid_contact)
	drop covid_contact
	rename TEMP_VAR covid_contact
	
replace covid_familiy_postive="Missing data" if covid_familiy_postive=="NA"
	encode covid_familiy_postive, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(covid_familiy_postive)
	drop covid_familiy_postive
	rename TEMP_VAR covid_familiy_postive

replace covid_colleague_positive="Missing data" if covid_colleague_positive=="NA"
	encode covid_colleague_positive, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(covid_colleague_positive)
	drop covid_colleague_positive
	rename TEMP_VAR covid_colleague_positive

replace covid_gathering_positive="Missing data" if covid_gathering_positive=="NA"
	encode covid_gathering_positive, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(covid_gathering_positive)
	drop covid_gathering_positive
	rename TEMP_VAR covid_gathering_positive
	
*covid_social_impact
*covid_psy_impact
*covid_economic_impact
*covid_family_impact
*covid_sanitory_impact

*cov21
replace covid_vaccination="Missing data" if covid_vaccination=="NA"
	encode covid_vaccination, gen(TEMP_VAR) label(lbyesno) noextend
	order TEMP_VAR, after(covid_vaccination)
	drop covid_vaccination
	rename TEMP_VAR covid_vaccination

*cov22
label define lbcovid_vaccination_name 1 "Pfizer/Biontech" 2 "Moderna" 3 "Janssen" 4 "AstraZeneca" 5 "Other" 99 "Missing data"

replace covid_vaccination_name="Missing data" if covid_vaccination_name=="NA"
	encode covid_vaccination_name, gen(TEMP_VAR) label(lbcovid_vaccination_name) noextend
	order TEMP_VAR, after(covid_vaccination_name)
	drop covid_vaccination_name
	rename TEMP_VAR covid_vaccination_name				

*covid_vaccination_name_prec

*****************
** LABO**********
*****************
replace res_hba1g="" if res_hba1g=="NA"
replace res_hba1g="" if strpos(res_hba1g, "Ininter")
	destring res_hba1g, replace			

replace res_index_idl="" if res_index_idl== "NA"
	destring res_index_idl, replace
replace res_index_idh="" if res_index_idh== "NA"
	destring res_index_idh, replace
replace res_index_idi="" if res_index_idi== "NA"
	destring res_index_idi, replace
replace res_ct="" if res_ct== "NA"
	destring res_ct, replace
replace res_tg="" if res_tg== "NA"
	destring res_tg, replace
replace res_hdl_hdl="" if res_hdl_hdl== "NA"
	destring res_hdl_hdl, replace
replace res_hdl_rcthd="" if res_hdl_rcthd== "NA"
	destring res_hdl_rcthd, replace
replace res_ldlc_ldlc="" if res_ldlc_ldlc== "NA"
	replace res_ldlc_ldlc="" if res_ldlc_ldlc=="calcul non valide"
	destring res_ldlc_ldlc, replace
replace res_ldlc_rhdld="" if res_ldlc_rhdld== "NA"
	replace res_ldlc_rhdld="" if res_ldlc_rhdld=="calcul non valide"
	destring res_ldlc_rhdld, replace
gen 		 res_pt2 = res_pt
	order 	 res_pt2, after(res_pt)
	replace  res_pt2="" if res_pt== "NA"
	replace  res_pt2="-1" if res_pt=="<5"
	destring res_pt2, replace
	label define lbrespt -1 "<5"
	label values res_pt2 lbrespt
replace res_ot="" if res_ot== "NA"
	destring res_ot, replace
replace res_cr="" if res_cr== "NA"
	destring res_cr, replace
replace res_dfgf1="" if res_dfgf1== "NA"
	destring res_dfgf1, replace
replace res_dfgf2="" if res_dfgf2== "NA"
	destring res_dfgf2, replace
replace res_dfgh1="" if res_dfgh1== "NA"
	destring res_dfgh1, replace
replace res_dfgh2="" if res_dfgh2== "NA"
	destring res_dfgh2, replace
gen 		 res_crp2 = res_crp
	order    res_crp2, after(res_crp)
	replace  res_crp2="" if res_crp== "NA"
	replace  res_crp2="-1" if res_crp=="< 0.6"
	destring res_crp2, replace
	label define lbrescrp -1 "< 0.6"
	label values res_crp2 lbrescrp
replace res_ggt="" if res_ggt== "NA"
	destring res_ggt, replace
replace res_bilt="" if res_bilt== "NA"
	destring res_bilt, replace
replace res_nfp2_nfrem="" if res_nfp2_nfrem== "NA"
	destring res_nfp2_nfrem, replace
replace res_nfp2_gr="" if res_nfp2_gr== "NA"
	replace res_nfp2_gr="" if res_nfp2_gr=="Ininterpr?table"
	destring res_nfp2_gr, replace
replace res_nfp2_hb="" if res_nfp2_hb== "NA"
	replace res_nfp2_hb="" if res_nfp2_hb=="Ininterpr?table"
	destring res_nfp2_hb, replace
replace res_nfp2_ht="" if res_nfp2_ht== "NA"
	replace res_nfp2_ht ="" if res_nfp2_ht =="Ininterpr?table"	
	destring res_nfp2_ht, replace
replace res_nfp2_vgm="" if res_nfp2_vgm== "NA"
	replace res_nfp2_vgm ="" if res_nfp2_vgm =="Ininterpr?table"	
	destring res_nfp2_vgm, replace
replace res_nfp2_vgmc="" if res_nfp2_vgmc== "NA"
	destring res_nfp2_vgmc, replace
replace res_nfp2_tcmh="" if res_nfp2_tcmh== "NA"
	replace res_nfp2_tcmh ="" if res_nfp2_tcmh =="Ininterpr?table"		
	destring res_nfp2_tcmh, replace
replace res_nfp2_ccmhc="" if res_nfp2_ccmhc== "NA"
	replace res_nfp2_ccmhc ="" if res_nfp2_ccmhc =="Ininterpr?table"	
	destring res_nfp2_ccmhc, replace
replace res_nfp2_idr="" if res_nfp2_idr== "NA"
	replace res_nfp2_idr ="" if res_nfp2_idr =="Ininterpr?table"		
	destring res_nfp2_idr, replace
replace res_nfp2_idrc="" if res_nfp2_idrc== "NA"
	destring res_nfp2_idrc, replace

	* 23/07 : "Vu avec Sophie, elle préfère que tu mettes la valeur 400 à la place des « > xxx » pour garder l'information que le taux de plaquettes est normal. Pour amas et ininterprétable, tu peux mettre données manquantes"
gen 		 		res_nfp2_pla2 = res_nfp2_pla
	replace  		res_nfp2_pla2 ="" if res_nfp2_pla =="NA" | res_nfp2_pla =="AMAS" | res_nfp2_pla =="amas" | res_nfp2_pla =="Ininterpr?table" 
	// vincent : en excluant les 22 observations avec « > xxx », med=294 ; moyenne=300.9 => rem:placement desdites vleurs par 300.9
	replace 		res_nfp2_pla2 ="300.9" if strpos(res_nfp2_pla, ">") 
	// mail Raphael BOS du 07 sept-2022 "Mataea - vérifier plaquettes" et revue du résultat des plaquettes pour les 4 amas 
		// 2ème ligne [note Vincent : BO0235ILM] : 83 G/L très nbreux amas donc >150 G/L dans la norme
		// 3ème ligne [[note Vincent : TA8482ILM] : > 150 pour sûr dans la norme
	replace 		res_nfp2_pla2 ="300.9" if subjid== "BO0235ILM" | subjid=="TA8482ILM"
	destring 		res_nfp2_pla2, replace
	order 			res_nfp2_pla2, after(res_nfp2_pla)
	label variable  res_nfp2_pla2 "NFS - Plaquettes - G/L"

replace res_nfp2_vpm="" if res_nfp2_vpm== "NA"
	replace res_nfp2_vpm ="" if res_nfp2_vpm =="Ininterpr?table"	
	replace res_nfp2_vpm ="" if res_nfp2_vpm =="ininterpr?table"	
	replace res_nfp2_vpm ="" if res_nfp2_vpm =="inintrepr?table"	
	replace res_nfp2_vpm ="" if res_nfp2_vpm =="ININTERPRETABLE"	
	replace res_nfp2_vpm ="" if res_nfp2_vpm =="----"	
* ?? replacer les "----" par données manquantes ?
	destring res_nfp2_vpm, replace
replace res_nfp2_gb="" if res_nfp2_gb== "NA"
	replace res_nfp2_gb ="" if res_nfp2_gb =="Ininterpr?table"	
	destring res_nfp2_gb, replace
replace res_nfp2_gbcal="" if res_nfp2_gbcal== "NA"
	destring res_nfp2_gbcal, replace
replace res_nfp2_pn="" if res_nfp2_pn== "NA"
	replace res_nfp2_pn ="" if res_nfp2_pn =="Ininterpr?table"	
	destring res_nfp2_pn, replace
replace res_nfp2_pn3="" if res_nfp2_pn3== "NA"
	destring res_nfp2_pn3, replace
replace res_nfp2_pe="" if res_nfp2_pe== "NA"
	replace res_nfp2_pe ="" if res_nfp2_pe =="Ininterpr?table"	
	destring res_nfp2_pe, replace
replace res_nfp2_pe3="" if res_nfp2_pe3== "NA"
	destring res_nfp2_pe3, replace
replace res_nfp2_ly="" if res_nfp2_ly== "NA"
	replace res_nfp2_ly ="" if res_nfp2_ly =="Ininterpr?table"	
	destring res_nfp2_ly, replace
replace res_nfp2_ly3="" if res_nfp2_ly3== "NA"
	destring res_nfp2_ly3, replace
replace res_nfp2_mo="" if res_nfp2_mo== "NA"
	replace res_nfp2_mo ="" if res_nfp2_mo =="Ininterpr?table"	
	destring res_nfp2_mo, replace
replace res_nfp2_mo3="" if res_nfp2_mo3== "NA"
	destring res_nfp2_mo3, replace
replace res_nfp2_clhem="" if res_nfp2_clhem== "NA"
	destring res_nfp2_clhem, replace
replace coser_index="" if coser_index== "NA"
	replace coser_index ="" if coser_index =="Non realise"		
	destring coser_index, replace


***************************************************************
**# RECHERCHE VALEURS INCOHERENTES ABERRANTES #6
***************************************************************

*sum nschool_years, d
	* 5 valeurs = 77 => à interpréter comme "ne sait pas" 
* Correction Journal#13 - transformation en donnée manquante pour l'analyse
*replace nschool_years=. if nschool_years==77

*list subjid age nschool_years if nschool_years>= age & nschool_years!=.
	* A part les 5 participants avec 77 nschool_years ("ne sait pas"), TA8362ILM, 19 ans et 20 ans d'étude
* Correction Journal#15
replace nschool_years=99 if subjid=="TA8362ILM"

*list subjid nhouse_people if nhouse_people >=30
	* 2 participants nhouse_people=77 => à interpréter par "NE SAIT PAS"	
* Correction Journal#16 - transformation en donnée manquante pour l'analyse
*replace nhouse_people=. if nhouse_people==77

* Correction Journal#68 - basculement des 5 valeurs de other_tabaco_prec_bis dans other_tabaco_prec
replace other_tabaco_prec=other_tabaco_prec_bis if other_tabaco_prec_bis != "NA"
	replace other_tabaco_prec_bis="NA" if other_tabaco_prec_bis != "NA"

list subjid if no_more_vege_prec=="77"
	* TA8367ILM => no_more_vege_prec = 77 pour "ne sait pas"
* Correction Journal#18
replace no_more_vege_prec="ne sait pas" if subjid=="TA8367ILM"
	
list subjid if bp_systolic_1==888
	* TH0087ILM avec bp_systolic_1=bp_diastolic_1= 888 ; 2 mesures suivantes = "NA" => interpréter comme NA / valeur manquante 
* Correction Journal#19
replace bp_systolic_1 =. if subjid =="TH0087ILM"
replace bp_diastolic_1 =. if subjid =="TH0087ILM"
	
list subjid if gender==1 & pregnancy !=99
	* RA0032ILM, Male, PREGNANCY = No ; remplacer par NA (cohérence pour tous les hommes)
* Correction Journal#20
replace pregnancy=99 if subjid=="RA0032ILM"
	
list subjid height if height >200 &height!=.	
	*2 participants avec height=888
* Correction Journal#21
replace height=. if height==888

list subjid bathroom_scale_id weight if weight >300 & weight!=.	
	* 1 participant avec weight=888 ; 1 avec 888.8
	* 2 participants avec 666 ; 4 avec 666.6 => poids hos gabarit
* Correction Journal#22 - transformation des 888 en donnée manquante pour l'analyse
replace weight=. if weight >=888 & weight!=.	

codebook subjid if abdocm==888
	* 46 participants avec 888 comme abdocm => à remplacer comme valeur manquante
* Correction Journal#23
replace abdocm=. if abdocm==888

codebook subjid if glycemia==777
	* 3 participants avec glycemia = 777  => interpréter comme refus ou problème de lecteur
* Correction Journal#24 - transformation en donnée manquante pour l'analyse
replace glycemia=. if glycemia==777

* Correction Journal#36 ; poids hors gabarit (> 200kg), traitement du poids et bmi
	replace weight=210 if weight ==666 | weight ==666.6
	replace bmi=round(weight/(height/100)^2,0.1) if weight==210
	
* Correction Journal#36_2 : 2 participants "Taillle trop petite par rapport à son poids/tour de taille - erreur de saisie ==> IMC erronée"
	replace bmi=. if subjid=="MK0011ILM" | subjid =="TA8748ILM"	
	replace height=. if subjid=="MK0011ILM" | subjid =="TA8748ILM"	

list subjid weight height bmi if weight ==. & bmi !=.
	* 2 valeurs aberrantes (précédentes valeurs de weight 888 888.8)
* Correction Journal#36_3
	replace bmi=. if weight ==. & bmi !=.

* Correction Journal#60 (2 hommes ont répondu "Non" au consentement des questions pour femmes ; devraient être "NA")
replace sensi_questions_woman="NA" if sensi_questions_woman=="No" & gender==1


***************************************************************
**# CORRECTION DE MODALITES #7
***************************************************************
label define lbneveralways  1 "Always" 2 "Often" 3 "Sometimes" 4 "Rarely" 5 "Never" 77 "Dont know" 99 "Missing data"
* RECODAGE 3 variables Hygiène alimentaire / SALT
* Correction Journal#8
	replace  seasoning_before_during="1" if seasoning_before_during=="Always"
	replace  seasoning_before_during="2" if seasoning_before_during=="Often"
	replace  seasoning_before_during="3" if seasoning_before_during=="Sometimes"
	replace  seasoning_before_during="4" if seasoning_before_during=="Rarely"
	replace  seasoning_before_during="5" if seasoning_before_during=="Never" 
	destring seasoning_before_during, replace
label values seasoning_before_during lbneveralways
* Correction Journal#9
	replace  seasoning_cooking="1"  if seasoning_cooking=="Always"
	replace  seasoning_cooking="2"  if seasoning_cooking=="Often"
	replace  seasoning_cooking="3"  if seasoning_cooking=="Sometimes"
	replace  seasoning_cooking="4"  if seasoning_cooking=="Rarely"
	replace  seasoning_cooking="5"  if seasoning_cooking=="Never" 
	replace  seasoning_cooking="77" if seasoning_cooking=="Dont know" 
	destring seasoning_cooking, replace
label values seasoning_cooking lbneveralways
* Correction Journal#10
	replace  eat_salty_food="1" if eat_salty_food=="Always"
	replace  eat_salty_food="2" if eat_salty_food=="Often"
	replace  eat_salty_food="3" if eat_salty_food=="Sometimes"
	replace  eat_salty_food="4" if eat_salty_food=="Rarely"
	replace  eat_salty_food="5" if eat_salty_food=="Never" 
	destring eat_salty_food, replace
label values eat_salty_food lbneveralways

* Corrections des town_name Journal#11
merge m:1 town_name using "Corrections town_name.dta",  nogenerate
	order town_name_correction, after(town_name)
	drop town_name 
	rename town_name_correction town_name

* Erreur de traduction des modalités paka_last_year_freq
* Correction Journal#56
* traduction en var numérique pour test de tendance
replace paka_last_year_freq="1 to 3 days per month" if paka_last_year_freq== "1 to 3 days per week"
replace paka_last_year_freq="2 to 4 days per week" if paka_last_year_freq=="2 to 1 to 3 days per week days per week"
replace paka_last_year_freq="Less than once a month" if paka_last_year_freq=="less than once a week"
replace paka_last_year_freq="5 to 7 days per week" if paka_last_year_freq=="less than once a week to 7 days per week"
replace paka_last_year_freq="Once a week" if paka_last_year_freq=="once a week"
replace paka_last_year_freq="Missing data" if paka_last_year_freq=="NA"
	label define lbfreq 1 "5 to 7 days per week" 2 "2 to 4 days per week" 3 "Once a week" 4 "1 to 3 days per month" 5 "Less than once a month" 77 "Dont know" 88 "Dont want to answer" 99 "Missing data"
	encode paka_last_year_freq, gen(TEMP_VAR) label(lbfreq) noextend
	order TEMP_VAR, after(paka_last_year_freq)
	drop paka_last_year_freq
	rename TEMP_VAR paka_last_year_freq				

* Erreur de traduction des modalités sweet_drink_last_month_freq
* Correction Journal#61
* traduction en var numérique pour test de tendance
replace sweet_drink_last_month_freq="2 to 4 days per week" if sweet_drink_last_month_freq== "2 to 1 to 3 days per month days per week"
replace sweet_drink_last_month_freq="5 to 7 days per week" if sweet_drink_last_month_freq=="Less than once a month to 7 days per week"
	encode sweet_drink_last_month_freq, gen(TEMP_VAR) label(lbfreq) noextend
	order TEMP_VAR, after(sweet_drink_last_month_freq)
	drop sweet_drink_last_month_freq
	rename TEMP_VAR sweet_drink_last_month_freq				

* Erreur de traduction des modalités snack_freq
* Correction Journal#62
* traduction en var numérique pour test de tendance
replace snack_freq="2 to 4 days per week" if snack_freq== "2 to 1 to 3 days per month days per week"
replace snack_freq="5 to 7 days per week" if snack_freq=="Less than once a month to 7 days per week"

	encode snack_freq, gen(TEMP_VAR) label(lbfreq) noextend
	order TEMP_VAR, after(snack_freq)
	drop snack_freq
	rename TEMP_VAR snack_freq				

* Erreur de traduction des modalités pain_limitation_last_4weeks
* Correction Journal#63
* traduction en var numérique pour test de tendance
replace pain_limitation_last_4weeks="Not at all" if pain_limitation_last_4weeks== "Never"

label define lbhowmuch 1 "Not at all" 2 "A little" 3 "Moderately" 4 "A lot" 5 "Extremely"
	encode pain_limitation_last_4weeks, gen(TEMP_VAR) label(lbhowmuch) noextend
	order TEMP_VAR, after(pain_limitation_last_4weeks)
	drop pain_limitation_last_4weeks
	rename TEMP_VAR pain_limitation_last_4weeks				

* Erreur de traduction des modalités ciguatera_how_long_sympt_stop
* Correction Journal#64
* traduction en var numérique pour test de tendance
replace ciguatera_how_long_sympt_stop="Between 1 and 3 months" if ciguatera_how_long_sympt_stop== "Between 1 and Between 3 and 6 months months"
replace ciguatera_how_long_sympt_stop="" if ciguatera_how_long_sympt_stop=="NA"

label define lbciguateraduration  77 "Dont know" 1 "Less than a month" 2 "Between 1 and 3 months" 3 "Between 3 and 6 months" 4 "Between 6 months and 1 year" 5 "More than a year"
	encode ciguatera_how_long_sympt_stop, gen(TEMP_VAR) label(lbciguateraduration) noextend
	order TEMP_VAR, after(ciguatera_how_long_sympt_stop)
	drop ciguatera_how_long_sympt_stop
	rename TEMP_VAR ciguatera_how_long_sympt_stop				

**COVID 
list subjid date_interview_step1 covid_vaccination_name covid_first_injection_date covid_second_injection_date if covid_vaccination==2 & covid_vaccination_name!=99
	* 2 observations "Pfizer" avec "covid_vaccination" = "No" : NU0303ILM TA8668ILM
* Correction Journal#37
replace covid_vaccination=1  if covid_vaccination==2 & covid_vaccination_name!=99

list subjid date_interview_step1 covid_vaccination_name covid_first_injection_date covid_second_injection_date if covid_first_injection_date< td(31dec2020) | covid_second_injection_date < td(31dec2020)
	*      +-----------------------------------------------------------------+
	*      |    subjid   date_in~1   covid_vaccina~e   c~irst_~e   covid_s~e |
	*      |-----------------------------------------------------------------|
	*1118. | MO0156ILM   19-Oct-21   Pfizer/Biontech   01-Aug-20   01-Aug-20 |
	*1766. | TA8763ILM   24-Nov-21   Pfizer/Biontech   01-Jan-20   01-Jan-20 |
	*      +-----------------------------------------------------------------+
	* erreur de frappe très probable et réponses très probables respectivement Janvier 2021 et aout 2021
* Correction Journal#38  #43
replace covid_first_injection_date=td(01Aug2021) if subjid=="MO0156ILM"
replace covid_second_injection_date=td(01Aug2021) if subjid=="MO0156ILM"
replace covid_first_injection_date=td(01Jan2021) if subjid=="TA8763ILM"
replace covid_second_injection_date=td(01Jan2021) if subjid=="TA8763ILM"

* COHERENCE 1ere et 2ème injection	
list subjid date_interview_step1 covid_vaccination_name covid_first_injection_date covid_second_injection_date if covid_vaccination==1 & covid_first_injection_date>covid_second_injection_date & covid_first_injection_date!=.
	* 3 participants avec 2nde injection antérieure à 1ère injection
	* TA8579ILM TA8832ILM TA8880ILM
* Correction Journal#46
replace covid_second_injection_date=covid_first_injection_date if covid_vaccination==1 & covid_first_injection_date>covid_second_injection_date & covid_first_injection_date!=.
	
* COHERENCE date interview, 1ere et 2ème injection	
list subjid date_interview_step1 investigator_id_step1 covid_vaccination covid_first_injection_date covid_second_injection_date if covid_vaccination==1 & dofc(date_interview_step1) < covid_first_injection_date & covid_first_injection_date != .
	* 1 participant TA8633ILM avec date de 1ère injection postérieure à la date d'interview => OK, certainement rdv vacci déjà planifié ; garder la date de 1ère injection, pour information CorrectionJournal#41

list subjid date_interview_step1 investigator_id_step1 covid_first_injection_date covid_second_injection_date if covid_vaccination==1 & dofc(date_interview_step1) < covid_second_injection_date & covid_second_injection_date != .
	* 3 participants (HI0248ILM TA8374ILM TA8691ILM) avec date de 2ème injection postérieure à la date d'interview
	* OK, certainement rdv vacci déjà planifié ; garder la date de 2ème injection, pour information CorrectionJournal#47
		
	
***************************************************************
**# DIVERS #8
***************************************************************

* Correction Journal#52 - drop variable dossier
drop dossier

* Correction Journal#53 - drop variable nodem
drop nodem

* Correction Journal#54 - drop variable res_cru
drop res_cru 

* Correction Journal#55 - drop variable res_nau
drop res_nau 

*label données labo
label variable qr_code_oms "QR Code"
label variable res_hba1g "Hémoglobine A1C - %"
label variable res_index_idl "Index sérique"
label variable res_index_idh "Index sérique"
label variable res_index_idi "Index sérique"
label variable res_ct "Cholestérol - mmol/l"
label variable res_tg "Triglycérides - mmol/L"
label variable res_hdl_hdl "Cholestérol HDL - mmol/L"
label variable res_hdl_rcthd "Rapport cholestérol total/HDL"
label variable res_ldlc_ldlc "Calcul du cholestérol LDL - mmol/L"
label variable res_ldlc_rhdld "Rapport cholestérol HDL/LDL"
label variable res_pt "Transaminases SGPT - ALAT - UI/L"
label variable res_ot "Transaminases SGOT - ASAT - UI/L"
label variable res_cr "Créatinine - µmol/L"
label variable res_dfgf1 "Débit de filtration glomérulaire F1 - mL/min/1.73m²"
label variable res_dfgf2 "Débit de filtration glomérulaire F2 - mL/min/1.73m²"
label variable res_dfgh1 "Débit de filtration glomérulaire H1 - mL/min/1.73m²"
label variable res_dfgh2 "Débit de filtration glomérulaire H2 - mL/min/1.73m²"
label variable res_crp "Protéine C réactive - mg/L"
label variable res_ggt "Gamma-glutamyl transférase - UI/L"
label variable res_bilt "Bilirubine totale - µmol/L"
label variable res_asp "Aspect du sérum - commentaire"
label variable res_nfp2_gr "NFS - Hématies - T/L"
label variable res_nfp2_hb "NFS - Hémoglobine - g/Dl"
label variable res_nfp2_ht "NFS - Hématrocrite - %"
label variable res_nfp2_vgm "NFS - V.G.M - fL"
label variable res_nfp2_tcmh "NFS - T.C.M.H - pg/cell"
label variable res_nfp2_ccmhc "NFS - C.C.M.H - g/dL"
label variable res_nfp2_pla "NFS - Plaquettes - G/L"
label variable res_nfp2_vpm "NFS - V.P.M - fL"
label variable res_nfp2_gb "NFS - Leucocytes - G/L"
label variable res_nfp2_gbcal "NFS - Leucocytes"
label variable res_nfp2_pn "NFS - Polynucléaires neutrophiles - %"
label variable res_nfp2_pn3 "NFS - Polynucléaires neutrophiles - G/L"
label variable res_nfp2_pe "NFS - Polynucléaires éosinophiles - %"
label variable res_nfp2_pe3 "NFS - Polynucléaires éosinophiles - G/L"
label variable res_nfp2_ly "NFS - Lymphocytes - %"
label variable res_nfp2_ly3 "NFS - Lymphocytes - G/L"
label variable res_nfp2_mo "NFS - Monocytes - %"
label variable res_nfp2_mo3 "NFS - Monocytes - G/L"
label variable coser_index "Sérologie COVID-19 (index)"
label variable coser "Sérologie COVID-19 (index)"

* dictionnaire aspect serum
label define lbres_asp 1 Limpide 2 "Légèrement opalescent" 3 Opalescent 4 Lactescent 5 Ictérique 6 "Subictérique" 7 "Hemolysé"
	replace res_asp="1" if res_asp== "AN001"
	replace res_asp="2" if res_asp== "AN002" 
	replace res_asp="3" if res_asp== "AN003" 
	replace res_asp="4" if res_asp== "AN004" 
	replace res_asp="5" if res_asp== "AN005" 
	replace res_asp="6" if res_asp== "AN006" 
	replace res_asp="7" if res_asp== "AN007" 
	replace res_asp="" if res_asp== "NA" 
	destring res_asp, replace      
	label values res_asp lbres_asp

* dictionnaire var coser
label define lbposneg 0 Negative 1 Positive 88 "Non-conclusive" 99 "Missing data"
	replace coser="99" if coser=="NA"
	destring coser, replace
	recode coser (2=99) (3=88)
	label values coser lbposneg

	
***************************************************************
**# IMPORT DONNEES VHB #9
***************************************************************
sort subjid
merge 1:1 subjid using "IMPORT_DONNEES_VHB.dta", keepusing(vhb_ag_hbs_qual vhb_ag_hbs_index vhb_ac_hbs_qual vhb_ac_hbs_quant vhb_ac_hbc_qual vhb_ac_hbc_index vhb_conclusion vhc_qual vhc_index vhc_conclusion) nogenerate

label variable vhb_ag_hbs_qual 	"Antigène HBs - Qualitatif"
label variable vhb_ag_hbs_index "Antigène HBs - Index"
label variable vhb_ac_hbs_qual 	"Anticorps HBs - Qualitatif"
label variable vhb_ac_hbs_quant "Anticorps HBs - Quantitatif"
label variable vhb_ac_hbc_qual	"Anticorps HBc - Qualitatif"
label variable vhb_ac_hbc_index "Anticorps HBc - Index"
label variable vhb_conclusion 	"VHB Conclusion"
label variable vhc_qual 		"VHC - Qualitatif"
label variable vhc_index 		"VHC - Index"
label variable vhc_conclusion	"VHC Conclusion"

label define lbvhb 0 "Absence de contact avec le virus" 1 "Portage de l'antigène HBs (infection en cours)" 2 "Profil évoquant une vaccination" 3 "Profil évoquant une infection ancienne guérie" 4 "Profil évoquant une infection ancienne guérie, mais anticorps anti-HBc isolés" 77 "Incomplet" 88 "Quantite insuffisante" 99 "Donnée manquante"
	replace  vhb_conclusion ="0"  if vhb_conclusion =="ABS"
	replace  vhb_conclusion ="1"  if vhb_conclusion =="POR"
	replace  vhb_conclusion ="2"  if vhb_conclusion =="VAC"
	replace  vhb_conclusion ="3"  if vhb_conclusion =="GUE"
	replace  vhb_conclusion ="4"  if vhb_conclusion =="GUE HBC ISO"
	replace  vhb_conclusion ="77" if vhb_conclusion =="INCOMP"
	replace  vhb_conclusion ="88" if vhb_conclusion =="QI"
	replace  vhb_conclusion ="99" if vhb_conclusion ==""
	destring vhb_conclusion, replace
	label values vhb_conclusion  lbvhb
	
label define lbvhc 0 "Absence de contact avec le virus" 1 "Séropositif pour le VHC" 88 "Quantite insuffisante" 99 "Donnée manquante"
	replace  vhc_conclusion ="0"  if vhc_conclusion =="ABS"
	replace  vhc_conclusion ="1"  if vhc_conclusion =="POS"
	replace  vhc_conclusion ="88"  if vhc_conclusion =="QI"
	replace  vhc_conclusion ="99" if vhc_conclusion ==""
	destring vhc_conclusion, replace
	label values vhc_conclusion lbvhc


*******************************************************************
**# IMPORT DONNEES SEROLOGIES COVID LUMINEX (ANTI-N & ANTI-S) #10
*******************************************************************
sort subjid
merge 1:1 subjid using "IMPORT_DONNEES_SERO_COVID.dta", keepusing(tp_serologie_covid tp_subjid2 tp_subjid3 covid_anti_n_his_tag covid_anti_s_s1_his_tag covid_anti_s_s2_his_tag covid_anti_s_s1_shfc_tag covid_anti_s_s2_shfc_tag covid_anti_n covid_anti_s) nogenerate
// 1,187 matched
// 755 not matched

* vérification concordance de la variable coser et tp_serologie_covid
tab tp_serologie_covid coser,m 
drop tp_serologie_covid

order covid_anti_s, after(coser)
order covid_anti_n, after(coser)
order covid_anti_s_s2_shfc_tag, after(coser)
order covid_anti_s_s1_shfc_tag, after(coser)
order covid_anti_s_s2_his_tag, after(coser)
order covid_anti_s_s1_his_tag, after(coser)
order covid_anti_n_his_tag, after(coser)

label variable 	covid_anti_n_his_tag	"Ac anti-N SARS-CoV-2 N His-Tag - 884"
	destring 	covid_anti_n_his_tag, replace
label variable 	covid_anti_s_s1_his_tag "Ac anti-S SARS-CoV-2 S1 His-Tag - 272"
	destring 	covid_anti_s_s1_his_tag, replace
label variable 	covid_anti_s_s2_his_tag "Ac anti-S SARS-CoV-2 S2 His-Tag - 255"
	destring 	covid_anti_s_s2_his_tag, replace
label variable 	covid_anti_s_s1_shfc_tag "Ac anti-S SARS-CoV-2 S1 SHFc-Tag - 50"
	destring 	covid_anti_s_s1_shfc_tag, replace
label variable 	covid_anti_s_s2_shfc_tag "Ac anti-S SARS-CoV-2 S2 SHFc-Tag - 70"
	destring 	covid_anti_s_s2_shfc_tag, replace
label variable 	covid_anti_n "Ac anti-N SARS-CoV-2"
label variable 	covid_anti_s "Ac anti-S SARS-CoV-2"

replace 	 covid_anti_n ="1" if covid_anti_n =="POS"
	replace  covid_anti_n ="0" if covid_anti_n =="NEG"
	destring covid_anti_n, replace
	recode   covid_anti_n (.=99)
	label values covid_anti_n lbposneg

replace 	 covid_anti_s ="1" if covid_anti_s =="POS"
	replace  covid_anti_s ="0" if covid_anti_s =="NEG"
	destring covid_anti_s, replace
	recode   covid_anti_s (.=99)	
	label values covid_anti_s lbposneg	 
				
compress
save "01_MATAEA_clean.dta", replace
*export excel using "01_MATAEA_clean.xlsx", firstrow(variables)