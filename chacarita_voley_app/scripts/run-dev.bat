@echo off
set BACKEND_URL=%1
if "%BACKEND_URL%"=="" set BACKEND_URL=https://chaca-jjsnmt6wj7u3.lafuah.com/graphql
flutter run --dart-define=BACKEND_URL=%BACKEND_URL%
