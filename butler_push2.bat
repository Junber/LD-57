set GAME=psychspacer
butler push build\windows solid-squid-contingent/%GAME%:windows --userversion v1
butler push build\web solid-squid-contingent/%GAME%:web --userversion v1
butler push build\linux solid-squid-contingent/%GAME%:linux --userversion v1
PAUSE
