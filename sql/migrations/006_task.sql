/*
  Migration: dbo.Task — mirrors inbox item attributes (Body, StatusId, TimeSensitivityId, FocusLevelId).
  AppUserId scopes the row (single-user: default 1; requires dbo.AppUser from 005_user.sql).
  StatusId FK to dbo.Status_lkp (_lkp lookup); allowed status IDs 1–7 (inbox triage + task lifecycle rows).
  Safe to run multiple times (idempotent). See RULES.md §8 (SQL script safety).
*/
SET NOCOUNT ON;

IF OBJECT_ID(N'dbo.Task', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.Task (
    TaskId BIGINT IDENTITY(1,1) NOT NULL,
    AppUserId BIGINT NOT NULL CONSTRAINT DF_Task_AppUserId DEFAULT (1),
    Body VARCHAR(MAX) NOT NULL,
    StatusId TINYINT NOT NULL CONSTRAINT DF_Task_StatusId DEFAULT (1),
    TimeSensitivityId TINYINT NULL,
    FocusLevelId TINYINT NULL,
    CONSTRAINT PK_Task PRIMARY KEY (TaskId),
    CONSTRAINT FK_Task_AppUser FOREIGN KEY (AppUserId) REFERENCES dbo.AppUser (AppUserId)
  );
END
GO

IF OBJECT_ID(N'dbo.Task', N'U') IS NOT NULL
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.Task') AND name = N'AppUserId'
  )
    ALTER TABLE dbo.Task ADD AppUserId BIGINT NOT NULL CONSTRAINT DF_Task_AppUserId DEFAULT (1);

  IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_Task_AppUser' AND parent_object_id = OBJECT_ID(N'dbo.Task')
  )
    AND OBJECT_ID(N'dbo.AppUser', N'U') IS NOT NULL
    ALTER TABLE dbo.Task ADD CONSTRAINT FK_Task_AppUser
      FOREIGN KEY (AppUserId) REFERENCES dbo.AppUser (AppUserId);

  IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_Task_Status_lkp' AND parent_object_id = OBJECT_ID(N'dbo.Task')
  )
    ALTER TABLE dbo.Task ADD CONSTRAINT FK_Task_Status_lkp
      FOREIGN KEY (StatusId) REFERENCES dbo.Status_lkp (StatusId);

  IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_Task_TimeSensitivity_lkp' AND parent_object_id = OBJECT_ID(N'dbo.Task')
  )
    ALTER TABLE dbo.Task ADD CONSTRAINT FK_Task_TimeSensitivity_lkp
      FOREIGN KEY (TimeSensitivityId) REFERENCES dbo.TimeSensitivity_lkp (TimeSensitivityId);

  IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_Task_FocusLevel_lkp' AND parent_object_id = OBJECT_ID(N'dbo.Task')
  )
    ALTER TABLE dbo.Task ADD CONSTRAINT FK_Task_FocusLevel_lkp
      FOREIGN KEY (FocusLevelId) REFERENCES dbo.FocusLevel_lkp (FocusLevelId);

  IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = N'CK_Task_Status_Allowed' AND parent_object_id = OBJECT_ID(N'dbo.Task')
  )
    ALTER TABLE dbo.Task ADD CONSTRAINT CK_Task_Status_Allowed
      CHECK (StatusId IN (1, 2, 3, 4, 5, 6, 7));

  IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_Task_AppUserId' AND object_id = OBJECT_ID(N'dbo.Task')
  )
    CREATE INDEX IX_Task_AppUserId ON dbo.Task (AppUserId);

  IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_Task_StatusId' AND object_id = OBJECT_ID(N'dbo.Task')
  )
    CREATE INDEX IX_Task_StatusId ON dbo.Task (StatusId);

  IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_Task_TimeSensitivityId' AND object_id = OBJECT_ID(N'dbo.Task')
  )
    CREATE INDEX IX_Task_TimeSensitivityId ON dbo.Task (TimeSensitivityId);

  IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_Task_FocusLevelId' AND object_id = OBJECT_ID(N'dbo.Task')
  )
    CREATE INDEX IX_Task_FocusLevelId ON dbo.Task (FocusLevelId);
END
GO
