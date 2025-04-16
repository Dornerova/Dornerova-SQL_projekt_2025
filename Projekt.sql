--Tabulka č. 1
SELECT 
	cpy.payroll_year AS Year,
	cpib."name" AS Industry,
	cpy.value AS value_payroll,
	cpc."name" AS Food_item,
	round(avg(cp.value)::numeric,2) AS price_value,
	cpc.price_value AS value_unit,
	cpc.price_unit AS product_unit
FROM czechia_payroll cpy 
JOIN czechia_payroll_industry_branch cpib 
	ON cpy.industry_branch_code = cpib.code
JOIN czechia_price cp
	ON cpy.payroll_year = date_part('year',cp.date_from)
JOIN czechia_price_category cpc 
	ON cp.category_code = cpc.code
WHERE cpy.value_type_code = 5958
GROUP BY 
	cpy.payroll_year,
	cpib."name",
	cpy.value,
	cpc."name",
	cpc.price_value,
	cpc.price_unit
; --moc složitý dotaz

SELECT
	round(avg(cp.value)::numeric,2),
	date_part('year',cp.date_from),
	date_part('year',cp.date_to)
FROM czechia_price cp 
WHERE 
	cp.category_code = 115101
GROUP BY
	cp.date_from,
	cp. date_to 
ORDER BY cp.date_from 
;

SELECT 
	pyi.payroll_year AS Year,
	pyi.Industry,
	pyi.avg_salary AS value_payroll,
	cp2.Food_item,
	cp2.avg_price AS price_value,
	cp2.value_unit,
	cp2.product_unit
FROM (
	SELECT
		cpy.payroll_year,
		cpib."name" AS Industry,
		round(avg(cpy.value)::numeric,2) AS avg_salary
	FROM czechia_payroll cpy 
	JOIN czechia_payroll_industry_branch cpib 
		ON cpy.industry_branch_code = cpib.code
	WHERE cpy.value_type_code = 5958
	GROUP BY 
		cpy.payroll_year,
		cpib."name"
) pyi
JOIN (
	SELECT 
		date_part('year', cp.date_from ) AS date_year,
		cp.category_code,
		cpc."name" AS Food_item,
		round(avg(cp.value)::numeric,2) AS avg_price,
		cpc.price_value AS value_unit,
		cpc.price_unit AS product_unit
	FROM czechia_price cp
	JOIN czechia_price_category cpc 
		ON cp.category_code = cpc.code
	WHERE
		cp.value IS NOT null
	GROUP BY
		cp.category_code,
		date_year,
		cpc."name",
		cpc.price_unit,
		cpc.price_value 
) cp2
	ON pyi.payroll_year = cp2.date_year
ORDER BY cp2.date_year, pyi.industry, price_value
; 
--potřebuji jen společné roky

WITH common_years AS (
    SELECT DISTINCT pyi.payroll_year AS Year
    FROM (
        SELECT DISTINCT payroll_year 
        FROM czechia_payroll 
        WHERE value_type_code = 5958
    ) pyi
    INNER JOIN (
        SELECT DISTINCT date_part('year', date_from) AS Year 
        FROM czechia_price
    ) cp2
    	ON pyi.payroll_year = cp2.Year
)
SELECT 
	pyi.payroll_year AS Year,
	pyi.Industry,
	pyi.code AS industry_code,
	pyi.avg_salary AS value_payroll,
	cp2.code AS product_code,
	cp2.Food_item,
	cp2.avg_price AS price_value,
	cp2.value_unit,
	cp2.product_unit
FROM (
	SELECT
		cpy.payroll_year,
		cpib."name" AS Industry,
		cpib.code,
		round(avg(cpy.value)::numeric,2) AS avg_salary
	FROM czechia_payroll cpy 
	JOIN czechia_payroll_industry_branch cpib 
		ON cpy.industry_branch_code = cpib.code
	WHERE cpy.value_type_code = 5958
	GROUP BY 
		cpy.payroll_year,
		cpib."name",
		cpib.code
) pyi
JOIN (
	SELECT 
		date_part('year', cp.date_from ) AS date_year,
		cp.category_code,
		cpc.code,
		cpc."name" AS Food_item,
		round(avg(cp.value)::numeric,2) AS avg_price,
		cpc.price_value AS value_unit,
		cpc.price_unit AS product_unit
	FROM czechia_price cp
	JOIN czechia_price_category cpc 
		ON cp.category_code = cpc.code
	WHERE
		cp.value IS NOT null
	GROUP BY
		cp.category_code,
		date_year,
		cpc."name",
		cpc.price_unit,
		cpc.price_value,
		cpc.code
) cp2
	ON pyi.payroll_year = cp2.date_year
JOIN common_years cy
	ON pyi.payroll_year = cy."year" 
ORDER BY cp2.date_year, pyi.industry, price_value; 

--abych zjistila, za jsou nějaké roky pouze v payroll nebo price

SELECT DISTINCT payroll_year AS Year
FROM czechia_payroll
WHERE value_type_code = 5958
ORDER BY Year;

SELECT DISTINCT date_part('year', date_from) AS Year
FROM czechia_price
ORDER BY Year;

SELECT 
    p.payroll_year AS Year_in_Payroll,
    pr.year AS Year_in_Price
FROM (
    SELECT DISTINCT payroll_year 
    FROM czechia_payroll 
    WHERE value_type_code = 5958
) p
FULL OUTER JOIN ( --ukáže i roky, které jsou v czechia_price, ale ne v czechia_payroll.
    SELECT DISTINCT date_part('year', date_from) AS year 
    FROM czechia_price
) pr
	ON p.payroll_year = pr.year
ORDER BY p.payroll_year NULLS LAST; --nulové hodnoty poslední


--Tabulka č. 2
SELECT
	e."year",
	e.country,
	round(e.gdp::numeric,2) AS gdp,
	round(e.gini::numeric,2) AS gini_index,
	round(e.population::numeric,0) AS population
FROM economies e 
JOIN countries c 
	ON e.country = c.country
WHERE 
	e."year" BETWEEN 2006 AND 2018
	AND c.continent = 'Europe'
	AND e.gdp IS NOT NULL
	AND e.gini IS NOT NULL
	AND e.population IS NOT null
ORDER BY e."year", c.country ;

SELECT DISTINCT 
	c.continent 
FROM countries c;

--Vtvoření tabulky
--když už mám vytvořené SQL dotazy, tak si vytvořím tabulku
CREATE OR REPLACE TABLE t_Kristina_Dornerova_project_SQL_primary_final AS 
WITH common_years AS (
    SELECT DISTINCT pyi.payroll_year AS Year
    FROM (
        SELECT DISTINCT payroll_year 
        FROM czechia_payroll 
        WHERE value_type_code = 5958
    ) pyi
    INNER JOIN (
        SELECT DISTINCT date_part('year', date_from) AS Year 
        FROM czechia_price
    ) cp2
    	ON pyi.payroll_year = cp2.Year
)
SELECT 
	pyi.payroll_year AS Year,
	pyi.Industry,
	pyi.code AS industry_code,
	pyi.avg_salary AS value_payroll,
	cp2.code AS product_code,
	cp2.Food_item,
	cp2.avg_price AS price_value,
	cp2.value_unit,
	cp2.product_unit
FROM (
	SELECT
		cpy.payroll_year,
		cpib."name" AS Industry,
		cpib.code,
		round(avg(cpy.value)::numeric,2) AS avg_salary
	FROM czechia_payroll cpy 
	JOIN czechia_payroll_industry_branch cpib 
		ON cpy.industry_branch_code = cpib.code
	WHERE cpy.value_type_code = 5958
	GROUP BY 
		cpy.payroll_year,
		cpib."name",
		cpib.code
) pyi
JOIN (
	SELECT 
		date_part('year', cp.date_from ) AS date_year,
		cp.category_code,
		cpc.code,
		cpc."name" AS Food_item,
		round(avg(cp.value)::numeric,2) AS avg_price,
		cpc.price_value AS value_unit,
		cpc.price_unit AS product_unit
	FROM czechia_price cp
	JOIN czechia_price_category cpc 
		ON cp.category_code = cpc.code
	WHERE
		cp.value IS NOT null
	GROUP BY
		cp.category_code,
		date_year,
		cpc."name",
		cpc.price_unit,
		cpc.price_value,
		cpc.code
) cp2
	ON pyi.payroll_year = cp2.date_year
JOIN common_years cy
	ON pyi.payroll_year = cy."year" 
ORDER BY cp2.date_year, pyi.industry, price_value;

DROP TABLE IF EXISTS t_Kristina_Dornerova_project_SQL_primary_final;

CREATE TABLE t_Kristina_Dornerova_project_SQL_primary_final AS 
WITH common_years AS (
    SELECT DISTINCT pyi.payroll_year AS Year
    FROM (
        SELECT DISTINCT payroll_year 
        FROM czechia_payroll 
        WHERE value_type_code = 5958
    ) pyi
    INNER JOIN (
        SELECT DISTINCT date_part('year', date_from) AS Year 
        FROM czechia_price
    ) cp2
    	ON pyi.payroll_year = cp2.Year
)
SELECT 
	pyi.payroll_year AS Year,
	pyi.Industry,
	pyi.code AS industry_code,
	pyi.avg_salary AS value_payroll,
	cp2.code AS product_code,
	cp2.Food_item,
	cp2.avg_price AS price_value,
	cp2.value_unit,
	cp2.product_unit
FROM (
	SELECT
		cpy.payroll_year,
		cpib."name" AS Industry,
		cpib.code,
		round(avg(cpy.value)::numeric,2) AS avg_salary
	FROM czechia_payroll cpy 
	JOIN czechia_payroll_industry_branch cpib 
		ON cpy.industry_branch_code = cpib.code
	WHERE cpy.value_type_code = 5958
	GROUP BY 
		cpy.payroll_year,
		cpib."name",
		cpib.code
) pyi
JOIN (
	SELECT 
		date_part('year', cp.date_from ) AS date_year,
		cp.category_code,
		cpc.code,
		cpc."name" AS Food_item,
		round(avg(cp.value)::numeric,2) AS avg_price,
		cpc.price_value AS value_unit,
		cpc.price_unit AS product_unit
	FROM czechia_price cp
	JOIN czechia_price_category cpc 
		ON cp.category_code = cpc.code
	WHERE
		cp.value IS NOT null
	GROUP BY
		cp.category_code,
		date_year,
		cpc."name",
		cpc.price_unit,
		cpc.price_value,
		cpc.code
) cp2
	ON pyi.payroll_year = cp2.date_year
JOIN common_years cy
	ON pyi.payroll_year = cy."year" 
ORDER BY cp2.date_year, pyi.industry, price_value;


--Tabulka 2
CREATE TABLE t_Kristina_Dornerova_project_SQL_secondary_final AS 
SELECT
	e."year",
	e.country,
	round(e.gdp::numeric,2) AS gdp,
	round(e.gini::numeric,2) AS gini_index,
	round(e.population::numeric,0) AS population
FROM economies e 
JOIN countries c 
	ON e.country = c.country
WHERE 
	e."year" BETWEEN 2006 AND 2018
	AND c.continent = 'Europe'
	AND e.gdp IS NOT NULL
	AND e.gini IS NOT NULL
	AND e.population IS NOT null
ORDER BY e."year", c.country;


--Výzkumené otázky
--1.Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
SELECT
	"year" ,
	industry_code ,
	avg(value_payroll),
	CASE
		WHEN avg(value_payroll) < LAG(avg(value_payroll)) OVER (PARTITION BY industry_code ORDER BY year) THEN 'pokles'
		ELSE 'růst'
	END wage_development
FROM t_kristina_dornerova_project_sql_primary_final tkd 
GROUP BY
	tkd.year,
	tkd.industry_code
ORDER BY industry_code, "year";

/*
 * Mzdy v ČR mají ve většině odvětví rostoucí tendenci. V některých odvětvích se ale objevuje krátkodobý pokles,
 * typicky kolem roku 2009. Vývoj mezd tedy není zcela lineární, ale celkový trend je rostoucí.
 */

SELECT
	DISTINCT "year" ,
	industry_code ,
	value_payroll
FROM t_kristina_dornerova_project_sql_primary_final tkd 
ORDER BY "year",industry_code;

SELECT *
FROM t_kristina_dornerova_project_sql_primary_final
WHERE "year" = 2009 AND industry_code = 'A';

--Otázka č.2 Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v 
--dostupných datech cen a mezd?
SELECT
	"year",
	product_code,
	tkd.price_value,
	round(avg(tkd.value_payroll),2) AS avg_payroll,
	round(avg(tkd.value_payroll) / tkd.price_value,2) AS units_affordable
FROM t_kristina_dornerova_project_sql_primary_final tkd
WHERE
	tkd."year" IN (2006, 2018)
	AND product_code IN (111301, 114201)
GROUP BY
	tkd."year",
	product_code,
	tkd.price_value
ORDER BY tkd.year, product_code
;

--kod produktu pro chléb a mléko
SELECT
	DISTINCT product_code,
	food_item 
FROM t_kristina_dornerova_project_sql_primary_final tkd
WHERE 
	 lower(food_item) LIKE '%mléko%'
	OR lower(food_item)  LIKE '%chléb%';

SELECT *
FROM t_kristina_dornerova_project_sql_primary_final tkdpspf;

/*
V roce 2018 si průměrný občan mohl za hrubou mzdu pořídit více litrů mléka i kilogramů chleba než v roce 2006. 
To znamená, že reálná kupní síla se zvýšila, i když ceny obou potravin v čase vzrostly.
*/

--Otazka 3 Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
SELECT 
	tkd.YEAR,
	tkd.product_code,
	tkd.food_item,
	tkd.price_value,
	LAG(tkd.price_value) OVER (PARTITION BY tkd.product_code ORDER BY tkd.year) AS prev_price,
	ROUND(
		(tkd.price_value - LAG(tkd.price_value) OVER (PARTITION BY tkd.product_code ORDER BY tkd.year))
		/ LAG(tkd.price_value) OVER (PARTITION BY tkd.product_code ORDER BY tkd.year) * 100, 2
	) AS precent
FROM t_kristina_dornerova_project_sql_primary_final tkd
ORDER BY 
	tkd.product_code, 
	tkd.year;

--nechci null hodnoty
WITH price_changes AS (
	SELECT 
		tkd.year,
		tkd.product_code,
		tkd.food_item,
		tkd.price_value,
		LAG(tkd.price_value) OVER (PARTITION BY tkd.product_code ORDER BY tkd.year) AS prev_price,
		ROUND(
			(tkd.price_value - LAG(tkd.price_value) OVER (PARTITION BY tkd.product_code ORDER BY tkd.year))
			/ LAG(tkd.price_value) OVER (PARTITION BY tkd.product_code ORDER BY tkd.year) * 100,
			2
		) AS percent
	FROM t_kristina_dornerova_project_sql_primary_final tkd 
)
SELECT *
FROM price_changes
WHERE 
	prev_price IS NOT NULL
ORDER BY product_code, year;


--chci se zbavit 0, které nemají žádnou vypovídající hodnotu
--pro každý rok má produkt více řádků, protože jsou tam různé kombinace s dalšími sloupci (např. industry_code nebo jinými). 
--Pokud má víc řádků pro stejný produkt a rok, LAG() pracuje s každým zvlášť → a srovnává i v rámci stejného roku, což nechci

WITH avg_prices AS (
  SELECT 
    year,
    product_code,
    food_item,
    ROUND(AVG(price_value)::numeric, 2) AS avg_price
  FROM t_kristina_dornerova_project_sql_primary_final
  GROUP BY 
  	year, 
  	product_code, 
  	food_item
),
price_changes AS (
  SELECT 
    year,
    product_code,
    food_item,
    avg_price,
    LAG(avg_price) OVER (PARTITION BY product_code ORDER BY year) AS prev_price,
    ROUND(
      (avg_price - LAG(avg_price) OVER (PARTITION BY product_code ORDER BY year))
      / LAG(avg_price) OVER (PARTITION BY product_code ORDER BY year) * 100, 2
    ) AS percent
  FROM avg_prices
)
SELECT *
FROM price_changes
WHERE 
	year >= 2007
ORDER BY 
	product_code, 
	year;

--zjištění výsledku
WITH avg_prices AS (
  SELECT 
    year,
    product_code,
    food_item,
    ROUND(AVG(price_value)::numeric, 2) AS avg_price
  FROM t_kristina_dornerova_project_sql_primary_final
  GROUP BY 
  	year, 
  	product_code, 
  	food_item
),
price_changes AS (
  SELECT 
    year,
    product_code,
    food_item,
    avg_price,
    LAG(avg_price) OVER (PARTITION BY product_code ORDER BY year) AS prev_price,
    ROUND(
      (avg_price - LAG(avg_price) OVER (PARTITION BY product_code ORDER BY year))
      / LAG(avg_price) OVER (PARTITION BY product_code ORDER BY year) * 100, 2
    ) AS percent
  FROM avg_prices
)
SELECT
	product_code,
	food_item,
	round(avg(percent),2) AS avg_precent
FROM price_changes
WHERE 
	year >= 2007
GROUP BY
	product_code,
	food_item 
ORDER BY avg_precent
LIMIT 1
;
--Na základě výpočtu průměrného meziročního procentuálního nárůstu cen jednotlivých potravin bylo zjištěno, 
--že potravinou s nejnižším růstem cen v čase je cukr krystalový.
--To znamená, že její cena se zvyšovala velmi pozvolna a stabilně, a v porovnání s ostatními kategoriemi potravin 
--zdražovala nejpomaleji.


--Otázka č. 4 Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd 
--(větší než 10 %)?
CREATE VIEW v_price_growth AS
WITH avg_prices AS (
  SELECT 
    year,
    product_code,
    food_item,
    ROUND(AVG(price_value)::numeric, 2) AS avg_price
  FROM t_kristina_dornerova_project_sql_primary_final
  GROUP BY 
  	year, 
  	product_code, 
  	food_item
),
price_changes AS (
  SELECT 
    year,
    product_code,
    food_item,
    avg_price,
    LAG(avg_price) OVER (PARTITION BY product_code ORDER BY year) AS prev_price,
    ROUND(
      (avg_price - LAG(avg_price) OVER (PARTITION BY product_code ORDER BY year))
      / LAG(avg_price) OVER (PARTITION BY product_code ORDER BY year) * 100, 2
    ) AS percent
  FROM avg_prices
)
SELECT *
FROM price_changes
WHERE 
	year >= 2007;

DROP VIEW v_price_growth; 

CREATE VIEW v_price_growth AS 
WITH avg_price AS (
  SELECT 
    year,
    ROUND(AVG(price_value)::numeric, 2) AS avg_price
  FROM t_kristina_dornerova_project_sql_primary_final
  GROUP BY 
  	year 
),
price_growth AS (
  SELECT 
    year,
    avg_price,
    LAG(avg_price) OVER (ORDER BY year) AS prev_price,
    ROUND(
      (avg_price - LAG(avg_price) OVER (ORDER BY year))
      / LAG(avg_price) OVER (ORDER BY year) * 100, 2
    ) AS percent
  FROM avg_price
)
SELECT *
FROM price_growth
WHERE 
	year >= 2007
;

DROP VIEW v_price_growth;

CREATE VIEW v_price_growth AS 
WITH avg_price AS (
  SELECT 
    year,
    ROUND(AVG(price_value)::numeric, 2) AS avg_price
  FROM t_kristina_dornerova_project_sql_primary_final
  GROUP BY 
  	year 
),
price_growth AS (
  SELECT 
    year,
    avg_price,
    LAG(avg_price) OVER (ORDER BY year) AS prev_price,
    ROUND(
      (avg_price - LAG(avg_price) OVER (ORDER BY year))
      / LAG(avg_price) OVER (ORDER BY year) * 100, 2
    ) AS percent
  FROM avg_price
)
SELECT *
FROM price_growth
WHERE 
	year >= 2007
;

SELECT *
FROM t_kristina_dornerova_project_sql_primary_final tkd;

--Pro mzdy
WITH avg_payroll AS (
  SELECT 
    year,
    ROUND(AVG(value_payroll)::numeric, 2) AS avg_payroll
  FROM t_kristina_dornerova_project_sql_primary_final
  GROUP BY 
  	year
),
payroll_changes AS (
  SELECT 
    YEAR,
    avg_payroll,
    LAG(avg_payroll) OVER (ORDER BY year) AS prev_payroll,
    ROUND(
      (avg_payroll - LAG(avg_payroll) OVER (ORDER BY year))
      / LAG(avg_payroll) OVER (ORDER BY year) * 100, 2
    ) AS percent
  FROM avg_payroll
)
SELECT *
FROM payroll_changes
WHERE 
	year >= 2007
ORDER BY
	year;

--vytvořím si view
CREATE VIEW v_salary_growth AS 
WITH avg_payroll AS (
  SELECT 
    year,
    ROUND(AVG(value_payroll)::numeric, 2) AS avg_payroll
  FROM t_kristina_dornerova_project_sql_primary_final
  GROUP BY 
  	year
),
payroll_changes AS (
  SELECT 
    YEAR,
    avg_payroll,
    LAG(avg_payroll) OVER (ORDER BY year) AS prev_payroll,
    ROUND(
      (avg_payroll - LAG(avg_payroll) OVER (ORDER BY year))
      / LAG(avg_payroll) OVER (ORDER BY year) * 100, 2
    ) AS percent
  FROM avg_payroll
)
SELECT *
FROM payroll_changes
WHERE 
	year >= 2007
;

SELECT
	vpg.YEAR,
	vpg.PERCENT AS price_percent,
	vsg.PERCENT AS payroll_percent,
	CASE
		WHEN (vpg.PERCENT - vsg.percent) > 10 THEN 1
		ELSE 0
	END gap_over_10_percent
FROM v_price_growth vpg
JOIN v_salary_growth vsg
	ON vpg.year = vsg.YEAR
; 
--Na základě analýzy průměrného meziročního růstu cen potravin a průměrného růstu mezd nebyl v žádném roce identifikován 
--rozdíl větší než 10 %.

--Otázka č. 5 Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
--projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?
SELECT *
FROM t_kristina_dornerova_project_sql_secondary_final tkdpssf 
WHERE country = 'Czech Republic';

CREATE VIEW v_gdp_growth AS 
WITH gdp_percent AS (
	SELECT
		YEAR,
		LAG(gdp) OVER (ORDER BY year) AS prev_gdp,
    	ROUND(
      	(gdp  - LAG(gdp) OVER (ORDER BY year))
      	/ LAG(gdp) OVER (ORDER BY year) * 100, 2
    ) AS percent_gdp
	FROM t_kristina_dornerova_project_sql_secondary_final tkds
	WHERE
	country = 'Czech Republic'
	)
SELECT *
FROM gdp_percent 
WHERE prev_gdp IS NOT null
;

SELECT *
FROM v_gdp_growth;

SELECT
	vpg.YEAR,
	vpg.PERCENT AS price_percent,
	vsg.PERCENT AS payroll_percent,
	vgdp.percent_gdp,
	CASE
    	WHEN vgdp.percent_gdp > 2 AND vsg.percent > 2 AND vpg.percent > 2 THEN 'Růst všech'
    	WHEN vgdp.percent_gdp < 0 AND vsg.percent < 0 AND vpg.percent < 0 THEN 'Pokles všech'
    	WHEN vgdp.percent_gdp > 2 AND vsg.percent < 0 THEN 'Růst HDP, pokles mezd'
    	WHEN vgdp.percent_gdp > 2 AND vpg.percent < 0 THEN 'Růst HDP, pokles cen'
    ELSE 'Žádný jasný trend'
  END AS interpretace
FROM v_price_growth vpg
LEFT JOIN v_salary_growth vsg
	ON vpg.year = vsg.YEAR
LEFT JOIN v_gdp_growth vgdp
	ON vpg."year" = vgdp.YEAR;

--porovnání s náledujícím rokem
SELECT
	vgdp.year AS gdp_year,
	vgdp.percent_gdp AS gdp_percent,
	vsg_same.percent AS payroll_same_year,
	vpg_same.percent AS price_same_year,
	vsg_next.percent AS payroll_next_year,
	vpg_next.percent AS price_next_year,
	CASE
		WHEN vsg_next.percent IS NULL OR vpg_next.percent IS NULL THEN 'Nelze posoudit (chybí následující rok)'
		WHEN vgdp.percent_gdp > 5 AND vsg_same.percent > 5 AND vpg_same.percent > 5 THEN 'Růst všech'
		WHEN vgdp.percent_gdp > 5 AND vsg_next.percent > 5 AND vpg_next.percent > 5 THEN 'Zpožděný růst po HDP'
		WHEN vgdp.percent_gdp > 5 AND (vsg_same.percent < 0 OR vpg_same.percent < 0) THEN 'HDP roste, ostatní stagnují/klesají'
		ELSE 'Žádný jasný trend'
	END AS interpretation
FROM v_gdp_growth vgdp
LEFT JOIN v_salary_growth vsg_same
	ON vsg_same.year = vgdp.year
LEFT JOIN v_price_growth vpg_same
	ON vpg_same.year = vgdp.year
LEFT JOIN v_salary_growth vsg_next 
	ON vsg_next.year = vgdp.year + 1
LEFT JOIN v_price_growth vpg_next	
	ON vpg_next.year = vgdp.year + 1
ORDER BY vgdp.year;

/*
 *Na základě porovnání meziročního růstu HDP, mezd a cen potravin v ČR v letech 2007–2018 nebyla prokázána jednoznačná
 *souvislost mezi růstem HDP a výrazným růstem cen potravin či mezd ve stejném ani v následujícím roce.
 */

