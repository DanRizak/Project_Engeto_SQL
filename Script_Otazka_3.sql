
/*  Projekt SQL - Otázka 3
Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší procentuální meziroční nárůst)?    */

SELECT sum(gr.price_growth_percent) AS sum_growth, gr.category_name, gr.region_name
FROM(
     SELECT `year`, round((value_current_year/value_prev_year-1)*100,2) AS price_growth_percent, category_name, region_name
     FROM t_daniel_rizak_project_sql_primary_final
     WHERE unit != 'czk' AND value_prev_year IS NOT NULL) AS gr
GROUP BY gr.category_name, gr.region_name
ORDER BY sum_growth;


-- jen položky, které zdražily, eliminujeme zlevněné:
SELECT sum(gr.price_growth_percent) AS sum_growth, gr.category_name, gr.region_name
FROM(
     SELECT `year`, round((value_current_year/value_prev_year-1)*100,2) AS price_growth_percent, category_name, region_name
     FROM t_daniel_rizak_project_sql_primary_final
     WHERE unit != 'czk' AND value_prev_year IS NOT NULL) AS gr
GROUP BY gr.category_name, gr.region_name
HAVING  sum_growth >0
ORDER BY sum_growth;
