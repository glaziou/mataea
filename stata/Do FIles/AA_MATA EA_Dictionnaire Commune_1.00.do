*********************************************
*   	Projet MATA'EA						*
* Cartographie de l'état de santé de la 	*
* population de la Polynésie française		*
*											*
* 		Fichier A							*
*	Transformation dictionnaire Commune 	*
*											*
*											*
*											*
* auteur : Vincent Mendiboure				*
* dernier update : 17 juin 2022				*
*											*
*********************************************


*cd "Z:\BDD\Stata"
 cd "C:\Users\Mendiboure\Documents\Master PH\Stage Pasteur\image\donnees\Stata"

*import excel using "Z:\BDD\base initiale\Mataea Liste ID Commune.xlsx", firstrow clear
import excel using "C:\Users\Mendiboure\Documents\Master PH\Stage Pasteur\image\donnees\BDD dta tsv xls\base initiale_PAS TOUCHER\Mataea Liste ID Commune.xlsx", firstrow clear

rename IDcommune town_id
rename Île island
rename Archipel archipelago

order town_id
sort town_id

save "Mataea Liste ID Commune.dta", replace
