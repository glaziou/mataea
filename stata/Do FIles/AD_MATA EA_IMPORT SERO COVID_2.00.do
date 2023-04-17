*********************************************
*   	Projet MATA'EA						*
* Cartographie de l'état de santé de la 	*
* population de la Polynésie française		*
*											*
* 		Fichier D							*
* IMPORT DONNEES SEROLOGIES COVID LUMINEX 	*
*											*
*											*
*											*
* auteur : Vincent Mendiboure				*
* dernier update : 03 OCTOBRE 2022			*
*											*
*********************************************


*cd "Z:\donnees\Stata"
 cd "C:\Users\Mendiboure\Documents\Master PH\Stage Pasteur\image\donnees\Stata"


*import excel using "Z:\donnees\BDD dta tsv xls\base initiale_PAS TOUCHER\MATAEA_Sero_CoViD_27.09.2022_import.xlsx", firstrow clear
import excel using "C:\Users\Mendiboure\Documents\Master PH\Stage Pasteur\image\donnees\BDD dta tsv xls\base initiale_PAS TOUCHER\MATAEA_Sero_CoViD_30.09.2022_import.xlsx", firstrow clear

list if subjid==""
	drop if subjid=="" // suppression des 2 premières lignes 

duplicates report subjid		// 2 doublons RI0224ILM & TA8030ILM
duplicates list subjid
drop if _n==813 & subjid =="RI0224ILM"
duplicates list subjid
drop if _n==826 & subjid =="TA8030ILM"

gen test_subjid =0
	replace test_subjid = 1 if subjid != tp_subjid2 | subjid != tp_subjid3 
	list subjid tp_subjid2 tp_subjid3  if test_subjid==1 // 2 obs problématiques
/*    +-------------------------------------------+
      |    subjid      tp_subjid2      tp_subjid3 |
      |-------------------------------------------|
 461. | TA8855ILM                       TA8855ILM |
 833. | TA8029ILM   TA8029ILM  QI   TA8029ILM  QI |
      +-------------------------------------------+ */	
* TA8855ILM : OK, erreur dans la case tp_subjid2 du fichier excel
* TA8029ILM : OK
  
 // 1,187 observations
	  
save "IMPORT_DONNEES_SERO_COVID.dta", replace