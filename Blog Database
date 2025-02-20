-- Users table for system users
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'author', -- Possible values: admin, author, reader
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Authors table linking to Users for author-specific data
CREATE TABLE Authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    bio TEXT,
    website VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Categories table for organizing posts
CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL
);

-- Posts table for blog content
CREATE TABLE Posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    author_id INT,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    status VARCHAR(50) DEFAULT 'Draft', -- Draft, Published, Archived
    publish_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES Authors(author_id)
);

-- Junction table for posts and categories
CREATE TABLE PostCategories (
    post_id INT,
    category_id INT,
    PRIMARY KEY (post_id, category_id),
    FOREIGN KEY (post_id) REFERENCES Posts(post_id),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

-- Comments table for post feedback
CREATE TABLE Comments (
    comment_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT,
    user_id INT,
    comment_text TEXT,
    comment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES Posts(post_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Ratings table for post ratings
CREATE TABLE Ratings (
    rating_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT,
    user_id INT,
    rating TINYINT CHECK(rating BETWEEN 1 AND 5),
    rating_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES Posts(post_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Audit log table for post changes
CREATE TABLE AuditPostChanges (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT,
    change_type VARCHAR(50),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    details TEXT,
    FOREIGN KEY (post_id) REFERENCES Posts(post_id)
);

-- Trigger to log updates on posts
DELIMITER //
CREATE TRIGGER trg_post_update
AFTER UPDATE ON Posts
FOR EACH ROW
BEGIN
    INSERT INTO AuditPostChanges(post_id, change_type, details)
    VALUES (NEW.post_id, 'UPDATE', CONCAT('Title changed from ', OLD.title, ' to ', NEW.title));
END//
DELIMITER ;

-- Stored Procedure to publish a post (update status and set publish_date)
DELIMITER //
CREATE PROCEDURE PublishPost(IN p_post_id INT)
BEGIN
    UPDATE Posts
    SET status = 'Published', publish_date = NOW()
    WHERE post_id = p_post_id;
    
    INSERT INTO AuditPostChanges(post_id, change_type, details)
    VALUES (p_post_id, 'PUBLISH', 'Post published');
END//
DELIMITER ;
