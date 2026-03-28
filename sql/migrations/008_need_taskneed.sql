/*
  Migration: dbo.Need (user-scoped human needs) and dbo.TaskNeed_link (junction suffix _link; Task ↔ Need).
  Prereq: dbo.AppUser (005_user.sql) and dbo.Task.AppUserId (006_task.sql).
  Safe to run multiple times (idempotent). See RULES.md §8 (SQL script safety).
*/
SET NOCOUNT ON;

IF OBJECT_ID(N'dbo.Need', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.Need (
    NeedId BIGINT IDENTITY(1,1) NOT NULL,
    AppUserId BIGINT NOT NULL,
    Label VARCHAR(200) NOT NULL,
    Meaning VARCHAR(MAX) NOT NULL,
    SortOrder INT NULL,
    CONSTRAINT PK_Need PRIMARY KEY (NeedId),
    CONSTRAINT FK_Need_AppUser FOREIGN KEY (AppUserId) REFERENCES dbo.AppUser (AppUserId)
  );
END
GO

IF OBJECT_ID(N'dbo.Need', N'U') IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_Need_AppUserId' AND object_id = OBJECT_ID(N'dbo.Need')
  )
  CREATE INDEX IX_Need_AppUserId ON dbo.Need (AppUserId);
GO

IF OBJECT_ID(N'dbo.TaskNeed_link', N'U') IS NULL
  AND OBJECT_ID(N'dbo.Task', N'U') IS NOT NULL
  AND OBJECT_ID(N'dbo.Need', N'U') IS NOT NULL
BEGIN
  CREATE TABLE dbo.TaskNeed_link (
    TaskId BIGINT NOT NULL,
    NeedId BIGINT NOT NULL,
    CONSTRAINT PK_TaskNeed_link PRIMARY KEY (TaskId, NeedId),
    CONSTRAINT FK_TaskNeed_link_Task FOREIGN KEY (TaskId)
      REFERENCES dbo.Task (TaskId) ON DELETE CASCADE,
    CONSTRAINT FK_TaskNeed_link_Need FOREIGN KEY (NeedId)
      REFERENCES dbo.Need (NeedId) ON DELETE CASCADE
  );
END
GO

IF OBJECT_ID(N'dbo.TaskNeed_link', N'U') IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_TaskNeed_link_NeedId' AND object_id = OBJECT_ID(N'dbo.TaskNeed_link')
  )
  CREATE INDEX IX_TaskNeed_link_NeedId ON dbo.TaskNeed_link (NeedId);
GO
