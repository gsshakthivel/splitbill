CREATE TABLE users (
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY email (email)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `groups` (
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    created_by INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY created_by (created_by),
    CONSTRAINT groups_ibfk_1
        FOREIGN KEY (created_by) REFERENCES users (id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE group_members (
    group_id INT NOT NULL,
    user_id INT NOT NULL,
    role VARCHAR(20) NOT NULL,
    created_by INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (group_id, user_id),
    KEY user_id (user_id),
    KEY created_by (created_by),
    CONSTRAINT group_members_ibfk_1
        FOREIGN KEY (group_id) REFERENCES `groups` (id),
    CONSTRAINT group_members_ibfk_2
        FOREIGN KEY (user_id) REFERENCES users (id),
    CONSTRAINT group_members_ibfk_3
        FOREIGN KEY (created_by) REFERENCES users (id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE expenses (
    id INT NOT NULL AUTO_INCREMENT,
    description VARCHAR(100) NOT NULL,
    group_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    paid_by INT NOT NULL,
    created_by INT NOT NULL,
    split_type VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    updated_by INT DEFAULT NULL,
    PRIMARY KEY (id),
    KEY paid_by (paid_by),
    KEY created_by (created_by),
    KEY updated_by (updated_by),
    KEY idx_expenses_group_id (group_id),
    CONSTRAINT expenses_ibfk_1
        FOREIGN KEY (group_id) REFERENCES `groups` (id),
    CONSTRAINT expenses_ibfk_2
        FOREIGN KEY (paid_by) REFERENCES users (id),
    CONSTRAINT expenses_ibfk_3
        FOREIGN KEY (created_by) REFERENCES users (id),
    CONSTRAINT expenses_ibfk_4
        FOREIGN KEY (updated_by) REFERENCES users (id),
    CONSTRAINT expenses_chk_1
        CHECK (amount > 0)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE expense_splits (
    expense_id INT NOT NULL,
    user_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (expense_id, user_id),
    KEY idx_expense_splits_user_id (user_id),
    CONSTRAINT expense_splits_ibfk_1
        FOREIGN KEY (expense_id) REFERENCES expenses (id),
    CONSTRAINT expense_splits_ibfk_2
        FOREIGN KEY (user_id) REFERENCES users (id),
    CONSTRAINT expense_splits_chk_1
        CHECK (amount > 0)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE settlements (
    id INT NOT NULL AUTO_INCREMENT,
    group_id INT NOT NULL,
    from_user_id INT NOT NULL,
    to_user_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY from_user_id (from_user_id),
    KEY to_user_id (to_user_id),
    KEY idx_settlements_pair (group_id, from_user_id, to_user_id),
    CONSTRAINT settlements_ibfk_1
        FOREIGN KEY (group_id) REFERENCES `groups` (id),
    CONSTRAINT settlements_ibfk_2
        FOREIGN KEY (from_user_id) REFERENCES users (id),
    CONSTRAINT settlements_ibfk_3
        FOREIGN KEY (to_user_id) REFERENCES users (id),
    CONSTRAINT settlements_chk_1
        CHECK (amount > 0),
    CONSTRAINT settlements_chk_2
        CHECK (from_user_id <> to_user_id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE notifications (
    id INT NOT NULL AUTO_INCREMENT,
    group_id INT NOT NULL,
    created_by INT NOT NULL,
    type VARCHAR(50) COLLATE utf8mb4_cs_0900_ai_ci NOT NULL,
    message VARCHAR(255)
        CHARACTER SET utf8mb4
        COLLATE utf8mb4_0900_ai_ci NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY group_id (group_id),
    KEY created_by (created_by),
    CONSTRAINT notifications_ibfk_1
        FOREIGN KEY (group_id) REFERENCES `groups` (id),
    CONSTRAINT notifications_ibfk_2
        FOREIGN KEY (created_by) REFERENCES users (id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_cs_0900_ai_ci;


CREATE TABLE notification_recipients (
    id INT NOT NULL AUTO_INCREMENT,
    notification_id INT NOT NULL,
    recipient_user_id INT NOT NULL,
    read_at TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY notification_id (notification_id, recipient_user_id),
    KEY idx_notification_recipients_user_read
        (recipient_user_id, read_at),
    CONSTRAINT notification_recipients_ibfk_1
        FOREIGN KEY (notification_id)
            REFERENCES notifications (id),
    CONSTRAINT notification_recipients_ibfk_2
        FOREIGN KEY (recipient_user_id)
            REFERENCES users (id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;