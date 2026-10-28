CREATE TABLE pref_arr (
    user_id TEXT NOT NULL,            
    arrivee TEXT NOT NULL,       
    FOREIGN KEY (user_id) REFERENCES user_info(username) ON DELETE CASCADE
);


