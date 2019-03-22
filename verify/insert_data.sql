-- Verify marketplace:insert_data on pg

BEGIN;

DO $$
DECLARE
    balance NUMERIC(9, 3);
    seller_pay seller_pays%ROWTYPE;
BEGIN
    balance := (SELECT seller_balance FROM seller_balance(1));
    ASSERT (balance = 7502.500), 'balance for seller 1';

    select * into seller_pay from run_seller_pay(1);
    ASSERT seller_pay.balance = 6002.000, 'pay balance for seller 1';

    select * into seller_pay from run_seller_pay(1);
    ASSERT seller_pay.id = 2, 'equal seller_pay';

    balance := (SELECT seller_balance FROM seller_balance(1));
    ASSERT (balance = 1500.500), 'current balance for seller 1';

    UPDATE purchases SET refund = TRUE WHERE id = 5;
    balance := (SELECT seller_balance FROM seller_balance(1));
    ASSERT (balance = 0), 'considering refund in balance for seller 1';

END $$;

ROLLBACK;
