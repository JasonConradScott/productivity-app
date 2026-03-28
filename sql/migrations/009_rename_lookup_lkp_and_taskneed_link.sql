/*
  Migration: Apply table naming convention — *Lookup -> *_lkp, TaskNeed -> TaskNeed_link.
  For databases that still have pre-rename object names. Idempotent. See RULES.md §8.
*/
SET NOCOUNT ON;

IF OBJECT_ID(N'dbo.TaskNeed_link', N'U') IS NULL
  AND OBJECT_ID(N'dbo.TaskNeed', N'U') IS NOT NULL
BEGIN
  IF EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_TaskNeed_Task' AND parent_object_id = OBJECT_ID(N'dbo.TaskNeed')
  )
    ALTER TABLE dbo.TaskNeed DROP CONSTRAINT FK_TaskNeed_Task;

  IF EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_TaskNeed_Need' AND parent_object_id = OBJECT_ID(N'dbo.TaskNeed')
  )
    ALTER TABLE dbo.TaskNeed DROP CONSTRAINT FK_TaskNeed_Need;

  EXEC sys.sp_rename N'dbo.TaskNeed', N'TaskNeed_link', N'OBJECT';
END
GO

IF OBJECT_ID(N'dbo.TaskNeed_link', N'U') IS NOT NULL
BEGIN
  IF EXISTS (
    SELECT 1 FROM sys.key_constraints
    WHERE name = N'PK_TaskNeed' AND parent_object_id = OBJECT_ID(N'dbo.TaskNeed_link')
  )
    EXEC sys.sp_rename N'PK_TaskNeed', N'PK_TaskNeed_link', N'OBJECT';

  IF EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_TaskNeed_NeedId' AND object_id = OBJECT_ID(N'dbo.TaskNeed_link')
  )
    EXEC sys.sp_rename N'dbo.TaskNeed_link.IX_TaskNeed_NeedId', N'IX_TaskNeed_link_NeedId', N'INDEX';

  IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_TaskNeed_link_Task' AND parent_object_id = OBJECT_ID(N'dbo.TaskNeed_link')
  )
    ALTER TABLE dbo.TaskNeed_link ADD CONSTRAINT FK_TaskNeed_link_Task FOREIGN KEY (TaskId)
      REFERENCES dbo.Task (TaskId) ON DELETE CASCADE;

  IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_TaskNeed_link_Need' AND parent_object_id = OBJECT_ID(N'dbo.TaskNeed_link')
  )
    ALTER TABLE dbo.TaskNeed_link ADD CONSTRAINT FK_TaskNeed_link_Need FOREIGN KEY (NeedId)
      REFERENCES dbo.Need (NeedId) ON DELETE CASCADE;
END
GO

IF OBJECT_ID(N'dbo.FocusLevel_lkp', N'U') IS NULL
  AND OBJECT_ID(N'dbo.FocusLevelLookup', N'U') IS NOT NULL
BEGIN
  IF EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_InboxItem_FocusLevelLookup' AND parent_object_id = OBJECT_ID(N'dbo.InboxItem')
  )
    ALTER TABLE dbo.InboxItem DROP CONSTRAINT FK_InboxItem_FocusLevelLookup;

  IF EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_Task_FocusLevelLookup' AND parent_object_id = OBJECT_ID(N'dbo.Task')
  )
    ALTER TABLE dbo.Task DROP CONSTRAINT FK_Task_FocusLevelLookup;

  EXEC sys.sp_rename N'dbo.FocusLevelLookup', N'FocusLevel_lkp', N'OBJECT';
END
GO

IF OBJECT_ID(N'dbo.FocusLevel_lkp', N'U') IS NOT NULL
BEGIN
  IF EXISTS (
    SELECT 1 FROM sys.key_constraints
    WHERE name = N'PK_FocusLevelLookup' AND parent_object_id = OBJECT_ID(N'dbo.FocusLevel_lkp')
  )
    EXEC sys.sp_rename N'PK_FocusLevelLookup', N'PK_FocusLevel_lkp', N'OBJECT';

  IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_InboxItem_FocusLevel_lkp' AND parent_object_id = OBJECT_ID(N'dbo.InboxItem')
  )
    AND OBJECT_ID(N'dbo.InboxItem', N'U') IS NOT NULL
    ALTER TABLE dbo.InboxItem ADD CONSTRAINT FK_InboxItem_FocusLevel_lkp FOREIGN KEY (FocusLevelId)
      REFERENCES dbo.FocusLevel_lkp (FocusLevelId);

  IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_Task_FocusLevel_lkp' AND parent_object_id = OBJECT_ID(N'dbo.Task')
  )
    AND OBJECT_ID(N'dbo.Task', N'U') IS NOT NULL
    ALTER TABLE dbo.Task ADD CONSTRAINT FK_Task_FocusLevel_lkp FOREIGN KEY (FocusLevelId)
      REFERENCES dbo.FocusLevel_lkp (FocusLevelId);
END
GO

IF OBJECT_ID(N'dbo.TimeSensitivity_lkp', N'U') IS NULL
  AND OBJECT_ID(N'dbo.TimeSensitivityLookup', N'U') IS NOT NULL
BEGIN
  IF EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_InboxItem_TimeSensitivityLookup' AND parent_object_id = OBJECT_ID(N'dbo.InboxItem')
  )
    ALTER TABLE dbo.InboxItem DROP CONSTRAINT FK_InboxItem_TimeSensitivityLookup;

  IF EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_Task_TimeSensitivityLookup' AND parent_object_id = OBJECT_ID(N'dbo.Task')
  )
    ALTER TABLE dbo.Task DROP CONSTRAINT FK_Task_TimeSensitivityLookup;

  EXEC sys.sp_rename N'dbo.TimeSensitivityLookup', N'TimeSensitivity_lkp', N'OBJECT';
END
GO

IF OBJECT_ID(N'dbo.TimeSensitivity_lkp', N'U') IS NOT NULL
BEGIN
  IF EXISTS (
    SELECT 1 FROM sys.key_constraints
    WHERE name = N'PK_TimeSensitivityLookup' AND parent_object_id = OBJECT_ID(N'dbo.TimeSensitivity_lkp')
  )
    EXEC sys.sp_rename N'PK_TimeSensitivityLookup', N'PK_TimeSensitivity_lkp', N'OBJECT';

  IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_InboxItem_TimeSensitivity_lkp' AND parent_object_id = OBJECT_ID(N'dbo.InboxItem')
  )
    AND OBJECT_ID(N'dbo.InboxItem', N'U') IS NOT NULL
    ALTER TABLE dbo.InboxItem ADD CONSTRAINT FK_InboxItem_TimeSensitivity_lkp FOREIGN KEY (TimeSensitivityId)
      REFERENCES dbo.TimeSensitivity_lkp (TimeSensitivityId);

  IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_Task_TimeSensitivity_lkp' AND parent_object_id = OBJECT_ID(N'dbo.Task')
  )
    AND OBJECT_ID(N'dbo.Task', N'U') IS NOT NULL
    ALTER TABLE dbo.Task ADD CONSTRAINT FK_Task_TimeSensitivity_lkp FOREIGN KEY (TimeSensitivityId)
      REFERENCES dbo.TimeSensitivity_lkp (TimeSensitivityId);
END
GO

IF OBJECT_ID(N'dbo.Status_lkp', N'U') IS NULL
  AND OBJECT_ID(N'dbo.StatusLookup', N'U') IS NOT NULL
BEGIN
  IF EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_InboxItem_StatusLookup' AND parent_object_id = OBJECT_ID(N'dbo.InboxItem')
  )
    ALTER TABLE dbo.InboxItem DROP CONSTRAINT FK_InboxItem_StatusLookup;

  IF EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_Task_StatusLookup' AND parent_object_id = OBJECT_ID(N'dbo.Task')
  )
    ALTER TABLE dbo.Task DROP CONSTRAINT FK_Task_StatusLookup;

  EXEC sys.sp_rename N'dbo.StatusLookup', N'Status_lkp', N'OBJECT';
END
GO

IF OBJECT_ID(N'dbo.Status_lkp', N'U') IS NOT NULL
BEGIN
  IF EXISTS (
    SELECT 1 FROM sys.key_constraints
    WHERE name = N'PK_StatusLookup' AND parent_object_id = OBJECT_ID(N'dbo.Status_lkp')
  )
    EXEC sys.sp_rename N'PK_StatusLookup', N'PK_Status_lkp', N'OBJECT';

  IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_InboxItem_Status_lkp' AND parent_object_id = OBJECT_ID(N'dbo.InboxItem')
  )
    AND OBJECT_ID(N'dbo.InboxItem', N'U') IS NOT NULL
    ALTER TABLE dbo.InboxItem ADD CONSTRAINT FK_InboxItem_Status_lkp FOREIGN KEY (StatusId)
      REFERENCES dbo.Status_lkp (StatusId);

  IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_Task_Status_lkp' AND parent_object_id = OBJECT_ID(N'dbo.Task')
  )
    AND OBJECT_ID(N'dbo.Task', N'U') IS NOT NULL
    ALTER TABLE dbo.Task ADD CONSTRAINT FK_Task_Status_lkp FOREIGN KEY (StatusId)
      REFERENCES dbo.Status_lkp (StatusId);
END
GO
