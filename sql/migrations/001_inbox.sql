/*
  Migration: Inbox (Capture) tables — dbo.InboxItem, dbo.InboxAttachment.
  Product: quick notes (Body VARCHAR(MAX)); StatusId for triage lifecycle; attachments without sort order.
  Safe to run multiple times (idempotent). See RULES.md §8 (SQL script safety).
*/
SET NOCOUNT ON;

IF OBJECT_ID(N'dbo.InboxItem', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.InboxItem (
    InboxItemId BIGINT IDENTITY(1,1) NOT NULL,
    Body VARCHAR(MAX) NOT NULL,
    StatusId TINYINT NOT NULL CONSTRAINT DF_InboxItem_StatusId DEFAULT (1),
    CONSTRAINT PK_InboxItem PRIMARY KEY (InboxItemId),
    CONSTRAINT CK_InboxItem_Status CHECK (StatusId IN (1, 2, 3))
  );
END
GO

IF OBJECT_ID(N'dbo.InboxItem', N'U') IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_InboxItem_StatusId' AND object_id = OBJECT_ID(N'dbo.InboxItem')
  )
  CREATE INDEX IX_InboxItem_StatusId ON dbo.InboxItem (StatusId);
GO

IF OBJECT_ID(N'dbo.InboxAttachment', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.InboxAttachment (
    InboxAttachmentId BIGINT IDENTITY(1,1) NOT NULL,
    InboxItemId BIGINT NOT NULL,
    FileName VARCHAR(400) NOT NULL,
    ContentType VARCHAR(255) NOT NULL,
    FileContent VARBINARY(MAX) NOT NULL,
    CONSTRAINT PK_InboxAttachment PRIMARY KEY (InboxAttachmentId),
    CONSTRAINT FK_InboxAttachment_InboxItem FOREIGN KEY (InboxItemId)
      REFERENCES dbo.InboxItem (InboxItemId) ON DELETE CASCADE
  );
END
GO

IF OBJECT_ID(N'dbo.InboxAttachment', N'U') IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_InboxAttachment_InboxItemId' AND object_id = OBJECT_ID(N'dbo.InboxAttachment')
  )
  CREATE INDEX IX_InboxAttachment_InboxItemId ON dbo.InboxAttachment (InboxItemId);
GO
