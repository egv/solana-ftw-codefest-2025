# Ethereum Counter - Начало разработки

## Обзор

Простой смарт-контракт счетчика на Ethereum с функциями увеличения, уменьшения и сброса значения.

## Предварительные требования

1. **Node.js** (v16 или выше)
   ```bash
   node --version
   ```

2. **Hardhat** - фреймворк для разработки Ethereum
   ```bash
   npm install --global hardhat
   ```

3. **MetaMask** - кошелек для взаимодействия с блокчейном

## Быстрый старт

### 1. Инициализация проекта
```bash
mkdir ethereum-counter
cd ethereum-counter
npm init -y
npm install --save-dev hardhat @nomiclabs/hardhat-ethers ethers
```

### 2. Настройка Hardhat
```bash
npx hardhat
# Выберите "Create a JavaScript project"
```

### 3. Копирование контракта
Скопируйте файл `Counter.sol` в папку `contracts/`

### 4. Компиляция
```bash
npx hardhat compile
```

### 5. Развертывание (локально)
```bash
# Запуск локальной сети
npx hardhat node

# В новом терминале
npx hardhat run scripts/deploy.js --network localhost
```

## Структура контракта

- `count` - текущее значение счетчика
- `owner` - адрес владельца контракта
- `increment()` - увеличение на 1
- `decrement()` - уменьшение на 1 (с проверкой)
- `reset()` - сброс (только владелец)
- `getCount()` - получение текущего значения

## Полезные ресурсы

- [Документация Hardhat](https://hardhat.org/docs)
- [Solidity документация](https://docs.soliditylang.org/)
- [OpenZeppelin](https://openzeppelin.com/contracts/) - безопасные контракты
- [Remix IDE](https://remix.ethereum.org/) - онлайн редактор