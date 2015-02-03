#!/bin/bash
echo "aus pdf:"
pdftotext main.pdf -enc UTF-8 - | wc -m
echo ""
echo "mit detex:"
echo ""
echo "hardware.tex"
detex hardware.tex | wc -m
echo ""
echo "software.tex"
detex software.tex | wc -m
echo ""
echo "einleitung.tex"
detex einleitung.tex | wc -m
echo ""
echo "weitere_informationen.tex"
detex weitere_informationen.tex | wc -m
echo ""
echo "main.tex"
detex main.tex | wc -m
echo ""
echo ""
echo "gesamt"
detex einleitung.tex software.tex hardware.tex weitere_informationen.tex| wc -m
echo ""
echo "gesamt mit main.tex"
detex einleitung.tex software.tex hardware.tex weitere_informationen.tex main.tex| wc -m
