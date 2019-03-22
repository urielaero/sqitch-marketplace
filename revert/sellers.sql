-- Revert marketplace:sellers from pg

BEGIN;


DROP FUNCTION seller_balance(INT);
DROP FUNCTION run_seller_pay(INT);
DROP FUNCTION seller_last_pay(INT);

DROP TABLE purchases;
DROP TABLE products;
DROP TABLE seller_pays;
DROP TABLE sellers;

COMMIT;
