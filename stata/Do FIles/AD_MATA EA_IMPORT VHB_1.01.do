*********************************************
*   	Projet MATA'EA						*
* Cartographie de l'état de santé de la 	*
* population de la Polynésie française		*
*											*
* 		Fichier D							*
*	IMPORT DONNEES VHB					 	*
*											*
*											*
*											*
* auteur : Vincent Mendiboure				*
* dernier update : 27 SEPT 2022				*
*											*
*********************************************


*cd "Z:\donnees\Stata"
 cd "C:\Users\Mendiboure\Documents\Master PH\Stage Pasteur\image\donnees\Stata"


*import excel using "Z:\donnees\BDD dta tsv xls\base initiale_PAS TOUCHER\MATAEA_HepB_30.08.2022_import.xlsx", firstrow clear
import excel using "C:\Users\Mendiboure\Documents\Master PH\Stage Pasteur\image\donnees\BDD dta tsv xls\base initiale_PAS TOUCHER\MATAEA_HepB_19.09.2022_import.xlsx", firstrow clear

save "IMPORT_DONNEES_VHB.dta", replace