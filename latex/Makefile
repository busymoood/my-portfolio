# Build LaTeX du CV (remplace l'ancien .vscode/tasks.json — agnostique de l'éditeur)
MAIN   = my_cv
SOURCE = $(MAIN).tex
FLAGS  = -pdf -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=.

.DEFAULT_GOAL := build
.PHONY: build watch clean

build:
	latexmk $(FLAGS) $(SOURCE)

watch:
	latexmk -pvc $(FLAGS) $(SOURCE)

clean:
	latexmk -C $(SOURCE)
