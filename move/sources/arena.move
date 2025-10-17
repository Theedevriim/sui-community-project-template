module challenge::arena;

use challenge::hero::{Hero, hero_power};
use sui::event;


// ========= STRUCTS =========

public struct Arena has key, store {
    id: UID,
    warrior: Hero,
    owner: address,
}

// ========= EVENTS =========

public struct ArenaCreated has copy, drop {
    arena_id: ID,
    timestamp: u64,
}

public struct ArenaCompleted has copy, drop {
    winner_hero_id: ID,
    loser_hero_id: ID,
    timestamp: u64,
}

// ========= FUNCTIONS =========

public fun create_arena(hero: Hero, ctx: &mut TxContext) {

let arena = Arena {
    id: object::new(ctx),
    warrior: hero,
    owner: ctx.sender(),
};
event::emit(
    ArenaCreated {
        arena_id: object::id(&arena),
        timestamp: tx_context::epoch_timestamp_ms(ctx),
    },
);
transfer::share_object(arena);
}

#[allow(lint(self_transfer))]
public fun battle(hero: Hero, arena: Arena, ctx: &mut TxContext) {
    let Arena {id, warrior, owner} = arena;

    let incoming_id = object::id(&hero);
    let warrior_id = object::id(&warrior);

    if (hero_power(&hero) > hero_power(&warrior)) {
        transfer::public_transfer(hero, ctx.sender());
        transfer::public_transfer(warrior, ctx.sender());

        event::emit(
            ArenaCompleted {
                winner_hero_id: incoming_id,
                loser_hero_id: warrior_id,
                timestamp: tx_context::epoch_timestamp_ms(ctx),
            },
        );
    } else {
        transfer::public_transfer(hero, owner);
        transfer::public_transfer(warrior, owner);

        event::emit(
            ArenaCompleted {
                winner_hero_id: warrior_id,
                loser_hero_id: incoming_id,
                timestamp: ctx.epoch_timestamp_ms(),
            },
        );
    };

    object::delete(id);
}

