use sakila;

##Step 1: Create a View for Rental Summary
CREATE VIEW customer_rental_summary AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM 
    customer c
    JOIN rental r ON c.customer_id = r.customer_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name, c.email;

#Step 2: Create a Temporary Table for Payment Summary
CREATE TEMPORARY TABLE customer_payment_summary AS (
    SELECT 
        crs.customer_id,
        SUM(p.amount) AS total_paid
    FROM 
        customer_rental_summary crs
        JOIN rental r ON crs.customer_id = r.customer_id
        JOIN payment p ON r.rental_id = p.rental_id
    GROUP BY 
        crs.customer_id
);

##Step 3: Create a CTE and Generate the Customer Summary Report
WITH customer_summary AS (
    SELECT 
        crs.first_name,
        crs.last_name,
        crs.email,
        crs.rental_count,
        cps.total_paid,
        (cps.total_paid / crs.rental_count) AS average_payment_per_rental
    FROM 
        customer_rental_summary crs
        JOIN customer_payment_summary cps ON crs.customer_id = cps.customer_id
)
SELECT 
    first_name,
    last_name,
    email,
    rental_count,
    total_paid,
    average_payment_per_rental
FROM 
    customer_summary;