
--  Projekt SQL - Sekundární tabulka

-- Základní dotaz, zanořený Select 
SELECT*
FROM economies e 
WHERE e.country IN (
	SELECT c.country 
	FROM countries c 
	WHERE continent = 'Europe'
);

-- tvorba tabulky, chceme běžný a předchozí roky pro HDP
CREATE TABLE t_daniel_rizak_project_sql_secondary_final
WITH half_table AS (
	SELECT*
	FROM economies e 
	WHERE e.country IN (
		SELECT c.country 
		FROM countries c 
		WHERE continent = 'Europe'
)
		AND e.`year` BETWEEN 2004 AND 2018)
SELECT ht1.country, ht1.`year`, ht1.GDP AS GDP_current_year, ht2.GDP AS GDP_previous_year,
	ht1.population, ht1.taxes, ht1.fertility, ht1.mortaliy_under5 AS mortality_under5
FROM half_table ht1
JOIN half_table ht2
	ON ht1.country = ht2.country
		AND ht1.`year` = ht2.`year`+1
ORDER BY country, `year` ASC;


-- Alternativní způsob, jednodušší, využití funkce LAG:
CREATE TABLE t_daniel_rizak_project_sql_secondary_final
SELECT country, `year`, GDP AS GDP_current_year,
	LAG(GDP) OVER (ORDER BY `year`) AS GDP_previous_year,
	population, taxes, fertility, mortaliy_under5 AS mortality_under5
FROM economies e
WHERE e.country IN (
	SELECT c.country 
	FROM countries c 
	WHERE continent = 'Europe'
)
	AND e.`year` BETWEEN 2004 AND 2018
ORDER BY country, `year` ASC;
