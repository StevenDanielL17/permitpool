import WebSocket from "ws";
import "dotenv/config";
import { privateKeyToAccount, generatePrivateKey } from "viem/accounts";
import { createECDSAMessageSigner } from "@erc7824/nitrolite";
import * as THREE from 'three'


// ---------- MAIN WALLET ----------
const account = privateKeyToAccount(process.env.PRIVATE_KEY as `0x${string}`);

// ---------- SESSION KEY ----------
const sessionPrivateKey = generatePrivateKey();
const sessionSigner = createECDSAMessageSigner(sessionPrivateKey);
const sessionAccount = privateKeyToAccount(sessionPrivateKey);

// ---------- WS ----------
const ws = new WebSocket("wss://clearnet-sandbox.yellow.com/ws");

ws.on("open", async () => {
  console.log("✅ WS Connected");
  console.log("Using Account:", account.address);

  // Send Auth Request (Simple JSON format)
  const authMsg = JSON.stringify({
    type: "auth_request",
    address: account.address,
    application: "PermitPool",
    session_key: sessionAccount.address,
    allowances: [{ asset: "ytest.usd", amount: "1000000000" }],
    expires_at: Math.floor(Date.now() / 1000) + 3600,
    scope: "permitpool.test",
  });

  ws.send(authMsg);
  console.log("📤 Auth request sent (Simple JSON)");
});

ws.on('message', async (raw) => {
  const msg = JSON.parse(raw.toString())
  console.log('Received:', JSON.stringify(msg, null, 2)) 

  // Ensure we handle both cases where 'type' is top-level (Simple) or nested (Nitrolite implied)
  // But since we sent Simple, receiving Simple is expected.
  // If server forces Nitrolite response to Simple request, we adapt.
  
  let msgType = msg.type;
  let challengePayload = msg.challenge; // Simple JSON location

  // Just in case server forces array structure even for simple request:
  if (!msgType && msg.res && Array.isArray(msg.res)) {
      msgType = msg.res[1];
      const payload = msg.res[2];
      challengePayload = payload.challenge_message || payload.challenge;
  }

  // AUTH CHALLENGE
  if (msgType === 'auth_challenge') {
    if (!challengePayload) {
        console.error("UNKNOWN CHALLENGE FORMAT", msg);
        return;
    }

    console.log("Signing Challenge:", challengePayload);
    
    // Sign the challenge string directly (EIP-191)
    const signature = await account.signMessage({
      message: challengePayload,
    })

    ws.send(JSON.stringify({
      type: 'auth_response',
      address: account.address,
      signature,
    }))

    console.log('auth response sent')
  }

  // AUTH SUCCESS
  if (msgType === 'auth_success') {
    console.log('✅ AUTH SUCCESS')
    
    // 3️⃣ AFTER FAUCET -> SEND allocate_amount
    console.log('Sending allocate_amount...')
    ws.send(JSON.stringify({
      type: 'allocate_amount',
      asset: 'USDC',
      amount: '1000'
    }))
  }

  // ALLOCATE SUCCESS
  if (msgType === 'allocate_amount_success') {
      console.log('✅ ALLOCATE AMOUNT SUCCESS', msg)
  }

  if (msgType === 'auth_error' || msgType === 'error') {
    console.error('❌ AUTH FAILED', msg)
    process.exit(1)
  }
})

ws.on('error', console.error);
