// ==========================================
// TRADER APP DEBUG SCRIPT
// ==========================================
// Run this in the browser console while on localhost:3001

async function debugTraderApp() {
  console.log("🔍 TRADER APP DIAGNOSTICS\n");
  
  // 1. Check Environment Variables
  console.log("📋 ENVIRONMENT VARIABLES:");
  console.log("LICENSE_MANAGER:", process.env.NEXT_PUBLIC_LICENSE_MANAGER_ADDRESS);
  console.log("PARENT_DOMAIN:", process.env.NEXT_PUBLIC_PARENT_DOMAIN);
  console.log("CHAIN_ID:", process.env.NEXT_PUBLIC_CHAIN_ID);
  console.log("HOOK:", process.env.NEXT_PUBLIC_HOOK_ADDRESS);
  console.log("");
  
  // 2. Check Wallet Connection
  console.log("💳 WALLET STATUS:");
  if (!window.ethereum) {
    console.error("❌ No MetaMask detected!");
    return;
  }
  
  const accounts = await window.ethereum.request({ method: 'eth_accounts' });
  if (accounts.length === 0) {
    console.warn("⚠️  No wallet connected!");
    return;
  }
  
  const address = accounts[0];
  console.log("✅ Connected:", address);
  console.log("");
  
  // 3. Check Current Network
  console.log("🌐 NETWORK:");
  const chainId = await window.ethereum.request({ method: 'eth_chainId' });
  console.log("Current Chain ID:", chainId);
  console.log("Expected Chain ID:", "0xaa36a7 (Sepolia)");
  if (chainId !== "0xaa36a7") {
    console.error("❌ WRONG NETWORK! Switch to Sepolia!");
  }
  console.log("");
  
  // 4. Check Reverse ENS Resolution
  console.log("🔄 REVERSE ENS LOOKUP:");
  try {
    const { BrowserProvider } = await import('ethers');
    const provider = new BrowserProvider(window.ethereum);
    
    console.log("Looking up ENS name for:", address);
    const ensName = await provider.lookupAddress(address);
    
    if (!ensName) {
      console.error("❌ NO REVERSE ENS RESOLUTION SET!");
      console.log("Your address doesn't resolve to an ENS name.");
      console.log("This is why the app can't detect your license!");
      console.log("");
      console.log("🔧 FIX: You need to set the reverse resolver for", address);
    } else {
      console.log("✅ ENS Name Found:", ensName);
      
      if (ensName.endsWith('.hedgefund-v3.eth')) {
        console.log("✅ VALID LICENSE DETECTED!");
      } else {
        console.warn("⚠️  ENS name doesn't end with .hedgefund-v3.eth");
      }
    }
  } catch (error) {
    console.error("Error during reverse lookup:", error);
  }
  console.log("");
  
  // 5. Check Forward ENS Resolution
  console.log("➡️  FORWARD ENS LOOKUP:");
  try {
    const { BrowserProvider } = await import('ethers');
    const provider = new BrowserProvider(window.ethereum);
    
    const testName = "dexter.hedgefund-v3.eth";
    console.log("Resolving:", testName);
    const resolved = await provider.resolveName(testName);
    console.log("Resolves to:", resolved);
    console.log("Your address:", address);
    
    if (resolved?.toLowerCase() === address.toLowerCase()) {
      console.log("✅ Forward resolution matches!");
    } else {
      console.warn("⚠️  Forward resolution doesn't match your address");
    }
  } catch (error) {
    console.error("Error during forward lookup:", error);
  }
  console.log("");
  
  // 6. Summary
  console.log("📊 SUMMARY:");
  console.log("The Trader App uses REVERSE ENS lookup to detect licenses.");
  console.log("It checks: wallet address → ENS name → is it *.hedgefund-v3.eth?");
  console.log("");
  console.log("If reverse resolution isn't working, the license won't be detected,");
  console.log("even if forward resolution (dexter.hedgefund-v3.eth → address) works!");
}

// Auto-run
debugTraderApp();
