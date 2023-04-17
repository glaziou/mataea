*********************************************
*   	Projet MATA'EA						*
* Cartographie de l'état de santé de la 	*
* population de la Polynésie française		*
*											*
* 		Fichier C							*
*	Classification des Communes				*
*											*
*											*
*											*
* auteur : Vincent Mendiboure				*
* dernier update : 08 aout 2022				*
*											*
*********************************************


*cd "Z:\donnees\Stata"
cd "C:\Users\Mendiboure\Documents\Master PH\Stage Pasteur\image\donnees\Stata"

*import excel using "Z:\donnees\BDD dta tsv xls\base initiale_PAS TOUCHER\\Mataea Classification Communes.xlsx", firstrow clear

import excel using "C:\Users\Mendiboure\Documents\Master PH\Stage Pasteur\image\donnees\BDD dta tsv xls\base initiale_PAS TOUCHER\Mataea Classification Communes.xlsx", firstrow clear


save "Mataea town clustering.dta", replace
