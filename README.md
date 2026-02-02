# PermitPoolHook

## Concept

A permissioned liquidity protocol enforcing trader eligibility through cryptographic identity verification on Ethereum Name Service infrastructure.

## Architecture

The system implements a **gatekeeper pattern** at the swap interface layer, leveraging ENS's hierarchical namespace as a credential substrate. Trading privileges are encoded as:

1. **Namespace membership** - Subdomain ownership under a controlled parent node
2. **Immutability guarantees** - Cryptographic fuses preventing credential transfer or parent revocation
3. **Off-chain attestations** - DID credentials resolved via ENS text records
4. **Centralized override** - Administrative blacklist for emergency revocation

## Mechanism Design

The hook intercepts swap attempts and performs **sequential verification**:

```
Swap Request → ENS Reverse Lookup → Parent Node Validation → Fuse Verification → DID Resolution → Blacklist Check → Execution
```

Each stage acts as a **boolean gate**: failure at any point reverts the transaction. The verification is **stateless** (reads only) except for the revocation registry, minimizing state manipulation attack vectors.

## Technical Primitives

- **ENS NameWrapper**: Provides fuse-based permission semantics and ownership proofs
- **ENS Resolver**: Exposes off-chain DID credentials via text records
- **Uniswap v4 Hooks**: Enables pre-swap execution interception
- **Namehash Algorithm**: Ensures cryptographic binding of names to unique identifiers

## Key Insight

Traditional permissioned pools require trusted operators or complex governance. This design **delegates credential issuance to ENS** while maintaining swap-layer enforcement, creating a separation of concerns:

- **ENS layer**: Identity management and credential lifecycle
- **Hook layer**: Permission enforcement and revocation
- **DEX layer**: Price discovery and settlement

The result is a **composable permission system** compatible with any Uniswap v4 pool, enabling selective market access without fragmenting liquidity across separate instances.

## Deployment Parameters

```solidity
constructor(
    IPoolManager poolManager,      // Uniswap v4 core
    address nameWrapper,           // ENS credential provider
    address textResolver,          // DID resolver
    bytes32 parentNode,            // Namespace root
    address admin                  // Revocation authority
)
```

## Use Cases

- **Regulatory compliance**: KYC/AML-gated trading
- **Private markets**: Accredited investor restrictions
- **Organizational pools**: DAO-member-only liquidity
- **Reputation systems**: Merit-based trading privileges
