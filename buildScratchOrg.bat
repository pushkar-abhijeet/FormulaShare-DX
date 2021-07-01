:: This script creates and configures a scratch org for genenral development. The steps below will be carried out:
:: - A default scratch org valid for 7 days will be created with name "<Day><Mon>FS" (e.g. "21DecFS")
:: - The core app and sample app will be pushed
:: - Permission sets for the core and sample apps will be assigned to the default scratch org user
:: - Lightning debug will be enabled for the default user
:: - A few test records are created (donations, programmes, countries and themes)
:: - The FormulaShare batch job will be scheduled

@echo off
setlocal EnableDelayedExpansion

set X=
for /f "skip=1 delims=" %%x in ('wmic os get localdatetime') do if not defined X set X=%%x
set month=%X:~4,2%
set day=%X:~6,2%

set monthList=JanFebMarAprMayJunJulAugSepOctNovDec
set /a monthPos=(%month%-1)*3
set monthName=!monthList:~%monthPos%,3!

set orgName=%day%%monthName%FS
echo Username for default org: %orgName%

call sfdx force:org:create -f config/project-scratch-def.json -a %orgName% --setdefaultusername
echo Created org with default username %orgName%
call node scripts/appendNamespaceToSampleMD.js
echo Checked for namespace and appended to custom metadata if required
call sfdx force:source:push
echo Pushed source
call sfdx force:user:permset:assign --permsetname FormulaShare_Admin_User
call sfdx force:user:permset:assign --permsetname FormulaShare_Sample_App_Permissions
echo Assigned permissions
call sfdx force:apex:execute -f config/setDebugModeForUser.apex
echo Set up user for debug mode
call sfdx force:apex:execute -f config/runApexOnInstallation.apex
echo Created test data