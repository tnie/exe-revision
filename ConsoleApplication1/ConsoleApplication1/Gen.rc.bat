@echo off

:SVN
:: https://tortoisesvn.net/docs/release/TortoiseSVN_zh_CN/tsvn-subwcrev.html
echo Maybe Subversion WorkingCopyPath ...
subwcrev.exe ../ version.rc.svn version.rc -nNm
if %errorlevel% == 10 goto GIT
goto END

:DUMMY
ehco Do nothing.

:GIT
:: https://tortoisegit.org/docs/tortoisegit/tgit-gitwcrev.html
echo Not SVN, try GIT ...
gitwcrev.exe ../ version.rc.git version.rc -mu

:END
echo Exit with %errorlevel%
exit /B errorlevel