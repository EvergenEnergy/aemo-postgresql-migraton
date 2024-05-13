/*==============================================================*/
/* DBMS name:      AEMO Electricity Data Model v5.3.0.2         */
/* Created on:     2024/04/04                                   */
/*==============================================================*/

-- Set the search path to the EMMS schema (this is an Evergen convention)
SET search_path TO emms, public;

alter table ANCILLARY_RECOVERY_SPLIT add ACE_PORTION NUMERIC(18,8);

comment on column ANCILLARY_RECOVERY_SPLIT.ACE_PORTION is
    'The percentage value of the recovery funded using the ACE MWh Values. This field is only used for Settlement post IESS rule effective date.';


/*==============================================================*/
/* Table: BIDDAYOFFER                                           */
/*==============================================================*/

DO $$
    DECLARE
v_sql TEXT;
BEGIN
        IF NOT EXISTS (SELECT 1
                       FROM pg_constraint c
                                JOIN pg_class cl ON c.conrelid = cl.oid
                                JOIN pg_attribute a ON a.attrelid = cl.oid AND a.attnum = ANY (c.conkey)
                                JOIN pg_namespace n ON cl.relnamespace = n.oid
                       WHERE n.nspname = current_schema() -- Defaults to the current schema, similar to schema_name() in SQL Server
                         AND cl.relname IN ('BIDDAYOFFER', 'BIDDAYOFFER_DM53')
                         AND a.attname = 'DIRECTION'
                         AND c.contype = 'p' -- 'p' stands for primary key constraint
        ) THEN

            EXECUTE 'ALTER TABLE BIDDAYOFFER add DIRECTION VARCHAR(20)';
EXECUTE 'ALTER INDEX BIDDAYOFFER_PK RENAME TO BIDDAYOFFER_PK_PRE53';
EXECUTE 'ALTER index BIDDAYOFFER_LCHD_IDX RENAME TO BIDDAYOFFER_LCHD_IDX_PRE53';
EXECUTE 'ALTER index BIDDAYOFFER_PART_IDX RENAME TO BIDDAYOFFER_PART_IDX_PRE53';
EXECUTE 'ALTER TABLE BIDDAYOFFER rename to BIDDAYOFFER_PRE53';
RAISE NOTICE 'Renamed BIDDAYOFFER constraint and table.';

            v_sql := 'CREATE TABLE BIDDAYOFFER (
											   DUID                 VARCHAR(10)          not null,
											   BIDTYPE              VARCHAR(10)          not null,
											   SETTLEMENTDATE       TIMESTAMP(0)         not null,
											   OFFERDATE            TIMESTAMP(0)         not null,
											   DIRECTION            VARCHAR(20)          not null,
											   VERSIONNO            NUMERIC(22,0),
											   PARTICIPANTID        VARCHAR(10),
											   DAILYENERGYCONSTRAINT NUMERIC(12,6),
											   REBIDEXPLANATION     VARCHAR(500),
											   PRICEBAND1           NUMERIC(9,2),
											   PRICEBAND2           NUMERIC(9,2),
											   PRICEBAND3           NUMERIC(9,2),
											   PRICEBAND4           NUMERIC(9,2),
											   PRICEBAND5           NUMERIC(9,2),
											   PRICEBAND6           NUMERIC(9,2),
											   PRICEBAND7           NUMERIC(9,2),
											   PRICEBAND8           NUMERIC(9,2),
											   PRICEBAND9           NUMERIC(9,2),
											   PRICEBAND10          NUMERIC(9,2),
											   MINIMUMLOAD          NUMERIC(22,0),
											   T1                   NUMERIC(22,0),
											   T2                   NUMERIC(22,0),
											   T3                   NUMERIC(22,0),
											   T4                   NUMERIC(22,0),
											   NORMALSTATUS         VARCHAR(3),
											   LASTCHANGED          TIMESTAMP(0),
											   MR_FACTOR            NUMERIC(16,6),
											   ENTRYTYPE            VARCHAR(20),
											   REBID_EVENT_TIME     VARCHAR(20),
											   REBID_AWARE_TIME     VARCHAR(20),
											   REBID_DECISION_TIME  VARCHAR(20),
											   REBID_CATEGORY       VARCHAR(1),
											   REFERENCE_ID         VARCHAR(100)
											)';

EXECUTE v_sql;
RAISE NOTICE 'Created BIDDAYOFFER table with new PK';
            v_sql := 'ALTER TABLE BIDDAYOFFER add constraint BIDDAYOFFER_PK primary key (SETTLEMENTDATE, BIDTYPE, DUID, OFFERDATE, DIRECTION)';
EXECUTE v_sql;
v_sql := 'create index BIDDAYOFFER_LCHD_IDX on BIDDAYOFFER (LASTCHANGED ASC )';
EXECUTE v_sql;
v_sql := 'create index BIDDAYOFFER_PART_IDX on BIDDAYOFFER (PARTICIPANTID ASC )';
EXECUTE v_sql;
RAISE NOTICE 'Created indexes on BIDDAYOFFER table';
END IF;
END $$;


comment on table BIDDAYOFFER is
    'BIDDAYOFFER shows the Energy and Ancillary Service bid data for each Market Day. BIDDAYOFFER is the parent table to BIDOFFERPERIOD. BIDDAYOFFER is a child table to BIDOFFERFILETRK';

comment on column BIDDAYOFFER.DUID is
    'Dispatchable unit identifier';

comment on column BIDDAYOFFER.BIDTYPE is
    'Bid Type Identifier';

comment on column BIDDAYOFFER.SETTLEMENTDATE is
    'Market date for applying the bid';

comment on column BIDDAYOFFER.OFFERDATE is
    'Time this bid was processed and loaded';

comment on column BIDDAYOFFER.DIRECTION is
    'The power flow direction to which this offer applies: GEN, LOAD or BIDIRECTIONAL';

comment on column BIDDAYOFFER.VERSIONNO is
    'Version No. for given offer date';

comment on column BIDDAYOFFER.PARTICIPANTID is
    'Unique participant identifier';

comment on column BIDDAYOFFER.DAILYENERGYCONSTRAINT is
    'Maximum energy available from Energy Constrained Plant. (Energy Bids Only)';

comment on column BIDDAYOFFER.REBIDEXPLANATION is
    'Explanation for all rebids and inflexibilities';

comment on column BIDDAYOFFER.PRICEBAND1 is
    'Price for Availability Band 1';

comment on column BIDDAYOFFER.PRICEBAND2 is
    'Price for Availability Band 2';

comment on column BIDDAYOFFER.PRICEBAND3 is
    'Price for Availability Band 3';

comment on column BIDDAYOFFER.PRICEBAND4 is
    'Price for Availability Band 4';

comment on column BIDDAYOFFER.PRICEBAND5 is
    'Price for Availability Band 5';

comment on column BIDDAYOFFER.PRICEBAND6 is
    'Price for Availability Band 6';

comment on column BIDDAYOFFER.PRICEBAND7 is
    'Price for Availability Band 6';

comment on column BIDDAYOFFER.PRICEBAND8 is
    'Price for Availability Band 8';

comment on column BIDDAYOFFER.PRICEBAND9 is
    'Price for Availability Band 9';

comment on column BIDDAYOFFER.PRICEBAND10 is
    'Price for Availability Band 10';

comment on column BIDDAYOFFER.MINIMUMLOAD is
    'Minimum MW load fast start plant';

comment on column BIDDAYOFFER.T1 is
    'Time to synchronise in minutes (Energy Bids Only)';

comment on column BIDDAYOFFER.T2 is
    'Time to minimum load in minutes (Energy Bids Only)';

comment on column BIDDAYOFFER.T3 is
    'Time at minimum load in minutes (Energy Bids Only)';

comment on column BIDDAYOFFER.T4 is
    'Time to shutdown in minutes (Energy Bids Only)';

comment on column BIDDAYOFFER.NORMALSTATUS is
    'not used; was ON/OFF for loads (Energy Bids Only)';

comment on column BIDDAYOFFER.LASTCHANGED is
    'Last date and time record changed';

comment on column BIDDAYOFFER.MR_FACTOR is
    'Mandatory Restriction Offer Factor';

comment on column BIDDAYOFFER.ENTRYTYPE is
    'Daily if processed before BidCutOff of previous day, otherwise REBID';

comment on column BIDDAYOFFER.REBID_EVENT_TIME is
    'The time of the event(s) or other occurrence(s) cited/adduced as the reason for the rebid. Required for rebids, not required for fixed load or low ramp rates. Expected in the format: HH:MM:SS e.g. 20:11:00';

comment on column BIDDAYOFFER.REBID_AWARE_TIME is
    'Intended to support the Rebidding and Technical Parameters Guideline. The time at which the participant became aware of the event(s) / occurrence(s) that prompted the rebid.Not validated by AEMO';

comment on column BIDDAYOFFER.REBID_DECISION_TIME is
    'Intended to support the Rebidding and Technical Parameters Guideline. The time at which the participant made the decision to rebid. Not validated by AEMO';

comment on column BIDDAYOFFER.REBID_CATEGORY is
    'Intended to support the Rebidding and Technical Parameters Guideline. A provided rebid category. Not validated by AEMO';

comment on column BIDDAYOFFER.REFERENCE_ID is
    'A participants unique Reference Id';

/*==============================================================*/
/* Table: BIDDAYOFFER_D                                         */
/*==============================================================*/

DO $$
    DECLARE
v_constraint_exists INTEGER;
        v_sql TEXT;
BEGIN
SELECT INTO v_constraint_exists COUNT(*)
FROM information_schema.table_constraints AS tc
    JOIN information_schema.constraint_column_usage AS ccu ON tc.constraint_name = ccu.constraint_name AND tc.table_schema = ccu.table_schema
WHERE tc.table_schema = current_schema()
  AND tc.table_name = 'BIDDAYOFFER_D'
  AND ccu.column_name = 'DIRECTION';

IF v_constraint_exists = 0 THEN
            -- Perform the operations
            EXECUTE 'ALTER TABLE BIDDAYOFFER_D ADD COLUMN direction VARCHAR(20);';
EXECUTE 'ALTER INDEX BIDDAYOFFER_D_PK RENAME TO BIDDAYOFFER_D_PK_pre53;';
EXECUTE 'ALTER INDEX BIDDAYOFFER_D_LCHD_IDX RENAME TO BIDDAYOFFER_D_PK_LCHD_IDX_PRE53;';
EXECUTE 'ALTER INDEX BIDDAYOFFER_D_PART_IDX RENAME TO BIDDAYOFFER_D_PK_PART_IDX_PRE53;';
EXECUTE 'ALTER TABLE BIDDAYOFFER_D RENAME TO BIDDAYOFFER_D_PRE53;';
RAISE NOTICE 'Renamed BIDDAYOFFER_d constraint and table.';

            -- Table creation
            v_sql := 'CREATE TABLE BIDDAYOFFER_D (
                    settlementdate       TIMESTAMP(0) NOT NULL,
                    duid                 VARCHAR(10) NOT NULL,
                    bidtype              VARCHAR(10) NOT NULL,
                    direction            VARCHAR(20) NOT NULL,
                    bidsettlementdate    TIMESTAMP(0),
                    offerdate            TIMESTAMP(0),
                    versionno            NUMERIC(22,0),
                    participantid        VARCHAR(10),
                    dailyenergyconstraint NUMERIC(12,6),
                    rebidexplanation     VARCHAR(500),
                    priceband1           NUMERIC(9,2),
                    priceband2           NUMERIC(9,2),
                    priceband3           NUMERIC(9,2),
                    priceband4           NUMERIC(9,2),
                    priceband5           NUMERIC(9,2),
                    priceband6           NUMERIC(9,2),
                    priceband7           NUMERIC(9,2),
                    priceband8           NUMERIC(9,2),
                    priceband9           NUMERIC(9,2),
                    priceband10          NUMERIC(9,2),
                    minimumload          NUMERIC(22,0),
                    t1                   NUMERIC(22,0),
                    t2                   NUMERIC(22,0),
                    t3                   NUMERIC(22,0),
                    t4                   NUMERIC(22,0),
                    normalstatus         VARCHAR(3),
                    lastchanged          TIMESTAMP(0),
                    mr_factor            NUMERIC(16,6),
                    entrytype            VARCHAR(20)
                  );';
EXECUTE v_sql;
RAISE NOTICE 'Created BIDDAYOFFER_D table with new PK.';

            -- Constraint and index creation with tablespaces if needed
EXECUTE 'ALTER TABLE BIDDAYOFFER_d ADD CONSTRAINT BIDDAYOFFER_D_PK PRIMARY KEY (settlementdate, bidtype, duid, direction);';
EXECUTE 'CREATE INDEX BIDDAYOFFER_D_LCHD_IDX ON BIDDAYOFFER_D (lastchanged);';
EXECUTE 'CREATE INDEX BIDDAYOFFER_D_PART_IDX ON BIDDAYOFFER_D (participantid);';
RAISE NOTICE 'Created indexes on BIDDAYOFFER_d table.';
END IF;
END
$$ LANGUAGE plpgsql;


comment on table BIDDAYOFFER_D is
    'BIDDAYOFFER_D shows the public summary of the energy and FCAS offers applicable in the Dispatch for the
    intervals identified. BIDDAYOFFER_D is the parent table to BIDPEROFFER_D.';

comment on column BIDDAYOFFER_D.SETTLEMENTDATE is
    'Market date for which the bid applied';

comment on column BIDDAYOFFER_D.DUID is
    'Dispatchable unit identifier';

comment on column BIDDAYOFFER_D.BIDTYPE is
    'Bid Type Identifier';

comment on column BIDDAYOFFER_D.DIRECTION is
    'The power flow direction to which this offer applies: GEN, LOAD or BIDIRECTIONAL';

comment on column BIDDAYOFFER_D.BIDSETTLEMENTDATE is
    'Market date for which the bid was submitted.';

comment on column BIDDAYOFFER_D.OFFERDATE is
    'Offer date and time';

comment on column BIDDAYOFFER_D.VERSIONNO is
    'Version No. for given offer date';

comment on column BIDDAYOFFER_D.PARTICIPANTID is
    'Unique participant identifier';

comment on column BIDDAYOFFER_D.DAILYENERGYCONSTRAINT is
    'Maximum energy available from Energy Constrained Plant. (Energy Bids Only)';

comment on column BIDDAYOFFER_D.REBIDEXPLANATION is
    'Explanation for all rebids and inflexibilities';

comment on column BIDDAYOFFER_D.PRICEBAND1 is
    'Price for Availability Band 1';

comment on column BIDDAYOFFER_D.PRICEBAND2 is
    'Price for Availability Band 2';

comment on column BIDDAYOFFER_D.PRICEBAND3 is
    'Price for Availability Band 3';

comment on column BIDDAYOFFER_D.PRICEBAND4 is
    'Price for Availability Band 4';

comment on column BIDDAYOFFER_D.PRICEBAND5 is
    'Price for Availability Band 5';

comment on column BIDDAYOFFER_D.PRICEBAND6 is
    'Price for Availability Band 6';

comment on column BIDDAYOFFER_D.PRICEBAND7 is
    'Price for Availability Band 7';

comment on column BIDDAYOFFER_D.PRICEBAND8 is
    'Price for Availability Band 8';

comment on column BIDDAYOFFER_D.PRICEBAND9 is
    'Price for Availability Band 9';

comment on column BIDDAYOFFER_D.PRICEBAND10 is
    'Price for Availability Band 10';

comment on column BIDDAYOFFER_D.MINIMUMLOAD is
    'Minimum MW load fast start plant';

comment on column BIDDAYOFFER_D.T1 is
    'Time to synchronise in minutes (Energy Bids Only)';

comment on column BIDDAYOFFER_D.T2 is
    'Time to minimum load in minutes (Energy Bids Only)';

comment on column BIDDAYOFFER_D.T3 is
    'Time at minimum load in minutes (Energy Bids Only)';

comment on column BIDDAYOFFER_D.T4 is
    'Time to shutdown in minutes (Energy Bids Only)';

comment on column BIDDAYOFFER_D.NORMALSTATUS is
    'ON/OFF for loads (Energy Bids Only)';

comment on column BIDDAYOFFER_D.LASTCHANGED is
    'Last date and time record changed';

comment on column BIDDAYOFFER_D.MR_FACTOR is
    'Mandatory Restriction Scaling Factor';

comment on column BIDDAYOFFER_D.ENTRYTYPE is
    'Daily if processed before BidCutOff of previous day, otherwise REBID';

/*==============================================================*/
/* Table: BIDOFFERPERIOD                                        */
/*==============================================================*/

DO $$
    DECLARE
v_column_exists INTEGER;
        v_sql TEXT;
BEGIN
        -- Check for the existence of the primary key constraint on 'DIRECTION'
SELECT COUNT(*)
INTO v_column_exists
FROM pg_constraint c
         JOIN pg_class cl ON c.conrelid = cl.oid
         JOIN pg_attribute a ON a.attrelid = cl.oid AND a.attnum = ANY(c.conkey)
         JOIN pg_namespace n ON cl.relnamespace = n.oid
WHERE n.nspname = current_schema()
  AND cl.relname IN ('bidofferperiod', 'bidofferperiod_dm53')
  AND a.attname = 'direction'
  AND c.contype = 'p';

IF v_column_exists = 0 THEN
            EXECUTE 'ALTER TABLE bidofferperiod ADD COLUMN direction VARCHAR(20);';
EXECUTE 'ALTER TABLE bidofferperiod ADD COLUMN energylimit NUMERIC(15,5);';

-- Check if 'PERIODIDTO' column exists
SELECT COUNT(*)
INTO v_column_exists
FROM pg_attribute
WHERE attrelid = 'bidofferperiod'::regclass
              AND attname = 'periodidto';

IF v_column_exists = 0 THEN
                EXECUTE 'ALTER TABLE bidofferperiod ADD COLUMN periodidto NUMERIC(3,0);';
END IF;

            -- Renaming of the primary key constraint is not straightforward in PostgreSQL.
            -- You need to drop and recreate the constraint for changes other than name.
EXECUTE 'ALTER INDEX bidofferperiod_pk RENAME TO bidofferperiod_pk_pre53;';
EXECUTE 'ALTER TABLE bidofferperiod RENAME TO bidofferperiod_pre53;';
RAISE NOTICE 'Renamed bidofferperiod constraint and table.';

            -- Creating new table
            v_sql := 'CREATE TABLE bidofferperiod (
                    duid                 VARCHAR(20) NOT NULL,
                    bidtype              VARCHAR(10) NOT NULL,
                    tradingdate          TIMESTAMP(0) NOT NULL,
                    offerdatetime        TIMESTAMP(0) NOT NULL,
                    direction            VARCHAR(20) NOT NULL,
                    periodid             NUMERIC(3,0) NOT NULL,
                    maxavail             NUMERIC(8,3),
                    fixedload            NUMERIC(8,3),
                    rampuprate           NUMERIC(6),
                    rampdownrate         NUMERIC(6),
                    enablementmin        NUMERIC(8,3),
                    enablementmax        NUMERIC(8,3),
                    lowbreakpoint        NUMERIC(8,3),
                    highbreakpoint       NUMERIC(8,3),
                    bandavail1           NUMERIC(8,3),
                    bandavail2           NUMERIC(8,3),
                    bandavail3           NUMERIC(8,3),
                    bandavail4           NUMERIC(8,3),
                    bandavail5           NUMERIC(8,3),
                    bandavail6           NUMERIC(8,3),
                    bandavail7           NUMERIC(8,3),
                    bandavail8           NUMERIC(8,3),
                    bandavail9           NUMERIC(8,3),
                    bandavail10          NUMERIC(8,3),
                    pasaavailability     NUMERIC(8,3),
                    energylimit          NUMERIC(15,5),
                    periodidto           NUMERIC(3,0)
                  );';
EXECUTE v_sql;
RAISE NOTICE 'Created bidofferperiod table with new PK.';

            -- Add primary key
EXECUTE 'ALTER TABLE bidofferperiod ADD CONSTRAINT bidofferperiod_pk PRIMARY KEY (tradingdate, bidtype, duid, offerdatetime, direction, periodid);';

RAISE NOTICE 'Created indexes on bidofferperiod table.';
END IF;
END
$$ LANGUAGE plpgsql;


comment on table BIDOFFERPERIOD is
    'BIDOFFERPERIOD shows 5-minute period-based Energy and Ancillary Service bid data.BIDOFFERPERIOD is a child table of BIDDAYOFFER';

comment on column BIDOFFERPERIOD.DUID is
    'Dispatchable Unit ID';

comment on column BIDOFFERPERIOD.BIDTYPE is
    'The type of bid, one-of ENERGY, RAISE6SEC, RAISE60SEC, RAISE5MIN, RAISEREG, LOWER6SEC, LOWER60SEC, LOWER5MIN, LOWERREG';

comment on column BIDOFFERPERIOD.TRADINGDATE is
    'The trading date this bid is for';

comment on column BIDOFFERPERIOD.OFFERDATETIME is
    'Time this bid was processed and loaded';

comment on column BIDOFFERPERIOD.DIRECTION is
    'The power flow direction to which this offer applies: GEN, LOAD or BIDIRECTIONAL';

comment on column BIDOFFERPERIOD.PERIODID is
    'Period ID 1 to 288';

comment on column BIDOFFERPERIOD.MAXAVAIL is
    'Maximum availability for this BidType in this period';

comment on column BIDOFFERPERIOD.FIXEDLOAD is
    'Fixed unit output MW (Energy bids only) A null value means no fixed load so the unit is dispatched according to bid and market';

comment on column BIDOFFERPERIOD.RAMPUPRATE is
    'MW/Min for raise (Energy bids only)';

comment on column BIDOFFERPERIOD.RAMPDOWNRATE is
    'MW/Min for lower (Energy bids only)';

comment on column BIDOFFERPERIOD.ENABLEMENTMIN is
    'Minimum Energy Output (MW) at which this ancillary service becomes available (AS Only)';

comment on column BIDOFFERPERIOD.ENABLEMENTMAX is
    'Maximum Energy Output (MW) at which this ancillary service can be supplied (AS Only)';

comment on column BIDOFFERPERIOD.LOWBREAKPOINT is
    'Minimum Energy Output (MW) at which the unit can provide the full availability (MAXAVAIL) for this ancillary service (AS Only)';

comment on column BIDOFFERPERIOD.HIGHBREAKPOINT is
    'Maximum Energy Output (MW) at which the unit can provide the full availability (MAXAVAIL) for this ancillary service (AS Only)';

comment on column BIDOFFERPERIOD.BANDAVAIL1 is
    'Availability at price band 1';

comment on column BIDOFFERPERIOD.BANDAVAIL2 is
    'Availability at price band 2';

comment on column BIDOFFERPERIOD.BANDAVAIL3 is
    'Availability at price band 3';

comment on column BIDOFFERPERIOD.BANDAVAIL4 is
    'Availability at price band 4';

comment on column BIDOFFERPERIOD.BANDAVAIL5 is
    'Availability at price band 5';

comment on column BIDOFFERPERIOD.BANDAVAIL6 is
    'Availability at price band 6';

comment on column BIDOFFERPERIOD.BANDAVAIL7 is
    'Availability at price band 7';

comment on column BIDOFFERPERIOD.BANDAVAIL8 is
    'Availability at price band 8';

comment on column BIDOFFERPERIOD.BANDAVAIL9 is
    'Availability at price band 9';

comment on column BIDOFFERPERIOD.BANDAVAIL10 is
    'Availability at price band 10';

comment on column BIDOFFERPERIOD.PASAAVAILABILITY is
    'Allows for future use for Energy bids, being the physical plant capability including any capability potentially available within 24 hours';

comment on column BIDOFFERPERIOD.ENERGYLIMIT is
    'The Energy limit applying at the end of this dispatch interval in MWh. For GEN this is a lower energy limit. For LOAD this is an upper energy limit';

comment on column BIDOFFERPERIOD.PERIODIDTO is
    'Period ID Ending';

/*==============================================================*/
/* Table: BIDPEROFFER_D                                         */
/*==============================================================*/

DO $$
    DECLARE
v_column_exists INTEGER;
        v_sql TEXT;
BEGIN
        -- Check if a primary key constraint exists on 'DIRECTION' for 'BIDPEROFFER_D'
SELECT COUNT(*)
INTO v_column_exists
FROM pg_constraint c
         JOIN pg_class cl ON c.conrelid = cl.oid
         JOIN pg_attribute a ON a.attrelid = cl.oid AND a.attnum = ANY(c.conkey)
         JOIN pg_namespace n ON cl.relnamespace = n.oid
WHERE n.nspname = current_schema()
  AND cl.relname = 'bidperoffer_d'
  AND a.attname = 'direction'
  AND c.contype = 'p';

IF v_column_exists = 0 THEN
            -- Alter table commands
            EXECUTE 'ALTER TABLE bidperoffer_d ADD COLUMN direction VARCHAR(20);';
EXECUTE 'ALTER TABLE bidperoffer_d ADD COLUMN energylimit NUMERIC(15,5);';
EXECUTE 'ALTER INDEX BIDPEROFFER_D_LCHD_IDX RENAME TO BIDPEROFFER_D_LCHD_IDX_PRE53';
EXECUTE 'ALTER INDEX BIDPEROFFER_D_PK RENAME TO BIDPEROFFER_D_PK_PRE53';
EXECUTE 'ALTER TABLE bidperoffer_d RENAME TO bidperoffer_d_pre53;';
RAISE NOTICE 'Renamed bidperoffer_d constraint and table.';

            -- Create new table
            v_sql := 'CREATE TABLE bidperoffer_d (
                    settlementdate       DATE NOT NULL,
                    duid                 VARCHAR(10) NOT NULL,
                    bidtype              VARCHAR(10) NOT NULL,
                    direction            VARCHAR(20) NOT NULL,
                    interval_datetime    TIMESTAMP(0) NOT NULL,
                    bidsettlementdate    TIMESTAMP(0),
                    offerdate            TIMESTAMP(0),
                    periodid             NUMERIC(22,0),
                    versionno            NUMERIC(22,0),
                    maxavail             NUMERIC(12,6),
                    fixedload            NUMERIC(12,6),
                    rocup                NUMERIC(6,0),
                    rocdown              NUMERIC(6,0),
                    enablementmin        NUMERIC(6,0),
                    enablementmax        NUMERIC(6,0),
                    lowbreakpoint        NUMERIC(6,0),
                    highbreakpoint       NUMERIC(6,0),
                    bandavail1           NUMERIC(22,0),
                    bandavail2           NUMERIC(22,0),
                    bandavail3           NUMERIC(22,0),
                    bandavail4           NUMERIC(22,0),
                    bandavail5           NUMERIC(22,0),
                    bandavail6           NUMERIC(22,0),
                    bandavail7           NUMERIC(22,0),
                    bandavail8           NUMERIC(22,0),
                    bandavail9           NUMERIC(22,0),
                    bandavail10          NUMERIC(22,0),
                    lastchanged          TIMESTAMP(0),
                    pasaavailability     NUMERIC(12,0),
                    mr_capacity          NUMERIC(6,0),
                    energylimit          NUMERIC(15,5)
                  );';
EXECUTE v_sql;
RAISE NOTICE 'Created BIDPEROFFER_D table with new PK.';

            -- Add primary key
EXECUTE 'ALTER TABLE bidperoffer_d ADD CONSTRAINT bidperoffer_d_pk PRIMARY KEY (settlementdate, bidtype, duid, direction, interval_datetime);';

-- Create indexes
EXECUTE 'CREATE INDEX bidperoffer_d_lchd_idx ON bidperoffer_d (lastchanged ASC);';

RAISE NOTICE 'Created indexes on BIDPEROFFER_D table.';
END IF;
END
$$ LANGUAGE plpgsql;


comment on table BIDPEROFFER_D is
    'BIDPEROFFER_D shows the public summary of the energy and FCAS offers applicable in the Dispatch for the
    intervals identified. BIDPEROFFER_D is the child to BIDDAYOFFER_D.';

comment on column BIDPEROFFER_D.SETTLEMENTDATE is
    'Market date for which the bid applied';

comment on column BIDPEROFFER_D.DUID is
    'Dispatchable Unit identifier';

comment on column BIDPEROFFER_D.BIDTYPE is
    'Bid Type Identifier';

comment on column BIDPEROFFER_D.DIRECTION is
    'The power flow direction to which this offer applies: GEN, LOAD or BIDIRECTIONAL';

comment on column BIDPEROFFER_D.INTERVAL_DATETIME is
    'Date and Time of the dispatch interval to which the offer applied';

comment on column BIDPEROFFER_D.BIDSETTLEMENTDATE is
    'Market date for which the bid was submitted';

comment on column BIDPEROFFER_D.OFFERDATE is
    'Offer date and time';

comment on column BIDPEROFFER_D.PERIODID is
    'The trading interval period identifier (1-48)';

comment on column BIDPEROFFER_D.VERSIONNO is
    'Version number of offer';

comment on column BIDPEROFFER_D.MAXAVAIL is
    'Maximum availability for this BidType in this period';

comment on column BIDPEROFFER_D.FIXEDLOAD is
    'Fixed unit output MW (Energy Bids Only).  A value of zero means no fixed load so the unit is dispatched according to bid and market (rather than zero fixed load)';

comment on column BIDPEROFFER_D.ROCUP is
    'MW/min for raise (Energy Bids Only)';

comment on column BIDPEROFFER_D.ROCDOWN is
    'MW/Min for lower (Energy Bids Only)';

comment on column BIDPEROFFER_D.ENABLEMENTMIN is
    'Minimum Energy Output (MW) at which this ancillary service becomes available (AS Only)';

comment on column BIDPEROFFER_D.ENABLEMENTMAX is
    'Maximum Energy Output (MW) at which this ancillary service can be supplied (AS Only)';

comment on column BIDPEROFFER_D.LOWBREAKPOINT is
    'Minimum Energy Output (MW) at which the unit can provide the full availability (MAXAVAIL) for this ancillary service (AS Only)';

comment on column BIDPEROFFER_D.HIGHBREAKPOINT is
    'Maximum Energy Output (MW) at which the unit can provide the full availability (MAXAVAIL) for this ancillary service (AS Only)';

comment on column BIDPEROFFER_D.BANDAVAIL1 is
    'Availability at price band 1';

comment on column BIDPEROFFER_D.BANDAVAIL2 is
    'Availability at price band 2';

comment on column BIDPEROFFER_D.BANDAVAIL3 is
    'Availability at price band 3';

comment on column BIDPEROFFER_D.BANDAVAIL4 is
    'Availability at price band 4';

comment on column BIDPEROFFER_D.BANDAVAIL5 is
    'Availability at price band 5';

comment on column BIDPEROFFER_D.BANDAVAIL6 is
    'Availability at price band 6';

comment on column BIDPEROFFER_D.BANDAVAIL7 is
    'Availability at price band 7';

comment on column BIDPEROFFER_D.BANDAVAIL8 is
    'Availability at price band 8';

comment on column BIDPEROFFER_D.BANDAVAIL9 is
    'Availability at price band 9';

comment on column BIDPEROFFER_D.BANDAVAIL10 is
    'Availability at price band 10';

comment on column BIDPEROFFER_D.LASTCHANGED is
    'Last date and time record changed';

comment on column BIDPEROFFER_D.PASAAVAILABILITY is
    'Allows for future use for energy bids, being the physical plant capability including any capability potentially available within 24 hours';

comment on column BIDPEROFFER_D.MR_CAPACITY is
    'Mandatory Restriction Offer amount';

comment on column BIDPEROFFER_D.ENERGYLIMIT is
    'The Energy limit applying at the end of this dispatch interval in MWh. For GEN this is a lower energy limit. For LOAD this is an upper energy limit';

alter table BILLINGASRECOVERY add LOWERREG_ACE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.LOWERREG_ACE is
    'The Lower Regulation FCAS Residue Recovery Amount using ACE MWh values. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLINGASRECOVERY add RAISEREG_ACE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.RAISEREG_ACE is
    'The Raise Regulation FCAS Residue Recovery Amount using ACE MWh values. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLINGASRECOVERY add RAISE1SEC_ACE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.RAISE1SEC_ACE is
    'The Raise1Sec FCAS Recovery Amount for the Participant and Region from ACE MWh Portion. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLINGASRECOVERY add RAISE1SEC_ASOE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.RAISE1SEC_ASOE is
    'The Raise1Sec FCAS Recovery Amount for the Participant and Region from ASOE MWh Portion. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLINGASRECOVERY add LOWER1SEC_ACE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.LOWER1SEC_ACE is
    'The Lower1Sec FCAS Recovery Amount for the Participant and Region from ACE MWh Portion. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLINGASRECOVERY add LOWER1SEC_ASOE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.LOWER1SEC_ASOE is
    'The Lower1Sec FCAS Recovery Amount for the Participant and Region from ASOE MWh Portion. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLINGASRECOVERY add RAISE6SEC_ACE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.RAISE6SEC_ACE is
    'The Raise6Sec FCAS Recovery Amount for the Participant and Region from ACE MWh Portion. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLINGASRECOVERY add RAISE6SEC_ASOE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.RAISE6SEC_ASOE is
    'The Raise6Sec FCAS Recovery Amount for the Participant and Region from ASOE MWh Portion. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLINGASRECOVERY add LOWER6SEC_ACE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.LOWER6SEC_ACE is
    'The Lower6Sec FCAS Recovery Amount for the Participant and Region from ACE MWh Portion. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLINGASRECOVERY add LOWER6SEC_ASOE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.LOWER6SEC_ASOE is
    'The Lower6Sec FCAS Recovery Amount for the Participant and Region from ASOE MWh Portion. NULL for Billing Week prior to the IESS rule effective date value.';

alter table BILLINGASRECOVERY add RAISE60SEC_ACE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.RAISE60SEC_ACE is
    'The Raise60Sec FCAS Recovery Amount for the Participant and Region from ACE MWh Portion. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLINGASRECOVERY add RAISE60SEC_ASOE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.RAISE60SEC_ASOE is
    'The Raise60Sec FCAS Recovery Amount for the Participant and Region from ASOE MWh Portion. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLINGASRECOVERY add LOWER60SEC_ACE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.LOWER60SEC_ACE is
    'The Lower60Sec FCAS Recovery Amount for the Participant and Region from ACE MWh Portion. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLINGASRECOVERY add LOWER60SEC_ASOE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.LOWER60SEC_ASOE is
    'The Lower60Sec FCAS Recovery Amount for the Participant and Region from ASOE MWh Portion. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLINGASRECOVERY add RAISE5MIN_ACE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.RAISE5MIN_ACE is
    'The Raise5Min FCAS Recovery Amount for the Participant and Region from ACE MWh Portion. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLINGASRECOVERY add RAISE5MIN_ASOE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.RAISE5MIN_ASOE is
    'The Raise5Min FCAS Recovery Amount for the Participant and Region from ASOE MWh Portion. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLINGASRECOVERY add LOWER5MIN_ACE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.LOWER5MIN_ACE is
    'The Lower5Min FCAS Recovery Amount for the Participant and Region from ACE MWh Portion. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLINGASRECOVERY add LOWER5MIN_ASOE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.LOWER5MIN_ASOE is
    'The Lower5Min FCAS Recovery Amount for the Participant and Region from ASOE MWh Portion. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLINGASRECOVERY add REACTIVEPOWER_ACE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.REACTIVEPOWER_ACE is
    'The Reactive Power Ancillary Service Recovery Amount for for the Participant and Region from ACE MWh Portion. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLINGASRECOVERY add REACTIVEPOWER_ASOE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.REACTIVEPOWER_ASOE is
    'The Reactive Power Ancillary Service Recovery Amount for for the Participant and Region from ASOE MWh Portion. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLINGASRECOVERY add LOADSHED_ACE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.LOADSHED_ACE is
    'The Load Shed Ancillary Service Recovery Amount for for the Participant and Region from ACE MWh Portion. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLINGASRECOVERY add LOADSHED_ASOE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.LOADSHED_ASOE is
    'The Load Shed Ancillary Service Recovery Amount for for the Participant and Region from ASOE MWh Portion. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLINGASRECOVERY add SYSTEMRESTART_ACE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.SYSTEMRESTART_ACE is
    'The System Restart Ancillary Service Recovery Amount for for the Participant and Region from ACE MWh Portion. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLINGASRECOVERY add SYSTEMRESTART_ASOE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.SYSTEMRESTART_ASOE is
    'The System Restart Ancillary Service Recovery Amount for for the Participant and Region from ASOE MWh Portion. NULL for Billing Week prior to the IESS rule effective date,';

alter table BILLINGASRECOVERY add AVAILABILITY_REACTIVE_ACE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.AVAILABILITY_REACTIVE_ACE is
    'The Reactive Power Ancillary Service Availability Payment Recovery Amount for the Participant and Region from ACE MWh Portion. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLINGASRECOVERY add AVAILABILITY_REACTIVE_ASOE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.AVAILABILITY_REACTIVE_ASOE is
    'The Reactive Power Ancillary Service Availability Payment Recovery Amount for the Participant and Region from ASOE MWh Portion. For Pre-IESS Settlement dates this column will have NULL value. For Pre-IESS Settlement dates this column will have NULL value.';

alter table BILLINGASRECOVERY add AVAILABILITY_REACTIVE_RBT_ACE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.AVAILABILITY_REACTIVE_RBT_ACE is
    'The Reactive Power Ancillary Service Availability Rebate Payment Recovery Amount for the Participant and Region from ACE MWh Portion. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLINGASRECOVERY add AVAILABILITY_REACTIVE_RBT_ASOE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.AVAILABILITY_REACTIVE_RBT_ASOE is
    'The Reactive Power Ancillary Service Availability Rebate Payment Recovery Amount for the Participant and Region from ASOE MWh Portion. NULL for Billing Week prior to the IESS rule effective date';

comment on column BILLINGASRECOVERY.RAISE6SEC is
    'Raise 6 Sec Recovery. NULL for Billing Week post the IESS rule effective date';

comment on column BILLINGASRECOVERY.LOWER6SEC is
    'Lower 6 Sec Recovery. NULL for Billing Week post the IESS rule effective date';

comment on column BILLINGASRECOVERY.RAISE60SEC is
    'Raise 60 Sec Recovery. NULL for Billing Week post the IESS rule effective date';

comment on column BILLINGASRECOVERY.LOWER60SEC is
    'Lower 60 Sec Recovery. NULL for Billing Week post the IESS rule effective date';

comment on column BILLINGASRECOVERY.LOADSHED is
    'Load Shed Recovery. Post-IESS the value in this column only represent the Testing Payment Recovery from Customers. 0 if no testing payment exists.';

comment on column BILLINGASRECOVERY.REACTIVEPOWER is
    'Reactive Power Recovery. Post-IESS the value in this column only represent the Testing Payment Recovery from Customers. 0 if no testing payment exists.';

comment on column BILLINGASRECOVERY.SYSTEMRESTART is
    'System Restart Recovery. Post-IESS the value in this column only represent the Testing Payment Recovery from Customers. 0 if no testing payment exists';

comment on column BILLINGASRECOVERY.RAISE6SEC_GEN is
    'Raise 6 Sec Recovery for Generator. NULL for Billing Week post the IESS rule effective date';

comment on column BILLINGASRECOVERY.LOWER6SEC_GEN is
    'Lower 6 Sec Recovery for Generator. NULL for Billing Week post the IESS rule effective date';

comment on column BILLINGASRECOVERY.RAISE60SEC_GEN is
    'Raise 60 Sec Recovery for Generator. NULL for Billing Week post the IESS rule effective date';

comment on column BILLINGASRECOVERY.LOWER60SEC_GEN is
    'Lower 60 Sec Recovery for Generator. NULL for Billing Week post the IESS rule effective date';

comment on column BILLINGASRECOVERY.LOADSHED_GEN is
    'Load Shed Recovery for Generator. Post-IESS the value in this column only represent the Testing Payment Recovery from Generators. 0 if no testing payment exists.';

comment on column BILLINGASRECOVERY.REACTIVEPOWER_GEN is
    'Reactive Power Recovery for Generator. Post-IESS the value in this column only represent the Testing Payment Recovery from Generators. 0 if no testing payment exists.';

comment on column BILLINGASRECOVERY.SYSTEMRESTART_GEN is
    'System Restart Recovery for Generator. Post-IESS the value in this column only represent the Testing Payment Recovery from Generators. 0 if no testing payment exists.';

comment on column BILLINGASRECOVERY.LOWER5MIN is
    'Recovery amount for the Lower 5 Minute service attributable to customer connection points. NULL for Billing Week post the IESS rule effective date';

comment on column BILLINGASRECOVERY.RAISE5MIN is
    'Recovery amount for the Raise 5 Minute service attributable to customer connection points. NULL for Billing Week post the IESS rule effective date';

comment on column BILLINGASRECOVERY.LOWERREG is
    'Pre-IESS - Recovery amount for the Lower Regulation service attributable to customer connection points(MPF + Residue). Post-IESS the amount in this column represent only the Lower Regulation FCAS MPF Recovery Amount from Customer and Generator Connection Point MPFs, no Residue Amounts are added to this column value.';

ALTER TABLE billingasrecovery ALTER COLUMN lowerreg TYPE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.RAISEREG is
    'Pre-IESS - Recovery amount for the Raise Regulation service attributable to customer connection points(MPF + Residue). Post-IESS the amount in this column represent only the Raise Regulation FCAS MPF Recovery Amount from Customer and Generator Connection Point MPFs, no Residue Amounts are added to this column value.';

ALTER TABLE BILLINGASRECOVERY ALTER COLUMN RAISEREG TYPE NUMERIC(18,8);

comment on column BILLINGASRECOVERY.LOWER5MIN_GEN is
    'Recovery amount for the Lower 5 Minute service attributable to generator connection points. NULL for Billing Week post the IESS rule effective date';

comment on column BILLINGASRECOVERY.RAISE5MIN_GEN is
    'Recovery amount for the Raise 5 Minute service attributable to generator connection points. NULL for Billing Week post the IESS rule effective date';

comment on column BILLINGASRECOVERY.LOWERREG_GEN is
    'Recovery amount for the Lower Regulation service attributable to generator connection points. NULL for Billing Week post the IESS rule effective date';

comment on column BILLINGASRECOVERY.RAISEREG_GEN is
    'Recovery amount for the Raise Regulation service attributable to generator connection points. NULL for Billing Week post the IESS rule effective date. NULL for Billing Week post the IESS rule effective date.';

comment on column BILLINGASRECOVERY.AVAILABILITY_REACTIVE is
    'The total availability payment recovery amount (customer).. NULL for Billing Week post the IESS rule effective date';

comment on column BILLINGASRECOVERY.AVAILABILITY_REACTIVE_RBT is
    'The total availability payment rebate recovery amount (customer).. NULL for Billing Week post the IESS rule effective date';

comment on column BILLINGASRECOVERY.AVAILABILITY_REACTIVE_GEN is
    'The total availability payment recovery amount (Generator).. NULL for Billing Week post the IESS rule effective date';

comment on column BILLINGASRECOVERY.AVAILABILITY_REACTIVE_RBT_GEN is
    'The total availability payment rebate recovery amount (Generator).. NULL for Billing Week post the IESS rule effective date';

comment on column BILLINGASRECOVERY.RAISE1SEC is
    'Customer recovery amount for the very fast raise service. NULL for Billing Week post the IESS rule effective date';

comment on column BILLINGASRECOVERY.LOWER1SEC is
    'Customer recovery amount for the very fast lower service. NULL for Billing Week post the IESS rule effective date';

comment on column BILLINGASRECOVERY.RAISE1SEC_GEN is
    'Generator recovery amount for the very fast raise service. NULL for Billing Week post the IESS rule effective date';

comment on column BILLINGASRECOVERY.LOWER1SEC_GEN is
    'Generator recovery amount for the very fast lower service. NULL for Billing Week post the IESS rule effective date';

alter table BILLING_APC_RECOVERY add PARTICIPANT_ACE_MWH NUMERIC(18,8);

comment on column BILLING_APC_RECOVERY.PARTICIPANT_ACE_MWH is
    'The ACE MWh value of the participant from the Eligibility Interval used for the APC Recovery Calculation. If the Billing Week is prior to the IESS rule effective date, then value is Null.';

alter table BILLING_APC_RECOVERY add REGION_ACE_MWH NUMERIC(18,8);

comment on column BILLING_APC_RECOVERY.REGION_ACE_MWH is
    'The ACE MWh value of the Region from the Eligibility Interval used for the APC Recovery Calculation. This is the sum of the ACE MWh of all the participants in that recovery. If the Billing Week is prior to the IESS rule effective date, then value is Null.';

alter table BILLING_DAILY_ENERGY_SUMMARY add ACE_MWH NUMERIC(18,8);

comment on column BILLING_DAILY_ENERGY_SUMMARY.ACE_MWH is
    'The Sum of ACE MWh value for the Participant and region for the Settlement Date. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLING_DAILY_ENERGY_SUMMARY add ASOE_MWH NUMERIC(18,8);

comment on column BILLING_DAILY_ENERGY_SUMMARY.ASOE_MWH is
    'The Sum of ASOE MWh value for the Participant and region for the Settlement Date. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLING_DAILY_ENERGY_SUMMARY add ACE_AMOUNT NUMERIC(18,8);

comment on column BILLING_DAILY_ENERGY_SUMMARY.ACE_AMOUNT is
    'The Sum of ACE Amount for the Participant and region for the Settlement Date. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLING_DAILY_ENERGY_SUMMARY add ASOE_AMOUNT NUMERIC(18,8);

comment on column BILLING_DAILY_ENERGY_SUMMARY.ASOE_AMOUNT is
    'The Sum of ASOE Amount for the Participant and region for the Settlement Date. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLING_DAILY_ENERGY_SUMMARY add CE_MWH NUMERIC(18,8);

comment on column BILLING_DAILY_ENERGY_SUMMARY.CE_MWH is
    'The Sum of CE MWh value for the Participant and region for the Settlement Date. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLING_DAILY_ENERGY_SUMMARY add UFEA_MWH NUMERIC(18,8);

comment on column BILLING_DAILY_ENERGY_SUMMARY.UFEA_MWH is
    'The Sum of UFEA MWh value for the Participant and region for the Settlement Date. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLING_DAILY_ENERGY_SUMMARY add TOTAL_MWH NUMERIC(18,8);

comment on column BILLING_DAILY_ENERGY_SUMMARY.TOTAL_MWH is
    'The Sum of Total MWh value for the Participant and region for the Settlement Date. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLING_DAILY_ENERGY_SUMMARY add TOTAL_AMOUNT NUMERIC(18,8);

comment on column BILLING_DAILY_ENERGY_SUMMARY.TOTAL_AMOUNT is
    'The Sum of Total Amount for the Participant and region for the Settlement Date. NULL for Billing Week prior to the IESS rule effective date';

comment on column BILLING_DAILY_ENERGY_SUMMARY.CUSTOMER_ENERGY_PURCHASED is
    'Customer energy amount purchased on this settlement day by the participant in the region. NULL for Billing Week post the IESS rule effective date.';

comment on column BILLING_DAILY_ENERGY_SUMMARY.GENERATOR_ENERGY_SOLD is
    'Generator energy amount sold on this settlement day by the participant in the region. NULL for Billing Week post the IESS rule effective date.';

comment on column BILLING_DAILY_ENERGY_SUMMARY.GENERATOR_ENERGY_PURCHASED is
    'Generator energy amount purchased on this settlement day by the participant in the region. NULL for Billing Week post the IESS rule effective date.';

alter table BILLING_DIRECTION_RECON_OTHER add REGION_ACE_MWH NUMERIC(18,8);

comment on column BILLING_DIRECTION_RECON_OTHER.REGION_ACE_MWH is
    'The Sum of ACE MWh value for the Region over the duration of the direction. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLING_DIRECTION_RECON_OTHER add REGION_ASOE_MWH NUMERIC(18,8);

comment on column BILLING_DIRECTION_RECON_OTHER.REGION_ASOE_MWH is
    'The Sum of ASOE MWh value for the Region over the duration of the direction. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLING_DIRECTION_RECON_OTHER add DIRECTION_SERVICE_ID VARCHAR(20);

comment on column BILLING_DIRECTION_RECON_OTHER.DIRECTION_SERVICE_ID is
    'The Direction Service ID associated with the Direction Type ID. Eg For FCAS Direction Type, Direction Service could be any contingency service.';

comment on column BILLING_DIRECTION_RECON_OTHER.REGIONAL_CUSTOMER_ENERGY is
    'The total customer energy for this region, over the duration of the direction. NULL for Billing Week post the IESS rule effective date.';

comment on column BILLING_DIRECTION_RECON_OTHER.REGIONAL_GENERATOR_ENERGY is
    'The total generator energy for this region, over the duration of the direction. NULL for Billing Week post the IESS rule effective date.';

/*==============================================================*/
/* Table: BILLING_ENERGY_GENSET_DETAIL                          */
/*==============================================================*/
create table BILLING_ENERGY_GENSET_DETAIL (
                                              CONTRACTYEAR         NUMERIC(4,0)           not null,
                                              WEEKNO               NUMERIC(3,0)           not null,
                                              BILLRUNNO            NUMERIC(4,0)           not null,
                                              PARTICIPANTID        VARCHAR(20)          not null,
                                              STATIONID            VARCHAR(20)          not null,
                                              DUID                 VARCHAR(20)          not null,
                                              GENSETID             VARCHAR(20)          not null,
                                              REGIONID             VARCHAR(20)          not null,
                                              CONNECTIONPOINTID    VARCHAR(20)          not null,
                                              METERID              VARCHAR(20)          not null,
                                              CE_MWH               NUMERIC(18,8),
                                              UFEA_MWH             NUMERIC(18,8),
                                              ACE_MWH              NUMERIC(18,8),
                                              ASOE_MWH             NUMERIC(18,8),
                                              TOTAL_MWH            NUMERIC(18,8),
                                              DME_MWH              NUMERIC(18,8),
                                              ACE_AMOUNT           NUMERIC(18,8),
                                              ASOE_AMOUNT          NUMERIC(18,8),
                                              TOTAL_AMOUNT         NUMERIC(18,8),
                                              LASTCHANGED          DATE
);

comment on table BILLING_ENERGY_GENSET_DETAIL is
    'The Billing Energy Genset report contains the Genset Energy detail summary for the Billing Week data';

comment on column BILLING_ENERGY_GENSET_DETAIL.CONTRACTYEAR is
    'The Billing Contract Year';

comment on column BILLING_ENERGY_GENSET_DETAIL.WEEKNO is
    'The Billing Week No';

comment on column BILLING_ENERGY_GENSET_DETAIL.BILLRUNNO is
    'The Billing Run No';

comment on column BILLING_ENERGY_GENSET_DETAIL.PARTICIPANTID is
    'The Participant Id Identifier';

comment on column BILLING_ENERGY_GENSET_DETAIL.STATIONID is
    'The StationId identifier associated with the GensetId';

comment on column BILLING_ENERGY_GENSET_DETAIL.DUID is
    'The DUID for the meter associated with the GensetId';

comment on column BILLING_ENERGY_GENSET_DETAIL.GENSETID is
    'The GensetId for the Meter Id received';

comment on column BILLING_ENERGY_GENSET_DETAIL.REGIONID is
    'The Region Id for the Connection Point associated with the DUID';

comment on column BILLING_ENERGY_GENSET_DETAIL.CONNECTIONPOINTID is
    'The Connection Point associated with the DUID';

comment on column BILLING_ENERGY_GENSET_DETAIL.METERID is
    'The Meter ID Identifier (NMI)';

comment on column BILLING_ENERGY_GENSET_DETAIL.CE_MWH is
    'The Consumed Energy for the Meter Id . Energy received in the meter reads (DLF Adjusted) in that Billing Week';

comment on column BILLING_ENERGY_GENSET_DETAIL.UFEA_MWH is
    'The UFEA Energy MWh Consumed for that Connection Point for the Participant Id in that Billing Week';

comment on column BILLING_ENERGY_GENSET_DETAIL.ACE_MWH is
    'The Adjusted Consumed Energy MWh Consumed for that Connection Point for the Participant Id in that Billing Week';

comment on column BILLING_ENERGY_GENSET_DETAIL.ASOE_MWH is
    'The Adjusted Sent Out Energy MWh Consumed for that Connection Point for the Participant Id in that Billing Week';

comment on column BILLING_ENERGY_GENSET_DETAIL.TOTAL_MWH is
    'The Total MWh(ACE_MWh + ASOE_MWh) for that Connection Point for the Participant Id in that Billing Week';

comment on column BILLING_ENERGY_GENSET_DETAIL.DME_MWH is
    'The DME MWh for that Connection Point for the Participant Id in that Billing Week. This is the MWh value that is used for the UFEA Allocation';

comment on column BILLING_ENERGY_GENSET_DETAIL.ACE_AMOUNT is
    'The Adjusted Consumed Energy Dollar Amount for that Connection Point for the Participant Id in that Billing Week';

comment on column BILLING_ENERGY_GENSET_DETAIL.ASOE_AMOUNT is
    'The Adjusted Sent Out Energy Dollar Amount for that Connection Point for the Participant Id in that Billing Week';

comment on column BILLING_ENERGY_GENSET_DETAIL.TOTAL_AMOUNT is
    'The Total Amount(ACE_Amount + ASOE_Amount) for that Connection Point for the Participant Id in that Billing Week';

comment on column BILLING_ENERGY_GENSET_DETAIL.LASTCHANGED is
    'The Last changed date time for the record';

ALTER TABLE billing_energy_genset_detail
    ADD CONSTRAINT bill_energy_genset_detail_pk PRIMARY KEY (contractyear, weekno, billrunno, participantid, stationid, duid, gensetid, regionid, connectionpointid, meterid);

/*==============================================================*/
/* Table: BILLING_ENERGY_TRANSACTIONS                           */
/*==============================================================*/
create table BILLING_ENERGY_TRANSACTIONS (
                                             CONTRACTYEAR         NUMERIC(4,0)           not null,
                                             WEEKNO               NUMERIC(3,0)           not null,
                                             BILLRUNNO            NUMERIC(4,0)           not null,
                                             PARTICIPANTID        VARCHAR(20)          not null,
                                             CONNECTIONPOINTID    VARCHAR(20)          not null,
                                             REGIONID             VARCHAR(20)          not null,
                                             CE_MWH               NUMERIC(18,8),
                                             UFEA_MWH             NUMERIC(18,8),
                                             ACE_MWH              NUMERIC(18,8),
                                             ASOE_MWH             NUMERIC(18,8),
                                             ACE_AMOUNT           NUMERIC(18,8),
                                             ASOE_AMOUNT          NUMERIC(18,8),
                                             TOTAL_MWH            NUMERIC(18,8),
                                             TOTAL_AMOUNT         NUMERIC(18,8),
                                             DME_MWH              NUMERIC(18,8),
                                             LASTCHANGED          DATE
);

comment on table BILLING_ENERGY_TRANSACTIONS is
    'The Billing Energy Transactions is the summary of the Settlement Energy Transactions that has the ACE and ASOE MWh and Dollar values that is used for the Statement';

comment on column BILLING_ENERGY_TRANSACTIONS.CONTRACTYEAR is
    'The Billing Contract Year';

comment on column BILLING_ENERGY_TRANSACTIONS.WEEKNO is
    'The Billing WeekNo';

comment on column BILLING_ENERGY_TRANSACTIONS.BILLRUNNO is
    'The Billing RunNo';

comment on column BILLING_ENERGY_TRANSACTIONS.PARTICIPANTID is
    'The Participant Id Identifier';

comment on column BILLING_ENERGY_TRANSACTIONS.CONNECTIONPOINTID is
    'The ConnectionPoint Id for the Billing Aggregation for the Participant Id.';

comment on column BILLING_ENERGY_TRANSACTIONS.REGIONID is
    'The Region Id Identifier';

comment on column BILLING_ENERGY_TRANSACTIONS.CE_MWH is
    'The Consumed Energy MWh Consumed for that Connection Point for the Participant Id in that Billing Week';

comment on column BILLING_ENERGY_TRANSACTIONS.UFEA_MWH is
    'The UFEA Energy MWh Consumed for that Connection Point for the Participant Id in that Billing Week';

comment on column BILLING_ENERGY_TRANSACTIONS.ACE_MWH is
    'The Adjusted Consumed Energy MWh Consumed for that Connection Point for the Participant Id in that Billing Week';

comment on column BILLING_ENERGY_TRANSACTIONS.ASOE_MWH is
    'The Adjusted Sent Out Energy MWh Consumed for that Connection Point for the Participant Id in that Billing Week';

comment on column BILLING_ENERGY_TRANSACTIONS.ACE_AMOUNT is
    'The Adjusted Consumed Energy Dollar Amount for that Connection Point for the Participant Id in that Billing Week';

comment on column BILLING_ENERGY_TRANSACTIONS.ASOE_AMOUNT is
    'The Adjusted Sent Out Energy Dollar Amount for that Connection Point for the Participant Id in that Billing Week';

comment on column BILLING_ENERGY_TRANSACTIONS.TOTAL_MWH is
    'The Total MWh(ACE_MWh + ASOE_MWh) for that Connection Point for the Participant Id in that Billing Week';

comment on column BILLING_ENERGY_TRANSACTIONS.TOTAL_AMOUNT is
    'The Total Amount(ACE_Amount + ASOE_Amount) for that Connection Point for the Participant Id in that Billing Week';

comment on column BILLING_ENERGY_TRANSACTIONS.DME_MWH is
    'The DME MWh for that Connection Point for the Participant Id in that Billing Week. This is the MWh value that is used for the UFEA Allocation.';

comment on column BILLING_ENERGY_TRANSACTIONS.LASTCHANGED is
    'The Last Changed date time for the record';

ALTER TABLE billing_energy_transactions
    ADD CONSTRAINT billing_energy_transactions_pk PRIMARY KEY (contractyear, weekno, billrunno, participantid, connectionpointid, regionid);

alter table BILLING_NMAS_TST_RECOVERY add PARTICIPANT_ACE_MWH NUMERIC(18,8);

comment on column BILLING_NMAS_TST_RECOVERY.PARTICIPANT_ACE_MWH is
    'The Participant ACE MWh Value used in the Recovery of the Testing Payment Amount if the service is recovered from ACE. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLING_NMAS_TST_RECOVERY add REGION_ACE_MWH NUMERIC(18,8);

comment on column BILLING_NMAS_TST_RECOVERY.REGION_ACE_MWH is
    'The Region ACE MWh Value used in the Recovery of the Testing Payment Amount if the service is recovered from ACE. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLING_NMAS_TST_RECOVERY add ACE_PORTION NUMERIC(18,8);

comment on column BILLING_NMAS_TST_RECOVERY.ACE_PORTION is
    'The Portion of ACE MWh Value used in the Recovery Calculation. . NULL for Billing Week prior to the IESS rule effective date';

alter table BILLING_NMAS_TST_RECOVERY add ASOE_PORTION NUMERIC(18,8);

comment on column BILLING_NMAS_TST_RECOVERY.ASOE_PORTION is
    'The Portion of ASOE MWh Value used in the Recovery Calculation (100 - ACE_Portion). . NULL for Billing Week prior to the IESS rule effective date';

alter table BILLING_NMAS_TST_RECOVERY add PARTICIPANT_ASOE_MWH NUMERIC(18,8);

comment on column BILLING_NMAS_TST_RECOVERY.PARTICIPANT_ASOE_MWH is
    'The Participant ASOE MWh Value used in the Recovery of the Testing Payment Amount if the service is recovered from ASOE. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLING_NMAS_TST_RECOVERY add REGION_ASOE_MWH NUMERIC(18,8);

comment on column BILLING_NMAS_TST_RECOVERY.REGION_ASOE_MWH is
    'The Region ASOE MWh Value used in the Recovery of the Testing Payment Amount if the service is recovered from ASOE. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLING_NMAS_TST_RECOVERY add RECOVERYAMOUNT_ACE NUMERIC(18,8);

comment on column BILLING_NMAS_TST_RECOVERY.RECOVERYAMOUNT_ACE is
    'The Participant Recovery Amount based on ACE MWh Value if the service is recovered from ACE . NULL for Billing Week prior to the IESS rule effective date';

alter table BILLING_NMAS_TST_RECOVERY add RECOVERYAMOUNT_ASOE NUMERIC(18,8);

comment on column BILLING_NMAS_TST_RECOVERY.RECOVERYAMOUNT_ASOE is
    'The Participant Recovery Amount based on ASOE MWh Value if the service is recovered from ASOE . NULL for Billing Week prior to the IESS rule effective date';

comment on column BILLING_NMAS_TST_RECOVERY.RECOVERY_AMOUNT is
    'The Total recovery amount for the billing week, being the sum of the customer and generator proportions for the PARTICIPANTID in REGIONID and sum of RecoveryAmount_ACE and RecoveryAmount_ASOE.';

alter table BILLRESERVETRADERRECOVERY add PARTICIPANT_ACE_MWH NUMERIC(18,8);

comment on column BILLRESERVETRADERRECOVERY.PARTICIPANT_ACE_MWH is
    'The Participant ACE MWh Value used in the Recovery of the RERT Amount. NULL for Billing Week prior to the IESS rule effective date';

alter table BILLRESERVETRADERRECOVERY add REGION_ACE_MWH NUMERIC(18,8);

comment on column BILLRESERVETRADERRECOVERY.REGION_ACE_MWH is
    'The Region ACE MWh Value used in the Recovery of the RERT Amount. NULL for Billing Week prior to the IESS rule effective date';

comment on column BILLRESERVETRADERRECOVERY.PARTICIPANT_DEMAND is
    'Participant Demand Value used for RERT Recovery. NULL for Billing Week post the IESS rule effective date.';

comment on column BILLRESERVETRADERRECOVERY.REGION_DEMAND is
    'Region Demand Value used for RERT Recovery. NULL for Billing Week post the IESS rule effective date.';

comment on column DISPATCHABLEUNIT.UNITTYPE is
    'Identifies LOAD, GENERATOR or BIDIRECTIONAL';

alter table DISPATCHLOAD add INITIAL_ENERGY_STORAGE NUMERIC(15,5);

comment on column DISPATCHLOAD.INITIAL_ENERGY_STORAGE is
    'BDU only. The energy storage at the start of this dispatch interval (MWh)';

alter table DISPATCHLOAD add ENERGY_STORAGE NUMERIC(15,5);

comment on column DISPATCHLOAD.ENERGY_STORAGE is
    'BDU only. The projected energy storage based on cleared energy and regulation FCAS dispatch (MWh)';

alter table DISPATCHLOAD add MIN_AVAILABILITY NUMERIC(15,5);

comment on column DISPATCHLOAD.MIN_AVAILABILITY is
    'BDU only. Load side availability (BidOfferPeriod.MAXAVAIL where DIRECTION = LOAD)';

comment on column DISPATCHLOAD.INITIALMW is
    'Initial MW at start of period. Negative values when Bi-directional Unit start from importing power, otherwise positive.';

comment on column DISPATCHLOAD.TOTALCLEARED is
    'Target MW for end of period. Negative values when Bi-directional Unit is importing power, otherwise positive.';

alter table DISPATCHREGIONSUM add BDU_ENERGY_STORAGE NUMERIC(15,5);

comment on column DISPATCHREGIONSUM.BDU_ENERGY_STORAGE is
    'Regional aggregated energy storage where the DUID type is BDU (MWh)';

alter table DISPATCHREGIONSUM add BDU_MIN_AVAIL NUMERIC(15,5);

comment on column DISPATCHREGIONSUM.BDU_MIN_AVAIL is
    'Total available load side BDU summated for region (MW)';

alter table DISPATCHREGIONSUM add BDU_MAX_AVAIL NUMERIC(15,5);

comment on column DISPATCHREGIONSUM.BDU_MAX_AVAIL is
    'Total available generation side BDU summated for region (MW)';

alter table DISPATCHREGIONSUM add BDU_CLEAREDMW_GEN NUMERIC(15,5);

comment on column DISPATCHREGIONSUM.BDU_CLEAREDMW_GEN is
    'Regional aggregated cleared MW where the DUID type is BDU. Net of export (Generation)';

alter table DISPATCHREGIONSUM add BDU_CLEAREDMW_LOAD NUMERIC(15,5);

comment on column DISPATCHREGIONSUM.BDU_CLEAREDMW_LOAD is
    'Regional aggregated cleared MW where the DUID type is BDU. Net of import (Load)';

alter table DUDETAIL add MINCAPACITY NUMERIC(6,0);

comment on column DUDETAIL.MINCAPACITY is
    'Minimum capacity only for load side of BDU, otherwise 0 (MW)';

alter table DUDETAIL add REGISTEREDMINCAPACITY NUMERIC(6,0);

comment on column DUDETAIL.REGISTEREDMINCAPACITY is
    'Registered minimum capacity only for load side of BDU, otherwise 0 (MW)';

alter table DUDETAIL add MAXRATEOFCHANGEUP_LOAD NUMERIC(6,0);

comment on column DUDETAIL.MAXRATEOFCHANGEUP_LOAD is
    'Raise Ramp rate applied to BDU Load component (MW/min)';

alter table DUDETAIL add MAXRATEOFCHANGEDOWN_LOAD NUMERIC(6,0);

comment on column DUDETAIL.MAXRATEOFCHANGEDOWN_LOAD is
    'Lower Ramp rate applied to BDU Load component (MW/min)';

alter table DUDETAIL add MAXSTORAGECAPACITY NUMERIC(15,5);

comment on column DUDETAIL.MAXSTORAGECAPACITY is
    'The rated storage capacity (MWh), information only';

alter table DUDETAIL add STORAGEIMPORTEFFICIENCYFACTOR NUMERIC(15,5);

comment on column DUDETAIL.STORAGEIMPORTEFFICIENCYFACTOR is
    'The storage energy import conversion efficiency. Number from 0 to 1 where 1 is lossless. Calculated as (increase in stored energy / increase in imported energy)';

alter table DUDETAIL add STORAGEEXPORTEFFICIENCYFACTOR NUMERIC(15,5);

comment on column DUDETAIL.STORAGEEXPORTEFFICIENCYFACTOR is
    'The storage energy export conversion efficiency. Number from 0 to 1 where 1 is lossless. Calculated as (decrease in exported energy / decrease in stored energy)';

alter table DUDETAIL add MIN_RAMP_RATE_UP NUMERIC(6,0);

comment on column DUDETAIL.MIN_RAMP_RATE_UP is
    'Calculated Minimum Ramp Rate Up value accepted for Energy Offers or Bids with explanation for energy imports (all DUID types and BDU Generation side) (MW/min)';

alter table DUDETAIL add MIN_RAMP_RATE_DOWN NUMERIC(6,0);

comment on column DUDETAIL.MIN_RAMP_RATE_DOWN is
    'Calculated Minimum Ramp Rate Down value accepted for Energy Offers or Bids with explanation for energy imports (all DUID types and BDU Generation side) (MW/min)';

alter table DUDETAIL add LOAD_MIN_RAMP_RATE_UP NUMERIC(6,0);

comment on column DUDETAIL.LOAD_MIN_RAMP_RATE_UP is
    'Calculated Minimum Ramp Rate Up value accepted for Energy Offers or Bids on BDU Load component with explanation for energy imports (MW/min)';

alter table DUDETAIL add LOAD_MIN_RAMP_RATE_DOWN NUMERIC(6,0);

comment on column DUDETAIL.LOAD_MIN_RAMP_RATE_DOWN is
    'Calculated Minimum Ramp Rate Down value accepted for Energy Offers or Bids on BDU Load component with explanation for energy imports (MW/min)';

comment on column DUDETAIL.DISPATCHTYPE is
    'Identifies LOAD, GENERATOR or BIDIRECTIONAL.';

alter table DUDETAILSUMMARY add LOAD_MINIMUM_ENERGY_PRICE NUMERIC(9,2);

comment on column DUDETAILSUMMARY.LOAD_MINIMUM_ENERGY_PRICE is
    'BDU only. Floored Offer/Bid Energy Price adjusted for TLF, DLF and MPF for energy imports';

alter table DUDETAILSUMMARY add LOAD_MAXIMUM_ENERGY_PRICE NUMERIC(9,2);

comment on column DUDETAILSUMMARY.LOAD_MAXIMUM_ENERGY_PRICE is
    'BDU only. Capped Offer/Bid Energy Price adjusted for TLF, DLF and VoLL for energy imports';

alter table DUDETAILSUMMARY add LOAD_MIN_RAMP_RATE_UP NUMERIC(6,0);

comment on column DUDETAILSUMMARY.LOAD_MIN_RAMP_RATE_UP is
    'BDU only. MW/Min. Calculated Minimum Ramp Rate Up value accepted for Energy Offers or Bids with explanation for energy imports';

alter table DUDETAILSUMMARY add LOAD_MIN_RAMP_RATE_DOWN NUMERIC(6,0);

comment on column DUDETAILSUMMARY.LOAD_MIN_RAMP_RATE_DOWN is
    'BDU only. MW/Min. Calculated Minimum Ramp Rate Down value accepted for Energy Offers or Bids with explanation for energy imports';

alter table DUDETAILSUMMARY add LOAD_MAX_RAMP_RATE_UP NUMERIC(6,0);

comment on column DUDETAILSUMMARY.LOAD_MAX_RAMP_RATE_UP is
    'BDU only. MW/Min. Registered Maximum Ramp Rate Up value accepted for Energy Offers or Bids for energy imports';

alter table DUDETAILSUMMARY add LOAD_MAX_RAMP_RATE_DOWN NUMERIC(6,0);

comment on column DUDETAILSUMMARY.LOAD_MAX_RAMP_RATE_DOWN is
    'BDU only. MW/Min. Registered Maximum Ramp Rate Down value accepted for Energy Offers or Bids for energy imports';

alter table DUDETAILSUMMARY add SECONDARY_TLF NUMERIC(18,8);

comment on column DUDETAILSUMMARY.SECONDARY_TLF is
    'Used in Bidding, Dispatch and Settlements, only populated where Dual TLFs apply. For Bidding and Dispatch, the TLF for the generation component of a BDU, when null the TRANSMISSIONLOSSFACTOR is used for both the load and generation components. For Settlements, the secondary TLF is applied to all energy (load and generation) when the Net Energy Flow of the ConnectionPointID in the interval is positive (net generation).';

comment on column DUDETAILSUMMARY.DISPATCHTYPE is
    'Identifies LOAD, GENERATOR or BIDIRECTIONAL. This will likely expand to more generic models as new technology types are integrated into the NEM';

comment on column DUDETAILSUMMARY.TRANSMISSIONLOSSFACTOR is
    'Used in Bidding, Dispatch and Settlements. For Bidding and Dispatch, where the DUID is a BDU with DISPATCHTYPE of BIDIRECTIONAL, the TLF for the load component of the BDU. For Settlements, where dual TLFs apply, the primary TLF is applied to all energy (load and generation) when the Net Energy Flow of the ConnectionPointID in the interval is negative (net load).';

comment on column DUDETAILSUMMARY.ADG_ID is
    'Aggregate Dispatch Group. Group into which the DUID is aggregated for Conformance. Null if DUID not aggregated for Conformance';

/*==============================================================*/
/* Table: FCAS_REGU_USAGE_FACTORS                               */
/*==============================================================*/
create table FCAS_REGU_USAGE_FACTORS (
                                         EFFECTIVEDATE        DATE                  not null,
                                         VERSIONNO            NUMERIC(3,0)           not null,
                                         REGIONID             VARCHAR(20)          not null,
                                         BIDTYPE              VARCHAR(20)          not null,
                                         PERIODID             NUMERIC(3,0)           not null,
                                         USAGE_FACTOR         NUMERIC(8,3),
                                         LASTCHANGED          DATE
);

comment on table FCAS_REGU_USAGE_FACTORS is
    'Stores the proportion of enabled regulation FCAS dispatch that is typically consumed for frequency regulation. Used to calculate the projected state of charge for energy storage systems.';

comment on column FCAS_REGU_USAGE_FACTORS.EFFECTIVEDATE is
    'The effective date for this regulation FCAS usage factor';

comment on column FCAS_REGU_USAGE_FACTORS.VERSIONNO is
    'Version with respect to effective date';

comment on column FCAS_REGU_USAGE_FACTORS.REGIONID is
    'Unique RegionID';

comment on column FCAS_REGU_USAGE_FACTORS.BIDTYPE is
    'The type of regulation FCAS service [RAISEREG,LOWERREG]';

comment on column FCAS_REGU_USAGE_FACTORS.PERIODID is
    'The Period ID (1 - 48) within the calendar day to which this usage factor applies';

comment on column FCAS_REGU_USAGE_FACTORS.USAGE_FACTOR is
    'The proportion of cleared regulation FCAS that is assumed to be used within a dispatch interval. Expressed as a fractional amount between 0 and 1';

comment on column FCAS_REGU_USAGE_FACTORS.LASTCHANGED is
    'The last time the data has been changed/updated';

ALTER TABLE fcas_regu_usage_factors
    ADD CONSTRAINT fcas_regu_usage_factors_pk PRIMARY KEY (effectivedate, versionno, regionid, bidtype, periodid);


/*==============================================================*/
/* Table: FCAS_REGU_USAGE_FACTORS_TRK                           */
/*==============================================================*/
create table FCAS_REGU_USAGE_FACTORS_TRK (
                                             EFFECTIVEDATE        DATE                  not null,
                                             VERSIONNO            NUMERIC(3,0)           not null,
                                             AUTHORISEDDATE       DATE,
                                             LASTCHANGED          DATE
);

comment on table FCAS_REGU_USAGE_FACTORS_TRK is
    'Stores the proportion of enabled regulation FCAS dispatch that is typically consumed for frequency regulation. Used to calculate the projected state of charge for energy storage systems.';

comment on column FCAS_REGU_USAGE_FACTORS_TRK.EFFECTIVEDATE is
    'The effective date for this regulation FCAS usage factor';

comment on column FCAS_REGU_USAGE_FACTORS_TRK.VERSIONNO is
    'Version of the date with respect to effective date';

comment on column FCAS_REGU_USAGE_FACTORS_TRK.AUTHORISEDDATE is
    'The date time that this set of usage factors was authorised';

comment on column FCAS_REGU_USAGE_FACTORS_TRK.LASTCHANGED is
    'The last time the data has been changed/updated';

ALTER TABLE fcas_regu_usage_factors_trk
    ADD CONSTRAINT fcas_regu_usage_factors_trk_pk PRIMARY KEY (effectivedate, versionno);

alter table GENUNITS add MINCAPACITY NUMERIC(6,0);

comment on column GENUNITS.MINCAPACITY is
    'Minimum capacity only for load side of BDU, otherwise 0 (MW)';

alter table GENUNITS add REGISTEREDMINCAPACITY NUMERIC(6,0);

comment on column GENUNITS.REGISTEREDMINCAPACITY is
    'Registered minimum capacity only for load side of BDU, otherwise 0 (MW)';

alter table GENUNITS add MAXSTORAGECAPACITY NUMERIC(15,5);

comment on column GENUNITS.MAXSTORAGECAPACITY is
    'The rated storage capacity (MWh), information only';

comment on column GENUNITS.DISPATCHTYPE is
    'Identifies LOAD, GENERATOR or BIDIRECTIONAL. This will likely expand to more generic models as new technology types are integrated into the NEM.';

alter table GENUNITS_UNIT add UNITMINSIZE NUMERIC(8,3);

comment on column GENUNITS_UNIT.UNITMINSIZE is
    'Only applicable for the LOAD side of BDU (MW)';

alter table GENUNITS_UNIT add MAXSTORAGECAPACITY NUMERIC(15,5);

comment on column GENUNITS_UNIT.MAXSTORAGECAPACITY is
    'The rated storage capacity (MWh), information only';

alter table GENUNITS_UNIT add REGISTEREDCAPACITY NUMERIC(8,3);

comment on column GENUNITS_UNIT.REGISTEREDCAPACITY is
    'Registered capacity for normal operations';

alter table GENUNITS_UNIT add REGISTEREDMINCAPACITY NUMERIC(8,3);

comment on column GENUNITS_UNIT.REGISTEREDMINCAPACITY is
    'Only applicable for the LOAD side of BDU (MW)';

alter table MARKETFEE add METER_TYPE VARCHAR(20);

comment on column MARKETFEE.METER_TYPE is
    'The Energy Type for the Market Fees Calculation. E.g of Meter Types are CUSTOMER, GENERATOR, NREG, BDU etc. If Meter Type is mentioned as ALL then all the Meter Types for that Participant Category will be used in the Fee calculation';

alter table MARKETFEE add METER_SUBTYPE VARCHAR(20);

comment on column MARKETFEE.METER_SUBTYPE is
    'The Meter Sub Type values are ACE, ASOE or ALL. ACE represent ACE_MWH value , ASOE represent ASOE_MWH value and ALL represent sum of ACE_MWh and ASOE_MWh';

alter table P5MIN_REGIONSOLUTION add BDU_ENERGY_STORAGE NUMERIC(15,5);

comment on column P5MIN_REGIONSOLUTION.BDU_ENERGY_STORAGE is
    'Regional aggregated energy storage where the DUID type is BDU (MWh)';

alter table P5MIN_REGIONSOLUTION add BDU_MIN_AVAIL NUMERIC(15,5);

comment on column P5MIN_REGIONSOLUTION.BDU_MIN_AVAIL is
    'Total available load side BDU summated for region (MW)';

alter table P5MIN_REGIONSOLUTION add BDU_MAX_AVAIL NUMERIC(15,5);

comment on column P5MIN_REGIONSOLUTION.BDU_MAX_AVAIL is
    'Total available generation side BDU summated for region (MW)';

alter table P5MIN_REGIONSOLUTION add BDU_CLEAREDMW_GEN NUMERIC(15,5);

comment on column P5MIN_REGIONSOLUTION.BDU_CLEAREDMW_GEN is
    'Regional aggregated cleared MW where the DUID type is BDU. Net of export (Generation)';

alter table P5MIN_REGIONSOLUTION add BDU_CLEAREDMW_LOAD NUMERIC(15,5);

comment on column P5MIN_REGIONSOLUTION.BDU_CLEAREDMW_LOAD is
    'Regional aggregated cleared MW where the DUID type is BDU. Net of import (Load)';

alter table P5MIN_UNITSOLUTION add INITIAL_ENERGY_STORAGE NUMERIC(15,5);

comment on column P5MIN_UNITSOLUTION.INITIAL_ENERGY_STORAGE is
    'BDU only. The energy storage at the start of this dispatch interval (MWh)';

alter table P5MIN_UNITSOLUTION add ENERGY_STORAGE NUMERIC(15,5);

comment on column P5MIN_UNITSOLUTION.ENERGY_STORAGE is
    'BDU only. The projected energy storage based on cleared energy and regulation FCAS dispatch (MWh)';

alter table P5MIN_UNITSOLUTION add ENERGY_STORAGE_MIN NUMERIC(15,5);

comment on column P5MIN_UNITSOLUTION.ENERGY_STORAGE_MIN is
    'BDU only - Minimum Energy Storage constraint limit (MWh)';

alter table P5MIN_UNITSOLUTION add ENERGY_STORAGE_MAX NUMERIC(15,5);

comment on column P5MIN_UNITSOLUTION.ENERGY_STORAGE_MAX is
    'BDU only - Maximum Energy Storage constraint limit (MWh)';

alter table P5MIN_UNITSOLUTION add MIN_AVAILABILITY NUMERIC(15,5);

comment on column P5MIN_UNITSOLUTION.MIN_AVAILABILITY is
    'BDU only. Load side availability (BidOfferPeriod.MAXAVAIL where DIRECTION = LOAD).';

comment on column P5MIN_UNITSOLUTION.INITIALMW is
    'Initial MW at start of period. For periods subsequent to the first period of a P5MIN run, this value represents the cleared target for the previous period of that P5MIN run. Negative values when Bi-directional Unit start from importing power, otherwise positive.';

comment on column P5MIN_UNITSOLUTION.TOTALCLEARED is
    'Target MW for end of period. Negative values when Bi-directional Unit is importing power, otherwise positive.';



-- Check if PD7DAY tables, constraints and indexes already exists


DO $$
    DECLARE
        -- Record variables
const_curs_rec RECORD;
        index_curs_rec RECORD;
        tbl_curs_rec RECORD;
BEGIN
        -- Loop for renaming constraints
FOR const_curs_rec IN
SELECT tc.table_name, tc.constraint_name
FROM information_schema.table_constraints tc
WHERE tc.constraint_name IN ('PD7DAY_CASESOLUTION_PK', 'PD7DAY_CONSTRAINTSOLUTION_PK', 'PD7DAY_INTERCONNECTORSOLN_PK', 'PD7DAY_MARKET_SUMMARY_PK', 'PD7DAY_PRICESOLUTION_PK')
  AND tc.constraint_schema = 'emms'
    LOOP
                EXECUTE format('ALTER TABLE %I RENAME CONSTRAINT %I TO %I_PRE53', const_curs_rec.table_name, const_curs_rec.constraint_name, const_curs_rec.constraint_name);
RAISE NOTICE 'renamed % constraint belonging to table %', const_curs_rec.constraint_name, const_curs_rec.table_name;
END LOOP;

        -- Loop for renaming indexes
FOR index_curs_rec IN
SELECT i.tablename, i.indexname as index_name
FROM pg_indexes i
WHERE i.indexname IN ('PD7DAY_CASESOLUTION_PK', 'PD7DAY_CONSTRAINTSOLUTION_PK', 'PD7DAY_INTERCONNECTORSOLN_PK', 'PD7DAY_MARKET_SUMMARY_PK', 'PD7DAY_PRICESOLUTION_PK')
  AND i.schemaname = 'emms'
    LOOP
                EXECUTE format('ALTER INDEX %I RENAME TO %I_PRE53', index_curs_rec.index_name, index_curs_rec.index_name);
RAISE NOTICE 'renamed % index belonging to table %', index_curs_rec.index_name, index_curs_rec.tablename;
END LOOP;

        -- Loop for renaming tables
FOR tbl_curs_rec IN
SELECT table_name
FROM information_schema.tables
WHERE table_name IN ('PD7DAY_CASESOLUTION', 'PD7DAY_CONSTRAINTSOLUTION', 'PD7DAY_INTERCONNECTORSOLUTION', 'PD7DAY_MARKET_SUMMARY', 'PD7DAY_PRICESOLUTION')
  AND table_schema = 'emms'
    LOOP
                EXECUTE format('ALTER TABLE %I RENAME TO %I_PRE53', tbl_curs_rec.table_name, tbl_curs_rec.table_name);
RAISE NOTICE 'renamed % to %_PRE53', tbl_curs_rec.table_name, tbl_curs_rec.table_name;
END LOOP;
END
$$;

/*==============================================================*/
/* Table: PD7DAY_CASESOLUTION                                   */
/*==============================================================*/
create table PD7DAY_CASESOLUTION (
                                     RUN_DATETIME         DATE                  not null,
                                     INTERVENTION         NUMERIC(2,0),
                                     LASTCHANGED          DATE
);

comment on table PD7DAY_CASESOLUTION is
    'PD7DAY case solution table';

comment on column PD7DAY_CASESOLUTION.RUN_DATETIME is
    'Unique Timestamp Identifier for this study';

comment on column PD7DAY_CASESOLUTION.INTERVENTION is
    'Flag to indicate if this Predispatch case includes an intervention pricing run: 0 = case does not include an intervention pricing run, 1 = case does include an intervention pricing run.';

comment on column PD7DAY_CASESOLUTION.LASTCHANGED is
    'Last date and time record changed';

ALTER TABLE pd7day_casesolution
    ADD CONSTRAINT pd7day_casesolution_pk PRIMARY KEY (run_datetime);

/*==============================================================*/
/* Table: PD7DAY_CONSTRAINTSOLUTION                             */
/*==============================================================*/
create table PD7DAY_CONSTRAINTSOLUTION (
                                           RUN_DATETIME         DATE                  not null,
                                           INTERVENTION         NUMERIC(2,0)           not null,
                                           INTERVAL_DATETIME    DATE                  not null,
                                           CONSTRAINTID         VARCHAR(20)          not null,
                                           RHS                  NUMERIC(15,5),
                                           MARGINALVALUE        NUMERIC(15,5),
                                           VIOLATIONDEGREE      NUMERIC(15,5),
                                           LHS                  NUMERIC(15,5),
                                           LASTCHANGED          DATE
);

comment on table PD7DAY_CONSTRAINTSOLUTION is
    'PD7DAY constraint solution';

comment on column PD7DAY_CONSTRAINTSOLUTION.RUN_DATETIME is
    'Unique Timestamp Identifier for this study';

comment on column PD7DAY_CONSTRAINTSOLUTION.INTERVENTION is
    'Flag to indicate if this Predispatch case includes an intervention pricing run: 0 = case does not include an intervention pricing run, 1 = case does include an intervention pricing run.';

comment on column PD7DAY_CONSTRAINTSOLUTION.INTERVAL_DATETIME is
    'The unique identifier for the interval within this study';

comment on column PD7DAY_CONSTRAINTSOLUTION.CONSTRAINTID is
    'Constraint identifier (synonymous with GenConID)';

comment on column PD7DAY_CONSTRAINTSOLUTION.RHS is
    'Right Hand Side value in the capacity evaluation in MW';

comment on column PD7DAY_CONSTRAINTSOLUTION.MARGINALVALUE is
    'Marginal cost of constraint (>0 if binding) in $/MW';

comment on column PD7DAY_CONSTRAINTSOLUTION.VIOLATIONDEGREE is
    'Amount of Violation (>0 if violating) in MW';

comment on column PD7DAY_CONSTRAINTSOLUTION.LHS is
    'Aggregation of the constraints LHS term solution values in MW';

comment on column PD7DAY_CONSTRAINTSOLUTION.LASTCHANGED is
    'Last date and time record changed';

ALTER TABLE pd7day_constraintsolution
    ADD CONSTRAINT pd7day_constraintsolution_pk PRIMARY KEY (run_datetime, interval_datetime, constraintid, intervention);

/*==============================================================*/
/* Table: PD7DAY_INTERCONNECTORSOLUTION                         */
/*==============================================================*/
create table PD7DAY_INTERCONNECTORSOLUTION (
                                               RUN_DATETIME         DATE                  not null,
                                               INTERVENTION         NUMERIC(2,0)           not null,
                                               INTERVAL_DATETIME    DATE                  not null,
                                               INTERCONNECTORID     VARCHAR(20)          not null,
                                               METEREDMWFLOW        NUMERIC(15,5),
                                               MWFLOW               NUMERIC(15,5),
                                               MWLOSSES             NUMERIC(15,5),
                                               MARGINALVALUE        NUMERIC(15,5),
                                               VIOLATIONDEGREE      NUMERIC(15,5),
                                               EXPORTLIMIT          NUMERIC(15,5),
                                               IMPORTLIMIT          NUMERIC(15,5),
                                               MARGINALLOSS         NUMERIC(15,5),
                                               EXPORTCONSTRAINTID   VARCHAR(20),
                                               IMPORTCONSTRAINTID   VARCHAR(20),
                                               FCASEXPORTLIMIT      NUMERIC(15,5),
                                               FCASIMPORTLIMIT      NUMERIC(15,5),
                                               LOCAL_PRICE_ADJUSTMENT_EXPORT NUMERIC(10,2),
                                               LOCALLY_CONSTRAINED_EXPORT NUMERIC(1,0),
                                               LOCAL_PRICE_ADJUSTMENT_IMPORT NUMERIC(10,2),
                                               LOCALLY_CONSTRAINED_IMPORT NUMERIC(1,0),
                                               LASTCHANGED          DATE
);

comment on table PD7DAY_INTERCONNECTORSOLUTION is
    'PD7DAY intereconnector solution';

comment on column PD7DAY_INTERCONNECTORSOLUTION.RUN_DATETIME is
    'Unique Timestamp Identifier for this study';

comment on column PD7DAY_INTERCONNECTORSOLUTION.INTERVENTION is
    'Flag to indicate if this Predispatch case includes an intervention pricing run: 0 = case does not include an intervention pricing run, 1 = case does include an intervention pricing run.';

comment on column PD7DAY_INTERCONNECTORSOLUTION.INTERVAL_DATETIME is
    'The unique identifier for the interval within this study';

comment on column PD7DAY_INTERCONNECTORSOLUTION.INTERCONNECTORID is
    'Interconnector identifier';

comment on column PD7DAY_INTERCONNECTORSOLUTION.METEREDMWFLOW is
    'SCADA MW Flow measured at Run start. For periods subsequent to the first period of a PD7DAY run, this value represents the cleared target for the previous period of that PD7DAY run.';

comment on column PD7DAY_INTERCONNECTORSOLUTION.MWFLOW is
    'Cleared Interconnector loading level (MW)';

comment on column PD7DAY_INTERCONNECTORSOLUTION.MWLOSSES is
    'Interconnector Losses at cleared flow';

comment on column PD7DAY_INTERCONNECTORSOLUTION.MARGINALVALUE is
    'Marginal cost of Interconnector standing data limits (if binding)';

comment on column PD7DAY_INTERCONNECTORSOLUTION.VIOLATIONDEGREE is
    'Violation of Interconnector standing data limits';

comment on column PD7DAY_INTERCONNECTORSOLUTION.EXPORTLIMIT is
    'Calculated Interconnector limit of exporting energy on the basis of invoked constraints and static interconnector export limit';

comment on column PD7DAY_INTERCONNECTORSOLUTION.IMPORTLIMIT is
    'Calculated Interconnector limit of importing energy on the basis of invoked constraints and static interconnector import limit. Note unlike the input interconnector import limit this is a directional quantity and should be defined with respect to the interconnector flow.';

comment on column PD7DAY_INTERCONNECTORSOLUTION.MARGINALLOSS is
    'Marginal loss factor at the cleared flow';

comment on column PD7DAY_INTERCONNECTORSOLUTION.EXPORTCONSTRAINTID is
    'Generic Constraint setting the export limit';

comment on column PD7DAY_INTERCONNECTORSOLUTION.IMPORTCONSTRAINTID is
    'Generic Constraint setting the import limit';

comment on column PD7DAY_INTERCONNECTORSOLUTION.FCASEXPORTLIMIT is
    'Calculated export limit applying to energy + Frequency Controlled Ancillary Services.';

comment on column PD7DAY_INTERCONNECTORSOLUTION.FCASIMPORTLIMIT is
    'Calculated import limit applying to energy + Frequency Controlled Ancillary Services.';

comment on column PD7DAY_INTERCONNECTORSOLUTION.LOCAL_PRICE_ADJUSTMENT_EXPORT is
    'Aggregate Constraint contribution cost of this Interconnector: Sum(MarginalValue x Factor) for all relevant Constraints, for Export (Factor >= 0)';

comment on column PD7DAY_INTERCONNECTORSOLUTION.LOCALLY_CONSTRAINED_EXPORT is
    'Key for Local_Price_Adjustment_Export: 2 = at least one Outage Constraint; 1 = at least 1 System Normal Constraint (and no Outage Constraint); 0 = No System Normal or Outage Constraints';

comment on column PD7DAY_INTERCONNECTORSOLUTION.LOCAL_PRICE_ADJUSTMENT_IMPORT is
    'Aggregate Constraint contribution cost of this Interconnector: Sum(MarginalValue x Factor) for all relevant Constraints, for Import (Factor >= 0)';

comment on column PD7DAY_INTERCONNECTORSOLUTION.LOCALLY_CONSTRAINED_IMPORT is
    'Key for Local_Price_Adjustment_Import: 2 = at least one Outage Constraint; 1 = at least 1 System Normal Constraint (and no Outage Constraint); 0 = No System Normal or Outage Constraints';

comment on column PD7DAY_INTERCONNECTORSOLUTION.LASTCHANGED is
    'Last date and time record changed';

ALTER TABLE pd7day_interconnectorsolution
    ADD CONSTRAINT pd7day_interconnectorsoln_pk PRIMARY KEY (run_datetime, interval_datetime, interconnectorid, intervention);

/*==============================================================*/
/* Table: PD7DAY_MARKET_SUMMARY                                 */
/*==============================================================*/
create table PD7DAY_MARKET_SUMMARY (
                                       RUN_DATETIME         DATE                  not null,
                                       INTERVAL_DATETIME    DATE                  not null,
                                       GPG_FUEL_FORECAST_TJ NUMERIC(15,5)
);

comment on table PD7DAY_MARKET_SUMMARY is
    'PD7DAY market summary showing calculated gas fuel forecasts';

comment on column PD7DAY_MARKET_SUMMARY.RUN_DATETIME is
    'Unique Timestamp Identifier for this study';

comment on column PD7DAY_MARKET_SUMMARY.INTERVAL_DATETIME is
    'The unique identifier for the interval within this study';

comment on column PD7DAY_MARKET_SUMMARY.GPG_FUEL_FORECAST_TJ is
    'The total gas consumption in TJ';

ALTER TABLE pd7day_market_summary
    ADD CONSTRAINT pd7day_market_summary_pk PRIMARY KEY (run_datetime, interval_datetime);

/*==============================================================*/
/* Table: PD7DAY_PRICESOLUTION                                  */
/*==============================================================*/
create table PD7DAY_PRICESOLUTION (
                                      RUN_DATETIME         DATE                  not null,
                                      INTERVENTION         NUMERIC(2,0)           not null,
                                      INTERVAL_DATETIME    DATE                  not null,
                                      REGIONID             VARCHAR(20)          not null,
                                      RRP                  NUMERIC(15,5),
                                      LOWER1SECRRP         NUMERIC(15,5),
                                      LOWER6SECRRP         NUMERIC(15,5),
                                      LOWER60SECRRP        NUMERIC(15,5),
                                      LOWER5MINRRP         NUMERIC(15,5),
                                      LOWERREGRRP          NUMERIC(15,5),
                                      RAISE1SECRRP         NUMERIC(15,5),
                                      RAISE6SECRRP         NUMERIC(15,5),
                                      RAISE60SECRRP        NUMERIC(15,5),
                                      RAISE5MINRRP         NUMERIC(15,5),
                                      RAISEREGRRP          NUMERIC(15,5),
                                      LASTCHANGED          DATE
);

comment on table PD7DAY_PRICESOLUTION is
    'PD7DAY price solution';

comment on column PD7DAY_PRICESOLUTION.RUN_DATETIME is
    'Unique Timestamp Identifier for this study';

comment on column PD7DAY_PRICESOLUTION.INTERVENTION is
    'Flag to indicate if this Predispatch case includes an intervention pricing run: 0 = case does not include an intervention pricing run, 1 = case does include an intervention pricing run.';

comment on column PD7DAY_PRICESOLUTION.INTERVAL_DATETIME is
    'The unique identifier for the interval within this study';

comment on column PD7DAY_PRICESOLUTION.REGIONID is
    'Region Identifier';

comment on column PD7DAY_PRICESOLUTION.RRP is
    'Region Reference Price (Energy)';

comment on column PD7DAY_PRICESOLUTION.LOWER1SECRRP is
    'Regional Lower 1Sec Price - RegionSolution element L1Price attribute';

comment on column PD7DAY_PRICESOLUTION.LOWER6SECRRP is
    'Region Reference Price (Lower6Sec)';

comment on column PD7DAY_PRICESOLUTION.LOWER60SECRRP is
    'Region Reference Price (Lower60Sec)';

comment on column PD7DAY_PRICESOLUTION.LOWER5MINRRP is
    'Region Reference Price (Lower5Min)';

comment on column PD7DAY_PRICESOLUTION.LOWERREGRRP is
    'Region Reference Price (LowerReg)';

comment on column PD7DAY_PRICESOLUTION.RAISE1SECRRP is
    'Regional Raise 1Sec Price - R1Price attribute after capping/flooring';

comment on column PD7DAY_PRICESOLUTION.RAISE6SECRRP is
    'Region Reference Price (Raise6Sec)';

comment on column PD7DAY_PRICESOLUTION.RAISE60SECRRP is
    'Region Reference Price (Raise60Sec)';

comment on column PD7DAY_PRICESOLUTION.RAISE5MINRRP is
    'Region Reference Price (Raise5Min)';

comment on column PD7DAY_PRICESOLUTION.RAISEREGRRP is
    'Region Reference Price (RaiseReg)';

comment on column PD7DAY_PRICESOLUTION.LASTCHANGED is
    'Last date and time record changed';

ALTER TABLE pd7day_pricesolution
    ADD CONSTRAINT pd7day_pricesolution_pk PRIMARY KEY (run_datetime, interval_datetime, regionid, intervention);

comment on column PDPASA_REGIONSOLUTION.AGGREGATEPASAAVAILABILITY is
    'Sum of PASAAVAILABILITY for all scheduled generating units and the Unconstrained Intermittent Generation Forecasts (UIGF) for all semi-scheduled generating units in a given Region for a given PERIODID.
    For the RELIABILITY_LRC and OUTAGE_LRC runs, UIGF is the POE90 forecast. For the LOR run, UIGF is the POE50 forecast.';

comment on column PDPASA_REGIONSOLUTION.SEMISCHEDULEDCAPACITY is
    'Constrained generation forecast for semi-scheduled units for the region. For RELIABILITY_LRC run semi-scheduled generation is constrained only by System Normal constraints. For OUTAGE_LRC run and LOR run semi-scheduled generation is constrained by both System Normal and Outage constraints. All three run types (RELIABILITY_LRC, OUTAGE_LRC, LOR) incorporate MAXAVAIL limits.';

comment on column PDPASA_REGIONSOLUTION.LOR_SEMISCHEDULEDCAPACITY is
    'Constrained generation forecast for semi-scheduled units for the region for the LOR run. Semi-scheduled generation is constrained by both System Normal and Outage constraints, and incorporate MAXAVAIL limits.';

alter table PREDISPATCHLOAD add INITIAL_ENERGY_STORAGE NUMERIC(15,5);

comment on column PREDISPATCHLOAD.INITIAL_ENERGY_STORAGE is
    'BDU only. The energy storage at the start of this dispatch interval (MWh)';

alter table PREDISPATCHLOAD add ENERGY_STORAGE NUMERIC(15,5);

comment on column PREDISPATCHLOAD.ENERGY_STORAGE is
    'BDU only. The projected energy storage based on cleared energy and regulation FCAS dispatch (MWh).
    Participants may use negative values as an indicator of the relative �error� in profiling Max Availability to reflect energy limits';

alter table PREDISPATCHLOAD add ENERGY_STORAGE_MIN NUMERIC(15,5);

comment on column PREDISPATCHLOAD.ENERGY_STORAGE_MIN is
    'BDU only - Minimum Energy Storage constraint limit (MWh)';

alter table PREDISPATCHLOAD add ENERGY_STORAGE_MAX NUMERIC(15,5);

comment on column PREDISPATCHLOAD.ENERGY_STORAGE_MAX is
    'BDU only - Maximum Energy Storage constraint limit (MWh)';

alter table PREDISPATCHLOAD add MIN_AVAILABILITY NUMERIC(15,5);

comment on column PREDISPATCHLOAD.MIN_AVAILABILITY is
    'BDU only. Load side availability (BidOfferPeriod.MAXAVAIL where DIRECTION = LOAD)';

comment on column PREDISPATCHLOAD.INITIALMW is
    'Initial MW at start of first period. For periods subsequent to the first period of a Pre-Dispatch run, this value represents the cleared target for the previous period of that Pre-Dispatch run. Negative values when Bi-directional Unit start from importing power, otherwise positive.';

comment on column PREDISPATCHLOAD.TOTALCLEARED is
    'Target MW for end of period. Negative values when Bi-directional Unit is importing power, otherwise positive.';

alter table PREDISPATCHREGIONSUM add BDU_ENERGY_STORAGE NUMERIC(15,5);

comment on column PREDISPATCHREGIONSUM.BDU_ENERGY_STORAGE is
    'Regional aggregated energy storage where the DUID type is BDU (MWh)';

alter table PREDISPATCHREGIONSUM add BDU_MIN_AVAIL NUMERIC(15,5);

comment on column PREDISPATCHREGIONSUM.BDU_MIN_AVAIL is
    'Total available load side BDU summated for region (MW)';

alter table PREDISPATCHREGIONSUM add BDU_MAX_AVAIL NUMERIC(15,5);

comment on column PREDISPATCHREGIONSUM.BDU_MAX_AVAIL is
    'Total available generation side BDU summated for region (MW)';

alter table PREDISPATCHREGIONSUM add BDU_CLEAREDMW_GEN NUMERIC(15,5);

comment on column PREDISPATCHREGIONSUM.BDU_CLEAREDMW_GEN is
    'Regional aggregated cleared MW where the DUID type is BDU. Net of export (Generation)';

alter table PREDISPATCHREGIONSUM add BDU_CLEAREDMW_LOAD NUMERIC(15,5);

comment on column PREDISPATCHREGIONSUM.BDU_CLEAREDMW_LOAD is
    'Regional aggregated cleared MW where the DUID type is BDU. Net of import (Load)';

comment on table SETFCASREGIONRECOVERY is
    'The FCAS Recovery amount from each NEM Region and the Energy MWh used for the FCAS Recovery calculation from Participants';

alter table SETFCASREGIONRECOVERY add REGION_ACE_MWH NUMERIC(18,8);

comment on column SETFCASREGIONRECOVERY.REGION_ACE_MWH is
    'The Regional ACE MWh value used for the FCAS Recovery. NULL for Settlement dates prior to the IESS rule effective date';

alter table SETFCASREGIONRECOVERY add REGION_ASOE_MWH NUMERIC(18,8);

comment on column SETFCASREGIONRECOVERY.REGION_ASOE_MWH is
    'The Regional ASOE MWh value used for the FCAS Recovery. NULL for Settlement dates prior to the IESS rule effective date';

alter table SETFCASREGIONRECOVERY add REGIONRECOVERYAMOUNT_ACE NUMERIC(18,8);

comment on column SETFCASREGIONRECOVERY.REGIONRECOVERYAMOUNT_ACE is
    'The Total Dollar Amount for the Region recovered using the ACE MWh Values. NULL for Settlement dates prior to the IESS rule effective date';

alter table SETFCASREGIONRECOVERY add REGIONRECOVERYAMOUNT_ASOE NUMERIC(18,8);

comment on column SETFCASREGIONRECOVERY.REGIONRECOVERYAMOUNT_ASOE is
    'The Total Dollar Amount for the Region recovered using the ASOE MWh Values. NULL for Settlement dates prior to the IESS rule effective date';

alter table SETFCASREGIONRECOVERY add REGIONRECOVERYAMOUNT NUMERIC(18,8);

comment on column SETFCASREGIONRECOVERY.REGIONRECOVERYAMOUNT is
    'The Total Dollar Amount for the Region (RegionRecoveryAmountACE + RegionRecoveryAmountASOE). NULL for Settlement dates prior to the IESS rule effective date';

comment on column SETFCASREGIONRECOVERY.GENERATORREGIONENERGY is
    'Generator Regional Energy Amount. NULL for Settlement dates post the IESS rule effective date';

comment on column SETFCASREGIONRECOVERY.CUSTOMERREGIONENERGY is
    'Customer Region Energy Amount. NULL for Settlement dates post the IESS rule effective date';

comment on table SETINTRAREGIONRESIDUES is
    'The Settlement Intra Region Residues Result.';

alter table SETINTRAREGIONRESIDUES add ACE_AMOUNT NUMERIC(18,8);

comment on column SETINTRAREGIONRESIDUES.ACE_AMOUNT is
    'The Adjusted Consumed Energy Dollar Amount for the Region used in the calculation of IRSS (Intra Residue Amount). NULL for Settlement dates prior to the IESS rule effective date';

alter table SETINTRAREGIONRESIDUES add ASOE_AMOUNT NUMERIC(18,8);

comment on column SETINTRAREGIONRESIDUES.ASOE_AMOUNT is
    'The Adjusted Sent Out Energy Dollar Amount for the Region used in the calculation of IRSS (Intra Residue Amount). NULL for Settlement dates prior to the IESS rule effective date';

comment on column SETINTRAREGIONRESIDUES.EP is
    'Energy payments to generators. NULL for Settlement dates post the IESS rule effective date';

comment on column SETINTRAREGIONRESIDUES.EC is
    'Energy purchased by customers. NULL for Settlement dates post the IESS rule effective date';

alter table SETMARKETFEES add METER_TYPE VARCHAR(20);

comment on column SETMARKETFEES.METER_TYPE is
    'The Energy Type for the Market Fees Calculation. E.g of Meter Types are CUSTOMER, GENERATOR, NREG, BDU etc. If Meter Type is mentioned as ALL then all the Meter Types for that Participant Category will be used in the Fee calculation';

alter table SETMARKETFEES add METER_SUBTYPE VARCHAR(20);

comment on column SETMARKETFEES.METER_SUBTYPE is
    'The Meter Sub Type values are ACE, ASOE or ALL. ACE represent ACE_MWH value or ASOE represent ASOE_MWH value and ALL represent sum of ACE_MWh and ASOE_MWh';

/*==============================================================*/
/* Table: SET_ENERGY_GENSET_DETAIL                              */
/*==============================================================*/
create table SET_ENERGY_GENSET_DETAIL (
                                          SETTLEMENTDATE       DATE                  not null,
                                          VERSIONNO            NUMERIC(3,0)           not null,
                                          PERIODID             NUMERIC(3,0)           not null,
                                          PARTICIPANTID        VARCHAR(20),
                                          STATIONID            VARCHAR(20)          not null,
                                          DUID                 VARCHAR(20)          not null,
                                          GENSETID             VARCHAR(20)          not null,
                                          REGIONID             VARCHAR(20),
                                          CONNECTIONPOINTID    VARCHAR(20),
                                          RRP                  NUMERIC(18,8),
                                          TLF                  NUMERIC(18,8),
                                          METERID              VARCHAR(20),
                                          CE_MWH               NUMERIC(18,8),
                                          UFEA_MWH             NUMERIC(18,8),
                                          ACE_MWH              NUMERIC(18,8),
                                          ASOE_MWH             NUMERIC(18,8),
                                          TOTAL_MWH            NUMERIC(18,8),
                                          DME_MWH              NUMERIC(18,8),
                                          ACE_AMOUNT           NUMERIC(18,8),
                                          ASOE_AMOUNT          NUMERIC(18,8),
                                          TOTAL_AMOUNT         NUMERIC(18,8),
                                          LASTCHANGED          DATE
);

comment on table SET_ENERGY_GENSET_DETAIL is
    'The Settlement Energy Genset report contains the Energy Transactions data for each generation meter point. This report is produced only for Settlement Date post the IESS rule effective date.';

comment on column SET_ENERGY_GENSET_DETAIL.SETTLEMENTDATE is
    'The Settlement Date of the Billing Week';

comment on column SET_ENERGY_GENSET_DETAIL.VERSIONNO is
    'The Settlement Run No';

comment on column SET_ENERGY_GENSET_DETAIL.PERIODID is
    'The Period ID Identifier';

comment on column SET_ENERGY_GENSET_DETAIL.PARTICIPANTID is
    'The Participant Id Identifier';

comment on column SET_ENERGY_GENSET_DETAIL.STATIONID is
    'The StationId identifier associated with the GensetId';

comment on column SET_ENERGY_GENSET_DETAIL.DUID is
    'The DUID for the meter associated with the GensetId';

comment on column SET_ENERGY_GENSET_DETAIL.GENSETID is
    'The GensetId for the Meter Id received';

comment on column SET_ENERGY_GENSET_DETAIL.REGIONID is
    'The Region Id for the Connection Point associated with the DUID';

comment on column SET_ENERGY_GENSET_DETAIL.CONNECTIONPOINTID is
    'The Connection Point associated with the DUID';

comment on column SET_ENERGY_GENSET_DETAIL.RRP is
    'The Regional Reference Price for the Settlement Period';

comment on column SET_ENERGY_GENSET_DETAIL.TLF is
    'The Transmission Loss Factor applied to the Connection Point Id. TLF is calculated based on the Net Flow at the TNI.';

comment on column SET_ENERGY_GENSET_DETAIL.METERID is
    'The Meter ID Identifier (NMI)';

comment on column SET_ENERGY_GENSET_DETAIL.CE_MWH is
    'The Consumed Energy for the Meter Id . Energy received in the meter reads (DLF Adjusted)';

comment on column SET_ENERGY_GENSET_DETAIL.UFEA_MWH is
    'The UFEA allocation amount applied to the Meter Data';

comment on column SET_ENERGY_GENSET_DETAIL.ACE_MWH is
    'The Adjusted Consumed Energy for the Meter Id (CE_MWh + UFEA)';

comment on column SET_ENERGY_GENSET_DETAIL.ASOE_MWH is
    'The Adjusted Sent Out Energy for the Meter Id.';

comment on column SET_ENERGY_GENSET_DETAIL.TOTAL_MWH is
    'The Total MWh for the Meter Id (ACE_MWh + ASOE_MWh)';

comment on column SET_ENERGY_GENSET_DETAIL.DME_MWH is
    'The DME MWh value that is used to calculate the UFEA Allocation Amount';

comment on column SET_ENERGY_GENSET_DETAIL.ACE_AMOUNT is
    'The Adjusted Consumed Energy Dollar Amount';

comment on column SET_ENERGY_GENSET_DETAIL.ASOE_AMOUNT is
    'The Adjusted Sent Out Energy Dollar Amount';

comment on column SET_ENERGY_GENSET_DETAIL.TOTAL_AMOUNT is
    'The Total Amount for the Meter Id (ACE_Amount + ASOE_Amount)';

comment on column SET_ENERGY_GENSET_DETAIL.LASTCHANGED is
    'The Last changed Date time of the record';

ALTER TABLE set_energy_genset_detail
    ADD CONSTRAINT set_energy_genset_detail_pk PRIMARY KEY (settlementdate, versionno, periodid, stationid, duid, gensetid);


/*==============================================================*/
/* Table: SET_ENERGY_REGION_SUMMARY                             */
/*==============================================================*/
create table SET_ENERGY_REGION_SUMMARY (
                                           SETTLEMENTDATE       DATE                  not null,
                                           VERSIONNO            NUMERIC(3,0)           not null,
                                           PERIODID             NUMERIC(3,0)           not null,
                                           REGIONID             VARCHAR(20)          not null,
                                           CE_MWH               NUMERIC(18,8),
                                           UFEA_MWH             NUMERIC(18,8),
                                           ACE_MWH              NUMERIC(18,8),
                                           ASOE_MWH             NUMERIC(18,8),
                                           ACE_AMOUNT           NUMERIC(18,8),
                                           ASOE_AMOUNT          NUMERIC(18,8),
                                           TOTAL_MWH            NUMERIC(18,8),
                                           TOTAL_AMOUNT         NUMERIC(18,8),
                                           LASTCHANGED          DATE
);

comment on table SET_ENERGY_REGION_SUMMARY is
    'The Settlement Energy Region Summary report contains the Energy Transactions Summary for all the NEM regions. This report is produced only for Settlement Date post the IESS rule effective date.';

comment on column SET_ENERGY_REGION_SUMMARY.SETTLEMENTDATE is
    'The Settlement Date of the Billing Week';

comment on column SET_ENERGY_REGION_SUMMARY.VERSIONNO is
    'The Settlement Run No';

comment on column SET_ENERGY_REGION_SUMMARY.PERIODID is
    'The Period ID Identifier';

comment on column SET_ENERGY_REGION_SUMMARY.REGIONID is
    'The NEM Region Id Identifier';

comment on column SET_ENERGY_REGION_SUMMARY.CE_MWH is
    'The Consumed Energy summary for the Region Id';

comment on column SET_ENERGY_REGION_SUMMARY.UFEA_MWH is
    'The UFEA Energy summary for the Region Id';

comment on column SET_ENERGY_REGION_SUMMARY.ACE_MWH is
    'The Adjusted Consumed Energy summary for the Region Id';

comment on column SET_ENERGY_REGION_SUMMARY.ASOE_MWH is
    'The Adjusted Sent Out Energy summary for the Region Id';

comment on column SET_ENERGY_REGION_SUMMARY.ACE_AMOUNT is
    'The Adjusted Consumed Energy Amount for the Region Id';

comment on column SET_ENERGY_REGION_SUMMARY.ASOE_AMOUNT is
    'The Adjusted Sent Out Energy Amount for the Region Id';

comment on column SET_ENERGY_REGION_SUMMARY.TOTAL_MWH is
    'The Total Energy summary for the Region Id';

comment on column SET_ENERGY_REGION_SUMMARY.TOTAL_AMOUNT is
    'The Total Dollar Amount summary for the Region Id';

comment on column SET_ENERGY_REGION_SUMMARY.LASTCHANGED is
    'The Last changed Date time of the record';

ALTER TABLE set_energy_region_summary
    ADD CONSTRAINT set_energy_region_summary_pk PRIMARY KEY (settlementdate, versionno, periodid, regionid);


/*==============================================================*/
/* Table: SET_ENERGY_TRANSACTIONS                               */
/*==============================================================*/
create table SET_ENERGY_TRANSACTIONS (
                                         SETTLEMENTDATE       DATE                  not null,
                                         VERSIONNO            NUMERIC(3,0)           not null,
                                         PERIODID             NUMERIC(3,0)           not null,
                                         PARTICIPANTID        VARCHAR(20)          not null,
                                         CONNECTIONPOINTID    VARCHAR(20)          not null,
                                         METER_TYPE           VARCHAR(20)          not null,
                                         REGIONID             VARCHAR(20),
                                         RRP                  NUMERIC(18,8),
                                         TLF                  NUMERIC(18,8),
                                         CE_MWH               NUMERIC(18,8),
                                         UFEA_MWH             NUMERIC(18,8),
                                         ACE_MWH              NUMERIC(18,8),
                                         ASOE_MWH             NUMERIC(18,8),
                                         TOTAL_MWH            NUMERIC(18,8),
                                         ACE_AMOUNT           NUMERIC(18,8),
                                         ASOE_AMOUNT          NUMERIC(18,8),
                                         TOTAL_AMOUNT         NUMERIC(18,8),
                                         CASE_ID              NUMERIC(10,0),
                                         DME_MWH              NUMERIC(18,8),
                                         AGGREGATE_READ_FLAG  NUMERIC(3,0),
                                         INDIVIDUAL_READ_FLAG NUMERIC(3,0),
                                         LASTCHANGED          DATE
);

comment on table SET_ENERGY_TRANSACTIONS is
    'The Settlement Energy Transactions report contains the Energy Transactions data for all the Participants based on their ACE and ASOE at each customer and generator Connection Point ID. This table is populated The Settlement Energy Transactions report contains the Energy Transactions data for all the Participants based on their ACE and ASOE at each customer and generator Connection Point ID. This table is populated only if Settlement Date is post the IESS rule effective date.';

comment on column SET_ENERGY_TRANSACTIONS.SETTLEMENTDATE is
    'The Settlement Date of the Billing Week';

comment on column SET_ENERGY_TRANSACTIONS.VERSIONNO is
    'The Settlement Run No';

comment on column SET_ENERGY_TRANSACTIONS.PERIODID is
    'The Period ID Identifier';

comment on column SET_ENERGY_TRANSACTIONS.PARTICIPANTID is
    'The Participant Id Identifier';

comment on column SET_ENERGY_TRANSACTIONS.CONNECTIONPOINTID is
    'The Connection Point associated with the Energy Transaction reads.';

comment on column SET_ENERGY_TRANSACTIONS.METER_TYPE is
    'The type of meter reads received. Eg Customer, Generator, BDU, NREG etc.';

comment on column SET_ENERGY_TRANSACTIONS.REGIONID is
    'The NEM Region Id Identifier';

comment on column SET_ENERGY_TRANSACTIONS.RRP is
    'The Regional Reference Price for the Region';

comment on column SET_ENERGY_TRANSACTIONS.TLF is
    'The Transmission Loss Factor applied to the Connection Point Id. TLF is calculated based on the Net Flow at the TNI.';

comment on column SET_ENERGY_TRANSACTIONS.CE_MWH is
    'The Consumed Energy . Energy received in the meter reads (DLF Adjusted)';

comment on column SET_ENERGY_TRANSACTIONS.UFEA_MWH is
    'The UFE Allocation Amount applied to the Participant';

comment on column SET_ENERGY_TRANSACTIONS.ACE_MWH is
    'The Adjusted Consumed Energy MWh ( CE_MWh + UFEA) for the ConnectionPointId';

comment on column SET_ENERGY_TRANSACTIONS.ASOE_MWH is
    'The Adjusted Sent Out Energy for the ConnectionPointId . Energy received in the meter reads adjusted by DLF.';

comment on column SET_ENERGY_TRANSACTIONS.TOTAL_MWH is
    'The Total MWh Value for the Participant. ACE_MWh + ASOE_MWh';

comment on column SET_ENERGY_TRANSACTIONS.ACE_AMOUNT is
    'The dollar amount for Adjusted Consumed Energy MWh (ACE_MWh * TLF * RRP)';

comment on column SET_ENERGY_TRANSACTIONS.ASOE_AMOUNT is
    'The dollar amount for Adjusted Sent Out Energy MWh (ASOE_MWh * TLF * RRP)';

comment on column SET_ENERGY_TRANSACTIONS.TOTAL_AMOUNT is
    'The Total Dollar Value for the Participant. ACE_Amount + ASOE_Amount';

comment on column SET_ENERGY_TRANSACTIONS.CASE_ID is
    'The Metering Case ID';

comment on column SET_ENERGY_TRANSACTIONS.DME_MWH is
    'The DME MWh (Distribution Connected) that is used in the UFEA Calculation.';

comment on column SET_ENERGY_TRANSACTIONS.AGGREGATE_READ_FLAG is
    'The Flag is 1 if the meter data source is from Aggregate Reads Meter Data, Else 0';

comment on column SET_ENERGY_TRANSACTIONS.INDIVIDUAL_READ_FLAG is
    'The Flag is 1 if the meter data source is from Individual Reads Meter Data, Else 0';

comment on column SET_ENERGY_TRANSACTIONS.LASTCHANGED is
    'The Last changed Date time of the record';

ALTER TABLE set_energy_transactions
    ADD CONSTRAINT set_energy_transactions_pk PRIMARY KEY (settlementdate, versionno, periodid, participantid, connectionpointid, meter_type);

alter table SET_FCAS_RECOVERY add LOWERREG_ACE NUMERIC(18,8);

comment on column SET_FCAS_RECOVERY.LOWERREG_ACE is
    'The Lower Regulation FCAS Residue Recovery Amount using ACE MWh values excluding the MPF Connection Points. NULL value for Settlement Dates prior to the IESS rule effective date.';

alter table SET_FCAS_RECOVERY add RAISEREG_ACE NUMERIC(18,8);

comment on column SET_FCAS_RECOVERY.RAISEREG_ACE is
    'The Raise Regulation FCAS Residue Recovery Amount using ACE MWh values excluding the MPF Connection Points. NULL Value for Settlement Dates prior to the IESS rule effective date.';

alter table SET_FCAS_RECOVERY add RAISE1SEC_ACE NUMERIC(18,8);

comment on column SET_FCAS_RECOVERY.RAISE1SEC_ACE is
    'The Raise1Sec FCAS Recovery Amount for the Participant and Region from ACE MWh Portion. NULL Value for Settlement Dates prior to the IESS rule effective date.';

alter table SET_FCAS_RECOVERY add RAISE1SEC_ASOE NUMERIC(18,8);

comment on column SET_FCAS_RECOVERY.RAISE1SEC_ASOE is
    'The Raise1Sec FCAS Recovery Amount for the Participant and Region from ASOE MWh Portion. NULL Value for Settlement Dates prior to the IESS rule effective date.';

alter table SET_FCAS_RECOVERY add LOWER1SEC_ACE NUMERIC(18,8);

comment on column SET_FCAS_RECOVERY.LOWER1SEC_ACE is
    'The Lower1Sec FCAS Recovery Amount for the Participant and Region from ACE MWh Portion. NULL Value for Settlement Dates prior to the IESS rule effective date.';

alter table SET_FCAS_RECOVERY add LOWER1SEC_ASOE NUMERIC(18,8);

comment on column SET_FCAS_RECOVERY.LOWER1SEC_ASOE is
    'The Lower1Sec FCAS Recovery Amount for the Participant and Region from ASOE MWh Portion. NULL Value for Settlement Dates prior to the IESS rule effective date.';

alter table SET_FCAS_RECOVERY add RAISE6SEC_ACE NUMERIC(18,8);

comment on column SET_FCAS_RECOVERY.RAISE6SEC_ACE is
    'The Raise6Sec FCAS Recovery Amount for the Participant and Region from ACE MWh Portion. NULL Value for Settlement Dates prior to the IESS rule effective date.';

alter table SET_FCAS_RECOVERY add RAISE6SEC_ASOE NUMERIC(18,8);

comment on column SET_FCAS_RECOVERY.RAISE6SEC_ASOE is
    'The Raise6Sec FCAS Recovery Amount for the Participant and Region from ASOE MWh Portion. NULL Value for Settlement Dates prior to the IESS rule effective date.';

alter table SET_FCAS_RECOVERY add LOWER6SEC_ACE NUMERIC(18,8);

comment on column SET_FCAS_RECOVERY.LOWER6SEC_ACE is
    'The Lower6Sec FCAS Recovery Amount for the Participant and Region from ACE MWh Portion. NULL Value for Settlement Dates prior to the IESS rule effective date.';

alter table SET_FCAS_RECOVERY add LOWER6SEC_ASOE NUMERIC(18,8);

comment on column SET_FCAS_RECOVERY.LOWER6SEC_ASOE is
    'The Lower6Sec FCAS Recovery Amount for the Participant and Region from ASOE MWh Portion. NULL Value for Settlement Dates prior to the IESS rule effective date.';

alter table SET_FCAS_RECOVERY add RAISE60SEC_ACE NUMERIC(18,8);

comment on column SET_FCAS_RECOVERY.RAISE60SEC_ACE is
    'The Raise60Sec FCAS Recovery Amount for the Participant and Region from ACE MWh Portion. NULL Value for Settlement Dates prior to the IESS rule effective date.';

alter table SET_FCAS_RECOVERY add RAISE60SEC_ASOE NUMERIC(18,8);

comment on column SET_FCAS_RECOVERY.RAISE60SEC_ASOE is
    'The Raise60Sec FCAS Recovery Amount for the Participant and Region from ASOE MWh Portion. NULL Value for Settlement Dates prior to the IESS rule effective date.';

alter table SET_FCAS_RECOVERY add LOWER60SEC_ACE NUMERIC(18,8);

comment on column SET_FCAS_RECOVERY.LOWER60SEC_ACE is
    'The Lower60Sec FCAS Recovery Amount for the Participant and Region from ACE MWh Portion. NULL Value for Settlement Dates prior to the IESS rule effective date.';

alter table SET_FCAS_RECOVERY add LOWER60SEC_ASOE NUMERIC(18,8);

comment on column SET_FCAS_RECOVERY.LOWER60SEC_ASOE is
    'The Lower60Sec FCAS Recovery Amount for the Participant and Region from ASOE MWh Portion. NULL Value for Settlement Dates prior to the IESS rule effective date.';

alter table SET_FCAS_RECOVERY add RAISE5MIN_ACE NUMERIC(18,8);

comment on column SET_FCAS_RECOVERY.RAISE5MIN_ACE is
    'The Raise5Min FCAS Recovery Amount for the Participant and Region from ACE MWh Portion. NULL Value for Settlement Dates prior to the IESS rule effective date.';

alter table SET_FCAS_RECOVERY add RAISE5MIN_ASOE NUMERIC(18,8);

comment on column SET_FCAS_RECOVERY.RAISE5MIN_ASOE is
    'The Raise5Min FCAS Recovery Amount for the Participant and Region from ASOE MWh Portion. NULL Value for Settlement Dates prior to the IESS rule effective date.';

alter table SET_FCAS_RECOVERY add LOWER5MIN_ACE NUMERIC(18,8);

comment on column SET_FCAS_RECOVERY.LOWER5MIN_ACE is
    'The Lower5Min FCAS Recovery Amount for the Participant and Region from ACE MWh Portion. NULL Value for Settlement Dates prior to the IESS rule effective date.';

alter table SET_FCAS_RECOVERY add LOWER5MIN_ASOE NUMERIC(18,8);

comment on column SET_FCAS_RECOVERY.LOWER5MIN_ASOE is
    'The Lower5Min FCAS Recovery Amount for the Participant and Region from ASOE MWh Portion. NULL Value for Settlement Dates prior to the IESS rule effective date.';

comment on column SET_FCAS_RECOVERY.LOWER6SEC_RECOVERY is
    'Recovery amount for the Lower 6 Second service attributable to customer connection points. NULL for Settlement date post the IESS rule effective date';

comment on column SET_FCAS_RECOVERY.RAISE6SEC_RECOVERY is
    'Recovery amount for the Raise 6 Second service attributable to customer connection points. NULL for Settlement dates post the IESS rule effective date';

comment on column SET_FCAS_RECOVERY.LOWER60SEC_RECOVERY is
    'Recovery amount for the Lower 60 Second service attributable to customer connection points. NULL for Settlement dates post the IESS rule effective date';

comment on column SET_FCAS_RECOVERY.RAISE60SEC_RECOVERY is
    'Recovery amount for the Raise 60 Second service attributable to customer connection points. NULL for Settlement dates post the IESS rule effective date';

comment on column SET_FCAS_RECOVERY.LOWER5MIN_RECOVERY is
    'Recovery amount for the Lower 5 Minute service attributable to customer connection points. NULL for Settlement dates post the IESS rule effective date';

comment on column SET_FCAS_RECOVERY.RAISE5MIN_RECOVERY is
    'Recovery amount for the Raise 5 Minute service attributable to customer connection points. NULL for Settlement dates post the IESS rule effective date';

comment on column SET_FCAS_RECOVERY.LOWERREG_RECOVERY is
    'For a Settlement date prior to the IESS rule effective date, the column represent Sum of MPF Lower Regulation recovery amount from Customer Connection Points and the Residue Recovery amount from Customers excluding the MPF Connection Points. For Settlement Date post the IESS rule effective date the column represent the Lower Regulation FCAS MPF Recovery Amount from Customer and Generator Connection Point MPFs only. Residue Recovery Amount is not included in this amount.';

comment on column SET_FCAS_RECOVERY.RAISEREG_RECOVERY is
    'For a Settlement date prior to the IESS rule effective date, the column represent Sum of MPF Raise Regulation recovery amount from Customer Connection Points and the Residue Recovery amount from Customers excluding the MPF Connection Points. For Settlement Date post the IESS rule effective date the column represent the Raise Regulation FCAS MPF Recovery Amount from Customer and Generator Connection Point MPFs only. Residue Recovery Amount is not included in this amount.';

comment on column SET_FCAS_RECOVERY.LOWER6SEC_RECOVERY_GEN is
    'Recovery amount for the Lower 6 Second service attributable to generator connection points. NULL for Settlement dates post the IESS rule effective date';

comment on column SET_FCAS_RECOVERY.RAISE6SEC_RECOVERY_GEN is
    'Recovery amount for the Raise 6 Second service attributable to generator connection points. NULL for Settlement dates post the IESS rule effective date';

comment on column SET_FCAS_RECOVERY.LOWER60SEC_RECOVERY_GEN is
    'Recovery amount for the Lower 60 Second service attributable to generator connection points. NULL for Settlement dates post the IESS rule effective date';

comment on column SET_FCAS_RECOVERY.RAISE60SEC_RECOVERY_GEN is
    'Recovery amount for the Raise 60 Second service attributable to generator connection points. NULL for Settlement dates post the IESS rule effective date';

comment on column SET_FCAS_RECOVERY.LOWER5MIN_RECOVERY_GEN is
    'Recovery amount for the Lower 5 Minute service attributable to generator connection points. NULL for Settlement dates post the IESS rule effective date';

comment on column SET_FCAS_RECOVERY.RAISE5MIN_RECOVERY_GEN is
    'Recovery amount for the Raise 5 Minute service attributable to generator connection points. NULL for Settlement dates post the IESS rule effective date';

comment on column SET_FCAS_RECOVERY.LOWERREG_RECOVERY_GEN is
    'For Settlement date prior to the IESS rule effective date, the column represent Sum of MPF Lower Regulation recovery amount from Generator Connection Points. NULL for Settlement dates post the IESS rule effective date.';

comment on column SET_FCAS_RECOVERY.RAISEREG_RECOVERY_GEN is
    'For Settlement date prior to the IESS rule effective date, the column represent Sum of MPF Raise Regulation recovery amount from Generator Connection Points. NULL for Settlement dates post the IESS rule effective date.';

comment on column SET_FCAS_RECOVERY.RAISE1SEC_RECOVERY is
    'Customer recovery amount for the very fast raise service. NULL for Settlement dates post the IESS rule effective date';

comment on column SET_FCAS_RECOVERY.LOWER1SEC_RECOVERY is
    'Customer recovery amount for the very fast lower service. NULL for Settlement dates post the IESS rule effective date';

comment on column SET_FCAS_RECOVERY.RAISE1SEC_RECOVERY_GEN is
    'Generator recovery amount for the very fast raise service. NULL for Settlement dates post the IESS rule effective date';

comment on column SET_FCAS_RECOVERY.LOWER1SEC_RECOVERY_GEN is
    'Generator recovery amount for the very fast lower service. NULL for Settlement dates post the IESS rule effective date';

alter table SET_NMAS_RECOVERY add PARTICIPANT_ACE_MWH NUMERIC(18,8);

comment on column SET_NMAS_RECOVERY.PARTICIPANT_ACE_MWH is
    'The ACE MWh value for the Participant used in the Recovery Amount Calculation. NULL Value for Settlement Dates prior to the IESS rule effective date.';

alter table SET_NMAS_RECOVERY add REGION_ACE_MWH NUMERIC(18,8);

comment on column SET_NMAS_RECOVERY.REGION_ACE_MWH is
    'The Regional ACE MWh value used in the Recovery Amount Calculation. NULL Value for Settlement Dates prior to the IESS rule effective date.';

alter table SET_NMAS_RECOVERY add PARTICIPANT_ASOE_MWH NUMERIC(18,8);

comment on column SET_NMAS_RECOVERY.PARTICIPANT_ASOE_MWH is
    'The ASOE MWh value for the Participant used in the Recovery Amount Calculation. NULL Value for Settlement Dates prior to the IESS rule effective date.';

alter table SET_NMAS_RECOVERY add REGION_ASOE_MWH NUMERIC(18,8);

comment on column SET_NMAS_RECOVERY.REGION_ASOE_MWH is
    'The Regional ASOE MWh value used in the Recovery Amount Calculation. NULL Value for Settlement Dates prior to the IESS rule effective date.';

alter table SET_NMAS_RECOVERY add RECOVERYAMOUNT_ACE NUMERIC(18,8);

comment on column SET_NMAS_RECOVERY.RECOVERYAMOUNT_ACE is
    'The Recovery dollar amount for the Participant for the NMAS Contract Id calculated using the ACE MWh values for eligible services. NULL Value for Settlement Dates prior to the IESS rule effective date.';

alter table SET_NMAS_RECOVERY add RECOVERYAMOUNT_ASOE NUMERIC(18,8);

comment on column SET_NMAS_RECOVERY.RECOVERYAMOUNT_ASOE is
    'The Recovery dollar amount for the Participant for the NMAS Contract Id calculated using the ASOE_MWh values for eligible services. NULL Value for Settlement Dates prior to the IESS rule effective date.';

comment on column SET_NMAS_RECOVERY.PARTICIPANT_ENERGY is
    'The Participant energy in MWh for the period. NULL Value for Settlement Dates post IESS rule effective date.';

comment on column SET_NMAS_RECOVERY.REGION_ENERGY is
    'The RegionId energy in MWh for the period. NULL Value for Settlement Dates post IESS rule effective date.';

comment on column SET_NMAS_RECOVERY.RECOVERY_AMOUNT is
    'The Total recovery amount for the period for the PARTICIPANTID and REGIONID. For Settlement dates prior to the IESS rule effective date Sum of RECOVERY_AMOUNT_CUSTOMER + RECOVERY_AMOUNT_GENERATOR and Post IESS it is sum of RECOVERYAMOUNT_ACE + RECOVERYAMOUNT_ASOE.';

comment on column SET_NMAS_RECOVERY.PARTICIPANT_GENERATION is
    'Participant Generator Energy in the benefitting region. NULL Value for Settlement Dates post IESS rule effective date.';

comment on column SET_NMAS_RECOVERY.REGION_GENERATION is
    'The generator energy in the benefitting region. NULL Value for Settlement Dates post IESS rule effective date.';

comment on column SET_NMAS_RECOVERY.RECOVERY_AMOUNT_CUSTOMER is
    'The recovery amount allocated to customers. NULL Value for Settlement Dates post IESS rule effective date.';

comment on column SET_NMAS_RECOVERY.RECOVERY_AMOUNT_GENERATOR is
    'The recovery amount allocated to generators. NULL Value for Settlement Dates post IESS rule effective date.';

alter table SET_RECOVERY_ENERGY add ACE_MWH_ACTUAL NUMERIC(18,8);

comment on column SET_RECOVERY_ENERGY.ACE_MWH_ACTUAL is
    'Actual ACE MWh Value for the Recovery Calculation. NULL Value for Settlement date prior to the IESS rule effective date';

alter table SET_RECOVERY_ENERGY add ACE_MWH_MPFEX_ACTUAL NUMERIC(18,8);

comment on column SET_RECOVERY_ENERGY.ACE_MWH_MPFEX_ACTUAL is
    'The Actual ACE MWh Value excluding the MPF Connection Points for the Recovery Calculation. This is used only in FCAS Residue Recovery Calculation. NULL Value for Settlement date prior to the IESS rule effective date.';

alter table SET_RECOVERY_ENERGY add ACE_MWH_SUBSTITUTE NUMERIC(18,8);

comment on column SET_RECOVERY_ENERGY.ACE_MWH_SUBSTITUTE is
    'The Substitute ACE MWh Value for the Recovery Calculation. There is no substitute demand post IESS Rule Change. Hence this column will have same value as ACE_MWh_Actual. NULL Value for Settlement date prior to the IESS rule effective date.';

alter table SET_RECOVERY_ENERGY add ACE_MWH_MPFEX_SUBSTITUTE NUMERIC(18,8);

comment on column SET_RECOVERY_ENERGY.ACE_MWH_MPFEX_SUBSTITUTE is
    'The Substitute ACE MWh Value excluding the MPF Connection Points for the Recovery Calculation. This is used only in FCAS Residue Recovery Calculation. There is no substitute demand post IESS Rule Change. Hence this column will have same value as ACE_MWh_MPFExActual. NULL Value for Settlement date prior to the IESS rule effective date.';

alter table SET_RECOVERY_ENERGY add ASOE_MWH_ACTUAL NUMERIC(18,8);

comment on column SET_RECOVERY_ENERGY.ASOE_MWH_ACTUAL is
    'The Actual ASOE MWh Value for the Recovery Calculation. NULL Value for Settlement date prior to the IESS rule effective date.';

alter table SET_RECOVERY_ENERGY add REGION_ACE_MWH_ACTUAL NUMERIC(18,8);

comment on column SET_RECOVERY_ENERGY.REGION_ACE_MWH_ACTUAL is
    'The Region total of Actual ACE MWh Value. NULL Value for Settlement date prior to the IESS rule effective date.';

alter table SET_RECOVERY_ENERGY add REGION_ACE_MWH_MPFEX_ACTUAL NUMERIC(18,8);

comment on column SET_RECOVERY_ENERGY.REGION_ACE_MWH_MPFEX_ACTUAL is
    'The Region total of Actual ACE MWh Value excluding the MPF Connection Points. NULL Value for Settlement date prior to the IESS rule effective date.';

alter table SET_RECOVERY_ENERGY add REGION_ACE_MWH_SUBST NUMERIC(18,8);

comment on column SET_RECOVERY_ENERGY.REGION_ACE_MWH_SUBST is
    'The Region total of Substitute ACE MWh Value. NULL Value for Settlement date prior to the IESS rule effective date.';

alter table SET_RECOVERY_ENERGY add REGION_ACE_MWH_MPFEX_SUBST NUMERIC(18,8);

comment on column SET_RECOVERY_ENERGY.REGION_ACE_MWH_MPFEX_SUBST is
    'The Region total of Substitute ACE MWh Value excluding the MPF Connection Points . NULL Value for Settlement date prior to the IESS rule effective date.';

alter table SET_RECOVERY_ENERGY add REGION_ASOE_MWH_ACTUAL NUMERIC(18,8);

comment on column SET_RECOVERY_ENERGY.REGION_ASOE_MWH_ACTUAL is
    'The Region total of Actual ASOE MWh Value. NULL Value for Settlement date prior to the IESS rule effective date.';

comment on column SET_RECOVERY_ENERGY.CUSTOMERENERGYACTUAL is
    'Actual Customer Demand. NULL for Settlement dates post the IESS rule effective date.';

comment on column SET_RECOVERY_ENERGY.CUSTOMERENERGYMPFEXACTUAL is
    'Actual Customer Demand excluding TNIs that have a causer pays MPF. NULL for Settlement dates post the IESS rule effective date.';

comment on column SET_RECOVERY_ENERGY.CUSTOMERENERGYSUBSTITUTE is
    'Substitute Customer Demand. NULL for Settlement dates post the IESS rule effective date.';

comment on column SET_RECOVERY_ENERGY.CUSTOMERENERGYMPFEXSUBSTITUTE is
    'Substitute Customer Demand excluding TNIs that have a causer pays MPF. NULL for Settlement dates post the IESS rule effective date.';

comment on column SET_RECOVERY_ENERGY.GENERATORENERGYACTUAL is
    'Actual Generator Output. NULL for Settlement dates post the IESS rule effective date.';

comment on column SET_RECOVERY_ENERGY.REGIONCUSTENERGYACTUAL is
    'Region Total of Actual Customer Demand. NULL for Settlement dates post the IESS rule effective date.';

comment on column SET_RECOVERY_ENERGY.REGIONCUSTENERGYMPFEXACTUAL is
    'Region Total of Actual Customer Demand excluding TNIs that have a causer pays MPF. NULL for Settlement dates post the IESS rule effective date.';

comment on column SET_RECOVERY_ENERGY.REGIONCUSTENERGYSUBST is
    'Region Total of Substitute Customer Demand. NULL for Settlement dates post the IESS rule effective date.';

comment on column SET_RECOVERY_ENERGY.REGIONCUSTENERGYMPFEXSUBST is
    'Region total of Substitute Customer Demand excluding TNIs that have a causer pays MPF. NULL for Settlement dates post the IESS rule effective date.';

comment on column SET_RECOVERY_ENERGY.REGIONGENENERGYACTUAL is
    'Region Total of Actual Generator Output. NULL for Settlement dates post the IESS rule effective date.';

comment on column STPASA_REGIONSOLUTION.AGGREGATEPASAAVAILABILITY is
    'Sum of PASAAVAILABILITY for all scheduled generating units and the Unconstrained Intermittent Generation Forecasts (UIGF) for all semi-scheduled generating units in a given Region for a given PERIODID.
    For the RELIABILITY_LRC and OUTAGE_LRC runs, UIGF is the POE90 forecast. For the LOR run, UIGF is the POE50 forecast.';

comment on column STPASA_REGIONSOLUTION.SEMISCHEDULEDCAPACITY is
    'Constrained generation forecast for semi-scheduled units for the region. For RELIABILITY_LRC run semi-scheduled generation is constrained only by System Normal constraints. For OUTAGE_LRC run and LOR run semi-scheduled generation is constrained by both System Normal and Outage constraints. All three run types (RELIABILITY_LRC, OUTAGE_LRC, LOR) incorporate MAXAVAIL limits.';

comment on column STPASA_REGIONSOLUTION.LOR_SEMISCHEDULEDCAPACITY is
    'Constrained generation forecast for semi-scheduled units for the region for the LOR run type. Semi-scheduled generation is constrained by both System Normal and Outage constraints, and incorporate MAXAVAIL limits.';

comment on column TRANSMISSIONLOSSFACTOR.TRANSMISSIONLOSSFACTOR is
    'Used in Bidding, Dispatch and Settlements. For Bidding and Dispatch, where the DUID is a BDU with DISPATCHTYPE of BIDIRECTIONAL, the TLF for the load component of the BDU. For Settlements, where dual TLFs apply, the primary TLF is applied to all energy (load and generation) when the Net Energy Flow of the ConnectionPointID in the interval is negative (net load).';

comment on column TRANSMISSIONLOSSFACTOR.REGIONID is
    'Region Identifier';

comment on column TRANSMISSIONLOSSFACTOR.SECONDARY_TLF is
    'Used in Bidding, Dispatch and Settlements, only populated where Dual TLFs apply. For Bidding and Dispatch, the TLF for the generation component of a BDU, when null the TRANSMISSIONLOSSFACTOR is used for both the load and generation components. For Settlements, the secondary TLF is applied to all energy (load and generation) when the Net Energy Flow of the ConnectionPointID in the interval is positive (net generation).';

