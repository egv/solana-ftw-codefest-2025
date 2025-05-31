# TON Counter - Начало разработки

## Обзор

Смарт-контракт счетчика на TON блокчейне, написанный на FunC. Поддерживает операции увеличения, уменьшения, сброса и получения значения счетчика.

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
mkdir ton-counter
cd ton-counter
mkdir contracts
mkdir build
```

### 2. Копирование контракта
Скопируйте файл `counter.fc` в папку `contracts/`

### 3. Компиляция
```bash
func -o build/counter.fif -SPA contracts/counter.fc
fift -s build/counter.fif
```

### 4. Создание кошелька
```bash
# Генерация приватного ключа
tonos-cli genkey counter.keys.json

# Создание адреса
tonos-cli genaddr build/counter.tvc build/counter.abi.json --setkey counter.keys.json
```

### 5. Развертывание
```bash
# Пополнение кошелька (testnet)
# Используйте Telegram бот @testgiver_ton_bot

# Развертывание контракта
tonos-cli deploy build/counter.tvc '{}' --abi build/counter.abi.json --sign counter.keys.json
```

## Взаимодействие с контрактом

### Увеличение счетчика
```bash
tonos-cli call <contract_address> increment '{}' --abi build/counter.abi.json --sign counter.keys.json
```

### Уменьшение счетчика
```bash
tonos-cli call <contract_address> decrement '{}' --abi build/counter.abi.json --sign counter.keys.json
```

### Сброс счетчика (только владелец)
```bash
tonos-cli call <contract_address> reset '{}' --abi build/counter.abi.json --sign counter.keys.json
```

### Получение значения
```bash
tonos-cli call <contract_address> get_count '{}' --abi build/counter.abi.json
```

## Структура контракта

### Операции (op коды):
- `1` - increment (увеличение)
- `2` - decrement (уменьшение) 
- `3` - reset (сброс)
- `4` - get_count (получение значения)

### Данные:
- `count` (64 бит) - значение счетчика
- `owner` (256 бит) - адрес владельца

## Основные концепции TON

1. **Cells** - базовая структура данных TON
2. **Messages** - коммуникация между контрактами
3. **Gas** - плата за вычисления
4. **Sharding** - масштабируемость через шарды

## Полезные ресурсы

- [TON документация](https://ton.org/docs/)
- [FunC справочник](https://ton.org/docs/develop/func/overview)
- [TON IDE](https://ide.ton.org/) - онлайн среда разработки
- [Telegram: @TONDev](https://t.me/tondev) - сообщество разработчиков