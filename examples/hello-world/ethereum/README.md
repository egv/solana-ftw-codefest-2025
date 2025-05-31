# Ethereum Hello World - Начало разработки

## Обзор

Простейший смарт-контракт "Hello World" на Ethereum, демонстрирующий сохранение и обновление строкового сообщения в блокчейне.

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
mkdir ethereum-hello-world
cd ethereum-hello-world
npm init -y
npm install --save-dev hardhat @nomiclabs/hardhat-ethers ethers
```

### 2. Настройка Hardhat
```bash
npx hardhat
# Выберите "Create a JavaScript project"
```

### 3. Копирование контракта
Скопируйте файл `HelloWorld.sol` в папку `contracts/`

### 4. Компиляция
```bash
npx hardhat compile
```

### 5. Создание скрипта деплоя
Создайте файл `scripts/deploy.js`:
```javascript
async function main() {
  const HelloWorld = await ethers.getContractFactory("HelloWorld");
  const helloWorld = await HelloWorld.deploy();
  await helloWorld.deployed();
  
  console.log("HelloWorld развернут по адресу:", helloWorld.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
```

### 6. Развертывание (локально)
```bash
# Запуск локальной сети
npx hardhat node

# В новом терминале
npx hardhat run scripts/deploy.js --network localhost
```

## Взаимодействие с контрактом

### Получение сообщения
```javascript
const message = await helloWorld.getMessage();
console.log(message); // "Привет, мир от Ethereum!"
```

### Обновление сообщения
```javascript
await helloWorld.setMessage("Новое сообщение!");
```

## Структура контракта

- `message` - хранимое сообщение (public)
- `owner` - адрес создателя контракта
- `setMessage()` - обновление сообщения
- `getMessage()` - получение сообщения
- `MessageUpdated` - событие при обновлении

## Тестирование

Создайте файл `test/HelloWorld.js`:
```javascript
const { expect } = require("chai");

describe("HelloWorld", function () {
  it("Должен установить правильное начальное сообщение", async function () {
    const HelloWorld = await ethers.getContractFactory("HelloWorld");
    const helloWorld = await HelloWorld.deploy();
    
    expect(await helloWorld.getMessage()).to.equal("Привет, мир от Ethereum!");
  });
});
```

Запуск тестов:
```bash
npx hardhat test
```

## Полезные ресурсы

- [Документация Hardhat](https://hardhat.org/docs)
- [Solidity документация](https://docs.soliditylang.org/)
- [OpenZeppelin](https://openzeppelin.com/contracts/)
- [Remix IDE](https://remix.ethereum.org/)