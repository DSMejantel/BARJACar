CREATE TABLE pref_dep (
    user_id TEXT NOT NULL,            
    depart TEXT NOT NULL,       
    FOREIGN KEY (user_id) REFERENCES user_info(username) ON DELETE CASCADE
);


