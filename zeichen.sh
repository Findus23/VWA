#!/bin/bash
echo "aus pdf:"
echo $(pdftotext main.pdf -enc UTF-8 - | wc -m)
echo ""
echo "mit detex:"
echo ""
echo "hardware.tex"
echo $(detex hardware.tex | wc -m)
echo ""
echo "software.tex"
echo $(detex software.tex | wc -m)
echo ""
echo "einleitung.tex"
echo $(detex einleitung.tex | wc -m)
echo ""
echo "weitere_informationen.tex"
echo $(detex weitere_informationen.tex | wc -m)
echo ""
echo "main.tex"
echo $(detex main.tex | wc -m)
echo ""
echo ""
echo "gesamt"
echo $(detex einleitung.tex software.tex hardware.tex weitere_informationen.tex| wc -m)
echo ""
echo "gesamt mit main.tex"
echo $(detex einleitung.tex software.tex hardware.tex weitere_informationen.tex main.tex| wc -m)
