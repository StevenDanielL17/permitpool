# PermitPoolHook - Uniswap v4 ENS License Hook

A Uniswap v4 Hook that enforces trading permissions based on ENS licenses with Arc DID credentials.

## Overview

PermitPoolHook is a Uniswap v4 custom hook that verifies traders have valid ENS-based licenses before allowing swaps. It checks:

1. **ENS Subdomain Ownership** - Trader owns an ENS subdomain under a parent node
2. **Fuse Requirements** - CANNOT_TRANSFER (0x10) and PARENT_CANNOT_CONTROL (0x40000) fuses are burned
3. **Arc DID Credentials** - Valid Arc DID credential exists in ENS text records
4. **Revocation Status** - License hasn't been revoked by admin

## Development Status

**Stage 1: Basic Hook Structure** ✅ **COMPLETE**

- ✅ Foundry project setup
- ✅ BaseHook integration with Uniswap v4
- ✅ ENS Name Wrapper interface definition
- ✅ Custom errors and events
- ✅ Admin revocation mapping
- ✅ Skeleton beforeSwap() implementation

**Stage 2: ENS Verification Logic** 🚧 **NEXT**

- [ ] ENS subdomain ownership verification
- [ ] Fuse verification logic
- [ ] Helper functions for ENS operations
- [ ] Comprehensive error handling

**Stage 3: License Verification & Finalization** ⏳ **PENDING**

- [ ] Arc DID credential verification
- [ ] Complete beforeSwap() implementation
- [ ] Admin revocation functions
- [ ] Gas optimization
- [ ] Testing

## Technical Details

### Contract: `PermitPoolHook.sol`

**Inherits:** BaseHook (Uniswap v4)

**Dependencies:**

- Uniswap v4-core
- Uniswap v4-periphery

**Key Components:**

- **INameWrapper Interface** - Interacts with ENS Name Wrapper (Sepolia: `0x0635513f179D50A207757E05759CbD106d7dFcE8`)
- **Fuse Constants** - CANNOT_TRANSFER, PARENT_CANNOT_CONTROL
- **Admin Controls** - License revocation capabilities
- **Events** - LicenseChecked, LicenseRevokedEvent

### Installation

```bash
# Install dependencies (requires Foundry)
forge install Uniswap/v4-core --no-git --no-commit
forge install Uniswap/v4-periphery --no-git --no-commit
```

### Build

```bash
forge build
```

## Configuration

- **Network:** Sepolia Testnet
- **Solidity:** ^0.8.26
- **EVM Version:** Cancun

## Stage 1 Commit

This commit includes:

- Project structure and configuration
- Complete interface definitions
- All error and event declarations
- Skeleton hook implementation with TODOs
- Documentation

## Next Steps

Stage 2 will implement:

- ENS subdomain ownership checks
- Fuse verification logic
- ENS node computation helpers
- Integration of verification into beforeSwap()


