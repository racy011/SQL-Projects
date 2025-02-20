-- Students table for student details
CREATE TABLE Students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    enrollment_date DATE DEFAULT CURDATE()
);

-- Courses table with course information
CREATE TABLE Courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(255) NOT NULL,
    description TEXT,
    credits INT,
    department VARCHAR(100)
);

-- Instructors table for teacher details
CREATE TABLE Instructors (
    instructor_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    hire_date DATE
);

-- Enrollments table to link students to courses
CREATE TABLE Enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    course_id INT,
    enrollment_date DATE DEFAULT CURDATE(),
    status VARCHAR(50) DEFAULT 'Enrolled',
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

-- ClassSchedules table for scheduling classes
CREATE TABLE ClassSchedules (
    schedule_id INT PRIMARY KEY AUTO_INCREMENT,
    course_id INT,
    instructor_id INT,
    class_date DATE,
    start_time TIME,
    end_time TIME,
    room VARCHAR(50),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id),
    FOREIGN KEY (instructor_id) REFERENCES Instructors(instructor_id)
);

-- Assignments table for course assignments
CREATE TABLE Assignments (
    assignment_id INT PRIMARY KEY AUTO_INCREMENT,
    course_id INT,
    title VARCHAR(255),
    description TEXT,
    due_date DATE,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

-- Submissions table for student assignment submissions
CREATE TABLE Submissions (
    submission_id INT PRIMARY KEY AUTO_INCREMENT,
    assignment_id INT,
    student_id INT,
    submission_date DATE,
    grade DECIMAL(5,2),
    feedback TEXT,
    FOREIGN KEY (assignment_id) REFERENCES Assignments(assignment_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- Trigger to mark enrollment status as 'Late Submission' if assignment submitted after due date
DELIMITER //
CREATE TRIGGER trg_submission_late
AFTER INSERT ON Submissions
FOR EACH ROW
BEGIN
    DECLARE v_due_date DATE;
    SELECT due_date INTO v_due_date FROM Assignments WHERE assignment_id = NEW.assignment_id;
    
    IF NEW.submission_date > v_due_date THEN
        UPDATE Enrollments
        SET status = 'Late Submission'
        WHERE student_id = NEW.student_id 
          AND course_id = (SELECT course_id FROM Assignments WHERE assignment_id = NEW.assignment_id);
    END IF;
END//
DELIMITER ;
