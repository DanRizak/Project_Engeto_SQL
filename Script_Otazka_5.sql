
/* Projekt SQL - Otázka 5
Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?    */

-- Růst HDP v rocích N-1 a N a růst mezd v roce N
SELECT base.country, tab1.`year`, tab1.value_current_year/tab1.value_prev_year AS wage_grow_same_year,
	base.GDP_current_year/base.GDP_previous_year AS GDP_grow_prev_year,
	LEAD(base.GDP_current_year,19)OVER(ORDER BY base.`year`)/LEAD(base.GDP_previous_year,19)OVER(ORDER BY base.`year`) AS GDP_grow_same_year,
	tab1.category_name
FROM t_daniel_rizak_project_sql_secondary_final base
JOIN t_daniel_rizak_project_sql_primary_final tab1
	ON base.`year`+1 = tab1.`year`
	AND base.country = 'Czech Republic'
	AND tab1.unit = 'czk';
	
-- Kontrola správného posunutí o 19 pozic
SELECT `year`, value_current_year/value_prev_year AS index_wage, category_name 
FROM t_daniel_rizak_project_sql_primary_final

SELECT `year`, GDP_current_year/GDP_previous_year AS index_GDP
FROM t_daniel_rizak_project_sql_secondary_final tdrpssf 
WHERE country = 'Czech Republic';
-- OK, výše je správné (toto v průvodní listině přeskočeno)

-- Alternativa prvního dotazu bez funkce LEAD:
SELECT tab1.country, base.`year`, base.value_current_year/base.value_prev_year AS wage_grow_same_year,
	tab1.GDP_current_year/tab1.GDP_previous_year AS GDP_grow_prev_year,
	tab2.GDP_current_year/tab2.GDP_previous_year AS GDP_grow_same_year,
	base.category_name
FROM t_daniel_rizak_project_sql_primary_final base
JOIN t_daniel_rizak_project_sql_secondary_final tab1
	ON base.`year` = tab1.`year`+1
	AND tab1.country = 'Czech Republic'
	AND base.unit = 'czk'
JOIN t_daniel_rizak_project_sql_secondary_final tab2
	ON base.`year` = tab2.`year`
	AND tab2.country = 'Czech Republic'
	AND base.unit = 'czk';

	
-- CENY a HDP. (Nelze použít variantu s LEAD, kvůli jakostnímu vínu (měřeno jen 4 roky))
SELECT tab1.country, base.`year`, base.value_current_year/base.value_prev_year AS price_grow_same_year,
	tab1.GDP_current_year/tab1.GDP_previous_year AS GDP_grow_prev_year,
	tab2.GDP_current_year/tab2.GDP_previous_year AS GDP_grow_same_year,
	base.category_name, base.region_name 
FROM t_daniel_rizak_project_sql_primary_final base
JOIN t_daniel_rizak_project_sql_secondary_final tab1
	ON base.`year` = tab1.`year`+1
	AND tab1.country = 'Czech Republic' 
	AND base.unit != 'czk'
JOIN t_daniel_rizak_project_sql_secondary_final tab2
	ON base.`year` = tab2.`year`
	AND tab2.country = 'Czech Republic' 
	AND base.unit != 'czk' 
	AND base.`year` > 2006;


-- Indexy růstu - vzájemné závislosti: MZDY
SELECT trends1.*,
		CASE
			WHEN trends1.wage_grow_same_year > 1 AND trends1.GDP_grow_prev_year > 1 THEN 1
			WHEN trends1.wage_grow_same_year < 1 AND trends1.GDP_grow_prev_year < 1 THEN 1
			ELSE 0
		END wages_and_Y_previous,
		CASE
			WHEN trends1.wage_grow_same_year > 1 AND trends1.GDP_grow_same_year > 1 THEN 1
			WHEN trends1.wage_grow_same_year < 1 AND trends1.GDP_grow_same_year < 1 THEN 1
			ELSE 0
		END wages_and_Y_same
FROM (
	SELECT base.country, tab1.`year`, tab1.value_current_year/tab1.value_prev_year AS wage_grow_same_year,
		base.GDP_current_year/base.GDP_previous_year AS GDP_grow_prev_year,
		LEAD(base.GDP_current_year,19)OVER(ORDER BY base.`year`)/LEAD(base.GDP_previous_year,19)OVER(ORDER BY base.`year`) AS GDP_grow_same_year,
		tab1.category_name
	FROM t_daniel_rizak_project_sql_secondary_final base
	JOIN t_daniel_rizak_project_sql_primary_final tab1
		ON base.`year`+1 = tab1.`year`
		AND base.country = 'Czech Republic' 
		AND tab1.unit = 'czk'
) trends1;
	
-- Indexy růstu - vzájemné závislosti: CENY
SELECT trends2.*,
	CASE
		WHEN trends2.price_grow_same_year > 1 AND trends2.GDP_grow_prev_year > 1 THEN 1
		WHEN trends2.price_grow_same_year < 1 AND trends2.GDP_grow_prev_year < 1 THEN 1
		ELSE 0
	END prices_and_Y_previous,
	CASE
		WHEN trends2.price_grow_same_year > 1 AND trends2.GDP_grow_same_year > 1 THEN 1
		WHEN trends2.price_grow_same_year < 1 AND trends2.GDP_grow_same_year < 1 THEN 1
		ELSE 0
	END prices_and_Y_same
FROM (
	SELECT tab1.country, base.`year`, base.value_current_year/base.value_prev_year AS price_grow_same_year,
		tab1.GDP_current_year/tab1.GDP_previous_year AS GDP_grow_prev_year,
		tab2.GDP_current_year/tab2.GDP_previous_year AS GDP_grow_same_year,
		base.category_name, base.region_name 
	FROM t_daniel_rizak_project_sql_primary_final base
	JOIN t_daniel_rizak_project_sql_secondary_final tab1
		ON base.`year` = tab1.`year`+1
		AND tab1.country = 'Czech Republic' 
		AND base.unit != 'czk'
	JOIN t_daniel_rizak_project_sql_secondary_final tab2
		ON base.`year` = tab2.`year`
		AND tab2.country = 'Czech Republic' 
		AND base.unit != 'czk' 
		AND base.`year` > 2006
) AS trends2;


-- Frekvence výskytu, kde HDP a mzdy mají stejný trend růstu/poklesu
SELECT sum(wages_and_Y_previous), sum(wages_and_Y_same), count(1) AS total_cases
FROM (
	SELECT trends1.*,
		CASE
			WHEN trends1.wage_grow_same_year > 1 AND trends1.GDP_grow_prev_year > 1 THEN 1
			WHEN trends1.wage_grow_same_year < 1 AND trends1.GDP_grow_prev_year < 1 THEN 1
			ELSE 0
		END wages_and_Y_previous,
		CASE
			WHEN trends1.wage_grow_same_year > 1 AND trends1.GDP_grow_same_year > 1 THEN 1
			WHEN trends1.wage_grow_same_year < 1 AND trends1.GDP_grow_same_year < 1 THEN 1
			ELSE 0
		END wages_and_Y_same
	FROM (
		SELECT base.country, tab1.`year`, tab1.value_current_year/tab1.value_prev_year AS wage_grow_same_year,
			base.GDP_current_year/base.GDP_previous_year AS GDP_grow_prev_year,
			LEAD(base.GDP_current_year,19)OVER(ORDER BY base.`year`)/LEAD(base.GDP_previous_year,19)OVER(ORDER BY base.`year`) AS GDP_grow_same_year,
			tab1.category_name
		FROM t_daniel_rizak_project_sql_secondary_final base
		JOIN t_daniel_rizak_project_sql_primary_final tab1
			ON base.`year`+1 = tab1.`year`
			AND base.country = 'Czech Republic' 
			AND tab1.unit = 'czk'
	) trends1
) frequency1;

-- Frekvence výskytu, kde HDP a ceny mají stejný trend růstu/poklesu
SELECT sum(prices_and_Y_previous), sum(prices_and_Y_same), count(1) AS total_cases
FROM (
	SELECT trends2.*,
		CASE
			WHEN trends2.price_grow_same_year > 1 AND trends2.GDP_grow_prev_year > 1 THEN 1
			WHEN trends2.price_grow_same_year < 1 AND trends2.GDP_grow_prev_year < 1 THEN 1
			ELSE 0
		END prices_and_Y_previous,
		CASE
			WHEN trends2.price_grow_same_year > 1 AND trends2.GDP_grow_same_year > 1 THEN 1
			WHEN trends2.price_grow_same_year < 1 AND trends2.GDP_grow_same_year < 1 THEN 1
			ELSE 0
		END prices_and_Y_same
	FROM (
		SELECT tab1.country, base.`year`, base.value_current_year/base.value_prev_year AS price_grow_same_year,
			tab1.GDP_current_year/tab1.GDP_previous_year AS GDP_grow_prev_year,
			tab2.GDP_current_year/tab2.GDP_previous_year AS GDP_grow_same_year,
			base.category_name, base.region_name 
		FROM t_daniel_rizak_project_sql_primary_final base
		JOIN t_daniel_rizak_project_sql_secondary_final tab1
			ON base.`year` = tab1.`year`+1
			AND tab1.country = 'Czech Republic' 
			AND base.unit != 'czk'
		JOIN t_daniel_rizak_project_sql_secondary_final tab2
			ON base.`year` = tab2.`year`
			AND tab2.country = 'Czech Republic'
			AND base.unit != 'czk' 
			AND base.`year` > 2006
	) AS trends2
) frequency2;


-- Frekvence výskytu, HDP a mzdy, v jednotlivých letech -> přidáno Group By Year
SELECT `year`, sum(wages_and_Y_previous), count(wages_and_Y_previous), sum(wages_and_Y_same), count(wages_and_Y_same)
FROM (
	SELECT trends1.*,
		CASE
			WHEN trends1.wage_grow_same_year > 1 AND trends1.GDP_grow_prev_year > 1 THEN 1
			WHEN trends1.wage_grow_same_year < 1 AND trends1.GDP_grow_prev_year < 1 THEN 1
			ELSE 0
		END wages_and_Y_previous,
		CASE
			WHEN trends1.wage_grow_same_year > 1 AND trends1.GDP_grow_same_year > 1 THEN 1
			WHEN trends1.wage_grow_same_year < 1 AND trends1.GDP_grow_same_year < 1 THEN 1
			ELSE 0
		END wages_and_Y_same
	FROM (
		SELECT base.country, tab1.`year`, tab1.value_current_year/tab1.value_prev_year AS wage_grow_same_year,
			base.GDP_current_year/base.GDP_previous_year AS GDP_grow_prev_year,
			LEAD(base.GDP_current_year,19)OVER(ORDER BY base.`year`)/LEAD(base.GDP_previous_year,19)OVER(ORDER BY base.`year`) AS GDP_grow_same_year,
			tab1.category_name
		FROM t_daniel_rizak_project_sql_secondary_final base
		JOIN t_daniel_rizak_project_sql_primary_final tab1
			ON base.`year`+1 = tab1.`year`
			AND base.country = 'Czech Republic'
			AND tab1.unit = 'czk'
	) trends1
) frequency1
GROUP BY YEAR;

-- Frekvence výskytu, HDP a ceny, v jednotlivých letech -> přidáno Group By Year
SELECT `year`, sum(prices_and_Y_previous), count(prices_and_Y_previous), sum(prices_and_Y_same), count(prices_and_Y_same)
FROM (
	SELECT trends2.*,
		CASE
			WHEN trends2.price_grow_same_year > 1 AND trends2.GDP_grow_prev_year > 1 THEN 1
			WHEN trends2.price_grow_same_year < 1 AND trends2.GDP_grow_prev_year < 1 THEN 1
			ELSE 0
		END prices_and_Y_previous,
		CASE
			WHEN trends2.price_grow_same_year > 1 AND trends2.GDP_grow_same_year > 1 THEN 1
			WHEN trends2.price_grow_same_year < 1 AND trends2.GDP_grow_same_year < 1 THEN 1
			ELSE 0
		END prices_and_Y_same
	FROM (
		SELECT tab1.country, base.`year`, base.value_current_year/base.value_prev_year AS price_grow_same_year,
				tab1.GDP_current_year/tab1.GDP_previous_year AS GDP_grow_prev_year,
				tab2.GDP_current_year/tab2.GDP_previous_year AS GDP_grow_same_year,
				base.category_name, base.region_name 
		FROM t_daniel_rizak_project_sql_primary_final base
		JOIN t_daniel_rizak_project_sql_secondary_final tab1
			ON base.`year` = tab1.`year`+1
			AND tab1.country = 'Czech Republic'
			AND base.unit != 'czk'
		JOIN t_daniel_rizak_project_sql_secondary_final tab2
			ON base.`year` = tab2.`year`
			AND tab2.country = 'Czech Republic'
			AND base.unit != 'czk'
			AND base.`year` > 2006
	) AS trends2
) frequency2
GROUP BY YEAR;
