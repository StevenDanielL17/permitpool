export const CONTRACTS = {
  HOOK: process.env.NEXT_PUBLIC_HOOK_ADDRESS as `0x${string}`,
  LICENSE_MANAGER: process.env.NEXT_PUBLIC_LICENSE_MANAGER_ADDRESS as `0x${string}`,
  ARC_ORACLE: process.env.NEXT_PUBLIC_ARC_ORACLE_ADDRESS as `0x${string}`,
  PAYMENT_MANAGER: process.env.NEXT_PUBLIC_PAYMENT_MANAGER_ADDRESS as `0x${string}`,
  POOL: process.env.NEXT_PUBLIC_POOL_ADDRESS as `0x${string}`,
} as const;

export const ENS = {
  NAME_WRAPPER: '0x0635513f179D50A207757E05759CbD106d7dFcE8' as `0x${string}`,
  RESOLVER: '0x8FADE66B79cC9f707aB26799354482EB93a5B7dD' as `0x${string}`,
  PARENT_NODE: process.env.NEXT_PUBLIC_PARENT_NODE as `0x${string}`,
} as const;

export const TOKENS = {
  USDC: '0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238' as `0x${string}`, // Sepolia USDC
  WETH: '0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14' as `0x${string}`, // Sepolia WETH
} as const;
