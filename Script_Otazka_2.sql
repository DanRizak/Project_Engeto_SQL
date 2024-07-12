
/*  Projekt SQL - Otázka 2
Kolik je možné si koupit litrů mléka a kg chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?   */

-- Zjistujeme pro chleba:
SELECT fin1.`year`, fin1.value_current_year AS avg_wage_sector, fin1.category_name AS sector,
	fin2.value_current_year AS bread_price_CZK_region, fin2.region_name,
	round(fin1.value_current_year/fin2.value_current_year) AS bread_kg_for_wage
FROM (
	SELECT `year`, value_current_year, category_name    -- prumerne vyplaty ve 2006 a 2018 podle odvetvi
	FROM t_daniel_rizak_project_sql_primary_final 
	WHERE unit = 'czk'
		AND `year` IN (2006, 2018)
) fin1
JOIN (
	SELECT `year`, value_current_year, category_name, region_name, category_code   -- prumerne ceny chleba ve 2006 a 2018 podle kraju
	FROM t_daniel_rizak_project_sql_primary_final
	WHERE unit != 'czk' 
		AND `year` IN (2006, 2018) 
		AND category_code = '111301'
) fin2
	ON fin1.`year` = fin2.`year`;

-- pridame klauzuli Order By
SELECT fin1.`year`, fin1.value_current_year AS avg_wage_sector, fin1.category_name AS sector,
	fin2.value_current_year AS bread_price_CZK_region, fin2.region_name,
	round(fin1.value_current_year/fin2.value_current_year) AS bread_kg_for_wage
FROM (
	SELECT `year`, value_current_year, category_name    -- prumerne vyplaty ve 2006 a 2018 podle odvetvi
	FROM t_daniel_rizak_project_sql_primary_final 
	WHERE unit = 'czk' 
		AND `year` IN (2006, 2018)
) fin1
JOIN (
	SELECT `year`, value_current_year, category_name, region_name, category_code   -- prumerne ceny chleba ve 2006 a 2018 podle kraju
	FROM t_daniel_rizak_project_sql_primary_final
	WHERE unit != 'czk'
		AND `year` IN (2006, 2018)
		AND category_code = '111301'
) fin2
	ON fin1.`year` = fin2.`year`
	ORDER BY bread_kg_for_wage

	
-- Upravime dotaz pro pro mléko:
SELECT fin1.`year`, fin1.value_current_year AS avg_wage_sector, fin1.category_name AS sector,
	fin2.value_current_year AS milk_price_CZK_region, fin2.region_name,
	round(fin1.value_current_year/fin2.value_current_year) AS milk_litres_for_wage
FROM (
	SELECT `year`, value_current_year, category_name  -- prumerne vyplaty ve 2006 a 2018 podle odvetvi
	FROM t_daniel_rizak_project_sql_primary_final 
	WHERE unit = 'czk' 
	AND `year` IN (2006, 2018)
) fin1
JOIN (
	SELECT `year`, value_current_year, category_name, region_name, category_code   -- prumerne ceny mleka ve 2006 a 2018 podle kraju
	FROM t_daniel_rizak_project_sql_primary_final
	WHERE unit != 'czk' 
		AND `year` IN (2006, 2018) 
		AND category_code = '114201'
) fin2
	ON fin1.`year` = fin2.`year`
	ORDER BY milk_litres_for_wage;
