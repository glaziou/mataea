*********************************************
*   	Projet MATA'EA						*
* Cartographie de l'état de santé de la 	*
* population de la Polynésie française		*
*											*
* 		Fichier B							*
*	Corrections town_name				 	*
*											*
*											*
*											*
* auteur : Vincent Mendiboure				*
* dernier update : 27 juin 2022				*
*											*
*********************************************


cd "Z:\donnees\Stata"

import excel using "Z:\donnees\BDD dta tsv xls\base initiale_PAS TOUCHER\Corrections town_name.xlsx", firstrow clear

save "Corrections town_name.dta", replace