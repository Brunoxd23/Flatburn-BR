# FLATBURN: O City Scanner Open-Source (Versão Brasil - Flatburn-BR)

<img src="https://github.com/MIT-Senseable-City-Lab/OSCS/raw/main/flatburn-images/cover.jpeg">

Desenvolvido originalmente no [MIT Senseable City Lab](https://senseable.mit.edu) como parte do projeto [City Scanner](https://senseable.mit.edu/cityscanner/), o **Flatburn** é uma plataforma aberta, modular e movida a energia solar para sensoriamento ambiental urbano instalada em veículos em circulação (ônibus, viaturas, etc.).

Este repositório (**Flatburn-BR**) contém o firmware otimizado, documentação completa em português, esquemáticos de hardware e ferramentas de download de dados para implantação no Brasil.

---

## 📋 Sumário
1. [Especificações Técnicas](#-especificações-técnicas)
2. [Arquitetura do Firmware](#%EF%B8%8F-arquitetura-do-firmware)
3. [Estrutura de Pastas e Módulos](#-estrutura-de-pastas-e-módulos)
4. [Configuração do Ambiente e Ferramentas](#%EF%B8%8F-configuração-do-ambiente-e-ferramentas)
5. [Comandos de Compilação e Gravação (Particle CLI)](#-comandos-de-compilação-e-gravação-particle-cli)
6. [Manual de Comandos do Firmware (CLI Serial / Nuvem)](#-manual-de-comandos-do-firmware-cli-serial--nuvem)
7. [Configurações Principais (cityscanner_config.h)](#-configurações-principais-cityscanner_configh)
8. [Estrutura dos Payloads de Dados](#-estrutura-dos-payloads-de-dados)
9. [Tratamento de Data, Hora e Fuso Horário (Brasília UTC-3)](#-tratamento-de-data-hora-e-fuso-horário-brasília-utc-3)
10. [Histórico de Alterações e Correções de Estabilidade](#%EF%B8%8F-histórico-de-alterações-e-correções-de-estabilidade)

---

## ⚙️ Especificações Técnicas

- **Microcontrolador / Módulo IoT:** Particle B-Series SoM (`b5som` / `bsom`) com suporte a rede celular LTE.
- **Versão do Sistema Operacional:** [Particle Device OS @ 6.3.4](https://docs.particle.io/reference/device-os/firmware/).
- **Linguagem:** C++ (Particle Wiring API).
- **Sensores Embarcados:**
  - **Qualidade do Ar (Material Particulado):** Sensirion SPS30 (PM1.0, PM2.5, PM4, PM10).
  - **Meteorologia:** BME280 (Temperatura, Umidade e Pressão).
  - **Gases:** Sensor eletroquímico via conversor ADC de alta resolução (ADS1256).
  - **Ruído Urbano:** Microfone analógico com amostragem contínua.
  - **Geolocalização:** Módulo GPS com saída NMEA.
  - **Movimento e Detecção de Inatividade:** Acelerômetro / IMU.
  - **Telemetria de Bateria e Solar:** Medidores BQ24195 e LC709203F.
  - **Armazenamento Local:** Módulo MicroSD (buffer redundante quando sem conexão).

---

## 🏛️ Arquitetura do Firmware

O firmware adota um padrão modular de classes Singleton, onde cada classe é responsável por um subsistema do dispositivo:

| Módulo / Classe | Arquivos | Responsabilidade |
| :--- | :--- | :--- |
| **Cityscanner** | `firmware/src/cityscanner.h / .cpp` | Gerenciador central. Controla o loop principal e máquina de estados (`IDLE`, `REALTIME`, `LOGGING`, `PWRSAVE`). |
| **CitySense** | `firmware/src/cityscanner_sense.h / .cpp` | Inicialização, amostragem e conversão de dados de todos os sensores ambientais (SPS30, BME280, ADS1256, Ruído). |
| **CityVitals** | `firmware/src/cityscanner_vitals.h / .cpp` | Aquisição de dados de diagnóstico elétrico: nível de bateria (SOC), tensão, corrente, temperatura e produção de energia dos painéis solares. |
| **CityStore** | `firmware/src/cityscanner_store.h / .cpp` | Manipulação do cartão MicroSD: gravação em buffer CSV, rotação de arquivos e descarga de dados via USB. |
| **LocationService** | `firmware/src/location_service.h / .cpp` | Leitura e parsing de mensagens NMEA do GPS (latitude, longitude, velocidade, altitude e horário Epoch). |
| **MotionService** | `firmware/src/motion_service.h / .cpp` | Monitora o acelerômetro. Se o veículo ficar parado por mais de `INACTIVITY_TIME`, ativa rotinas de economia de energia. |
| **CitySleep** | `firmware/src/cityscanner_sleep.h / .cpp` | Controle de modos de suspensão (`Stop`, `Hibernate`, `Light Sleep`) para evitar descarregar a bateria durante a noite ou estacionado. |
| **CS_core** | Em `cscore` (lib) | Controle dos reguladores de tensão (chaveamento dos barramentos 3.3V e 5V dos sensores). |
| **CLI Handler** | `firmware/src/cityscanner_cli.h` | Interpretador de comandos que recebe instruções via porta Serial (USB) ou pela função de nuvem da Particle. |

---

## 📁 Estrutura de Pastas e Módulos

```text
flartBurn/
├── README.md                  # Documentação principal no GitHub (Português)
├── LICENSE                    # Licença MIT
├── firmware/                  # Código fonte do microcontrolador
│   ├── project.properties     # Configuração básica do projeto Particle
│   ├── README.md              # Documentação técnica do firmware
│   ├── README.pt-BR.md        # Documentação completa em português
│   ├── src/                   # Arquivos-fonte (.cpp e .h)
│   └── lib/                   # Bibliotecas dos sensores e periféricos
├── hardware/                  # Esquemáticos elétricos, PCB (KiCad) e modelos CAD/3D (STEP/STL)
└── documentation/             # Site de documentação Docusaurus e ferramentas (flatburn_downloader.html)
```

---

## 🛠️ Configuração do Ambiente e Ferramentas

Para trabalhar com este firmware, você só precisa do **Node.js** e do **Particle CLI** instalados no computador.

### 1. Instalar o Particle CLI (Global)
No terminal do seu computador (PowerShell ou Prompt de Comando):
```bash
npm install -g particle-cli
```

### 2. Verificar a Instalação
```bash
particle --version
# Exemplo de saída: 3.51.0
```

### 3. Fazer Login na Conta Particle
Para utilizar o compilador na nuvem e os recursos remotos:
```bash
particle login
```
*Insira seu e-mail e senha cadastrados no console da [Particle.io](https://login.particle.io).*

---

## 🚀 Comandos de Compilação e Gravação (Particle CLI)

Todos os comandos abaixo devem ser executados a partir da raiz do repositório (`flartBurn/`):

### 1. Binários Pré-compilados Prontos para Teste
Para facilitar testes imediatos em bancada ou em campo, o projeto dispõe de dois binários prontos:

| Arquivo `.bin` | Configuração Celular | Comportamento do LED | Uso Recomendado |
| :--- | :--- | :--- | :--- |
| **`firmware_sem_celular.bin`** | `CELLULAR_ON_STARTUP FALSE` | ⚪ **Branco suave** (offline) | **Bancada e desenvolvimento local:** Desativa o modem na inicialização, liberando a Serial instantaneamente e gravando dados no MicroSD. |
| **`firmware_com_celular.bin`** | `CELLULAR_ON_STARTUP TRUE` | 🟢 **Verde** $\rightarrow$ 🌐 **Ciano** | **Operação em campo com telemetria:** Conecta à rede móvel e envia dados para a Nuvem Particle. |

---

### 2. Automação com Scripts Rápidos (.bat no Windows)
Você pode executar as ações com 2 cliques ou pelo terminal:

- **Compilação Automática:**
  - `compilar_sem_celular.bat` $\rightarrow$ Ajusta a configuração para `FALSE` e compila `firmware_sem_celular.bin`.
  - `compilar_com_celular.bat` $\rightarrow$ Ajusta a configuração para `TRUE` e compila `firmware_com_celular.bin`.
- **Gravação Direta via USB:**
  - `gravar_sem_celular.bat` $\rightarrow$ Grava a versão offline via USB.
  - `gravar_com_celular.bat` $\rightarrow$ Grava a versão online via USB.

---

### 3. Gravar no Dispositivo via USB (Cabo)
1. Conecte a placa ao computador pelo cabo USB.
2. Coloque a placa em **modo DFU**:
   - Mantenha pressionados os botões **RESET** e **MODE**.
   - Solte o botão **RESET** e continue segurando o botão **MODE** até o LED RGB começar a **piscar rápido em amarelo / âmbar**.
   - Solte o botão **MODE**.
3. Execute o comando de gravação da versão desejada:
   ```bash
   # Opção A: Versão Offline (Recomendada para testes e sem antena celular)
   particle flash --usb firmware_sem_celular.bin

   # Opção B: Versão Online (Conexão celular ativa)
   particle flash --usb firmware_com_celular.bin
   ```

---

### 4. Compilar Manualmente via Terminal
Caso altere o código-fonte manualmente e queira compilar via linha de comando:
```bash
particle compile b5som firmware/ --target 6.3.4 --saveTo firmware.bin
```

---

### 5. Gravar no Dispositivo via Nuvem (OTA - Sem cabo)
Caso o dispositivo esteja na rua ou conectado via celular:
```bash
particle flash NOME_OU_ID_DO_DISPOSITIVO firmware.bin
```

### 6. Visualizar Logs da Porta Serial (Monitor em Tempo Real)
Para acompanhar leituras de sensores e mensagens de debug enviadas pelo dispositivo via USB:
```bash
particle serial monitor --follow
```

### 7. Listar Dispositivos Conectados na USB
```bash
particle serial list
```

### 8. Como Baixar e Unificar o CSV de Dados via Navegador
Para descarregar todos os dados gravados no cartão MicroSD e gerar uma planilha única `.csv` com georreferenciamento e timestamps corrigidos:

1. **Liberar a porta USB:**  
   Se o comando `particle serial monitor` estiver rodando no terminal, feche-o pressionando **`Ctrl + C`** *(no Windows, a porta serial fica bloqueada caso outro programa esteja usando)*.
2. **Abrir a ferramenta web:**  
   Abra o arquivo [`documentation/content/explore/flatburn_downloader.html`](documentation/content/explore/flatburn_downloader.html) no **Google Chrome** ou **Microsoft Edge** (estes navegadores possuem suporte nativo à *Web Serial API*).
3. **Conectar ao dispositivo:**  
   Na página aberta, clique em **Connect** e selecione a porta serial do Flatburn (geralmente identificada como **"B-SoM CDC Mode"** ou **"USB Serial Device"**).
4. **Baixar e Unificar:**  
   Clique no botão **"Download All, Parse & Merge"**. O sistema baixa todos os blocos do SD, limpa os dados e unifica tudo em uma única tabela.
5. **Salvar o arquivo:**  
   Clique em **"Save CSV File"** para salvar a planilha `.csv` final na sua pasta de Downloads.

### 9. Significado dos LEDs de Status (Guia de Cores)
O módulo Particle e a placa Flatburn utilizam LEDs indicadores para sinalizar o estado do hardware e das conexões:

| Cor do LED | Padrão | Significado | O que fazer / Situação |
| :--- | :--- | :--- | :--- |
| 🟢 **Verde** | Piscando rápido | **Buscando Rede Celular:** O modem celular está ativo e tentando se registrar na torre de telefonia. | Comportamento normal logo após ligar a placa ou gravar novo firmware. |
| 🔵 **Azul Escuro** | Piscando | **Modo de Escuta (Listening Mode):** Placa aguardando comandos USB ou sistema desatualizado (firmware do Flatburn pausado). | 1. Dê 1 clique no botão **RESET**.<br>2. Se continuar azul ou for placa nova, coloque em DFU (amarelo) e execute `particle update`. |
| 🌐 **Ciano (Azul Claro)** | Piscando rápido | **Conectando à Nuvem:** Autenticando com os servidores da Particle após conectar na torre celular. | Aguardar alguns segundos até a conclusão do handshake. |
| 🌐 **Ciano (Azul Claro)** | Pulsando suave ("respirando") | **Conectado e Online:** Comunicação ativa e estável com a Nuvem Particle. | Dispositivo 100% online e apto a transmitir dados em tempo real. |
| 🟡 **Amarelo / Âmbar** | Piscando rápido | **Modo DFU:** Placa pronta para receber novo firmware via USB (`particle flash --usb`). | Gravar o firmware pelo terminal ou pressionar RESET para sair. |
| ⚪ **Branco** | Pulsando suave | **Modo Offline:** Modem celular desligado (`Cellular.off()`), gravando dados apenas localmente no SD Card. | Padrão do Flatburn para economia de energia durante coletas. |
| 🟣 **Magenta / Roxo** | Piscando rápido | **Safe Mode / Atualização OTA:** Atualizando firmware pela nuvem ou em modo de proteção. | Aguardar o término do download/gravação. |
| 🔴 **Vermelho** *(Placa Flatburn)* | Piscando lento / Aceso | **Carga / Sistema Ativo:** LED do circuito de alimentação (BQ25798) e amostragem ativa dos sensores. | Normal durante a operação e quando conectado ao cabo USB. |

> [!TIP]
> **Placa travada piscando em Azul Escuro (Listening Mode) ou não inicializa após gravar?**  
> Isso é muito comum em placas novas ou virgens de fábrica cujo sistema operacional interno (*Device OS*) ainda está em versões antigas:
> 1. Feche o monitor serial com `Ctrl + C` para liberar a porta USB.
> 2. Coloque a placa em **modo DFU** (LED piscando rápido em **amarelo**): segure `RESET + MODE`, solte `RESET`, espere piscar em amarelo e solte `MODE`.
> 3. No terminal, execute a atualização do sistema:
>    ```bash
>    particle update
>    ```
> 4. Após a conclusão com sucesso, regrave o firmware desejado (`particle flash --usb firmware_sem_celular.bin` ou use o script `.bat`).

---

## 🎮 Manual de Comandos do Firmware (CLI Serial / Nuvem)

O firmware possui um interpretador de comandos integrado (`cityscanner_cli.h`).  
Os comandos podem ser enviados de duas formas:
1. **Pela porta Serial USB:** digitando diretamente no monitor serial ou enviando via scripts em Python.
2. **Pela Nuvem da Particle:** chamando a função `CLI` da placa pelo terminal:
   ```bash
   particle call NOME_DO_DISPOSITIVO CLI "COMANDO"
   ```

Abaixo está a lista completa de comandos suportados:

### A. Download e Gerenciamento do Cartão SD
| Comando | Descrição |
| :--- | :--- |
| `LIST` | Lista todos os arquivos `.csv` armazenados no cartão MicroSD. |
| `READ:<nome_arquivo>` | Imprime na Serial todo o conteúdo do arquivo especificado (ex: `READ:0001.csv`). |
| `DELETE_ALL` | Remove do cartão SD os arquivos que já foram baixados. |
| `sd,dump,all` | Despeja todos os arquivos de dados na porta Serial. |
| `sd,dump,<N>` | Despeja os últimos `<N>` arquivos de dados (ex: `sd,dump,5`). |
| `sd,files` | Retorna a quantidade de arquivos de dados pendentes no cartão SD. |
| `sd,health` | Retorna o status de saúde e conectividade do cartão SD. |
| `sd,reinit` | Reinicializa o driver do cartão SD caso ocorra alguma falha. |
| `sd,format` | Formata e reinicia a estrutura de pastas do cartão SD. |

### B. Leituras Imediatas e Sensores
| Comando | Descrição |
| :--- | :--- |
| `last,payload` | Retorna a última leitura completa dos sensores (GPS + Poluentes + Clima). |
| `last,vitals` | Retorna a última leitura de telemetria elétrica (Bateria + Solar). |
| `device-check` | Executa um teste em todos os sensores e retorna a linha consolidada. |
| `location` | Retorna as coordenadas GPS atuais (`latitude,longitude`). |
| `battery` | Retorna status detalhado da bateria (SOC %, tensão, corrente de carga). |
| `solar` ou `input` | Retorna a tensão e corrente produzidas pelos painéis solares. |
| `opc` | Retorna os dados brutos da última leitura do sensor de material particulado SPS30. |

### C. Controle de Energia dos Sensores (Chaveamento de Barramentos)
| Comando | Descrição |
| :--- | :--- |
| `3v3on` | Liga a alimentação de 3.3V e inicializa GPS, temperatura, ruído e gás. |
| `3v3off` | Desliga todos os sensores de 3.3V para economizar energia. |
| `5von` | Liga a linha de 5V (alimentação necessária para o sensor SPS30). |
| `5voff` | Desliga a linha de 5V e desativa o sensor SPS30. |
| `opcon` | Liga o sensor de partículas SPS30. |
| `opcoff` | Desliga o sensor de partículas SPS30. |
| `autosleep,on` | Habilita o modo de suspensão automática quando o veículo estaciona. |
| `autosleep,off` | Força o dispositivo a ficar acordado mesmo se estiver parado. |

### D. Controle do Sistema e Modos de Espera
| Comando | Descrição |
| :--- | :--- |
| `reboot` | Reinicia o microcontrolador imediatamente (`System.reset()`). |
| `dfu` | Coloca a placa em modo DFU remotamente para receber novo firmware. |
| `stop` | Coloca a placa em modo de espera profundo (Stop Sleep) por até 12 horas ou até movimento. |
| `hibernate,<tempo>,<unidade>` | Coloca a placa em hibernação profunda por um tempo pré-determinado.<br>Exemplo: `hibernate,30,minutes` ou `hibernate,2,hours`. |

---

## ⚙️ Configurações Principais (`cityscanner_config.h`)

Para alterar a frequência de coleta, modos de operação ou limites de segurança de bateria, edite o arquivo [firmware/src/cityscanner_config.h](firmware/src/cityscanner_config.h):

| Parâmetro | Padrão | O que configura |
| :--- | :--- | :--- |
| `MODE` | `LOGGING` | Modo padrão de operação (`REALTIME`, `LOGGING` ou `PWRSAVE`). |
| `SAMPLE_RATE` | `5` | Intervalo em segundos entre amostragens de sensores de qualidade do ar. |
| `VITALS_RATE` | `300` | Intervalo em segundos (5 minutos) entre leituras de telemetria da bateria/solar. |
| `INACTIVITY_TIME`| `120` | Segundos sem movimento do veículo para ativar o modo de economia. |
| `AUTOSLEEP` | `TRUE` | Ativa/desativa se a placa dorme automaticamente quando estacionada. |
| `LOW_BATTERY_THRESHOLD` | `3.70` | Tensão em Volts da bateria para acionar o alerta de bateria baixa. |
| `RECORDS_PER_FILE` | `200` | Quantidade de registros por arquivo `.csv` no cartão SD antes de rotacionar. |
| `CELLULAR_ON_STARTUP` | `FALSE` | Define se a conexão celular é ligada imediatamente ao dar boot. |
| `TIMEZONE_OFFSET` | `-3` | Fuso horário em horas (padrão `-3` para Horário de Brasília / São Paulo). |

---

## 📊 Estrutura dos Payloads de Dados

Os dados gravados no cartão SD e transmitidos via nuvem/USB seguem o padrão CSV delimitado por vírgulas:

### 1. Payload de Sensores (Ambiental)
```text
deviceID, timestamp, latitude, longitude, PM1.0, PM2.5, PM4, PM10, numPM0.5, numPM1, numPM2.5, numPM4, numPM10, PM_size, temperature, humidity, gas_op1_w, gas_op1_r, gas_op2_w, gas_op2_r, noise
```

### 2. Payload de Vitals (Diagnóstico Elétrico)
```text
deviceID, time, latitude, longitude, SOC_batt, temp_batt, voltage_batt, voltage_particle, current_batt, isCharging, isCharginS, temp_int, hum_int, voltage_solar, current_solar, cell_strength
```

---

## 🕒 Tratamento de Data, Hora e Fuso Horário (Brasília UTC-3)

Para garantir precisão nas análises em **São Paulo / Brasil**, o firmware conta com as seguintes regras de sincronização temporal e georreferenciamento:

### 1. Correção do Timestamp Epoch
- O cálculo da data do GPS utiliza `CalendarYrToTm(tinyGps->date.year())`, convertendo o ano civil de 4 dígitos (ex.: 2024, 2026) diretamente em anos transcorridos desde 1970.
- Isso gera um **Unix Epoch UTC padronizado em segundos** na coluna `timestamp` do CSV, pronto para ser lido pelo downloader web ou bibliotecas de análise (ex.: Pandas).

### 2. Sincronização Automática do Relógio Interno (RTC)
- Assim que o módulo GPS obtém uma data e hora válidas dos satélites (`tinyGps->date.isValid()` e ano >= 2020), o firmware executa `Time.setTime(epoch)`.

### 3. Fuso Horário de Brasília (`TIMEZONE_OFFSET -3`)
- O parâmetro `#define TIMEZONE_OFFSET -3` no [cityscanner_config.h](firmware/src/cityscanner_config.h) ativa a compensação local via `Time.zone(-3)`. Os arquivos no SD são nomeados como `MMDDHHMM.csv` em horário de Brasília.

---

## 🛠️ Histórico de Alterações e Correções de Estabilidade

1. **Taxa de Transmissão Serial Atualizada para 115200 Baud:**
   - A inicialização da porta Serial em [main.cpp](firmware/src/main.cpp) foi ajustada de `9600` para `115200` baud. Isso sincronizou a velocidade do microcontrolador com a interface web ([flatburn_downloader.html](documentation/content/explore/flatburn_downloader.html)), permitindo o download ultrarrápido dos arquivos do cartão SD via USB.

2. **Timeout de Proteção no Conversor ADC ADS1256:**
   - Adicionada verificação com timeout de 100ms nas funções `waitForLowDRDY()` e `waitForHighDRDY()` no driver do sensor de gás ADS1256 ([ADS1256.cpp](firmware/lib/ADS1256-main/src/ADS1256.cpp)). Evita travamentos caso o sensor esteja ausente ou o pino DRDY em nível alto.

3. **Correção na Ordem de Energização das Linhas 3.3V e 5V:**
   - Em [cityscanner.cpp](firmware/src/cityscanner.cpp), a inicialização dos barramentos de alimentação (`core.enable3V3(true)` e `core.enable5V(true)`) foi movida para o **início da função `init()`**, garantindo energia no barramento I2C e SD Card antes do acesso.

4. **Desativação de Sketches de Exemplo nas Bibliotecas (`.ino.bak`):**
   - Todos os arquivos `.ino` situados dentro da pasta `lib/` (ex.: `ADS1256-Example.ino`) foram renomeados para `.ino.bak`. Evita que o compilador da Particle inclua sketches de teste de bibliotecas no binário final (~80 KB).

5. **Exibição do Modo `LOGGING` em Tempo Real na Serial:**
   - Ativada a chamada da função `printDebug()` no bloco `case LOGGING:` dentro do `loop()`, imprimindo a tabela consolidada de todos os sensores diretamente no monitor serial a cada 5 segundos.

6. **Desativação Total do Modem Celular no Boot:**
   - Incluído o comando `Cellular.off()` no bloco `STARTUP()` de [main.cpp](firmware/src/main.cpp) para eliminar a busca por torres e o LED piscando em verde.

7. **Correção do Pino CS e Barramento SPI1 do Conversor ADC de Gases (ADS1256):**
   - Corrigido conflito de pinagem no módulo B-SoM onde o pino `D4` (que é `SPI1 MISO`) estava configurado incorretamente como Chip Select (`CS`). Como o pino CS do hardware do Flatburn V5 é soldado permanentemente ao GND (Pino 20), `ADS1256_CS_PIN` foi redefinido para `0` e o driver [ADS1256.cpp](firmware/lib/ADS1256-main/src/ADS1256.cpp) foi ajustado para liberar `D4` para receber os dados dos sensores eletroquímicos via barramento `SPI1` (`gas_op1_w`, `gas_op1_r`, `gas_op2_w`, `gas_op2_r`), eliminando leituras saturadas em 0V / -0.000001V.

---

Todos os materiais estão sob a licença [MIT License](LICENSE).