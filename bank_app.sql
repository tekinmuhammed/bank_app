select * from customers;

CALL add_customer(
	'Gün Gören',
	'11111111111',
	'Eskişehir',
	'1993-02-01'
);

select * from accounts;


CREATE OR REPLACE PROCEDURE public.add_account(
    IN p_customer_id INT,
    IN p_account_name VARCHAR
)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    v_account_number VARCHAR(20);
    v_iban CHAR(26);
BEGIN
    -- Unique account number based on the customer's ID and a sequence
    v_account_number := 'ACC' || p_customer_id || nextval('account_number_seq');
    
    -- Unique IBAN generation
    v_iban := 'TR' || LPAD(nextval('iban_seq')::TEXT, 24, '1');
    
    -- Insert new account with the generated account number and IBAN
    INSERT INTO accounts (customer_id, account_name, account_number, iban, balance, account_status)
    VALUES (p_customer_id, p_account_name, v_account_number, v_iban, 0.00, TRUE);
    
    RAISE NOTICE 'New account created successfully for customer ID %', p_customer_id;
END;
$BODY$;
ALTER PROCEDURE public.add_account(integer, character varying)
    OWNER TO postgres;


-- Create a sequence for generating unique account numbers
CREATE SEQUENCE IF NOT EXISTS account_number_seq START WITH 1;

CREATE SEQUENCE iban_seq START 1;


CALL add_account(
	1,
	'Ek Hesap'
);
select * from accounts;

select * from cards;

CALL add_card(
	1,
	'8888777766665555',
	09,
	29,
	'456',
	'credit'
);

CALL add_transaction(
	1,
	1,
	1,
	500.00,
	'deposit'
);



CREATE OR REPLACE PROCEDURE public.add_transaction(
    IN p_account_id INT,
    IN p_card_id INT,
    IN p_transaction_type_id INT,
    IN p_amount NUMERIC,
    IN p_description VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_card_type VARCHAR(10);
    v_balance NUMERIC(12, 2);
    v_risk_limit NUMERIC(12, 2);
    v_total_spent NUMERIC(12, 2);
BEGIN
    SELECT card_type INTO v_card_type FROM cards WHERE card_id = p_card_id;
    SELECT balance INTO v_balance FROM accounts WHERE account_id = p_account_id;

    IF p_transaction_type_id = (SELECT transaction_type_id FROM transaction_types WHERE transaction_type_name = 'credit_card_payment') THEN
        SELECT risk_limit INTO v_risk_limit FROM customers WHERE customer_id = 
            (SELECT customer_id FROM accounts WHERE account_id = p_account_id);
        
        SELECT COALESCE(SUM(amount), 0) INTO v_total_spent 
        FROM transactions 
        WHERE card_id = p_card_id 
        AND transaction_type_id = (SELECT transaction_type_id FROM transaction_types WHERE transaction_type_name = 'credit_card_payment');
        
        IF (v_total_spent + p_amount) > v_risk_limit THEN
            RAISE EXCEPTION 'Credit card limit exceeded';
        END IF;
    END IF;
    
    -- Withdraw and deposit checks for account balance
    IF v_card_type = 'debit' THEN
        IF p_transaction_type_id = (SELECT transaction_type_id FROM transaction_types WHERE transaction_type_name = 'withdrawal') THEN
            IF v_balance < p_amount THEN
                RAISE EXCEPTION 'Insufficient account balance for withdrawal';
            END IF;
            UPDATE accounts SET balance = balance - p_amount WHERE account_id = p_account_id;
        ELSIF p_transaction_type_id = (SELECT transaction_type_id FROM transaction_types WHERE transaction_type_name = 'deposit') THEN
            UPDATE accounts SET balance = balance + p_amount WHERE account_id = p_account_id;
        ELSIF p_transaction_type_id = (SELECT transaction_type_id FROM transaction_types WHERE transaction_type_name = 'transfer_to_credit_card') THEN
            UPDATE accounts SET balance = balance - p_amount WHERE account_id = p_account_id;
            -- Credit the amount to the credit card balance
        END IF;
    END IF;

    -- Insert the transaction
    INSERT INTO transactions (account_id, card_id, transaction_type_id, amount, description)
    VALUES (p_account_id, p_card_id, p_transaction_type_id, p_amount, p_description);

    RAISE NOTICE 'Transaction completed successfully.';
END;
$$;

select * from transactions;

CALL add_transaction(
	1,
	1,
	1,
	1500.00,
	'deposit'
);

CALL add_transaction(
	1,
	1,
	2,
	1500.00,
	'withdrawal'
);

CALL add_transaction(
	1,
	1,
	2,
	1500.00,
	'withdrawal'
);

CALL add_transaction(
	1,
	2,
	3,
	1500.00,
	'credit_card_payment'
);

CALL add_transaction(
	1,
	1,
	7,
	500.00,
	'transfer_to_credit_card'
);


select * from accounts;

select * from cards;

select * from customers;

SELECT 
    iban, 
    balance 
FROM 
    accounts
WHERE 
    iban = 'TR000000000000000000000001';



SELECT 
    card_number, 
    risk_limit, 
    current_balance, 
    (risk_limit - current_balance) AS available_credit 
FROM 
    customers;

CREATE OR REPLACE PROCEDURE public.add_transaction_type(p_transaction_type_name VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO transaction_types (transaction_type_name)
    VALUES (p_transaction_type_name)
    ON CONFLICT (transaction_type_name) DO NOTHING;

    RAISE NOTICE 'Transaction type added successfully.';
END $$;
CALL public.add_transaction_type('transfer_to_credit_card');



CREATE VIEW customer_account_overview AS
SELECT 
    c.customer_id,
    c.full_name,
    SUM(a.balance) AS total_balance,
    c.risk_limit AS total_credit_limit,
    COUNT(a.account_id) AS account_count
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
GROUP BY c.customer_id, c.full_name, c.risk_limit;

select * from customer_account_overview;


CREATE OR REPLACE VIEW account_transaction_summary AS
SELECT 
    a.account_id,
    a.account_name,
    COUNT(t.transaction_id) AS total_transactions,
    SUM(t.amount) AS total_amount
FROM accounts a
JOIN transactions t ON a.account_id = t.account_id
GROUP BY a.account_id, a.account_name;

select * from account_transaction_summary;

CREATE OR REPLACE VIEW credit_card_spending AS
SELECT 
    c.card_id,
    ca.full_name,
    c.card_number,
    SUM(t.amount) AS total_spent
FROM cards c
JOIN transactions t ON c.card_id = t.card_id
JOIN accounts a ON c.account_id = a.account_id
JOIN customers ca ON a.customer_id = ca.customer_id
WHERE c.card_type = 'credit'
GROUP BY c.card_id, ca.full_name, c.card_number;

select * from credit_card_spending;


CREATE OR REPLACE VIEW account_balance_and_credit_limit AS
SELECT 
    a.account_id,
    a.account_name,
    a.balance AS account_balance,
    c.risk_limit AS customer_credit_limit
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id;

select * from account_balance_and_credit_limit;
