/*
  Migration: Rename dbo.InboxItem.Status and dbo.Task.Status to StatusId (clearer FK intent).
  Drops FK/CHECK/default, then sp_rename in one batch; re-adds default/FK/CHECK in later batches
  (SQL Server parses a whole batch before execute, so new column name cannot appear in same batch as sp_rename).
  Renames indexes in separate batches. Idempotent. See RULES.md §8 (SQL script safety).
*/
SET NOCOUNT ON;

IF EXISTS (
  SELECT 1
  FROM sys.columns c
  INNER JOIN sys.tables t ON c.object_id = t.object_id
  INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
  WHERE s.name = N'dbo' AND t.name = N'InboxItem' AND c.name = N'Status'
)
BEGIN
  IF EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_InboxItem_Status_lkp'
      AND parent_object_id = OBJECT_ID(N'dbo.InboxItem')
  )
    ALTER TABLE dbo.InboxItem DROP CONSTRAINT FK_InboxItem_Status_lkp;

  IF EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_InboxItem_StatusLookup'
      AND parent_object_id = OBJECT_ID(N'dbo.InboxItem')
  )
    ALTER TABLE dbo.InboxItem DROP CONSTRAINT FK_InboxItem_StatusLookup;

  IF EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_InboxItem_InboxItemTriageStatus'
      AND parent_object_id = OBJECT_ID(N'dbo.InboxItem')
  )
    ALTER TABLE dbo.InboxItem DROP CONSTRAINT FK_InboxItem_InboxItemTriageStatus;

  IF EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = N'CK_InboxItem_Status_InboxTriage'
      AND parent_object_id = OBJECT_ID(N'dbo.InboxItem')
  )
    ALTER TABLE dbo.InboxItem DROP CONSTRAINT CK_InboxItem_Status_InboxTriage;

  IF OBJECT_ID(N'dbo.DF_InboxItem_Status', N'D') IS NOT NULL
    ALTER TABLE dbo.InboxItem DROP CONSTRAINT DF_InboxItem_Status;

  EXEC sys.sp_rename N'dbo.InboxItem.Status', N'StatusId', N'COLUMN';
END
GO

IF EXISTS (
  SELECT 1
  FROM sys.columns c
  INNER JOIN sys.tables t ON c.object_id = t.object_id
  INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
  WHERE s.name = N'dbo' AND t.name = N'InboxItem' AND c.name = N'StatusId'
)
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM sys.default_constraints
    WHERE name = N'DF_InboxItem_StatusId' AND parent_object_id = OBJECT_ID(N'dbo.InboxItem')
  )
    ALTER TABLE dbo.InboxItem ADD CONSTRAINT DF_InboxItem_StatusId DEFAULT (1) FOR StatusId;

  IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_InboxItem_Status_lkp'
      AND parent_object_id = OBJECT_ID(N'dbo.InboxItem')
  )
    AND OBJECT_ID(N'dbo.Status_lkp', N'U') IS NOT NULL
    ALTER TABLE dbo.InboxItem ADD CONSTRAINT FK_InboxItem_Status_lkp
      FOREIGN KEY (StatusId) REFERENCES dbo.Status_lkp (StatusId);

  IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = N'CK_InboxItem_Status_InboxTriage'
      AND parent_object_id = OBJECT_ID(N'dbo.InboxItem')
  )
    ALTER TABLE dbo.InboxItem ADD CONSTRAINT CK_InboxItem_Status_InboxTriage
      CHECK (StatusId IN (1, 2, 3));

  IF EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_InboxItem_Status' AND object_id = OBJECT_ID(N'dbo.InboxItem')
  )
    EXEC sys.sp_rename N'dbo.InboxItem.IX_InboxItem_Status', N'IX_InboxItem_StatusId', N'INDEX';
END
GO

IF EXISTS (
  SELECT 1
  FROM sys.columns c
  INNER JOIN sys.tables t ON c.object_id = t.object_id
  INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
  WHERE s.name = N'dbo' AND t.name = N'Task' AND c.name = N'Status'
)
BEGIN
  IF EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_Task_Status_lkp'
      AND parent_object_id = OBJECT_ID(N'dbo.Task')
  )
    ALTER TABLE dbo.Task DROP CONSTRAINT FK_Task_Status_lkp;

  IF EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_Task_StatusLookup'
      AND parent_object_id = OBJECT_ID(N'dbo.Task')
  )
    ALTER TABLE dbo.Task DROP CONSTRAINT FK_Task_StatusLookup;

  IF EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = N'CK_Task_Status_Allowed'
      AND parent_object_id = OBJECT_ID(N'dbo.Task')
  )
    ALTER TABLE dbo.Task DROP CONSTRAINT CK_Task_Status_Allowed;

  IF OBJECT_ID(N'dbo.DF_Task_Status', N'D') IS NOT NULL
    ALTER TABLE dbo.Task DROP CONSTRAINT DF_Task_Status;

  EXEC sys.sp_rename N'dbo.Task.Status', N'StatusId', N'COLUMN';
END
GO

IF EXISTS (
  SELECT 1
  FROM sys.columns c
  INNER JOIN sys.tables t ON c.object_id = t.object_id
  INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
  WHERE s.name = N'dbo' AND t.name = N'Task' AND c.name = N'StatusId'
)
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM sys.default_constraints
    WHERE name = N'DF_Task_StatusId' AND parent_object_id = OBJECT_ID(N'dbo.Task')
  )
    ALTER TABLE dbo.Task ADD CONSTRAINT DF_Task_StatusId DEFAULT (1) FOR StatusId;

  IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_Task_Status_lkp'
      AND parent_object_id = OBJECT_ID(N'dbo.Task')
  )
    AND OBJECT_ID(N'dbo.Status_lkp', N'U') IS NOT NULL
    ALTER TABLE dbo.Task ADD CONSTRAINT FK_Task_Status_lkp
      FOREIGN KEY (StatusId) REFERENCES dbo.Status_lkp (StatusId);

  IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = N'CK_Task_Status_Allowed'
      AND parent_object_id = OBJECT_ID(N'dbo.Task')
  )
    ALTER TABLE dbo.Task ADD CONSTRAINT CK_Task_Status_Allowed
      CHECK (StatusId IN (1, 2, 3, 4, 5, 6, 7));

  IF EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_Task_Status' AND object_id = OBJECT_ID(N'dbo.Task')
  )
    EXEC sys.sp_rename N'dbo.Task.IX_Task_Status', N'IX_Task_StatusId', N'INDEX';
END
GO
