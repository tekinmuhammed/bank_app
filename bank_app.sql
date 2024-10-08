--************************BANK APPLICATION********************


-- CREATE TABLE customers (
--     customer_id SERIAL PRIMARY KEY,
--     full_name VARCHAR(100) NOT NULL,
--     tc_no CHAR(11) UNIQUE NOT NULL,
--     birth_place VARCHAR(50) NOT NULL,
--     birth_date DATE NOT NULL,
--     risk_limit NUMERIC(10, 2) DEFAULT 10000.00,
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );


-- CREATE TABLE accounts (
--     account_id SERIAL PRIMARY KEY,
--     customer_id INT REFERENCES customers(customer_id),
--     account_name VARCHAR(50) NOT NULL,
--     account_number VARCHAR(20) UNIQUE NOT NULL,
--     iban CHAR(26) UNIQUE NOT NULL,
--     balance NUMERIC(10, 2) DEFAULT 0.00,
--     account_status BOOLEAN DEFAULT TRUE, -- True: Active, False: Inactive
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );


-- CREATE TABLE cards (
--     card_id SERIAL PRIMARY KEY,
--     account_id INT REFERENCES accounts(account_id),
--     card_number CHAR(16) UNIQUE NOT NULL,
--     expiry_month INT NOT NULL,
--     expiry_year INT NOT NULL,
--     ccv_code CHAR(3) NOT NULL,
--     card_type VARCHAR(10) NOT NULL, -- 'debit' or 'credit'
--     card_status BOOLEAN DEFAULT TRUE, -- True: Active, False: Inactive
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );



-- CREATE TABLE transactions (
--     transaction_id SERIAL PRIMARY KEY,
--     account_id INT REFERENCES accounts(account_id),
--     card_id INT REFERENCES cards(card_id),
--     transaction_type VARCHAR(20) NOT NULL, -- 'deposit', 'withdraw', 'payment'
--     amount NUMERIC(10, 2) NOT NULL,
--     description VARCHAR(100),
--     transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );

-- CREATE OR REPLACE PROCEDURE create_all_tables()
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN

--     CREATE TABLE IF NOT EXISTS customers (
--         customer_id SERIAL PRIMARY KEY,
--         full_name VARCHAR(100) NOT NULL,
--         national_id CHAR(11) UNIQUE NOT NULL,
--         birth_place VARCHAR(50) NOT NULL,
--         birth_date DATE NOT NULL,
--         risk_limit NUMERIC(10, 2) DEFAULT 10000
--     );
    

--     CREATE TABLE IF NOT EXISTS accounts (
--         account_id SERIAL PRIMARY KEY,
--         customer_id INT REFERENCES customers(customer_id) ON DELETE CASCADE,
--         account_name VARCHAR(50) NOT NULL,
--         account_number VARCHAR(20) UNIQUE NOT NULL,
--         iban VARCHAR(26) NOT NULL,
--         balance NUMERIC(10, 2) DEFAULT 0,
--         is_active BOOLEAN DEFAULT TRUE,
--         opened_at TIMESTAMPTZ DEFAULT NOW()
--     );
    

--     CREATE TABLE IF NOT EXISTS cards (
--         card_id SERIAL PRIMARY KEY,
--         account_id INT REFERENCES accounts(account_id) ON DELETE CASCADE,
--         card_number CHAR(16) UNIQUE NOT NULL,
--         expiration_month INT NOT NULL,
--         expiration_year INT NOT NULL,
--         ccv_code CHAR(3) NOT NULL,
--         is_active BOOLEAN DEFAULT TRUE,
--         card_type VARCHAR(10) NOT NULL -- 'hesap' or 'kredi'
--     );


--     CREATE TABLE IF NOT EXISTS transactions (
--         transaction_id SERIAL PRIMARY KEY,
--         account_id INT REFERENCES accounts(account_id) ON DELETE CASCADE,
--         card_id INT REFERENCES cards(card_id),
--         transaction_type VARCHAR(20) NOT NULL, -- 'deposit', 'withdrawal', 'payment'
--         amount NUMERIC(10, 2) NOT NULL,
--         description VARCHAR(100),
--         transaction_date TIMESTAMPTZ DEFAULT NOW()
--     );
    
--     RAISE NOTICE 'All tables created successfully.';
-- END $$;

