#!/bin/bash

################################################################
#$1: numéro de la partie
#$2: nom du fichier de la partie
#$3: nom de la partie
initialisation () {
	numPartie=$1
	echo "Création de la partie $1"
	mkdir ~/Documents/Cours/Cours_2AE/Statistiques/fiche/exercices/chap/
	mkdir ~/Documents/Cours/Cours_2AE/Statistiques/fiche/exercices/chap/$1chap
	echo "Accès à la partie $1"
	cd ~/Documents/Cours/Cours_2AE/Statistiques/fiche/exercices/chap
	echo "Création du fichier qui centralisera tous les fichiers de la partie $1"
	eval j="$1_$2.tex"
	nomFichierPartie=$j
	echo -e "\\\begin{itemize}\n\t\\\item\n\\\end{itemize}" >> $j
	echo -e "\\\chapter{$3}\n\\\input{./chap/$j}" >> ../statisticalLearningSummaryExos.tex
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
}

initialisation2 () {
	cd ~/Documents/Cours/Cours_2AE/Statistiques/fiche/exercices/chap/${numPartie}chap
	for ((i=0; i<${#chap[@]}; i++))
	do
		#Adaptation du nom des fichiers
		eval j="$((i+1))_${chap[i]}.tex"
		newChap+=("$j")
		echo -e "\\\begin{itemize}\n\t\\\item\n \\\end{itemize}" >> $j
		echo -e "\\\section{${nChap[i]}}\n\\\input{./chap/${numPartie}chap/$j}" >> ../$nomFichierPartie
	done
	echo "+ + + + + + + + + + + + + + + + + + + + + + + + + + + + +"
}


#FONCTION creation
function creation {
	echo "Création de la section '${files[0]}sec'"
	mkdir ~/Documents/Cours/Cours_2AE/Statistiques/fiche/exercices/chap/${numPartie}chap/${files[0]}sec
	echo "Accès à la section '${files[0]}sec'"
	cd ~/Documents/Cours/Cours_2AE/Statistiques/fiche/exercices/chap/${numPartie}chap/${files[0]}sec
	echo "Position dans l'arboressence:"
	pwd
	for ((i=1; i<${#files[@]}; i++))
	do
		#Adaptation du nom des fichiers
		eval j="${i}_${files[i]}.tex"
		echo -e "\\\begin{itemize}\n\t\\\item\n \\\end{itemize}" >> $j
		echo -e "\\\subsection{${nFiles[$(($i-1))]}}\n\\\input{./chap/${numPartie}chap/${files[0]}sec/$j}" >> ../${newChap[$((${files[0]}-1))]}
	done
	echo "Affichage de la liste des fichiers crées:"
	ls -l
	echo "=================================================================="
}
