// ABIs for PermitPool contracts
// Generated from: forge inspect ContractName abi

export const HOOK_ABI = [
  {
    inputs: [{ name: 'user', type: 'address' }],
    name: 'getENSNodeForAddress',
    outputs: [{ name: '', type: 'bytes32' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ name: 'node', type: 'bytes32' }],
    name: 'revokeLicense',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [{ name: 'node', type: 'bytes32' }],
    name: 'restoreLicense',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [{ name: 'user', type: 'address' }],
    name: 'batchVerifyLicense',
    outputs: [
      { name: 'isValid', type: 'bool' },
      { name: 'node', type: 'bytes32' },
      { name: 'revoked', type: 'bool' },
      { name: 'paymentCurrent', type: 'bool' },
    ],
    stateMutability: 'view',
    type: 'function',
  },
] as const;

export const LICENSE_MANAGER_ABI = [
  {
    inputs: [
      { name: 'licensee', type: 'address' },
      { name: 'label', type: 'string' },
      { name: 'arcCredentialHash', type: 'string' },
    ],
    name: 'issueLicense',
    outputs: [{ name: 'node', type: 'bytes32' }],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      { name: 'licensee', type: 'address', indexed: true },
      { name: 'label', type: 'string', indexed: false },
      { name: 'node', type: 'bytes32', indexed: true },
      { name: 'arcCredentialHash', type: 'string', indexed: false },
    ],
    name: 'LicenseIssued',
    type: 'event',
    anonymous: false,
  },
] as const;

export const ARC_ORACLE_ABI = [
  {
    inputs: [{ name: 'credentialHash', type: 'bytes32' }],
    name: 'isValidCredential',
    outputs: [{ name: '', type: 'bool' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      { name: 'credentialHash', type: 'bytes32' },
      { name: 'holder', type: 'address' },
    ],
    name: 'issueCredential',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [{ name: 'credentialHash', type: 'bytes32' }],
    name: 'revokeCredential',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
] as const;
