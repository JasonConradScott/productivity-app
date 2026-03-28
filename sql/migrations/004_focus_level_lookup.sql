/*
  Migration: Shared focus level — dbo.FocusLevel_lkp (lookup suffix _lkp) + optional FK from dbo.InboxItem.
  IDs: 1 Unknown, 2 Light, 3 Moderate, 4 Deep, 5 High, 6 Peak.
  Safe to run multiple times (idempotent). See RULES.md §8 (SQL script safety).
*/
SET NOCOUNT ON;

IF OBJECT_ID(N'dbo.FocusLevel_lkp', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.FocusLevel_lkp (
    FocusLevelId TINYINT NOT NULL,
    Label VARCHAR(32) NOT NULL,
    Meaning VARCHAR(500) NOT NULL,
    CONSTRAINT PK_FocusLevel_lkp PRIMARY KEY (FocusLevelId)
  );
END
GO

IF OBJECT_ID(N'dbo.FocusLevel_lkp', N'U') IS NOT NULL
BEGIN
  IF NOT EXISTS (SELECT 1 FROM dbo.FocusLevel_lkp WHERE FocusLevelId = 1)
    INSERT INTO dbo.FocusLevel_lkp (FocusLevelId, Label, Meaning)
    VALUES (1, 'Unknown', 'Not yet assessed; treat as needs a rating when scheduling.');

  IF NOT EXISTS (SELECT 1 FROM dbo.FocusLevel_lkp WHERE FocusLevelId = 2)
    INSERT INTO dbo.FocusLevel_lkp (FocusLevelId, Label, Meaning)
    VALUES (2, 'Light', 'Trivial or habitual; little sustained attention.');

  IF NOT EXISTS (SELECT 1 FROM dbo.FocusLevel_lkp WHERE FocusLevelId = 3)
    INSERT INTO dbo.FocusLevel_lkp (FocusLevelId, Label, Meaning)
    VALUES (3, 'Moderate', 'Normal focused work; some interruption tolerance.');

  IF NOT EXISTS (SELECT 1 FROM dbo.FocusLevel_lkp WHERE FocusLevelId = 4)
    INSERT INTO dbo.FocusLevel_lkp (FocusLevelId, Label, Meaning)
    VALUES (4, 'Deep', 'Long uninterrupted blocks; context costly to rebuild.');

  IF NOT EXISTS (SELECT 1 FROM dbo.FocusLevel_lkp WHERE FocusLevelId = 5)
    INSERT INTO dbo.FocusLevel_lkp (FocusLevelId, Label, Meaning)
    VALUES (5, 'High', 'Heavy concentration; minimize switching and noise.');

  IF NOT EXISTS (SELECT 1 FROM dbo.FocusLevel_lkp WHERE FocusLevelId = 6)
    INSERT INTO dbo.FocusLevel_lkp (FocusLevelId, Label, Meaning)
    VALUES (6, 'Peak', 'Hardest cognitive load; protect with strict boundaries.');
END
GO

IF OBJECT_ID(N'dbo.InboxItem', N'U') IS NOT NULL
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.InboxItem') AND name = N'FocusLevelId'
  )
    ALTER TABLE dbo.InboxItem ADD FocusLevelId TINYINT NULL;

  IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_InboxItem_FocusLevel_lkp'
      AND parent_object_id = OBJECT_ID(N'dbo.InboxItem')
  )
    ALTER TABLE dbo.InboxItem ADD CONSTRAINT FK_InboxItem_FocusLevel_lkp
      FOREIGN KEY (FocusLevelId) REFERENCES dbo.FocusLevel_lkp (FocusLevelId);

  IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_InboxItem_FocusLevelId' AND object_id = OBJECT_ID(N'dbo.InboxItem')
  )
    CREATE INDEX IX_InboxItem_FocusLevelId ON dbo.InboxItem (FocusLevelId);
END
GO
