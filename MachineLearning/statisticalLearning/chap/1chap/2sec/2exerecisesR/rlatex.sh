#!/bin/bash
cp writting.tex 2exercices.Rnw
Rscript -e "library(knitr); knit('./2exercices.Rnw')"
pdflatex 2exercices.tex
