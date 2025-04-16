# Dornerova-SQL_projekt_2025
Tento projekt se zaměřuje na analýzu dostupnosti základních potravin v České republice na základě průměrných mezd a cen potravin. Využívá otevřené datové sady o mzdách, cenách potravin a makroekonomických ukazatelích. Cílem je odpovědět na výzkumné otázky týkající se růstu mezd, cen potravin a vlivu HDP na tuto problematiku. 

Vysvětlení tabulek
Primární tabulky:
1.czechia_payroll – Informace o mzdách v různých odvětvích za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
    propojena s 
2.czechia_payroll_calculation – Číselník kalkulací v tabulce mezd.
    code 100 = fyzický
    code 200 = přepočtený
3.czechia_payroll_industry_branch – Číselník odvětví v tabulce mezd.
    A	Zemědělství, lesnictví, rybářství
    B	Těžba a dobývání
    C	Zpracovatelský průmysl
4.czechia_payroll_unit – Číselník jednotek hodnot v tabulce mezd.
    code 200 = name tis. osob
    code 80 403 = name Kč
5.czechia_payroll_value_type – Číselník typů hodnot v tabulce mezd.
    316	Průměrný počet zaměstnaných osob
    5958	Průměrná hrubá mzda na zaměstnance

6.czechia_price – Informace o cenách vybraných potravin za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
7.czechia_price_category – Číselník kategorií potravin, které se vyskytují v našem přehledu.
    příklad: 
    111101	Rýže loupaná dlouhozrnná	1.0	kg
    111201	Pšeničná mouka hladká	1.0	kg
    111301	Chléb konzumní kmínový	1.0	kg
    111303	Pečivo pšeničné bílé	1.0	kg

Číselníky sdílených informací o ČR:
1.czechia_region – Číselník krajů České republiky dle normy CZ-NUTS 2.
    příklad CZ010	Hlavní město Praha

2.czechia_district – Číselník okresů České republiky dle normy LAU.

Dodatečné tabulky:
1.countries - Všemožné informace o zemích na světě, například hlavní město, měna, národní jídlo nebo průměrná výška populace.
2.economies - HDP, GINI, daňová zátěž, atd. pro daný stát a rok.

Postup tvorby dat:
1.	Nejprve byla připravována data pro vytvoření první tabulky. Původní dotazy byly příliš složité, proto byly postupně zjednodušeny a přepsány.
2.	Z tabulek czechia_payroll a czechia_price byly identifikovány společné roky pomocí WITH common_years.
3.	Následně byla provedena kontrola, zda existují roky, které jsou pouze v czechia_payroll nebo pouze v czechia_price.
4.	Vytvořeny byly agregované hodnoty mezd (průměr za odvětví a rok) a cen potravin (průměr za potravinu a rok).
5.	Data byla spojena pomocí JOIN a výsledná tabulka byla uložena do t_kristina_dornerova_project_sql_primary_final.
6.	Tabulka byla v průběhu práce několikrát upravena a rozšířena o další sloupce (např. industry_code, product_code). K tomu bylo použito DROP TABLE IF EXISTS ... + CREATE TABLE ... místo CREATE OR REPLACE TABLE, aby se zajistila úplná aktualizace struktury a obsahu tabulky.
7.	Pro sekundární tabulku byly filtrovány evropské země (podle continent = 'Europe') a roky 2006–2018. Zvoleny byly jen řádky s dostupnými hodnotami HDP, GINI a populace.
8.	Z vytvořených tabulek byly následně sestaveny odpovědi na jednotlivé výzkumné otázky.

Mezivýsledky k jednotlivých otázkám

Otázka 1: Rostou mzdy ve všech odvětvích?
•	Použito: LAG() a CASE pro vytvoření dalšího sloupce
•	Závěr: Většina odvětví má rostoucí trend, ale např. v roce 2009 došlo k poklesům.

Otázka 2: Kolik si lze koupit litrů mléka a kg chleba?
•	Vybrány produkty podle kódů: mléko (114201), chleb (111301)
•	Vypočtena průměrná mzda a cena v letech 2006 a 2018
•	Výpočet kolik jednotek lze koupit: mzda / cena
•	Závěr: V roce 2018 si lze koupit více, kupní síla vzrostla

Otázka 3: Která potravina zdražuje nejpomaleji?
•	Použito: LAG() a průměrný meziroční nárůst v %
•	Ceny byly agregovány za rok a potravinu
•	Byly odstraněny NULL hodnoty a byl upraven celkový dotaz
•	Byly odstraněny hodnoty 0, které neměly žádnou vypovídající hodnotu
•	Závěr: Nejnižší průměrný růst měla potravina cukr krystalový

Otázka 4: Existuje rok, kdy ceny rostly o >10 % rychleji než mzdy?
•	Vytvořena view v_price_growth a v_salary_growth (meziroční růst v %)
•	Spojeno a porovnáno, rozdíl testován přes CASE
•	Závěr: V žádném roce nepřesáhl rozdíl 10 %

Otázka 5: Má růst HDP vliv na ceny a mzdy?
•	Vytvořeno view v_gdp_growth, porovnáno s v_price_growth a v_salary_growth
•	Hodnoceno pro stejný rok i následující rok (zpožděný vliv)
•	Doplněn sloupec interpretation (CASE)
•	Závěr: žádný jasný trend nepřevládá, výjimky např. 2007 a 2017 (růst všech), 2015 (HDP roste, ostatní stagnují)

Chybející nebo omezená data
•	Mzdy: dostupné roky 2000–2021
•	Ceny: dostupné roky 2006–2018
•	Proto byly ve výsledné tabulce zahrnuty pouze společné roky 2006–2018
•	Řádky s NULL hodnotami (např. v cenách) byly odstraněny pomocí WHERE value IS NOT NULL

