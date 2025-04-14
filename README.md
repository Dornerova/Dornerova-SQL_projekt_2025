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
