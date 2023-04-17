*****************************************************************************
*   					Projet MATA'EA										*
* 			Cartographie de l'état de santé de la 							*
* 			population de la Polynésie française							*
*																			*
*					 		Fichier 03 G									*
*				   		  ANALYSES CANCER									*
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

tab cancer_or_malignant_tumor_medica, m
tab gender cancer_or_malignant_tumor_medica if cancer_or_malignant_tumor_medica !="Dont know", chi2 expected row

tab cancer_type gender if cancer_type !="Dont know" & cancer_type !="NA"

tab cancer_type_prec if cancer_type_prec!="NA" & cancer_type_prec!="Dont remember"








