#!/bin/bash

################################################################
#$1: numéro de la partie
#$2: nom du fichier du chapitre
#$3: nom du chapitre 

initialisation2 () {
	mkdir ~/Documents/Cours/Cours_2AE/Statistiques/fiche2/chaps/
	cd ~/Documents/Cours/Cours_2AE/Statistiques/fiche2/chaps/
	#Adaptation du nom des fichiers
	eval j="$2.tex"
	echo -e "\\\chapter{$3}\n\\\input{./chaps/$j}" >> ../statisticalResume.tex
	numPartie=$1
	nomFichier=$j
	echo "+ + + + + + + + + + + + + + + + + + + + + + + + + + + + +"
}


#FONCTION creation
function creation {
	echo "Création de la section '${files[0]}sec'"
	mkdir ~/Documents/Cours/Cours_2AE/Statistiques/fiche2/chaps/${files[0]}sec
	echo "Accès à la section '${files[0]}sec'"
	cd ~/Documents/Cours/Cours_2AE/Statistiques/fiche2/chaps/${files[0]}sec
	echo "Position dans l'arboressence:"
	pwd
	for ((i=1; i<${#files[@]}; i++))
	do
		#Adaptation du nom des fichiers
		eval j="${i}_${files[i]}.tex"
		echo -e "\\\begin{itemize}\n\t\\\item\n\\\end{itemize}" >> $j
		echo -e "\\\section{${nFiles[$(($i-1))]}}\n\\\input{./chaps/${files[0]}sec/$j}" >> ../$nomFichier
	done
	echo "Affichage de la liste des fichiers crées:"
	ls -l
	echo "=================================================================="
}
