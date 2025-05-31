# Solana Hello World - Начало разработки

## Обзор

Простая программа "Hello World" на Solana с использованием Anchor фреймворка. Демонстрирует создание аккаунта и сохранение строкового сообщения.

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
anchor init solana-hello-world --no-git
cd solana-hello-world
```

### 2. Копирование программы
Замените содержимое `programs/solana-hello-world/src/lib.rs` на код из `hello_world.rs`

### 3. Конфигурация Solana
```bash
# Настройка на localhost
solana config set --url localhost

# Создание нового кошелька (если нужно)
solana-keygen new --outfile ~/.config/solana/id.json

# Проверка конфигурации
solana config get
```

### 4. Запуск локального валидатора
```bash
solana-test-validator
```

### 5. Сборка и развертывание
```bash
# В новом терминале
anchor build
anchor deploy

# Получение Program ID
solana address -k target/deploy/solana_hello_world-keypair.json
```

### 6. Тестирование
```bash
anchor test
```

## Взаимодействие с программой

### TypeScript клиент
```typescript
import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { HelloWorld } from "../target/types/hello_world";

// Подключение
const provider = anchor.AnchorProvider.env();
anchor.setProvider(provider);
const program = anchor.workspace.HelloWorld as Program<HelloWorld>;

// Создание аккаунта
const helloAccount = anchor.web3.Keypair.generate();

await program.methods
  .initialize()
  .accounts({
    helloAccount: helloAccount.publicKey,
    user: provider.wallet.publicKey,
    systemProgram: anchor.web3.SystemProgram.programId,
  })
  .signers([helloAccount])
  .rpc();

// Обновление сообщения
await program.methods
  .updateMessage("Новое сообщение!")
  .accounts({
    helloAccount: helloAccount.publicKey,
    user: provider.wallet.publicKey,
  })
  .rpc();

// Получение сообщения
const account = await program.account.helloAccount.fetch(helloAccount.publicKey);
console.log("Сообщение:", account.message);
```

## Структура программы

### Инструкции:
- `initialize` - создание аккаунта с начальным сообщением
- `update_message` - обновление сообщения

### Аккаунты:
- `HelloAccount` - хранит сообщение и владельца

### Важные концепции:
- **Space calculation** - расчет размера аккаунта (discriminator + данные)
- **Rent exemption** - аккаунт должен иметь достаточно SOL для освобождения от аренды

## Создание простого теста

```typescript
describe("hello-world", () => {
  it("Инициализация!", async () => {
    const helloAccount = anchor.web3.Keypair.generate();
    
    await program.methods
      .initialize()
      .accounts({
        helloAccount: helloAccount.publicKey,
        user: provider.wallet.publicKey,
        systemProgram: anchor.web3.SystemProgram.programId,
      })
      .signers([helloAccount])
      .rpc();

    const account = await program.account.helloAccount.fetch(helloAccount.publicKey);
    assert.equal(account.message, "Привет, мир от Solana!");
  });
});
```

## Полезные ресурсы

- [Anchor документация](https://www.anchor-lang.com/)
- [Solana документация](https://docs.solana.com/)
- [Solana Cookbook](https://solanacookbook.com/)
- [Anchor Book](https://book.anchor-lang.com/)