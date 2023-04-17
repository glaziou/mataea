*****************************************************************************
*   					Projet MATA'EA										*
* 			Cartographie de l'état de santé de la 							*
* 			population de la Polynésie française							*
*																			*
*					 		Fichier 03 I									*
*						 ANALYSES VHB										*
*																			*
*																			*
*																			*
* 	auteur : Vincent Mendiboure												*
* 	dernier update : 30 septembre 2022										*
*																			*
*****************************************************************************

*cd "Z:\donnees\Stata"
cd "R:\LIV\Projets-Programmes-Manips\MATAEA\Stata by Vincent\2022-10-14 Tous résultats de Vincent\bases\Stata"

use "02_MATAEA_final.dta", clear


**********************************************************************
**# 		I. INTRODUCTION - PREPARATIONS SPECIFIQUES 				**
**********************************************************************

// SIMPLIFICATION DE L'OUTCOME CONCLUSION VHB (REDUCTION DU NOMBRE DE CLASSE)
gen vhb_conclusion2 = vhb_conclusion
	recode vhb_conclusion2 (4=3) (77=99) (88=99)
	label define lbvhb2 0 "Absence de contact avec VHB" 1 "Infection en cours" 2 "Vacciné" 3 "Guéri" 99 "Donnée manquante"
	label values vhb_conclusion2 lbvhb2
	order vhb_conclusion2, after(vhb_conclusion)
	
// CREATION DE L'OUTCOME 'PORTAGE Ag HBs'
gen vhb_por_ag_hbs = vhb_conclusion2
	recode vhb_por_ag_hbs (2=0) (3=0)
	label values vhb_por_ag_hbs lbbooleen
	order vhb_por_ag_hbs, after(vhb_conclusion2)
	label variable vhb_por_ag_hbs "Portage de l'Ag HBs"
	
// CREATION DE L'OUTCOME 'INFECTION PASSEE OU PRESENTE'
gen vhb_inf	= vhb_conclusion2 
	recode vhb_inf (3=1) (2=0)
	label var vhb_inf "Infection (past or present)"
	label values vhb_inf lbbooleen
	order vhb_inf, after(vhb_por_ag_hbs)
	
// CREATION D'UNE VARIABLE DE SELECTION DE SOUS-ECHANTILLON
gen selection 		= 0	
	
**********************************************************************
**# 		II. DEFINITION DU PLAN D'ECHANTILLONAGE	 				**
**********************************************************************
egen strata_id = group(archipelago gender age_cat)
egen strata_id2 = group(island gender age_cat)

****OPTION 1******
// pas de référence à la stratification
svyset [pweight=weighting]

****OPTION 2******
// tirage ausort des participants après stratification par ile, genre et age
*svyset [pweight=weighting], strata(strata_id)
*svydes

****OPTION 3******
// idem avec correction de population finie
*svyset [pweight=weighting], strata(strata_id) fpc(fpc)	

****OPTION 4******
// 'tirage au sort' / sélection des 18 iles sur 75, puis tirage au sort après stratification 
// par genre et age
*	egen strata_id2 = group (gender age_cat)
*	gen N_island = 75 // 75 iles peuplées en Pf selon le recensement ISPF de 2017
*svyset island [pweight=weighting], fpc(N_island) || _n, strata(strata_id) fpc(fpc)

****OPTION 5******
// 'tirage au sort' / sélection des iles après stratification par 'strate géographique' (3),
// puis tirage au sort après stratification par genre et age
*	gen 	  N_island_geo_strate =.	
*	label var N_island_geo_strate "number of islands per geo strates"
*	replace   N_island_geo_strate =4   if geo_strate ==1 // 4 iles composent les IDV
*	replace   N_island_geo_strate =7   if geo_strate ==2 // 7 iles composent les ISLV
*	replace   N_island_geo_strate =64  if geo_strate ==3 // 64 iles composent les 'autres archipels' (Australes, Marquises et Tuamotu-Gambier)
*svyset island [pweight=weighting], strata(geo_strate) fpc(N_island_geo_strate) || _n, strata(strata_id) fpc(fpc) // il faut sans doute revoir le fpc par sex age_cat et geo_strat

	
**********************************************************************
**# 		III. DESCRIPTION	ECHANTILLON				 			**
**********************************************************************
**# 3.1 PREVALENCES DANS TOUT L'ECHANTILLON 
tab vhb_por_ag_hbs archipelago if vhb_por_ag_hbs <10 ,col chi2 expected exact


bysort archipelago: tab vhb_conclusion2 age_cat if vhb_conclusion2 <10, col chi2 expected exact
	tab vhb_conclusion2 age_cat if vhb_conclusion2 <10, col chi2 exp 
	
bysort archipelago: tab vhb_conclusion2 age_cat if gender==1 & vhb_conclusion2 <10, col
					tab vhb_conclusion2 age_cat if gender==1 & vhb_conclusion2 <10, col
bysort archipelago: tab vhb_conclusion2 age_cat if gender==2 & vhb_conclusion2 <10, col
					tab vhb_conclusion2 age_cat if gender==2 & vhb_conclusion2 <10, col

bysort archipelago: tab vhb_conclusion2 gender if vhb_conclusion2 <10,col exp chi2  exact
					tab vhb_conclusion2 gender if vhb_conclusion2 <10,col exp chi2

bysort archipelago: tab vhb_por_ag_hbs gender if vhb_por_ag_hbs <10 ,col chi2 expected exact
					tab vhb_por_ag_hbs gender if vhb_por_ag_hbs <10 ,col chi2 expected
					
					
***** PLUS DE 30 ANS :					
bysort archipelago: tab vhb_conclusion2 age_cat if vhb_conclusion2 <10 & (age_cat==2 | age_cat==3) ,col 
					tab vhb_conclusion2 age_cat if vhb_conclusion2 <10 & (age_cat==2 | age_cat==3) ,col 					
					
* difference % serologie H/F par archipel
bysort archipelago: tab vhb_conclusion2 gender if vhb_conclusion2 <10 & (age_cat==2 | age_cat==3) ,col chi2  exact
					tab vhb_conclusion2 gender if vhb_conclusion2 <10 & (age_cat==2 | age_cat==3) ,col chi2

* difference % infection H/F par archipel
bysort archipelago: tab vhb_por_ag_hbs gender if vhb_por_ag_hbs <10 & (age_cat==2 | age_cat==3) ,col chi2 expected exact
					tab vhb_por_ag_hbs gender if vhb_por_ag_hbs <10 & (age_cat==2 | age_cat==3) ,col chi2 expected
	*pour chaque archipel : pas de différence significative

*** VARIABLES EXPLICATIVES
gen variableA =""
gen modaliteA =""
*gen vhb_conclusion2_0 =.
gen vhb_conclusionA_1 =.
gen vhb_conclusionA_2 =.
gen vhb_conclusionA_3 =.
gen vhb_conclusionA_4 =.
gen vhb_conclusionA_total=.
browse  variableA modaliteA vhb_conclusionA_1 vhb_conclusionA_2 vhb_conclusionA_3 vhb_conclusionA_4 vhb_conclusionA_total 

local ligne 1
local j  	1

foreach var in max_school2 civil_state3 pro_act_last_year2 sex2 condom_during_first_sex2 condom_during_occasional_sex2 ist_mst2 health_status2 {
	display "`var'"	
	tab `var' vhb_conclusion2 if vhb_conclusion2 <10, row chi2 exp 	matcell(tableau)
	levelsof `var', local(mod)
		local nb_mod = r(r)
	foreach modj of local mod  {   
		replace variableA ="`var'"	 if _n==`ligne'
		replace modaliteA ="`modj'"  if _n==`ligne'

		forvalues i=1/4  {
			replace vhb_conclusionA_`i' = tableau[`j',`i'] if _n==`ligne'
		}
		local j = `j' +1
		local ligne=`ligne'+1
	}
	local j 1
}	

replace vhb_conclusionA_total =  vhb_conclusionA_1 + vhb_conclusionA_2 + vhb_conclusionA_3 + vhb_conclusionA_4
	
		
**# 3.2 FOCUS >30 ANS ET 2 ARCHIPELS					
bysort archipelago: tab vhb_conclusion2 max_school2 if vhb_conclusion2 <10 & (age_cat==2 | age_cat==3) & (archipelago==5 | archipelago==4),col chi2
					tab vhb_conclusion2 max_school2 if vhb_conclusion2 <10 & (age_cat==2 | age_cat==3) & (archipelago==5 | archipelago==4),col chi2

bysort archipelago: tab vhb_conclusion2 civil_state3 if vhb_conclusion2 <10 & (age_cat==2 | age_cat==3) & (archipelago==5 | archipelago==4),col chi2
					tab vhb_conclusion2 civil_state3 if vhb_conclusion2 <10 & (age_cat==2 | age_cat==3) & (archipelago==5 | archipelago==4),col chi2

bysort archipelago: tab vhb_conclusion2 sex if vhb_conclusion2 <10 & (age_cat==2 | age_cat==3) & (archipelago==5 | archipelago==4),col chi2
					tab vhb_conclusion2 sex if vhb_conclusion2 <10 & (age_cat==2 | age_cat==3) & (archipelago==5 | archipelago==4),col chi2

bysort archipelago: tab vhb_conclusion2 condom_during_first_sex if vhb_conclusion2 <10 & (age_cat==2 | age_cat==3) & (archipelago==4 | archipelago==5),col chi2
					tab vhb_conclusion2 condom_during_first_sex if vhb_conclusion2 <10 & (age_cat==2 | age_cat==3) & (archipelago==4 | archipelago==5),col chi2

bysort archipelago: tab vhb_conclusion2 condom_during_occasional_sex if vhb_conclusion2 <10 & (age_cat==2 | age_cat==3) & (archipelago==4 | archipelago==5),col chi2
					tab vhb_conclusion2 condom_during_occasional_sex if vhb_conclusion2 <10 & (age_cat==2 | age_cat==3) & (archipelago==4 | archipelago==5),col chi2
					
bysort archipelago: tab vhb_conclusion2 ist_mst if vhb_conclusion2 <10 & (age_cat==2 | age_cat==3) & (archipelago==4 | archipelago==5),col chi2
					tab vhb_conclusion2 ist_mst if vhb_conclusion2 <10 & (age_cat==2 | age_cat==3) & (archipelago==4 | archipelago==5),col chi2
				
bysort archipelago: tab vhb_conclusion2 health_status if vhb_conclusion2 <10 & (age_cat==2 | age_cat==3) & (archipelago==4 | archipelago==5),col chi2
					tab vhb_conclusion2 health_status if vhb_conclusion2 <10 & (age_cat==2 | age_cat==3) & (archipelago==4 | archipelago==5),col chi2
				
		
**********************************************************************
**# 		IV. INFERENCE POPULATION SOURCE 		 				**
**********************************************************************

gen selection_svy =0
	label variable selection_svy "Selection du sous-ensemble de la population source"

// CASELOAD PAR ARCHIPEL 
	replace selection_svy = 1 if vhb_conclusion2 <10 
svy, subpop(selection_svy): tab  archipelago vhb_por_ag_hbs if selection_svy ==1, ci pearson count
		
* INFERENCE SUR TOUTE LA POPULATION (18-69 ans)
	replace selection_svy =0
	replace selection_svy = 1 if vhb_conclusion2 <10 
svy, subpop(selection_svy): tab vhb_conclusion2 , ci
svy, subpop(selection_svy): tab vhb_inf , ci

* INFERENCE PAR ARCHIPEL
	replace selection_svy =0
levelsof archipelago, local(modalites)
*		local nb_mod = r(r)
foreach j of local modalites  { 
	quietly replace selection_svy =1 if vhb_conclusion2 <10 & archipelago==`j'
	dis ""
	dis ""
	display in red "Archipel : `: label lbarchipelago `j''"
	svy, subpop(selection_svy): tab vhb_conclusion2 gender if selection_svy ==1  , ci pearson
	svy, subpop(selection_svy): tab vhb_por_ag_hbs gender if selection_svy ==1, ci pearson 
	svy, subpop(selection_svy): tab vhb_inf gender if selection_svy ==1  , ci pearson
	quietly replace selection_svy =0
	}
	
* INFERENCE PAR GENRE
	replace selection_svy =0
levelsof gender, local(modalites)
foreach j of local modalites  { 
	quietly replace selection_svy =1 if vhb_conclusion2 <10 & gender ==`j'
	display ""
	display "Genre : `: label lbgender `j''"
	svy, subpop(selection_svy): tab vhb_conclusion2  if selection_svy ==1, ci
	svy, subpop(selection_svy): tab vhb_inf  if selection_svy ==1, ci
	quietly replace selection_svy =0
	}

* INFERENCE PAR AGE
	replace selection_svy =0
levelsof age_cat, local(modalites)
foreach j of local modalites  { 
	quietly replace selection_svy =1 if vhb_conclusion2 <10 & age_cat ==`j'
	display ""
	display "Age: `: label lbagecat `j''"
	svy, subpop(selection_svy): tab vhb_conclusion2 , ci
	svy, subpop(selection_svy): tab vhb_inf , ci
	quietly replace selection_svy =0
	}
	
* INFERENCE PAR ILE CHEZ LES [30-69 ans]
	replace selection_svy =0
levelsof island if archipelago==4, local(modalites)
*		local nb_mod = r(r)
foreach j of local modalites  { 
	quietly replace selection_svy =1 if vhb_conclusion2 <10 & island ==`j' & (age_cat==2 | age_cat==3) & archipelago==4
	display""
	display in red "*************ILE SUIVANTE*******************"	
	display in red "Ile : `: label lbisland `j'', ages [30-69 ans]"
	svy, subpop(selection_svy): tab vhb_conclusion2  if vhb_conclusion2 <10 , ci
	quietly replace selection_svy =0
	}

tab vhb_por_ag_hbs island if archipelago ==4 & vhb_por_ag_hbs <10 & (age_cat==2 | age_cat==3), chi2 expected col exact
* Pas de différence significative de la prévalence de portage entre les îles des marquises (p=0.209)

* INFERENCE PAR ARCHIPEL CHEZ LES [30-69 ans]
	replace selection_svy =0
	replace selection_svy =1 if vhb_conclusion2 <10 & (age_cat==2 | age_cat==3)
	svy, subpop(selection_svy): tab vhb_conclusion2  if selection_svy ==1  , ci
	
	replace selection_svy =0
levelsof archipelago, local(modalites)
foreach j of local modalites  { 
	quietly replace selection_svy =1 if vhb_conclusion2 <10 & archipelago==`j' & (age_cat==2 | age_cat==3)
	display""
	display in red "*************ARCHIPEL SUIVANT*******************"	
	display in red "Archipel : `: label lbarchipelago `j'', ages [30-69 ans]"
	svy, subpop(selection_svy): tab vhb_conclusion2  if selection_svy ==1, ci
	quietly replace selection_svy =0
	}

	
**********************************************************************
**# 	V. ASSOCIATION & FACTEURS DE RISQUES DANS L'ECHANTILLON		**
**********************************************************************
**# 5.1. Modèle logistique

gen tp_variableB 	 =""
gen tp_modaliteB1 	 =""
gen tp_modaliteB2	 =""
gen vhb_por_ag_hbs_0 =.
gen vhb_por_ag_hbs_1 =.
gen total_por_ag_hbs =.
gen orB				 =.
gen lorB			 =.
gen uorB			 =.
gen check_orB		 =""
gen p_valueB		 =.
gen methodeB 		 =""

char archipelago[omit] "1"
char gender[omit] "2"
char age_cat[omit] "2"
char max_school2 [omit] "3"
char birth_location[omit] "987"
char civil_state4 [omit] "2"
char age_first_sex_cat [omit] "2"
char nhouse_tot_classif3[omit] "2"
char house_type[omit] "1"
char house_clean_water[omit] "1"
char house_clim[omit] "1"
char health_status2[omit] "2"
char res_ct_cat [omit] "0"
char res_tg_cat [omit] "0"
char res_hdl_hdl_cat [omit] "0"
char res_hdl_rcthd_cat [omit] "0"
char res_ldlc_ldlc_cat [omit] "0"
char res_ldlc_rhdld_cat [omit] "0"
char res_nfp2_pla2_cat [omit] "0"
char res_pt2_cat [omit] "0"
char res_ot_cat [omit] "0"
char res_bilt_cat [omit] "0"
char res_ggt_cat[omit] "0"

// pour refaire tourner sans avoir à supprimer les variables
replace tp_variableB 	 =""
replace tp_modaliteB1 	 =""
replace tp_modaliteB2	 =""
replace vhb_por_ag_hbs_0 =.
replace vhb_por_ag_hbs_1 =.
replace total_por_ag_hbs =.
replace orB				 =.
replace lorB			 =.
replace uorB			 =.
replace check_orB	 	 =""
replace p_valueB		 =.
replace methodeB 		 =""
replace selection 		= 0

// INDIQUER ICI SUR QUELLE SELECTION TRAVAILLER
//	replace selection = 1 if vhb_por_ag_hbs <10 & (age_cat==2 | age_cat==3) & (archipelago==4 | archipelago==5)
	replace selection = 1 if vhb_por_ag_hbs <10
browse tp_variableB tp_modaliteB1 tp_modaliteB2 vhb_por_ag_hbs_0 vhb_por_ag_hbs_1 total_por_ag_hbs orB lorB uorB check_orB p_valueB methodeB

local ligne	2							// la variable 'ligne' est la variable compteur du numéro de ligne qui va étre éditée
replace vhb_por_ag_hbs_0 = 0 if _n==1	// en tête du tableau avec les modalités (0=No et 1=Yes) de l'outcome vhb_por_ag_hbs (Portage de l'Ag HBs)
replace vhb_por_ag_hbs_1 = 1 if _n==1	

foreach var in archipelago gender age_cat max_school2 birth_location civil_state4 socio_cultural2 pro_act_last_year2 nhouse_tot_classif3 alcool_12m_bool alcool_30d_bool alcool_use smoking_everyday_bool ntabaco_per_day_equ_class paka_last_year_bool paka_weekly_bool house_type house_clim house_clean_water health_status2 chronic_ald sex2 age_first_sex_cat condom_during_first_sex2 condom_during_occasional_sex2 ist_mst2 diabete_bool obesity_who_bool res_ct_cat res_tg_cat res_hdl_hdl_cat res_hdl_rcthd_cat res_ldlc_ldlc_cat res_ldlc_rhdld_cat res_nfp2_pla2_cat res_pt2_cat res_ot_cat res_bilt_cat res_ggt_cat fib_4_cat 	{
	local num_modalite 1 // la variable 'num_modalite' est la variable compteur spécifique à la variable explicative qui compte le numéro de la modalité
	display ""
	display "*****************************"
	display "Association du Portage Ag HBs avec `var'"	

	/* A N'ACTIVER QUE POUR LE CALCUL SANS LES DONNEES MANQUANTES
	if substr("`:type `var''" , 1, 3) != "str" {		
			tab `var' vhb_por_ag_hbs if selection ==1 & `var' !=99, row chi2 exp matcell(tableau)
			//	matrix list tableau
	
			levelsof `var' if selection ==1 & `var' !=99, local(mod)
			local nb_mod = r(r)
			//	display `mod'
	}

	if substr("`:type `var''" , 1, 3) == "str" {		
			tab `var' vhb_por_ag_hbs if selection ==1 & `var' !="NA" & `var' !="_Missing data", row chi2 exp matcell(tableau)
			//	matrix list tableau
	
			levelsof `var' if selection ==1 & `var' !="NA" & `var' !="_Missing data", local(mod)
			local nb_mod = r(r)
			//	display `mod'
	}	
	*/	

	tab `var' vhb_por_ag_hbs if selection ==1, row chi2 exp matcell(tableau)
	levelsof `var' if selection ==1 , local(mod)
	local nb_mod = r(r)
	
	// Y a t'il un effectif nul ? un effectif nul conduirait à utiliser 'firthlogit' à la place de 'logistic'
	// Calcul du produit des effectifs ; une seule valeure nulle conduira à un produit nul
			local produit 1
			forvalues i=1/`nb_mod' {			// calcul du produit des effectifs par itération
				local produit = `produit' * tableau[`i',2]
			}
		
	if 	`produit' ==0 {							// si un seul effectif nul, usage de firthlogit
		display "Au moins un effectif nul : Usage de FIRTHLOGIT"
		xi: firthlogit vhb_por_ag_hbs i.`var' if selection ==1, or
		replace p_valueB =e(p) if _n==`ligne'
		replace methodeB = "FIRTHLOGIT" if _n==`ligne'
		matrix or =r(table)
	}
		
	if 	`produit' !=0 {							// si pas d'effectif nul, usage de logistic
		display "Pas d'effectif nul : Usage de LOGISTIC classique"
		xi: logistic vhb_por_ag_hbs i.`var' if selection ==1
		replace p_valueB =e(p) if _n==`ligne'
		replace methodeB = "LOGISTIC" if _n==`ligne'
		matrix or =r(table)
	}

	local noms_dummy_var_or : colnames or // Stockage du nom des dummy variables de la regression logistique dans `noms_dummy_var_or'
	display "`noms_dummy_var_or'"
	
	replace tp_variableB ="`: var label `var''"	 if _n==`ligne'  //ligne d'en-tête
	local ligne=`ligne'+1

	local count =1		// Compteur modalité de la variable
	foreach modj of local mod  {   
		replace tp_variableB ="`: var label `var''"	 		if _n==`ligne'
		replace tp_modaliteB1 ="`:label (`var') `modj''"   	if _n==`ligne'
		replace tp_modaliteB2 ="`modj'" 					if _n==`ligne'
		
		forvalues i=0/1  {
			replace vhb_por_ag_hbs_`i' = tableau[`num_modalite',`i'+1] if _n==`ligne'
			replace total_por_ag_hbs = vhb_por_ag_hbs_0 + vhb_por_ag_hbs_1 if _n==`ligne'
			}
			
*		if "`modj'" =="``var'[omit]'" {
*		display "`modj' is omitted"
*		}

		local count =1
		foreach dummy_var of local noms_dummy_var_or { // boucle qui renvoie dans dummy_var la nième (COUNTième) modalité des dummy variables  
			if `count'== `num_modalite' {
			
				if "`dummy_var'" == "_cons" {
					continue, break
				}
				replace orB = el("or",1,`num_modalite') 			if _n==`ligne'
				replace lorB = el("or",5,`num_modalite') 			if _n==`ligne'
				replace uorB = el("or",6,`num_modalite') 			if _n==`ligne'
				replace check_orB = "`dummy_var'" 					if _n==`ligne'
				continue, break
			}
		local count = `count'+1
		}

	*local fin_mod =substr("`dummy_var'",-2,.)  // pas utilise finalement compliqué de matcher les '99' / données manquantes
	
	local num_modalite = `num_modalite' +1
	local ligne=`ligne'+1
	
	}
	replace tp_variableB ="`: var label `var''"	 if _n==`ligne'		// dernière ligne de la variable => "TOTAL"
	replace tp_modaliteB1 ="Total"   if _n==`ligne'

	forvalues i=1/ `nb_mod' {										// calcul du total des effectifs par modalité de l'outcome par itération
		replace vhb_por_ag_hbs_0 = 0 if `i'==1 & _n==`ligne'
		replace vhb_por_ag_hbs_1 = 0 if `i'==1 & _n==`ligne'		

		replace vhb_por_ag_hbs_0 = vhb_por_ag_hbs_0 + tableau[`i',1]  if _n==`ligne'
		replace vhb_por_ag_hbs_1 = vhb_por_ag_hbs_1 + tableau[`i',2]  if _n==`ligne'
	}
	
	replace total_por_ag_hbs = vhb_por_ag_hbs_0 + vhb_por_ag_hbs_1  if _n==`ligne'

	local ligne=`ligne'+2				// 1 ligne vide	
}


tab npregnancies_cat vhb_por_ag_hbs if selection ==1 & gender ==2 & npregnancies_cat !=99, row chi2 exp exact m
	xi: logistic vhb_por_ag_hbs i.npregnancies_cat if selection ==1 & gender ==2 & npregnancies_cat !=99

tab npregnancies_cat vhb_por_ag_hbs if selection ==1 & gender ==2, row chi2 exp exact m
	xi: firthlogit vhb_por_ag_hbs i.npregnancies_cat if selection ==1 & gender ==2, or

**# 5.2. Modèle de Poisson
xi: poisson vhb_por_ag_hbs i.archipelago if selection ==1 , irr
xi: poisson vhb_por_ag_hbs i.gender if selection ==1 , irr
xi: poisson vhb_por_ag_hbs i.age_cat if selection ==1 , irr	
xi: poisson vhb_por_ag_hbs i.birth_location if selection ==1 , irr	
xi: poisson vhb_por_ag_hbs i.socio_cultural2 if selection ==1 , irr	
xi: poisson vhb_por_ag_hbs i.nhouse_tot_classif3 if selection ==1 , irr	

xi: svy: poisson vhb_por_ag_hbs i.archipelago if selection ==1 , irr
xi: svy:  poisson vhb_por_ag_hbs i.gender if selection ==1 , irr
xi:  svy: poisson vhb_por_ag_hbs i.age_cat if selection ==1 , irr	




**********************************************************************
**# 	VI.  CARACTERISTIQUES SOCIO-DEMOGRAPHIQUE EPIDEMIOLOGIQUES, **
**				COMORBIDITES DES PERSONNES POSITIVES AgHBs 			**
**						DANS LA POPULATION SOURCE 					**
**********************************************************************
**# 6.1. UNIVARIE EN POPULATION
// besoin d'installer le composant suivant :
// ssc inst estout
gen selection_3		 =0
gen selection_3f 	 =0

gen tp_variable3 	 =""
gen tp_modalite31 	 =""
gen tp_modalite32 	 =""
gen vhb_por_ag_hbs3_0 =.
gen vhb_por_ag_hbs3_1 =.
gen total_por_ag_hbs3 =.
gen p_value3		 =.


char archipelago[omit] "1"
char gender[omit] "2"
char age_cat[omit] "2"
char max_school2 [omit] "3"
char civil_state4 [omit] "2"
char age_first_sex_cat [omit] "2"
char nhouse_tot_classif3[omit] "2"
char house_clean_water[omit] "1"
char house_clim[omit] "1"
char health_status2[omit] "2"
char res_ct_cat [omit] "0"
char res_tg_cat [omit] "0"
char res_hdl_hdl_cat [omit] "0"
char res_hdl_rcthd_cat [omit] "0"
char res_ldlc_ldlc_cat [omit] "0"
char res_ldlc_rhdld_cat [omit] "0"
char res_nfp2_pla2_cat [omit] "0"
char res_pt2_cat [omit] "0"
char res_ot_cat [omit] "0"
char res_bilt_cat [omit] "0"
char res_ggt_cat[omit] "0"

local avec_donnee_manquante 0	// rentrer 0 pour retirer les données manquantes
// reset des varaibles pour refaire tourner le calcul
replace tp_variable3 	 =""
replace tp_modalite31 	 =""
replace tp_modalite32 	 =""
replace vhb_por_ag_hbs3_0 =.
replace vhb_por_ag_hbs3_1 =.
replace total_por_ag_hbs3 =.
replace p_value3		 =.

// INDIQUER ICI SUR QUELLE SELECTION TRAVAILLER***********************************************
	replace selection =0
	*	replace selection = 1 if vhb_por_ag_hbs <10 & (age_cat==2 | age_cat==3) & (archipelago==4 | archipelago==5)
	replace selection = 1 if vhb_por_ag_hbs <10
	browse tp_variable3 tp_modalite31 tp_modalite32 vhb_por_ag_hbs3_0 vhb_por_ag_hbs3_1 total_por_ag_hbs3 p_value3 

local ligne	2							// la variable 'ligne' est la variable compteur du numéro de ligne qui va étre éditée
replace vhb_por_ag_hbs3_0 = 0 if _n==1	// en tête du tableau avec les modalités (0=No et 1=Yes) de l'outcome vhb_por_ag_hbs (Portage de l'Ag HBs)
replace vhb_por_ag_hbs3_1 = 1 if _n==1	

foreach var in archipelago gender age_cat max_school2 birth_location civil_state4 socio_cultural2 pro_act_last_year2 nhouse_tot_classif3 alcool_12m_bool alcool_30d_bool alcool_use alcool_medical_stop smoking_everyday_bool ntabaco_per_day_equ_class paka_last_year_bool paka_weekly_bool house_type house_clim house_clean_water health_status2 chronic_ald sex2 age_first_sex_cat condom_during_first_sex2 condom_during_occasional_sex2 ist_mst2 diabete_bool obesity_who_bool res_ct_cat res_tg_cat res_hdl_hdl_cat res_hdl_rcthd_cat res_ldlc_ldlc_cat res_ldlc_rhdld_cat res_nfp2_pla2_cat res_pt2_cat res_ot_cat res_bilt_cat res_ggt_cat fib_4_cat  	{
	display ""
	display "*****************************"
	display "Proportion des modalités de `var' en population générale par statut sérologique (et p-value de Pearson)"	
	replace selection_3 =0
	
	if substr("`:type `var''" , 1, 3) != "str" {  // si la variable est numérique (n'est pas format string) 
		replace selection_3 =1 if `avec_donnee_manquante' ==0 & selection ==1 &  `var' !=99  	
		replace selection_3 =1 if `avec_donnee_manquante' ==1 & selection ==1 
	}

	if substr("`:type `var''" , 1, 3) == "str" {  // si la variable est  format string 
		replace selection_3 =1 if `avec_donnee_manquante' ==0 & selection ==1 &  `var' !="NA" & `var' !="_Missing data" 
		replace selection_3 =1 if `avec_donnee_manquante' ==1 & selection ==1 
	}
	
	estpost svy, subpop(selection_3): tabulate `var' vhb_por_ag_hbs if selection_3 ==1, col pearson // résultats p-value dans e(b)
		replace p_value3 =e(p_Pear) if _n==`ligne'											// enregistrement de la p-value Chi2 Pearson
		matrix vecteur=e(b)																	// création du vecteur avec toutes les valeurs à stocker
		levelsof `var' if selection_3 ==1, local(mod)										// création vecteur avec l'ensemble des modalités
		local nb_mod = r(r)																	// nombre de modalités
		replace tp_modalite31 = "n=`e(N)'" 		 if _n==`ligne'
	replace tp_variable3 ="`: var label `var''"	 if _n==`ligne'  							//ligne d'en-tête
	local ligne=`ligne'+1
	
	local num_modalite 1 																	// création du compteur de la modalité				
	foreach modj of local mod  {   
		* traitement de la modalité modj, num_modalite ème modalité de la liste mod 
		replace tp_variable3 ="`: var label `var''"	 		if _n==`ligne'
		replace tp_modalite31 ="`:label (`var') `modj''"   	if _n==`ligne'
		replace tp_modalite32 ="`modj'" 					if _n==`ligne'
		
		forvalues i=0/1  {
			replace vhb_por_ag_hbs3_`i' = vecteur[1,`i'*(`nb_mod'+1)+`num_modalite'] if _n==`ligne'
			}
		replace total_por_ag_hbs3 = vecteur[1,2*(`nb_mod'+1)+`num_modalite'] if _n==`ligne'		

		local num_modalite = `num_modalite' +1
		local ligne=`ligne'+1
	}

	// dernière ligne de la variable => "TOTAL"
	replace tp_variable3 ="`: var label `var''"	 if _n==`ligne'		
	replace tp_modalite31 ="Total"   			 if _n==`ligne'
	forvalues i=0/1 {										
		replace vhb_por_ag_hbs3_`i' = vecteur[1,`i'*(`nb_mod'+1)+`nb_mod'+1] if _n==`ligne'
	}
	replace total_por_ag_hbs3 = vecteur[1,2*(`nb_mod'+1)+`nb_mod'+1] if _n==`ligne'

	local ligne=`ligne'+2				// 1 ligne vide, passage à la varibale suivante
}
		
		replace selection_3f =0
		replace selection_3f =selection_3
		replace selection_3f =0 if gender ==1
svy, subpop(selection_3f): tabulate npregnancies_cat vhb_por_ag_hbs if selection_3f ==1, col pearson 


**# 6.2. ESSAI EXPLICATION DIFF P-VALUE HEALTH STATUS ECHANTILLON VS POPULATION
/* DIFFERENCE HEALTH STATUS ECHANTILLON VERSUS POPULATION
gen selec=0
gen a  =""
gen g  =""
gen ac =""
gen res_1  =.
gen res_2  =.
gen res_3  =.
gen res_4  =.
gen res_5  =.
gen res_6  =.
gen res_7  =.
gen res_8  =.
gen res_9  =.
gen res_10  =.
gen res_11  =.
gen res_12  =.


browse a g ac res_1 res_2 res_3 res_4 res_5 res_6 res_7 res_8 res_9 res_10 res_11 res_12  
replace res_1  =.
replace res_2  =.
replace res_3  =.
replace res_4  =.
replace res_5  =.
replace res_6  =.
replace res_7  =.
replace res_8  =.
replace res_9  =.
replace res_10  =.
replace res_11  =.
replace res_12  =.
replace selec=1 if vhb_por_ag_hbs !=99
local ligne 2
	
levelsof archipelago if selec ==1, local(mod_a)
local nb_a = r(r)
foreach moda of local mod_a {
display "balise 1"
	levelsof gender if selec ==1 & archipelago=="`moda'", local(mod_g)	
		local nb_g = r(r)					
	foreach modg of local mod_g {
display "balise 2"		
		levelsof age_cat if selec ==1 & archipelago=="`moda'" & gender ==`modg', local(mod_ac)	
		local nb_ac = r(r)	
		foreach modac of local mod_ac {
display "balise 3"
			replace a = "`moda'" 					if _n==`ligne'
			replace g ="`:label lbgender `modg''" 	if _n==`ligne'
			//  "`:label (`var') `modj''"
			replace ac ="`:label lbagecat `modac''"	if _n==`ligne'
			
			estpost	tab health_status2 vhb_por_ag_hbs if selec ==1 & archipelago=="`moda'" & gender ==`modg' & age_cat ==`modac'
			matrix vecteur=e(b)
			
			tab vhb_por_ag_hbs if selec ==1 & archipelago=="`moda'" & gender ==`modg' & age_cat ==`modac'
			local mod_por = r(r)

			
			replace res_1  =vecteur[1,1] 	if _n==`ligne'
			replace res_2  =vecteur[1,2]	if _n==`ligne'
			replace res_3  =vecteur[1,3]	if _n==`ligne'
			replace res_4  =vecteur[1,4]	if _n==`ligne'
			
			if `mod_por'==2 {
				replace res_5  =vecteur[1,5]	if _n==`ligne'
				replace res_6  =vecteur[1,6]	if _n==`ligne'
				replace res_7  =vecteur[1,7]	if _n==`ligne'
				replace res_8  =vecteur[1,8]	if _n==`ligne'
				replace res_9  =vecteur[1,9]	if _n==`ligne'
				replace res_10  =vecteur[1,10]	if _n==`ligne'
				replace res_11  =vecteur[1,11]	if _n==`ligne'
				replace res_12  =vecteur[1,12]	if _n==`ligne'
			}  
			
			if `mod_por'==1 {
				replace res_5  =0				if _n==`ligne'
				replace res_6  =0				if _n==`ligne'
				replace res_7  =0				if _n==`ligne'
				replace res_8  =0				if _n==`ligne'
				replace res_9   =vecteur[1,5]	if _n==`ligne'
				replace res_10  =vecteur[1,6]	if _n==`ligne'
				replace res_11  =vecteur[1,7]	if _n==`ligne'
				replace res_12  =vecteur[1,8]	if _n==`ligne'
			}
			
			local ligne=`ligne'+1
		}
	}
}

bysort archipelago gender age_cat : tab health_status2 vhb_por_ag_hbs if selec ==1 

tab health_status2 vhb_por_ag_hbs if selec ==1,chi2
tabi 246 1007 548 \ 3 15 15 , chi2
*/

**# 6.3. ANALYSE MULTIVARIEE POPULATION
replace selection =0
replace selection = 1 if vhb_por_ag_hbs <10 & (age_cat==2 | age_cat==3) & (archipelago==4 | archipelago==5)

char archipelago[omit] "1"
char gender[omit] "2"
char age_cat[omit] "2"
char max_school2 [omit] "3"
char civil_state4 [omit] "2"
char age_first_sex_cat [omit] "2"
char nhouse_tot_classif3[omit] "2"
char house_clean_water[omit] "1"
char house_clim[omit] "1"
char health_status2[omit] "2"
char res_ct_cat [omit] "0"
char res_tg_cat [omit] "0"
char res_hdl_hdl_cat [omit] "0"
char res_hdl_rcthd_cat [omit] "0"
char res_ldlc_ldlc_cat [omit] "0"
char res_ldlc_rhdld_cat [omit] "0"
char res_nfp2_pla2_cat [omit] "0"
char res_pt2_cat [omit] "0"
char res_ot_cat [omit] "0"
char res_bilt_cat [omit] "0"
char res_ggt_cat[omit] "0"

xi : logistic vhb_por_ag_hbs i.archipelago i.age_cat if selection ==1 [pweight=weighting]

xi: svy: logistic vhb_por_ag_hbs i.archipelago i.age_cat if selection ==1 
xi: svy, subpop(selection) : logistic vhb_por_ag_hbs i.archipelago i.age_cat 

CONTINUER ICI ANALYSE MULTIVARIEE SUR >30 ANS ET AUSTRALES OU MARQUISES
archipelago gender age_cat max_school2 birth_location civil_state4 socio_cultural2 pro_act_last_year2 nhouse_tot_classif3 alcool_12m_bool alcool_30d_bool alcool_use alcool_medical_stop smoking_everyday_bool ntabaco_per_day_equ_class paka_last_year_bool paka_weekly_bool house_type house_clim house_clean_water health_status2 chronic_ald sex2 age_first_sex_cat condom_during_first_sex2 condom_during_occasional_sex2 ist_mst2 diabete_bool obesity_who_bool res_ct_cat res_tg_cat res_hdl_hdl_cat res_hdl_rcthd_cat res_ldlc_ldlc_cat res_ldlc_rhdld_cat res_nfp2_pla2_cat res_pt2_cat res_ot_cat res_bilt_cat res_ggt_cat fib_4_cat 



*************************************
* TEST
/*
replace selection =0
replace selection = 1 if vhb_por_ag_hbs <10 

xi : exlogistic vhb_por_ag_hbs i.archipelago i.age_cat if selection ==1 , memory(2000m)

xi: svy, subpop(selection) : logistic vhb_por_ag_hbs i.archipelago i.age_cat 

xi: poisson vhb_por_ag_hbs i.archipelago i.age_cat if selection ==1,irr

tab archipelago vhb_por_ag_hbs if selection ==1
xi: poisson vhb_por_ag_hbs i.archipelago if selection ==1,irr
xi: svy: poisson vhb_por_ag_hbs i.archipelago if selection ==1,irr
*/


**********************************************************************
**# 	VII. CARACTERISTIQUES SOCIO-DEMOGRAPHIQUE EPIDEMIOLOGIQUES, **
**		COMORBIDITES DES PERSONNES INFECTEES (PRESENT OU PASSEES)	**
**						DANS LA POPULATION SOURCE 					**
**********************************************************************
**# 7.1. TESTS STATISTIQUES 
gen selection_4		 =0
gen selection_4f 	 =0
gen tp_variable4 	 =""
gen tp_modalite41 	 =""
gen tp_modalite42 	 =""
gen vhb_inf4_0 =.
gen vhb_inf4_1 =.
gen total_por_ag_hbs4 =.
gen p_value4		 =.



local avec_donnee_manquante 1	// rentrer 0 pour retirer les données manquantes
// reset des varaibles pour refaire tourner le calcul
replace tp_variable4 	 =""
replace tp_modalite41 	 =""
replace tp_modalite42 	 =""
replace vhb_inf4_0 =.
replace vhb_inf4_1 =.
replace total_por_ag_hbs4 =.
replace p_value4		 =.

// INDIQUER ICI SUR QUELLE SELECTION TRAVAILLER***********************************************
	replace selection =0
	*	replace selection = 1 if vhb_inf <10 & (age_cat==2 | age_cat==3) & (archipelago==4 | archipelago==5)
	replace selection = 1 if vhb_inf <10
	browse tp_variable4 tp_modalite41 tp_modalite42 vhb_inf4_0 vhb_inf4_1 total_por_ag_hbs4 p_value4 

local ligne	2							// la variable 'ligne' est la variable compteur du numéro de ligne qui va étre éditée
replace vhb_inf4_0 = 0 if _n==1	// en tête du tableau avec les modalités (0=No et 1=Yes) de l'outcome vhb_inf 
replace vhb_inf4_1 = 1 if _n==1	

foreach var in archipelago gender age_cat max_school2 birth_location civil_state4 socio_cultural2 pro_act_last_year2 nhouse_tot_classif3 alcool_12m_bool alcool_30d_bool alcool_use alcool_medical_stop smoking_everyday_bool ntabaco_per_day_equ_class paka_last_year_bool paka_weekly_bool house_type house_clim house_clean_water health_status2 chronic_ald sex2 age_first_sex_cat condom_during_first_sex2 condom_during_occasional_sex2 ist_mst2 diabete_bool obesity_who_bool res_ct_cat res_tg_cat res_hdl_hdl_cat res_hdl_rcthd_cat res_ldlc_ldlc_cat res_ldlc_rhdld_cat res_nfp2_pla2_cat res_pt2_cat res_ot_cat res_bilt_cat res_ggt_cat fib_4_cat  	{
	display ""
	display "*****************************"
	display "Proportion des modalités de `var' en population générale par statut sérologique (et p-value de Pearson)"	
	replace selection_4 =0
	
	if substr("`:type `var''" , 1, 3) != "str" {  // si la variable est numérique (n'est pas format string) 
		replace selection_4 =1 if `avec_donnee_manquante' ==0 & selection ==1 &  `var' !=99  	
		replace selection_4 =1 if `avec_donnee_manquante' ==1 & selection ==1 
	}

	if substr("`:type `var''" , 1, 3) == "str" {  // si la variable est  format string 
		replace selection_4 =1 if `avec_donnee_manquante' ==0 & selection ==1 &  `var' !="NA" & `var' !="_Missing data" 
		replace selection_4 =1 if `avec_donnee_manquante' ==1 & selection ==1 
	}
	
	estpost svy, subpop(selection_4): tabulate `var' vhb_inf if selection_4 ==1, col pearson // résultats p-value dans e(b)
		replace p_value4 =e(p_Pear) if _n==`ligne'											// enregistrement de la p-value Chi2 Pearson
		matrix vecteur=e(b)																	// création du vecteur avec toutes les valeurs à stocker
		levelsof `var' if selection_4 ==1, local(mod)										// création vecteur avec l'ensemble des modalités
		local nb_mod = r(r)																	// nombre de modalités
		replace tp_modalite41 = "n=`e(N)'" 		 if _n==`ligne'
	replace tp_variable4 ="`: var label `var''"	 if _n==`ligne'  							//ligne d'en-tête
	local ligne=`ligne'+1
	
	local num_modalite 1 																	// création du compteur de la modalité				
	foreach modj of local mod  {   
		* traitement de la modalité modj, num_modalite ème modalité de la liste mod 
		replace tp_variable4 ="`: var label `var''"	 		if _n==`ligne'
		replace tp_modalite41 ="`:label (`var') `modj''"   	if _n==`ligne'
		replace tp_modalite42 ="`modj'" 					if _n==`ligne'
		
		forvalues i=0/1  {
			replace vhb_inf4_`i' = vecteur[1,`i'*(`nb_mod'+1)+`num_modalite'] if _n==`ligne'
			}
		replace total_por_ag_hbs4 = vecteur[1,2*(`nb_mod'+1)+`num_modalite'] if _n==`ligne'		

		local num_modalite = `num_modalite' +1
		local ligne=`ligne'+1
	}

	// dernière ligne de la variable => "TOTAL"
	replace tp_variable4 ="`: var label `var''"	 if _n==`ligne'		
	replace tp_modalite41 ="Total"   			 if _n==`ligne'
	forvalues i=0/1 {										
		replace vhb_inf4_`i' = vecteur[1,`i'*(`nb_mod'+1)+`nb_mod'+1] if _n==`ligne'
	}
	replace total_por_ag_hbs4 = vecteur[1,2*(`nb_mod'+1)+`nb_mod'+1] if _n==`ligne'

	local ligne=`ligne'+2				// 1 ligne vide, passage à la varibale suivante
}
		
		replace selection_4f =0
		replace selection_4f =selection_4
		replace selection_4f =0 if gender ==1
svy, subpop(selection_4f): tabulate npregnancies_cat vhb_inf if selection_4f ==1, col pearson 


//  drop tp_variable4  tp_modalite41  tp_modalite42  vhb_inf4_0  vhb_inf4_1 total_por_ag_hbs4 p_value4  


**# 7.2. ANALYSE MULTIVARIEE
char archipelago[omit] "1"
char gender[omit] "2"
char age_cat[omit] "2"
char max_school2 [omit] "3"
char civil_state4 [omit] "2"
char age_first_sex_cat [omit] "2"
 	
// dans l'échantillon
xi: sw logistic vhb_inf (i.archipelago) (i.gender) (i.age_cat) (i.max_school2) (i.birth_location) (i.civil_state4) (i.socio_cultural2) (i.pro_act_last_year2) (i.nhouse_tot_classif3) (i.alcool_12m_bool) (i.alcool_30d_bool) (i.ntabaco_per_day_equ_class) (i.paka_weekly_bool) (i.house_clim) (i.chronic_ald) (i.sex2) (i.age_first_sex_cat)  (i.condom_during_first_sex2) (i.condom_during_occasional_sex2) (i.diabete_bool) (i.obesity_who_bool) if  vhb_inf !=99,pr (0.05) lr


/* note: 5 obs omitted because of estimability.
Logistic regression                                     Number of obs =  1,829
                                                        LR chi2(22)   = 395.48
                                                        Prob > chi2   = 0.0000
Log likelihood = -642.49588                             Pseudo R2     = 0.2353

--------------------------------------------------------------------------------
       vhb_inf | Odds ratio   Std. err.      z    P>|z|     [95% conf. interval]
---------------+----------------------------------------------------------------
 _Iarchipela_1 |   1.344055   .3131547     1.27   0.204     .8513211    2.121976
 _Iarchipela_2 |    3.58521   .7822958     5.85   0.000     2.337662    5.498541
 _Iarchipela_4 |   1.276143   .2395167     1.30   0.194      .883363     1.84357
 _Iarchipela_5 |   .8644452   .2216675    -0.57   0.570     .5229571    1.428923
    _Igender_1 |   1.509887   .2169824     2.87   0.004     1.139254      2.0011
   _Iage_cat_1 |   .0259621   .0154106    -6.15   0.000     .0081112     .083099
   _Iage_cat_3 |   1.737972   .2771735     3.47   0.001     1.271429    2.375709
 _Imax_schoo_1 |    1.57574   .2978314     2.41   0.016     1.087924    2.282289
 _Imax_schoo_2 |   .9619265   .1767222    -0.21   0.833     .6710605    1.378866
 _Imax_schoo_4 |   .6931164    .179766    -1.41   0.158     .4169072     1.15232
 _Icondom_du_2 |   2.534542   .6283531     3.75   0.000     1.559097    4.120272
_Icondom_du_99 |   1.546229   .5896199     1.14   0.253     .7322964    3.264829
 _Icivil_sta_1 |   1.319458   .2587274     1.41   0.157      .898435    1.937779
 _Icivil_sta_3 |   1.689379   .3893285     2.28   0.023     1.075381    2.653946
 _Isocio_cul_2 |    .036219   .0370782    -3.24   0.001     .0048702     .269358
 _Isocio_cul_3 |    1.16016   .8275447     0.21   0.835     .2866513      4.6955
 _Isocio_cul_4 |   .8419351   .1706712    -0.85   0.396      .565886    1.252646
 _Isocio_cul_5 |   1.120058   .8481083     0.15   0.881     .2539281    4.940496
_Isocio_cul_99 |   .3376289   .3782678    -0.97   0.332     .0375649    3.034566
 _Iage_first_1 |   .6440009   .1254344    -2.26   0.024     .4396377    .9433613
 _Iage_first_3 |   .6434282   .1341081    -2.12   0.034     .4276479    .9680859
_Iage_first_99 |   1.241591   .3584108     0.75   0.453     .7051178    2.186228
         _cons |   .0737331   .0212874    -9.03   0.000     .0418709    .1298412
-------------------------------------------------------------------------------- */

xi : sw logistic vhb_inf (i.archipelago) (i.gender) (i.age_cat) (i.max_school2) (i.birth_location) (i.civil_state4) (i.socio_cultural2) (i.pro_act_last_year2) (i.nhouse_tot_classif3) (i.alcool_12m_bool) (i.alcool_30d_bool) (i.ntabaco_per_day_equ_class) (i.paka_weekly_bool) (i.house_clim) (i.chronic_ald) (i.sex2) (i.age_first_sex_cat) (i.condom_during_first_sex2) (i.condom_during_occasional_sex2) (i.diabete_bool) (i.obesity_who_bool)  if  vhb_inf !=99   [pweight=weighting], pr (0.05) lr
  
  
*******************************  
xi : logistic vhb_inf i.archipelago i.gender i.age_cat i.max_school2 i.birth_location i.civil_state4 i.socio_cultural2 i.pro_act_last_year2 i.nhouse_tot_classif3 i.alcool_12m_bool i.alcool_30d_bool i.ntabaco_per_day_equ_class i.paka_weekly_bool i.house_clim i.chronic_ald i.sex2 i.age_first_sex_cat i.condom_during_first_sex2 i.condom_during_occasional_sex2 i.diabete_bool i.obesity_who_bool  if  vhb_inf !=99   [pweight=weighting]
testparm _Iarchi*						
testparm _Igender* 
testparm _Iage_cat* 
testparm _Imax_* 
testparm _Ibirth_* 
testparm _Icivil_* 
testparm _Isocio_* 
testparm _Ipro_* 
testparm _Inhous* 
testparm _Ialcool_12* 
testparm _Ialcool_30* 
testparm _Intabaco_* 
testparm _Ipaka_wee* 
testparm _Ihouse_cli* 
testparm _Ichronic_* 	//p= 0.9577
testparm _Isex2* 
testparm _Iage_first* 
testparm _Icondom_du_* 
testparm _Icondom_dua* 
testparm _Idiabete* 
testparm _Iobesity*

xi : logistic vhb_inf i.archipelago i.gender i.age_cat i.max_school2 i.birth_location i.civil_state4 i.socio_cultural2 i.pro_act_last_year2 i.nhouse_tot_classif3 i.alcool_12m_bool i.alcool_30d_bool i.ntabaco_per_day_equ_class i.paka_weekly_bool i.house_clim i.sex2 i.age_first_sex_cat i.condom_during_first_sex2 i.condom_during_occasional_sex2 i.diabete_bool i.obesity_who_bool  if  vhb_inf !=99   [pweight=weighting]
testparm _Iarchi*						
testparm _Igender* 
testparm _Iage_cat* 
testparm _Imax_* 
testparm _Ibirth_* 
testparm _Icivil_* 
testparm _Isocio_* 
testparm _Ipro_* 
testparm _Inhous* 
testparm _Ialcool_12* 		//p= 0.8543
testparm _Ialcool_30* 
testparm _Intabaco_* 
testparm _Ipaka_wee* 
testparm _Ihouse_cli* 
testparm _Isex2* 
testparm _Iage_first* 
testparm _Icondom_du_* 
testparm _Icondom_dua* 
testparm _Idiabete* 
testparm _Iobesity*

xi : logistic vhb_inf i.archipelago i.gender i.age_cat i.max_school2 i.birth_location i.civil_state4 i.socio_cultural2 i.pro_act_last_year2 i.nhouse_tot_classif3 i.alcool_30d_bool i.ntabaco_per_day_equ_class i.paka_weekly_bool i.house_clim i.sex2 i.age_first_sex_cat i.condom_during_first_sex2 i.condom_during_occasional_sex2 i.diabete_bool i.obesity_who_bool  if  vhb_inf !=99   [pweight=weighting]
testparm _Iarchi*						
testparm _Igender* 
testparm _Iage_cat* 
testparm _Imax_* 
testparm _Ibirth_* 
testparm _Icivil_* 
testparm _Isocio_* 
testparm _Ipro_* 
testparm _Inhous* 
testparm _Ialcool_30* 
testparm _Intabaco_* 
testparm _Ipaka_wee* 
testparm _Ihouse_cli* 
testparm _Isex2* 
testparm _Iage_first* 
testparm _Icondom_du_* 
testparm _Icondom_dua* 
testparm _Idiabete* 
testparm _Iobesity*			//p=0.7583

xi : logistic vhb_inf i.archipelago i.gender i.age_cat i.max_school2 i.birth_location i.civil_state4 i.socio_cultural2 i.pro_act_last_year2 i.nhouse_tot_classif3 i.alcool_30d_bool i.ntabaco_per_day_equ_class i.paka_weekly_bool i.house_clim i.sex2 i.age_first_sex_cat i.condom_during_first_sex2 i.condom_during_occasional_sex2 i.diabete_bool if  vhb_inf !=99   [pweight=weighting]
testparm _Iarchi*						
testparm _Igender* 
testparm _Iage_cat* 
testparm _Imax_* 
testparm _Ibirth_* 
testparm _Icivil_* 
testparm _Isocio_* 
testparm _Ipro_* 		// p= 0.5160
testparm _Inhous* 
testparm _Ialcool_30* 
testparm _Intabaco_* 
testparm _Ipaka_wee* 
testparm _Ihouse_cli* 
testparm _Isex2* 
testparm _Iage_first* 
testparm _Icondom_du_* 
testparm _Icondom_dua* 
testparm _Idiabete* 

xi : logistic vhb_inf i.archipelago i.gender i.age_cat i.max_school2 i.birth_location i.civil_state4 i.socio_cultural2 i.nhouse_tot_classif3 i.alcool_30d_bool i.ntabaco_per_day_equ_class i.paka_weekly_bool i.house_clim i.sex2 i.age_first_sex_cat i.condom_during_first_sex2 i.condom_during_occasional_sex2 i.diabete_bool if  vhb_inf !=99   [pweight=weighting]
testparm _Iarchi*						
testparm _Igender* 
testparm _Iage_cat* 
testparm _Imax_* 
testparm _Ibirth_* 
testparm _Icivil_* 
testparm _Isocio_* 
testparm _Inhous* 
testparm _Ialcool_30* 
testparm _Intabaco_* 
testparm _Ipaka_wee* 
testparm _Ihouse_cli* 
testparm _Isex2* 
testparm _Iage_first* 
testparm _Icondom_du_* 
testparm _Icondom_dua* 
testparm _Idiabete* 		//p=0.4377

xi : logistic vhb_inf i.archipelago i.gender i.age_cat i.max_school2 i.birth_location i.civil_state4 i.socio_cultural2 i.nhouse_tot_classif3 i.alcool_30d_bool i.ntabaco_per_day_equ_class i.paka_weekly_bool i.house_clim i.sex2 i.age_first_sex_cat i.condom_during_first_sex2 i.condom_during_occasional_sex2 if  vhb_inf !=99 [pweight=weighting]
testparm _Iarchi*						
testparm _Igender* 
testparm _Iage_cat* 
testparm _Imax_* 
testparm _Ibirth_* 
testparm _Icivil_* 
testparm _Isocio_* 
testparm _Inhous* 
testparm _Ialcool_30* 		//p=rob > chi2 =    0.3534
testparm _Intabaco_* 
testparm _Ipaka_wee* 
testparm _Ihouse_cli* 
testparm _Isex2* 
testparm _Iage_first* 
testparm _Icondom_du_* 
testparm _Icondom_dua* 

xi : logistic vhb_inf i.archipelago i.gender i.age_cat i.max_school2 i.birth_location i.civil_state4 i.socio_cultural2 i.nhouse_tot_classif3 i.ntabaco_per_day_equ_class i.paka_weekly_bool i.house_clim i.sex2 i.age_first_sex_cat i.condom_during_first_sex2 i.condom_during_occasional_sex2 if  vhb_inf !=99 [pweight=weighting]
testparm _Iarchi*						
testparm _Igender* 
testparm _Iage_cat* 
testparm _Imax_* 
testparm _Ibirth_* 
testparm _Icivil_* 
testparm _Isocio_* 
testparm _Inhous* 
testparm _Intabaco_* 
testparm _Ipaka_wee* 
testparm _Ihouse_cli* 
testparm _Isex2* 
testparm _Iage_first* 
testparm _Icondom_du_* 
testparm _Icondom_dua* 	//p=   0.3286

xi : logistic vhb_inf i.archipelago i.gender i.age_cat i.max_school2 i.birth_location i.civil_state4 i.socio_cultural2 i.nhouse_tot_classif3 i.ntabaco_per_day_equ_class i.paka_weekly_bool i.house_clim i.sex2 i.age_first_sex_cat i.condom_during_first_sex2 if  vhb_inf !=99 [pweight=weighting]
testparm _Iarchi*						
testparm _Igender* 
testparm _Iage_cat* 
testparm _Imax_* 
testparm _Ibirth_* 
testparm _Icivil_* 
testparm _Isocio_* 
testparm _Inhous* 
testparm _Intabaco_* 
testparm _Ipaka_wee* 
testparm _Ihouse_cli* 
testparm _Isex2* 		//p=b > chi2 =    0.4548
testparm _Iage_first* 
testparm _Icondom_du_* 

xi : logistic vhb_inf i.archipelago i.gender i.age_cat i.max_school2 i.birth_location i.civil_state4 i.socio_cultural2 i.nhouse_tot_classif3 i.ntabaco_per_day_equ_class i.paka_weekly_bool i.house_clim i.age_first_sex_cat i.condom_during_first_sex2 if  vhb_inf !=99 [pweight=weighting]
testparm _Iarchi*						
testparm _Igender* 
testparm _Iage_cat* 
testparm _Imax_* 
testparm _Ibirth_* 
testparm _Icivil_* 
testparm _Isocio_* 
testparm _Inhous* 
testparm _Intabaco_* 
testparm _Ipaka_wee* 		//p=0.2649
testparm _Ihouse_cli* 
testparm _Iage_first* 
testparm _Icondom_du_* 

xi : logistic vhb_inf i.archipelago i.gender i.age_cat i.max_school2 i.birth_location i.civil_state4 i.socio_cultural2 i.nhouse_tot_classif3 i.ntabaco_per_day_equ_class i.house_clim i.age_first_sex_cat i.condom_during_first_sex2 if  vhb_inf !=99 [pweight=weighting]
testparm _Iarchi*						
testparm _Igender* 
testparm _Iage_cat* 
testparm _Imax_* 
testparm _Ibirth_* 
testparm _Icivil_* 
testparm _Isocio_* 
testparm _Inhous* 
testparm _Intabaco_* 		//p= 0.2375
testparm _Ihouse_cli* 
testparm _Iage_first* 
testparm _Icondom_du_* 

xi : logistic vhb_inf i.archipelago i.gender i.age_cat i.max_school2 i.birth_location i.civil_state4 i.socio_cultural2 i.nhouse_tot_classif3 i.house_clim i.age_first_sex_cat i.condom_during_first_sex2 if  vhb_inf !=99 [pweight=weighting]
testparm _Iarchi*						
testparm _Igender* 
testparm _Iage_cat* 
testparm _Imax_* 
testparm _Ibirth_* 
testparm _Icivil_* 	//p=0.2342
testparm _Isocio_* 
testparm _Inhous* 
testparm _Ihouse_cli* 
testparm _Iage_first* 
testparm _Icondom_du_* 

xi : logistic vhb_inf i.archipelago i.gender i.age_cat i.max_school2 i.birth_location i.socio_cultural2 i.nhouse_tot_classif3 i.house_clim i.age_first_sex_cat i.condom_during_first_sex2 if  vhb_inf !=99 [pweight=weighting]
testparm _Iarchi*						
testparm _Igender* 
testparm _Iage_cat* 
testparm _Imax_* 
testparm _Ibirth_* //p=0.2168
testparm _Isocio_* 
testparm _Inhous* 
testparm _Ihouse_cli* 
testparm _Iage_first* 
testparm _Icondom_du_* 

xi : logistic vhb_inf i.archipelago i.gender i.age_cat i.max_school2 i.socio_cultural2 i.nhouse_tot_classif3 i.house_clim i.age_first_sex_cat i.condom_during_first_sex2 if  vhb_inf !=99 [pweight=weighting]
testparm _Iarchi*						
testparm _Igender* 
testparm _Iage_cat* 
testparm _Imax_* 
testparm _Isocio_* 
testparm _Inhous* 		//p=0.1441
testparm _Ihouse_cli* 
testparm _Iage_first* 
testparm _Icondom_du_* 

xi : logistic vhb_inf i.archipelago i.gender i.age_cat i.max_school2 i.socio_cultural2 i.house_clim i.age_first_sex_cat i.condom_during_first_sex2 if  vhb_inf !=99 [pweight=weighting]
testparm _Iarchi*						
testparm _Igender* 
testparm _Iage_cat* 
testparm _Imax_* 
testparm _Isocio_* 
testparm _Ihouse_cli* 		//p=0.1380
testparm _Iage_first* 
testparm _Icondom_du_* 

xi : logistic vhb_inf i.archipelago i.gender i.age_cat i.max_school2 i.socio_cultural2 i.age_first_sex_cat i.condom_during_first_sex2 if  vhb_inf !=99 [pweight=weighting]
testparm _Iarchi*				// p<0.0001
testparm _Igender* 				// p=0.0280
testparm _Iage_cat* 			// p< 0.0001
testparm _Imax_* 				// p=0.0379
testparm _Isocio_* 				// p=0.0154
testparm _Iage_first* 			// p=0.0008
testparm _Icondom_du_* 			// p=0.0188

*************************************
* TEST
/*
replace selection =0
replace selection = 1 if vhb_por_ag_hbs <10 

xi : exlogistic vhb_por_ag_hbs i.archipelago i.age_cat if selection ==1 , memory(2000m)

xi: svy, subpop(selection) : logistic vhb_por_ag_hbs i.archipelago i.age_cat 

xi: poisson vhb_por_ag_hbs i.archipelago i.age_cat if selection ==1,irr

tab archipelago vhb_por_ag_hbs if selection ==1
xi: poisson vhb_por_ag_hbs i.archipelago if selection ==1,irr
xi: svy: poisson vhb_por_ag_hbs i.archipelago if selection ==1,irr
*/
replace selection = 1 if vhb_por_ag_hbs <10 
xi : exlogistic vhb_por_ag_hbs i.age_cat if selection ==1 , memory(2000m)

xi : firthlogit vhb_por_ag_hbs i.age_cat if selection ==1 , or

xi : logistic vhb_por_ag_hbs i.archipelago if selection ==1


****OPTION 1******
svyset [pweight=weighting]
xi : svy, subpop(selection): logistic vhb_por_ag_hbs i.archipelago 

****OPTION 2******
svyset [pweight=weighting], strata(strata_id)

xi : svy, subpop(selection): logistic vhb_por_ag_hbs i.archipelago



res_hba1g>=6.5
**********************************************************************
**# 		ANALYSER LE FIB4 COMME OUTCOME PRINCIPAL 				**
**********************************************************************
capture log close
log using "fib4.log", replace

tab fib_4_cat hypertension_clin, col chi2 
tab fib_4_cat hypertension_bool, col chi2 
tab fib_4_cat diabete, col chi2 
tab fib_4_cat diabete_bool, col chi2 
*tab fib_4_cat obesity_classif_who2, col chi2 expected exact
log close

capture log close
log using "alcool.log", replace
list subjid alcool alcool_last_year alcool_12m_bool alcool_medical_stop alcool_one_glass_last_year_freq alcool_last_month alcool_30d_bool alcool_one_glass_last_month_freq nalcool_glass_last_month alcool_category nmax_alcool_glass_last_month alcool_six_glass_last_month_freq nalcool_glass_last_monday nalcool_glass_last_tuesday nalcool_glass_last_wednesday nalcool_glass_last_thursday nalcool_glass_last_friday nalcool_glass_last_saturday nalcool_glass_last_sunday social_pb_alcool_last_year social_pb_alcool_last_year in 1/100
log close


gen diabete_ilm = 0
label define lbdiabete_ilm 0 "Non diabétique" 1 "Diabétique"
label var diabete_ilm "CATEGORIE DIABETE SELON LIV"
label values diabete_ilm lbdiabete_ilm
replace diabete_ilm=1 if res_hba1g>=6.5 | diabete_measured_last_year=="Yes" | diabete_medic_last_2weeks=="Yes"
browse subjid gender diabete_measured diabete_measured_last_year diabete_medic_last_2weeks diabete diabete_bool diabete_ilm res_hba1g res_hba1g_cat