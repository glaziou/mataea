*****************************************************************************
*   					Projet MATA'EA										*
* 			Cartographie de l'état de santé de la 							*
* 			population de la Polynésie française							*
*																			*
*					 		Fichier 02										*
*					Préparation de la base : 								*
*	   Création de variables explicatives additionnelles					*
*																			*
*																			*
* 	auteur : Vincent Mendiboure												*
* 	dernier update : 31 octobre 2022										*
*																			*
*****************************************************************************

*cd "Z:\donnees\Stata"
cd "C:\Users\Mendiboure\Documents\Master PH\Stage Pasteur\image\donnees\Stata"

use "01_MATAEA_clean.dta", clear


*******************************************************************************	
**# CREATION DE VARIABLES EXPLICATIVES OU CLASSES ADDITIONNELLES #1
*******************************************************************************
label define lbbooleen 1 Yes 0 No 99 "Missing data"

* MOIS D'INTERVIEW
gen mois_interview_step1 = month(dofc(date_interview_step1))
	order mois_interview_step1 , after(date_interview_step1)

gen annee_interview_step1 = year(dofc(date_interview_step1))
	order mois_interview_step1 , after(date_interview_step1)
	
egen annee_mois_interview_step1 = concat(annee_interview_step1 mois_interview_step1), punct(-) 
	order annee_mois_interview_step1 , after(date_interview_step1)
	replace annee_mois_interview_step1 = subinstr(annee_mois_interview_step1,"-2","-02",.)
	replace annee_mois_interview_step1 = subinstr(annee_mois_interview_step1,"-3","-03",.)
	replace annee_mois_interview_step1 = subinstr(annee_mois_interview_step1,"-4","-04",.)
	replace annee_mois_interview_step1 = subinstr(annee_mois_interview_step1,"-5","-05",.)
	replace annee_mois_interview_step1 = subinstr(annee_mois_interview_step1,"-6","-06",.)
	replace annee_mois_interview_step1 = subinstr(annee_mois_interview_step1,"-7","-07",.)

* Creation de la variable ARCHIPEL et ILE
merge m:1 town_id using "Mataea Liste ID Commune.dta", keepusing(archipelago island)  nogenerate
	order archipelago, after(town_name)
		label define lbarchipelago 1 "Société (Îles-du-vent)" 2 "Société (Îles-sous-le-vent)" 3 "Tuamotu-Gambier" 4 "Marquises" 5 "Australes"
		encode archipelago, gen(TEMP_VAR) label(lbarchipelago) noextend
		order TEMP_VAR, after(archipelago)
		drop archipelago
		rename TEMP_VAR archipelago
	order island, after(town_name)
		label define lbisland 1 Tahiti 2 Moorea 3 "Bora Bora" 4 Raiatea 5 Tahaa 6 Huahine 7 Rangiroa 8 Fakarava 9 Hao 10 Makemo 11 Mangareva 12 "Nuku Hiva" 13 "Hiva Oa" 14 "Ua Pou" 15 Tubuai 16 Rurutu 17 Rimatara 18 Raivavae
		encode island, gen(TEMP_VAR) label(lbisland) noextend
		order TEMP_VAR, after(island)
		drop island
		rename TEMP_VAR island

* Creation de la Classification des communes des IDV
merge m:1 town_id using "Mataea town clustering.dta", keepusing(town_classif_1 town_classif_2 town_classif_3)  nogenerate
	order town_classif_1, after(town_id)
	order town_classif_2, after(town_classif_1)
	order town_classif_3, after(town_classif_2)
	label variable town_classif_1 "INSEE Clustering"
	label variable town_classif_2 "CHSP Clustering"
	label variable town_classif_3 "INED Clustering"

* Creation de la STRATE GEOGRAPHIQUE
gen geo_strate = 1 if archipelago== 1
	replace geo_strate = 2 if archipelago == 2
	replace geo_strate = 3 if archipelago == 3 | archipelago == 4 | archipelago == 5
	label variable geo_strate "Strate géographique"
	order geo_strate, after(archipelago)
	label define lbgeostrate 1 "IDV" 2 "ISLV" 3 "Other archipelago"
	label values geo_strate lbgeostrate

* Creation de la CATEGORIE D'AGE PRINCIPALE
gen age_cat = recode(age,29,44,69)
	label variable age_cat "Classe d'age"
	recode age_cat (29=1) (44=2) (69=3)
	order age_cat, after(age)
	label define lbagecat 1 "18-29 ans" 2 "30-44 ans" 3 "45-69 ans"
	label values age_cat lbagecat	
	
* Creation de la CATEGORIE D'AGE SECONDAIRE 
gen age_cat2 = recode(age,24,29,37,44,55,69)
	label variable age_cat2 "Classe d'age secondaire"
	recode age_cat2 (24=1) (29=2) (37=3) (44=4) (55=5) (69=6)
	order age_cat2, after(age_cat)
	label define lbagecat2 1 "18-24 ans" 2 "25-29 ans" 3 "30-37 ans" 4 "38-44 ans" 5 "45-55 ans" 6 "56-69 ans"
	label values age_cat2 lbagecat2	

* Creation CLASSES DE NOMBRE D'ANNEES DE FORMATION
*verifier avec Iotefa ?
gen nschool_cat = recode(nschool_years,5,9,12,14)
	label variable nschool_cat "Classe d'annees de formation"
	recode nschool_cat (5=1) (9=2) (12=3) (14=4)
	order nschool_cat, after(nschool_years)
	label define lbnschoolcat 1 "<= 5 annees" 2 "6-9 annees" 3 "10-12 annees" 4 ">=13 annees" 
	label values nschool_cat lbnschoolcat
	
* Regroupement PLUS HAUT NIVEAU D'INSTRUCTION
gen 				max_school2=.
	label variable  max_school2 "Plus haut niveau d'instruction"
	label define lbmaxschool2 1 "End of primary or before" 2 "End of secundary school" 3 "End of lycee or equivalent" 4 "University or after" 99 "Missing data"
	label values max_school2 lbmaxschool2
	replace max_school2= 1  if max_school==1 | max_school==2 | max_school==3 
	replace max_school2= 2  if max_school==4 
	replace max_school2= 3  if max_school==5
	replace max_school2= 4  if max_school==6 | max_school==7
	replace max_school2= 99 if max_school==88
	order   max_school2, after(max_school)
	
* Regroupement ETAT CIVIL - 3 classes
gen civil_state2 =civil_state
	label var civil_state2 "Marital status"
	label define lbcivilstate2 1 "Never married, separated, divorced or widower" 2 "Married" 3  "Cohabitation" 99 "Missing data"
	recode civil_state2 (3=1) (4=1) (5=1) (6=3) (88=99)
	label values civil_state2 lbcivilstate2
	order civil_state2, after(civil_state)

* Regroupement ETAT CIVIL - 4 classes
gen civil_state3 =civil_state
	label var civil_state3 "Marital status"
	label define lbcivilstate3 1 "Never married" 2 "Married" 3 "Separated, divorced or widower" 4 "Cohabitation" 99 "Missing data"
	recode civil_state3 (4=3) (5=3) (6=4) (88=99)
	label values civil_state3 lbcivilstate3
	order civil_state3, after(civil_state2)

* Regroupement ETAT CIVIL - 3 classes : en couple regroupé en une seule classe 
gen civil_state4=civil_state3
	label var civil_state4 "Marital status"
	label define lbcivilstate4 1 "Never married" 2 "In a relationship (married or cohabitation)" 3 "Separated, divorced or widower" 99 "Missing data"
	label values civil_state4 lbcivilstate4
	recode civil_state4 (4=2)
	order civil_state4, after(civil_state3)

* Regroupement ACTIVITE PROFESSIONNELLE selon Enquete 2010
gen pro_act_last_year2 =pro_act_last_year
	label variable pro_act_last_year2 "Catégorie activité professionnelle"
	label define lbproactlastyear2 1 "Administration employee" 2 "Private employee" 3 "Independant" 4 "Unpaid activity" 
	recode pro_act_last_year2 (5=4) (6=4) (7=4) (8=4) (9=4) 
	label values pro_act_last_year2 lbproactlastyear2
	order pro_act_last_year2, after(pro_act_last_year)

* Regroupement ACTIVITE PROFESSIONNELLE selon interactions sociales (pour analyses COVID)
gen pro_act_last_year3 =pro_act_last_year
	label variable pro_act_last_year3 "Catégorie activité professionnelle"
	label define lbproactlastyear3 1 "Administration employee" 2 "Private employee (and volunteer)" 3 "Independant" 4 "Student" 5 "Without activity (Housewives, retired, unemployed, disabled)" 
	recode pro_act_last_year3 (4=2) (5=4) (6=5) (7=5) (8=5) (9=5) 
	label values pro_act_last_year3 lbproactlastyear3
	order pro_act_last_year3, after(pro_act_last_year2)
	
* Regroupement NOMBRE MAJEURS DANS LA MAISON pour nhouse_people
gen nhouse_classif = recode(nhouse_people,1,2,3) if nhouse_people !=77
	replace nhouse_classif =99 if nhouse_people ==77
	order nhouse_classif, after(nhouse_people)
	label define lbnhouseclassif 1 "Seule pers. de 18 ou + dans la maison" 2 "Total 2 pers. de 18 ou + dans la maison" 3 "3 pers. ou plus de 18 ans ou + dans la maison" 99 "Missing data"
	label values nhouse_classif lbnhouseclassif	

* Regroupement NOMBRE PERSONNES DANS LE FOYER nhouse_people_tot - 6 classes
gen 		nhouse_tot_classif = recode(nhouse_people_tot,1,2,3,4,5,6) if nhouse_people_tot !=77
	replace nhouse_tot_classif =99 if nhouse_people_tot ==77
	order   nhouse_tot_classif, after(nhouse_people_tot)
	label variable nhouse_tot_classif "Nombre de personnes résidant dans le foyer"
	label define lbnhousetotclassif 1 "1 pers." 2 "2 pers." 3 "3 pers." 4 "4 pers." 5 "5 perrs." 6 "6 pers. ou +" 99 "Missing data"
	label values nhouse_tot_classif lbnhousetotclassif	

	*NOMBRE PERSONNES DANS LE FOYER nhouse_people_tot - 3 classes [1-2] [3-4] [5 et plus]
 	gen nhouse_tot_classif2 = nhouse_tot_classif
	recode nhouse_tot_classif2 (2=1) (3=2) (4=2) (5=3) (6=3)
	order nhouse_tot_classif2, after(nhouse_tot_classif)
	label variable nhouse_tot_classif2 "Nombre de personnes résidant dans le foyer"
	label define lbnhousetotclassif2 1 "1 ou 2 pers." 2 "3 ou 4 pers." 3 "5 pers. ou plus" 99 "Missing data"
	label values nhouse_tot_classif2 lbnhousetotclassif2	

	*NOMBRE PERSONNES DANS LE FOYER nhouse_people_tot - 4 classes [1-2] [3-5] [6-10] [11 et plus]
 	gen nhouse_tot_classif3 = recode(nhouse_people_tot,2,5,10,11) if nhouse_people_tot !=77
	replace nhouse_tot_classif3 =99 if nhouse_people_tot ==77
	recode nhouse_tot_classif3 (2=1) (5=2) (10=3) (11=4)
	order   nhouse_tot_classif3, after(nhouse_tot_classif2)
	label variable nhouse_tot_classif3 "Nombre de personnes résidant dans le foyer"
	label define lbnhousetotclassif3 1 "1 à 2 pers." 2 "3 à 5 pers." 3 "6 à 10 pers." 4 "11 pers. ou plus"  99 "Missing data"
	label values nhouse_tot_classif3 lbnhousetotclassif3	

* CREATION DE LA CLASSE 'MARQUISIEN' DANS LA VARIABLE LANGUE MATERNELLE (SORTIE DE 'OTHERS')	
gen	native_language2 = native_language
	recode native_language2 (5=6)
	replace native_language2 = 5 if strpos(native_language_prec, "Marqui") | strpos(native_language_prec, "Mzrqui")  
	replace native_language2 = 1 if strpos(native_language_prec, "ran")  
	replace native_language2 = 6 if  native_language ==3 | native_language ==4
	label define lbnativelanguage2 1 French 2 Tahitian 3 English 4 Spanish 5 Marquisian 6 Other
	label values native_language2 lbnativelanguage2 
	order native_language2, after(native_language)
	
* CIGUATERA
gen ciguatera_freq2 = ciguatera_freq
	order ciguatera_freq2, after (ciguatera_freq)
	recode ciguatera_freq2 (77=99) (6=5)
	label define lbciguaterafreq2 0 "Never" 1 "Once" 2 "Twice" 3 "Three times" 4 "Four times" 5 "Five or more" 99 "Missing data"
	label values ciguatera_freq2 lbciguaterafreq2 

gen ciguatera_freq3 = ciguatera_freq
	order ciguatera_freq3, after (ciguatera_freq2)
	recode ciguatera_freq3 (77=99) (3=2) (4=2) (5=2) (6=2)
	label define lbciguaterafreq3 0 "Never" 1 "Once" 2 "Twice or more" 99 "Missing data"
	label values ciguatera_freq3 lbciguaterafreq3 
	
* NBRE ANNEE DEPUIS DIAGNOSTIC CANCER
gen cancer_year =.
	order cancer_year, after(cancer_age)
	label var cancer_year "Number of years since diagnosis"
	replace cancer_year=(age - cancer_age) if cancer_age!=.
				

*******************************************************************************
**# CREATION DE VARIABLES COMPORTEMENT ADDITIONNELLES #3
*******************************************************************************
	
*******************************************************************************
**#			# USAGE TABAC  #3.1
******************************************************************************* 

gen smoking_classif=0
	order smoking_classif, after(smoking_everyday)
	label variable smoking_classif "Classification consommation de tabac"
	replace smoking_classif=1 if smoking_everyday==2
	replace smoking_classif=2 if smoking_everyday==1
	* inclure consommation de paka ?
	label define lbsmokingclassif 0 "Non fumeur" 1 "Usage occasionnel" 2 "Usage quotidien"
	label values smoking_classif lbsmokingclassif

gen smoking_everyday_bool=smoking_classif
	order smoking_everyday_bool, after(smoking_classif)
	label variable smoking_everyday_bool "Fumeur quotidien Y/N"
	recode smoking_everyday_bool (1=0) (2=1)
	label values smoking_everyday_bool lbbooleen
	
* QUANTIFICATION CONSOMMATION TABAC
*** 1/ CALCUL EQUIVALENT CONSOMMATION QUOTIDIENNE PAR FORME DE TABAC
gen ncigaret_indust_per_day_0=ncigaret_indust_per_day
	replace ncigaret_indust_per_day_0=0 if ncigaret_indust_per_day_0==. | ncigaret_indust_per_day_0==77
gen ncigaret_indust_per_week_0=ncigaret_indust_per_week
	replace ncigaret_indust_per_week_0=0 if ncigaret_indust_per_week_0==. | ncigaret_indust_per_week_0==77
gen ncigaret_roll_per_day_0=ncigaret_roll_per_day
	replace ncigaret_roll_per_day_0=0 if ncigaret_roll_per_day_0==. | ncigaret_roll_per_day_0==77
gen ncigaret_roll_per_week_0=ncigaret_roll_per_week
	replace ncigaret_roll_per_week_0=0 if ncigaret_roll_per_week_0==. | ncigaret_roll_per_week_0==77
gen other_tabaco_per_day_0=other_tabaco_per_day
	replace other_tabaco_per_day_0=0 if other_tabaco_per_day_0==. | other_tabaco_per_day_0==77
gen other_tabaco_per_week_0=other_tabaco_per_week
	replace other_tabaco_per_week_0=0 if other_tabaco_per_week_0==. | other_tabaco_per_week_0==77
*?? remplacer les 77 par 0 ou valeurs manquantes=> ne pas prendre en compte => voir plus et les 5 cas particulier

gen ncigaret_indust_per_day_equ = ncigaret_indust_per_day_0+ ncigaret_indust_per_week_0/7
	replace ncigaret_indust_per_day_equ =. if smoking_prst==2
	order ncigaret_indust_per_day_equ, after(ncigaret_indust_per_week)
	label variable ncigaret_indust_per_day_equ "Nombre equivalent de cigarettes industrielles fumées par jour"

gen ncigaret_roll_per_day_equ = ncigaret_roll_per_day_0+ ncigaret_roll_per_week_0/7
	replace ncigaret_roll_per_day_equ =. if smoking_prst==2
	order ncigaret_roll_per_day_equ, after(ncigaret_roll_per_week)
	label variable ncigaret_roll_per_day_equ "Nombre equivalent de cigarettes roulées fumées par jour"
	
gen other_tabaco_per_day_equ = other_tabaco_per_day_0+ other_tabaco_per_week_0/7
	replace other_tabaco_per_day_equ =. if smoking_prst==2
	order other_tabaco_per_day_equ, after(other_tabaco_per_week)
	label variable other_tabaco_per_day_equ "Nombre equivalent d'autres tabacs fumés par jour"

* Quelques consommateurs de paka / Cannabis classés dans autres ; RETRAIT DES CONSOMMATION DE CANNABIS / PAKA DE AUTRES 
* cigarette electro / vapoteuse maintenus
* strpos(other_tabaco_prec,"electro") | strpos(other_tabaco_prec,"Vapo") 
replace other_tabaco_per_day_equ =0 if strpos(other_tabaco_prec,"pak") | strpos(other_tabaco_prec,"Pak") | strpos(other_tabaco_prec,"Cannabis") | strpos(other_tabaco_prec,"Marijuana") | strpos(other_tabaco_prec,"Pipette")  

* CONSIDERATION DE CONSO 'DONT KNOW' / 77 POUR LES PARTICIPANTS N'AYANT PAS D'AUTRE CONSOMMATION
* 5 participants / 32 (BO0131ILM GA0220ILM TA8451ILM TA8859ILM TA8586ILM) n'ont pas d'autres conso que le 77
* browse subjid gender age smoking_everyday ncigaret_indust_per_day ncigaret_indust_per_week ncigaret_indust_per_day_equ ncigaret_roll_per_day ncigaret_roll_per_week ncigaret_roll_per_day_equ  other_tabaco_per_day other_tabaco_per_week  other_tabaco_per_day_equ other_tabaco_prec if ncigaret_indust_per_day ==77 | ncigaret_indust_per_week  ==77 | ncigaret_roll_per_day  ==77 | ncigaret_roll_per_week  ==77 | other_tabaco_per_day  ==77 | other_tabaco_per_week   ==77
replace ncigaret_indust_per_day_equ=. if subjid=="BO0131ILM"
replace ncigaret_roll_per_day_equ=. if subjid=="BO0131ILM"
replace other_tabaco_per_day_equ=. if subjid=="BO0131ILM"

replace ncigaret_roll_per_day_equ=. if subjid=="GA0220ILM"

replace ncigaret_roll_per_day_equ=. if subjid=="TA8451ILM"

replace other_tabaco_per_day_equ=. if subjid=="TA8859ILM"

replace ncigaret_roll_per_day_equ=. if subjid=="TA8586ILM"

*** 2/ CALCUL EQUIVALENT CONSOMMATION QUOTIDIENNE TOTALE
gen ntabaco_per_day_equ = ncigaret_indust_per_day_equ+ncigaret_roll_per_day_equ+other_tabaco_per_day_equ
	order ntabaco_per_day_equ, after(other_tabaco_per_day_equ)
	label variable ntabaco_per_day_equ "Nombre total toutes cigarettes / tabac par jour"
	replace ntabaco_per_day_equ =0 if smoking_prst ==2
	* attention, les participants qui déclarent dans un 1er temps fumer, puis déclarent 0 par jour et par semaine sur les 3 types de prise (n=16) sont donc à 0/jour

*** 3/ CLASSES EQUIVALENT CONSOMMATION QUOTIDIENNE TOTALE
gen ntabaco_per_day_equ_class = recode(ntabaco_per_day_equ,0,10,20,21)
	recode ntabaco_per_day_equ_class(10=1) (20=2) (21=3) (.=99)
	label var ntabaco_per_day_equ_class "Equivalent nombre total cigarettes par jour"
	label define lbntabaco 1 "[1 - 10]" 2 "[11 - 20]" 3 "[21 and more" 99 "Missing data"
	label values ntabaco_per_day_equ_class lbntabaco 
	order ntabaco_per_day_equ_class, after(ntabaco_per_day_equ)
	
*** 4/ IDENTIFICATION FORME TABAC LA PLUS CONSOMMEE
egen ntabaco_max=rowmax(ncigaret_indust_per_day_equ ncigaret_roll_per_day_equ other_tabaco_per_day_equ)

gen smoking_type = 0
	order smoking_type, after(ntabaco_per_day_equ_class)
	label var smoking_type "Forme de tabac la plus consommée"
	
forvalues j = 1/3 {
  replace smoking_type = smoking_type + (ncigaret_indust_per_day_equ == ntabaco_max) *100 if `j'==3
  replace smoking_type = smoking_type + (ncigaret_roll_per_day_equ == ntabaco_max) *10 if `j'==2
  replace smoking_type = smoking_type + (other_tabaco_per_day_equ == ntabaco_max)  if `j'==1 
  }
replace smoking_type =999 if ntabaco_max==. | ntabaco_max==0
  
	label define lbsmokingtype 1 "Other tabaco" 10 "Rolled cigarets" 100 "Industrial cigarets" 101 "Industrial & Other" 110 "Industrial & Rolled" 999 "Missing data"
	label values smoking_type lbsmokingtype

drop ntabaco_max
drop ncigaret_indust_per_day_0
drop ncigaret_indust_per_week_0
drop ncigaret_roll_per_day_0
drop ncigaret_roll_per_week_0
drop other_tabaco_per_day_0
drop other_tabaco_per_week_0
	
*******************************************************************************
**#			# USAGE PAKA  #3.2
******************************************************************************* 
gen 			paka_last_year_bool = paka_last_year
	recode 		paka_last_year_bool (2=0) (77=99) (88=99)
	replace 	paka_last_year_bool =0 if paka_last_year_bool ==99 & paka==2 
	label values paka_last_year_bool lbbooleen
	order 		paka_last_year_bool, after(paka_last_year)
	label var 	paka_last_year_bool "Paka consumption in the last 12 months Y/N"

gen 			paka_weekly_bool = paka_last_year_freq
	recode 		paka_weekly_bool (2=1) (3=1) (4=0) (5=0) (77=99)
	replace 	paka_weekly_bool=0 if paka_weekly_bool ==99 & paka_last_year_bool ==0 
	label values paka_weekly_bool lbbooleen
	order 		paka_weekly_bool, after(paka_last_year_freq)
	label var 	paka_weekly_bool "Paka consumption more than once a week Y/N"

	
*******************************************************************************
**#			# USAGE ALCOOL  #3.3
******************************************************************************* 

gen alcool_12m_bool=alcool_last_year
	order alcool_12m_bool, after(alcool_last_year)
	label var alcool_12m_bool "Alcohol consumption in the last 12 months"
	label values alcool_12m_bool  lbbooleen
	recode alcool_12m_bool (2=0)
	replace alcool_12m_bool = 0 if alcool_12m_bool ==99 & alcool ==2

gen alcool_use = recode(alcool_one_glass_last_year_freq,1,4,7) if alcool_one_glass_last_year_freq !=99
	replace alcool_use =0 if alcool_one_glass_last_year_freq ==99 
	recode alcool_use (4=2) (7=3)
	order alcool_use, after(alcool_one_glass_last_year_freq)
	label var alcool_use "Classification of alcohol consumption"
	label define lbalcooluse 0 "No alcohol in the past 12 months" 1 "Daily use" 2 "Regular use" 3 "Occasional use" 99 "Missing data"
	label values alcool_use lbalcooluse 
	
gen alcool_30d_bool = alcool_last_month
	replace alcool_30d_bool = 0 if alcool_30d_bool ==99 & alcool_12m_bool ==0
	replace alcool_30d_bool = 0 if alcool_30d_bool ==99 & alcool ==2
	order alcool_30d_bool, after(alcool_last_month)
	label var alcool_30d_bool "Alcohol consumption in the last 30 days"
	label values alcool_30d_bool  lbbooleen
	recode alcool_30d_bool (2=0)

gen alcool_category = recode(nalcool_glass_last_month,3,5,6) if gender==1
	replace alcool_category = recode(nalcool_glass_last_month,1,3,4) if gender==2
	replace alcool_category= 99 if nalcool_glass_last_month==77 | (nalcool_glass_last_month ==. & alcool_last_month ==1)
	replace alcool_category= 999 if alcool ==2 | alcool_last_year ==2 | alcool_last_month ==2
	recode alcool_category (3=1) (5=2) (6=3) if gender==1
	recode alcool_category (3=2) (4=3) if gender==2
	order alcool_category, after(nalcool_glass_last_month)
	label var alcool_category "Category of alcohol consumers"
	label define lbalcoolcat 1 "Category I" 2 "Category II" 3 "Category III" 99"Missing data" 999 "N/A"
	label values alcool_category lbalcoolcat
	
	
*******************************************************************************
**#			# HYGIENE ALIMENTAIRE #3.4
******************************************************************************* 
// RECO FRUITS ET LEGUMES : 5 OU PLUS PAR JOUR 
gen 			fruit_avg_per_day = (fruit_nday_per_week * nfruit_per_day)/7
	order 		fruit_avg_per_day,after(nfruit_per_day)
	label var 	fruit_avg_per_day "Servings of fruit on avg per day"
gen 			vege_avg_per_day = (vege_nday_per_week * nvege_per_day)/7
	order 		vege_avg_per_day,after(nvege_per_day)
	label var 	vege_avg_per_day "Servings of veg on avg per day"
	
	* le programme EPI-Info de l'OMS considère la consommation d'un seul élément (fruit par exemple) si des données sont manquantes dans le 2nd élément (vege par exemple)
	* [IF (FruitCLN=1 AND VegCLN=2) THEN amount=((D1*D2)/7)]
gen 		fruit_vege_avg_per_day = max(fruit_avg_per_day,0) + max(vege_avg_per_day,0)
	replace fruit_vege_avg_per_day =. if fruit_avg_per_day ==. & vege_avg_per_day==.
	order   fruit_vege_avg_per_day,after(snack_freq)
	label var fruit_vege_avg_per_day "Servings of fruit/veg on avg per day"
	
gen 			 reco_fruit_vege =1  if fruit_vege_avg_per_day >=5 & fruit_vege_avg_per_day !=.
	replace 	 reco_fruit_vege =0  if fruit_vege_avg_per_day <5
	replace 	 reco_fruit_vege =99 if fruit_vege_avg_per_day ==.
	label define lbrecofruitvege 1 "5 or more servings of fruit/veg on avg per day" 0 "Less than 5 servings of fruit/veg on avg per day" 99 "Missing data"
	label values reco_fruit_vege lbrecofruitvege 
	order 		 reco_fruit_vege,after(fruit_vege_avg_per_day)
	label var 	 reco_fruit_vege "Servings of fruit/veg on avg per day"

// Regroupement de classes 
gen 			 seasoning_before_during_cat = 1 if seasoning_before_during == 1 | seasoning_before_during == 2
	replace 	 seasoning_before_during_cat = 0 if seasoning_before_during == 3 | seasoning_before_during == 4 | seasoning_before_during == 5
	order 		 seasoning_before_during_cat, after (seasoning_before_during)
	label values seasoning_before_during_cat lbseasoning
	label define lbseasoning 1 "Always / Often" 0 "Sometimes / Rarely / Never" 99 "Missing data"
	
gen 			 seasoning_cooking_cat = 1 if seasoning_cooking == 1		| seasoning_cooking == 2
	replace 	 seasoning_cooking_cat = 0 if seasoning_cooking == 3  | seasoning_cooking == 4 | seasoning_cooking == 5
	replace 	 seasoning_cooking_cat = 99 if seasoning_cooking == 77
	order 		 seasoning_cooking_cat, after (seasoning_cooking)
	label values seasoning_cooking_cat lbseasoning

gen 			 eat_salty_food_cat = 1 if eat_salty_food == 1	 | eat_salty_food == 2
	replace 	 eat_salty_food_cat = 0 if eat_salty_food == 3 	 | eat_salty_food == 4 | eat_salty_food == 5
	order 		 eat_salty_food_cat, after (eat_salty_food)
	label values eat_salty_food_cat lbseasoning
	
// SCORE CONSOMMATION DE SEL
gen 			salt_added = seasoning_before_during_cat + seasoning_cooking_cat + eat_salty_food_cat if seasoning_cooking_cat !=99
	replace 	salt_added = seasoning_before_during_cat + eat_salty_food_cat if seasoning_cooking_cat ==99	//discutable - valeur manquante plutôt ??
	label var 	salt_added "Score sel : 0 faible consommation du sel / 3 forte consommation de sel"	
	order 		salt_added, after(eat_salty_food_cat)

// SODA
	gen 	tp_sweet_drink_week_freq =sweet_drink_last_month_freq 
	recode  tp_sweet_drink_week_freq (1=6) (2=3) (3=1) (4=0.46) (5=0.23) (77=99) (88=99) 
gen 	  sweet_drink_avg_per_day = (tp_sweet_drink_week_freq * nsweet_drink_glass_per_day)/7 if nsweet_drink_glass_per_day !=99
	label var sweet_drink_avg_per_day "Nombre moyen de boissons sucrées par jour"
	order sweet_drink_avg_per_day , after(nsweet_drink_glass_per_day)
	drop 	tp_sweet_drink_week_freq
	
	
*******************************************************************************
**#			# ACTIVITE PHYSIQUE #3.5
******************************************************************************* 
* Creation d'une variable bouléeen (0/1) de pratique d'une activité physique intense (pro ou loisir)
gen phys_act_hard_bool = phys_act_hard_work * phys_act_hard_leisure
	recode phys_act_hard_bool (4=0) (2=1)
	label variable phys_act_hard_bool "Intense activity Y/N"
	order phys_act_hard_bool, after(sitting_laying_minute)
	label values phys_act_hard_bool lbbooleen

* Creation d'une variable bouléeen (0/1) de pratique d'une activité physique modérée (pro, loisir ou déplacement vélo/pied)
gen phys_act_medium_or_walk_bool = phys_act_medium_work * phys_act_medium_leisure *velo_or_walk
	recode phys_act_medium_or_walk_bool (8=0) (2=1) (4=1)
	label variable phys_act_medium_or_walk_bool "Moderate activity or walk or velo Y/N"
	order phys_act_medium_or_walk_bool, after(phys_act_hard_bool)
	label values phys_act_medium_or_walk_bool lbbooleen

* Distinction des valeurs nulles des données manquantes
replace phys_act_hard_per_week =0 if phys_act_hard_work ==2
replace phys_act_hard_hour =0 if phys_act_hard_work ==2
replace phys_act_hard_minute =0 if phys_act_hard_work ==2

replace phys_act_medium_per_week =0 if phys_act_medium_work ==2
replace phys_act_medium_hour =0 if phys_act_medium_work ==2
replace phys_act_medium_minute =0 if phys_act_medium_work ==2

replace velo_or_walk_freq =0 if velo_or_walk ==2
replace velo_or_walk_hour =0 if velo_or_walk ==2
replace velo_or_walk_minute =0 if velo_or_walk ==2

replace phys_act_hard_leisure_per_week =0 if phys_act_hard_leisure ==2
replace phys_act_hard_leisure_hour =0 if phys_act_hard_leisure ==2
replace phys_act_hard_leisure_minute =0 if phys_act_hard_leisure ==2

replace phys_act_medium_leisure_per_week =0 if phys_act_medium_leisure ==2
replace phys_act_medium_leisure_hour =0 if phys_act_medium_leisure ==2
replace phys_act_medium_leisure_minute =0 if phys_act_medium_leisure ==2

* Volume quotidien et hebdo d'activité exprimé en minutes
gen phys_act_hard_minute_daily = phys_act_hard_hour*60 + phys_act_hard_minute
	order phys_act_hard_minute_daily, after(phys_act_hard_minute)
gen phys_act_hard_minute_weekly = phys_act_hard_minute_daily * phys_act_hard_per_week
	order phys_act_hard_minute_weekly, after(phys_act_hard_minute_daily) 
	
gen phys_act_medium_minute_daily = phys_act_medium_hour*60 + phys_act_medium_minute
	order phys_act_medium_minute_daily, after(phys_act_medium_minute)
gen phys_act_medium_minute_weekly = phys_act_medium_minute_daily * phys_act_medium_per_week
	order phys_act_medium_minute_weekly, after(phys_act_medium_minute_daily) 
	
gen velo_or_walk_minute_daily = velo_or_walk_hour*60 + velo_or_walk_minute
	order velo_or_walk_minute_daily, after(velo_or_walk_minute)
gen velo_or_walk_minute_weekly = velo_or_walk_minute_daily * velo_or_walk_freq
	order velo_or_walk_minute_weekly, after(velo_or_walk_minute_daily) 
	
gen act_hard_leisure_daily = phys_act_hard_leisure_hour*60 + phys_act_hard_leisure_minute
	order act_hard_leisure_daily, after(phys_act_hard_leisure_minute)
gen act_hard_leisure_weekly = act_hard_leisure_daily * phys_act_hard_leisure_per_week
	order act_hard_leisure_weekly, after(act_hard_leisure_daily) 
	
gen act_medium_leisure_daily = phys_act_medium_leisure_hour*60 + phys_act_medium_leisure_minute
	order act_medium_leisure_daily, after(phys_act_medium_leisure_minute)
gen act_medium_leisure_weekly = act_medium_leisure_daily * phys_act_medium_leisure_per_week
	order act_medium_leisure_weekly, after(act_medium_leisure_daily) 

* Nombre hebdomadaire de journées d'activité intense / modérée (inclut pied/vélo)
gen nb_hard_days_per_week = max(phys_act_hard_per_week,0) + max(phys_act_hard_leisure_per_week,0)
		* list subjid phys_act_hard_work phys_act_hard_per_week phys_act_hard_minute_weekly phys_act_hard_leisure phys_act_hard_leisure_per_week act_hard_leisure_weekly nb_hard_days_per_week  if  phys_act_hard_per_week==. | phys_act_hard_leisure_per_week==.
		* attention TA8046ILM phys_act_hard_leisure_per_week=5 / hard_minutes_per_week =900 (3h/j) suffit à le qualifier comme activité élevé ??? voir avec Yoann
	replace nb_hard_days_per_week =. if (phys_act_hard_per_week==. | phys_act_hard_leisure_per_week==.) & max(phys_act_hard_minute_weekly,0)+max(act_hard_leisure_weekly,0)<60
	order nb_hard_days_per_week, after(phys_act_medium_or_walk_bool)
	label variable nb_hard_days_per_week "Number of days of intense activity per week"

gen nb_medium_days_per_week = max(phys_act_medium_per_week,0) + max(velo_or_walk_freq,0) + max(phys_act_medium_leisure_per_week,0)
		*list subjid phys_act_medium_per_week phys_act_medium_minute_weekly velo_or_walk_freq velo_or_walk_minute_weekly phys_act_medium_leisure_per_week act_medium_leisure_weekly nb_medium_days_per_week if phys_act_medium_per_week ==. | velo_or_walk_freq ==. | phys_act_medium_leisure_per_week ==.
		* attention BO0132ILM BO0147ILM TA8046ILM (meme que plus haut) respectivement minimum de 2880 1500 et 180 min d'activité modérés : qualifiés pour activité élevé et moyenne ??? voir avec Yoann
	replace nb_medium_days_per_week =. if (phys_act_medium_per_week ==. | velo_or_walk_freq ==. | phys_act_medium_leisure_per_week ==.) & max(phys_act_medium_minute_weekly,0)+max(velo_or_walk_minute_weekly,0)+max(act_medium_leisure_weekly,0)<150
	order nb_medium_days_per_week, after(nb_hard_days_per_week)
	label variable nb_medium_days_per_week "Number of days of moderate activity per week"

gen nb_act_days_per_week = 	nb_hard_days_per_week + nb_medium_days_per_week
	order nb_act_days_per_week, after(nb_medium_days_per_week)
	label var nb_act_days_per_week "Number of days of intense or moderate activity per week"
	
* Volume d'activités intenses et modérés par semaine, exprimé en minutes	
gen hard_minutes_per_week = max(phys_act_hard_minute_weekly,0) + max(act_hard_leisure_weekly,0)
	* list subjid phys_act_hard_minute phys_act_hard_minute_weekly phys_act_hard_leisure_minute act_hard_leisure_weekly hard_minutes_per_week  if phys_act_hard_minute_weekly ==. | act_hard_leisure_weekly ==.
	* attention a TA8046ILM (meme que plus haut) HI0203ILM (180 min hard leisure) et TA8786ILM (420 min hard leisure ) ??? voir avec Yoann
	replace hard_minutes_per_week=. if (phys_act_hard_minute_weekly ==. | act_hard_leisure_weekly ==.) & hard_minutes_per_week<60
	order hard_minutes_per_week ,after(nb_medium_days_per_week)
	label var hard_minutes_per_week "Time spent in intense activity per week, in minutes"
	
gen medium_minutes_per_week = max(phys_act_medium_minute_weekly,0) + max(velo_or_walk_minute_weekly,0) + max(act_medium_leisure_weekly,0)
	*list subjid phys_act_medium_minute_weekly velo_or_walk_minute_weekly act_medium_leisure_weekly medium_minutes_per_week if phys_act_medium_minute_weekly ==. | act_medium_leisure_weekly ==. | velo_or_walk_minute_weekly==.
	* attention, bcp de medium_minutes_per_week > 150 min avec seulement 1 ou 2 activités / 3  ??? voir avec Yoann
	replace medium_minutes_per_week =. if (phys_act_medium_minute_weekly ==. | velo_or_walk_minute_weekly ==. | act_medium_leisure_weekly ==. ) & medium_minutes_per_week<150
	order medium_minutes_per_week, after(hard_minutes_per_week)
	label var medium_minutes_per_week "Time spent in moderate activity per week, in minutes"
	
* MET (Metabolic Equivalent of Task) minute par semaine
gen met_per_week = 8*max(hard_minutes_per_week,0) + 4*max(medium_minutes_per_week,0) 
	replace met_per_week =. if hard_minutes_per_week ==. | medium_minutes_per_week ==.
	order met_per_week, after(medium_minutes_per_week)
	label var met_per_week "Physical activity per week in MET.minutes"
	
* Niveau d'activité physique
gen phys_act_level = 1
	order phys_act_level, after(met_per_week)
	label var phys_act_level "Level of physical activity"
	label define lbphysact 1 "Limited physical activity" 2 "Moderate physical activity" 3 "High physical activity" 99 "Missing data"
	label values phys_act_level lbphysact 
	
	replace phys_act_level =99 if nb_act_days_per_week ==.

	* critère : "au moins 30 minutes d'activité physique modérée ou de marche à pied par jour pendant 5 jours ou plus par semaine" (tel que codé dans EPI-info)
	replace phys_act_level =2 if (nb_medium_days_per_week >=5 & nb_medium_days_per_week !=.) & (medium_minutes_per_week >150 & medium_minutes_per_week !=.)
	* critère : "au moins 5 jours de marche à pied et d'activité physique modérée ou intense, jusqu'à parvenir à un minimum de 600 MET-minutes par semaine."
	replace phys_act_level =2 if (nb_act_days_per_week >=5 & nb_act_days_per_week !=.) & (met_per_week >=600 & met_per_week !=.)
	*critère : "au moins 20 minutes d'activité physique intense par jour pendant 3 jours ou plus par semaine"
	replace phys_act_level =2 if (phys_act_hard_per_week >=3 & phys_act_hard_per_week !=.) & (phys_act_hard_minute_daily >=20 & phys_act_hard_minute_daily !=.)
	replace phys_act_level =2 if (phys_act_hard_leisure_per_week >=3 & phys_act_hard_leisure_per_week !=.) & (act_hard_leisure_daily >=20 & act_hard_leisure_daily !=.)
	replace phys_act_level =2 if (phys_act_hard_minute_daily >=20 & phys_act_hard_minute_daily !=.) & (act_hard_leisure_daily >=20 & act_hard_leisure_daily !=.) & (nb_hard_days_per_week >=3 & nb_hard_days_per_week !=.)
	
	* critere : "au moins 7 jours de marche à pied et d'activité physique modérée ou intense jusqu'à parvenir à un minimum de 3000 MET-minutes par semaine."
	replace phys_act_level =3 if (nb_act_days_per_week >=7 & nb_act_days_per_week !=.) & (met_per_week >=3000 & met_per_week !=.)
	* critere : "activité physique intense au moins 3 jours par semaine, entraînant une dépense énergétique d'au moins 1500 MET-minutes par semaine"
	replace phys_act_level =3 if (nb_hard_days_per_week >=3 & nb_hard_days_per_week !=.) & (met_per_week >= 1500 & met_per_week !=.)

	
***************************************************************	
**# CREATION DE VARIABLES LABO ADDITIONNELLES #4
***************************************************************
label define lblabo -1 "inférieur à la norme" 0 "Normal" 1 "Superieur à la norme" 99 "Mising data"

gen 		res_hba1g_cat = 0 if res_hba1g <6.5
	replace res_hba1g_cat = 1 if res_hba1g >=6.5 & res_hba1g !=. 
	replace res_hba1g_cat = 99 if res_hba1g ==.
	order 	res_hba1g_cat , after(res_hba1g)
	label values res_hba1g_cat lblabo
	label variable res_hba1g_cat "Hémoglobine A1C"

* res_index_idl
* res_index_idh
* res_index_idi
gen res_ct_cat = 0 if res_ct<=6.58 & res_ct >=4 & gender == 1
	replace res_ct_cat = 1  if res_ct >6.58 & res_ct !=. & gender==1
	replace res_ct_cat = -1 if res_ct <4 & gender==1
	replace res_ct_cat = 0  if res_ct<=5.95 & res_ct >=3.35 & gender == 2
	replace res_ct_cat = 1  if res_ct >5.95 & res_ct !=. & gender==2
	replace res_ct_cat = -1 if res_ct <3.35 & gender==2
	replace res_ct_cat = 99 if res_ct ==.
	order 	res_ct_cat , after(res_ct)
	label values 	res_ct_cat lblabo
	label variable  res_ct_cat "Cholestérol"

gen 		res_tg_cat = 0  if res_tg<=2 & res_tg >=0.5 & gender == 1
	replace res_tg_cat = 1  if res_tg >2 & res_tg !=. & gender==1
	replace res_tg_cat = -1 if res_tg <0.5 & gender==1
	replace res_tg_cat = 0  if res_tg<=1.6 & res_tg >=0.4 & gender == 2
	replace res_tg_cat = 1  if res_tg >1.6 & res_tg !=. & gender==2
	replace res_tg_cat = -1 if res_tg <0.4 & gender==2
	replace res_tg_cat = 99 if res_tg ==.
	order 	res_tg_cat , after(res_tg)
	label values 	res_tg_cat lblabo
	label variable  res_tg_cat "Triglycérides"
	
gen 		res_hdl_hdl_cat = 0  if res_hdl_hdl <=2.4 & res_hdl_hdl >=1.5 & gender == 1
	replace res_hdl_hdl_cat = 1  if res_hdl_hdl >2.4 & res_hdl_hdl !=. & gender==1
	replace res_hdl_hdl_cat = -1 if res_hdl_hdl <1.5 & gender==1
	replace res_hdl_hdl_cat = 0  if res_hdl_hdl<=1.68 & res_hdl_hdl >=0.96 & gender == 2
	replace res_hdl_hdl_cat = 1  if res_hdl_hdl >1.68 & res_hdl_hdl !=. & gender==2
	replace res_hdl_hdl_cat = -1 if res_hdl_hdl <0.96 & gender==2
	replace res_hdl_hdl_cat = 99 if res_hdl_hdl ==.
	order   res_hdl_hdl_cat , after(res_hdl_hdl)
	label values 	res_hdl_hdl_cat lblabo
	label variable  res_hdl_hdl_cat "Cholestérol HDL"

gen 		res_hdl_rcthd_cat = 0 if res_hdl_rcthd<5 & gender == 1
	replace res_hdl_rcthd_cat=1   if res_hdl_rcthd>=5 & res_hdl_rcthd !=. & gender == 1
	replace res_hdl_rcthd_cat =0  if res_hdl_rcthd <4.9 & gender == 2
	replace res_hdl_rcthd_cat =1  if res_hdl_rcthd>= 4.9 & res_hdl_rcthd != . & gender == 2
	replace res_hdl_rcthd_cat =99 if res_hdl_rcthd ==.
	order 	res_hdl_rcthd_cat , after(res_hdl_rcthd)
	label values 	res_hdl_rcthd_cat lblabo
	label variable  res_hdl_rcthd_cat "Rapport cholestérol total/HDL"

gen 		res_ldlc_ldlc_cat = 0  if res_ldlc_ldlc >=2.84 & res_ldlc_ldlc<=4.13 & gender == 1
	replace res_ldlc_ldlc_cat = 1  if res_ldlc_ldlc >4.13 & res_ldlc_ldlc !=. & gender==1
	replace res_ldlc_ldlc_cat = -1 if res_ldlc_ldlc <2.84 & gender==1
	replace res_ldlc_ldlc_cat = 0  if res_ldlc_ldlc >=2.58 & res_ldlc_ldlc<=3.87 & gender == 2
	replace res_ldlc_ldlc_cat = 1  if res_ldlc_ldlc >3.87 & res_ldlc_ldlc !=. & gender==2
	replace res_ldlc_ldlc_cat = -1 if res_ldlc_ldlc <2.58 & gender==2
	replace res_ldlc_ldlc_cat = 99 if res_ldlc_ldlc ==.
	order 	res_ldlc_ldlc_cat , after(res_ldlc_ldlc)
	label values 	res_ldlc_ldlc_cat lblabo
	label variable  res_ldlc_ldlc_cat "Calcul du cholestérol LDL"

gen 		res_ldlc_rhdld_cat = 0 if res_ldlc_rhdld >0.29 & res_ldlc_rhdld!=. 
	replace res_ldlc_rhdld_cat =-1 if res_ldlc_rhdld<= 0.29 
	replace res_ldlc_rhdld_cat =99 if res_ldlc_rhdld ==.
	order 	res_ldlc_rhdld_cat ,after(res_ldlc_rhdld)
	label values 	res_ldlc_rhdld_cat lblabo
	label variable  res_ldlc_rhdld_cat "Rapport cholestérol HDL/LDL"

gen 		res_pt2_cat = 0 if res_pt2<41 & gender == 1
	replace res_pt2_cat = 1 if res_pt2>=41 & res_pt2 !=. & gender == 1
	replace res_pt2_cat = 0 if res_pt2 <33 & gender == 2
	replace res_pt2_cat = 1 if res_pt2>= 33 & res_pt2 != . & gender == 2
	replace res_pt2_cat =99 if res_pt2 ==.
	order 	res_pt2_cat , after(res_pt2)
	label values 	res_pt2_cat lblabo
	label variable  res_pt2_cat "Transaminases SGPT - ALAT"

gen 		res_ot_cat = 0 if res_ot<40 & gender == 1
	replace res_ot_cat = 1 if res_ot>=40 & res_ot !=. & gender == 1
	replace res_ot_cat = 0 if res_ot <32 & gender == 2
	replace res_ot_cat = 1 if res_ot>= 32 & res_ot != . & gender == 2
	replace res_ot_cat =99 if res_ot ==.
	order 	res_ot_cat ,after(res_ot)
	label values 	res_ot_cat lblabo
	label variable  res_ot_cat "Transaminases SGOT - ASAT"

gen 		res_cr_cat = 0 if res_cr >=62 & res_cr<=106 & gender == 1
	replace res_cr_cat = 1 if res_cr >106 & res_cr !=. & gender==1
	replace res_cr_cat =-1 if res_cr <62 & gender==1
	replace res_cr_cat = 0 if res_cr >=44 & res_cr<=80 & gender == 2
	replace res_cr_cat = 1 if res_cr >80 & res_cr !=. & gender==2
	replace res_cr_cat =-1 if res_cr <44 & gender==2
	replace res_cr_cat =99 if res_cr ==.
	order 	res_cr_cat ,after(res_cr)
	label values 	res_cr_cat lblabo
	label variable  res_cr_cat "Créatinine"

gen 		res_dfgf1_cat =10 if res_dfgf1 >=90 & res_dfgf1 !=. 
	replace res_dfgf1_cat =20 if res_dfgf1_cat ==. & res_dfgf1 >= 60 & res_dfgf1 !=.
	replace res_dfgf1_cat =30 if res_dfgf1_cat ==. & res_dfgf1 >= 45 & res_dfgf1 !=.
	replace res_dfgf1_cat =35 if res_dfgf1_cat ==. & res_dfgf1 >= 30 & res_dfgf1 !=.
	replace res_dfgf1_cat =40 if res_dfgf1_cat ==. & res_dfgf1 >= 15 & res_dfgf1 !=.
	replace res_dfgf1_cat =50 if res_dfgf1_cat ==. & res_dfgf1 <  15 & res_dfgf1 !=.
	replace res_dfgf1_cat =99 if res_dfgf1 ==.
	order 	res_dfgf1_cat ,after(res_dfgf1)
	label define lbresdfg 10 "Maladie rénale chronique avec DFG normal" 20 "Maladie rénale chronique avec DFG légèrement diminué" 30 "Insuffisance rénale chronique modérée" 35 "Insuffisance rénale chronique modérée à sévère" 40 "Insuffisance rénale chronique sévère" 50 "Insuffisance rénale chronique terminale" 99 "Donnée manquante"
	label values 	res_dfgf1_cat lbresdfg
	label variable  res_dfgf1_cat "Débit de filtration glomérulaire F1"

gen 		res_dfgf2_cat =10 if res_dfgf2 >=90 & res_dfgf2 !=. 
	replace res_dfgf2_cat =20 if res_dfgf2_cat ==. & res_dfgf2   >= 60 & res_dfgf2 !=.
	replace res_dfgf2_cat =30 if res_dfgf2_cat ==. & res_dfgf2   >= 45 & res_dfgf2 !=.
	replace res_dfgf2_cat =35 if res_dfgf2_cat ==. & res_dfgf2 >= 30 & res_dfgf2 !=.
	replace res_dfgf2_cat =40 if res_dfgf2_cat ==. & res_dfgf2   >= 15 & res_dfgf2 !=.
	replace res_dfgf2_cat =50 if res_dfgf2_cat ==. & res_dfgf2   < 15 & res_dfgf2 !=.
	replace res_dfgf2_cat =99 if res_dfgf2 ==.
	order 	res_dfgf2_cat ,after(res_dfgf2)
	label values 	res_dfgf2_cat lbresdfg
	label variable  res_dfgf2_cat "Débit de filtration glomérulaire F2"

gen 		res_dfgh1_cat = 10 if res_dfgh1 >=90 & res_dfgh1 !=. 
	replace res_dfgh1_cat= 20 if res_dfgh1_cat ==. & res_dfgh1   >= 60 & res_dfgh1 !=.
	replace res_dfgh1_cat= 30 if res_dfgh1_cat ==. & res_dfgh1   >= 45 & res_dfgh1 !=.
	replace res_dfgh1_cat= 35 if res_dfgh1_cat ==. & res_dfgh1 	 >= 30 & res_dfgh1 !=.
	replace res_dfgh1_cat= 40 if res_dfgh1_cat ==. & res_dfgh1   >= 15 & res_dfgh1 !=.
	replace res_dfgh1_cat= 50 if res_dfgh1_cat ==. & res_dfgh1   < 15 & res_dfgh1 !=.
	replace res_dfgh1_cat = 99 if res_dfgh1 ==.
	order 	res_dfgh1_cat , after(res_dfgh1)
	label values 	res_dfgh1_cat lbresdfg
	label variable  res_dfgh1_cat "Débit de filtration glomérulaire H1"

gen 		res_dfgh2_cat =10 if res_dfgh2 >=90 & res_dfgh2 !=. 
	replace res_dfgh2_cat =20 if res_dfgh2_cat ==. & res_dfgh2   >=60 & res_dfgh2 !=.
	replace res_dfgh2_cat =30 if res_dfgh2_cat ==. & res_dfgh2   >=45 & res_dfgh2 !=.
	replace res_dfgh2_cat =35 if res_dfgh2_cat ==. & res_dfgh2   >=30 & res_dfgh2 !=.
	replace res_dfgh2_cat =40 if res_dfgh2_cat ==. & res_dfgh2   >=15 & res_dfgh2 !=.
	replace res_dfgh2_cat =50 if res_dfgh2_cat ==. & res_dfgh2   < 15 & res_dfgh2 !=.
	replace res_dfgh2_cat =99 if res_dfgh2 ==.
	order   res_dfgh2_cat ,after(res_dfgh2)
	label values 	res_dfgh2_cat lbresdfg
	label variable  res_dfgh2_cat "Débit de filtration glomérulaire H2"
	
gen 		res_crp2_cat = 0	if res_crp2 <5
	replace res_crp2_cat = 1	if res_crp2 >=5 & res_crp2 !=. 
	replace res_crp2_cat =99 if res_crp2 ==.
	order   res_crp2_cat ,after(res_crp2)
	label values 	res_crp2_cat lblabo
	label variable  res_crp2_cat "Protéine C réactive"

gen 		res_ggt_cat = 0 if res_ggt <60 	 & gender == 1
	replace res_ggt_cat = 1 if res_ggt >=60  & res_ggt !=. & gender == 1
	replace res_ggt_cat = 0 if res_ggt <40 	 & gender == 2
	replace res_ggt_cat = 1 if res_ggt >= 40 & res_ggt != . & gender == 2
	replace res_ggt_cat =99 if res_ggt ==.
	order   res_ggt_cat ,after(res_ggt)
	label values 	res_ggt_cat lblabo
	label variable  res_ggt_cat "Gamma-glutamyl transférase"

gen 		res_bilt_cat = 0 if res_bilt <17
	replace res_bilt_cat = 1 if res_bilt >=17 & res_bilt !=. 
	replace res_bilt_cat =99 if res_bilt ==.
	order 	res_bilt_cat ,after(res_bilt)
	label values 	res_bilt_cat lblabo
	label variable  res_bilt_cat "Bilirubine totale"

* dictionneaire de res_asp géré dans "02_MATA EA_Preparation base.do"
* pas de seuil pour res_nfp2_nfrem

gen 		res_nfp2_gr_cat = 0 if res_nfp2_gr >=3.9 & res_nfp2_gr <=5.5
	replace res_nfp2_gr_cat = 1 if res_nfp2_gr > 5.5 & res_nfp2_gr !=. 
	replace res_nfp2_gr_cat =-1 if res_nfp2_gr < 3.9
	replace res_nfp2_gr_cat =99 if res_nfp2_gr ==.
	order 	res_nfp2_gr_cat ,after(res_nfp2_gr)
	label values 	res_nfp2_gr_cat lblabo
	label variable  res_nfp2_gr_cat "NFS - Hématies"

gen 		res_nfp2_hb_cat =0  if res_nfp2_hb >=13.5 & res_nfp2_hb <=17.5 	& gender ==1
	replace res_nfp2_hb_cat =1  if res_nfp2_hb >17.5  & res_nfp2_hb !=. 	& gender ==1
	replace res_nfp2_hb_cat =-1 if res_nfp2_hb <13.5  						& gender ==1
	replace res_nfp2_hb_cat =0  if res_nfp2_hb >=12.5 & res_nfp2_hb <=15.5 	& gender ==2
	replace res_nfp2_hb_cat =1  if res_nfp2_hb >15.5  & res_nfp2_hb !=. 	& gender ==2
	replace res_nfp2_hb_cat =-1 if res_nfp2_hb <12.5  						& gender ==2
	replace res_nfp2_hb_cat =99 if res_nfp2_hb ==.
	order 	res_nfp2_hb_cat, after(res_nfp2_hb)
	label values 	res_nfp2_hb_cat lblabo
	label variable  res_nfp2_hb_cat "NFS - Hémoglobine"

gen 		res_nfp2_ht_cat = 0 if res_nfp2_ht >=40 & res_nfp2_ht <=50 	& gender ==1
	replace res_nfp2_ht_cat = 1 if res_nfp2_ht > 50 & res_nfp2_ht !=. 	& gender ==1
	replace res_nfp2_ht_cat =-1 if res_nfp2_ht < 40 					& gender ==1
	replace res_nfp2_ht_cat = 0 if res_nfp2_ht >=37 & res_nfp2_ht <=47 	& gender ==2
	replace res_nfp2_ht_cat = 1 if res_nfp2_ht >47  & res_nfp2_ht !=. 	& gender ==2
	replace res_nfp2_ht_cat =-1 if res_nfp2_ht <37  					& gender ==2
	replace res_nfp2_ht_cat =99 if res_nfp2_ht ==.
	order 	res_nfp2_ht_cat ,after(res_nfp2_ht)
	label values 	res_nfp2_ht_cat lblabo
	label variable  res_nfp2_ht_cat "NFS - Hématrocrite"

gen 		res_nfp2_vgm_cat = 0 if res_nfp2_vgm >=80 & res_nfp2_vgm<=98
	replace res_nfp2_vgm_cat = 1 if res_nfp2_vgm > 98 & res_nfp2_vgm !=. 
	replace res_nfp2_vgm_cat =-1 if res_nfp2_vgm < 80
	replace res_nfp2_vgm_cat =99 if res_nfp2_vgm ==.
	order 	res_nfp2_vgm_cat ,after(res_nfp2_vgm)
	label values 	res_nfp2_vgm_cat lblabo
	label variable  res_nfp2_vgm_cat "NFS - V.G.M"
	
* pas de seuil pour res_nfp2_vgmc

gen 		res_nfp2_tcmh_cat = 0 if res_nfp2_tcmh >=27 & res_nfp2_tcmh <=32
	replace res_nfp2_tcmh_cat = 1 if res_nfp2_tcmh > 32 & res_nfp2_tcmh !=. 
	replace res_nfp2_tcmh_cat =-1 if res_nfp2_tcmh < 27
	replace res_nfp2_tcmh_cat =99 if res_nfp2_tcmh ==.
	order 	res_nfp2_tcmh_cat ,after(res_nfp2_tcmh)
	label values 	res_nfp2_tcmh_cat lblabo
	label variable  res_nfp2_tcmh_cat "NFS - T.C.M.H"

gen 		res_nfp2_ccmhc_cat = 0 if res_nfp2_ccmhc >=31 & res_nfp2_ccmhc <=35
	replace res_nfp2_ccmhc_cat = 1 if res_nfp2_ccmhc > 35 & res_nfp2_ccmhc !=. 
	replace res_nfp2_ccmhc_cat =-1 if res_nfp2_ccmhc < 31
	replace res_nfp2_ccmhc_cat =99 if res_nfp2_ccmhc ==.
	order 	res_nfp2_ccmhc_cat ,after(res_nfp2_ccmhc)
	label values 	res_nfp2_ccmhc_cat lblabo
	label variable  res_nfp2_ccmhc_cat "NFS - C.C.M.H"
	
* pas de seuil pour res_nfp2_idr
* pas de seuil pour res_nfp2_idrc

gen 		res_nfp2_pla2_cat = 0 if res_nfp2_pla2 >=150 & res_nfp2_pla2<=450
	replace res_nfp2_pla2_cat = 1 if res_nfp2_pla2 > 450 & res_nfp2_pla2 !=. 
	replace res_nfp2_pla2_cat =-1 if res_nfp2_pla2 < 150
	replace res_nfp2_pla2_cat =99 if res_nfp2_pla2 ==.
	order 	res_nfp2_pla2_cat ,after(res_nfp2_pla2)
	label values 	res_nfp2_pla2_cat lblabo 
	label variable  res_nfp2_pla2_cat "NFS - Plaquettes"

gen 		res_nfp2_vpm_cat = 0 if res_nfp2_vpm<=10
	replace res_nfp2_vpm_cat = 1 if res_nfp2_vpm > 10 & res_nfp2_vpm !=. 
	replace res_nfp2_vpm_cat =99 if res_nfp2_vpm ==.
	order 	res_nfp2_vpm_cat ,after(res_nfp2_vpm)
	label values 	res_nfp2_vpm_cat lblabo
	label variable  res_nfp2_vpm_cat "NFS - V.P.M"

gen 		res_nfp2_gb_cat = 0 if res_nfp2_gb >=4 & res_nfp2_gb <=10
	replace res_nfp2_gb_cat = 1 if res_nfp2_gb > 10 & res_nfp2_gb !=. 
	replace res_nfp2_gb_cat =-1 if res_nfp2_gb < 4
	replace res_nfp2_gb_cat =99 if res_nfp2_gb ==.
	order 	res_nfp2_gb_cat ,after(res_nfp2_gb)
	label values 	res_nfp2_gb_cat lblabo
	label variable  res_nfp2_gb_cat "NFS - Leucocytes"

* pas de seuil pour res_nfp2_gbcal
* pas de seuil pour res_nfp2_pn

gen 		res_nfp2_pn3_cat = 0 if res_nfp2_pn3 >=2   & res_nfp2_pn3 <=7.5
	replace res_nfp2_pn3_cat = 1 if res_nfp2_pn3 > 7.5 & res_nfp2_pn3 !=. 
	replace res_nfp2_pn3_cat =-1 if res_nfp2_pn3 < 2
	replace res_nfp2_pn3_cat =99 if res_nfp2_pn3 ==.
	order 	res_nfp2_pn3_cat ,after(res_nfp2_pn3)
	label values 	res_nfp2_pn3_cat lblabo
	label variable  res_nfp2_pn3_cat "NFS - Polynucléaires neutrophiles"

* pas de seuil pour res_nfp2_pe

gen 		res_nfp2_pe3_cat = 0 if res_nfp2_pe3 >=0.04 & res_nfp2_pe3 <=0.7
	replace res_nfp2_pe3_cat = 1 if res_nfp2_pe3 > 0.7  & res_nfp2_pe3 !=. 
	replace res_nfp2_pe3_cat =-1 if res_nfp2_pe3 < 0.04
	replace res_nfp2_pe3_cat =99 if res_nfp2_pe3 ==.
	order 	res_nfp2_pe3_cat ,after(res_nfp2_pe3)
	label values 	res_nfp2_pe3_cat lblabo
	label variable  res_nfp2_pe3_cat "NFS - Polynucléaires éosinophiles"

* pas de seuil pour res_nfp2_ly

gen 		res_nfp2_ly3_cat = 0 if res_nfp2_ly3 >=1   & res_nfp2_ly3 <=4.5
	replace res_nfp2_ly3_cat = 1 if res_nfp2_ly3 > 4.5 & res_nfp2_ly3 !=. 
	replace res_nfp2_ly3_cat =-1 if res_nfp2_ly3 < 1
	replace res_nfp2_ly3_cat =99 if res_nfp2_ly3 ==.
	order 	res_nfp2_ly3_cat ,after(res_nfp2_ly3)
	label values 	res_nfp2_ly3_cat lblabo
	label variable  res_nfp2_ly3_cat "NFS - Lymphocytes"

* pas de seuil pour res_nfp2_mo

gen 		res_nfp2_mo3_cat = 0 if res_nfp2_mo3 >=1   & res_nfp2_mo3 <=4.5
	replace res_nfp2_mo3_cat = 1 if res_nfp2_mo3 > 4.5 & res_nfp2_mo3 !=. 
	replace res_nfp2_mo3_cat =-1 if res_nfp2_mo3 < 1
	replace res_nfp2_mo3_cat =99 if res_nfp2_mo3 ==.
	order 	res_nfp2_mo3_cat ,after(res_nfp2_mo3)
	label values 	res_nfp2_mo3_cat lblabo
	label variable  res_nfp2_mo3_cat "NFS - Monocytes"

* pas de seuil pour res_nfp2_clhem

// GENERATION DU SCORE FIB-4
*https://soshepatites.org/depistage-de-la-fibrose-calculez-votre-fib-4/#:~:text=Si%20le%20FIB%2D4%20est,fibrose%20s%C3%A9v%C3%A8re%20ou%20une%20cirrhose.
*https://www.sealab.fr/node/356	
gen fib_4 = age * res_ot / (res_nfp2_pla2 * res_pt2^0.5)
	label variable fib_4 "Fibrosis-4 index"
	order fib_4, after(donnees_labo_complete)
	*	hist fib_4, width(0.1)
	
gen fib_4_cat = recode(fib_4,1.299999999,2.67, 10 )	
	order fib_4_cat, after(fib_4)
	recode fib_4_cat (1.299999999=1) (2.67=2) (10=3) (.=99)
	label variable fib_4_cat "Interpretation of Fibrosis-4 index (1.30 & 2.67)"
	label define lbfib4cat 1 "risque négligeable" 2 "Surveillance" 3 "Parcours de soin" 99"données manquantes"
	label values fib_4_cat lbfib4cat
	*	tab fib_4_cat vhb_conclusion2,row col	

gen fib_4_cat2 = recode(fib_4,1.4499999999,3.25, 10 )	
	order fib_4_cat2, after(fib_4_cat)
	recode fib_4_cat2 (1.4499999999=1) (3.25=2) (10=3) (.=99)
	label variable fib_4_cat2 "Interpretation of Fibrosis-4 index (1.45 & 3.25)"
	label define lbfib4cat2 1 "Cat 1 : 90% de chance de ne pas avoir de fibrose sévère" 2 "Cat 2 : Surveillance" 3 "Cat 3 : Fibrose sévère ou une cirrhose dans 65% des cas" 99"données manquantes"
	label values fib_4_cat2 lbfib4cat2
	*	tab fib_4_cat2 vhb_conclusion2,row col

	
***************************************************************	
**# CREATION DE VARIABLES ADDITIONNELLES #5
***************************************************************
// CLASSIFICATION OMS D'OBESITE AVEC DIFFERENTES CLASSES D'OBESITE (6 CLASSES)
gen 		obesity_classif_who = recode(bmi,18.4,24.9,29.9,34.9,39.9,40) if bmi !=.
	replace obesity_classif_who =99 if bmi ==.
	recode 	obesity_classif_who (18.4=1) (24.9=2) (29.9=3) (34.9=4) (39.9=5) (40=6)
	order 	obesity_classif_who, after(bmi)
	label variable obesity_classif_who "WHO Classification of BMI (with obesity classes)"
	label define lbobesityclassifwho 1 Underweight 2 Normal 3 Overweight 4 "Obesity Class I" 5 "Obesity Class II" 6 "Obesity Class III" 99 "Missing data"
	label values obesity_classif_who lbobesityclassifwho

// CLASSIFICATION OMS D'OBESITE SANS CLASSES D'OBESITE (4 CLASSES)
gen obesity_classif_who2 = obesity_classif_who
	recode obesity_classif_who2 (5=4) (6=4)
	label variable obesity_classif_who2 "WHO Classification of BMI"
	order obesity_classif_who2, after(obesity_classif_who)
	label define lbobesityclassifwho2 1 Underweight 2 Normal 3 Overweight 4 "Obesity" 99 "Missing data"
	label values obesity_classif_who2 lbobesityclassifwho2

// CLASSIFICATION D'IMC / OBESITE EN 3 CLASSES
gen obesity_classif_who3 = obesity_classif_who
	recode obesity_classif_who3 (2=1) (3=2) (4=3) (5=3) (6=3)
	label variable obesity_classif_who3 "BMI Classification"
	order obesity_classif_who3, after(obesity_classif_who2)
	label define lbobesityclassifwho3 1 "<25" 2 "[25-30[" 3 "≥30" 99 "Missing data"
	label values obesity_classif_who3 lbobesityclassifwho3
	
// VARIABLE OBESITE BOOLEENE SELON CRITERES OMS
gen obesity_who_bool=obesity_classif_who2
	recode obesity_who_bool (1=0) (2=0) (3=0) (4=1)
	label variable obesity_who_bool "OBESITY Y/N"
	order obesity_who_bool, after(obesity_classif_who2)
	label values obesity_who_bool lbbooleen
	
// CLASSIFICATION SPC D'OBESITE (Secretariat of the Pacific Community)
gen 		obesity_classif_spc = recode(bmi,21.9,26.9,31.9,32) if bmi !=.
	recode 	obesity_classif_spc (21.9=1) (26.9=2) (31.9=3) (32=4) 
	replace obesity_classif_spc =99 if bmi ==.
	order 	obesity_classif_spc, after(obesity_classif_who2)
	label variable obesity_classif_spc "SPC Classification of BMI"
	label define lbobesityclassifspc 1 Underweight 2 Normal 3 Overweight 4 Obesity
	label values obesity_classif_spc lbobesityclassifspc	
	
// OBESITE ABDOMINALE	
gen obesity_abdo_bool=99
	order 	obesity_abdo_bool, after(abdocm)
	replace obesity_abdo_bool=0 if abdocm !=.
	replace obesity_abdo_bool=1 if abdocm >=102 & gender ==1 & abdocm !=.
	replace obesity_abdo_bool=1 if abdocm >= 88 & gender ==2 & abdocm !=.
	label var obesity_abdo_bool "WHO Classification of abdo obesity"
	label values obesity_abdo_bool lbbooleen
	
// HYPERTENSION CLINIQUE (basée uniquement sur la tension artérielle) et HYPERTENSION (prenant en compte un traitement)
gen hypertension_clin =2
	label variable hypertension_clin "Hypertension artérielle clinique (calculated)"
	replace hypertension_clin = 1 if bp_systolic_mean >= 140 | bp_diastolic_mean >= 90
	replace hypertension_clin =99 if bp_systolic_mean==. | bp_systolic_mean ==888 | bp_diastolic_mean==.
	order hypertension_clin, after (bp_diastolic_mean)
	label values hypertension_clin lbyesno
	
gen 			 hypertension_bool =99
	label var 	 hypertension_bool "Hypertension artérielle Y/N"
	replace 	 hypertension_bool=0 if hypertension_clin==2 & drug_for_hypertension ==2
	replace 	 hypertension_bool=1 if hypertension_clin==1 | drug_for_hypertension ==1 | art_tension_medic_last_2weeks==1 /* inclure critère sur art_tension_medic_last_2weeks ?*/
	order 		 hypertension_bool, after (hypertension_clin)
	label values hypertension_bool lbbooleen

// DIABETE (prenant en compte un traitement)
gen 			 diabete = 99
label define lbdiabete 0 "Non-diabétique" 1 "Prédiabète" 2 "Diabète Type 2" 99 "Mising data"
	order 		 diabete, after(res_hba1g_cat)
	label var 	 diabete "CLASSIFICATION DIABETE"
	label values diabete lbdiabete
	replace 	 diabete=0 if res_hba1g<5.7
	replace 	 diabete=1 if res_hba1g >=5.7 & res_hba1g<6.5 
	replace 	 diabete=2 if (res_hba1g>=6.5 & res_hba1g!=.) | diabete_medic_last_2weeks=="Yes" /* pas utilisation de la variable  diabete_insulin (pas d'incohérence) */
	
	*transformation en variabel booléenne
gen 			 diabete_bool=diabete
	order 		 diabete_bool, after(diabete)
	label var 	 diabete_bool "DIABETE Y/N"
	recode 		 diabete_bool (1=0) (2=1)
	label values diabete_bool lbbooleen

// HYPERCHOLESTEROLEMIE	
gen 			 hypercholesterolemia_bool=99
	order 		 hypercholesterolemia_bool, after (res_ct_cat)
	label var 	 hypercholesterolemia_bool "Hypercholestérolemie (≥5.2 mmol/L))"
	label values hypercholesterolemia_bool lbbooleen
	replace 	 hypercholesterolemia_bool =0 if res_ct < 5.2	
	* seuil basé sur "The tide of dietary risks for noncommunicable diseases in Pacific Islands: an analysis of population NCD surveys" 
	* https://doi.org/10.1186/s12889-022-13808-
	replace 	 hypercholesterolemia_bool =1 if (res_ct >=5.2 & res_ct !=.) | high_cholest_medic_last_2weeks =="Yes" 

	
***************************************************************	
**# IMPORT PONDERATION ET CORRECTION POPULATION FINIE #6
***************************************************************	


gen tp_archipelago = ""				// variable avec le label de archipelago 
forvalues j =1 / `=_N' {
	local archi = archipelago[`j']
	quietly replace tp_archipelago = "`:label (archipelago) `archi''" if _n==`j'
}
rename archipelago archipelago_tempo // on réserve temporairement archipelago
rename tp_archipelago archipelago 

sort archipelago gender age_cat
merge m:1 archipelago gender age_cat using  "ponderation_draft.dta", keepusing(weighting) nogenerate
	label var weighting "Survey Design Weight"
	order weighting, after(age_cat2)

drop archipelago	
rename archipelago_tempo archipelago // on repositionne archipelago comme initialement
	
*tab island age_cat if gender==1,m
*tab island age_cat if gender==2,m		
* pas de femme de [45-69ans] à RImatara
gen tp_island = ""				// variable avec le label de island
forvalues j =1 / `=_N' {
	local ile = island[`j']
	quietly replace tp_island = "`:label (island) `ile''" if _n==`j'
}
rename island island_tempo // on réserve temporairement island
rename tp_island island 

sort island gender age_cat
merge m:1 island gender age_cat using "fpc_draft.dta", keepusing(fpc) nogenerate
drop if subjid ==""

drop island	
rename island_tempo island // on repositionne island comme initialement
	
compress
save "02_MATAEA_final.dta", replace
* export excel using "02_MATAEA_final.xlsx", firstrow(variables) replace