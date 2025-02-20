-- Departments table with optional manager assignment
CREATE TABLE Departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL,
    manager_id INT,
    location VARCHAR(255)
);

-- Employees table with personal and job details
CREATE TABLE Employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    hire_date DATE NOT NULL,
    department_id INT,
    job_title VARCHAR(100),
    salary DECIMAL(10,2),
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);

-- SalaryHistory table to track salary changes
CREATE TABLE SalaryHistory (
    record_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT,
    salary DECIMAL(10,2),
    change_date DATE,
    reason VARCHAR(255),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- PerformanceReviews table for periodic employee reviews
CREATE TABLE PerformanceReviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT,
    review_date DATE,
    reviewer VARCHAR(255),
    score INT CHECK(score BETWEEN 1 AND 10),
    comments TEXT,
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- Audit log table for employee changes
CREATE TABLE AuditEmployeeChanges (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT,
    change_type VARCHAR(50),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    details TEXT
);

-- Trigger to log salary changes and update SalaryHistory
DELIMITER //
CREATE TRIGGER trg_employee_salary_update
AFTER UPDATE ON Employees
FOR EACH ROW
BEGIN
    IF OLD.salary <> NEW.salary THEN
        INSERT INTO SalaryHistory(employee_id, salary, change_date, reason)
        VALUES (NEW.employee_id, NEW.salary, CURDATE(), 'Salary updated via system');
        
        INSERT INTO AuditEmployeeChanges(employee_id, change_type, details)
        VALUES (NEW.employee_id, 'SALARY_UPDATE', CONCAT('Old salary: ', OLD.salary, ', New salary: ', NEW.salary));
    END IF;
END//
DELIMITER ;

-- Stored Procedure to adjust employee salary based on performance review bonus
DELIMITER //
CREATE PROCEDURE AdjustSalary(IN p_employee_id INT, IN p_bonus_percentage DECIMAL(5,2))
BEGIN
    DECLARE v_current_salary DECIMAL(10,2);
    SELECT salary INTO v_current_salary FROM Employees WHERE employee_id = p_employee_id;
    
    SET v_current_salary = v_current_salary + (v_current_salary * (p_bonus_percentage/100));
    
    UPDATE Employees
    SET salary = v_current_salary
    WHERE employee_id = p_employee_id;
END//
DELIMITER ;
