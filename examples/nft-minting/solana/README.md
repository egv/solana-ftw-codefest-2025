# Solana NFT Minting - Начало разработки

## Обзор

Программа для создания NFT на Solana с использованием Anchor фреймворка и Metaplex Token Metadata стандарта. Включает создание mint аккаунта, токен аккаунта и метаданных.

## Предварительные требования

1. **Rust** (стабильная версия)
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   rustc --version
   ```

2. **Solana CLI**
   ```bash
   sh -c "$(curl -sSfL https://release.solana.com/v1.17.0/install)"
   solana --version
   ```

3. **Anchor CLI**
   ```bash
   cargo install --git https://github.com/coral-xyz/anchor avm --locked --force
   avm install latest
   avm use latest
   anchor --version
   ```

4. **Node.js** (для клиентского кода)
   ```bash
   node --version
   ```

## Быстрый старт

### 1. Инициализация проекта
```bash
anchor init solana-nft-minting --no-git
cd solana-nft-minting
```

### 2. Добавление зависимостей в Cargo.toml
```toml
[dependencies]
anchor-lang = "0.29.0"
anchor-spl = "0.29.0"
mpl-token-metadata = "2.0.0"
```

### 3. Копирование программы
Замените содержимое `programs/solana-nft-minting/src/lib.rs` на код из `nft_mint.rs`

### 4. Конфигурация Solana
```bash
# Настройка на localhost
solana config set --url localhost

# Создание нового кошелька (если нужно)
solana-keygen new --outfile ~/.config/solana/id.json

# Получение SOL для тестов
solana airdrop 2
```

### 5. Запуск локального валидатора
```bash
solana-test-validator
```

### 6. Сборка и развертывание
```bash
# В новом терминале
anchor build
anchor deploy
```

## Структура программы

### Инструкции:
- `mint_nft` - создание NFT с метаданными

### Аккаунты в контексте MintNFT:
- `mint` - новый mint аккаунт для NFT
- `token_account` - associated token account
- `metadata` - аккаунт метаданных Metaplex
- `mint_authority` - подписант и плательщик

### Параметры метаданных:
```rust
pub struct InitTokenParams {
    pub name: String,      // Название NFT
    pub symbol: String,    // Символ коллекции  
    pub uri: String,       // URI метаданных (JSON)
}
```

## Создание клиента

### Установка зависимостей
```bash
npm install @coral-xyz/anchor @solana/web3.js
npm install @metaplex-foundation/mpl-token-metadata
```

### TypeScript клиент
```typescript
import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { NftMint } from "../target/types/nft_mint";
import { PublicKey } from "@solana/web3.js";

// Инициализация
const provider = anchor.AnchorProvider.env();
anchor.setProvider(provider);
const program = anchor.workspace.NftMint as Program<NftMint>;

// Создание NFT
async function mintNFT() {
    // Генерация нового mint аккаунта
    const mintKeypair = anchor.web3.Keypair.generate();
    
    // Адрес метаданных (по стандарту Metaplex)
    const [metadataAddress] = PublicKey.findProgramAddressSync(
        [
            Buffer.from("metadata"),
            new PublicKey("metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s").toBuffer(),
            mintKeypair.publicKey.toBuffer(),
        ],
        new PublicKey("metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s")
    );

    // Associated Token Account
    const associatedTokenAccount = anchor.utils.token.associatedAddress({
        mint: mintKeypair.publicKey,
        owner: provider.wallet.publicKey,
    });

    // Метаданные NFT
    const metadata = {
        name: "Мой Solana NFT",
        symbol: "MSN", 
        uri: "https://arweave.net/your-metadata-hash",
    };

    // Минтинг NFT
    const tx = await program.methods
        .mintNft(metadata)
        .accounts({
            mint: mintKeypair.publicKey,
            tokenAccount: associatedTokenAccount,
            metadata: metadataAddress,
            mintAuthority: provider.wallet.publicKey,
            rent: anchor.web3.SYSVAR_RENT_PUBKEY,
            systemProgram: anchor.web3.SystemProgram.programId,
            tokenProgram: anchor.utils.token.TOKEN_PROGRAM_ID,
            associatedTokenProgram: anchor.utils.token.ASSOCIATED_PROGRAM_ID,
            tokenMetadataProgram: new PublicKey("metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s"),
        })
        .signers([mintKeypair])
        .rpc();

    console.log("NFT создан! Mint:", mintKeypair.publicKey.toString());
    console.log("Transaction:", tx);
}

mintNFT().catch(console.error);
```

## Подготовка метаданных

### Пример JSON метаданных
```json
{
  "name": "Мой Solana NFT",
  "description": "Это мой первый NFT на Solana",
  "image": "https://arweave.net/your-image-hash",
  "external_url": "https://mysite.com",
  "attributes": [
    {
      "trait_type": "Цвет",
      "value": "Красный"
    },
    {
      "trait_type": "Редкость",
      "value": "Легендарный"
    }
  ],
  "properties": {
    "files": [
      {
        "uri": "https://arweave.net/your-image-hash",
        "type": "image/png"
      }
    ],
    "category": "image"
  }
}
```

### Загрузка на Arweave
```bash
# Установка Arweave CLI
npm install -g arweave-deploy

# Загрузка изображения
arweave deploy image.png --key-file wallet.json

# Загрузка метаданных
arweave deploy metadata.json --key-file wallet.json
```

## Тестирование

```typescript
describe("nft-mint", () => {
  it("Создает NFT", async () => {
    const mintKeypair = anchor.web3.Keypair.generate();
    
    const metadata = {
      name: "Test NFT",
      symbol: "TEST",
      uri: "https://example.com/metadata.json",
    };

    await program.methods
      .mintNft(metadata)
      .accounts({
        // ... аккаунты
      })
      .signers([mintKeypair])
      .rpc();

    // Проверка создания mint аккаунта
    const mintInfo = await program.provider.connection.getMintInfo(mintKeypair.publicKey);
    assert.equal(mintInfo.decimals, 0);
    assert.equal(mintInfo.supply.toString(), "1");
  });
});
```

## Работа с коллекциями

### Создание Verified Collection
```typescript
// Создание master edition для коллекции
const [masterEdition] = PublicKey.findProgramAddressSync(
    [
        Buffer.from("metadata"),
        TOKEN_METADATA_PROGRAM_ID.toBuffer(),
        collectionMint.toBuffer(),
        Buffer.from("edition"),
    ],
    TOKEN_METADATA_PROGRAM_ID
);

// Добавление в коллекцию при минтинге
const collection = {
    verified: false,
    key: collectionMint,
};
```

## Основные концепции Solana NFT

1. **Mint Account** - уникальный адрес токена
2. **Token Account** - владение токенами
3. **Metadata Account** - метаданные по стандарту Metaplex
4. **Master Edition** - для создания ограниченных изданий
5. **Collection** - группировка NFT

## Полезные ресурсы

- [Metaplex документация](https://docs.metaplex.com/)
- [Solana NFT стандарт](https://spl.solana.com/token)
- [Arweave](https://arweave.org/) - постоянное хранение
- [Magic Eden](https://magiceden.io/) - NFT маркетплейс Solana