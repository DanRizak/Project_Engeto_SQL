
/*  Projekt SQL - Primární tabulka
*
Tvorba zakladni tabulky pro mzdy*/ 

SELECT pay1.`year`, pay1.industry_branch_code, pay1.value_current_year, pay2.value_prev_year
FROM (
	SELECT payroll_year AS `year`, industry_branch_code, avg(value) AS value_current_year
	FROM czechia_payroll cp 
	WHERE value_type_code = 5958 AND industry_branch_code IS NOT NULL AND payroll_year BETWEEN 2005 AND 2018
	GROUP BY payroll_year, industry_branch_code) AS pay1
LEFT JOIN (
	SELECT payroll_year AS `year`, industry_branch_code, avg(value) AS value_prev_year
	FROM czechia_payroll cp 
	WHERE value_type_code = 5958 AND industry_branch_code IS NOT NULL AND payroll_year BETWEEN 2005 AND 2018
	GROUP BY payroll_year, industry_branch_code) AS pay2
	ON pay1.industry_branch_code = pay2.industry_branch_code
	AND pay1.year = pay2.year+1;

CREATE TABLE t_payroll_temporary AS
SELECT pay1.`year`, pay1.value_current_year, pay2.value_prev_year, pay1.industry_branch_code, cpib.name 
FROM (
	SELECT payroll_year AS `year`, industry_branch_code, avg(value) AS value_current_year
	FROM czechia_payroll cp 
	WHERE value_type_code = 5958 AND calculation_code = 100 AND industry_branch_code IS NOT NULL AND payroll_year BETWEEN 2005 AND 2018
	GROUP BY payroll_year, industry_branch_code) AS pay1
LEFT JOIN (
	SELECT payroll_year AS `year`, industry_branch_code, avg(value) AS value_prev_year
	FROM czechia_payroll cp 
	WHERE value_type_code = 5958 AND calculation_code = 100 AND industry_branch_code IS NOT NULL AND payroll_year BETWEEN 2005 AND 2018
	GROUP BY payroll_year, industry_branch_code) AS pay2
	ON pay1.industry_branch_code = pay2.industry_branch_code
	AND pay1.year = pay2.year+1
LEFT JOIN czechia_payroll_industry_branch cpib
	ON pay1.industry_branch_code = cpib.code;

ALTER TABLE t_payroll_temporary
ADD COLUMN unit VARCHAR(10);

UPDATE t_payroll_temporary
SET unit = 'czk';

ALTER TABLE t_payroll_temporary
RENAME COLUMN name TO category_name;

ALTER TABLE t_payroll_temporary
RENAME COLUMN industry_branch_code TO category_code;

ALTER TABLE t_payroll_temporary
ADD COLUMN region_code CHAR(5);

ALTER TABLE t_payroll_temporary
ADD COLUMN region_name VARCHAR(255);


-- Tvorba zakladni tabulky pro mzdy
SELECT prices.year, prices.value_current_year, prices2.value_prev_year, prices.category_code, prices.region_code
FROM (
	SELECT YEAR(date_to) AS `year`, category_code, region_code, avg(value) AS value_current_year
	FROM czechia_price cp  
	WHERE YEAR(date_to) BETWEEN 2005 AND 2018 AND region_code IS NOT NULL
	GROUP BY YEAR(date_to), category_code, region_code) prices
LEFT JOIN (
	SELECT YEAR(date_to) AS `year`, category_code, region_code, avg(value) AS value_prev_year
	FROM czechia_price cp  
	WHERE YEAR(date_to) BETWEEN 2005 AND 2018 AND region_code IS NOT NULL
	GROUP BY YEAR(date_to), category_code, region_code) prices2
	ON prices.category_code = prices2.category_code
	AND prices.region_code = prices2.region_code
	AND prices.year = prices2.year+1;

CREATE TABLE t_price_temporary AS
SELECT prices.year, prices.value_current_year, prices2.value_prev_year, prices.category_code, prices.region_code
FROM (
	SELECT YEAR(date_to) AS `year`, category_code, region_code, avg(value) AS value_current_year
	FROM czechia_price cp  
	WHERE YEAR(date_to) BETWEEN 2005 AND 2018 AND region_code IS NOT NULL
	GROUP BY YEAR(date_to), category_code, region_code) prices
LEFT JOIN (
	SELECT YEAR(date_to) AS `year`, category_code, region_code, avg(value) AS value_prev_year
	FROM czechia_price cp  
	WHERE YEAR(date_to) BETWEEN 2005 AND 2018 AND region_code IS NOT NULL
	GROUP BY YEAR(date_to), category_code, region_code) prices2
	ON prices.category_code = prices2.category_code
	AND prices.region_code = prices2.region_code
	AND prices.year = prices2.year+1;

-- druhá dočasná tabulka s cenami:
CREATE TABLE t_price_temporary_2 AS
SELECT tpt.*, cpc.name AS category_name, concat(cpc.price_value, ' ', cpc.price_unit) AS unit, cr.name AS region_name
FROM t_price_temporary tpt
JOIN czechia_price_category cpc
	ON tpt.category_code = cpc.code
JOIN czechia_region cr 
	ON tpt.region_code = cr.code;

-- Ze dvou dočasných tab. tvoříme primární
CREATE TABLE t_Daniel_Rizak_project_SQL_primary_final
SELECT `year`, value_current_year, value_prev_year, unit, category_code, category_name, region_code, region_name
FROM t_payroll_temporary tpt 
UNION
SELECT `year`, value_current_year, value_prev_year, unit, category_code, category_name, region_code, region_name
FROM t_price_temporary_2 tpt2;

ALTER TABLE t_Daniel_Rizak_project_SQL_primary_final
ADD COLUMN id INT NOT NULL AUTO_INCREMENT PRIMARY KEY;







