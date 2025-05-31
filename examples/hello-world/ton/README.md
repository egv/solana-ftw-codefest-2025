# TON Hello World - Начало разработки

## Обзор

Простейший смарт-контракт "Hello World" на TON блокчейне, написанный на FunC. Демонстрирует сохранение и получение строкового сообщения.

## Предварительные требования

1. **TON CLI** (tonos-cli)
   ```bash
   # Для Linux/macOS
   curl -O https://github.com/tonlabs/tonos-cli/releases/latest/download/tonos-cli
   chmod +x tonos-cli
   sudo mv tonos-cli /usr/local/bin/
   ```

2. **func компилятор** и **fift**
   ```bash
   # Установка через TON CLI
   git clone https://github.com/ton-blockchain/ton.git
   cd ton
   mkdir build && cd build
   cmake .. -DCMAKE_BUILD_TYPE=Release
   make -j4
   ```

3. **Node.js** (для взаимодействия с контрактом)
   ```bash
   npm install @ton/core @ton/crypto @ton/ton
   ```

## Быстрый старт

### 1. Инициализация проекта
```bash
mkdir ton-hello-world
cd ton-hello-world
mkdir contracts
mkdir build
```

### 2. Копирование контракта
Скопируйте файл `hello_world.fc` в папку `contracts/`

### 3. Компиляция
```bash
func -o build/hello_world.fif -SPA contracts/hello_world.fc
fift -s build/hello_world.fif
```

### 4. Создание кошелька
```bash
# Генерация приватного ключа
tonos-cli genkey hello_world.keys.json

# Создание адреса
tonos-cli genaddr build/hello_world.tvc build/hello_world.abi.json --setkey hello_world.keys.json
```

### 5. Развертывание
```bash
# Пополнение кошелька (testnet)
# Используйте Telegram бот @testgiver_ton_bot

# Развертывание контракта
tonos-cli deploy build/hello_world.tvc '{}' --abi build/hello_world.abi.json --sign hello_world.keys.json
```

## Взаимодействие с контрактом

### Получение сообщения
```bash
tonos-cli call <contract_address> get_message '{}' --abi build/hello_world.abi.json
```

### Установка нового сообщения
```bash
tonos-cli call <contract_address> set_message '{"message":"Новое сообщение!"}' --abi build/hello_world.abi.json --sign hello_world.keys.json
```

## Взаимодействие через JavaScript

### Установка зависимостей
```bash
npm install @ton/core @ton/crypto @ton/ton
```

### Пример клиента
```javascript
import { TonClient, WalletContractV4, internal, external } from "@ton/ton";
import { mnemonicNew, mnemonicToPrivateKey } from "@ton/crypto";

// Подключение к сети
const client = new TonClient({
    endpoint: "https://testnet.toncenter.com/api/v2/jsonRPC",
});

// Отправка сообщения
async function getMessage(contractAddress) {
    const result = await client.runMethod(contractAddress, "get_message");
    console.log("Сообщение:", result.stack.readString());
}

async function setMessage(contractAddress, newMessage) {
    // Создание и отправка внешнего сообщения
    const message = internal({
        to: contractAddress,
        value: "0.01", // 0.01 TON
        body: beginCell()
            .storeUint(2, 32) // op code для set_message
            .storeRef(beginCell().storeStringTail(newMessage).endCell())
            .endCell()
    });
    
    await wallet.sendTransfer({
        seqno: await wallet.getSeqno(),
        messages: [message]
    });
}
```

## Структура контракта

### Операции (op коды):
- `1` - get_message (получение сообщения)
- `2` - set_message (установка сообщения)

### Данные:
- Сообщение хранится как Cell в storage контракта

### Функции:
- `recv_internal` - обработка внутренних сообщений
- `recv_external` - инициализация при развертывании

## Основные концепции TON

1. **Messages** - основной способ взаимодействия
2. **Cells** - структура данных для хранения
3. **Gas fees** - плата за выполнение операций
4. **External/Internal messages** - типы сообщений

## Создание ABI файла

Создайте файл `build/hello_world.abi.json`:
```json
{
    "ABI version": 2,
    "functions": [
        {
            "name": "get_message",
            "inputs": [],
            "outputs": [
                {"name": "message", "type": "string"}
            ]
        },
        {
            "name": "set_message", 
            "inputs": [
                {"name": "message", "type": "string"}
            ],
            "outputs": []
        }
    ]
}
```

## Полезные ресурсы

- [TON документация](https://ton.org/docs/)
- [FunC справочник](https://ton.org/docs/develop/func/overview)
- [TON IDE](https://ide.ton.org/) - онлайн среда разработки
- [TonWeb](https://github.com/toncenter/tonweb) - JavaScript SDK