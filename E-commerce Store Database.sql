-- Customers table with registration details
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    address VARCHAR(255),
    phone VARCHAR(20),
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products table with detailed product info
CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL,
    category VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders table for purchase orders
CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2),
    status VARCHAR(50),
    discount_code VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- OrderDetails table to store product details per order
CREATE TABLE OrderDetails (
    order_detail_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Reviews table for product reviews by customers
CREATE TABLE Reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    customer_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- DiscountCodes table for promotional discounts
CREATE TABLE DiscountCodes (
    code VARCHAR(50) PRIMARY KEY,
    description VARCHAR(255),
    discount_percentage DECIMAL(5,2),
    valid_from DATE,
    valid_until DATE,
    usage_limit INT,
    times_used INT DEFAULT 0
);

-- Trigger to update product stock when an order is placed
DELIMITER //
CREATE TRIGGER trg_orderdetails_stock
AFTER INSERT ON OrderDetails
FOR EACH ROW
BEGIN
    UPDATE Products
    SET stock = stock - NEW.quantity
    WHERE product_id = NEW.product_id;
END//
DELIMITER ;

-- Stored Procedure to apply a discount code to an order
DELIMITER //
CREATE PROCEDURE ApplyDiscount(IN p_order_id INT, IN p_code VARCHAR(50))
BEGIN
    DECLARE v_discount DECIMAL(5,2);
    DECLARE v_total DECIMAL(10,2);

    SELECT discount_percentage INTO v_discount 
    FROM DiscountCodes 
    WHERE code = p_code AND CURDATE() BETWEEN valid_from AND valid_until;

    SELECT total_amount INTO v_total FROM Orders WHERE order_id = p_order_id;
    
    SET v_total = v_total - (v_total * (v_discount/100));
    
    UPDATE Orders
    SET total_amount = v_total, discount_code = p_code
    WHERE order_id = p_order_id;
    
    UPDATE DiscountCodes
    SET times_used = times_used + 1
    WHERE code = p_code;
END//
DELIMITER ;
