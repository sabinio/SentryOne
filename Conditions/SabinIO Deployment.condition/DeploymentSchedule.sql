USE --[DatabaseName]
GO

CREATE SCHEMA [Deploy]
GO

CREATE TABLE [Deploy].[DeploymentSchedule](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[DeployStartTime] [datetime2](7) NULL,
	[DeployEndTime] [datetime2](7) NULL,
	[ReleaseDefinitionName] [varchar](100) NULL,
	[ReleaseName] [varchar](100) NULL,
	[ReleaseDescription] [varchar](1000) NULL,
	[ReleaseEnv] [varchar](30) NULL,
 CONSTRAINT [PK_DeploymentSchedule] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [USERDATA]
) ON [USERDATA]
GO

ALTER TABLE [Deploy].[DeploymentSchedule] ADD  DEFAULT (getdate()) FOR [DeployStartTime]
GO

CREATE PROCEDURE [Deploy].[sp_DeploymentSchedule_i]
	@ReleaseDefinitionName VARCHAR(100),
	@ReleaseName VARCHAR(100),
	@ReleaseDescription VARCHAR(100) = NULL,
	@ReleaseEnv VARCHAR(30) = NULL
AS
	INSERT [deploy].[DeploymentSchedule] (ReleaseDefinitionName, ReleaseName, ReleaseDescription, ReleaseEnv)
	VALUES (@ReleaseDefinitionName, @ReleaseName, @ReleaseDescription, @ReleaseEnv)
GO

CREATE PROCEDURE [Deploy].[sp_DeploymentSchedule_u]
	@ReleaseName VARCHAR(100)
AS
	UPDATE [deploy].[DeploymentSchedule]
	SET DeployEndTime = GETDATE()
	WHERE ReleaseName = @ReleaseName
	AND DeployEndTime IS NULL
RETURN 0
GO


