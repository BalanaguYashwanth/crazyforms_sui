/// status - because if they want to return their SUI then making status - inactive
/// status 1 - active and 2 - inactive (out of funds)
/// Module: forms_escrow

module forms_escrow::forms_escrow {

    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Balance};
    use std::string::{Self, String};

    const ENotEnough: u64 = 0;

    public struct Form has key {
        id: UID,
        formId: String,
        budget: u64,
        cost_per_respose: u64,
        end_date: u64,
        name: String,
        status: u64,
        wallet_address: address,
        funds_to_distribute:  Balance<SUI>,
    }

    public entry fun create(
        budget: u64,
        formId: vector<u8>,
        cost_per_respose: u64,
        coin_address: &mut Coin<SUI>,
        end_date: u64,
        name: vector<u8>,
        status: u64,
        wallet_address: address,
        ctx: &mut TxContext,
    ) {
        let uid = object::new(ctx);
        let coin_balance = coin::balance_mut(coin_address);
        let pay = balance::split(coin_balance, budget);

        let form_object = Form {
            id: uid,
            formId: string::utf8(formId),
            budget,
            cost_per_respose,
            end_date,
            name: string::utf8(name),
            status,
            wallet_address,
            funds_to_distribute: pay,
        };

        transfer::share_object(form_object);
    }

    public fun reward(date: u64, form: &mut Form, sender_address: address, ctx: &mut TxContext){
        assert!(form.status == 1, ENotEnough);

        let balance = balance::value(&form.funds_to_distribute);

        if(balance >= form.cost_per_respose){
            let amount = coin::take(&mut form.funds_to_distribute, form.cost_per_respose, ctx);
            transfer::public_transfer(amount, sender_address);
        }
        else{
            form.status = 2;
            form.end_date = date;
        }   
    }
}
