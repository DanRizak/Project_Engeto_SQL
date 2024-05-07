
/*  Projekt SQL - Otázka 4
Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?   */

-- indexy cen zboží v letech 2006-2018:
SELECT `year`, avg(value_current_year/value_prev_year) AS grow_prices, category_name
FROM t_daniel_rizak_project_sql_primary_final 
WHERE unit != 'czk'
GROUP BY category_name, `year`;
	
-- indexy mezd v letech 2006-2018:
SELECT `year`, avg(value_current_year/value_prev_year) AS grow_wages
FROM t_daniel_rizak_project_sql_primary_final
WHERE unit = 'czk'
GROUP BY `year`;


SELECT pri.`year`, pri.grow_prices, pri.category_name, pay.grow_wages,
	CASE WHEN pri.grow_prices-pay.grow_wages >0.1 THEN 'YES'
	ELSE 'no'
	END AS prices_growth_much_higher
FROM (
	SELECT `year`, avg(value_current_year/value_prev_year) AS grow_prices, category_name
	FROM t_daniel_rizak_project_sql_primary_final 
	WHERE unit != 'czk'
	GROUP BY category_name, `year`) pri
JOIN (
	SELECT `year`, avg(value_current_year/value_prev_year) AS grow_wages
	FROM t_daniel_rizak_project_sql_primary_final
	WHERE unit = 'czk'
	GROUP BY `year`) pay
	ON pri.`year` = pay.`year`
HAVING pri.grow_prices != 'czk';


-- chci jen hodnoty, kde ceny rostou nejméně o 10% víc než mzdy
SELECT pri.`year`, pri.grow_prices, pri.category_name, pay.grow_wages,
	CASE WHEN pri.grow_prices-pay.grow_wages >0.1 THEN 'YES'
	ELSE 'no'
	END AS prices_growth_much_higher
FROM (
	SELECT `year`, avg(value_current_year/value_prev_year) AS grow_prices, category_name
	FROM t_daniel_rizak_project_sql_primary_final 
	WHERE unit != 'czk'
	GROUP BY category_name, `year`) pri
JOIN (
	SELECT `year`, avg(value_current_year/value_prev_year) AS grow_wages
	FROM t_daniel_rizak_project_sql_primary_final
	WHERE unit = 'czk'
	GROUP BY `year`) pay
	ON pri.`year` = pay.`year`
HAVING pri.grow_prices IS NOT NULL AND prices_growth_much_higher LIKE 'YES'
ORDER BY `year`;

