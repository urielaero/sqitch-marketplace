-- Deploy marketplace:insert_data to pg

BEGIN;


INSERT INTO sellers(id, days_for_pay, days_until_pay) VALUES(1, 10, 5);
INSERT INTO sellers(id, days_for_pay, days_until_pay) VALUES(2, 5, 4);

INSERT INTO products(id, seller_id, price) VALUES (1, 1, 1500.50);
INSERT INTO products(id, seller_id, price) VALUES (2, 1, 1000.50);

INSERT INTO products(id, seller_id, price) VALUES (3, 2, 500.50);
INSERT INTO products(id, seller_id, price) VALUES (4, 2, 1000.50);

INSERT INTO purchases(id, seller_id, product_id, price, inserted_at) VALUES (1, 1, 1, 1500.50, TO_TIMESTAMP('01-01-2017 10:2', 'DD-MM-YYYY SS:MS'));
INSERT INTO purchases(id, seller_id, product_id, price, inserted_at) VALUES (2, 1, 1, 1500.50, TO_TIMESTAMP('01-01-2017 10:2', 'DD-MM-YYYY SS:MS'));
INSERT INTO purchases(id, seller_id, product_id, price, inserted_at) VALUES (3, 1, 1, 1500.50, TO_TIMESTAMP('01-01-2017 10:2', 'DD-MM-YYYY SS:MS'));
INSERT INTO purchases(id, seller_id, product_id, price, inserted_at) VALUES (4, 1, 1, 1500.50, TO_TIMESTAMP('01-01-2017 10:2', 'DD-MM-YYYY SS:MS'));
INSERT INTO purchases(id, seller_id, product_id, price) VALUES (5, 1, 1, 1500.50);

INSERT INTO seller_pays(seller_id, balance, inserted_at) VALUES (1, 0, TO_TIMESTAMP('01-01-2017 10:2', 'DD-MM-YYYY SS:MS'));

COMMIT;
