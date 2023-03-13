#!/bin/bash
cp 4writting.tex 4Exercises.Rnw
Rscript -e "library(knitr); knit('./4Exercises.Rnw')"
pdflatex 4Exercises.tex

