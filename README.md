# Voting Module

This module defines a simple voting system. It allows users to initialize a voting system, add candidates, vote for candidates, and declare a winner. The module consists of several structs and functions:

## Structs

### CandidateList

- `candidate_list: SimpleMap<address, u64>`: A simple map that stores the number of votes for each candidate, where the candidate's address is the key.
- `c_list: vector<address>`: A vector that maintains the list of candidates in the order they were added.
- `winner: address`: The address of the winning candidate.

### VotingList

- `voters: SimpleMap<address, u64>`: A simple map that keeps track of voters and the number of votes they have cast.

## Functions

### assert_is_owner(addr: address)

- Checks if the given address is the owner of the voting system.
- Aborts with error code `E_NOT_OWNER` if the address is not the owner.

### assert_is_initialized(addr: address)

- Checks if the voting system is initialized at the given address.
- Aborts with error code `E_IS_NOT_INITIALIZED` if the system is not initialized.

### assert_uninitialized(addr: address)

- Checks if the voting system is not initialized at the given address.
- Aborts with error code `E_IS_INITIALIZED` if the system is initialized.

### assert_contains_key(map: &SimpleMap<address, u64>, addr: &address)

- Checks if the given map contains the specified key.
- Aborts with error code `E_DOES_NOT_CONTAIN_KEY` if the key is not present in the map.

### assert_not_contains_key(map: &SimpleMap<address, u64>, addr: &address)

- Checks if the given map does not contain the specified key.
- Aborts with error code `E_IS_INITIALIZED_WITH_CANDIDATE` if the key is present in the map.

### initialize_with_candidate(acc: &signer, c_addr: address)

- Initializes the voting system with a candidate.
- Requires the caller to be the owner of the voting system.
- Aborts if the system is already initialized or if the caller is not the owner.
- Creates `CandidateList` and `VotingList` instances.
- Adds the candidate to the `candidate_list` and `c_list`.

### add_candidate(acc: &signer, c_addr: address)

- Adds a candidate to the voting system.
- Requires the caller to be the owner of the voting system.
- Aborts if the system is not initialized, if the caller is not the owner, or if the candidate already exists.
- Adds the candidate to the `candidate_list` and `c_list`.

### vote(acc: &signer, c_addr: address, store_addr: address)

- Allows a voter to cast a vote for a candidate.
- Requires the voting system to be initialized.
- Aborts if the system is not initialized, if the candidate does not exist, if the voter has already voted, or if a winner has been declared.
- Increments the vote count for the specified candidate in the `candidate_list` and adds the voter to the `voters` map.

### declare_winner(acc: &signer)

- Declares the winner of the voting system.
- Requires the caller to be the owner of the voting system.
- Aborts if the system is not initialized or if a winner has already been declared.
- Determines the winner by iterating through the `c_list` and finding the candidate with the highest number of votes.
- Updates the `winner` field in the `CandidateList` with the winning candidate.

## Tests

The code includes several test cases to verify the functionality of the voting module.

### Test Flow
 - Initializes the voting system with a candidate.
 - Adds another candidate to the system.
 - Verifies that both candidates are present in the candidate_list.
 - Allows three voters to cast their votes for the candidates.
 - Verifies that the voters' addresses are present in the voters map.
 - Declares the winner and verifies that the correct candidate is declared as the winner.

### Test Cases
 - `test_declare_winner`: Attempts to declare the winner twice, which should fail with an abort code `E_WINNER_DECLARED`.
 - `test_initialize_with_candidate_not_owner`: Attempts to initialize the voting system with a candidate using an address that is not the owner, which should fail with an abort code `E_NOT_OWNER`.
 - `test_initialize_with_same_candidate`: Attempts to initialize the voting system with the same candidate twice, which should fail with an abort code `E_IS_INITIALIZED`.
 - `test_vote_twice`: Attempts to vote twice for the same candidate, which should fail with an abort code `E_HAS_VOTED`.
 - `test_vote_not_initialized`: Attempts to vote in a voting system that is not initialized, which should fail with an abort code `E_IS_NOT_INITIALIZED`.
 - `test_add_candidate_after_winner_declared`: Attempts to add a candidate after a winner has been declared, which should fail with an abort code `E_WINNER_DECLARED`.
