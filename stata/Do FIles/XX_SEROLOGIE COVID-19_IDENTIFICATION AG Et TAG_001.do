*****************************************************************************
*   			  		  Serologie Covid-19 								*
*																			*
*					  Serologie Covid-16 Luminex®							*
*																			*
*	  		EVALUATION PERFORMANCE LUMINEX ANTI-N & ANTI-S					*
*					IDENTIFICATION ANTI-GENE ET TAG							*
* 	auteur : Vincent Mendiboure												*
* 	dernier update : 20 septembre 2022										*
*																			*
*****************************************************************************


**************************************************
**# 		I. PREPARATION
**************************************************

*cd "Z:\donnees\Stata\SERO COVID"
 cd  "C:\Users\Mendiboure\Documents\Master PH\Stage Pasteur\image\donnees\Stata\SERO COVID"

// Importation de la base
clear
import excel using "220920_CROC 5Plex SARS-cov-2 seroprevalence kit Elycsis.xlsx", firstrow clear

// Nettoyage
label var luminex_n	"SARS-CoV-2 N His-Tag (30)"
label var luminex_s1_histag36 "SARS-CoV-2 spike (NA) S1 His-Tag (36)"
label var luminex_s2_histag37 "SARS-CoV-2 spike (NA) S2 His-Tag (37)"
label var luminex_s1_shfctag46 "SARS-CoV-2 spike (NA) S1 SHFc-Tag (46)"
label var luminex_s2_shfctag52 "SARS-CoV-2 spike (NA) S2 SHFc-Tag (52)"
label var elisa_n "Résultats ELISA LABM - Protéine N"
label var elisa_s "Résultats ELISA LABM - Protéine S"

label define lbnegpos 0 "Negatif" 1 "Positif" 

foreach var in luminex_n luminex_s1_histag36 luminex_s2_histag37 luminex_s1_shfctag46 luminex_s2_shfctag52 elisa_n elisa_s {
	replace `var' ="0" if `var' =="NEG" | `var' =="Négatif" 
	replace `var' ="1" if `var' =="POS" | `var' =="Positif" 
	destring `var', replace
	label values `var' lbnegpos
}

gen res_test  =""
gen res_se	  =.
gen res_sp	  =.
gen res_vpp	  =.
gen res_vpn	  =.
gen res_kappa =.
gen res_kappa_stderr =.
gen res_bi	  =.
gen res_pi	  =.
gen res_pabak =.
gen res_ppos  =.
gen res_pneg  =.
	format res_se res_sp res_vpp res_vpn %8.1f


**************************************************
**# 		II. DEFINITION DU PROGRAMME 
**************************************************

capture program drop evaluation

program define evaluation

	// Cette commande permet à partir des effectifs
	// du tableau de calculer PABAK, PI et BI
	gettoken a 0 : 0
	gettoken b 0 : 0
	gettoken c 0 : 0
	gettoken d 0 : 0

	** Effectif total	
	local tot=`a'+`b'+`c'+`d'
	
	** Effectifs attendus
	local ae =(`a'+`c')*(`a'+`b')/`tot'
*	local be =(`b'+`d')*(`a'+`b')/`tot'
*	local ce =(`a'+`c')*(`c'+`d')/`tot'
	local de =(`b'+`d')*(`c'+`d')/`tot'

	** Validité du test (sp, se, VPP, VPN)
	global se=`a'/(`a'+`c')
		global lse=$se-1.96*sqrt(($se*(1-$se))/(`a'+`c')) //lower 95% CI
		global use=$se+1.96*sqrt(($se*(1-$se))/(`a'+`c')) //upper 95% CI
	global sp=`d'/(`b'+`d')
		local lsp=$sp-1.96*sqrt(($sp*(1-$sp))/(`b'+`d')) //lower 95% CI
		local usp=$sp+1.96*sqrt(($sp*(1-$sp))/(`b'+`d')) //upper 95% CI
	global vpp=`a'/(`a'+`b')
	global vpn=`d'/(`c'+`d')
		
	** Reproductibilité du test 
	** Calcul de Po & Pe
	global po =(`a'+`d')/`tot'
	global pe =(`ae'+`de')/`tot'
	
	** Calcul des différents scores PABAK, PI, BI, ...
	global kappa=($po-$pe)/(1-$pe)
	global bi=(`b'-`c')/`tot'
	global pi=(`a'-`d')/`tot'
	global pabak=2*$po - 1
	global ppos=(2*`a')/(`tot'+`a'-`d')
	global pneg=(2*`d')/(`tot'+`d'-`a')

	** Affichage des résultats
	display as text "{hline 10} Validité du test {hline 10}"
	display ""
	display as result "Sensibilité= "  				 %8.1f $se  * 100 "%"
	display as result "Spécificité= "  				 %8.1f $sp  * 100 "%"
	display as result "Valeur Prédictive Positive= " %8.1f $vpp * 100 "%"
	display as result "Valeur Prédictive Négative= " %8.1f $vpn * 100 "%"
	display ""
	display as text "{hline 10} Reproductibilité du test : Kappa & PABAK {hline 10}"
	display as result "Kappa= "  %8.4f $kappa
	display as result "BI=    "  %8.3f $bi
	display as result "PI=    "  %8.3f $pi
	display as result "PABAK= "  %8.3f $pabak
	display as result "P pos= "  %8.3f $ppos
	display as result "P neg= "  %8.3f $pneg
	display ""
	display as text "{hline 30}"
end


************************************************************
**# 		III. EVALUATION PERFORMANCE LUMINEX ANTI-N
************************************************************
local ligne 2
tab luminex_n elisa_n, matcell(tableau)
	display  "Test Luminex® vs Elisa - Séroprévalence Ac anti-N"
	display ""
evaluation tableau[2,2] tableau[2,1] tableau[1,2] tableau[1,1] 
kap luminex_n elisa_n, tab
	replace res_test  ="luminex_n"  	if _n==`ligne'
	replace res_se	  =$se  *100		if _n==`ligne'
	replace res_sp	  =$sp  *100		if _n==`ligne'
	replace res_vpp	  =$vpp *100		if _n==`ligne'
	replace res_vpn	  =$vpn *100		if _n==`ligne'
	replace res_kappa =$kappa 			if _n==`ligne'
	replace res_kappa_stderr = `r(se)' 	if _n==`ligne'
	replace res_bi	  =$bi 				if _n==`ligne'
	replace res_pi	  =$pi 				if _n==`ligne'
	replace res_pabak =$pabak			if _n==`ligne'
	replace res_ppos  =$ppos 			if _n==`ligne'
	replace res_pneg  =$pneg 			if _n==`ligne'


*************************************************************************
**# 		III. EVALUATION PERFORMANCE COMBINAISONS LUMINEX ANTI-S
*************************************************************************

{	// 1 positif parmi 1 (4 combinaisons) : Res_i pos
local ligne 3
foreach var in luminex_s1_histag36 luminex_s2_histag37 luminex_s1_shfctag46 luminex_s2_shfctag52 {
	tab `var' elisa_s, matcell(tableau)
	display  "Test Luminex® `var' vs Elisa - Séroprévalence Ac anti-S"
	display ""
evaluation tableau[2,2] tableau[2,1] tableau[1,2] tableau[1,1] 
kap `var' elisa_s, tab
	replace res_test  ="`var'"  	if _n==`ligne'
	replace res_se	  =$se  * 100			if _n==`ligne'
	replace res_sp	  =$sp  * 100			if _n==`ligne'
	replace res_vpp	  =$vpp * 100 			if _n==`ligne'
	replace res_vpn	  =$vpn * 100 			if _n==`ligne'
	replace res_kappa =$kappa 			if _n==`ligne'
	replace res_kappa_stderr = `r(se)' 	if _n==`ligne'
	replace res_bi	  =$bi 				if _n==`ligne'
	replace res_pi	  =$pi 				if _n==`ligne'
	replace res_pabak =$pabak			if _n==`ligne'
	replace res_ppos  =$ppos 			if _n==`ligne'
	replace res_pneg  =$pneg 			if _n==`ligne'

local ligne = `ligne'+1
}
}

{	// 2 positifs parmi 2 (6 combinaisons): Res_i pos ET Res_j pos
local ligne 7
local varlist luminex_s1_histag36 luminex_s2_histag37 luminex_s1_shfctag46 luminex_s2_shfctag52 
local varlist2 `varlist'
foreach var1 in `varlist' {
	gettoken a varlist2 : varlist2
	display `"`a'"'
	display `"`varlist2'"'
	foreach var2 in `varlist2' {
		gen tp_res = `var1' * `var2'
			display  "Test Luminex® `var1' & `var2' vs Elisa - Séroprévalence Ac anti-S"
			display ""
		quietly tab tp_res elisa_s, matcell(tableau)
		evaluation tableau[2,2] tableau[2,1] tableau[1,2] tableau[1,1] 
		kap tp_res elisa_s, tab
			replace res_test  ="`var1' & `var2'"  	if _n==`ligne'
			replace res_se	  =$se  * 100			if _n==`ligne'
			replace res_sp	  =$sp  * 100			if _n==`ligne'
			replace res_vpp	  =$vpp * 100 			if _n==`ligne'
			replace res_vpn	  =$vpn * 100 			if _n==`ligne'
			replace res_kappa =$kappa 			if _n==`ligne'
			replace res_kappa_stderr = `r(se)' 	if _n==`ligne'
			replace res_bi	  =$bi 				if _n==`ligne'
			replace res_pi	  =$pi 				if _n==`ligne'
			replace res_pabak =$pabak			if _n==`ligne'
			replace res_ppos  =$ppos 			if _n==`ligne'
			replace res_pneg  =$pneg 			if _n==`ligne'
		local ligne = `ligne'+1
		drop tp_res
	}
}
}

{	// 1 positif parmi 2 (6 combinaisons): Res_i pos OU Res_j pos
local ligne 13
local varlist luminex_s1_histag36 luminex_s2_histag37 luminex_s1_shfctag46 luminex_s2_shfctag52 
local varlist2 `varlist'
foreach var1 in `varlist' {
	gettoken a varlist2 : varlist2
	foreach var2 in `varlist2' {
		gen tp_res = `var1' + `var2'
		recode tp_res (2=1)
			display  "Test Luminex® `var1' OU `var2' vs Elisa - Séroprévalence Ac anti-S"
			display ""
		quietly tab tp_res elisa_s, matcell(tableau)
		evaluation tableau[2,2] tableau[2,1] tableau[1,2] tableau[1,1] 
		kap tp_res elisa_s, tab
			replace res_test  ="`var1' OU `var2'"  	if _n==`ligne'
			replace res_se	  =$se  * 100			if _n==`ligne'
			replace res_sp	  =$sp  * 100			if _n==`ligne'
			replace res_vpp	  =$vpp * 100 			if _n==`ligne'
			replace res_vpn	  =$vpn * 100 			if _n==`ligne'
			replace res_kappa =$kappa 			if _n==`ligne'
			replace res_kappa_stderr = `r(se)' 	if _n==`ligne'
			replace res_bi	  =$bi 				if _n==`ligne'
			replace res_pi	  =$pi 				if _n==`ligne'
			replace res_pabak =$pabak			if _n==`ligne'
			replace res_ppos  =$ppos 			if _n==`ligne'
			replace res_pneg  =$pneg 			if _n==`ligne'
		local ligne = `ligne'+1
		drop tp_res
	}
}
}

{	// 3 positifs parmi 3 (4 combinaisons): Res_i pos ET Res_j pos ET Res_k pos
local ligne 19
gen tp_res = 0 
	replace tp_res =1 if luminex_s1_histag36 ==1 & luminex_s2_histag37 ==1 & luminex_s1_shfctag46 ==1
		display  "Test Luminex® (36 & 37 & 46) vs Elisa - Séroprévalence Ac anti-S"
			display ""
	quietly tab tp_res elisa_s, matcell(tableau)
	evaluation tableau[2,2] tableau[2,1] tableau[1,2] tableau[1,1] 
	kap tp_res elisa_s, tab
			replace res_test  ="36 & 37 & 46"  	if _n==`ligne'
			replace res_se	  =$se  * 100			if _n==`ligne'
			replace res_sp	  =$sp  * 100			if _n==`ligne'
			replace res_vpp	  =$vpp * 100 			if _n==`ligne'
			replace res_vpn	  =$vpn * 100 			if _n==`ligne'
			replace res_kappa =$kappa 			if _n==`ligne'
			replace res_kappa_stderr = `r(se)' 	if _n==`ligne'
			replace res_bi	  =$bi 				if _n==`ligne'
			replace res_pi	  =$pi 				if _n==`ligne'
			replace res_pabak =$pabak			if _n==`ligne'
			replace res_ppos  =$ppos 			if _n==`ligne'
			replace res_pneg  =$pneg 			if _n==`ligne'
	local ligne = `ligne'+1
	drop tp_res

gen tp_res = 0 
	replace tp_res =1 if luminex_s1_histag36 ==1 & luminex_s2_histag37 ==1 & luminex_s2_shfctag52 ==1
		display  "Test Luminex® (36 & 37 & 52) vs Elisa - Séroprévalence Ac anti-S"
			display ""
	quietly tab tp_res elisa_s, matcell(tableau)
	evaluation tableau[2,2] tableau[2,1] tableau[1,2] tableau[1,1] 
	kap tp_res elisa_s, tab
			replace res_test  ="36 & 37 & 52"  	if _n==`ligne'
			replace res_se	  =$se  * 100			if _n==`ligne'
			replace res_sp	  =$sp  * 100			if _n==`ligne'
			replace res_vpp	  =$vpp * 100 			if _n==`ligne'
			replace res_vpn	  =$vpn * 100 			if _n==`ligne'
			replace res_kappa =$kappa 			if _n==`ligne'
			replace res_kappa_stderr = `r(se)' 	if _n==`ligne'
			replace res_bi	  =$bi 				if _n==`ligne'
			replace res_pi	  =$pi 				if _n==`ligne'
			replace res_pabak =$pabak			if _n==`ligne'
			replace res_ppos  =$ppos 			if _n==`ligne'
			replace res_pneg  =$pneg 			if _n==`ligne'
	local ligne = `ligne'+1
	drop tp_res	

gen tp_res = 0 
	replace tp_res =1 if luminex_s1_histag36 ==1 & luminex_s1_shfctag46 ==1 & luminex_s2_shfctag52 ==1
		display  "Test Luminex® (36 & 46 & 52) vs Elisa - Séroprévalence Ac anti-S"
			display ""
	quietly tab tp_res elisa_s, matcell(tableau)
	evaluation tableau[2,2] tableau[2,1] tableau[1,2] tableau[1,1] 
	kap tp_res elisa_s, tab
			replace res_test  ="36 & 46 & 52"  	if _n==`ligne'
			replace res_se	  =$se  * 100			if _n==`ligne'
			replace res_sp	  =$sp  * 100			if _n==`ligne'
			replace res_vpp	  =$vpp * 100 			if _n==`ligne'
			replace res_vpn	  =$vpn * 100 			if _n==`ligne'
			replace res_kappa =$kappa 			if _n==`ligne'
			replace res_kappa_stderr = `r(se)' 	if _n==`ligne'
			replace res_bi	  =$bi 				if _n==`ligne'
			replace res_pi	  =$pi 				if _n==`ligne'
			replace res_pabak =$pabak			if _n==`ligne'
			replace res_ppos  =$ppos 			if _n==`ligne'
			replace res_pneg  =$pneg 			if _n==`ligne'
	local ligne = `ligne'+1
	drop tp_res

gen tp_res = 0 
	replace tp_res =1 if luminex_s2_histag37 ==1 & luminex_s1_shfctag46 ==1 & luminex_s2_shfctag52 ==1
		display  "Test Luminex® (37 & 46 & 52) vs Elisa - Séroprévalence Ac anti-S"
			display ""
	quietly tab tp_res elisa_s, matcell(tableau)
	evaluation tableau[2,2] tableau[2,1] tableau[1,2] tableau[1,1] 
	kap tp_res elisa_s, tab
			replace res_test  ="37 & 46 & 52"  	if _n==`ligne'
			replace res_se	  =$se  * 100			if _n==`ligne'
			replace res_sp	  =$sp  * 100			if _n==`ligne'
			replace res_vpp	  =$vpp * 100 			if _n==`ligne'
			replace res_vpn	  =$vpn * 100 			if _n==`ligne'
			replace res_kappa =$kappa 			if _n==`ligne'
			replace res_kappa_stderr = `r(se)' 	if _n==`ligne'
			replace res_bi	  =$bi 				if _n==`ligne'
			replace res_pi	  =$pi 				if _n==`ligne'
			replace res_pabak =$pabak			if _n==`ligne'
			replace res_ppos  =$ppos 			if _n==`ligne'
			replace res_pneg  =$pneg 			if _n==`ligne'
	local ligne = `ligne'+1
	drop tp_res
}	
	
{	// 2 positifs parmi 3 (4 combinaisons) 
local ligne 23
gen tp_res = luminex_s1_histag36 + luminex_s2_histag37 + luminex_s1_shfctag46
	recode tp_res (1=0) (2=1) (3=1)
		display  "Test Luminex® 2 parmi (36 37 46) vs Elisa - Séroprévalence Ac anti-S"
		display ""
	quietly tab tp_res elisa_s, matcell(tableau)
	evaluation tableau[2,2] tableau[2,1] tableau[1,2] tableau[1,1] 
	kap tp_res elisa_s, tab
			replace res_test  ="2 parmi (36 37 46)"  	if _n==`ligne'
			replace res_se	  =$se  * 100			if _n==`ligne'
			replace res_sp	  =$sp  * 100			if _n==`ligne'
			replace res_vpp	  =$vpp * 100 			if _n==`ligne'
			replace res_vpn	  =$vpn * 100 			if _n==`ligne'
			replace res_kappa =$kappa 			if _n==`ligne'
			replace res_kappa_stderr = `r(se)' 	if _n==`ligne'
			replace res_bi	  =$bi 				if _n==`ligne'
			replace res_pi	  =$pi 				if _n==`ligne'
			replace res_pabak =$pabak			if _n==`ligne'
			replace res_ppos  =$ppos 			if _n==`ligne'
			replace res_pneg  =$pneg 			if _n==`ligne'
	local ligne = `ligne'+1
	drop tp_res

gen tp_res = luminex_s1_histag36 + luminex_s2_histag37 + luminex_s2_shfctag52
		recode tp_res (1=0) (2=1) (3=1)
		display  "Test Luminex® 2 parmi (36 37 52) vs Elisa - Séroprévalence Ac anti-S"
		display ""
	quietly tab tp_res elisa_s, matcell(tableau)
	evaluation tableau[2,2] tableau[2,1] tableau[1,2] tableau[1,1] 
	kap tp_res elisa_s, tab
			replace res_test  ="2 parmi (36 37 52)"  	if _n==`ligne'
			replace res_se	  =$se  * 100			if _n==`ligne'
			replace res_sp	  =$sp  * 100			if _n==`ligne'
			replace res_vpp	  =$vpp * 100 			if _n==`ligne'
			replace res_vpn	  =$vpn * 100 			if _n==`ligne'
			replace res_kappa =$kappa 			if _n==`ligne'
			replace res_kappa_stderr = `r(se)' 	if _n==`ligne'
			replace res_bi	  =$bi 				if _n==`ligne'
			replace res_pi	  =$pi 				if _n==`ligne'
			replace res_pabak =$pabak			if _n==`ligne'
			replace res_ppos  =$ppos 			if _n==`ligne'
			replace res_pneg  =$pneg 			if _n==`ligne'
	local ligne = `ligne'+1
	drop tp_res	

gen tp_res = luminex_s1_histag36 + luminex_s1_shfctag46 + luminex_s2_shfctag52
		recode tp_res (1=0) (2=1) (3=1)
		display  "Test Luminex® 2 parmi (36 46 52) vs Elisa - Séroprévalence Ac anti-S"
		display ""
	quietly tab tp_res elisa_s, matcell(tableau)
	evaluation tableau[2,2] tableau[2,1] tableau[1,2] tableau[1,1] 
	kap tp_res elisa_s, tab
			replace res_test  ="2 parmi (36 46 52)"  	if _n==`ligne'
			replace res_se	  =$se  * 100			if _n==`ligne'
			replace res_sp	  =$sp  * 100			if _n==`ligne'
			replace res_vpp	  =$vpp * 100 			if _n==`ligne'
			replace res_vpn	  =$vpn * 100 			if _n==`ligne'
			replace res_kappa =$kappa 			if _n==`ligne'
			replace res_kappa_stderr = `r(se)' 	if _n==`ligne'
			replace res_bi	  =$bi 				if _n==`ligne'
			replace res_pi	  =$pi 				if _n==`ligne'
			replace res_pabak =$pabak			if _n==`ligne'
			replace res_ppos  =$ppos 			if _n==`ligne'
			replace res_pneg  =$pneg 			if _n==`ligne'
	local ligne = `ligne'+1
	drop tp_res

gen tp_res = luminex_s2_histag37 + luminex_s1_shfctag46 + luminex_s2_shfctag52
		recode tp_res (1=0) (2=1) (3=1)
		display  "Test Luminex® 2 parmi (37 46 52) vs Elisa - Séroprévalence Ac anti-S"
		display ""
	quietly tab tp_res elisa_s, matcell(tableau)
	evaluation tableau[2,2] tableau[2,1] tableau[1,2] tableau[1,1] 
	kap tp_res elisa_s, tab
			replace res_test  ="2 parmi (37 46 52)"  	if _n==`ligne'
			replace res_se	  =$se  * 100			if _n==`ligne'
			replace res_sp	  =$sp  * 100			if _n==`ligne'
			replace res_vpp	  =$vpp * 100 			if _n==`ligne'
			replace res_vpn	  =$vpn * 100 			if _n==`ligne'
			replace res_kappa =$kappa 			if _n==`ligne'
			replace res_kappa_stderr = `r(se)' 	if _n==`ligne'
			replace res_bi	  =$bi 				if _n==`ligne'
			replace res_pi	  =$pi 				if _n==`ligne'
			replace res_pabak =$pabak			if _n==`ligne'
			replace res_ppos  =$ppos 			if _n==`ligne'
			replace res_pneg  =$pneg 			if _n==`ligne'
	local ligne = `ligne'+1
	drop tp_res
}	

{	// 1 positif parmi 3 (4 combinaisons) 
local ligne 27
gen tp_res = luminex_s1_histag36 + luminex_s2_histag37 + luminex_s1_shfctag46
	recode tp_res (1=1) (2=1) (3=1)
		display  "Test Luminex® 1 parmi (36 37 46) vs Elisa - Séroprévalence Ac anti-S"
		display ""
	quietly tab tp_res elisa_s, matcell(tableau)
	evaluation tableau[2,2] tableau[2,1] tableau[1,2] tableau[1,1] 
	kap tp_res elisa_s, tab
			replace res_test  ="1 parmi (36 37 46)"  	if _n==`ligne'
			replace res_se	  =$se  * 100			if _n==`ligne'
			replace res_sp	  =$sp  * 100			if _n==`ligne'
			replace res_vpp	  =$vpp * 100 			if _n==`ligne'
			replace res_vpn	  =$vpn * 100 			if _n==`ligne'
			replace res_kappa =$kappa 			if _n==`ligne'
			replace res_kappa_stderr = `r(se)' 	if _n==`ligne'
			replace res_bi	  =$bi 				if _n==`ligne'
			replace res_pi	  =$pi 				if _n==`ligne'
			replace res_pabak =$pabak			if _n==`ligne'
			replace res_ppos  =$ppos 			if _n==`ligne'
			replace res_pneg  =$pneg 			if _n==`ligne'
	local ligne = `ligne'+1
	drop tp_res

gen tp_res = luminex_s1_histag36 + luminex_s2_histag37 + luminex_s2_shfctag52
		recode tp_res (1=1) (2=1) (3=1)
		display  "Test Luminex® 1 parmi (36 37 52) vs Elisa - Séroprévalence Ac anti-S"
		display ""
	quietly tab tp_res elisa_s, matcell(tableau)
	evaluation tableau[2,2] tableau[2,1] tableau[1,2] tableau[1,1] 
	kap tp_res elisa_s, tab
			replace res_test  ="1 parmi (36 37 52)"  	if _n==`ligne'
			replace res_se	  =$se  * 100			if _n==`ligne'
			replace res_sp	  =$sp  * 100			if _n==`ligne'
			replace res_vpp	  =$vpp * 100 			if _n==`ligne'
			replace res_vpn	  =$vpn * 100 			if _n==`ligne'
			replace res_kappa =$kappa 			if _n==`ligne'
			replace res_kappa_stderr = `r(se)' 	if _n==`ligne'
			replace res_bi	  =$bi 				if _n==`ligne'
			replace res_pi	  =$pi 				if _n==`ligne'
			replace res_pabak =$pabak			if _n==`ligne'
			replace res_ppos  =$ppos 			if _n==`ligne'
			replace res_pneg  =$pneg 			if _n==`ligne'
	local ligne = `ligne'+1
	drop tp_res	

gen tp_res = luminex_s1_histag36 + luminex_s1_shfctag46 + luminex_s2_shfctag52
		recode tp_res (1=1) (2=1) (3=1)
		display  "Test Luminex® 1 parmi (36 46 52) vs Elisa - Séroprévalence Ac anti-S"
		display ""
	quietly tab tp_res elisa_s, matcell(tableau)
	evaluation tableau[2,2] tableau[2,1] tableau[1,2] tableau[1,1] 
	kap tp_res elisa_s, tab
			replace res_test  ="1 parmi (36 46 52)"  	if _n==`ligne'
			replace res_se	  =$se  * 100			if _n==`ligne'
			replace res_sp	  =$sp  * 100			if _n==`ligne'
			replace res_vpp	  =$vpp * 100 			if _n==`ligne'
			replace res_vpn	  =$vpn * 100 			if _n==`ligne'
			replace res_kappa =$kappa 			if _n==`ligne'
			replace res_kappa_stderr = `r(se)' 	if _n==`ligne'
			replace res_bi	  =$bi 				if _n==`ligne'
			replace res_pi	  =$pi 				if _n==`ligne'
			replace res_pabak =$pabak			if _n==`ligne'
			replace res_ppos  =$ppos 			if _n==`ligne'
			replace res_pneg  =$pneg 			if _n==`ligne'
	local ligne = `ligne'+1
	drop tp_res

gen tp_res = luminex_s2_histag37 + luminex_s1_shfctag46 + luminex_s2_shfctag52
		recode tp_res (1=1) (2=1) (3=1)
		display  "Test Luminex® 1 parmi (37 46 52) vs Elisa - Séroprévalence Ac anti-S"
		display ""
	quietly tab tp_res elisa_s, matcell(tableau)
	evaluation tableau[2,2] tableau[2,1] tableau[1,2] tableau[1,1] 
	kap tp_res elisa_s, tab
			replace res_test  ="1 parmi (37 46 52)"  	if _n==`ligne'
			replace res_se	  =$se  * 100			if _n==`ligne'
			replace res_sp	  =$sp  * 100			if _n==`ligne'
			replace res_vpp	  =$vpp * 100 			if _n==`ligne'
			replace res_vpn	  =$vpn * 100 			if _n==`ligne'
			replace res_kappa =$kappa 			if _n==`ligne'
			replace res_kappa_stderr = `r(se)' 	if _n==`ligne'
			replace res_bi	  =$bi 				if _n==`ligne'
			replace res_pi	  =$pi 				if _n==`ligne'
			replace res_pabak =$pabak			if _n==`ligne'
			replace res_ppos  =$ppos 			if _n==`ligne'
			replace res_pneg  =$pneg 			if _n==`ligne'
	local ligne = `ligne'+1
	drop tp_res
}	
		
{	// 4 positifs parmi 4 (1 combinaison), Res1 ET Res2 ET Res3 ET Res 4
local ligne 31
gen tp_res = 0 
	replace tp_res =1 if luminex_s1_histag36 ==1 & luminex_s2_histag37 ==1 & luminex_s1_shfctag46 ==1 & luminex_s2_shfctag52 ==1
		display  "Test Luminex® (36 & 37 & 46 & 52) vs Elisa - Séroprévalence Ac anti-S"
			display ""
	quietly tab tp_res elisa_s, matcell(tableau)
	evaluation tableau[2,2] tableau[2,1] tableau[1,2] tableau[1,1] 
	kap tp_res elisa_s, tab
			replace res_test  ="36 & 37 & 46 & 52" 	if _n==`ligne'
			replace res_se	  =$se  * 100			if _n==`ligne'
			replace res_sp	  =$sp  * 100			if _n==`ligne'
			replace res_vpp	  =$vpp * 100 			if _n==`ligne'
			replace res_vpn	  =$vpn * 100 			if _n==`ligne'
			replace res_kappa =$kappa 			if _n==`ligne'
			replace res_kappa_stderr = `r(se)' 	if _n==`ligne'
			replace res_bi	  =$bi 				if _n==`ligne'
			replace res_pi	  =$pi 				if _n==`ligne'
			replace res_pabak =$pabak			if _n==`ligne'
			replace res_ppos  =$ppos 			if _n==`ligne'
			replace res_pneg  =$pneg 			if _n==`ligne'
	local ligne = `ligne'+1
	drop tp_res
}	
		
{	// 3 res positifs parmi 4 res luminex (1 combinaison)
local ligne 32
gen tp_res = luminex_s1_histag36 + luminex_s2_histag37 + luminex_s1_shfctag46 + luminex_s2_shfctag52
	recode tp_res (1=0) (2=0) (3=1) (4=1)
		display  "Test Luminex® 3 parmi (36 37 46 52) vs Elisa - Séroprévalence Ac anti-S"
			display ""
	quietly tab tp_res elisa_s, matcell(tableau)
	evaluation tableau[2,2] tableau[2,1] tableau[1,2] tableau[1,1] 
	kap tp_res elisa_s, tab
			replace res_test  ="3 parmi (36 37 46 52)" 	if _n==`ligne'
			replace res_se	  =$se  * 100				if _n==`ligne'
			replace res_sp	  =$sp  * 100				if _n==`ligne'
			replace res_vpp	  =$vpp * 100 				if _n==`ligne'
			replace res_vpn	  =$vpn * 100 				if _n==`ligne'
			replace res_kappa =$kappa 			if _n==`ligne'
			replace res_kappa_stderr = `r(se)' 	if _n==`ligne'
			replace res_bi	  =$bi 				if _n==`ligne'
			replace res_pi	  =$pi 				if _n==`ligne'
			replace res_pabak =$pabak			if _n==`ligne'
			replace res_ppos  =$ppos 			if _n==`ligne'
			replace res_pneg  =$pneg 			if _n==`ligne'
	local ligne = `ligne'+1
	drop tp_res
}	
		
{	// 2 res positifs parmi 4 res luminex (1 combinaison)
local ligne 33
gen tp_res = luminex_s1_histag36 + luminex_s2_histag37 + luminex_s1_shfctag46 + luminex_s2_shfctag52
	recode tp_res (1=0) (2=1) (3=1) (4=1)
		display  "Test Luminex® 2 parmi (36 37 46 52) vs Elisa - Séroprévalence Ac anti-S"
			display ""
	quietly tab tp_res elisa_s, matcell(tableau)
	evaluation tableau[2,2] tableau[2,1] tableau[1,2] tableau[1,1] 
	kap tp_res elisa_s, tab
			replace res_test  ="2 parmi (36 37 46 52)" 	if _n==`ligne'
			replace res_se	  =$se  * 100				if _n==`ligne'
			replace res_sp	  =$sp  * 100				if _n==`ligne'
			replace res_vpp	  =$vpp * 100 				if _n==`ligne'
			replace res_vpn	  =$vpn * 100 				if _n==`ligne'
			replace res_kappa =$kappa 			if _n==`ligne'
			replace res_kappa_stderr = `r(se)' 	if _n==`ligne'
			replace res_bi	  =$bi 				if _n==`ligne'
			replace res_pi	  =$pi 				if _n==`ligne'
			replace res_pabak =$pabak			if _n==`ligne'
			replace res_ppos  =$ppos 			if _n==`ligne'
			replace res_pneg  =$pneg 			if _n==`ligne'
	local ligne = `ligne'+1
	drop tp_res
}	

{	// 1 res positif parmi 4 res luminex (1 combinaison)
local ligne 34
gen tp_res = luminex_s1_histag36 + luminex_s2_histag37 + luminex_s1_shfctag46 + luminex_s2_shfctag52
	recode tp_res (1=1) (2=1) (3=1) (4=1)
		display  "Test Luminex® 1 parmi (36 37 46 52) vs Elisa - Séroprévalence Ac anti-S"
			display ""
	quietly tab tp_res elisa_s, matcell(tableau)
	evaluation tableau[2,2] tableau[2,1] tableau[1,2] tableau[1,1] 
	kap tp_res elisa_s, tab
			replace res_test  ="1 parmi (36 37 46 52)" 	if _n==`ligne'
			replace res_se	  =$se  * 100				if _n==`ligne'
			replace res_sp	  =$sp  * 100				if _n==`ligne'
			replace res_vpp	  =$vpp * 100 				if _n==`ligne'
			replace res_vpn	  =$vpn * 100 				if _n==`ligne'
			replace res_kappa =$kappa 			if _n==`ligne'
			replace res_kappa_stderr = `r(se)' 	if _n==`ligne'
			replace res_bi	  =$bi 				if _n==`ligne'
			replace res_pi	  =$pi 				if _n==`ligne'
			replace res_pabak =$pabak			if _n==`ligne'
			replace res_ppos  =$ppos 			if _n==`ligne'
			replace res_pneg  =$pneg 			if _n==`ligne'
	local ligne = `ligne'+1
	drop tp_res
}	
		
browse res*


compress
save "01_serologie_0.001.dta", replace
*export excel using "01_serologie.xlsx", firstrow(variables)


