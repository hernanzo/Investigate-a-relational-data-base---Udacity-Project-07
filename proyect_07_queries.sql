/*Quierie #1 Rental numbers by Family-Friendly Movies subcategories during 2005*/
SELECT t2.category_name, SUM(t2.rental_count) as total_rental_count
FROM
(SELECT
DISTINCT(t1.name) AS category_name,
t1.title AS film_title,
COUNT(t1.rental_num) OVER (PARTITION BY t1.title) AS rental_count
FROM
(SELECT c.name, f.title, r.rental_id AS rental_num
FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN film f
ON fc.film_id = f.film_id
JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')) t1
ORDER BY name) t2
GROUP BY 1

/*Quierie #2 Top Ten rented movies from Family-Friendly category */
SELECT
DISTINCT(t1.name) AS category_name,
t1.title AS film_title,
COUNT(t1.rental_num) OVER (PARTITION BY t1.title) AS rental_count
FROM
(SELECT c.name, f.title, r.rental_id AS rental_num
FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN film f
ON fc.film_id = f.film_id
JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')) t1
ORDER BY rental_count DESC
LIMIT 10;

/*Quierie #3 Family-Friendly movies average rental days */
SELECT DISTINCT(t1.category) AS cat, AVG(t1.rental_duration) OVER (PARTITION BY t1.category) as days_category
FROM
(SELECT c.name category, f.title title, f.rental_duration AS rental_duration, NTILE(4)OVER (PARTITION BY f.rental_duration) AS standard_quartile
FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN film f
ON fc.film_id = f.film_id
WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')) t1
ORDER BY 1

/*Quierie #3.1 Average rental days all categories */
SELECT DISTINCT(t1.category) AS cat, AVG(t1.rental_duration) OVER (PARTITION BY t1.category) as days_category
FROM
(SELECT c.name category, f.title title, f.rental_duration AS rental_duration, NTILE(4)OVER (PARTITION BY f.rental_duration) AS standard_quartile
FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN film f
ON fc.film_id = f.film_id) t1
ORDER BY 1

/*Quierie #4 Family-friendly rental time by lenght quartiles ordered by subcategories */
SELECT  category, standard_quartile, COUNT(t1.standard_quartile)
FROM
	(SELECT c.name category, f.title title, f.rental_duration AS rental_duration, NTILE(4)OVER (ORDER BY f.rental_duration) AS standard_quartile
	FROM category c
	JOIN film_category fc
	ON c.category_id = fc.category_id
	JOIN film f
	ON fc.film_id = f.film_id
	WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')) t1
GROUP BY 1,2
ORDER BY 1,2 ASC

/*Quierie #5 Top ten paying costumers ordered by monthly payments; it shows also the amounts of monthly payments */

SELECT t2.pay_mon AS pay_mon, t2.full_name full_name, COUNT(pay_amount) as pay_amount, SUM(t2.pay_countpermon) countpermon_pay
FROM
	(SELECT DATE_TRUNC('month', payment_date) AS pay_mon, full_name, SUM(p.amount) AS pay_countpermon, COUNT(t1.total_payments) AS pay_amount
	FROM
		(SELECT c.customer_id customer_id, (c.first_name || ' ' || c.last_name) AS full_name, SUM(p.amount) AS total_payments
		FROM customer c
		JOIN payment p
		ON p.customer_id = c.customer_id
		WHERE payment_date >= '2007-01-01' AND payment_date < '2008-01-01'
		GROUP BY c.customer_id
		ORDER BY total_payments DESC
		LIMIT 10) t1
	JOIN payment p
	ON p.customer_id = t1.customer_id
	GROUP BY full_name, p.payment_date
	ORDER BY pay_amount DESC) t2
GROUP BY full_name, pay_amount, pay_mon
ORDER BY 2 ASC
