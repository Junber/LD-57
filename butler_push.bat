set GAME=psychspacer
rmdir build /S / Q
mkdir build
mkdir build\windows
mkdir build\web
mkdir build\linux
Godot_v4.4.1-stable_win64_console.exe --export-debug "windows" .\build\windows\%GAME%.exe
Godot_v4.4.1-stable_win64_console.exe --export-debug "web" .\build\web\index.html
Godot_v4.4.1-stable_win64_console.exe --export-debug "linux" .\build\linux\%GAME%.x86_64
butler push build\windows solid-squid-contingent/%GAME%:windows --if-changed --userversion v1
butler push build\web solid-squid-contingent/%GAME%:web --if-changed --userversion v1
butler push build\linux solid-squid-contingent/%GAME%:linux --if-changed --userversion v1
PAUSE
