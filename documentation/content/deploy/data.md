---
sidebar_position: 4
---

# 📊 Data Retrieval via USB Cable

**Follow these steps to retrieve data from the Flatburn device using the web-based downloader tool.**

The Flatburn SD Downloader is a browser-based tool that connects to your device over USB. It works in **Google Chrome** or **Microsoft Edge** (requires Web Serial API support).

The HTML tool is located locally at [`documentation/content/explore/flatburn_downloader.html`](../explore/flatburn_downloader.html) (or online in the [Flatburn-BR repository](https://github.com/Brunoxd23/Flatburn-BR/blob/main/documentation/content/explore/flatburn_downloader.html)).

> ⚠️ **CRITICAL NOTE (Serial Port Conflicts on Windows):**  
> If you have `particle serial monitor` or any other serial terminal (PuTTY, Arduino IDE) open in a terminal window, you **must close it (`Ctrl + C`)** before clicking Connect in the browser. Windows does not allow two programs to share the same serial COM port.

## Step 1: Connect Flatburn to Your Computer

1. Turn on your Flatburn device.
2. Use a USB cable to connect the device to your computer.
3. Open `documentation/content/explore/flatburn_downloader.html` in **Google Chrome** or **Microsoft Edge**.

## Step 2: Connect to the Serial Port

1. Click the **Connect** button.
2. A browser dialog will show available serial ports.
3. Select the Flatburn port; it will be labeled **"B-SoM CDC Mode"** or **"USB Serial Device"**.
4. The status indicator will turn green once connected, and the file list will load automatically.

**Note**: After connecting, the tool waits a brief moment for the device to finish initializing before loading the file list. This is normal, just wait for the file list to appear.

## Step 3: Download, Parse & Merge

The tool will display all available files on the SD card (e.g., files in `/queue/` and `active.csv`).

1. Review the file list.
2. Click **"Download All, Parse & Merge"**.
3. The tool will:
   - Download all files from the SD card
   - Parse each CSV (filter columns, clean data)
   - Convert epoch timestamps to human-readable format (e.g., `2025-03-15 22:37:17`)
   - Merge everything into a single dataset

A progress bar will show the download status, and stats badges will display the total files processed and rows merged.

## Step 4: Save the Merged CSV

1. Click **"Save CSV File"** to download the merged data to your computer.
2. The file is automatically named with a timestamp: `merged_20250315_223717.csv`

The output CSV contains the following columns:

| Column | Description |
|--------|-------------|
| `timestamp` | Date and time of the reading (human-readable) |
| `latitude` | GPS latitude |
| `longitude` | GPS longitude |
| `PM1_0` | Particulate matter 1.0 µm |
| `PM2_5` | Particulate matter 2.5 µm |
| `PM4` | Particulate matter 4.0 µm |
| `PM10` | Particulate matter 10 µm |
| `temperature` | Temperature reading |
| `humidity` | Humidity reading |
| `gas_op1_w` | Gas sensor OP1 working electrode |
| `gas_op1_r` | Gas sensor OP1 reference electrode |
| `gas_op2_w` | Gas sensor OP2 working electrode |
| `gas_op2_r` | Gas sensor OP2 reference electrode |
| `noise` | Noise level reading |

## Step 5: Clean Up the SD Card (Optional)

After saving your merged CSV, you can delete all files from the SD card to free up space:

1. Click **"Delete All Files from SD"**.
2. A confirmation dialog will list all files that will be deleted.
3. Click **OK** to confirm, or **Cancel** to keep the files.

The device will automatically create a fresh `active.csv` file after deletion, so it is ready to continue collecting data.

## Step 6: You're Done!

You now have a single, clean CSV file containing all your environmental and telemetry data with human-readable timestamps. You can use this file for analysis, upload to cloud storage, or integrate into your research workflow.

---

## 🇧🇷 Guia Rápido em Português

Para descarregar os dados do cartão SD via cabo USB no navegador:

1. **Liberar a porta USB:** Se o comando `particle serial monitor` estiver rodando no terminal, feche-o com **`Ctrl + C`** para não travar a porta COM no Windows.
2. **Abrir a ferramenta:** Abra o arquivo [`flatburn_downloader.html`](../explore/flatburn_downloader.html) no **Google Chrome** ou **Microsoft Edge**.
3. **Conectar:** Clique em **Connect** e selecione a porta serial da placa (**"B-SoM CDC Mode"** ou **"USB Serial Device"**).
4. **Baixar e Unificar:** Clique em **"Download All, Parse & Merge"** para que a ferramenta baixe os arquivos do cartão SD e una tudo em um só conjunto de dados.
5. **Salvar:** Clique em **"Save CSV File"** para salvar a planilha `.csv` unificada no seu computador.

