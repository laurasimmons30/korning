-- DEFINE YOUR DATABASE SCHEMA HERE

CREATE TABLE employees (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  email VARCHAR(255)
); 

CREATE TABLE sales (
  id SERIAL PRIMARY KEY,
  sale_date DATE,
  sale_amount DECIMAL,
  units_sold INTEGER,
  invoice_no INTEGER,
  invoice_frequency VARCHAR(255),
  product_id INTEGER,
  employee_id INTEGER,
  customers_id INTEGER
);

CREATE TABLE customers (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  account_no VARCHAR(255)
);

CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255)
);
