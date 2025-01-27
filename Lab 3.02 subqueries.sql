USE sakila;
-- 1. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT COUNT(*) AS count_hunchback FROM inventory
WHERE film_id = 
(SELECT film_id FROM film WHERE title = 'Hunchback Impossible');

-- 2. List all films whose length is longer than the average of all the films.
SELECT title FROM film
WHERE length > (SELECT avg(length)
                FROM film)
ORDER BY length DESC;

-- 3. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name FROM
(SELECT first_name, last_name, film_id
FROM actor 
JOIN film_actor ON actor.actor_id = film_actor.actor_id) sub1
WHERE film_id = (SELECT film_id FROM film WHERE title = 'Alone Trip');

-- 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.

SELECT title FROM
(SELECT film.film_id, film.title, film_category.category_id
FROM film 
JOIN film_category ON film.film_id = film_category.film_id) sub1
WHERE category_id IN (SELECT category_id FROM category WHERE name IN ('Family', 'Children'));
-- or
SELECT title FROM film
WHERE film_id in (
SELECT film_id from film_category
	WHERE category_id IN
		(SELECT category_id FROM category
        WHERE name IN ('Family', 'Children'))
        );
-- 5. Get name and email from customers from Canada using subqueries. Do the same with joins. 
-- Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, 
-- that will help you get the relevant information.
SELECT * FROM customer;
SELECT first_name, last_name, email FROM customer
WHERE address_id IN 
	(SELECT address_id FROM address 
			WHERE city_id IN 
	(SELECT city_id FROM city 
			WHERE country_id = (SELECT country_id FROM country WHERE country = 'Canada') 
    ));

SELECT * FROM customer 
JOIN address 
USING (address_id)
JOIN city USING (city_id)
JOIN country USING (country_id)
WHERE country.country = 'Canada';


-- 6. Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that 
-- has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

SELECT title FROM film WHERE film_id IN
(
SELECT film_id 
FROM film_actor 
WHERE actor_id = 
(SELECT actor_id FROM (SELECT COUNT(*) AS count, actor_id
FROM film_actor 
GROUP BY actor_id
ORDER BY count DESC
LIMIT 1) sub) 
);

-- 7. Films rented by most profitable customer. 
-- You can use the customer table and payment table to find the most profitable customer 
-- ie the customer that has made the largest sum of payments

SELECT title FROM film WHERE film_id IN
(SELECT film_id FROM inventory WHERE inventory_id IN
(SELECT inventory_id FROM rental WHERE customer_id IN 
(
SELECT customer_id 
FROM (
SELECT customer_id, SUM(amount) AS total_payment 
FROM payment
GROUP BY customer_id
ORDER BY total_payment DESC
LIMIT 1
	) sub1
)
)
);

/* note for myself:

-- customer_id = 526
SELECT customer_id, SUM(amount) AS total_payment 
FROM payment
GROUP BY customer_id
ORDER BY total_payment DESC
LIMIT 1;   


-- name of the movies customer rented
SELECT title FROM film WHERE film_id IN
(
SELECT film_id FROM inventory WHERE inventory_id IN
(SELECT inventory_id FROM rental WHERE customer_id = 526)
); */

-- 8. Customers who spent more than the average payments.

SELECT first_name, last_name FROM customer WHERE customer_id IN
(
SELECT customer_id FROM
(SELECT customer_id, ROUND(AVG(amount),2) AS average_payment 
FROM payment
GROUP BY customer_id
HAVING average_payment > (SELECT AVG(amount) AS averape_payment FROM payment)
) subs
);
