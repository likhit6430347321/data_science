.open restaurant.db
.mode column
.header on

DROP TABLE menu;
DROP TABLE food_type;
DROP TABLE members;
DROP TABLE orders;
DROP TABLE employees;

--create menu table
CREATE TABLE IF NOT EXISTS menu (
  menu_id int NOT NULL PRIMARY KEY ,
  menu_name TEXT,
  menu_price REAL
);

--insert into menu
INSERT INTO menu values
  (1, 'Kaprao rice', 59.00),
  (2, 'Shoyu Ramen', 89.00),
  (3, 'Fried rice', 59.00),
  (4, 'French fries', 39.00),
  (5, 'Salad', 49.00),
  (6, 'Salmon steak', 109.00),
  (7, 'Curry rice', 79.00),
  (8, 'Pancake', 49.00),
  (9, 'Gyoza', 39.00),
  (10, 'Baked potato', 49.00),
  (11, 'Iced Latte', 29.00),
  (12, 'Iced tea', 9.00),
  (13, 'Soft drinks', 15.00),
  (14, 'Lemon tea', 17.00),
  (15, 'Cocoa', 19.00),
  (16, 'Blueberry muffin', 39.00),
  (17, 'Scone', 39.00),
  (18, 'Fresh fruits', 49.00),
  (19, 'Spaghetti', 99.00),
  (20, 'Hamburgers', 59.00);

--Create food type table
CREATE TABLE IF NOT EXISTS food_type (
  menu_id int,
  menu_type TEXT
);


--insert into food type
INSERT INTO food_type values
  (1, 'Main_dish'),
  (2, 'Main_dish'),
  (3, 'Main_dish'),
  (4, 'Side_dish'),
  (5, 'Side_dish'),
  (6, 'Main_dish'),
  (7, 'Main_dish'),
  (8, 'Dessert'),
  (9, 'Side_dish'),
  (10, 'Side_dish'),
  (11, 'Drinks'),
  (12, 'Drinks'),
  (13, 'Drinks'),
  (14, 'Drinks'),
  (15, 'Drinks'),
  (16, 'Dessert'),
  (17, 'Dessert'),
  (18, 'Dessert'),
  (19, 'Main_dish'),
  (20, 'Main_dish');
  
    
--create members table
CREATE TABLE IF NOT EXISTS members (
  member_id TEXT NOT NULL PRIMARY KEY,
  firstname TEXT,
  lastname TEXT,
  email TEXT,
  phone_number TEXT,
  DateOfBirth DATE
);
--Insert into members
INSERT INTO members VALUES 
  (1, 'Makaila', 'Knapp', 'makalia25@gmail.com', '093-339-2832', '1987-01-31' ),
  (5, 'Megan', 'Maxwell', 'megmax@outlook.co.uk', '094-993-2322', '1993-04-25'),
  (7, 'Kingston', "Welch", 'kingstonishere@ymail.com', '049-385-2453', '1998-12-09'),
  (9, 'Everlyn', 'Jefferson', 'eviejeff@gmail.com', '099-333-8584', '2000-06-06'),
  (12, 'Jerimiah', 'Payne', 'Jemiapayne@outlook.com', '092-544-5356', '1976-09-13'),
  (14, 'Laney', 'Robbins', 'laneynotlany@hotmail.com', '034-252-1222', '1984-06-24'),
  (15, 'Risey', 'Itche', 'riseyitche@yahoo.com', '094-229-4332', '1984-12-31'),
  (20, 'David', 'Mistherford', 'davelnwzaa007@gmail.com', '039-292-8242', '2003-04-15'),
  (23, 'David', 'Duarte', 'david309@gmail.com', '092-948-4353', '1988-08-23');

--create orders table
CREATE TABLE orders (
  order_id TEXT,
  menu_id TEXT,
  quantity INT,
  date DATE
  );


--insert into orders
INSERT INTO orders VALUES
  (1, 2, 3, '2022-09-26'),
  (1, 3, 2, '2022-09-26'),
  (1, 12, 3, '2022-09-26'),
  (2, 2, 2, '2022-09-26'),
  (2, 9, 1, '2022-09-26'),
  (2, 15, 1, '2022-09-26'),
  (2, 11, 1, '2022-09-26'),
  (3, 15, 3, '2022-09-26'),
  (3, 2, 3, '2022-09-26'),
  (4, 3, 1, '2022-09-26'),
  (4, 10, 1, '2022-09-26'),
  (5, 2, 3, '2022-09-27'),
  (5, 3, 4, '2022-09-27'),
  (5, 14, 1, '2022-09-27'),
  (6, 4, 3, '2022-09-27'),
  (6, 5, 1, '2022-09-27'),
  (6, 8, 1, '2022-09-27'),
  (7, 12, 1, '2022-09-28'),
  (7, 13, 1, '2022-09-28'),
  (7, 5, 1, '2022-09-28'),
  (7, 3, 3, '2022-09-28'),
  (8, 12, 4, '2022-09-28'),
  (8, 5, 1, '2022-09-28'),
  (8, 20, 5, '2022-09-28'),
  (8, 17, 5, '2022-09-28'),
  (9, 19, 9, '2022-09-28'),
  (9, 6, 5, '2022-09-28'),
  (9, 9, 5, '2022-09-28'),
  (9, 12, 10, '2022-09-28');

CREATE TABLE employees (
  employee_id INT PRIMARY KEY,
  name TEXT,
  surname TEXT,
  age INT,
  dateofBirth DATE,
  phone_number TEXT,
  email TEXT,
  position TEXT,
  salary INT
);

INSERT INTO employees (employee_id, name, surname, age, dateofBirth, phone_number, email, position, salary)
VALUES (1, 'John', 'Doe', 32, '1991-01-15', '555-555-1212', 'johndoe@email.com', 'Manager', 75000),
       (2, 'Jane', 'Smith', 28, '1993-07-12', '555-555-2323', 'janesmith@email.com', 'Server', 40000),
       (3, 'Bob', 'Johnson', 35, '1988-05-20', '555-555-3434', 'bobjohnson@email.com', 'Chef', 65000),
       (4, 'Emily', 'Williams', 25, '1997-03-07', '555-555-4545', 'emilywilliams@email.com', 'Bartender', 30000),
       (5, 'Michael', 'Jones', 29, '1994-06-10', '555-555-5656', 'michaeljones@email.com', 'Dishwasher', 25000),
       (6, 'Sarah', 'Davis', 30, '1993-09-05', '555-555-6767', 'sarahdavis@email.com', 'Server', 40000),
       (7, 'David', 'Brown', 27, '1996-02-17', '555-555-7878', 'davidbrown@email.com', 'Busser', 20000);

--create table
--Select all column from every tables
SELECT * from menu;
SELECT * from food_type;
SELECT * from members;
SELECT * from orders;
SELECT * from employees;

-- Join menu and food type
SELECT menu.menu_id, menu.menu_name, menu.menu_price, food_type.menu_type
FROM menu
JOIN food_type ON menu.menu_id = food_type.menu_id;

-- Employees who earn more than 50000
SELECT *
FROM employees
WHERE salary >= 50000;

-- Invoices (SUM)
SELECT orders.order_id, SUM(orders.quantity) as number_of_orders, SUM(menu.menu_price) as total_fee, orders.date
FROM orders, menu
WHERE orders.menu_id = menu.menu_id
GROUP BY orders.order_id;


-- The most popular menu (SUM, MAX, SUBQUERY)
SELECT *
FROM menu
WHERE menu_id IN (SELECT menu_id
                  FROM (SELECT menu_id, SUM(quantity) AS max_sold
                        FROM orders
                        GROUP BY menu_id) 
                  WHERE max_sold = (SELECT MAX(sold)
                                    FROM (SELECT menu_id, SUM(quantity) AS sold
                                          FROM orders
                                          GROUP BY menu_id) ));

-- Discount price for members (WITH)
WITH SUB AS (
  SELECT orders.order_id, SUM(menu.menu_price) as normal_fee
  FROM orders, menu
  WHERE orders.menu_id = menu.menu_id
  GROUP BY orders.order_id
)

SELECT SUB.order_id, SUB.normal_fee, SUB.normal_fee * 0.7 AS discounted_fee
FROM SUB, members
WHERE SUB.order_id = members.member_id;


-- finished :)



