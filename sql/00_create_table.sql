-- Creates the table first so DBeaver does not guess column types during the CSV import
-- (its default guess of VARCHAR(50) failed on long text such as job titles).
-- Then import fraudTrain.csv into this table (Import Data -> CSV).
CREATE TABLE public.transactions_raw (
  column1               BIGINT,
  trans_date_trans_time TIMESTAMP,
  cc_num                TEXT,
  merchant              TEXT,
  category              TEXT,
  amt                   NUMERIC(12,2),
  "first"               TEXT,
  "last"                TEXT,
  gender                TEXT,
  street                TEXT,
  city                  TEXT,
  state                 TEXT,
  zip                   TEXT,
  lat                   FLOAT8,
  long                  FLOAT8,
  city_pop              INTEGER,
  job                   TEXT,
  dob                   DATE,
  trans_num             TEXT,
  unix_time             BIGINT,
  merch_lat             FLOAT8,
  merch_long            FLOAT8,
  is_fraud              SMALLINT
);
