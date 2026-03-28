/*
  Migration: Shared time sensitivity — dbo.TimeSensitivity_lkp (lookup suffix _lkp) + optional FK from dbo.InboxItem.
  IDs (urgency high to low): 1 Now, 2 Critical, 3 High, 4 Medium, 5 Low, 6 VeryLow, 7 Whenever.
  Legacy: if dbo.InboxItemTimeSensitivity exists, data is moved here and the old table is dropped.
  Safe to run multiple times (idempotent). See RULES.md §8 (SQL script safety).
*/
SET NOCOUNT ON;

IF OBJECT_ID(N'dbo.InboxItemTimeSensitivity', N'U') IS NOT NULL
BEGIN
  IF OBJECT_ID(N'dbo.TimeSensitivity_lkp', N'U') IS NULL
  BEGIN
    CREATE TABLE dbo.TimeSensitivity_lkp (
      TimeSensitivityId TINYINT NOT NULL,
      Label VARCHAR(32) NOT NULL,
      Meaning VARCHAR(500) NOT NULL,
      CONSTRAINT PK_TimeSensitivity_lkp PRIMARY KEY (TimeSensitivityId)
    );
    INSERT INTO dbo.TimeSensitivity_lkp (TimeSensitivityId, Label, Meaning)
    SELECT InboxItemTimeSensitivityId, Label, Meaning FROM dbo.InboxItemTimeSensitivity;
  END
  ELSE IF NOT EXISTS (SELECT 1 FROM dbo.TimeSensitivity_lkp)
    INSERT INTO dbo.TimeSensitivity_lkp (TimeSensitivityId, Label, Meaning)
    SELECT InboxItemTimeSensitivityId, Label, Meaning FROM dbo.InboxItemTimeSensitivity;

  IF EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_InboxItem_InboxItemTimeSensitivity'
      AND parent_object_id = OBJECT_ID(N'dbo.InboxItem')
  )
    ALTER TABLE dbo.InboxItem DROP CONSTRAINT FK_InboxItem_InboxItemTimeSensitivity;

  DROP TABLE dbo.InboxItemTimeSensitivity;
END
GO

IF OBJECT_ID(N'dbo.TimeSensitivity_lkp', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.TimeSensitivity_lkp (
    TimeSensitivityId TINYINT NOT NULL,
    Label VARCHAR(32) NOT NULL,
    Meaning VARCHAR(500) NOT NULL,
    CONSTRAINT PK_TimeSensitivity_lkp PRIMARY KEY (TimeSensitivityId)
  );
END
GO

IF OBJECT_ID(N'dbo.TimeSensitivity_lkp', N'U') IS NOT NULL
BEGIN
  IF NOT EXISTS (SELECT 1 FROM dbo.TimeSensitivity_lkp WHERE TimeSensitivityId = 1)
    INSERT INTO dbo.TimeSensitivity_lkp (TimeSensitivityId, Label, Meaning)
    VALUES (1, 'Now', 'Act on this immediately; blocking or same-day required.');

  IF NOT EXISTS (SELECT 1 FROM dbo.TimeSensitivity_lkp WHERE TimeSensitivityId = 2)
    INSERT INTO dbo.TimeSensitivity_lkp (TimeSensitivityId, Label, Meaning)
    VALUES (2, 'Critical', 'Severe impact if missed; top priority after immediate items.');

  IF NOT EXISTS (SELECT 1 FROM dbo.TimeSensitivity_lkp WHERE TimeSensitivityId = 3)
    INSERT INTO dbo.TimeSensitivity_lkp (TimeSensitivityId, Label, Meaning)
    VALUES (3, 'High', 'Important deadline or dependency; address soon.');

  IF NOT EXISTS (SELECT 1 FROM dbo.TimeSensitivity_lkp WHERE TimeSensitivityId = 4)
    INSERT INTO dbo.TimeSensitivity_lkp (TimeSensitivityId, Label, Meaning)
    VALUES (4, 'Medium', 'Normal priority; fit into the usual workflow.');

  IF NOT EXISTS (SELECT 1 FROM dbo.TimeSensitivity_lkp WHERE TimeSensitivityId = 5)
    INSERT INTO dbo.TimeSensitivity_lkp (TimeSensitivityId, Label, Meaning)
    VALUES (5, 'Low', 'Nice to have soon; defer if higher priorities appear.');

  IF NOT EXISTS (SELECT 1 FROM dbo.TimeSensitivity_lkp WHERE TimeSensitivityId = 6)
    INSERT INTO dbo.TimeSensitivity_lkp (TimeSensitivityId, Label, Meaning)
    VALUES (6, 'VeryLow', 'No meaningful deadline; handle when convenient.');

  IF NOT EXISTS (SELECT 1 FROM dbo.TimeSensitivity_lkp WHERE TimeSensitivityId = 7)
    INSERT INTO dbo.TimeSensitivity_lkp (TimeSensitivityId, Label, Meaning)
    VALUES (7, 'Whenever', 'No time pressure; backlog or someday-maybe.');
END
GO

IF OBJECT_ID(N'dbo.InboxItem', N'U') IS NOT NULL
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.InboxItem') AND name = N'TimeSensitivityId'
  )
    ALTER TABLE dbo.InboxItem ADD TimeSensitivityId TINYINT NULL;

  IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_InboxItem_TimeSensitivity_lkp'
      AND parent_object_id = OBJECT_ID(N'dbo.InboxItem')
  )
    ALTER TABLE dbo.InboxItem ADD CONSTRAINT FK_InboxItem_TimeSensitivity_lkp
      FOREIGN KEY (TimeSensitivityId) REFERENCES dbo.TimeSensitivity_lkp (TimeSensitivityId);

  IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_InboxItem_TimeSensitivityId' AND object_id = OBJECT_ID(N'dbo.InboxItem')
  )
    CREATE INDEX IX_InboxItem_TimeSensitivityId ON dbo.InboxItem (TimeSensitivityId);
END
GO
