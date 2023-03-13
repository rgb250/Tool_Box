#!/bin/bash
cp writting.tex exercises.Rnw
Rscript -e "library(knitr); knit('./exercises.Rnw')"
pdflatex exercises.tex

