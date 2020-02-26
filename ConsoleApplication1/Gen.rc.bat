@echo off

:: replace $TARGETFILENAME$ with %1
echo TargetFileName is "%1"
powershell -Command "(Get-Content version.svn.rc) -replace '\$TARGETFILENAME\$', '%1' | Out-File  version.rc"

:SVN
:: https://tortoisesvn.net/docs/release/TortoiseSVN_zh_CN/tsvn-subwcrev.html
echo Maybe Subversion WorkingCopyPath ...
subwcrev.exe ../ version.rc version.rc -nNm
if %errorlevel% == 10 (
	powershell -Command "(Get-Content version.rc) -replace '\$WCREV\$', '$WCREV=7$' | Out-File  version.rc"
	goto GIT
)
goto END

:DUMMY
ehco Do nothing.

:GIT
:: https://tortoisegit.org/docs/tortoisegit/tgit-gitwcrev.html
echo Not SVN, try GIT ...
gitwcrev.exe ../ version.rc version.rc -mu

:END
echo Exit with %errorlevel%
exit /B errorlevel