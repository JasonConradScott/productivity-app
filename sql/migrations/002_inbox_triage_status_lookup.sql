/*
  Migration: Inbox item triage status lookup — dbo.InboxItemTriageStatus + FK from dbo.InboxItem.Status.
  IDs: 1 Open, 2 Triaged, 3 Archived (matches prior CK_InboxItem_Status).
  Safe to run multiple times (idempotent). See RULES.md §8 (SQL script safety).
*/
SET NOCOUNT ON;

IF OBJECT_ID(N'dbo.InboxItemTriageStatus', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.InboxItemTriageStatus (
    InboxItemTriageStatusId TINYINT NOT NULL,
    Label VARCHAR(64) NOT NULL,
    Meaning VARCHAR(500) NOT NULL,
    CONSTRAINT PK_InboxItemTriageStatus PRIMARY KEY (InboxItemTriageStatusId)
  );
END
GO

IF OBJECT_ID(N'dbo.InboxItemTriageStatus', N'U') IS NOT NULL
BEGIN
  IF NOT EXISTS (SELECT 1 FROM dbo.InboxItemTriageStatus WHERE InboxItemTriageStatusId = 1)
    INSERT INTO dbo.InboxItemTriageStatus (InboxItemTriageStatusId, Label, Meaning)
    VALUES (1, 'Open', 'New capture; not yet reviewed or filed.');

  IF NOT EXISTS (SELECT 1 FROM dbo.InboxItemTriageStatus WHERE InboxItemTriageStatusId = 2)
    INSERT INTO dbo.InboxItemTriageStatus (InboxItemTriageStatusId, Label, Meaning)
    VALUES (2, 'Triaged', 'Reviewed; next action is known or in progress.');

  IF NOT EXISTS (SELECT 1 FROM dbo.InboxItemTriageStatus WHERE InboxItemTriageStatusId = 3)
    INSERT INTO dbo.InboxItemTriageStatus (InboxItemTriageStatusId, Label, Meaning)
    VALUES (3, 'Archived', 'No longer active in the inbox; kept for history.');
END
GO

IF OBJECT_ID(N'dbo.InboxItem', N'U') IS NOT NULL
BEGIN
  IF EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = N'CK_InboxItem_Status'
      AND parent_object_id = OBJECT_ID(N'dbo.InboxItem')
  )
    ALTER TABLE dbo.InboxItem DROP CONSTRAINT CK_InboxItem_Status;

  IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_InboxItem_InboxItemTriageStatus'
      AND parent_object_id = OBJECT_ID(N'dbo.InboxItem')
  )
    ALTER TABLE dbo.InboxItem ADD CONSTRAINT FK_InboxItem_InboxItemTriageStatus
      FOREIGN KEY (Status) REFERENCES dbo.InboxItemTriageStatus (InboxItemTriageStatusId);
END
GO
