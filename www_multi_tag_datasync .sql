-- Users Table
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL
);

-- Document Table
CREATE TABLE doc (
    doc_uuid CHAR(36) PRIMARY KEY,
    parent_uuid CHAR(36),
    d_id TINYINT,  -- 1 represents folder, 2 represents document
    filename VARCHAR(255) NOT NULL,
    doc_type VARCHAR(50),  -- Represents the file type, e.g., .py for Python files
    checksum VARCHAR(255),
    timestamp TIMESTAMP,
    doc_hash VARCHAR(255),
    uploaded_by INT,  -- User ID who uploaded the document
    file_path VARCHAR(255), -- Path to the physical file location in the server
    FOREIGN KEY (parent_uuid) REFERENCES doc(doc_uuid) ON DELETE CASCADE,
    FOREIGN KEY (uploaded_by) REFERENCES users(user_id) ON DELETE SET NULL
);

-- Tags Table
CREATE TABLE tags (
    tag VARCHAR(255) PRIMARY KEY,
    builder_id INT,
    FOREIGN KEY (builder_id) REFERENCES users(user_id) ON DELETE SET NULL
);

-- Document-Tag Relationship (Many-to-Many)
CREATE TABLE doc_tags (
    doc_uuid CHAR(36),
    tag VARCHAR(255),
    PRIMARY KEY (doc_uuid, tag),
    FOREIGN KEY (doc_uuid) REFERENCES doc(doc_uuid) ON DELETE CASCADE,
    FOREIGN KEY (tag) REFERENCES tags(tag) ON DELETE CASCADE
);

-- Collaborative Table
CREATE TABLE collaborative (
    user_id INT,
    doc_uuid CHAR(36),
    permissions VARCHAR(255),
    user_owner_id INT,
    PRIMARY KEY (user_id, doc_uuid),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (doc_uuid) REFERENCES doc(doc_uuid) ON DELETE CASCADE,
    FOREIGN KEY (user_owner_id) REFERENCES users(user_id) ON DELETE SET NULL
);

-- Sharing Table to Record Grant and Share Actions
CREATE TABLE share (
    share_id INT PRIMARY KEY,
    user_id INT,
    doc_uuid VARCHAR(36),
    grant_permission BOOLEAN,  -- Renamed from 'grant' to 'grant_permission' to avoid conflicts
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (doc_uuid) REFERENCES doc(doc_uuid) ON DELETE CASCADE
);
