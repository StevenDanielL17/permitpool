import {
    createECDSAMessageSigner,
    createEIP712AuthMessageSigner,
    createAuthVerifyMessageFromChallenge,
    createAuthRequestMessage,
    createGetConfigMessage,
} from '@erc7824/nitrolite';
import { createWalletClient, http } from 'viem';
import { sepolia } from 'viem/chains';
import { privateKeyToAccount, generatePrivateKey } from 'viem/accounts';
import WebSocket from 'ws';
import 'dotenv/config';

console.log('Starting Auth Check...\n');

// Main wallet
let PRIVATE_KEY = process.env.PRIVATE_KEY as `0x${string}`;
if (!PRIVATE_KEY) {
    throw new Error('PRIVATE_KEY not set in .env');
}

const account = privateKeyToAccount(PRIVATE_KEY);
console.log('✓ Main Wallet:', account.address);

// Wallet client for signing
const walletClient = createWalletClient({
    chain: sepolia,
    transport: http(),
    account,
});

// Session key
const sessionPrivateKey = generatePrivateKey();
const sessionAccount = privateKeyToAccount(sessionPrivateKey);
const sessionSigner = createECDSAMessageSigner(sessionPrivateKey);

console.log('✓ Session Key:', sessionAccount.address);

// Auth params (defined ONCE, reused for both request and verification)
const authParams = {
    session_key: sessionAccount.address,
    allowances: [{
        asset: 'ytest.usd',
        amount: '1000000000'
    }],
    expires_at: BigInt(Math.floor(Date.now() / 1000) + 3600),
    scope: 'test.app',
};

// Connect to Yellow Network
const ws = new WebSocket('wss://clearnet-sandbox.yellow.com/ws');

let isAuthenticated = false;

ws.onopen = async () => {
    console.log('\n✅ WebSocket Connected\n');

    // Step 1: Send auth request
    console.log('📤 [STEP 1] Sending auth_request...');
    const authRequestMsg = await createAuthRequestMessage({
        address: account.address,
        application: 'Test app',
        ...authParams
    });
    ws.send(authRequestMsg);
};

ws.onmessage = async (event) => {
    const response = JSON.parse(event.data.toString());
    const method = response.res?.[1];
    
    console.log(`📨 Received: ${method}\n`);

    if (method === 'auth_challenge') {
        if (isAuthenticated) {
            console.log('  ⚠️  Ignoring auth_challenge (already authenticated)');
            return;
        }

        console.log('🔐 [STEP 2] Received auth_challenge');
        const challenge = response.res[2].challenge_message;
        console.log('  Challenge:', challenge);

        // Step 2: Sign challenge with main wallet
        console.log('\n✍️  [STEP 3] Signing with main wallet (EIP-712)...');
        
        const signer = createEIP712AuthMessageSigner(
            walletClient,
            authParams,
            { name: 'Test app' }
        );

        const verifyMsg = await createAuthVerifyMessageFromChallenge(signer, challenge);
        console.log('  ✓ Signature generated, sending auth_verify...\n');
        ws.send(verifyMsg);
    }

    if (method === 'auth_verify') {
        isAuthenticated = true;
        console.log('✅ [SUCCESS] AUTH VERIFIED!\n');
        console.log('  Address:', response.res[2].address);
        console.log('  Session Key:', response.res[2].session_key);
        console.log('  JWT Token Received:', response.res[2].jwt_token ? '✓ Yes' : '✗ No');
        console.log('\n🎉 Authentication Complete!\n');
        process.exit(0);
    }

    if (response.error) {
        console.error('❌ Error:', JSON.stringify(response.error, null, 2));
        process.exit(1);
    }
    
    if (method === 'error') {
        console.error('❌ Error Response:', JSON.stringify(response.res[2], null, 2));
        process.exit(1);
    }
};

ws.onerror = (error) => {
    console.error('❌ WebSocket Error:', error);
    process.exit(1);
};

ws.onclose = () => {
    console.log('⚠️  WebSocket Closed');
    if (!isAuthenticated) {
        console.error('❌ Auth failed - connection closed');
        process.exit(1);
    }
};

// Timeout handler
setTimeout(() => {
    console.error('❌ Timeout: No response from server');
    process.exit(1);
}, 30000);
