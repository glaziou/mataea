*****************************************************************************
*   					Projet MATA'EA										*
* 			Cartographie de l'état de santé de la 							*
* 			population de la Polynésie française							*
*																			*
*					 		Fichier 03 H									*
*				   		  ANALYSES LABO										*
*																			*
*																			*
*																			*
* 	auteur : Vincent Mendiboure												*
* 	dernier update : 30 septembre 2022										*
*																			*
*****************************************************************************

*cd "Z:\donnees\Stata"
cd "C:\Users\Mendiboure\Documents\Master PH\Stage Pasteur\image\donnees\Stata"

use "02_MATAEA_final.dta", clear

// suppression des sujets sans prélèvement sanguin
drop if date_prlvt=="NA"

*******************************************************	
**# DEFINITION DES SUJETS SAINS #1 		 	 **********
*******************************************************
{
gen selection_sane =1		// Définition du sous-ensemble des sujets sains 
		quietly tab selection_sane if selection_sane ==1
		display "`r(N)' sujets restant dans la sélection"
		local last=r(N)
	replace selection_sane =0 if hypertension_bool  !=0 	//HTA
		quietly tab selection_sane if selection_sane ==1
		local retires=`last'-`r(N)'
		display "retrait sujets HTA"
		display "`retires' sujets retirés de la sélection"
		display "`r(N)' sujets restant"
		local last=r(N)
	replace selection_sane =0 if diabete_bool 		!=0		// Diabete
		quietly tab selection_sane if selection_sane ==1
		local retires=`last'-`r(N)'
		display "retrait sujets Diabetiques"
		display "`retires' sujets retirés de la sélection"
		display "`r(N)' sujets restant"
		local last=r(N)
	replace selection_sane =0 if obesity_classif_spc >3		// Obesité (SPC)
		display "retrait sujets obèses (classification SPC)"
*		replace selection_sane =0 if obesity_who_bool !=0		
*		display "retrait sujets obèses (classification OMS)"
		quietly tab selection_sane if selection_sane ==1
		local retires=`last'-`r(N)'
		display "`retires' sujets retirés de la sélection"
		display "`r(N)' sujets restant"
		local last=r(N)		
/*	// Obésité abdominale ? seul 36.8% des sujets (n=715) négatifs
	replace selection_sane =0 if obesity_abdo_bool !=0 
		display "retrait sujets avec obésité abdominale"
		quietly tab selection_sane if selection_sane ==1
		local retires=`last'-`r(N)'
		display "`retires' sujets retirés de la sélection"
		display "`r(N)' sujets restant"
		local last=r(N)
*/

/*	replace selection_sane =0 if obesity_classif_who >4 // retrait des Obésités, Classes 2 & 3
		display "retrait sujets obèses Classe 2 et Classe 3 (classification OMS)"
		quietly tab selection_sane if selection_sane ==1
		local retires=`last'-`r(N)'
		display "`retires' sujets retirés de la sélection"
		display "`r(N)' sujets restant"
		local last=r(N)
*/
	// Hypercholestérolémie ?
	replace selection_sane =0 if hypercholesterolemia_bool !=0	// Hypercholesterolémie
		quietly tab selection_sane if selection_sane ==1
		local retires=`last'-`r(N)'
		display "retrait sujets avec hypercholesterolémie"
		display "`retires' sujets retirés de la sélection"
		display "`r(N)' sujets restant"
		local last=r(N)
	replace selection_sane =0 if fib_4_cat ==3 					// Score Fib-4
		quietly tab selection_sane if selection_sane ==1
		local retires=`last'-`r(N)'
		display "retrait sujets avec Fib-4 + (parcours de soin)"
		display "`retires' sujets retirés de la sélection"
		display "`r(N)' sujets restant"
		local last=r(N)
	replace selection_sane =0 if vhb_conclusion ==1				// Portage AgHBs (infectuion en cours VHB)
		quietly tab selection_sane if selection_sane ==1
		local retires=`last'-`r(N)'
		display "retrait sujets porteur AgHBs"
		display "`retires' sujets retirés de la sélection"
		display "`r(N)' sujets restant"
		local last=r(N)
}	
	
*******************************************************	
**# DESCRIPTION DES MARQUEURS BIO BASE ENTIERE #2 *****
*******************************************************
{
sum res_hba1g
sum res_hba1g,d
tab res_hba1g_cat if res_hba1g_cat!=99

sum res_index_idl
sum res_index_idl,d
*tab res_index_idl_cat

sum res_index_idh
sum res_index_idh,d
*tab res_index_idh_cat

sum res_index_idi
sum res_index_idi,d
*tab res_index_idi_cat

sum res_ct
sum res_ct,d
tab res_ct_cat

sum res_tg
sum res_tg,d
tab res_tg_cat

sum res_hdl_hdl
sum res_hdl_hdl,d
tab res_hdl_hdl_cat

sum res_hdl_rcthd
sum res_hdl_rcthd,d
tab res_hdl_rcthd_cat

sum res_ldlc_ldlc
sum res_ldlc_ldlc,d
tab res_ldlc_ldlc_cat

sum res_ldlc_rhdld
sum res_ldlc_rhdld,d
tab res_ldlc_rhdld_cat

tab res_pt2_cat if res_pt2_cat !=99
	* les valeurs "<5" on été codées "-1"
	replace res_pt2=2.5 if res_pt2==-1
	sum res_pt2
	sum res_pt2,d
	replace res_pt2=-1 if res_pt2==2.5

sum res_ot
sum res_ot,d
tab res_ot_cat

sum res_cr
sum res_cr,d
tab res_cr_cat

sum res_dfgf1
sum res_dfgf1,d
tab res_dfgf1_cat

sum res_dfgf2
sum res_dfgf2,d
tab res_dfgf2_cat

sum res_dfgh1
sum res_dfgh1,d
tab res_dfgh1_cat

sum res_dfgh2
sum res_dfgh2,d
tab res_dfgh2_cat

tab res_crp2_cat
	* les valeurs "<0.6" on été codée "-1"
	replace res_crp2=0.3 if res_crp2==-1
	sum res_crp2
	sum res_crp2,d
	replace res_crp2=-1 if res_crp2==0.3

sum res_ggt
sum res_ggt,d
tab res_ggt_cat

sum res_bilt
sum res_bilt,d
tab res_bilt_cat

sum res_asp
sum res_asp,d
*tab res_asp_cat

sum res_nfp2_nfrem
sum res_nfp2_nfrem,d
*tab res_nfp2_nfrem_cat

sum res_nfp2_gr
sum res_nfp2_gr,d
tab res_nfp2_gr_cat

sum res_nfp2_hb
sum res_nfp2_hb,d
tab res_nfp2_hb_cat

sum res_nfp2_ht
sum res_nfp2_ht,d
tab res_nfp2_ht_cat

sum res_nfp2_vgm
sum res_nfp2_vgm,d
tab res_nfp2_vgm_cat

sum res_nfp2_vgmc
sum res_nfp2_vgmc,d
*tab res_nfp2_vgmc_cat

sum res_nfp2_tcmh
sum res_nfp2_tcmh,d
tab res_nfp2_tcmh_cat

sum res_nfp2_ccmhc
sum res_nfp2_ccmhc,d
tab res_nfp2_ccmhc_cat

sum res_nfp2_idr
sum res_nfp2_idr,d
*tab res_nfp2_idr_cat

sum res_nfp2_idrc
sum res_nfp2_idrc,d
*tab res_nfp2_idrc_cat

sum res_nfp2_pla2
sum res_nfp2_pla2,d
tab res_nfp2_pla2_cat if res_nfp2_pla2_cat!=99

sum res_nfp2_vpm
sum res_nfp2_vpm,d
tab res_nfp2_vpm_cat

sum res_nfp2_nfmic
sum res_nfp2_nfmic,d
*tab res_nfp2_nfmic_cat

sum res_nfp2_gb
sum res_nfp2_gb,d
tab res_nfp2_gb_cat

sum res_nfp2_gbcal
sum res_nfp2_gbcal,d
*tab res_nfp2_gbcal_cat

sum res_nfp2_pn
sum res_nfp2_pn,d
*tab res_nfp2_pn_cat

sum res_nfp2_pn3
sum res_nfp2_pn3,d
tab res_nfp2_pn3_cat

sum res_nfp2_pe
sum res_nfp2_pe,d
*tab res_nfp2_pe_cat

sum res_nfp2_pe3
sum res_nfp2_pe3,d
tab res_nfp2_pe3_cat

sum res_nfp2_ly
sum res_nfp2_ly,d
*tab res_nfp2_ly_cat

sum res_nfp2_ly3
sum res_nfp2_ly3,d
tab res_nfp2_ly3_cat

sum res_nfp2_mo
sum res_nfp2_mo,d
*tab res_nfp2_mo_cat

sum res_nfp2_mo3
sum res_nfp2_mo3,d
tab res_nfp2_mo3_cat

sum res_nfp2_clhem
sum res_nfp2_clhem,d
*tab res_nfp2_clhem_cat

sum coser_index
sum coser_index,d
*tab coser_index_cat

sum coser
sum coser,d
*tab coser_cat

tab res_index_idi
tab res_dfgf1_cat
tab res_dfgf2_cat
tab res_dfgh1_cat
tab res_dfgh2_cat
tab res_asp
tab coser if coser!=99
}

**********************************************************
**# ASSOCIATIONS DES MARQUEURS BIO AVEC VARIABLES 		**
** 		MORBIDITES ET COMPORTEMENTALES #3			 	**
**********************************************************
{ // atention changer le code pour écarter les valeurs manquantes sur l'outcome et variables explicatives
tab hypertension_bool res_hba1g_cat 		if hypertension_bool !=99 & res_hba1g_cat!=99, expected chi2 row 
tab diabete_bool res_hba1g_cat  			if diabete_bool !=99 & res_hba1g_cat!=99, expected chi2 row 
tab obesity_who_bool res_hba1g_cat, expected chi2 row 
tab obesity_abdo_bool res_hba1g_cat, expected chi2 row 
tab smoking_everyday_bool res_hba1g_cat 	if res_hba1g_cat!=99, expected chi2 row 
tab paka_last_year_bool res_hba1g_cat, expected chi2 row 
tab paka_weekly_bool res_hba1g_cat, expected chi2 row 
tab alcool_30d_bool res_hba1g_cat, expected chi2 row 
tab alcool_category res_hba1g_cat			if res_hba1g_cat!=99 & alcool_category <10, expected chi2 row 
tab reco_fruit_vege res_hba1g_cat  if res_hba1g_cat !=99 & reco_fruit_vege!=99, expected chi2 row 
tab phys_act_level res_hba1g_cat, expected chi2 row 
tab cancer_or_malignant_tumor_medica res_hba1g_cat if res_hba1g_cat !=99 & cancer_or_malignant_tumor_medica!=99, expected chi2 row exact
tab covid_test_positif res_hba1g_cat, expected chi2 row 
*tab ciguatera_freq2 res_hba1g_cat, expected chi2 row exact // "exceeded memory limits using exact(1)"
tab ciguatera_freq3 res_hba1g_cat, expected chi2 row

ttest res_index_idl if hypertension_bool !=99, by(hypertension_bool)
ttest res_index_idl, by(diabete_bool)
ttest res_index_idl, by(obesity_who_bool)
ttest res_index_idl, by(obesity_abdo_bool)
ttest res_index_idl, by(smoking_everyday_bool)
ttest res_index_idl, by(paka_last_year_bool)
ttest res_index_idl, by(paka_weekly_bool)
ttest res_index_idl, by(alcool_30d_bool)
kwallis res_index_idl, by(alcool_category)
ttest res_index_idl, by(reco_fruit_vege)
kwallis res_index_idl, by(phys_act_level)
ttest res_index_idl, by(cancer_or_malignant_tumor_medica)
ttest res_index_idl, by(covid_test_positif)
kwallis res_index_idl, by(ciguatera_freq2)
kwallis res_index_idl, by(ciguatera_freq3)

ttest res_index_idh if hypertension_bool !=99, by(hypertension_bool)
ttest res_index_idh, by(diabete_bool)
ttest res_index_idh, by(obesity_who_bool)
ttest res_index_idh, by(obesity_abdo_bool)
ttest res_index_idh, by(smoking_everyday_bool)
ttest res_index_idh, by(paka_last_year_bool)
ttest res_index_idh, by(paka_weekly_bool)
ttest res_index_idh, by(alcool_30d_bool)
kwallis res_index_idh, by(alcool_category)
ttest res_index_idh, by(reco_fruit_vege)
kwallis res_index_idh, by(phys_act_level)
ttest res_index_idh, by(cancer_or_malignant_tumor_medica)
ttest res_index_idh, by(covid_test_positif)
kwallis res_index_idh, by(ciguatera_freq2)
kwallis res_index_idh, by(ciguatera_freq3)

ttest res_index_idi  if hypertension_bool !=99, by(hypertension_bool)
ttest res_index_idi, by(diabete_bool)
ttest res_index_idi, by(obesity_who_bool)
ttest res_index_idi, by(obesity_abdo_bool)
ttest res_index_idi, by(smoking_everyday_bool)
ttest res_index_idi, by(paka_last_year_bool)
ttest res_index_idi, by(paka_weekly_bool)
ttest res_index_idi, by(alcool_30d_bool)
kwallis res_index_idi, by(alcool_category)
ttest res_index_idi, by(reco_fruit_vege)
kwallis res_index_idi, by(phys_act_level)
ttest res_index_idi, by(cancer_or_malignant_tumor_medica)
ttest res_index_idi, by(covid_test_positif)
kwallis res_index_idi, by(ciguatera_freq2)
kwallis res_index_idi, by(ciguatera_freq3)

tab hypertension_bool res_ct_cat if hypertension_bool !=99, expected chi2 row 
tab diabete_bool res_ct_cat, expected chi2 row 
tab obesity_who_bool res_ct_cat, expected chi2 row 
tab obesity_abdo_bool res_ct_cat, expected chi2 row 
tab smoking_everyday_bool res_ct_cat, expected chi2 row 
tab paka_last_year_bool res_ct_cat, expected chi2 row 
tab paka_weekly_bool res_ct_cat, expected chi2 row 
tab alcool_30d_bool res_ct_cat, expected chi2 row 
tab alcool_category res_ct_cat, expected chi2 row 
tab reco_fruit_vege res_ct_cat, expected chi2 row 
tab phys_act_level res_ct_cat, expected chi2 row 
tab cancer_or_malignant_tumor_medica res_ct_cat, expected chi2 row 
tab covid_test_positif res_ct_cat, expected chi2 row 
*tab ciguatera_freq2 res_ct_cat, expected chi2 row exact
tab ciguatera_freq3 res_ct_cat, expected chi2 row

tab hypertension_bool res_tg_cat if hypertension_bool !=99, expected chi2 row exact
tab diabete_bool res_tg_cat, expected chi2 row exact
tab obesity_who_bool res_tg_cat, expected chi2 row exact
tab obesity_abdo_bool res_tg_cat, expected chi2 row exact
tab smoking_everyday_bool res_tg_cat, expected chi2 row exact
tab paka_last_year_bool res_tg_cat, expected chi2 row exact
tab paka_weekly_bool res_tg_cat, expected chi2 row exact
tab alcool_30d_bool res_tg_cat, expected chi2 row exact
tab alcool_category res_tg_cat, expected chi2 row exact
tab reco_fruit_vege res_tg_cat, expected chi2 row exact
tab phys_act_level res_tg_cat, expected chi2 row exact
tab cancer_or_malignant_tumor_medica res_tg_cat, expected chi2 row exact
tab covid_test_positif res_tg_cat, expected chi2 row exact
tab ciguatera_freq2 res_tg_cat, expected chi2 row exact
tab ciguatera_freq3 res_tg_cat, expected chi2 row

tab hypertension_bool res_hdl_hdl_cat if hypertension_bool !=99, expected chi2 row 
tab diabete_bool res_hdl_hdl_cat, expected chi2 row exact
tab obesity_who_bool res_hdl_hdl_cat, expected chi2 row 
tab obesity_abdo_bool res_hdl_hdl_cat, expected chi2 row 
tab smoking_everyday_bool res_hdl_hdl_cat, expected chi2 row 
tab paka_last_year_bool res_hdl_hdl_cat, expected chi2 row 
tab paka_weekly_bool res_hdl_hdl_cat, expected chi2 row 
tab alcool_30d_bool res_hdl_hdl_cat, expected chi2 row 
tab alcool_category res_hdl_hdl_cat, expected chi2 row 
tab reco_fruit_vege res_hdl_hdl_cat, expected chi2 row 
tab phys_act_level res_hdl_hdl_cat, expected chi2 row 
tab cancer_or_malignant_tumor_medica res_hdl_hdl_cat, expected chi2 row exact
tab covid_test_positif res_hdl_hdl_cat, expected chi2 row 
*tab ciguatera_freq2 res_hdl_hdl_cat, expected chi2 row exact
tab ciguatera_freq3 res_hdl_hdl_cat, expected chi2 row

tab hypertension_bool res_hdl_rcthd_cat if hypertension_bool !=99, expected chi2 row 
tab diabete_bool res_hdl_rcthd_cat, expected chi2 row 
tab obesity_who_bool res_hdl_rcthd_cat, expected chi2 row 
tab obesity_abdo_bool res_hdl_rcthd_cat, expected chi2 row 
tab smoking_everyday_bool res_hdl_rcthd_cat, expected chi2 row 
tab paka_last_year_bool res_hdl_rcthd_cat, expected chi2 row 
tab paka_weekly_bool res_hdl_rcthd_cat, expected chi2 row 
tab alcool_30d_bool res_hdl_rcthd_cat, expected chi2 row 
tab alcool_category res_hdl_rcthd_cat, expected chi2 row 
tab reco_fruit_vege res_hdl_rcthd_cat, expected chi2 row 
tab phys_act_level res_hdl_rcthd_cat, expected chi2 row 
tab cancer_or_malignant_tumor_medica res_hdl_rcthd_cat, expected chi2 row 
tab covid_test_positif res_hdl_rcthd_cat, expected chi2 row 
tab ciguatera_freq2 res_hdl_rcthd_cat, expected chi2 row exact
tab ciguatera_freq3 res_hdl_rcthd_cat, expected chi2 row

tab hypertension_bool res_ldlc_ldlc_cat if hypertension_bool !=99, expected chi2 row 
tab diabete_bool res_ldlc_ldlc_cat, expected chi2 row 
tab obesity_who_bool res_ldlc_ldlc_cat, expected chi2 row 
tab obesity_abdo_bool res_ldlc_ldlc_cat, expected chi2 row 
tab smoking_everyday_bool res_ldlc_ldlc_cat, expected chi2 row 
tab paka_last_year_bool res_ldlc_ldlc_cat, expected chi2 row 
tab paka_weekly_bool res_ldlc_ldlc_cat, expected chi2 row 
tab alcool_30d_bool res_ldlc_ldlc_cat, expected chi2 row 
tab alcool_category res_ldlc_ldlc_cat, expected chi2 row 
tab reco_fruit_vege res_ldlc_ldlc_cat, expected chi2 row 
tab phys_act_level res_ldlc_ldlc_cat, expected chi2 row 
tab cancer_or_malignant_tumor_medica res_ldlc_ldlc_cat, expected chi2 row 
tab covid_test_positif res_ldlc_ldlc_cat, expected chi2 row 
*tab ciguatera_freq2 res_ldlc_ldlc_cat, expected chi2 row exact
tab ciguatera_freq3 res_ldlc_ldlc_cat, expected chi2 row

tab hypertension_bool res_ldlc_rhdld_cat if hypertension_bool !=99, expected chi2 row 
tab diabete_bool res_ldlc_rhdld_cat, expected chi2 row 
tab obesity_who_bool res_ldlc_rhdld_cat, expected chi2 row 
tab obesity_abdo_bool res_ldlc_rhdld_cat, expected chi2 row 
tab smoking_everyday_bool res_ldlc_rhdld_cat, expected chi2 row 
tab paka_last_year_bool res_ldlc_rhdld_cat, expected chi2 row 
tab paka_weekly_bool res_ldlc_rhdld_cat, expected chi2 row 
tab alcool_30d_bool res_ldlc_rhdld_cat, expected chi2 row 
tab alcool_category res_ldlc_rhdld_cat, expected chi2 row 
tab reco_fruit_vege res_ldlc_rhdld_cat, expected chi2 row 
tab phys_act_level res_ldlc_rhdld_cat, expected chi2 row 
tab cancer_or_malignant_tumor_medica res_ldlc_rhdld_cat, expected chi2 row 
tab covid_test_positif res_ldlc_rhdld_cat, expected chi2 row 
tab ciguatera_freq2 res_ldlc_rhdld_cat, expected chi2 row exact
tab ciguatera_freq3 res_ldlc_rhdld_cat, expected chi2 row

tab hypertension_bool res_pt2_cat if hypertension_bool !=99, expected chi2 row 
tab diabete_bool res_pt2_cat, expected chi2 row 
tab obesity_who_bool res_pt2_cat, expected chi2 row 
tab obesity_abdo_bool res_pt2_cat, expected chi2 row 
tab smoking_everyday_bool res_pt2_cat, expected chi2 row 
tab paka_last_year_bool res_pt2_cat, expected chi2 row 
tab paka_weekly_bool res_pt2_cat, expected chi2 row 
tab alcool_30d_bool res_pt2_cat, expected chi2 row 
tab alcool_category res_pt2_cat, expected chi2 row 
tab reco_fruit_vege res_pt2_cat, expected chi2 row 
tab phys_act_level res_pt2_cat, expected chi2 row 
tab cancer_or_malignant_tumor_medica res_pt2_cat, expected chi2 row 
tab covid_test_positif res_pt2_cat, expected chi2 row 
tab ciguatera_freq2 res_pt2_cat, expected chi2 row exact
tab ciguatera_freq3 res_pt2_cat, expected chi2 row

tab hypertension_bool res_ot_cat if hypertension_bool !=99, expected chi2 row 
tab diabete_bool res_ot_cat, expected chi2 row 
tab obesity_who_bool res_ot_cat, expected chi2 row 
tab obesity_abdo_bool res_ot_cat, expected chi2 row 
tab smoking_everyday_bool res_ot_cat, expected chi2 row 
tab paka_last_year_bool res_ot_cat, expected chi2 row 
tab paka_weekly_bool res_ot_cat, expected chi2 row 
tab alcool_30d_bool res_ot_cat, expected chi2 row 
tab alcool_category res_ot_cat, expected chi2 row 
tab reco_fruit_vege res_ot_cat, expected chi2 row 
tab phys_act_level res_ot_cat, expected chi2 row 
tab cancer_or_malignant_tumor_medica res_ot_cat, expected chi2 row exact
tab covid_test_positif res_ot_cat, expected chi2 row 
tab ciguatera_freq2 res_ot_cat, expected chi2 row exact
tab ciguatera_freq3 res_ot_cat, expected chi2 row

tab hypertension_bool res_cr_cat if hypertension_bool !=99, expected chi2 row 
tab diabete_bool res_cr_cat, expected chi2 row exact
tab obesity_who_bool res_cr_cat, expected chi2 row 
tab obesity_abdo_bool res_cr_cat, expected chi2 row 
tab smoking_everyday_bool res_cr_cat, expected chi2 row 
tab paka_last_year_bool res_cr_cat, expected chi2 row 
tab paka_weekly_bool res_cr_cat, expected chi2 row 
tab alcool_30d_bool res_cr_cat, expected chi2 row 
tab alcool_category res_cr_cat, expected chi2 row exact
tab reco_fruit_vege res_cr_cat, expected chi2 row 
tab phys_act_level res_cr_cat, expected chi2 row 
tab cancer_or_malignant_tumor_medica res_cr_cat, expected chi2 row exact
tab covid_test_positif res_cr_cat, expected chi2 row exact
*tab ciguatera_freq2 res_cr_cat, expected chi2 row exact
tab ciguatera_freq3 res_cr_cat, expected chi2 row

tab hypertension_bool res_dfgf1_cat if hypertension_bool !=99, expected chi2 row 
tab diabete_bool res_dfgf1_cat, expected chi2 row 
tab obesity_who_bool res_dfgf1_cat, expected chi2 row 
tab obesity_abdo_bool res_dfgf1_cat, expected chi2 row 
tab smoking_everyday_bool res_dfgf1_cat, expected chi2 row 
tab paka_last_year_bool res_dfgf1_cat, expected chi2 row 
tab paka_weekly_bool res_dfgf1_cat, expected chi2 row 
tab alcool_30d_bool res_dfgf1_cat, expected chi2 row 
tab alcool_category res_dfgf1_cat, expected chi2 row 
tab reco_fruit_vege res_dfgf1_cat, expected chi2 row 
tab phys_act_level res_dfgf1_cat, expected chi2 row 
tab cancer_or_malignant_tumor_medica res_dfgf1_cat, expected chi2 row 
tab covid_test_positif res_dfgf1_cat, expected chi2 row 
tab ciguatera_freq2 res_dfgf1_cat, expected chi2 row exact
tab ciguatera_freq3 res_dfgf1_cat, expected chi2 row

tab hypertension_bool res_dfgf2_cat if hypertension_bool !=99, expected chi2 row exact
tab diabete_bool res_dfgf2_cat, expected chi2 row  exact
tab obesity_who_bool res_dfgf2_cat, expected chi2 row  exact
tab obesity_abdo_bool res_dfgf2_cat, expected chi2 row  exact
tab smoking_everyday_bool res_dfgf2_cat, expected chi2 row  exact
tab paka_last_year_bool res_dfgf2_cat, expected chi2 row  exact
tab paka_weekly_bool res_dfgf2_cat, expected chi2 row  exact
tab alcool_30d_bool res_dfgf2_cat, expected chi2 row  exact
tab alcool_category res_dfgf2_cat, expected chi2 row  exact
tab reco_fruit_vege res_dfgf2_cat, expected chi2 row  exact
tab phys_act_level res_dfgf2_cat, expected chi2 row  exact
tab cancer_or_malignant_tumor_medica res_dfgf2_cat, expected chi2 row  exact
tab covid_test_positif res_dfgf2_cat, expected chi2 row  exact
tab ciguatera_freq2 res_dfgf2_cat, expected chi2 row exact
tab ciguatera_freq3 res_dfgf2_cat, expected chi2 row exact

tab hypertension_bool res_dfgh1_cat if hypertension_bool !=99, expected chi2 row exact
tab diabete_bool res_dfgh1_cat, expected chi2 row exact
tab obesity_who_bool res_dfgh1_cat, expected chi2 row exact
tab obesity_abdo_bool res_dfgh1_cat, expected chi2 row exact
tab smoking_everyday_bool res_dfgh1_cat, expected chi2 row exact
tab paka_last_year_bool res_dfgh1_cat, expected chi2 row exact
tab paka_weekly_bool res_dfgh1_cat, expected chi2 row exact
tab alcool_30d_bool res_dfgh1_cat, expected chi2 row exact
tab alcool_category res_dfgh1_cat, expected chi2 row exact
tab reco_fruit_vege res_dfgh1_cat, expected chi2 row exact
tab phys_act_level res_dfgh1_cat, expected chi2 row exact
tab cancer_or_malignant_tumor_medica res_dfgh1_cat, expected chi2 row exact
tab covid_test_positif res_dfgh1_cat, expected chi2 row exact
tab ciguatera_freq2 res_dfgh1_cat, expected chi2 row exact
tab ciguatera_freq3 res_dfgh1_cat, expected chi2 row exact

tab hypertension_bool res_dfgh2_cat if hypertension_bool !=99, expected chi2 row exact
tab diabete_bool res_dfgh2_cat, expected chi2 row exact
tab obesity_who_bool res_dfgh2_cat, expected chi2 row exact
tab obesity_abdo_bool res_dfgh2_cat, expected chi2 row exact
tab smoking_everyday_bool res_dfgh2_cat, expected chi2 row exact
tab paka_last_year_bool res_dfgh2_cat, expected chi2 row exact
tab paka_weekly_bool res_dfgh2_cat, expected chi2 row exact
tab alcool_30d_bool res_dfgh2_cat, expected chi2 row exact
tab alcool_category res_dfgh2_cat, expected chi2 row exact
tab reco_fruit_vege res_dfgh2_cat, expected chi2 row exact
tab phys_act_level res_dfgh2_cat, expected chi2 row exact
tab cancer_or_malignant_tumor_medica res_dfgh2_cat, expected chi2 row exact
tab covid_test_positif res_dfgh2_cat, expected chi2 row exact
*tab ciguatera_freq2 res_dfgh2_cat, expected chi2 row exact
tab ciguatera_freq3 res_dfgh2_cat, expected chi2 row exact

tab hypertension_bool res_crp2_cat if hypertension_bool !=99, expected chi2 row 
tab diabete_bool res_crp2_cat, expected chi2 row 
tab obesity_who_bool res_crp2_cat, expected chi2 row 
tab obesity_abdo_bool res_crp2_cat, expected chi2 row 
tab smoking_everyday_bool res_crp2_cat, expected chi2 row 
tab paka_last_year_bool res_crp2_cat, expected chi2 row 
tab paka_weekly_bool res_crp2_cat, expected chi2 row 
tab alcool_30d_bool res_crp2_cat, expected chi2 row 
tab alcool_category res_crp2_cat, expected chi2 row 
tab reco_fruit_vege res_crp2_cat, expected chi2 row 
tab phys_act_level res_crp2_cat, expected chi2 row 
tab cancer_or_malignant_tumor_medica res_crp2_cat, expected chi2 row 
tab covid_test_positif res_crp2_cat, expected chi2 row 
tab ciguatera_freq2 res_crp2_cat, expected chi2 row exact
tab ciguatera_freq3 res_crp2_cat, expected chi2 row

tab hypertension_bool res_ggt_cat if hypertension_bool !=99, expected chi2 row 
tab diabete_bool res_ggt_cat, expected chi2 row 
tab obesity_who_bool res_ggt_cat, expected chi2 row 
tab obesity_abdo_bool res_ggt_cat, expected chi2 row 
tab smoking_everyday_bool res_ggt_cat, expected chi2 row 
tab paka_last_year_bool res_ggt_cat, expected chi2 row 
tab paka_weekly_bool res_ggt_cat, expected chi2 row 
tab alcool_30d_bool res_ggt_cat, expected chi2 row 
tab alcool_category res_ggt_cat, expected chi2 row 
tab reco_fruit_vege res_ggt_cat, expected chi2 row 
tab phys_act_level res_ggt_cat, expected chi2 row 
tab cancer_or_malignant_tumor_medica res_ggt_cat, expected chi2 row 
tab covid_test_positif res_ggt_cat, expected chi2 row 
tab ciguatera_freq2 res_ggt_cat, expected chi2 row exact
tab ciguatera_freq3 res_ggt_cat, expected chi2 row

tab hypertension_bool res_bilt_cat if hypertension_bool !=99, expected chi2 row 
tab diabete_bool res_bilt_cat, expected chi2 row 
tab obesity_who_bool res_bilt_cat, expected chi2 row 
tab obesity_abdo_bool res_bilt_cat, expected chi2 row 
tab smoking_everyday_bool res_bilt_cat, expected chi2 row 
tab paka_last_year_bool res_bilt_cat, expected chi2 row 
tab paka_weekly_bool res_bilt_cat, expected chi2 row 
tab alcool_30d_bool res_bilt_cat, expected chi2 row 
tab alcool_category res_bilt_cat, expected chi2 row 
tab reco_fruit_vege res_bilt_cat, expected chi2 row 
tab phys_act_level res_bilt_cat, expected chi2 row 
tab cancer_or_malignant_tumor_medica res_bilt_cat, expected chi2 row exact
tab covid_test_positif res_bilt_cat, expected chi2 row 
tab ciguatera_freq2 res_bilt_cat, expected chi2 row exact
tab ciguatera_freq3 res_bilt_cat, expected chi2 row

tab hypertension_bool res_asp if hypertension_bool !=99, expected chi2 row exact
tab diabete_bool res_asp, expected chi2 row exact
tab obesity_who_bool res_asp, expected chi2 row exact
tab obesity_abdo_bool res_asp, expected chi2 row exact
tab smoking_everyday_bool res_asp, expected chi2 row exact
tab paka_last_year_bool res_asp, expected chi2 row exact
tab paka_weekly_bool res_asp, expected chi2 row exact
tab alcool_30d_bool res_asp, expected chi2 row exact
tab alcool_category res_asp, expected chi2 row exact
tab reco_fruit_vege res_asp, expected chi2 row exact
tab phys_act_level res_asp, expected chi2 row exact
tab cancer_or_malignant_tumor_medica res_asp, expected chi2 row exact
tab covid_test_positif res_asp, expected chi2 row exact
*tab ciguatera_freq2 res_asp, expected chi2 row exact
tab ciguatera_freq3 res_asp, expected chi2 row exact

	*res_nfp2_nfrem

tab hypertension_bool res_nfp2_gr_cat if hypertension_bool !=99, expected chi2 row exact
tab diabete_bool res_nfp2_gr_cat, expected chi2 row exact
tab obesity_who_bool res_nfp2_gr_cat, expected chi2 row exact
tab obesity_abdo_bool res_nfp2_gr_cat, expected chi2 row exact
tab smoking_everyday_bool res_nfp2_gr_cat, expected chi2 row exact
tab paka_last_year_bool res_nfp2_gr_cat, expected chi2 row exact
tab paka_weekly_bool res_nfp2_gr_cat, expected chi2 row exact
tab alcool_30d_bool res_nfp2_gr_cat, expected chi2 row exact
tab alcool_category res_nfp2_gr_cat, expected chi2 row exact
tab reco_fruit_vege res_nfp2_gr_cat, expected chi2 row exact
tab phys_act_level res_nfp2_gr_cat, expected chi2 row exact
tab cancer_or_malignant_tumor_medica res_nfp2_gr_cat, expected chi2 row exact
tab covid_test_positif res_nfp2_gr_cat, expected chi2 row exact
*tab ciguatera_freq2 res_nfp2_gr_cat, expected chi2 row exact
tab ciguatera_freq3 res_nfp2_gr_cat, expected chi2 row exact

tab hypertension_bool res_nfp2_hb_cat if hypertension_bool !=99, expected chi2 row 
tab diabete_bool res_nfp2_hb_cat, expected chi2 row exact
tab obesity_who_bool res_nfp2_hb_cat, expected chi2 row 
tab obesity_abdo_bool res_nfp2_hb_cat, expected chi2 row 
tab smoking_everyday_bool res_nfp2_hb_cat, expected chi2 row 
tab paka_last_year_bool res_nfp2_hb_cat, expected chi2 row 
tab paka_weekly_bool res_nfp2_hb_cat, expected chi2 row 
tab alcool_30d_bool res_nfp2_hb_cat, expected chi2 row 
tab alcool_category res_nfp2_hb_cat, expected chi2 row 
tab reco_fruit_vege res_nfp2_hb_cat, expected chi2 row 
tab phys_act_level res_nfp2_hb_cat, expected chi2 row 
tab cancer_or_malignant_tumor_medica res_nfp2_hb_cat, expected chi2 row exact
tab covid_test_positif res_nfp2_hb_cat, expected chi2 row exact
*tab ciguatera_freq2 res_nfp2_hb_cat, expected chi2 row exact
tab ciguatera_freq3 res_nfp2_hb_cat, expected chi2 row exact

tab hypertension_bool res_nfp2_ht_cat if hypertension_bool !=99, expected chi2 row 
tab diabete_bool res_nfp2_ht_cat, expected chi2 row exact
tab obesity_who_bool res_nfp2_ht_cat, expected chi2 row 
tab obesity_abdo_bool res_nfp2_ht_cat, expected chi2 row 
tab smoking_everyday_bool res_nfp2_ht_cat, expected chi2 row 
tab paka_last_year_bool res_nfp2_ht_cat, expected chi2 row 
tab paka_weekly_bool res_nfp2_ht_cat, expected chi2 row 
tab alcool_30d_bool res_nfp2_ht_cat, expected chi2 row 
tab alcool_category res_nfp2_ht_cat, expected chi2 row 
tab reco_fruit_vege res_nfp2_ht_cat, expected chi2 row 
tab phys_act_level res_nfp2_ht_cat, expected chi2 row 
tab cancer_or_malignant_tumor_medica res_nfp2_ht_cat, expected chi2 row exact
tab covid_test_positif res_nfp2_ht_cat, expected chi2 row 
*tab ciguatera_freq2 res_nfp2_ht_cat, expected chi2 row exact
tab ciguatera_freq3 res_nfp2_ht_cat, expected chi2 row

tab hypertension_bool res_nfp2_vgm_cat if hypertension_bool !=99, expected chi2 row 
tab diabete_bool res_nfp2_vgm_cat, expected chi2 row exact
tab obesity_who_bool res_nfp2_vgm_cat, expected chi2 row 
tab obesity_abdo_bool res_nfp2_vgm_cat, expected chi2 row 
tab smoking_everyday_bool res_nfp2_vgm_cat, expected chi2 row 
tab paka_last_year_bool res_nfp2_vgm_cat, expected chi2 row 
tab paka_weekly_bool res_nfp2_vgm_cat, expected chi2 row exact
tab alcool_30d_bool res_nfp2_vgm_cat, expected chi2 row 
tab alcool_category res_nfp2_vgm_cat, expected chi2 row exact
tab reco_fruit_vege res_nfp2_vgm_cat, expected chi2 row exact
tab phys_act_level res_nfp2_vgm_cat, expected chi2 row 
tab cancer_or_malignant_tumor_medica res_nfp2_vgm_cat, expected chi2 row exact
tab covid_test_positif res_nfp2_vgm_cat, expected chi2 row exact
tab ciguatera_freq2 res_nfp2_vgm_cat, expected chi2 row exact
tab ciguatera_freq3 res_nfp2_vgm_cat, expected chi2 row

ttest res_nfp2_vgmc if hypertension_bool !=99, by(hypertension_bool)
ttest res_nfp2_vgmc, by(diabete_bool)
ttest res_nfp2_vgmc, by(obesity_who_bool)
ttest res_nfp2_vgmc, by(obesity_abdo_bool)
ttest res_nfp2_vgmc, by(smoking_everyday_bool)
ttest res_nfp2_vgmc, by(paka_last_year_bool)
ttest res_nfp2_vgmc, by(paka_weekly_bool)
ttest res_nfp2_vgmc, by(alcool_30d_bool)
kwallis res_nfp2_vgmc, by(alcool_category)
ttest res_nfp2_vgmc, by(reco_fruit_vege)
kwallis res_nfp2_vgmc, by(phys_act_level)
ttest res_nfp2_vgmc, by(cancer_or_malignant_tumor_medica)
ttest res_nfp2_vgmc, by(covid_test_positif)
kwallis res_nfp2_vgmc, by(ciguatera_freq2)
kwallis res_nfp2_vgmc, by(ciguatera_freq3)

tab hypertension_bool res_nfp2_tcmh_cat, expected chi2 row 
tab diabete_bool res_nfp2_tcmh_cat, expected chi2 row 
tab obesity_who_bool res_nfp2_tcmh_cat, expected chi2 row 
tab obesity_abdo_bool res_nfp2_tcmh_cat, expected chi2 row 
tab smoking_everyday_bool res_nfp2_tcmh_cat, expected chi2 row 
tab paka_last_year_bool res_nfp2_tcmh_cat, expected chi2 row 
tab paka_weekly_bool res_nfp2_tcmh_cat, expected chi2 row 
tab alcool_30d_bool res_nfp2_tcmh_cat, expected chi2 row 
tab alcool_category res_nfp2_tcmh_cat, expected chi2 row 
tab reco_fruit_vege res_nfp2_tcmh_cat, expected chi2 row 
tab phys_act_level res_nfp2_tcmh_cat, expected chi2 row 
tab cancer_or_malignant_tumor_medica res_nfp2_tcmh_cat, expected chi2 row exact
tab covid_test_positif res_nfp2_tcmh_cat, expected chi2 row 
*tab ciguatera_freq2 res_nfp2_tcmh_cat, expected chi2 row exact
tab ciguatera_freq3 res_nfp2_tcmh_cat, expected chi2 row

tab hypertension_bool 		res_nfp2_ccmhc_cat, expected chi2 row 
tab diabete_bool 			res_nfp2_ccmhc_cat, expected chi2 row exact
tab obesity_who_bool 		res_nfp2_ccmhc_cat, expected chi2 row 
tab obesity_abdo_bool 		res_nfp2_ccmhc_cat, expected chi2 row 
tab smoking_everyday_bool 	res_nfp2_ccmhc_cat, expected chi2 row 
tab paka_last_year_bool 	res_nfp2_ccmhc_cat, expected chi2 row 
tab paka_weekly_bool 		res_nfp2_ccmhc_cat, expected chi2 row 
tab alcool_30d_bool 		res_nfp2_ccmhc_cat, expected chi2 row 
tab alcool_category 		res_nfp2_ccmhc_cat, expected chi2 row exact
tab reco_fruit_vege 		res_nfp2_ccmhc_cat, expected chi2 row 
tab phys_act_level 			res_nfp2_ccmhc_cat, expected chi2 row 
tab cancer_or_malignant_tumor_medica res_nfp2_ccmhc_cat, expected chi2 row exact
tab covid_test_positif 		res_nfp2_ccmhc_cat, expected chi2 row exact
*tab ciguatera_freq2 res_nfp2_ccmhc_cat, expected chi2 row exact
tab ciguatera_freq3 res_nfp2_ccmhc_cat, expected chi2 row

ttest res_nfp2_idr if hypertension_bool !=99, by(hypertension_bool)
ttest res_nfp2_idr, by(diabete_bool)
ttest res_nfp2_idr, by(obesity_who_bool)
ttest res_nfp2_idr, by(obesity_abdo_bool)
ttest res_nfp2_idr, by(smoking_everyday_bool)
ttest res_nfp2_idr, by(paka_last_year_bool)
ttest res_nfp2_idr, by(paka_weekly_bool)
ttest res_nfp2_idr, by(alcool_30d_bool)
kwallis res_nfp2_idr, by(alcool_category)
ttest res_nfp2_idr, by(reco_fruit_vege)
kwallis res_nfp2_idr, by(phys_act_level)
ttest res_nfp2_idr, by(cancer_or_malignant_tumor_medica)
ttest res_nfp2_idr, by(covid_test_positif)
kwallis res_nfp2_idr, by(ciguatera_freq2)
kwallis res_nfp2_idr, by(ciguatera_freq3)

ttest res_nfp2_idrc if hypertension_bool !=99, by(hypertension_bool)
ttest res_nfp2_idrc, by(diabete_bool)
ttest res_nfp2_idrc, by(obesity_who_bool)
ttest res_nfp2_idrc, by(obesity_abdo_bool)
ttest res_nfp2_idrc, by(smoking_everyday_bool)
ttest res_nfp2_idrc, by(paka_last_year_bool)
ttest res_nfp2_idrc, by(paka_weekly_bool)
ttest res_nfp2_idrc, by(alcool_30d_bool)
kwallis res_nfp2_idrc, by(alcool_category)
ttest res_nfp2_idrc, by(reco_fruit_vege)
kwallis res_nfp2_idrc, by(phys_act_level)
ttest res_nfp2_idrc, by(cancer_or_malignant_tumor_medica)
ttest res_nfp2_idrc, by(covid_test_positif)
kwallis res_nfp2_idrc, by(ciguatera_freq2)
kwallis res_nfp2_idrc, by(ciguatera_freq3)

tab hypertension_bool res_nfp2_pla2_cat 	if res_nfp2_pla2_cat!=99 & hypertension_bool 	!=99, expected chi2 row exact
tab diabete_bool res_nfp2_pla2_cat			if res_nfp2_pla2_cat!=99 & diabete_bool			!=99, expected chi2 row exact
tab obesity_who_bool res_nfp2_pla2_cat		if res_nfp2_pla2_cat!=99 & obesity_who_bool		!=99, expected chi2 row exact
tab obesity_abdo_bool res_nfp2_pla2_cat		if res_nfp2_pla2_cat!=99 & obesity_abdo_bool 	!=99, expected chi2 row exact
tab smoking_everyday_bool res_nfp2_pla2_cat if res_nfp2_pla2_cat!=99 & smoking_everyday_bool !=99, expected chi2 row exact
tab paka_last_year_bool res_nfp2_pla2_cat	if res_nfp2_pla2_cat!=99 & paka_last_year_bool 	!=99, expected chi2 row exact
tab paka_weekly_bool res_nfp2_pla2_cat		if res_nfp2_pla2_cat!=99 & paka_weekly_bool 	!=99, expected chi2 row exact
tab alcool_30d_bool res_nfp2_pla2_cat		if res_nfp2_pla2_cat!=99 & alcool_30d_bool 		!=99, expected chi2 row exact
tab alcool_category res_nfp2_pla2_cat		if res_nfp2_pla2_cat!=99 & alcool_category 		<10, expected chi2 row exact
tab reco_fruit_vege res_nfp2_pla2_cat		if res_nfp2_pla2_cat!=99 & reco_fruit_vege 		!=99, expected chi2 row exact
tab phys_act_level res_nfp2_pla2_cat		if res_nfp2_pla2_cat!=99 & phys_act_level 		!=99, expected chi2 row exact
tab cancer_or_malignant_tumor_medica res_nfp2_pla2_cat if res_nfp2_pla2_cat!=99 & cancer_or_malignant_tumor_medica !=99, expected chi2 row exact
tab covid_test_positif res_nfp2_pla2_cat	if res_nfp2_pla2_cat!=99 & covid_test_positif 	!=99, expected chi2 row exact
tab ciguatera_freq2 res_nfp2_pla2_cat		if res_nfp2_pla2_cat!=99 & ciguatera_freq2 		!=99, expected chi2 row exact
tab ciguatera_freq3 res_nfp2_pla2_cat		if res_nfp2_pla2_cat!=99 & ciguatera_freq3 		!=99, expected chi2 row exact

tab hypertension_bool res_nfp2_vpm_cat, expected chi2 row 
tab diabete_bool res_nfp2_vpm_cat, expected chi2 row 
tab obesity_who_bool res_nfp2_vpm_cat, expected chi2 row 
tab obesity_abdo_bool res_nfp2_vpm_cat, expected chi2 row 
tab smoking_everyday_bool res_nfp2_vpm_cat, expected chi2 row 
tab paka_last_year_bool res_nfp2_vpm_cat, expected chi2 row 
tab paka_weekly_bool res_nfp2_vpm_cat, expected chi2 row 
tab alcool_30d_bool res_nfp2_vpm_cat, expected chi2 row 
tab alcool_category res_nfp2_vpm_cat, expected chi2 row 
tab reco_fruit_vege res_nfp2_vpm_cat, expected chi2 row 
tab phys_act_level res_nfp2_vpm_cat, expected chi2 row 
tab cancer_or_malignant_tumor_medica res_nfp2_vpm_cat, expected chi2 row 
tab covid_test_positif res_nfp2_vpm_cat, expected chi2 row 
tab ciguatera_freq2 res_nfp2_vpm_cat, expected chi2 row exact
tab ciguatera_freq3 res_nfp2_vpm_cat, expected chi2 row

tab hypertension_bool res_nfp2_nfmic, expected chi2 row 
tab diabete_bool res_nfp2_nfmic, expected chi2 row 
tab obesity_who_bool res_nfp2_nfmic, expected chi2 row 
tab obesity_abdo_bool res_nfp2_nfmic, expected chi2 row 
tab smoking_everyday_bool res_nfp2_nfmic, expected chi2 row 
tab paka_last_year_bool res_nfp2_nfmic, expected chi2 row 
tab paka_weekly_bool res_nfp2_nfmic, expected chi2 row 
tab alcool_30d_bool res_nfp2_nfmic, expected chi2 row 
tab alcool_category res_nfp2_nfmic, expected chi2 row 
tab reco_fruit_vege res_nfp2_nfmic, expected chi2 row 
tab phys_act_level res_nfp2_nfmic, expected chi2 row 
tab cancer_or_malignant_tumor_medica res_nfp2_nfmic, expected chi2 row 
tab covid_test_positif res_nfp2_nfmic, expected chi2 row 
tab ciguatera_freq2 res_nfp2_nfmic, expected chi2 row exact
tab ciguatera_freq3 res_nfp2_nfmic, expected chi2 row

tab hypertension_bool 		res_nfp2_gb_cat, expected chi2 row 
tab diabete_bool 			res_nfp2_gb_cat, expected chi2 row exact
tab obesity_who_bool 		res_nfp2_gb_cat, expected chi2 row 
tab obesity_abdo_bool 		res_nfp2_gb_cat, expected chi2 row 
tab smoking_everyday_bool 	res_nfp2_gb_cat, expected chi2 row 
tab paka_last_year_bool 	res_nfp2_gb_cat, expected chi2 row exact
tab paka_weekly_bool 		res_nfp2_gb_cat, expected chi2 row exact
tab alcool_30d_bool 		res_nfp2_gb_cat, expected chi2 row 
tab alcool_category 		res_nfp2_gb_cat, expected chi2 row exact
tab reco_fruit_vege 		res_nfp2_gb_cat, expected chi2 row exact
tab phys_act_level 			res_nfp2_gb_cat, expected chi2 row exact
tab cancer_or_malignant_tumor_medica res_nfp2_gb_cat, expected chi2 row exact
tab covid_test_positif 		res_nfp2_gb_cat, expected chi2 row exact
tab ciguatera_freq2 res_nfp2_gb_cat, expected chi2 row exact
tab ciguatera_freq3 res_nfp2_gb_cat, expected chi2 row

ttest res_nfp2_gbcal if hypertension_bool !=99, by(hypertension_bool)
ttest res_nfp2_gbcal, by(diabete_bool)
ttest res_nfp2_gbcal, by(obesity_who_bool)
ttest res_nfp2_gbcal, by(obesity_abdo_bool)
ttest res_nfp2_gbcal, by(smoking_everyday_bool)
ttest res_nfp2_gbcal, by(paka_last_year_bool)
ttest res_nfp2_gbcal, by(paka_weekly_bool)
ttest res_nfp2_gbcal, by(alcool_30d_bool)
kwallis res_nfp2_gbcal, by(alcool_category)
ttest res_nfp2_gbcal, by(reco_fruit_vege)
kwallis res_nfp2_gbcal, by(phys_act_level)
ttest res_nfp2_gbcal, by(cancer_or_malignant_tumor_medica)
ttest res_nfp2_gbcal, by(covid_test_positif)
kwallis res_nfp2_gbcal, by(ciguatera_freq2)
kwallis res_nfp2_gbcal, by(ciguatera_freq3)

ttest res_nfp2_pn if hypertension_bool !=99, by(hypertension_bool)
ttest res_nfp2_pn, by(diabete_bool)
ttest res_nfp2_pn, by(obesity_who_bool)
ttest res_nfp2_pn, by(obesity_abdo_bool)
ttest res_nfp2_pn, by(smoking_everyday_bool)
ttest res_nfp2_pn, by(paka_last_year_bool)
ttest res_nfp2_pn, by(paka_weekly_bool)
ttest res_nfp2_pn, by(alcool_30d_bool)
kwallis res_nfp2_pn, by(alcool_category)
ttest res_nfp2_pn, by(reco_fruit_vege)
kwallis res_nfp2_pn, by(phys_act_level)
ttest res_nfp2_pn, by(cancer_or_malignant_tumor_medica)
ttest res_nfp2_pn, by(covid_test_positif)
kwallis res_nfp2_pn, by(ciguatera_freq2)
kwallis res_nfp2_pn, by(ciguatera_freq3)

tab hypertension_bool res_nfp2_pn3_cat, expected chi2 row 
tab diabete_bool res_nfp2_pn3_cat, expected chi2 row exact
tab obesity_who_bool res_nfp2_pn3_cat, expected chi2 row 
tab obesity_abdo_bool res_nfp2_pn3_cat, expected chi2 row 
tab smoking_everyday_bool res_nfp2_pn3_cat, expected chi2 row 
tab paka_last_year_bool res_nfp2_pn3_cat, expected chi2 row 
tab paka_weekly_bool res_nfp2_pn3_cat, expected chi2 row 
tab alcool_30d_bool res_nfp2_pn3_cat, expected chi2 row 
tab alcool_category res_nfp2_pn3_cat, expected chi2 row exact
tab reco_fruit_vege res_nfp2_pn3_cat, expected chi2 row 
tab phys_act_level res_nfp2_pn3_cat, expected chi2 row 
tab cancer_or_malignant_tumor_medica res_nfp2_pn3_cat, expected chi2 row exact
tab covid_test_positif res_nfp2_pn3_cat, expected chi2 row exact
tab ciguatera_freq2 res_nfp2_pn3_cat, expected chi2 row exact
tab ciguatera_freq3 res_nfp2_pn3_cat, expected chi2 row

ttest res_nfp2_pe if hypertension_bool !=99, by(hypertension_bool)
ttest res_nfp2_pe, by(diabete_bool)
ttest res_nfp2_pe, by(obesity_who_bool)
ttest res_nfp2_pe, by(obesity_abdo_bool)
ttest res_nfp2_pe, by(smoking_everyday_bool)
ttest res_nfp2_pe, by(paka_last_year_bool)
ttest res_nfp2_pe, by(paka_weekly_bool)
ttest res_nfp2_pe, by(alcool_30d_bool)
kwallis res_nfp2_pe, by(alcool_category)
ttest res_nfp2_pe, by(reco_fruit_vege)
kwallis res_nfp2_pe, by(phys_act_level)
ttest res_nfp2_pe, by(cancer_or_malignant_tumor_medica)
ttest res_nfp2_pe, by(covid_test_positif)
kwallis res_nfp2_pe, by(ciguatera_freq2)
kwallis res_nfp2_pe, by(ciguatera_freq3)

tab hypertension_bool 		res_nfp2_pe3_cat, expected chi2 row exact
tab diabete_bool 			res_nfp2_pe3_cat, expected chi2 row exact
tab obesity_who_bool 		res_nfp2_pe3_cat, expected chi2 row exact
tab obesity_abdo_bool 		res_nfp2_pe3_cat, expected chi2 row exact
tab smoking_everyday_bool 	res_nfp2_pe3_cat, expected chi2 row exact
tab paka_last_year_bool 	res_nfp2_pe3_cat, expected chi2 row exact
tab paka_weekly_bool 		res_nfp2_pe3_cat, expected chi2 row exact
tab alcool_30d_bool 		res_nfp2_pe3_cat, expected chi2 row exact
tab alcool_category 		res_nfp2_pe3_cat, expected chi2 row exact
tab reco_fruit_vege 		res_nfp2_pe3_cat, expected chi2 row exact
tab phys_act_level 			res_nfp2_pe3_cat, expected chi2 row exact
tab cancer_or_malignant_tumor_medica res_nfp2_pe3_cat, expected chi2 row exact
tab covid_test_positif 		res_nfp2_pe3_cat, expected chi2 row exact
tab ciguatera_freq2 res_nfp2_pe3_cat, expected chi2 row exact
tab ciguatera_freq3 res_nfp2_pe3_cat, expected chi2 row exact

ttest res_nfp2_ly if hypertension_bool !=99, by(hypertension_bool)
ttest res_nfp2_ly, by(diabete_bool)
ttest res_nfp2_ly, by(obesity_who_bool)
ttest res_nfp2_ly, by(obesity_abdo_bool)
ttest res_nfp2_ly, by(smoking_everyday_bool)
ttest res_nfp2_ly, by(paka_last_year_bool)
ttest res_nfp2_ly, by(paka_weekly_bool)
ttest res_nfp2_ly, by(alcool_30d_bool)
kwallis res_nfp2_ly, by(alcool_category)
ttest res_nfp2_ly, by(reco_fruit_vege)
kwallis res_nfp2_ly, by(phys_act_level)
ttest res_nfp2_ly, by(cancer_or_malignant_tumor_medica)
ttest res_nfp2_ly, by(covid_test_positif)
kwallis res_nfp2_ly, by(ciguatera_freq2) 
kwallis res_nfp2_ly, by(ciguatera_freq3)

tab hypertension_bool res_nfp2_ly3_cat, expected chi2 row exact
tab diabete_bool res_nfp2_ly3_cat, expected chi2 row exact
tab obesity_who_bool res_nfp2_ly3_cat, expected chi2 row exact
tab obesity_abdo_bool res_nfp2_ly3_cat, expected chi2 row exact
tab smoking_everyday_bool res_nfp2_ly3_cat, expected chi2 row exact
tab paka_last_year_bool res_nfp2_ly3_cat, expected chi2 row exact
tab paka_weekly_bool res_nfp2_ly3_cat, expected chi2 row exact
tab alcool_30d_bool res_nfp2_ly3_cat, expected chi2 row exact
tab alcool_category res_nfp2_ly3_cat, expected chi2 row exact
tab reco_fruit_vege res_nfp2_ly3_cat, expected chi2 row exact
tab phys_act_level res_nfp2_ly3_cat, expected chi2 row exact
tab cancer_or_malignant_tumor_medica res_nfp2_ly3_cat, expected chi2 row exact
tab covid_test_positif res_nfp2_ly3_cat, expected chi2 row exact
tab ciguatera_freq2 res_nfp2_ly3_cat, expected exact chi2 row
tab ciguatera_freq3 res_nfp2_ly3_cat, expected chi2 row exact

ttest res_nfp2_mo if hypertension_bool !=99, by(hypertension_bool)
ttest res_nfp2_mo, by(diabete_bool)
ttest res_nfp2_mo, by(obesity_who_bool)
ttest res_nfp2_mo, by(obesity_abdo_bool)
ttest res_nfp2_mo, by(smoking_everyday_bool)
ttest res_nfp2_mo, by(paka_last_year_bool)
ttest res_nfp2_mo, by(paka_weekly_bool)
ttest res_nfp2_mo, by(alcool_30d_bool)
kwallis res_nfp2_mo, by(alcool_category)
ttest res_nfp2_mo, by(reco_fruit_vege)
kwallis res_nfp2_mo, by(phys_act_level)
ttest res_nfp2_mo, by(cancer_or_malignant_tumor_medica)
ttest res_nfp2_mo, by(covid_test_positif)
kwallis res_nfp2_mo, by(ciguatera_freq2)
kwallis res_nfp2_mo, by(ciguatera_freq3)

tab hypertension_bool 		res_nfp2_mo3_cat, expected chi2 row 
tab diabete_bool 			res_nfp2_mo3_cat, expected chi2 row exact
tab obesity_who_bool 		res_nfp2_mo3_cat, expected chi2 row 
tab obesity_abdo_bool 		res_nfp2_mo3_cat, expected chi2 row 
tab smoking_everyday_bool 	res_nfp2_mo3_cat, expected chi2 row 
tab paka_last_year_bool 	res_nfp2_mo3_cat, expected chi2 row 
tab paka_weekly_bool 		res_nfp2_mo3_cat, expected chi2 row exact
tab alcool_30d_bool 		res_nfp2_mo3_cat, expected chi2 row 
tab alcool_category 		res_nfp2_mo3_cat, expected chi2 row exact
tab reco_fruit_vege 		res_nfp2_mo3_cat, expected chi2 row exact
tab phys_act_level 			res_nfp2_mo3_cat, expected chi2 row 
tab cancer_or_malignant_tumor_medica res_nfp2_mo3_cat, expected chi2 row exact
tab covid_test_positif 		res_nfp2_mo3_cat, expected chi2 row exact
tab ciguatera_freq2 		res_nfp2_mo3_cat, expected chi2 row exact
tab ciguatera_freq3 		res_nfp2_mo3_cat, expected chi2 row exact

*res_nfp2_clhem

ttest coser_index if hypertension_bool !=99, by(hypertension_bool)
ttest coser_index, by(diabete_bool)
ttest coser_index, by(obesity_who_bool)
ttest coser_index, by(obesity_abdo_bool)
ttest coser_index, by(smoking_everyday_bool)
ttest coser_index, by(paka_last_year_bool)
ttest coser_index, by(paka_weekly_bool)
ttest coser_index, by(alcool_30d_bool)
kwallis coser_index, by(alcool_category)
ttest coser_index, by(reco_fruit_vege)
kwallis coser_index, by(phys_act_level)
ttest coser_index, by(cancer_or_malignant_tumor_medica)
ttest coser_index, by(covid_test_positif)
kwallis coser_index, by(ciguatera_freq2)
kwallis coser_index, by(ciguatera_freq3)

tab hypertension_bool 		coser if coser<2, expected chi2 row 
tab diabete_bool 			coser if coser<2, expected chi2 row 
tab obesity_who_bool 		coser if coser<2, expected chi2 row 
tab obesity_abdo_bool 		coser if coser<2, expected chi2 row 
tab smoking_everyday_bool 	coser if coser<2, expected chi2 row 
tab paka_last_year_bool 	coser if coser<2, expected chi2 row 
tab paka_weekly_bool 		coser if coser<2, expected chi2 row 
tab alcool_30d_bool 		coser if coser<2, expected chi2 row 
tab alcool_category 		coser if coser<2, expected chi2 row 
tab reco_fruit_vege 		coser if coser<2, expected chi2 row 
tab phys_act_level 			coser if coser<2, expected chi2 row 
tab cancer_or_malignant_tumor_medica coser if coser<2, expected chi2 row 
tab covid_test_positif 		coser if coser<2, expected chi2 row 
tab ciguatera_freq2 		coser if coser<2, expected chi2 row exact
tab ciguatera_freq3 		coser if coser<2, expected chi2 row

** test res_index_idi traitée comme variable qualitative
tab hypertension_bool res_index_idi, expected chi2 row exact
tab diabete_bool res_index_idi, expected chi2 row exact
tab obesity_who_bool res_index_idi, expected chi2 row exact
tab obesity_abdo_bool res_index_idi, expected chi2 row exact
tab smoking_everyday_bool res_index_idi, expected chi2 row exact
tab paka_last_year_bool res_index_idi, expected chi2 row exact
tab paka_weekly_bool res_index_idi, expected chi2 row exact
tab alcool_30d_bool res_index_idi, expected chi2 row exact
tab alcool_category res_index_idi, expected chi2 row exact
tab reco_fruit_vege res_index_idi, expected chi2 row exact
tab phys_act_level res_index_idi, expected chi2 row exact
tab cancer_or_malignant_tumor_medica res_index_idi, expected chi2 row exact
tab covid_test_positif res_index_idi, expected chi2 row exact
tab ciguatera_freq2 res_index_idi, expected chi2 row exact
tab ciguatera_freq3 res_index_idi, expected chi2 row exact
}

**********************************************************
**# DESCRIPTION SUR SOUS-ENSEMBLE DES SUJETS SAINS #4	**
** 													 	**
**********************************************************

capture drop tp_*

gen tp_var		 =""
gen tp_var_label =""
gen tp_n		 =.
gen tp_moy		 =.
gen tp_med		 =.
gen tp_sd		 =.
gen tp_min		 =.
gen tp_max		 =.
gen tp_n_inf	 =.
gen tp_perc_inf	 =.
gen tp_n_norm	 =.
gen tp_perc_norm =.
gen tp_n_sup	 =.
gen tp_perc_sup	 =.

local varlist hypertension_bool diabete_bool obesity_who_bool obesity_abdo_bool smoking_everyday_bool paka_last_year_bool paka_weekly_bool  alcool_30d_bool alcool_category reco_fruit_vege phys_act_level covid_test_positif ciguatera_freq3
* pb avec cette variable

foreach var in `varlist'{
			gen tp_`var'=.
}

browse tp_*
replace tp_var		 =""
replace tp_var_label =""
replace tp_n		 =.
replace tp_moy		 =.
replace tp_med		 =.
replace tp_sd		 =.
replace tp_min		 =.
replace tp_max		 =.
replace tp_n_inf	 =.
replace tp_perc_inf	 =.
replace tp_n_norm	 =.
replace tp_perc_norm =.
replace tp_n_sup	 =.
replace tp_perc_sup	 =.
			
local ligne	2	
foreach v_lab in res_hba1g res_index_idl  res_index_idh  res_index_idi  res_ct  res_tg  res_hdl_hdl  res_hdl_rcthd  res_ldlc_ldlc res_ldlc_rhdld res_pt2 res_ot res_cr res_dfgf1 res_dfgf2 res_dfgh1 res_dfgh2 res_crp2 res_ggt res_bilt res_asp res_nfp2_gr res_nfp2_hb res_nfp2_ht res_nfp2_vgm res_nfp2_vgmc res_nfp2_tcmh res_nfp2_ccmhc res_nfp2_idr res_nfp2_idrc res_nfp2_pla2 res_nfp2_vpm res_nfp2_gb res_nfp2_gbcal res_nfp2_pn res_nfp2_pn3 res_nfp2_pe res_nfp2_pe3 res_nfp2_ly res_nfp2_ly3 res_nfp2_mo res_nfp2_mo3 coser_index coser {
	replace tp_var	="`v_lab'"	 	if _n==`ligne'
	replace tp_var_label="`: var label `v_lab''"	 if _n==`ligne'
	sum `v_lab' if selection_sane==1, d
		replace tp_n	=r(N)	 	if _n==`ligne'
		replace tp_moy	=r(mean)	if _n==`ligne'
		replace tp_med	=r(p50)		if _n==`ligne'
		replace tp_sd	=r(sd)		if _n==`ligne'
		replace tp_min	=r(min)		if _n==`ligne'
		replace tp_max	=r(max)		if _n==`ligne'
	capture confirm variable `v_lab'_cat // test: variable catégorielle existe ?
dis "balise 2"
	if !_rc { // si la variable catégorielle existe
dis "balise 3"
		tab `v_lab'_cat if selection_sane==1 & `v_lab'_cat !=99 
		local effectif_total=`r(N)'
	
		* Effectifs sous la norme
		quietly tab `v_lab'_cat if selection_sane==1 & `v_lab'_cat ==-1
			replace tp_n_inf	 =`r(N)'					if _n==`ligne'
			replace tp_perc_inf	 =`r(N)'*100/`effectif_total'	if _n==`ligne'
		* Effectifs dans la norme
		quietly tab `v_lab'_cat if selection_sane==1 & `v_lab'_cat ==0
			replace tp_n_norm	 =`r(N)'					if _n==`ligne'
			replace tp_perc_norm =`r(N)'*100/`effectif_total'	if _n==`ligne'
		* Effectifs au-dessus de la norme
		quietly tab `v_lab'_cat if selection_sane==1 & `v_lab'_cat ==1
		replace tp_n_sup	 =`r(N)'					if _n==`ligne'
		replace tp_perc_sup	 =`r(N)'*100/`effectif_total'	if _n==`ligne'
			
		foreach var in `varlist'{	
			{  //tous les expected sont ils supérieurs à 5? (si oui Fisher = 0, sinon Fisher =1)
			levelsof `v_lab'_cat  if  `v_lab'_cat  !=99 & `var' !=99 & selection_sane==1, local(mod_lab)	
				local nb_mod_lab = r(r)	
			levelsof `var' if  `v_lab'_cat  !=99 & `var' !=99 & selection_sane==1, local(mod_var)									
				local nb_mod_var = r(r)	
			quietly estpost tab `var' `v_lab'_cat  if `v_lab'_cat  !=99  & `var' !=99 & selection_sane==1
					matrix pourcent=e(pct)	
			quietly tab `var' `v_lab'_cat  if `v_lab'_cat  !=99  & `var' !=99 & selection_sane==1
				local effectif=r(N)
			local fisher 0
			forvalues i = 1 / `nb_mod_lab' {
				forvalues j = 1 / `nb_mod_var' {
					local expect = pourcent[1,`i' * (`nb_mod_var'+1)] * pourcent[1,`nb_mod_lab' *(`nb_mod_var'+1)+`j'] * `effectif'/10000
					if `expect' <=5 {
						local fisher 1
					}	
				}
			}
			}
			if `fisher'==0 {	// tous les expected supérieurs à 5
				display "`var' vs `v_lab' tous les effectifs supérieurs à 5"
				tab `var' `v_lab'_cat if `v_lab'_cat  !=99 & `var' !=99 & selection_sane==1,  chi2 expected
				replace tp_`var'=r(p) if _n==`ligne'
			}
			else {
				display "`var' vs `v_lab' test fisher exactnécessaire"
*				tab `var' `v_lab'_cat if `v_lab'_cat  !=99 & `var' !=99 & selection_sane==1,  chi2 expected exact
*				replace tp_`var'=r(p_exact) if _n==`ligne'
				replace tp_`var'=9999 if _n==`ligne' //a retirer quand Fisher exact réactivé
			}
		}
	}
	
	else {	// pas de variable catégorielle - ttt de la var quantitative
		foreach var in `varlist' {
			levelsof `var' if  `v_lab' !=. & `var' !=99 & selection_sane==1, local(mod_var)	
				local nb_mod_var = r(r)	
			if `nb_mod_var' ==2 {
*				ttest `v_lab'  if `var' !=99 & selection_sane==1, by(`var')
				replace tp_`var'=r(p) if _n==`ligne'
			}
			else {
				display "`v_lab' vs `var' : test kruskal Wallis nécessaire"
			}
		}
	}
	
	local ligne=`ligne'+1	
}

