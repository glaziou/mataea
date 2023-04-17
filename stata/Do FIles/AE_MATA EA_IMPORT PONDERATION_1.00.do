*********************************************
*   	Projet MATA'EA						*
* Cartographie de l'état de santé de la 	*
* population de la Polynésie française		*
*											*
* 		Fichier E							*
*	IMPORT PONDERATION	& FPC				*
*											*
*											*
*											*
* auteur : Vincent Mendiboure				*
* dernier update : 25 AOUT 2022				*
*											*
*********************************************


*cd "Z:\donnees\Stata"
 cd "C:\Users\Mendiboure\Documents\Master PH\Stage Pasteur\image\donnees\Stata"


*import excel using "Z:\donnees\BDD dta tsv xls\base initiale_PAS TOUCHER\ponderation_data2017_draft.xlsx", firstrow clear
import excel using "C:\Users\Mendiboure\Documents\Master PH\Stage Pasteur\image\donnees\BDD dta tsv xls\base initiale_PAS TOUCHER\ponderation_data2017_draft.xlsx", firstrow clear

sort archipelago gender age_cat
destring gender,replace
destring age_cat, replace

save "ponderation_draft.dta", replace


*import excel using "Z:\donnees\BDD dta tsv xls\base initiale_PAS TOUCHER\fpc_data2017_draft.xlsx", firstrow clear
import excel using "C:\Users\Mendiboure\Documents\Master PH\Stage Pasteur\image\donnees\BDD dta tsv xls\base initiale_PAS TOUCHER\fpc_data2017_draft.xlsx", firstrow clear

sort island gender age_cat
destring gender,replace
destring age_cat, replace

save "fpc_draft.dta", replace