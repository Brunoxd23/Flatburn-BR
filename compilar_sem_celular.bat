@echo off
chcp 65001 > nul
echo ========================================================
echo  Compilando Flatburn (OFFLINE / Celular: FALSE)
echo ========================================================

powershell -Command "(Get-Content 'firmware\src\cityscanner_config.h') -replace '#define CELLULAR_ON_STARTUP TRUE', '#define CELLULAR_ON_STARTUP FALSE' | Set-Content 'firmware\src\cityscanner_config.h'"

echo Configuração ajustada para CELLULAR_ON_STARTUP FALSE.
echo Enviando para o compilador Particle (b5som @ 6.3.4)...
particle compile b5som firmware/ --target 6.3.4 --saveTo firmware_sem_celular.bin

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================================
    echo  SUCESSO! Gerado: firmware_sem_celular.bin
    echo  Para gravar: particle flash --usb firmware_sem_celular.bin
    echo ========================================================
) else (
    echo.
    echo [ERRO] Falha na compilação.
)
pause

