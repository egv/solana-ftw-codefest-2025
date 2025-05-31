# Ethereum NFT Minting - Начало разработки

## Обзор

Смарт-контракт для создания NFT (Non-Fungible Tokens) на Ethereum с использованием стандарта ERC-721 и OpenZeppelin библиотек.

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
mkdir ethereum-nft-minting
cd ethereum-nft-minting
npm init -y
npm install --save-dev hardhat @nomiclabs/hardhat-ethers ethers
npm install @openzeppelin/contracts
```

### 2. Настройка Hardhat
```bash
npx hardhat
# Выберите "Create a JavaScript project"
```

### 3. Копирование контракта
Скопируйте файл `SimpleNFT.sol` в папку `contracts/`

### 4. Компиляция
```bash
npx hardhat compile
```

### 5. Создание скрипта деплоя
Создайте файл `scripts/deploy.js`:
```javascript
async function main() {
  const SimpleNFT = await ethers.getContractFactory("SimpleNFT");
  const nft = await SimpleNFT.deploy();
  await nft.deployed();
  
  console.log("SimpleNFT развернут по адресу:", nft.address);
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

## Использование контракта

### Минтинг NFT (только владелец)
```javascript
const [owner, addr1] = await ethers.getSigners();
const nft = await ethers.getContractAt("SimpleNFT", contractAddress);

// Минтинг NFT
const tokenURI = "https://ipfs.io/ipfs/QmYourNFTMetadata";
const tx = await nft.mintNFT(addr1.address, tokenURI);
await tx.wait();

console.log("NFT создан!");
```

### Получение информации о токене
```javascript
// Получение URI токена
const tokenURI = await nft.tokenURI(1);
console.log("Token URI:", tokenURI);

// Получение общего количества токенов
const totalSupply = await nft.getTotalSupply();
console.log("Всего токенов:", totalSupply.toString());

// Получение владельца токена
const owner = await nft.ownerOf(1);
console.log("Владелец токена 1:", owner);
```

## Структура контракта

### Наследуемые контракты:
- **ERC721** - стандартная реализация NFT
- **Ownable** - контроль доступа владельца

### Основные функции:
- `mintNFT()` - создание нового NFT (только владелец)
- `tokenURI()` - получение метаданных токена
- `getTotalSupply()` - общее количество созданных токенов

### События:
- `NFTMinted` - эмитируется при создании нового NFT

## Подготовка метаданных NFT

### Пример metadata.json
```json
{
  "name": "Мой Первый NFT",
  "description": "Это мой первый NFT на Ethereum",
  "image": "https://ipfs.io/ipfs/QmYourImageHash",
  "attributes": [
    {
      "trait_type": "Цвет",
      "value": "Синий"
    },
    {
      "trait_type": "Редкость", 
      "value": "Обычный"
    }
  ]
}
```

### Загрузка на IPFS
```bash
# Установка IPFS CLI
npm install -g ipfs

# Загрузка файла
ipfs add metadata.json
# Вернет hash: QmYourMetadataHash
```

## Тестирование

Создайте файл `test/SimpleNFT.js`:
```javascript
const { expect } = require("chai");

describe("SimpleNFT", function () {
  let nft, owner, addr1;

  beforeEach(async function () {
    [owner, addr1] = await ethers.getSigners();
    const SimpleNFT = await ethers.getContractFactory("SimpleNFT");
    nft = await SimpleNFT.deploy();
    await nft.deployed();
  });

  it("Должен создать NFT", async function () {
    const tokenURI = "https://example.com/metadata.json";
    await nft.mintNFT(addr1.address, tokenURI);
    
    expect(await nft.ownerOf(1)).to.equal(addr1.address);
    expect(await nft.tokenURI(1)).to.equal(tokenURI);
    expect(await nft.getTotalSupply()).to.equal(1);
  });

  it("Только владелец может минтить", async function () {
    await expect(
      nft.connect(addr1).mintNFT(addr1.address, "test")
    ).to.be.revertedWith("Ownable: caller is not the owner");
  });
});
```

Запуск тестов:
```bash
npx hardhat test
```

## Развертывание в testnet

### Настройка hardhat.config.js
```javascript
require("@nomiclabs/hardhat-ethers");

module.exports = {
  solidity: "0.8.19",
  networks: {
    goerli: {
      url: "https://goerli.infura.io/v3/YOUR_INFURA_KEY",
      accounts: ["YOUR_PRIVATE_KEY"]
    }
  }
};
```

### Деплой в Goerli
```bash
npx hardhat run scripts/deploy.js --network goerli
```

## Полезные ресурсы

- [OpenZeppelin документация](https://docs.openzeppelin.com/)
- [ERC-721 стандарт](https://eips.ethereum.org/EIPS/eip-721)
- [IPFS документация](https://docs.ipfs.io/)
- [OpenSea Testnet](https://testnets.opensea.io/) - просмотр NFT