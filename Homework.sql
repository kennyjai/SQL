# Using uploaded Sakila DB
USE sakila;

# 1a Display the first and last names of all actors
SELECT first_name, last_name FROM actor;

# 1b Display the first and last name in a single column (Actor Name) in upper case 
SELECT UPPER(CONCAT(first_name, ' ', last_name)) AS 'Actor Name' FROM actor;

# 2a Find the ID number, first name and last name of an actor whom first name = "Joe"
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "Joe";

# 2b Find all actors whose last name contain the letters GEN
SELECT first_name, last_name FROM actor 
WHERE last_name LIKE '%GEN%';

# 2c. Find all actors whose last names contain the letters LI. 
# order the rows by last name and first name
SELECT last_name, first_name 
FROM actor 
WHERE last_name LIKE '%LI%' 
ORDER BY last_name, first_name;

# 2d. Using IN, display the country_id and country columns of the following countries: 
# Afghanistan, Bangladesh, and China:
SELECT country_id, country 
FROM country 
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

# 3a. You want to keep a description of each actor. 
#You don't think you will be performing queries on a description, 
#so create a column in the table actor named description and use the data type BLOB 
ALTER TABLE actor 
ADD description BLOB;

# for checking purposes
# SELECT * FROM actor;

# 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
# Delete the description column.
ALTER TABLE actor
DROP COLUMN description;

# 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, COUNT(last_name) AS 'Last Name Count' 
FROM actor
GROUP BY last_name;

# 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT last_name, COUNT(last_name) AS last_count
FROM actor
GROUP BY last_name
HAVING last_count > 1;

# 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
# first query to get actor_id
SELECT * FROM actor
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

UPDATE actor
SET first_name = 'HARPO'
WHERE actor_id = 172;

# 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO';

# SELECT * FROM actor WHERE actor_id = 172;

# 5a. You cannot locate the schema of the address table. 
# Which query would you use to re-create it?

SHOW CREATE TABLE address;

# view in viewer to get the schema

CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
)

# 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
# Use the tables staff and address:

SELECT staff.first_name, staff.last_name, address.address
FROM staff
JOIN address ON staff.address_id=address.address_id;

# 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
# Use tables staff and payment.

SELECT CONCAT(staff.first_name, " ", staff.last_name) as staff_member, SUM(payment.amount) as total_amount
FROM payment
JOIN staff USING (staff_id)
WHERE payment.payment_date LIKE '2005-08%'
GROUP BY staff_member;

# 6c. List each film and the number of actors who are listed for that film. 
# Use tables film_actor and film. Use inner join.

SELECT film.title, COUNT(film_actor.actor_id) AS number_of_actors
FROM film
INNER JOIN film_actor ON film.film_id=film_actor.film_id
GROUP BY film.title;

# 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT film.title, COUNT(inventory.inventory_id) AS inventory
FROM inventory
INNER JOIN film ON inventory.film_id=film.film_id
WHERE film.title = 'Hunchback Impossible';

# 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
# List the customers alphabetically by last name:

SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount) AS total_amount
FROM customer c
JOIN payment p USING (customer_id)
GROUP BY c.customer_id
ORDER by c.last_name;


/* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
Use subqueries to display the titles of movies starting with the letters K and Q whose language is English. */

SELECT title
FROM film
WHERE title LIKE 'k%' OR title LIKE 'q%' AND language_id IN
	(
	SELECT language_id 
	FROM language
	WHERE name = 'English'
	);

# 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT first_name, last_name
FROM actor
WHERE actor_id IN
	(
    SELECT actor_id
    FROM film_actor
    WHERE film_id in
		(
        SELECT film_id
        FROM film
        WHERE title = 'Alone Trip'
        )
	);

# 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
# Use joins to retrieve this information.

SELECT c.first_name, c.last_name, c.email
FROM customer c
LEFT JOIN address USING (address_id)
LEFT JOIN city USING (city_id)
LEFT JOIN country USING (country_id)
WHERE country = 'canada';

# 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
# Identify all movies categorized as family films.

SELECT f.title, c.name
FROM film f
LEFT JOIN film_category USING (film_id)
LEFT JOIN category c USING (category_id)
WHERE c.name = 'family';

# 7e. Display the most frequently rented movies in descending order.

SELECT f.title, COUNT(rental_id) AS 'Times Rented'
FROM rental r
LEFT JOIN inventory USING (inventory_id)
LEFT JOIN film f USING (film_id)
GROUP BY f.title
ORDER BY COUNT(rental_id) DESC;

# 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT s.store_id, SUM(p.amount) AS 'Total Business'
FROM payment p
LEFT JOIN staff USING (staff_id)
LEFT JOIN store s USING (store_id)
GROUP BY store_id;

# 7g. Write a query to display for each store its store ID, city, and country.

SELECT store_id, city, country
FROM store
LEFT JOIN address USING (address_id)
LEFT JOIN city USING (city_id)
LEFT JOIN country USING (country_id);

# 7h. List the top five genres in gross revenue in descending order. 

SELECT c.name AS 'Genre', SUM(p.amount) AS 'Gross Revenue'
FROM payment p
LEFT JOIN rental USING (rental_id)
LEFT JOIN inventory USING (inventory_id)
LEFT JOIN film_category USING (film_id)
LEFT JOIN category c USING (category_id)
GROUP BY c.name 
ORDER BY SUM(p.amount) DESC
LIMIT 5;

# 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 

CREATE VIEW gross_revenue AS 
    SELECT c.name AS 'Genre', SUM(p.amount) AS 'Gross Revenue'
	FROM payment p
	LEFT JOIN rental USING (rental_id)
	LEFT JOIN inventory USING (inventory_id)
	LEFT JOIN film_category USING (film_id)
	LEFT JOIN category c USING (category_id)
	GROUP BY c.name 
	ORDER BY SUM(p.amount) DESC LIMIT 5;

# 8b. How would you display the view that you created in 8a?

SELECT * FROM gross_revenue;

# 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW gross_revenue;

