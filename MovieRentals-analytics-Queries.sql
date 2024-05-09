-- Slide 1 - Query - Question Set #1 , Question 1
-- Chart 1
SELECT 
	c.name AS movie_category,
	count(r.rental_id) AS rental_count
FROM film f 
JOIN film_category fc 
	ON f.film_id = fc.film_id
JOIN category c 
	ON fc.category_id = c.category_id 
	AND c.name in ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
JOIN inventory i 
	ON i.film_id = f.film_id
JOIN rental r 
	on r.inventory_id = i.inventory_id
GROUP BY c.name
ORDER BY 2 desc;
--------------------------------------------
-- Chart 2
SELECT s.*
FROM (
	SELECT 
		f.title AS movie_title,
		COUNT(r.rental_id) AS movie_rental_count
	FROM film f 
	JOIN film_category fc 
		ON f.film_id = fc.film_id
	JOIN category c 
		ON fc.category_id = c.category_id 
		AND c.name = 'Animation'
	JOIN inventory i 
		ON i.film_id = f.film_id
	JOIN rental r 
		on r.inventory_id = i.inventory_id
	GROUP BY f.title
	ORDER BY 2 DESC ) s
LIMIT 5;
----------------------------------------------------------------------

-- Slide 2 - Query - Question Set #1 , Question 3 

SELECT ff.film_category, ff.standard_quartile, COUNT(*) count
FROM 
	(SELECT 
		f.title AS film_title,
		c.name AS film_category,
		f.rental_duration,
		NTILE(4) OVER (order BY f.rental_duration) AS standard_quartile
	 FROM film f
	 JOIN film_category fc 
	 	ON f.film_id = fc.film_id
	 JOIN category c 
	 	ON fc.category_id = c.category_id 
	 	AND c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family','Music')
	) ff
GROUP BY ff.film_category, ff.standard_quartile
ORDER BY 1,2;
----------------------------------------------------------------------

-- Slide 3 - Query - Question Set #2 , Question 2 

SELECT 
	date_trunc('month', pp.payment_date) pay_month,
	cr.fullname,		
	COUNT(pp.payment_id) pay_count_per_month,
	SUM(pp.amount) pay_amount
FROM 
	(SELECT 
	 	ff.customer_id,
		ff.fullname,
		pay_count,
		pay_amount,
		RANK() OVER (ORDER BY pay_amount DESC, pay_count DESC) customer_rank
	FROM
		(SELECT 
		    c.customer_id,
			concat(c.first_name,' ',c.last_name) fullname,
			COUNT(p.payment_id) pay_count,
			SUM(p.amount) pay_amount
		FROM payment p
		JOIN customer c 
		 	ON p.customer_id = c.customer_id
		WHERE date_part('year', p.payment_date)=2007
		GROUP BY 1,2
		) ff
	) cr
JOIN payment pp 
	ON cr.customer_id = pp.customer_id 
	AND cr.customer_rank <= 10	
GROUP BY 1,2	
ORDER BY 2,1;
----------------------------------------------------------------------

-- Slide 4 - Query - Question Set #2 , Question 3 

SELECT 
	pay_month,
	fullname,
	pay_count_per_month,
	pay_amount,	 
	pay_amount - LAG(pay_amount) OVER (PARTITION BY fullname ORDER BY pay_month) AS lag_difference 
from 
	(SELECT 
		date_trunc('month', pp.payment_date) pay_month,
		cr.fullname,		
		COUNT(pp.payment_id) pay_count_per_month,
		SUM(pp.amount) pay_amount
	FROM 
		(SELECT 
			ff.customer_id,
			ff.fullname,
			pay_count,
			pay_amount,
			RANK() OVER (ORDER BY pay_amount DESC, pay_count DESC) customer_rank
		FROM
			(SELECT 
				c.customer_id,
				concat(c.first_name,' ',c.last_name) fullname,
				COUNT(p.payment_id) pay_count,
				SUM(p.amount) pay_amount
			FROM payment p
			JOIN customer c on p.customer_id = c.customer_id
			and date_part('year', p.payment_date)=2007
			GROUP BY 1,2) ff
		) cr
	JOIN payment pp ON cr.customer_id=pp.customer_id AND cr.customer_rank <= 10	
	GROUP BY 1,2) topc
ORDER BY fullname, pay_month;
----------------------------------------------------------------------
