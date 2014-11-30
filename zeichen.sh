#!/bin/bash
echo "aus pdf:"
echo $(pdftotext main.pdf -enc UTF-8 - | wc -c)
echo ""
echo "mit detex:"
echo ""
echo "hardware.tex"
echo $(detex hardware.tex | wc -c)
echo ""
echo "software.tex"
echo $(detex software.tex | wc -c)
echo ""
echo "einleitung.tex"
echo $(detex einleitung.tex | wc -c)
echo ""
echo "gesamt"
echo $(detex einleitung.tex software.tex hardware.tex| wc -c)
