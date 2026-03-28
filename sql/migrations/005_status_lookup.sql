/*
  Migration: Generic status — dbo.Status_lkp; migrate from dbo.InboxItemTriageStatus; inbox + task seeds.
  IDs 1–3: inbox triage (Open, Triaged, Archived). IDs 4–7: task lifecycle (InProgress, Done, Cancelled, Blocked).
  InboxItem: FK to Status_lkp + CHECK (StatusId IN (1,2,3)).
  Legacy: if InboxItemTriageStatus exists, data is copied and the old table is dropped.
  Safe to run multiple times (idempotent). See RULES.md §8 (SQL script safety).
*/
SET NOCOUNT ON;

IF OBJECT_ID(N'dbo.InboxItemTriageStatus', N'U') IS NOT NULL
BEGIN
  IF OBJECT_ID(N'dbo.Status_lkp', N'U') IS NULL
  BEGIN
    CREATE TABLE dbo.Status_lkp (
      StatusId TINYINT NOT NULL,
      Label VARCHAR(64) NOT NULL,
      Meaning VARCHAR(500) NOT NULL,
      CONSTRAINT PK_Status_lkp PRIMARY KEY (StatusId)
    );
    INSERT INTO dbo.Status_lkp (StatusId, Label, Meaning)
    SELECT InboxItemTriageStatusId, Label, Meaning FROM dbo.InboxItemTriageStatus;
  END
  ELSE IF NOT EXISTS (SELECT 1 FROM dbo.Status_lkp)
    INSERT INTO dbo.Status_lkp (StatusId, Label, Meaning)
    SELECT InboxItemTriageStatusId, Label, Meaning FROM dbo.InboxItemTriageStatus;

  IF EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_InboxItem_InboxItemTriageStatus'
      AND parent_object_id = OBJECT_ID(N'dbo.InboxItem')
  )
    ALTER TABLE dbo.InboxItem DROP CONSTRAINT FK_InboxItem_InboxItemTriageStatus;

  DROP TABLE dbo.InboxItemTriageStatus;
END
GO

IF OBJECT_ID(N'dbo.Status_lkp', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.Status_lkp (
    StatusId TINYINT NOT NULL,
    Label VARCHAR(64) NOT NULL,
    Meaning VARCHAR(500) NOT NULL,
    CONSTRAINT PK_Status_lkp PRIMARY KEY (StatusId)
  );
END
GO

IF OBJECT_ID(N'dbo.Status_lkp', N'U') IS NOT NULL
BEGIN
  IF NOT EXISTS (SELECT 1 FROM dbo.Status_lkp WHERE StatusId = 1)
    INSERT INTO dbo.Status_lkp (StatusId, Label, Meaning)
    VALUES (1, 'Open', 'New capture; not yet reviewed or filed.');

  IF NOT EXISTS (SELECT 1 FROM dbo.Status_lkp WHERE StatusId = 2)
    INSERT INTO dbo.Status_lkp (StatusId, Label, Meaning)
    VALUES (2, 'Triaged', 'Reviewed; next action is known or in progress.');

  IF NOT EXISTS (SELECT 1 FROM dbo.Status_lkp WHERE StatusId = 3)
    INSERT INTO dbo.Status_lkp (StatusId, Label, Meaning)
    VALUES (3, 'Archived', 'No longer active in the inbox; kept for history.');

  IF NOT EXISTS (SELECT 1 FROM dbo.Status_lkp WHERE StatusId = 4)
    INSERT INTO dbo.Status_lkp (StatusId, Label, Meaning)
    VALUES (4, 'InProgress', 'Actively being worked; primary task in flight.');

  IF NOT EXISTS (SELECT 1 FROM dbo.Status_lkp WHERE StatusId = 5)
    INSERT INTO dbo.Status_lkp (StatusId, Label, Meaning)
    VALUES (5, 'Done', 'Completed successfully; no further work expected.');

  IF NOT EXISTS (SELECT 1 FROM dbo.Status_lkp WHERE StatusId = 6)
    INSERT INTO dbo.Status_lkp (StatusId, Label, Meaning)
    VALUES (6, 'Cancelled', 'Abandoned or no longer pursued.');

  IF NOT EXISTS (SELECT 1 FROM dbo.Status_lkp WHERE StatusId = 7)
    INSERT INTO dbo.Status_lkp (StatusId, Label, Meaning)
    VALUES (7, 'Blocked', 'Cannot proceed until an external dependency clears.');
END
GO

IF OBJECT_ID(N'dbo.InboxItem', N'U') IS NOT NULL
  AND OBJECT_ID(N'dbo.Status_lkp', N'U') IS NOT NULL
BEGIN
  IF EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_InboxItem_InboxItemTriageStatus'
      AND parent_object_id = OBJECT_ID(N'dbo.InboxItem')
  )
    ALTER TABLE dbo.InboxItem DROP CONSTRAINT FK_InboxItem_InboxItemTriageStatus;

  IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_InboxItem_Status_lkp'
      AND parent_object_id = OBJECT_ID(N'dbo.InboxItem')
  )
    ALTER TABLE dbo.InboxItem ADD CONSTRAINT FK_InboxItem_Status_lkp
      FOREIGN KEY (StatusId) REFERENCES dbo.Status_lkp (StatusId);

  IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = N'CK_InboxItem_Status_InboxTriage'
      AND parent_object_id = OBJECT_ID(N'dbo.InboxItem')
  )
    ALTER TABLE dbo.InboxItem ADD CONSTRAINT CK_InboxItem_Status_InboxTriage
      CHECK (StatusId IN (1, 2, 3));
END
GO
