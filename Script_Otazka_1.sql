
/*  Projekt SQL - Otázka 1
Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?   */

SELECT `year`, category_name, growth
FROM (
	SELECT `year`, value_current_year/value_prev_year, category_name,
		CASE WHEN value_current_year/value_prev_year > 1 THEN 1
		ELSE 0
		END AS growth
	FROM t_daniel_rizak_project_sql_primary_final tdrpspf 
	WHERE unit = 'czk'
		AND value_prev_year IS NOT NULL
) AS gr;
	
-- jen případy, kde mzdy klesají, tj. kde growth je roven 0:
SELECT `year`, category_name, growth
FROM (
	SELECT `year`, value_current_year/value_prev_year, category_name,
		CASE WHEN value_current_year/value_prev_year > 1 THEN 1
		ELSE 0
		END AS growth
	FROM t_daniel_rizak_project_sql_primary_final tdrpspf 
	WHERE unit = 'czk' 
		AND value_prev_year IS NOT NULL
) AS gr
WHERE growth = 0
ORDER BY category_name, `year`;

-- Řazení primárně podle roků:
SELECT `year`, category_name, growth
FROM (
	SELECT `year`, value_current_year/value_prev_year, category_name,
		CASE WHEN value_current_year/value_prev_year > 1 THEN 1
		ELSE 0
		END AS growth
	FROM t_daniel_rizak_project_sql_primary_final tdrpspf 
	WHERE unit = 'czk'
		AND value_prev_year IS NOT NULL
) AS gr
WHERE growth = 0
ORDER BY `year`, category_name;

/* Export vzniklé tabulky z dotazu výše:
 - klik pravým tlačítkem na tabulku, vybrat "Export data", vybrat CSV, klik 4x "Next", klik na "Proceed"
 - otevřít v Excelu: klik na horní lištu "Data" a na kartě Get&Transform Data vybrat "From Text/CSV", vybrat soubor .csv
 - upravit, uložit; importováno do Průvodní listiny  /*
