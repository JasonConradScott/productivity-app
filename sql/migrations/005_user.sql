/*
  Migration: dbo.AppUser — minimal account row for single-user phase (seed AppUserId = 1).
  Must run before dbo.Task (006) when Task references AppUser. Idempotent. See RULES.md §8.
*/
SET NOCOUNT ON;

IF OBJECT_ID(N'dbo.AppUser', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.AppUser (
    AppUserId BIGINT IDENTITY(1,1) NOT NULL,
    DisplayName VARCHAR(200) NOT NULL,
    CONSTRAINT PK_AppUser PRIMARY KEY (AppUserId)
  );
END
GO

IF OBJECT_ID(N'dbo.AppUser', N'U') IS NOT NULL
BEGIN
  SET IDENTITY_INSERT dbo.AppUser ON;

  IF NOT EXISTS (SELECT 1 FROM dbo.AppUser WHERE AppUserId = 1)
    INSERT INTO dbo.AppUser (AppUserId, DisplayName) VALUES (1, N'Primary');

  SET IDENTITY_INSERT dbo.AppUser OFF;
END
GO
