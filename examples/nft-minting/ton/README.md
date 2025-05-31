# TON NFT Minting - Начало разработки

## Обзор

Полная реализация NFT системы на TON блокчейне по стандарту TEP-62. Включает NFT коллекцию и отдельные NFT элементы с поддержкой трансферов и метаданных.

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
   # Установка TON инструментов
   git clone https://github.com/ton-blockchain/ton.git
   cd ton
   mkdir build && cd build
   cmake .. -DCMAKE_BUILD_TYPE=Release
   make -j4
   ```

3. **Node.js** (для взаимодействия с контрактами)
   ```bash
   npm install @ton/core @ton/crypto @ton/ton
   ```

## Структура проекта

Система NFT состоит из двух контрактов:
- **nft_collection.fc** - контракт коллекции (создает NFT)
- **nft_item.fc** - контракт отдельного NFT (владение и трансферы)

## Быстрый старт

### 1. Инициализация проекта
```bash
mkdir ton-nft-minting
cd ton-nft-minting
mkdir contracts
mkdir build
mkdir scripts
```

### 2. Копирование контрактов
```bash
# Скопируйте файлы в папку contracts/
contracts/
├── nft_collection.fc
└── nft_item.fc
```

### 3. Компиляция контрактов
```bash
# Компиляция NFT Collection
func -o build/nft_collection.fif -SPA contracts/nft_collection.fc
fift -s build/nft_collection.fif

# Компиляция NFT Item  
func -o build/nft_item.fif -SPA contracts/nft_item.fc
fift -s build/nft_item.fif
```

### 4. Создание кошельков
```bash
# Кошелек для коллекции
tonos-cli genkey collection.keys.json
tonos-cli genaddr build/nft_collection.tvc build/nft_collection.abi.json --setkey collection.keys.json

# Получение адреса коллекции
COLLECTION_ADDR=$(tonos-cli genaddr build/nft_collection.tvc build/nft_collection.abi.json --setkey collection.keys.json | grep "Raw address" | cut -d' ' -f3)
echo "Адрес коллекции: $COLLECTION_ADDR"
```

### 5. Пополнение кошелька
```bash
# Используйте Telegram бот @testgiver_ton_bot для получения тестовых TON
# Отправьте: $COLLECTION_ADDR
```

### 6. Развертывание коллекции
```bash
# Развертывание NFT Collection
tonos-cli deploy build/nft_collection.tvc '{}' --abi build/nft_collection.abi.json --sign collection.keys.json
```

## Создание NFT через JavaScript

### Установка зависимостей
```bash
npm install @ton/core @ton/crypto @ton/ton
```

### Пример скрипта (scripts/mint-nft.js)
```javascript
import { TonClient, WalletContractV4, internal, external, toNano } from "@ton/ton";
import { mnemonicNew, mnemonicToPrivateKey } from "@ton/crypto";
import { Address, beginCell } from "@ton/core";

// Подключение к testnet
const client = new TonClient({
    endpoint: "https://testnet.toncenter.com/api/v2/jsonRPC",
});

// Адрес развернутой коллекции
const COLLECTION_ADDRESS = Address.parse("EQC...");  // Ваш адрес коллекции

async function mintNFT() {
    // Создание кошелька (или загрузка существующего)
    const mnemonic = "your wallet mnemonic words here...".split(" ");
    const keyPair = await mnemonicToPrivateKey(mnemonic);
    const wallet = WalletContractV4.create({ 
        workchain: 0, 
        publicKey: keyPair.publicKey 
    });
    
    const contract = client.open(wallet);

    // Параметры NFT
    const itemIndex = 0; // Индекс NFT в коллекции
    const itemOwner = wallet.address; // Владелец NFT
    
    // Контент NFT (метаданные)
    const nftContent = beginCell()
        .storeBuffer(Buffer.from("https://example.com/nft/0.json"))
        .endCell();

    // Сообщение для минтинга NFT
    const mintMessage = internal({
        to: COLLECTION_ADDRESS,
        value: toNano("0.05"), // 0.05 TON для создания NFT
        body: beginCell()
            .storeUint(1, 32) // op code для mint_nft
            .storeUint(0, 64) // query_id
            .storeUint(itemIndex, 64) // индекс NFT
            .storeCoins(toNano("0.02")) // количество TON для NFT контракта
            .storeRef(nftContent) // метаданные NFT
            .endCell()
    });

    // Отправка транзакции
    const seqno = await contract.getSeqno();
    await contract.sendTransfer({
        seqno,
        messages: [mintMessage]
    });

    console.log(`NFT #${itemIndex} создан для адреса: ${itemOwner}`);
}

mintNFT().catch(console.error);
```

### Метаданные NFT (JSON)
```json
{
  "name": "Мой TON NFT #1",
  "description": "Первый NFT в моей коллекции на TON",
  "image": "https://example.com/images/nft1.png",
  "external_url": "https://mysite.com",
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

## Batch Minting (массовое создание)

```javascript
async function batchMintNFTs() {
    // Создание словаря для batch mint
    const deployList = Dictionary.empty(Dictionary.Keys.Uint(64), Cell);
    
    // Добавление нескольких NFT
    for (let i = 0; i < 5; i++) {
        const nftContent = beginCell()
            .storeBuffer(Buffer.from(`https://example.com/nft/${i}.json`))
            .endCell();
            
        const itemData = beginCell()
            .storeCoins(toNano("0.02")) // TON для NFT контракта
            .storeRef(nftContent)
            .endCell();
            
        deployList.set(i, itemData);
    }

    // Сообщение для batch mint
    const batchMintMessage = internal({
        to: COLLECTION_ADDRESS,
        value: toNano("0.3"), // 0.3 TON для создания 5 NFT
        body: beginCell()
            .storeUint(2, 32) // op code для batch_mint
            .storeUint(0, 64) // query_id
            .storeDict(deployList)
            .endCell()
    });

    const seqno = await contract.getSeqno();
    await contract.sendTransfer({
        seqno,
        messages: [batchMintMessage]
    });

    console.log("Batch mint выполнен для 5 NFT");
}
```

## Трансфер NFT

```javascript
async function transferNFT(nftAddress, newOwner) {
    const transferMessage = internal({
        to: nftAddress,
        value: toNano("0.05"),
        body: beginCell()
            .storeUint(0x05138d91, 32) // op code для transfer
            .storeUint(0, 64) // query_id
            .storeAddress(Address.parse(newOwner)) // новый владелец
            .storeAddress(wallet.address) // адрес для ответа
            .storeBit(false) // custom_payload
            .storeCoins(toNano("0.01")) // forward_amount
            .storeBit(false) // forward_payload
            .endCell()
    });

    const seqno = await contract.getSeqno();
    await contract.sendTransfer({
        seqno,
        messages: [transferMessage]
    });

    console.log(`NFT ${nftAddress} передан ${newOwner}`);
}
```

## Получение информации о NFT

### Get методы коллекции
```javascript
// Получение данных коллекции
async function getCollectionData() {
    const result = await client.runMethod(COLLECTION_ADDRESS, "get_collection_data");
    const [nextItemIndex, content, owner] = result.stack;
    
    console.log("Следующий индекс NFT:", nextItemIndex.readBigNumber());
    console.log("Владелец коллекции:", owner.readAddress());
}

// Получение адреса NFT по индексу
async function getNFTAddress(index) {
    const result = await client.runMethod(COLLECTION_ADDRESS, "get_nft_address_by_index", [
        { type: "int", value: BigInt(index) }
    ]);
    
    return result.stack.readAddress();
}
```

### Get методы NFT элемента
```javascript
async function getNFTData(nftAddress) {
    const result = await client.runMethod(nftAddress, "get_nft_data");
    const [init, index, collection, owner, content] = result.stack;
    
    console.log("NFT инициализирован:", init.readBoolean());
    console.log("Индекс:", index.readBigNumber());
    console.log("Владелец:", owner.readAddress());
}
```

## Создание ABI файлов

### nft_collection.abi.json
```json
{
    "ABI version": 2,
    "functions": [
        {
            "name": "mint_nft",
            "inputs": [
                {"name": "item_index", "type": "uint64"},
                {"name": "amount", "type": "uint128"},
                {"name": "nft_content", "type": "cell"}
            ],
            "outputs": []
        },
        {
            "name": "batch_mint", 
            "inputs": [
                {"name": "deploy_list", "type": "cell"}
            ],
            "outputs": []
        },
        {
            "name": "change_owner",
            "inputs": [
                {"name": "new_owner", "type": "address"}
            ],
            "outputs": []
        }
    ],
    "data": [],
    "events": []
}
```

## Основные концепции TON NFT

1. **TEP-62 стандарт** - стандарт NFT в TON
2. **Collection Contract** - создание и управление NFT
3. **Item Contract** - отдельный NFT с владением
4. **Content Cell** - метаданные в формате Cell
5. **Royalty** - роялти для создателей

## Полезные ресурсы

- [TON NFT стандарт (TEP-62)](https://github.com/ton-blockchain/TEPs/blob/master/text/0062-nft-standard.md)
- [TON документация](https://ton.org/docs/)
- [GetGems](https://getgems.io/) - NFT маркетплейс TON
- [TON NFT примеры](https://github.com/ton-blockchain/token-contract)