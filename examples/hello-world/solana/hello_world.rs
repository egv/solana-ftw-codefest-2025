use anchor_lang::prelude::*;

declare_id!("11111111111111111111111111111111");

#[program]
pub mod hello_world {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
        let hello_account = &mut ctx.accounts.hello_account;
        hello_account.message = "Привет, мир от Solana!".to_string();
        hello_account.owner = ctx.accounts.user.key();
        Ok(())
    }

    pub fn update_message(ctx: Context<UpdateMessage>, new_message: String) -> Result<()> {
        let hello_account = &mut ctx.accounts.hello_account;
        hello_account.message = new_message;
        Ok(())
    }
}

#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(
        init,
        payer = user,
        space = 8 + 4 + 200 + 32, // discriminator + string length + max string size + pubkey
    )]
    pub hello_account: Account<'info, HelloAccount>,
    #[account(mut)]
    pub user: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct UpdateMessage<'info> {
    #[account(mut)]
    pub hello_account: Account<'info, HelloAccount>,
    pub user: Signer<'info>,
}

#[account]
pub struct HelloAccount {
    pub message: String,
    pub owner: Pubkey,
}