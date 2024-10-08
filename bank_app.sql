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
--     transaction_type VARCHAR(20) CHECK (transaction_type IN ('deposit', 'withdrawal', 'credit_card_payment')),
--     amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
--     description VARCHAR(100),
--     created_at TIMESTAMP DEFAULT NOW(),
--     updated_at TIMESTAMP DEFAULT NOW()
-- );


-- CREATE OR REPLACE PROCEDURE create_all_tables()
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN

--     CREATE TABLE IF NOT EXISTS customers (
--         customer_id SERIAL PRIMARY KEY,
--         full_name VARCHAR(100) NOT NULL,
--         tc_no CHAR(11) UNIQUE NOT NULL,
--         birth_place VARCHAR(50) NOT NULL,
--         birth_date DATE NOT NULL,
--         risk_limit NUMERIC(10, 2) DEFAULT 10000
--         created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
--     );
    

--     CREATE TABLE IF NOT EXISTS accounts (
--         account_id SERIAL PRIMARY KEY,
--         customer_id INT REFERENCES customers(customer_id),
--         account_name VARCHAR(50) NOT NULL,
--         account_number VARCHAR(20) UNIQUE NOT NULL,
--         iban CHAR(26) UNIQUE NOT NULL,
--         balance NUMERIC(10, 2) DEFAULT 0.00,
--         account_status BOOLEAN DEFAULT TRUE, -- True: Active, False: Inactive
--         created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
--     );
    

--     CREATE TABLE IF NOT EXISTS cards (
--         card_id SERIAL PRIMARY KEY,
--         account_id INT REFERENCES accounts(account_id),
--         card_number CHAR(16) UNIQUE NOT NULL,
--         expiry_month INT NOT NULL,
--         expiry_year INT NOT NULL,
--         ccv_code CHAR(3) NOT NULL,
--         card_type VARCHAR(10) NOT NULL, -- 'debit' or 'credit'
--         card_status BOOLEAN DEFAULT TRUE, -- True: Active, False: Inactive
--         created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
--     );


-- 	   CREATE TABLE IF NOT EXISTS transactions (
--         transaction_id SERIAL PRIMARY KEY,
--         account_id INT REFERENCES accounts(account_id),
--         card_id INT REFERENCES cards(card_id),
--         transaction_type VARCHAR(20) CHECK (transaction_type IN ('deposit', 'withdrawal', 'credit_card_payment')),
--         amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
--         description VARCHAR(100),
--         created_at TIMESTAMP DEFAULT NOW(),
--         updated_at TIMESTAMP DEFAULT NOW()
--     );
    
--     RAISE NOTICE 'All tables created successfully.';
-- END $$;


-- CREATE OR REPLACE PROCEDURE drop_all_tables()
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     DROP TABLE IF EXISTS transactions CASCADE;
--     DROP TABLE IF EXISTS cards CASCADE;
--     DROP TABLE IF EXISTS accounts CASCADE;
--     DROP TABLE IF EXISTS customers CASCADE;
    
--     RAISE NOTICE 'All tables dropped successfully.';
-- END $$;


 -- CREATE OR REPLACE PROCEDURE add_customer(
 --     p_full_name VARCHAR, 
 --     p_tc_no CHAR(11), 
 --     p_birth_place VARCHAR, 
 --     p_birth_date DATE)
 -- LANGUAGE plpgsql
 -- AS $$
 -- DECLARE
 --     v_customer_id INT;
 -- BEGIN
 --     -- mmüşteri ekleme
 --     INSERT INTO customers (full_name, tc_no, birth_place, birth_date)
 --     VALUES (p_full_name, p_tc_no, p_birth_place, p_birth_date)
 --     RETURNING customer_id INTO v_customer_id;    
 --     -- otomatik hesap ekle
 --     INSERT INTO accounts (customer_id, account_name, account_number, iban)
 --     VALUES (v_customer_id, p_full_name || ' Account', 
 --             'ACC' || v_customer_id, 
 --             'TR' || LPAD(v_customer_id::TEXT, 24, '0'));
            
 --     RAISE NOTICE 'Customer and account created successfully.';
 -- END $$;


 -- CREATE OR REPLACE PROCEDURE add_card(
 --     p_account_id INT, 
 --     p_card_number CHAR(16), 
 --     p_expiry_month INT, 
 --     p_expiry_year INT, 
 --     p_ccv_code CHAR(3), 
 --     p_card_type VARCHAR)
 -- LANGUAGE plpgsql
 -- AS $$
 -- BEGIN
 --     -- card ekle
 --     INSERT INTO cards (account_id, card_number, expiry_month, expiry_year, ccv_code, card_type)
 --     VALUES (p_account_id, p_card_number, p_expiry_month, p_expiry_year, p_ccv_code, p_card_type);
    
 --     RAISE NOTICE 'Card added successfully.';
 -- END $$;


-- CREATE OR REPLACE PROCEDURE deposit(
--     p_account_id INT, 
--     p_amount NUMERIC(10, 2),
--     p_description VARCHAR)
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     -- hesap bakiyesi güncelle
--     UPDATE accounts
--     SET balance = balance + p_amount
--     WHERE account_id = p_account_id;
    
--     -- işlem kaydı
--     INSERT INTO transactions (account_id, transaction_type, amount, description)
--     VALUES (p_account_id, 'deposit', p_amount, p_description);
    
--     RAISE NOTICE 'Deposit successful.';
-- END $$;

select * from accounts;
CALL deposit(1, 2000.00, 'Deposit');


-- CREATE OR REPLACE PROCEDURE withdraw(
--     p_account_id INT, 
--     p_amount NUMERIC(10, 2),
--     p_description VARCHAR)
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     -- hesap bakiyesini kontrol et
--     IF (SELECT balance FROM accounts WHERE account_id = p_account_id) < p_amount THEN
--         RAISE EXCEPTION 'Insufficient funds.';
--     END IF;

--     -- hesap bakiyesini güncelle
--     UPDATE accounts
--     SET balance = balance - p_amount
--     WHERE account_id = p_account_id;
    
--     -- işlem kaydı
--     INSERT INTO transactions (account_id, transaction_type, amount, description)
--     VALUES (p_account_id, 'withdrawal', p_amount, p_description);
    
--     RAISE NOTICE 'Withdrawal successful.';
-- END $$;


-- CREATE OR REPLACE PROCEDURE make_payment(
--     p_account_id INT, 
--     p_card_id INT, 
--     p_amount NUMERIC(10, 2),
--     p_description VARCHAR)
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     -- hesap bakiyesini kontrol et
--     IF (SELECT balance FROM accounts WHERE account_id = p_account_id) < p_amount THEN
--         RAISE EXCEPTION 'Insufficient funds for payment.';
--     END IF;

--     -- hhesap bakiyesini güncelle
--     UPDATE accounts
--     SET balance = balance - p_amount
--     WHERE account_id = p_account_id;
    
--     -- işlem kaydi
--     INSERT INTO transactions (account_id, card_id, transaction_type, amount, description)
--     VALUES (p_account_id, p_card_id, 'payment', p_amount, p_description);
    
--     RAISE NOTICE 'Payment successful.';
-- END $$;

 -- CREATE OR REPLACE FUNCTION check_account_status()
 -- RETURNS TRIGGER AS $$
 -- BEGIN
 --     IF NEW.transaction_type IN ('deposit', 'withdrawal') THEN
 --         -- Fetch account status
 --         PERFORM 1 FROM accounts WHERE account_id = NEW.account_id AND account_status = false;
 --         IF FOUND THEN
 --             RAISE EXCEPTION 'Cannot perform transaction on an inactive account';
 --         END IF;
 --     END IF;
 --     RETURN NEW;
 -- END;
 -- $$ LANGUAGE plpgsql;

-- -- Trigger
-- CREATE TRIGGER prevent_inactive_account_transaction
-- BEFORE INSERT ON transactions
-- FOR EACH ROW
-- EXECUTE FUNCTION check_account_status();



-- CREATE OR REPLACE FUNCTION check_credit_card_limit()
-- RETURNS TRIGGER AS $$
-- DECLARE
--     card_limit NUMERIC(12, 2);
--     total_spent NUMERIC(12, 2);
-- BEGIN
--     IF NEW.transaction_type = 'credit_card_payment' THEN
--         -- Fetch credit card limit
--         SELECT risk_limit INTO card_limit FROM accounts WHERE account_id = NEW.account_id;
        
--         -- Calculate total spent on this card
--         SELECT COALESCE(SUM(amount), 0) INTO total_spent 
--         FROM transactions
--         WHERE card_id = NEW.card_id
--         AND transaction_type = 'credit_card_payment';
        
--         -- Check if the total exceeds the limit
--         IF (total_spent + NEW.amount) > card_limit THEN
--             RAISE EXCEPTION 'Credit card limit exceeded';
--         END IF;
--     END IF;
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

-- -- Trigger
-- CREATE TRIGGER prevent_credit_limit_exceed
-- BEFORE INSERT ON transactions
-- FOR EACH ROW
-- EXECUTE FUNCTION check_credit_card_limit();


-- CREATE OR REPLACE FUNCTION update_updated_at()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     NEW.updated_at = NOW();
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

-- -- Trigger for accounts table
-- CREATE TRIGGER update_accounts_timestamp
-- BEFORE UPDATE ON accounts
-- FOR EACH ROW
-- EXECUTE FUNCTION update_updated_at();

-- -- Trigger for credit_cards table
-- CREATE TRIGGER update_cards_timestamp
-- BEFORE UPDATE ON cards
-- FOR EACH ROW
-- EXECUTE FUNCTION update_updated_at();



-- CALL add_customer('Muhammed Tekin', '14464356542', 'Adiyaman', '2000-01-01');
-- CALL add_customer('Gün Gören', '11111111111', 'Eskişehir', '1993-01-02');

-- select * from customers;

-- select * from accounts;

-- CALL add_card( 1, '1234567898765432', 12, 2026, '123', 'debit');
-- CALL add_card( 1, '9876543210987654', 07, 2027, '321', 'debit');

-- CALL add_card( 1, '1111222233334444', 08, 2028, '456', 'credit');
-- CALL add_card( 1, '5555666677778888', 09, 2029, '654', 'credit');

-- select * from cards;

-- CREATE OR REPLACE PROCEDURE add_transaction(
--     IN p_account_name VARCHAR(50),
--     IN p_card_number CHAR(16),
--     IN p_transaction_type VARCHAR(50),
--     IN p_amount DECIMAL,
--     IN p_description VARCHAR(100)
-- )
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     INSERT INTO transactions (account_id, card_id, transaction_type, amount, description)
--     VALUES (
--         (SELECT account_id FROM accounts WHERE account_name = p_account_name),
--         (SELECT card_id FROM cards WHERE card_number = p_card_number),
--         p_transaction_type,
--         p_amount,
--         p_description
--     );
-- END;
-- $$;


CALL add_transaction('Muhammed Tekin Account', '1234567898765432', 'deposit', 1000, 'Initial deposit');

select * from transactions;
CALL add_transaction('John Doe Savings', '1234567812345678', 'withdrawal', 500, 'ATM withdrawal');

CALL credit_card_transaction('14464356542', '1234567898765432', )

  CREATE OR REPLACE PROCEDURE credit_card_transaction(
      IN p_customer_id INT,
      IN p_card_number CHAR(16),
      IN p_transaction_type VARCHAR(50),
      IN p_amount DECIMAL,
      IN p_description VARCHAR(100)
  )
  LANGUAGE plpgsql
  AS $$
  BEGIN
      INSERT INTO transactions (account_id, card_id, transaction_type, amount, description)
      VALUES (
          (SELECT account_id FROM accounts WHERE customer_id = (SELECT customer_id FROM customers WHERE customer_id = p_customer_id)),
          (SELECT card_id FROM cards WHERE card_number = p_card_number),
          p_transaction_type,
          p_amount,
          p_description
      );
  END;
  $$;

CALL credit_card_transaction(1, '1234567898765432', 'credit_card_payment', 3000, 'Shopping');
