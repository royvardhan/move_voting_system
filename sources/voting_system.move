module my_addrx::Voting {

use std::signer;
use std::vector;
use std::simple_map::{Self, SimpleMap};


const NOT_OWNER: u64 = 0;
const IS_NOT_INITIALIZED: u64 = 1;
const DOES_NOT_CONTAIN_KEY: u64 = 2;

struct CandidateList has key {
    candidate_list: SimpleMap<address, u64>,
    c_list: vector<address>,
    winner: address
}

struct VotingList has key {
    voters: SimpleMap<address, u8>
}

public fun assert_is_owner(addr: address) {
    assert!(addr == @my_addrx, 0);
}

public fun assert_has_initialized(addr: address) {
    assert!(exists<CandidateList>(addr), 1);
    assert!(exists<VotingList>(addr), 1);
}

public fun assert_contains_key(map: &SimpleMap<address, u64>, addr: &address) {
    assert!(simple_map::contains_key(map, addr), 2);
}


public entry fun initialize_with_candidate(acc: &signer, c_addr: address) acquires CandidateList {

    let addr = signer::address_of(acc);

    assert_is_owner(addr);
    assert_has_initialized(addr);

    let c_store = CandidateList{
        candidate_list:simple_map::create(),
        c_list: vector::empty<address>(),
        winner: @0x0,
        };

        move_to(acc, c_store);
    
    let v_store = VotingList {
        voters:simple_map::create(),
        };

        move_to(acc, v_store);
    
    let c_store = borrow_global_mut<CandidateList>(addr);
    assert_contains_key(&c_store.candidate_list, &c_addr);

    simple_map::add(&mut c_store.candidate_list, c_addr, 0);
    vector::push_back(&mut c_store.c_list, c_addr);
}

public entry fun add_candidate(acc: &signer, c_addr: address) acquires CandidateList {
    let addr = signer::address_of(acc);
    assert_is_owner(addr);
    assert_has_initialized(addr);

    let c_store = borrow_global_mut<CandidateList>(addr);
    assert_contains_key(&c_store.candidate_list, &c_addr);
    simple_map::add(&mut c_store.candidate_list, c_addr, 0);
}

public entry fun vote(acc: &signer, c_addr: address) acquires CandidateList, VotingList{
    let addr = signer::address_of(acc);

    assert_has_initialized(addr);


    let c_store = borrow_global_mut<CandidateList>(@my_addrx);
    let v_store = borrow_global_mut<VotingList>(@my_addrx);
    assert!(!simple_map::contains_key(&v_store.voters, &addr), 2);

    if(simple_map::contains_key(&c_store.candidate_list, &c_addr)) {
        let votes = simple_map::borrow_mut(&mut c_store.candidate_list, &c_addr);
        *votes = *votes + 1;
    } else {
        simple_map::add(&mut c_store.candidate_list, c_addr, 1);
    };

    let vote = simple_map::borrow_mut(&mut v_store.voters, &addr);
    *vote = 1;
}

public entry fun declare_winner(acc: &signer) acquires CandidateList {
    let addr = signer::address_of(acc);
    assert!(addr == @my_addrx, 0);
    assert!(exists<CandidateList>(addr), 0);

    let c_store = borrow_global_mut<CandidateList>(@my_addrx);

    let candidates = vector::length(&c_store.c_list);

    let i = 0;
    let winner: address = @0x0;
    let max_votes: u64 = 0;

    while (i < candidates) {
        let candidate = *vector::borrow(&c_store.c_list, (i as u64));
        let votes = simple_map::borrow(&c_store.candidate_list, &candidate);

        if(max_votes < *votes) {
            max_votes = *votes;
            winner = candidate;
        };
        i = i + 1;
    };

    c_store.winner = winner;
}


}