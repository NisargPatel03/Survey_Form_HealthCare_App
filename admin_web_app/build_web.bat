@echo off
echo Building Flutter Web for Release...
call flutter build web --release
echo.
echo Build Complete!
echo The output is in: build\web
echo.
echo Opening output folder...
explorer build\web
pause
