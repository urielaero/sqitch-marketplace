-- Deploy marketplace:sellers to pg

BEGIN;

CREATE TABLE sellers(
    id BIGSERIAL PRIMARY KEY,
    days_for_pay INT NOT NULL,
    days_until_pay INT NOT NULL CHECK (days_for_pay > days_until_pay),
    inserted_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()
);

CREATE TABLE products(
    id BIGSERIAL PRIMARY KEY,
    seller_id int NOT NULL REFERENCES sellers(id),
    price NUMERIC(9, 3) NOT NULL
);

CREATE TABLE purchases(
    id BIGSERIAL PRIMARY KEY,
    -- redundance for easy query over purchases
    seller_id int NOT NULL REFERENCES sellers(id),
    product_id int NOT NULL REFERENCES products(id),
    refund BOOLEAN NOT NULL DEFAULT FALSE,
    inbalance BOOLEAN NOT NULL DEFAULT FALSE,
    rebalance BOOLEAN NOT NULL DEFAULT FALSE,
    price NUMERIC(9, 3) NOT NULL,
    inserted_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()
);

CREATE INDEX ON purchases (seller_id) WHERE inbalance = FALSE;
CREATE INDEX ON purchases (seller_id) WHERE refund = TRUE AND rebalance = FALSE;

CREATE TABLE seller_pays(
    id BIGSERIAL PRIMARY KEY,
    seller_id int NOT NULL REFERENCES sellers(id),
    balance NUMERIC(9, 3) NOT NULL,
    inserted_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()
);

CREATE OR REPLACE FUNCTION seller_last_pay(s_id INT) RETURNS DATE AS $$
    DECLARE
        last_pay_date DATE;
    BEGIN
        SELECT DATE(inserted_at) INTO last_pay_date FROM seller_pays WHERE seller_id = s_id ORDER BY inserted_at DESC LIMIT 1;
        -- when don't previus pay...
        IF last_pay_date IS NULL THEN
            SELECT DATE(inserted_at) INTO last_pay_date FROM sellers WHERE id = s_id;
        END IF;
        RETURN last_pay_date;
    END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION run_seller_pay(s_id INT) RETURNS SETOF seller_pays AS $$
    --- transaction !!!
    DECLARE
        purchase_val NUMERIC(9, 3);
        refund_val NUMERIC(9, 3);
        seller sellers%ROWTYPE;
        last_pay seller_pays%ROWTYPE;
        last_pay_date DATE;
    BEGIN
        SELECT * INTO seller FROM sellers WHERE id = s_id;
        SELECT * INTO last_pay FROM seller_pays WHERE seller_id = s_id ORDER BY inserted_at DESC LIMIT 1;
        last_pay_date := seller_last_pay(s_id);

        IF (DATE(NOW()) - seller.days_for_pay) <= last_pay_date THEN
            RETURN NEXT last_pay;
            RETURN;
        END IF;

        SELECT SUM(price) FROM purchases
        WHERE seller_id = s_id
            AND inbalance = FALSE
            AND DATE(inserted_at) <= DATE(NOW()) - seller.days_until_pay
        INTO purchase_val;

        SELECT SUM(price) FROM purchases
        WHERE seller_id = s_id
            AND refund = TRUE
            AND rebalance = FALSE
        INTO refund_val;

        INSERT INTO seller_pays (seller_id, balance)
        VALUES(s_id, COALESCE(purchase_val, 0) - COALESCE(refund_val, 0)) RETURNING *
        INTO last_pay;

        -- refund in any time
        UPDATE purchases SET rebalance = TRUE
            WHERE rebalance = FALSE
            AND refund = TRUE
            AND DATE(inserted_at) <= DATE(NOW()) - seller.days_until_pay;

        -- mark as in balance
        UPDATE purchases SET inbalance = TRUE
            WHERE inbalance = FALSE
            AND DATE(inserted_at) <= DATE(NOW()) - seller.days_until_pay;

        RETURN NEXT last_pay;
    END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION seller_balance(s_id INT) RETURNS NUMERIC(9, 3) AS $$
    DECLARE
        purchase_val NUMERIC(9, 3);
        refund_val NUMERIC(9, 3);
        seller sellers%ROWTYPE;
        last_pay_date DATE;
    BEGIN
        last_pay_date := seller_last_pay(s_id);
        SELECT * INTO seller FROM sellers WHERE id = s_id;

        SELECT SUM(price) FROM purchases
        WHERE seller_id = s_id
            AND inbalance = FALSE
        INTO purchase_val;

        SELECT SUM(price) FROM purchases
        WHERE seller_id = s_id
            AND refund = TRUE
            AND rebalance = FALSE
        INTO refund_val;

        RETURN COALESCE(purchase_val, 0) - COALESCE(refund_val, 0);
    END
$$ LANGUAGE plpgsql;

COMMIT;
