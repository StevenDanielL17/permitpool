import {
    NitroliteClient,
    WalletStateSigner,
    createECDSAMessageSigner,
    createEIP712AuthMessageSigner,
    createAuthVerifyMessageFromChallenge,
    createAuthRequestMessage,
    createGetLedgerBalancesMessage,
    createCreateChannelMessage,
    createResizeChannelMessage,
    createTransferMessage,
    createCloseChannelMessage,
} from '@erc7824/nitrolite';
import { createPublicClient, createWalletClient, http } from 'viem';
import { sepolia } from 'viem/chains';
import { privateKeyToAccount, generatePrivateKey } from 'viem/accounts';
import WebSocket from 'ws';
import 'dotenv/config';

console.log('🚀 Yellow Clearnet Flow (Post-Auth)\n');

// Main wallet
let PRIVATE_KEY = process.env.PRIVATE_KEY as `0x${string}`;
if (!PRIVATE_KEY) {
    throw new Error('PRIVATE_KEY not set in .env');
}

const account = privateKeyToAccount(PRIVATE_KEY);
const walletClient = createWalletClient({
    chain: sepolia,
    transport: http(),
    account,
});

// Public client for contract calls
const publicClient = createPublicClient({
    chain: sepolia,
    transport: http(process.env.ALCHEMY_RPC_URL || 'https://1rpc.io/sepolia'),
});

// Nitrolite client for contract interactions
const client = new NitroliteClient({
    publicClient,
    walletClient,
    stateSigner: new WalletStateSigner(walletClient),
    addresses: {
        custody: '0x019B65A265EB3363822f2752141b3dF16131b262',
        adjudicator: '0x7c7ccbc98469190849BCC6c926307794fDfB11F2',
    },
    chainId: sepolia.id,
    challengeDuration: 3600n,
});

// Session key
const sessionPrivateKey = generatePrivateKey();
const sessionAccount = privateKeyToAccount(sessionPrivateKey);
const sessionSigner = createECDSAMessageSigner(sessionPrivateKey);

console.log('Main Wallet:', account.address);
console.log('Session Key:', sessionAccount.address, '\n');

// Auth params (FIXED - same for request and verify)
const authParams = {
    session_key: sessionAccount.address,
    allowances: [{
        asset: 'ytest.usd',
        amount: '1000000000'
    }],
    expires_at: BigInt(Math.floor(Date.now() / 1000) + 3600),
    scope: 'test.app',
};

// State tracking
let isAuthenticated = false;
let channelId: string | null = null;
let step = 0;

const ws = new WebSocket('wss://clearnet-sandbox.yellow.com/ws');

ws.onopen = async () => {
    console.log('✅ Connected to Clearnet\n');
    console.log('📤 [STEP 1] Sending auth_request...');
    
    const authRequestMsg = await createAuthRequestMessage({
        address: account.address,
        application: 'Yellow Flow',
        ...authParams
    });
    ws.send(authRequestMsg);
};

ws.onmessage = async (event) => {
    const data = event.data.toString();
    
    // Try to parse as JSON
    let response;
    try {
        response = JSON.parse(data);
    } catch {
        console.log('Raw message:', data);
        return;
    }

    const method = response.res?.[1] || response.type;
    
    // ============================================
    // AUTHENTICATION FLOW
    // ============================================

    if (method === 'auth_challenge') {
        if (isAuthenticated) return;
        
        console.log('🔐 Received auth_challenge');
        const challenge = response.res[2].challenge_message;
        
        const signer = createEIP712AuthMessageSigner(
            walletClient,
            authParams,
            { name: 'Yellow Flow' }
        );
        
        const verifyMsg = await createAuthVerifyMessageFromChallenge(signer, challenge);
        console.log('✍️  Signing and sending auth_verify...');
        ws.send(verifyMsg);
    }

    if (method === 'auth_verify') {
        isAuthenticated = true;
        console.log('✅ Authentication successful!\n');
        
        // Now proceed to step 1
        setTimeout(async () => {
            console.log('📤 [STEP 1] Checking unified balance...');
            const balanceMsg = await createGetLedgerBalancesMessage(
                sessionSigner,
                account.address,
                Date.now()
            );
            ws.send(balanceMsg);
        }, 1000);
    }

    // ============================================
    // POST-AUTH FLOW (Simple JSON)
    // ============================================

    // STEP 1: Get Unified Balance
    if (response.type === 'get_balances' || (response.res && response.res[1] === 'get_ledger_balances')) {
        console.log('✅ Received balance info');
        
        let balance = 0;
        if (response.res && response.res[2]?.ledger_balances) {
            const balances = response.res[2].ledger_balances;
            console.log('  Ledger Balances:', JSON.stringify(balances, null, 2));
            balance = parseInt(balances[0]?.amount || '0');
        } else if (response.balances) {
            console.log('  Balances:', JSON.stringify(response.balances, null, 2));
        }

        if (balance === 0) {
            console.error('❌ No unified balance! Run faucet first.');
            process.exit(1);
        }

        console.log(`✓ Balance available: ${balance}\n`);
        
        setTimeout(async () => {
            console.log('📤 [STEP 2] Opening channel...');
            const createChannelMsg = await createCreateChannelMessage(
                sessionSigner,
                {
                    chain_id: 11155111,
                    token: '0xDB9F293e3898c9E5536A3be1b0C56c89d2b32DEb', // ytest.usd on Sepolia
                }
            );
            ws.send(createChannelMsg);
        }, 1000);
    }

    // STEP 2: Channel Opened/Created
    if (response.type === 'channel_opened' || (response.res && response.res[1] === 'create_channel')) {
        if (response.res && response.res[1] === 'create_channel') {
            const { channel_id, channel, state, server_signature } = response.res[2];
            channelId = channel_id;
            console.log('✅ Channel created by server!');
            console.log(`  Channel ID: ${channelId}`);
            console.log('  Submitting to L1 Custody contract...\n');

            // Submit channel to L1
            setTimeout(async () => {
                try {
                    const unsignedInitialState = {
                        intent: state.intent,
                        version: BigInt(state.version),
                        data: state.state_data,
                        allocations: state.allocations.map((a: any) => ({
                            destination: a.destination,
                            token: a.token,
                            amount: BigInt(a.amount),
                        })),
                    };

                    const createResult = await client.createChannel({
                        channel,
                        unsignedInitialState,
                        serverSignature: server_signature,
                    });

                    const txHash = typeof createResult === 'string' ? createResult : (createResult as any).txHash;
                    console.log('✅ Channel submitted to L1!');
                    console.log(`  TX Hash: ${txHash}`);
                    console.log('  Waiting for confirmation...\n');

                    await publicClient.waitForTransactionReceipt({ hash: txHash as `0x${string}` });
                    console.log('✅ L1 transaction confirmed!\n');

                    console.log('📤 [STEP 3] Allocating 100 USDC to channel...');
                    const allocateMsg = await createResizeChannelMessage(
                        sessionSigner,
                        {
                            channel_id: channelId as `0x${string}`,
                            allocate_amount: 100n,
                            funds_destination: account.address,
                        }
                    );
                    ws.send(allocateMsg);
                } catch (err: any) {
                    console.error('❌ L1 Submission Error:', err.message || err);
                    process.exit(1);
                }
            }, 1000);
        } else {
            channelId = response.channel_id;
            console.log('✅ Channel opened!');
            console.log(`  Channel ID: ${channelId}\n`);
        }
    }

    // STEP 3: Allocated
    if (response.type === 'allocated' || response.type === 'allocate_success' || (response.res && response.res[1] === 'resize_channel')) {
        console.log('✅ Funds allocated by server!');
        
        if (response.res && response.res[1] === 'resize_channel') {
            const { channel_id, state, server_signature } = response.res[2];
            console.log('  Submitting resize to L1...\n');

            // Submit resize to L1
            setTimeout(async () => {
                try {
                    const resizeState = {
                        intent: state.intent,
                        version: BigInt(state.version),
                        data: state.state_data || state.data,
                        allocations: state.allocations.map((a: any) => ({
                            destination: a.destination,
                            token: a.token,
                            amount: BigInt(a.amount),
                        })),
                        channelId: channel_id,
                        serverSignature: server_signature,
                    };

                    const { txHash } = await client.resizeChannel({
                        resizeState,
                        proofStates: [],
                    });

                    console.log('✅ Resize submitted to L1!');
                    console.log(`  TX Hash: ${txHash}`);
                    console.log('  Waiting for confirmation...\n');

                    await publicClient.waitForTransactionReceipt({ hash: txHash as `0x${string}` });
                    console.log('✅ L1 transaction confirmed!\n');

                    console.log('📤 [STEP 5] Performing off-chain transfer...');
                    const transferMsg = await createTransferMessage(
                        sessionSigner,
                        {
                            destination: '0xc7E6827ad9DA2c89188fAEd836F9285E6bFdCCCC',
                            allocations: [{
                                asset: 'ytest.usd',
                                amount: '50'
                            }]
                        },
                        Date.now()
                    );
                    ws.send(transferMsg);
                } catch (err: any) {
                    console.error('❌ L1 Submission Error:', err.message || err);
                    process.exit(1);
                }
            }, 1000);
        } else {
            setTimeout(async () => {
                console.log('📤 [STEP 5] Performing off-chain transfer...');
                const transferMsg = await createTransferMessage(
                    sessionSigner,
                    {
                        destination: '0xc7E6827ad9DA2c89188fAEd836F9285E6bFdCCCC',
                        allocations: [{
                            asset: 'ytest.usd',
                            amount: '50'
                        }]
                    },
                    Date.now()
                );
                ws.send(transferMsg);
            }, 1000);
        }
    }

    // STEP 5: Transfer completed
    if (response.type === 'transfer_complete' || response.type === 'transfer_success' || (response.res && response.res[1] === 'transfer')) {
        console.log('✅ Transfer complete!\n');

        setTimeout(async () => {
            console.log('📤 [STEP 6] Closing channel...');
            const closeMsg = await createCloseChannelMessage(
                sessionSigner,
                channelId as `0x${string}`,
                account.address
            );
            ws.send(closeMsg);
        }, 1000);
    }

    // STEP 6: Channel closed
    if (response.type === 'channel_closed' || (response.res && response.res[1] === 'close_channel')) {
        if (response.res && response.res[1] === 'close_channel') {
            const { channel_id, state, server_signature } = response.res[2];
            console.log('✅ Channel close prepared by server!');
            console.log('  Submitting to L1...\n');

            setTimeout(async () => {
                try {
                    const txHash = await client.closeChannel({
                        finalState: {
                            intent: state.intent,
                            version: BigInt(state.version),
                            data: state.state_data || state.data,
                            allocations: state.allocations.map((a: any) => ({
                                destination: a.destination,
                                token: a.token,
                                amount: BigInt(a.amount),
                            })),
                            channelId: channel_id,
                            serverSignature: server_signature,
                        },
                        stateData: state.state_data || state.data || '0x',
                    });

                    console.log('✅ Channel closed on L1!');
                    console.log(`  TX Hash: ${txHash}\n`);
                    
                    await publicClient.waitForTransactionReceipt({ hash: txHash as `0x${string}` });
                    
                    console.log('🎉 YELLOW CLEARNET FLOW COMPLETE!\n');
                    console.log('Summary:');
                    console.log('  ✓ Authenticated');
                    console.log('  ✓ Checked unified balance');
                    console.log('  ✓ Created channel (L1 + Server)');
                    console.log('  ✓ Allocated funds (L1 + Server)');
                    console.log('  ✓ Performed off-chain transfer');
                    console.log('  ✓ Closed channel (L1)\n');
                    process.exit(0);
                } catch (err: any) {
                    console.error('❌ Close Error:', err.message || err);
                    process.exit(1);
                }
            }, 1000);
        } else {
            console.log('✅ Channel closed!\n');
            console.log('🎉 YELLOW CLEARNET FLOW COMPLETE!\n');
            process.exit(0);
        }
    }

    // Error handling
    if (response.error || method === 'error') {
        console.error('❌ Error:', response.error || response.res[2]);
        process.exit(1);
    }

    // Log unknown messages for debugging
    if (!isAuthenticated && method && !['assets', 'auth_challenge', 'auth_verify'].includes(method)) {
        console.log(`[DEBUG] ${method}:`, JSON.stringify(response, null, 2).substring(0, 200));
    }
};

ws.onerror = (error) => {
    console.error('❌ WebSocket error:', error);
    process.exit(1);
};

// Timeout
setTimeout(() => {
    console.error('❌ Timeout: No response from server');
    process.exit(1);
}, 60000);
