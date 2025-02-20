-- Categories for books
CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL
);

-- Authors information
CREATE TABLE Authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    author_name VARCHAR(255) NOT NULL,
    bio TEXT
);

-- Publishers information
CREATE TABLE Publishers (
    publisher_id INT PRIMARY KEY AUTO_INCREMENT,
    publisher_name VARCHAR(255) NOT NULL,
    contact_info VARCHAR(255)
);

-- Books table with references to category, author, and publisher
CREATE TABLE Books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    author_id INT,
    publisher_id INT,
    category_id INT,
    published_year INT,
    isbn VARCHAR(20),
    copies INT DEFAULT 1,
    FOREIGN KEY (author_id) REFERENCES Authors(author_id),
    FOREIGN KEY (publisher_id) REFERENCES Publishers(publisher_id),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

-- Borrowers table
CREATE TABLE Borrowers (
    borrower_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
    address VARCHAR(255)
);

-- Loans table to record book borrowings
CREATE TABLE Loans (
    loan_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT,
    borrower_id INT,
    loan_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    FOREIGN KEY (book_id) REFERENCES Books(book_id),
    FOREIGN KEY (borrower_id) REFERENCES Borrowers(borrower_id)
);

-- Fines table to record overdue fines
CREATE TABLE Fines (
    fine_id INT PRIMARY KEY AUTO_INCREMENT,
    loan_id INT,
    fine_amount DECIMAL(10,2),
    paid BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (loan_id) REFERENCES Loans(loan_id)
);

-- Audit log table for tracking changes in Loans
CREATE TABLE AuditLog (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    action VARCHAR(50),
    loan_id INT,
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    details TEXT
);

-- Trigger to log updates on the Loans table
DELIMITER //
CREATE TRIGGER trg_loans_update
AFTER UPDATE ON Loans
FOR EACH ROW
BEGIN
    INSERT INTO AuditLog(action, loan_id, details)
    VALUES ('UPDATE', NEW.loan_id, CONCAT('Loan updated. Old due date: ', OLD.due_date, ', New due date: ', NEW.due_date));
END//
DELIMITER ;

-- Stored Procedure to calculate fines for overdue loans
DELIMITER //
CREATE PROCEDURE CalculateFine(IN p_loan_id INT, IN p_return_date DATE)
BEGIN
    DECLARE v_due_date DATE;
    DECLARE v_days_overdue INT;
    DECLARE v_fine DECIMAL(10,2);

    SELECT due_date INTO v_due_date FROM Loans WHERE loan_id = p_loan_id;

    IF p_return_date > v_due_date THEN
        SET v_days_overdue = DATEDIFF(p_return_date, v_due_date);
        SET v_fine = v_days_overdue * 0.50; -- 50 cents per day overdue
        INSERT INTO Fines(loan_id, fine_amount)
        VALUES(p_loan_id, v_fine);
    END IF;
END//
DELIMITER ;
