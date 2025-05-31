# Solana Counter - Начало разработки

## Обзор

Программа счетчика на Solana с использованием Anchor фреймворка. Поддерживает инициализацию, увеличение, уменьшение и сброс счетчика.

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
anchor init solana-counter --no-git
cd solana-counter
```

### 2. Копирование программы
Замените содержимое `programs/solana-counter/src/lib.rs` на код из `counter.rs`

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
solana address -k target/deploy/solana_counter-keypair.json
```

### 6. Тестирование
```bash
anchor test
```

## Структура программы

### Инструкции:
- `initialize` - создание нового счетчика
- `increment` - увеличение на 1
- `decrement` - уменьшение на 1 (с проверкой)
- `reset` - сброс (только владелец)

### Аккаунты:
- `Counter` - хранит значение счетчика и владельца

## Основные концепции Solana

1. **Программы** - смарт-контракты Solana (stateless)
2. **Аккаунты** - хранилище данных
3. **Инструкции** - вызовы функций программы
4. **Подписи** - авторизация транзакций

## Полезные ресурсы

- [Anchor документация](https://www.anchor-lang.com/)
- [Solana документация](https://docs.solana.com/)
- [Solana Cookbook](https://solanacookbook.com/)
- [Anchor примеры](https://github.com/coral-xyz/anchor/tree/master/examples)