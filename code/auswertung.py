# -*- coding: utf-8 -*-
import csv
import math
from datetime import datetime # aus dem Modul datetime Datentyp datetime (Datum und Zeit) importieren
bis_roh = "2014/02/01 22:1:00"

namen = ["Innentemperatur", "Gerätetemperatur 1", "Außentemperatur", "Gerätetemperatur 2", "Temperatur (Luft)", "Luftfeuchtigkeit", "Luftdruck\t", "Temperatur (Druck)", "Prozessor\t", "Qualität\t"]
format = "%Y/%m/%d %H:%M:%S"
eingabeformat = "%d.%m.%y %H:%M:%S"
von_roh = "2014/02/01 18:12:42"


def offnen(datei):
	with open(datei) as filein:
		reader = csv.reader(filein, quoting = csv.QUOTE_NONNUMERIC)
		global liste # Liste außerhalb von Funtion nutzen
		liste = list(zip(*reader)) # = [temp1,temp2,temp3,temp4,luft_temp,luft_feucht,druck,temp_druck,rasp]

def ausreisser(spalte):
	zeilenanzahl = len(spalte) - 1
	i = 0

	while i < zeilenanzahl:
		if (spalte[i] != "") and (spalte[i + 1] != "") and (spalte[i - 1] != ""):
			diff1 = spalte[i] - spalte[i + 1]
			diff2 = spalte[i] - spalte[i - 1]
			if ((diff1 < -schwankung) or (diff1 > schwankung)) and ((diff2 < -schwankung) or (diff2 > schwankung)):
				print("in Spalte " + str(liste.index(spalte) + 1) + " Zeile " + str(i + 1) + " ist ein Ausreisser (" + str(spalte[i]) + ")")
				ausreisserliste.append((liste.index(spalte), i))
	# 		else:
	# 			print("Passt:" + str(i),str(diff1),str(diff2))
		i += 1

def mittelwert(spalte):
	summe = 0
	anzahl = 0 # Anzahl der Messwerte
	for wert in spalte:
		if wert != "":
			summe = summe + wert # zur bisherigen Summe addieren
			anzahl += 1
	mittelwert = summe / anzahl
	return mittelwert

def minmax(spalte):
	mini = spalte[0] # Minimum auf ersten Wert setzen
	maxi = spalte[0]
	for wert in spalte:
		if wert != "":
			if wert < mini:
				mini = wert
			if wert > maxi:
				maxi = wert
	return (mini, maxi)

def standardabweichung(spalte, mw):
	n = 0
	summe = 0
	for wert in spalte:
		if wert != "":
			term = wert - mw
			summe = summe + (term * term)
			n += 1
	stab = math.sqrt(summe / n)
	return stab

def datum_offnen():
	datei = open("datum.csv", "r")
	global inhalt
	inhalt = datei.readlines()
	datei.close()
def datumsauswahl(von, bis):

	start_gefunden = False
	stop_gefunden = False
	for datum in inhalt:
		datum_py = datetime.strptime(datum.rstrip(), format)
		if (datum_py > von) and (start_gefunden == False):
			start = inhalt.index(datum)
			start_gefunden = True
		if (start_gefunden == True) and (datum_py > bis) and (stop_gefunden == False):
			stop = inhalt.index(datum) - 1
			stop_gefunden = True
			break
	if(stop_gefunden != True) or (start_gefunden != True):
			print("Entweder ist der Endzeitpunkt vor dem Startzeitpunkt oder die beiden liegen zu nahe an den Grenzwerten.")
			exit(1)
	print("Der Messwert geht von Zeile " + str(start) + " bis Zeile " + str(stop) + " und über folgenden Zeitraum: " + str(bis - von))
	return start, stop

def datumsfrage(frage):
	while True:
		eingabe_roh = input(frage)
		try:
			eingabe = datetime.strptime(eingabe_roh, eingabeformat)
		except ValueError:
			print("Bitte Datum im Format 'DD.MM.YY HH:MM:SS' eingeben")
		else:
			return eingabe

offnen("vorbereitet.csv")
datum_offnen()
spalten_nummer = 0
ausreisserliste = []
for spalte in liste:
	if (spalten_nummer == 9):
		schwankung = 1000
	else:
		schwankung = 10
	ausreisser(spalte)
	spalten_nummer += 1
print("Bitte Datum im Format 'DD.MM.YY HH:MM:SS' eingeben")
print("Es sollte zwischen " + datetime.strptime(inhalt[1].rstrip(), format).strftime(eingabeformat) + " und " + datetime.strptime(inhalt[-1].rstrip(), format).strftime(eingabeformat) + " liegen")
von = datumsfrage("von: ")
bis = datumsfrage("bis: ")
startstop = datumsauswahl(von, bis)
von = startstop[0]
bis = startstop[1]
liste_auswahl = []
for spalte in liste:
	spalte_neu = spalte[von:bis]
	liste_auswahl.append(spalte_neu)
liste = liste_auswahl
print("------Mittelwerte------")
mittelwerte = [] # leere Liste erstellen
for spalte in liste:
	mw = mittelwert(spalte) # jeden MW ausrechnen ...
	mittelwerte.append(mw) # ... und an die Liste anhängen
mittelausgabe = zip(namen, mittelwerte) # in Tupel umwandeln [(Innentemperatur, 25), (Außentemperatur,8)]
for name, mittelwert in mittelausgabe:
	print(name + ":\t%0.2f" % mittelwert) # jedes Tupel ausgeben

print("------Minimum-Maximum------")
minima = []
maxima = []
for spalte in liste:
	minumax = minmax(spalte)
	mini = minumax[0]
	maxi = minumax[1]
	minima.append(mini)
	maxima.append(maxi)
minmaxausgabe = zip(namen, minima, maxima)
for name, minimum, maximum in minmaxausgabe:
	print(name + ":\t" + str(minimum) + "\t" + str(maximum))
print("------Standardabweichung------")
standardabweichungen = []
for spalte in liste:
	abweichung = standardabweichung(spalte, mittelwerte[liste.index(spalte)]) # Mittelwert über Stelle in Liste herausfinden
	standardabweichungen.append(abweichung)
stabausgabe = zip(namen, standardabweichungen)
for name, abweichung in stabausgabe:
	print(name + ":\t%0.2f" % abweichung)
