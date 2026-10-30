@echo off
chcp 65001 > nul
echo ========================================================
echo  Gravando firmware_com_celular.bin via USB
echo ========================================================
echo.
echo Certifique-se de que o LED esta piscando em AMARELO (DFU Mode):
echo (Segure MODE + RESET, solte RESET, espere piscar amarelo, solte MODE)
echo.
particle flash --usb firmware_com_celular.bin
pause

