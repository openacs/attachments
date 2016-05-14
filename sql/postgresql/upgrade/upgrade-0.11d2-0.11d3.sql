--
-- Alter caveman style booleans (type character(1)) to real SQL boolean types.
--

ALTER TABLE attachments
      DROP constraint IF EXISTS attachments_approved_p_ck,
      ALTER COLUMN approved_p DROP DEFAULT,
      ALTER COLUMN approved_p TYPE boolean
      USING approved_p::boolean,
      ALTER COLUMN approved_p SET DEFAULT true;

