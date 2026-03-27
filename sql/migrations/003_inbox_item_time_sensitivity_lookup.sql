/*
  Migration: Inbox item time sensitivity — dbo.InboxItemTimeSensitivity + optional FK from dbo.InboxItem.
  IDs (urgency high to low): 1 Now, 2 Critical, 3 High, 4 Medium, 5 Low, 6 VeryLow, 7 Whenever.
  Safe to run multiple times (idempotent). See RULES.md §8 (SQL script safety).
*/
SET NOCOUNT ON;

IF OBJECT_ID(N'dbo.InboxItemTimeSensitivity', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.InboxItemTimeSensitivity (
    InboxItemTimeSensitivityId TINYINT NOT NULL,
    Label VARCHAR(32) NOT NULL,
    Meaning VARCHAR(500) NOT NULL,
    CONSTRAINT PK_InboxItemTimeSensitivity PRIMARY KEY (InboxItemTimeSensitivityId)
  );
END
GO

IF OBJECT_ID(N'dbo.InboxItemTimeSensitivity', N'U') IS NOT NULL
BEGIN
  IF NOT EXISTS (SELECT 1 FROM dbo.InboxItemTimeSensitivity WHERE InboxItemTimeSensitivityId = 1)
    INSERT INTO dbo.InboxItemTimeSensitivity (InboxItemTimeSensitivityId, Label, Meaning)
    VALUES (1, 'Now', 'Act on this immediately; blocking or same-day required.');

  IF NOT EXISTS (SELECT 1 FROM dbo.InboxItemTimeSensitivity WHERE InboxItemTimeSensitivityId = 2)
    INSERT INTO dbo.InboxItemTimeSensitivity (InboxItemTimeSensitivityId, Label, Meaning)
    VALUES (2, 'Critical', 'Severe impact if missed; top priority after immediate items.');

  IF NOT EXISTS (SELECT 1 FROM dbo.InboxItemTimeSensitivity WHERE InboxItemTimeSensitivityId = 3)
    INSERT INTO dbo.InboxItemTimeSensitivity (InboxItemTimeSensitivityId, Label, Meaning)
    VALUES (3, 'High', 'Important deadline or dependency; address soon.');

  IF NOT EXISTS (SELECT 1 FROM dbo.InboxItemTimeSensitivity WHERE InboxItemTimeSensitivityId = 4)
    INSERT INTO dbo.InboxItemTimeSensitivity (InboxItemTimeSensitivityId, Label, Meaning)
    VALUES (4, 'Medium', 'Normal priority; fit into the usual workflow.');

  IF NOT EXISTS (SELECT 1 FROM dbo.InboxItemTimeSensitivity WHERE InboxItemTimeSensitivityId = 5)
    INSERT INTO dbo.InboxItemTimeSensitivity (InboxItemTimeSensitivityId, Label, Meaning)
    VALUES (5, 'Low', 'Nice to have soon; defer if higher priorities appear.');

  IF NOT EXISTS (SELECT 1 FROM dbo.InboxItemTimeSensitivity WHERE InboxItemTimeSensitivityId = 6)
    INSERT INTO dbo.InboxItemTimeSensitivity (InboxItemTimeSensitivityId, Label, Meaning)
    VALUES (6, 'VeryLow', 'No meaningful deadline; handle when convenient.');

  IF NOT EXISTS (SELECT 1 FROM dbo.InboxItemTimeSensitivity WHERE InboxItemTimeSensitivityId = 7)
    INSERT INTO dbo.InboxItemTimeSensitivity (InboxItemTimeSensitivityId, Label, Meaning)
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
    WHERE name = N'FK_InboxItem_InboxItemTimeSensitivity'
      AND parent_object_id = OBJECT_ID(N'dbo.InboxItem')
  )
    ALTER TABLE dbo.InboxItem ADD CONSTRAINT FK_InboxItem_InboxItemTimeSensitivity
      FOREIGN KEY (TimeSensitivityId) REFERENCES dbo.InboxItemTimeSensitivity (InboxItemTimeSensitivityId);

  IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_InboxItem_TimeSensitivityId' AND object_id = OBJECT_ID(N'dbo.InboxItem')
  )
    CREATE INDEX IX_InboxItem_TimeSensitivityId ON dbo.InboxItem (TimeSensitivityId);
END
GO
