-- Start of "Part 1" (https://www.geeksengine.com/database/problem-solving/northwind-queries-part-1.php)
-- For each order, calculate a subtotal. 
SELECT orders.order_id, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as Subtotal, COUNT(products.product_id) as "Products"
FROM orders 
JOIN order_details ON orders.order_id = order_details.order_id
JOIN products ON order_details.product_id = products.product_id
GROUP BY orders.order_id
ORDER BY orders.order_id;

-- Find the total amount of orders for each year.
SELECT YEAR(orders.order_date) AS Year, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as Subtotal
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
GROUP BY Year;

-- Find all sales; describe each sale (order id, shipped date, subtotal, year) and order by the most recent orders.
SELECT orders.order_id AS OrderID, orders.shipped_date AS ShippedDate, b.Subtotal, YEAR(orders.shipped_date) as Year
FROM orders
JOIN (
	SELECT order_details.order_id, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as Subtotal
	FROM order_details
	GROUP BY order_details.order_id
) AS b
ON orders.order_id = b.order_id
ORDER BY Year DESC;

-- For each employee, get their total sales amount per country.
SELECT orders.ship_country, employees.first_name, employees.last_name, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as Subtotal
FROM order_details
JOIN orders ON order_details.order_id = orders.order_id
JOIN employees ON orders.employee_id = employees.employee_id
GROUP BY orders.employee_id, orders.ship_country
ORDER BY orders.employee_id;

-- For each employee, get their sales details broken down by country.
SELECT orders.ship_country, orders.order_id, employees.first_name, employees.last_name, b.Subtotal
FROM orders
JOIN employees ON orders.employee_id = employees.employee_id
JOIN (
	SELECT order_details.order_id, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as Subtotal
	FROM order_details
	GROUP BY order_details.order_id
) as b
ON orders.order_id = b.order_id
ORDER BY employees.first_name, employees.last_name, orders.ship_country;

-- Alphabetical list of products
SELECT DISTINCT products.*
FROM products
WHERE products.discontinued = 0
ORDER BY products.product_name;

-- Current product list
SELECT DISTINCT products.*
FROM products
WHERE products.discontinued = 0;

-- Start of "Part 2" (https://www.geeksengine.com/database/problem-solving/northwind-queries-part-2.php)
-- Order details extended; this query calculates sales price for each order after discount is applied.
SELECT order_details.order_id as OrderID, order_details.product_id as ProductID, products.product_name as ProductName, order_details.unit_price as UnitPrice, order_details.quantity as Quantity, order_details.discount as OrderDiscount, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as Subtotal
FROM order_details
JOIN products ON order_details.product_id = products.product_id
GROUP BY OrderID, ProductID, UnitPrice, Quantity, OrderDiscount;

-- Sales by category; for each category, we get the list of products sold and the total sales amount.
SELECT categories.category_name, products.product_name, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as Subtotal
FROM categories
JOIN products USING (category_id)
JOIN order_details USING (product_id)
GROUP BY categories.category_id, categories.category_name, products.product_name;

-- Ten most expensive producs
SELECT products.product_name, products.unit_price
FROM products
ORDER BY products.unit_price DESC
LIMIT 10;

-- Products by category
SELECT DISTINCT categories.category_name, products.product_name
FROM categories
JOIN products ON categories.category_id = products.category_id
ORDER BY categories.category_name, products.product_name;

-- Active products by category
SELECT DISTINCT categories.category_name, products.product_name, products.discontinued
FROM categories
JOIN products ON categories.category_id = products.category_id
WHERE products.discontinued = 0
ORDER BY categories.category_name, products.product_name;

-- Customers and suppliers by city
SELECT customers.city, customers.company_name, customers.contact_name, 'Customers' AS Relationship
FROM customers
UNION
SELECT suppliers.city, suppliers.company_name, suppliers.contact_name, 'Suppliers'
FROM suppliers;

-- Start of "Part 3" (https://www.geeksengine.com/database/problem-solving/northwind-queries-part-3.php)
-- Products above average price
SELECT products.product_name, products.unit_price
FROM products
WHERE products.unit_price > (
	SELECT AVG(products.unit_price)
	FROM products
)
ORDER BY products.unit_price;

-- Product sales for 1997
SELECT orders.order_id, categories.category_name, products.product_name, order_details.quantity, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as Subtotal
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
JOIN products ON order_details.product_id = products.product_id
JOIN categories ON products.category_id = categories.category_id
WHERE YEAR(orders.order_date) = 1997
GROUP BY orders.order_id, categories.category_name, products.product_name, order_details.quantity;

-- Category sales for 1997
SELECT categories.category_name, FORMAT(SUM(order_details.unit_price * order_details.quantity * (1 - discount)), 2) as Subtotal
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
JOIN products ON order_details.product_id = products.product_id
JOIN categories ON products.category_id = categories.category_id
WHERE YEAR(orders.order_date) = 1997
GROUP BY categories.category_name;



-- Quarterly Orders by Product
SELECT products.product_name, customers.company_name, YEAR(orders.order_date),
	FORMAT(SUM(CASE QUARTER(orders.order_date) 
					WHEN '1' THEN order_details.unit_price * order_details.quantity * (1 - discount) 
						ELSE 0 
                    END), 0) AS "Qtr 1",
	FORMAT(SUM(CASE QUARTER(orders.order_date) 
					WHEN '2' THEN order_details.unit_price * order_details.quantity * (1 - discount) 
						ELSE 0 
                    END), 0) AS "Qtr 2",
	FORMAT(SUM(CASE QUARTER(orders.order_date) 
					WHEN '3' THEN order_details.unit_price * order_details.quantity * (1 - discount) 
						ELSE 0 
                    END), 0) AS "Qtr 3",        
	FORMAT(SUM(CASE QUARTER(orders.order_date) 
					WHEN '4' THEN order_details.unit_price * order_details.quantity * (1 - discount) 
						ELSE 0 
                    END), 0) AS "Qtr 4"
FROM products
JOIN order_details ON products.product_id = order_details.product_id
JOIN orders ON order_details.order_id = orders.order_id
JOIN customers ON orders.customer_id = customers.customer_id
WHERE YEAR(orders.order_date) = 1997
GROUP BY products.product_name, customers.company_name, YEAR(orders.order_date)
ORDER BY products.product_name, customers.company_name;

-- Invoice; A simple query to get detailed information for each sale so that invoice can be issued.
SELECT orders.order_id AS OrderID,
    customers.company_name AS CustomerCompany, 
    customers.contact_name AS CustomerContact, 
    customers.phone AS CustomerPhone,
    orders.employee_id AS EmployeeOfSale, 
    CONCAT(employees.first_name, " ", employees.last_name) AS SalesPerson,
    order_details.quantity AS ProductCount,
    products.product_name AS ProductName,
    order_details.unit_price * order_details.quantity * (1 - discount) as Subtotal,
    orders.order_date AS OrderDate, 
    orders.required_date AS RequiredDate, 
    orders.shipped_date AS ShippedDate, 
    shippers.company_name AS ShippingCompany,
    shippers.phone AS ShippingCoPhone,
    orders.freight AS Freight,
    orders.ship_name AS ShippingLabelName, 
    orders.ship_address AS ShippingLabelAddress, 
    orders.ship_city AS ShippingLabelCity,
    orders.ship_postal_code AS ShippingLabelZIP, 
    orders.ship_country AS ShippingLabelCountry
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
JOIN customers ON orders.customer_id = customers.customer_id
JOIN products ON order_details.product_id = products.product_id
JOIN employees ON orders.employee_id = employees.employee_id
JOIN shippers ON orders.ship_via = shippers.shipper_id
ORDER BY orders.order_id;

-- Number of units in stock by category and supplier continent
SELECT categories.category_name AS Category, suppliers.region AS Region, SUM(products.units_in_stock) AS UnitsInStock
FROM categories
JOIN products ON categories.category_id = products.category_id
JOIN suppliers ON products.supplier_id = suppliers.supplier_id
GROUP BY categories.category_name, suppliers.region;

-- OR
SELECT categories.category_name AS Category,
	CASE
		WHEN suppliers.country IN ('UK', 'Sweden', 'Germany', 'France', 'Italy', 'Spain', 'Denmark', 'Netherlands', 'Finland', 'Norway') THEN 'EMEA'
        WHEN suppliers.country IN ('USA', 'Canada') THEN 'NA'
        WHEN suppliers.country IN ('Brazil') THEN 'LATAM'
        WHEN suppliers.country IN ('Japan', 'Singapore', 'Australia') THEN 'APAC'
        ELSE 'Unknown country; cannot find region'
    END as 'SupplierContinent', 
    SUM(products.units_in_stock) AS UnitsInStock
FROM categories
JOIN products ON categories.category_id = products.category_id
JOIN suppliers ON products.supplier_id = suppliers.supplier_id
GROUP BY categories.category_name, 
	CASE
		WHEN suppliers.country IN ('UK', 'Sweden', 'Germany', 'France', 'Italy', 'Spain', 'Denmark', 'Netherlands', 'Finland', 'Norway') THEN 'EMEA'
        WHEN suppliers.country IN ('USA', 'Canada') THEN 'NA'
        WHEN suppliers.country IN ('Brazil') THEN 'LATAM'
        WHEN suppliers.country IN ('Japan', 'Singapore', 'Australia') THEN 'APAC'
        ELSE 'Unknown country; cannot find region'
    END;
    
    
-- Start of custom queries; focused on product performance
-- Top categories per region
SELECT products.product_name, categories.category_name, orders.ship_region
FROM products
JOIN categories ON products.category_id = categories.category_id
JOIN order_details ON products.product_id = order_details.product_id
JOIN orders ON order_details.order_id = orders.order_id
WHERE orders.ship_region IS NOT NULL;

-- Update region in country to state
-- Update ship_region in orders to state
-- Add region to both tables; fill in with world regions
-- Add some orders with the APAC region
SET SQL_SAFE_UPDATES = 0;
SELECT * FROM employees;

CREATE TABLE employees_updated (
	employee_id SMALLINT,
    last_name VARCHAR(20) NOT NULL,
    first_name VARCHAR(20) NOT NULL,
    title VARCHAR(30),
    title_of_courtesy VARCHAR(25),
    birth_date DATE,
    hire_date DATE,
    address VARCHAR(60),
    city VARCHAR(15),
    state VARCHAR(15),
    postal_code VARCHAR(10),
    country VARCHAR(15),
    region SMALLINT,
    home_phone VARCHAR(24),
    extension VARCHAR(4),
    photo BLOB,
    notes TEXT,
    reports_to SMALLINT,
    photo_path VARCHAR(255),
    PRIMARY KEY (employee_id)
);

INSERT INTO employees_updated (employee_id, last_name, first_name, title, title_of_courtesy, birth_date, hire_date, address, city, state, postal_code, country, region, home_phone, extension, photo, notes, reports_to, photo_path)
SELECT employee_id, last_name, first_name, title, title_of_courtesy, birth_date, hire_date, address, city, state, postal_code, country, region, home_phone, extension, photo, notes, reports_to, photo_path
FROM employees;

SELECT * FROM employees_updated;

DESCRIBE employees;

ALTER TABLE employees
CHANGE region state VARCHAR(15);
DESCRIBE employees;

SELECT orders.ship_city, orders.ship_region, orders.ship_country
FROM orders;

SELECT * FROM suppliers;