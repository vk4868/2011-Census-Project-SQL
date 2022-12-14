USE prac;

show tables;
SELECT * FROM table1;
SELECT * FROM table2;

-- number of rows into our dataset
SELECT COUNT(*) FROM table1;
SELECT COUNT(*) FROM table2;

-- dataset for jharkhand and bihar
SELECT * FROM table1 WHERE state in ('Jharkhand', 'Bihar');

-- population of India
SELECT SUM(population) as TotalPopulation FROM table2 ;

-- avg growth
SELECT AVG(GROWTH) *100 AS Average_Growth, State  FROM TABLE1 GROUP BY state ORDER BY Average_Growth Desc limit 3;

-- avg sex ratio
SELECT state, AVG(sex_ratio) as Average_Sex_Ratio FROM table1 GROUP BY state ORDER BY Average_Sex_Ratio LIMIT 3;

-- avg literacy rate
SELECT state, AVG(literacy) as Average_literacy FROM table1 group by state HAVING Average_literacy>90 order by Average_literacy DESC;

SELECT * FROM table1 WHERE state IN ('Kerala', 'Puducherry', 'Daman and Diu');

-- top and bottom 3 states in literacy state
(SELECT state, AVG(literacy) AS Average_literacy FROM table1 GROUP BY state ORDER BY Average_literacy Desc limit 3) 
UNION
(SELECT state, AVG(literacy) AS Average_literacy FROM table1 GROUP BY state ORDER BY Average_literacy asc limit 3)
 ;
SELECT DISTINCT STATE FROM table1 WHERE lower(state) LIKE 'a%';

-- joining both tables
-- total males and females
SELECT d.state, sum(d.males) total_males, sum(d.females) total_females FROM 
(SELECT district,state, round(population/(sex_ratio + 1),0) males, round((population*sex_ratio)/(sex_ratio + 1),0) females from
(SELECT a.district, a.state, a.sex_ratio/1000 sex_ratio, b.population FROM table1 a JOIN table2 b ON a.district = b.district) c) d
GROUP BY d.state;

-- Total literacy rate
SELECT d.state,SUM(literate_people) total_literate_people,SUM(Illiterate_people) total_illiterate_people FROM
(SELECT c.district, c.state, round(c.literacy_ratio*c.population,0) literate_people, round((1-c.literacy_ratio) * c.population,0) Illiterate_people from
(SELECT a.district, a.state, a.literacy/100 Literacy_ratio, b.population FROM table1 a JOIN table2 b ON a.district = b.district) c) d
GROUP BY d.state;

-- Population in previous census
SELECT SUM(m.previous_pop), SUM(m.current_pop) FROM
(SELECT e.state, SUM(e.previous_census_population) previous_pop, SUM(e.current_census_population) current_pop FROM 
(SELECT d.district, d.state, round(population/(1+growth),0) previous_census_population, d.population current_census_population FROM
(SELECT a.district, a.state, a.growth, b.population FROM table1 a JOIN table2 b ON a.district = b.district) d) e
GROUP BY e.state) m;

-- population vs area
SELECT g.total_area / g.previous_popu, g.total_area/ g.current_popu FROM
(SELECT q.*,r.total_area FROM (
SELECT "1" as keyy, n.* FROM
(SELECT SUM(m.previous_pop) previous_popu, SUM(m.current_pop) current_popu FROM
(SELECT e.state, SUM(e.previous_census_population) previous_pop, SUM(e.current_census_population) current_pop FROM 
(SELECT d.district, d.state, round(population/(1+growth),0) previous_census_population, d.population current_census_population FROM
(SELECT a.district, a.state, a.growth, b.population FROM table1 a JOIN table2 b ON a.district = b.district) d) e
GROUP BY e.state) m) n) q INNER JOIN (
SELECT "1" as keyy, z.* FROM
(SELECT SUM(area_km2) total_area FROM table2) z) r on q.keyy = r.keyy) g;

SELECT a.* FROM
(SELECT district, state, literacy, rank() over(partition by state order by literacy desc) rnk from table1) a 

WHERE rnk in (1,2,3) order by state;