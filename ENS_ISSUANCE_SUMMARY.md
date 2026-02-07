# ENS License Issuance Summary (Sepolia)

**Date**: 2026-02-07
**Status**: Partial Success (Pending Parent Node Ownership)

## 1. Contracts Deployed

We successfully deployed the entire PermitPool infrastructure on Sepolia.

| Contract           | Address                                      |
| :----------------- | :------------------------------------------- |
| **PermitPoolHook** | `0x223221e595c626c46bAB8c8D33f9Ea7cad3d4080` |
| **LicenseManager** | `0xBE033f15f64A8aE139cD8bCDf000603Ec100A01B` |
| **ArcOracle**      | `0x02404d83b142481a113059195f46FE49A522f66A` |
| **PaymentManager** | `0xf9A10fe56F9aC9614f032Ae9361131d08568cdF3` |

## 2. Configuration Status

- **Hook Configuration**: The Hook correctly points to the `LicenseManager`.
- **ENS Approval**: The `LicenseManager` has been approved as an operator on the ENS NameWrapper (`setApprovalForAll`).

## 3. The Current Blocker

We attempted to issue a license (`issueLicense`), but it failed with an `Unauthorised` revert from the ENS NameWrapper.

**Root Cause**:

- The script `ApproveENS.s.sol` revealed:
  ```
  Parent Node: myhedgefund.eth (Node Hash 0x5c7...)
  Parent Node Owner on NameWrapper: 0x0000000000000000000000000000000000000000
  ```
- **Explanation**: You do not own the parent domain `myhedgefund.eth` on the Sepolia ENS NameWrapper.
- **Why this matters**: You cannot issue subdomains (licenses) like `alice.myhedgefund.eth` if you don't own the parent `myhedgefund.eth`.

## 4. Required Action

To proceed with license issuance, you must:

1.  **Register the Domain**: Go to [app.ens.domains (Sepolia)](https://app.ens.domains/) and register `myhedgefund.eth` (or any available name) using your deployer wallet (`0x52b3...`).
2.  **Wrap the Name**: Ensure the name is "Wrapped" so it appears in the NameWrapper contract.
3.  **Update Config**: If you register a different name, update `PARENT_DOMAIN_NAME` and `PARENT_NODE` in your `.env` file.
4.  **Retry Issuance**: Run the issuance script again.

## 5. Next Steps

Once ownership is confirmed:

1.  Run `forge script script/IssueLicense.s.sol ...`
2.  The script will:
    - Create `demo-trader.myhedgefund.eth`
    - Burn `CANNOT_TRANSFER` + `PARENT_CANNOT_CONTROL` fuses.
    - Set the Arc DID text record.
