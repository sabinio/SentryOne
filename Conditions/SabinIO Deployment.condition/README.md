# Sabin.IO Deployment Condition

- In SentryOne open Advisory Conditions list from Navigator.
- Right click any current Condition and click Import, Select __[SabinIO Deployment.condition](SabinIO%20Deployment.condition)__ to import.
- Open the __[DeploymentSchedule.sql](DeploymentSchedule.sql)__ in SSMS and change the USE statement to point to the correct database.
- Execute the DeploymentSchedule.sql script.
- Test SabinIO Deployment Advisory Condition by inserting a record into the DeploymentSchedule table using the sp_DeploymentSchedule_i stored procedure, then execute the sp_DeploymentSchedule_u with the same ReleaseName to enter and end time for the release. For example:
  ```PLSQL
  EXEC sp_DeploymentSchedule_i @ReleaseDefinitionName = 'TestDefinition', @ReleaseName = 'TestRelease', @ReleaseDescription = 'Code Change', @ReleaseEnv = 'PreProd'
  EXEC sp_DeploymentSchedule_u @ReleaseName = 'TestRelease'
  ```
- Check the SentryOne Performance Advisor dashboard for any Alerts.