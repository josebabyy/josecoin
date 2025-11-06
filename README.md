# JoseCoin (JOSE)

A fungible token smart contract for Stacks, built with Clarinet. Implements a minimal SIP-010-compatible interface (name, symbol, decimals, supply, balance, and transfer).

## Project layout

- `Clarinet.toml` — Clarinet manifest
- `contracts/sip010-ft-trait.clar` — minimal SIP-010 FT trait used by JoseCoin
- `contracts/josecoin.clar` — JoseCoin token contract
- `settings/*.toml` — network/account presets for Clarinet
- `tests/` — place for Vitest-based tests (optional)

## Building and checking

If you have Clarinet installed:

- Check the project

```bash
clarinet check
```

- Open a console (simnet)

```bash
clarinet console
```

## Using the contract in Clarinet console

Initialize the contract (sets the caller as admin and optionally mints an initial supply to the caller):

```clarity
(contract-call? .josecoin initialize u100000000) ;; mints 100,000,000 base units (with 6 decimals)
```

Read metadata:

```clarity
(contract-call? .josecoin get-name)
(contract-call? .josecoin get-symbol)
(contract-call? .josecoin get-decimals)
```

Check balances and supply:

```clarity
(contract-call? .josecoin get-total-supply)
(contract-call? .josecoin get-balance-of tx-sender)
```

Transfer tokens (sender must be `tx-sender`):

```clarity
(contract-call? .josecoin transfer u100 tx-sender 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA none)
```

Admin-only minting and admin management (after `initialize`):

```clarity
(contract-call? .josecoin mint u1000 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA)
(contract-call? .josecoin set-admin 'ST2J8EVY02KX6E4A9NP8R0H12HNQ0TB2R2ZB6J9ZZ)
```

Burn tokens:

```clarity
(contract-call? .josecoin burn u500)
```

## Notes

- Decimals: `u6` (i.e., 1 JOSE = 1_000_000 base units)
- `initialize` must be called once to set the admin; subsequent calls will fail.
- The contract exposes a minimal SIP-010-like surface. If you need full SIP-010 compliance (including allowances), we can extend it.
