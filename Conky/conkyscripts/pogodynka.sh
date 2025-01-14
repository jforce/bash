# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#															#
# Pogodynka 0.2.2.1													#
#															#
# azhag (azhag@bsd.miki.eu.org)												#
#															# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#															#
# Skrypt pobiera informacje o stanie pogody ze strony weather.yahoo.com dla danego miasta, nast�pnie formatuje je i	#
# wy�wietla na ekranie. Skrypt mo�e by� wykorzystany np. w conky'm, xosd, *message.					#
#															#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#															#
# Wymagane aplikacje:													#
# w3m - tekstowa przegl�darka www											#
#															#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#															# 
# Przed u�yciem skryptu nale�y ustali� zmienne "sciezka" oraz "kod".							#
#															#
# Aby ustali� kod swojego miasta wejd� na stron� http://weather.yahoo.com/ i wyszukaj tam swoje miasto. Kodem jest 	#
# ko�c�wka linka z pogod� naszego miasta.										#	
#															#
# Przyk�adowe kody:													#
# Warszawa - PLXX0028													#
# Krak�w - PLXX0012													#
# Gda�sk - PLXX0005													#
# Szczecin - PLXX0025													#
#															#
# Informacj� jak� wy�wietla skrypt mo�na zmieni� haszuj�c odpowiednie linijki w sekcji "formatowanie informacji		#
# wyj�ciowej". Mo�na r�wnie� w �atwy spos�b sformatowa� w�asny wynik u�ywaj�c dostepnych zmiennych.			#
#															#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

#!/bin/bash

# Katalog, w kt�rym znajduje si� skrypt
sciezka=~/OsMeusScripts/conkyscripts

# Kod miasta
kod=POXX0022

plik=~/weather
# sprawdzenie czy serwer jest dost�pny
#if [ `ping -c1 216.109.126.70 | grep from | wc -l` -eq 0 ]
 # then
	#echo "Serwis niedost�pny"
  #else
	# pobieranie informacji
 	w3m -dump http://weather.yahoo.com/forecast/"$kod"_c.html | grep -A21 "Current" | sed 's/DEG/�/g' > $plik

	# ustalenie warto�ci zmiennych
	stan=`head -n3 $plik | tail -n1`
	temp=`tail -n1 $plik | awk '{print $1}'`
	tempo=`head -n6 $plik | tail -n1`
	cisn=`head -n8 $plik | tail -n1`
	wiatr=`head -n16 $plik | tail -n1`
	wilg=`head -n10 $plik | tail -n1`
	wsch=`head -n18 $plik | tail -n1`
	zach=`head -n20 $plik | tail -n1`
	if [ `cat "$sciezka"/pogodynka.sh | grep -x "# $stan" | wc -l` -eq 0 ]
	  then
		stanpl=$stan
	  else
		stanpl=`cat "$sciezka"/pogodynka.sh | grep -xA1 "# $stan" | tail -n1 | awk '{print $2,$3,$4,$5,$6,$7}'`
	fi
	
	# formatowanie informacji wyj�ciowej
	# dost�pne zmienne:
	# $stan		opis stanu po angielsku
	# $stanpl	opis stanu po polsku
	# $temp		temperatura powietrza
	# $tempo	temperatura odczuwalna
	# $cisn		ci�nienie atmosferyczne
	# $wiatr	kierunek, si�a wiatru
	# $wilg		wilgotno�� powietrza
	# $wsch		godzina wschodu s�o�ca
	# $zach		godzina zachodu s�o�ca
	
	#echo $stan
	#echo $stanpl
	echo $temp C  /  $tempo C
	#echo Cisnienie $cisn hPa
	#echo $wiatr
	#echo Wilgotno��: $wilg
	#echo Wsch�d S�o�ca: $wsch
	#echo Zach�d S�o�ca: $zach
	#echo $stanpl, $temp C

#fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# T�umaczenia stan�w pogody.
# Je�eli zauwa�ysz pogod�, kt�rej nie ma jeszcze na liscie daj mi zna� na maila podanego na g�rze. Z g�ry dzi�kuj�.
#
# Sunny
# S�onecznie
# Clear
# Przejrzy�cie
# Fair
# Pogodnie
# Sunny/Windy
# S�onecznie/Wiatr
# Clear/Windy
# Przejrzy�cie/Wiatr
# Fair/Windy
# Przejrzy�cie/Wiatr
# Windy
# Wiatr
#
# Partly Cloudy
# Cz�ciowo pochmurnie
# Partly Cloudy and Windy
# Cz�ciowo pochmurnie/Wiatr
# Partly Sunny
# Cz�ciowo s�onecznie
# Mostly Clear
# Przew. przejrzy�cie
# Partly Sunny/Windy
# Cz�ciowo s�onecznie/Wiatr
# Mostly Clear/Windy
# Przew. przejrzy�cie/Wiatr
# Mostly Sunny
# Przew. p�onecznie
# Mostly Sunny/Windy
# Przew. s�onecznie/Wiatr
# Scattered Clouds
# Rzadkie ob�oki
#
# Cloudy
# Pochmurnie
# Overcast
# Ca�k. zachmurzenie
# Cloudy/Windy
# Pochmurnie/Wiatr
# Overcast/Windy
# Ca�k. zachmurzenie/Wiatr
# Mostly Cloudy/Windy
# Przew. pochmurnie/Wiatr
# Mostly Cloudy
# Przew. pochmurnie
# Am Clouds / Pm Sun
# Ranek pochmurny/S�oneczne popo�udnie
#
# Light Drizzle
# Lekka m�awka
# Drizzle
# M�awka
# Light Rain
# Lekki deszcz
# Rain
# Deszcz
# Heavy Rain
# Ulewa
# Light Rain/Fog
# Lekki deszcz/Mg�a
# Rain/Fog
# Deszcz/Mg�a
# Light Drizzle/Windy
# Lekka m�awka/Wiatr
# Drizzle/Windy
# M�awka/Wiatr
# Light Rain/Windy
# Lekki deszcz/Wiatr
# Rain/Windy
# Deszcz/Wiatr
# Rain / Wind
# Deszcz/Wiatr
# Heavy Rain/Windy
# Ulewa/Wiatr
# AM Light Rain
# Ranny lekki deszcz
# PM Light Rain
# Popo�udniowy lekki deszcz
# Pm Light Rain
# Popo�udniowy lekki deszcz
# AM Light Rain/Windy
# Ranny lekki deszcz/Wiatr
# PM Light Rain/Windy
# Popo�udniowy lekki deszcz/Wiatr
#
# Rain Shower
# Przelotny deszcz
# Shower
# Przelotna ulewa
# Showers
# Przelotna ulewa
# Heavy Rain Shower
# Mocna ulewa
# Heavy Rain Shower/Windy
# Mocna ulewa/Wiatr
# Light Rain Shower
# Lekka ulewa
# AM Shower
# Poranna ulewa
# AM Showers
# Poranna ulewa
# Am Showers
# Poranna ulewa
# AM Showers / Wind
# Poranna ulewa/Wiatr
# PM Shower
# Popo�udniowa ulewa
# PM Showers / Wind
# Popo�udniowe ulewy/Wiatr
# Few Showers / Wind
# Przelotne deszcze/Wiatr
# Showers / Wind
# Deszcze/Wiatr
# PM Showers
# Popo�udniowe ulewy
# Pm Showers
# Popo�udniowe ulewy
# Scattered Shower
# Rozleg�a ulewa
# Scattered Showers
# Rozleg�e ulewy
# Scatter Showers
# Rozleg�e ulewy
# Rain Shower/Windy
# Przelotny deszcz/Wiatr
# Shower/Windy
# Przelotna ulewa/Wiatr
# Light Rain Shower/Windy
# Lekka ulewa/Wiatr
# AM Shower/Windy
# Poranna ulewa/Wiatr
# PM Shower/Windy
# Popo�udniowa ulewa/Wiatr
# Scattered Shower/Windy
# Rozleg�a ulewa/Wiatr
# Scatter Showers / Wind
# Rozleg�e ulewy/Wiatr
# Few Showers
# Mo�liwe ulewy
# Few Showers/Windy
# Mo�liwe ulewy/Wiatr
# Showers in the Vicinity
# Pobliskie ulewy
#
# Light Snow
# Lekki �nieg
# Snow
# �nieg
# Snow / Wind
# �nieg/Wiatr
# Heavy Snow
# Mocny �nieg
# Light Snow Pellets
# Lekki grad �nie�ny
# Snow Pellets
# Grad �nie�ny
# Light Ice Pellets
# Lekki grad lodowy
# Ice Pellets
# Grad lodowy
# Wintery Weather
# Zimowa pogoda
# Light Freezing Rain
# Lekki zamarzaj�y deszcz
# Freezing Rain
# Zamarzaj�cy deszcz
# Flurries/Windy
# Zamiecie/Wiatr
# Light Flurries/Windy
# Lekkie zamiecie/Wiatr
# Light Snow/Windy
# Lekki �nieg/Wiatr
# Light Snow / Wind
# Lekki �nieg/Wiatr
# Snow/Windy
# �nieg/Wiatr
# Heavy Snow/Windy
# Mocny �nieg/Wiatr
# Light Snow Pellets/Windy
# Lekki grad �nie�ny/Wiatr
# Snow Pellets/Windy
# Grad �nie�ny/Wiatr
# Light Ice Pellets/Windy
# Lekki grad lodowy/Wiatr
# Ice Pellets/Windy
# Grad lodowy/Wiatr
# Light Freezing Rain/Windy
# Lekki zamarzaj�cy deszcz/Wiatr
# Freezing Rain/Windy
# Zamarzaj�cy deszcz/Wiatr
# Wintery Mix
# Miks zimowy
# Light Snow Grains
# Lekkie granulki �niegu
# Snow Grains
# Granulki �niegu
# Rain/Snow
# �nieg z deszczem
# Rain / Snow Showers
# Deszcz ze �niegiem
# Rain / Snow
# Deszcz ze �niegiem
# Rain / Thunder
# Deszcz / Burza
# Rain/Show/Windy
# �nieg z deszczem/Wiatr
# Rain / Snow / Wind
# �nieg z deszczem/Wiatr
# Light Rain/Freezing Rain
# Lekki deszcz/Zamarzaj�cy deszcz
# Rain/Freezing Rain
# Deszcz/Zamarzaj�cy deszcz
# Light Rain/Freezing Rain/Windy
# Lekki deszcz/Zamarzaj�cy Deszcz/Wiatr
# Rain/Freezing Rain/Windy
# Deszcz/Zamarzaj�cy deszcz/Wiatr
# AM Snow
# Poranny �nieg
# PM Snow
# Popo�udniowy �nieg
# AM Light Snow
# Poranny lekki �nieg
# PM Light Snow
# Popo�udniowy lekki �nieg
# Ice Crystals
# Kryszta�ki lodu
# Ice Crystals/Windy
# Kryszta�ki lodu/Wiatr
# 
# Snow Showers
# Burze �nie�ne
# Snow Shower
# Burza �nie�na
# Heavy Snow Shower
# Mocna burza �nie�na
# Heavy Snow Shower/Windy
# Mocna burza �nie�na/Wiatr
# PM Snow Showers
# Popo�udniowe burze �nie�ne
# AM Snow Showers
# Poranne burze �nie�ne
# Rain/Snow Showers
# Deszcz/Burze �nie�ne
# Snow Showers/Windy
# Burze �nie�ne/Wiatr
# PM Snow Showers/Windy
# Popo�udniowe burze �nie�ne/Wiatr
# AM Snow Showers/Windy
# Poranne burze �nie�ne/Wiatr
# Rain/Snow Showers/Windy
# Deszcz/Burze �nie�ne/Wiatr
# Light Snow Showers
# Lekkie burze �nie�ne
# Light Snow Shower
# Lekka burza �nie�na
# Light Snow Showers/Windy
# Lekkie burze �nie�ne/Wiatr
# Flurries
# Zamiecie
# Light Flurries
# Lekkie zamiecie
# Scattered Flurries
# Rozleg�e zamiecie
# Few Flurries
# Mo�liwe zamiecie
# Few Flurries/Windy
# Mo�liwe zamiecie/Wiatr
# Scattered Snow Showers
# Rozleg�e burze �nie�ne
# Scattered Snow Showers/Windy
# Rozleg�e burze �nie�ne/Wiatr
# Few Snow Showers
# Mo�liwe burze �nie�ne
# Few Snow Showers/Windy
# Mo�liwe burze �nie�ne/Wiatr
# Freezing Drizzle
# Marzn�ca m�awka
# Light Freezing Drizzle
# Lekka marzn�ca m�awka
# Freezing Drizzle/Windy
# Marzn�ca m�awka/Wiatr
# Light Freezing Drizzle/Windy
# Lekka marzn�ca m�awka/Wiatr
# Drifting Snow
# Zawieja �nie�na
# 
# Thunderstorms
# Burze
# T-storms
# Burze
# T-Storms
# Burze
# T-Storm
# Burza
# Scattered Thunderstorms
# Rozleg�e burze
# Scattered T-Storms
# Rozleg�e burze
# Thunderstorms/Windy
# Burze/Wiatr
# Scattered Thunderstorms/Windy
# Rozleg�e burze/Wiatr
# Rain/Thunder
# Deszcz/Grzmoty
# Light Thunderstorms/Rain
# Lekkie burze/Deszcz
# Thunderstorms/Rain
# Burze/Deszcz
# Light Rain with Thunder
# Lekki deszcz z grzmotami
# Rain with Thunder
# Deszcz z grzmotami
# Thunder in the Vicinity
# Pobliskie burze
# 
# Fog
# Mg�a
# Haze
# Lekka mg�a
# Mist
# Lekkie zamglenie
# Fog/Windy
# Mg�a/Wiatr
# Haze/Windy
# Lekka Mg�a/Wiatr
# Mist/Windy
# Lekkie zamglenie/Wiatr
# Partial Fog
# Cz�ciowa mg�a
# Smoke
# G�sta mg�a
# Foggy
# Mglisto
# AM Fog/PM Sun
# Ranna mg�a/Popo�udniowe s�o�ce
# Shallow Fog
# P�ytka mg�a
# 
# Blowing Dust
# Zawieja py�owa
# Blowing Sand
# Zawieja piaskowa
# Duststorm
# Burza piaskowa
# Wind
# Wiatr
# Widespread Dust/Windy
# Rozleg�e zamiecie/Wiatr
# Widespread Dust
# Rozleg�e zamiecie
# Low Drifting Sand
# Zawieja piaskowa
# 
# Data Not Available
# Dane niedost�pne
# N/A
# N/D
# N/a
# N/d

