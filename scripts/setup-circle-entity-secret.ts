#!/usr/bin/env node

/**
 * Circle Entity Secret Setup Script
 * 
 * This script generates and registers an Entity Secret with Circle for developer-controlled wallets.
 * 
 * Prerequisites:
 * 1. Circle Developer Account (https://console.circle.com)
 * 2. Circle API Key with appropriate permissions
 * 3. Node.js installed
 * 
 * Usage:
 * npx ts-node scripts/setup-circle-entity-secret.ts
 * 
 * The script will:
 * 1. Generate a 32-byte Entity Secret
 * 2. Register it with Circle (encrypted)
 * 3. Save recovery file
 * 4. Output environment variables to use in .env
 */

import * as fs from 'fs';
import * as path from 'path';

// Colors for terminal output
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  red: '\x1b[31m',
  cyan: '\x1b[36m',
};

async function setupEntitySecret() {
  console.log(`\n${colors.cyan}=== Circle Entity Secret Setup ===${colors.reset}\n`);

  // Check if Circle SDK is installed
  try {
    require.resolve('@circle-fin/developer-controlled-wallets');
  } catch (e) {
    console.log(`${colors.red}❌ Circle SDK not installed${colors.reset}`);
    console.log(`\nInstall it with:\n`);
    console.log(`${colors.yellow}npm install @circle-fin/developer-controlled-wallets${colors.reset}\n`);
    process.exit(1);
  }

  try {
    const {
      generateEntitySecret,
      registerEntitySecretCiphertext,
    } = require('@circle-fin/developer-controlled-wallets');

    // Load API key from environment
    const apiKey = process.env.CIRCLE_API_KEY;
    if (!apiKey) {
      console.log(`${colors.red}❌ CIRCLE_API_KEY not found in environment${colors.reset}`);
      console.log(`\nSet it with:\n`);
      console.log(`${colors.yellow}export CIRCLE_API_KEY="your_api_key_here"${colors.reset}\n`);
      process.exit(1);
    }

    console.log(`${colors.yellow}Step 1: Generating Entity Secret...${colors.reset}`);
    const entitySecret = generateEntitySecret();
    console.log(`${colors.green}✓ Entity Secret generated${colors.reset}`);
    console.log(`   Length: ${entitySecret.length} characters\n`);

    console.log(`${colors.yellow}Step 2: Registering with Circle...${colors.reset}`);
    
    // Create recovery file path
    const recoveryDir = path.join(process.cwd(), '.circle-recovery');
    if (!fs.existsSync(recoveryDir)) {
      fs.mkdirSync(recoveryDir, { recursive: true });
    }
    const recoveryFilePath = path.join(recoveryDir, `entity-secret-recovery-${Date.now()}.json`);

    const response = await registerEntitySecretCiphertext({
      apiKey,
      entitySecret,
      recoveryFileDownloadPath: recoveryFilePath,
    });

    if (response.data?.recoveryFile) {
      console.log(`${colors.green}✓ Entity Secret registered with Circle${colors.reset}`);
      console.log(`${colors.green}✓ Recovery file saved${colors.reset}`);
      console.log(`   Path: ${recoveryFilePath}\n`);
    }

    // Display environment variables to add
    console.log(`${colors.cyan}============= ADD TO .env ==============${colors.reset}\n`);
    console.log(`${colors.yellow}# Circle Entity Secret${colors.reset}`);
    console.log(`CIRCLE_ENTITY_SECRET="${entitySecret}"`);
    console.log(`CIRCLE_RECOVERY_FILE="${recoveryFilePath}"\n`);

    // Display important warnings
    console.log(`${colors.red}⚠️  IMPORTANT - SECURE YOUR FILES ⚠️${colors.reset}\n`);
    console.log(`${colors.yellow}1. Store Entity Secret in password manager${colors.reset}`);
    console.log(`${colors.yellow}2. Save recovery file in separate secure location${colors.reset}`);
    console.log(`${colors.yellow}3. Never commit these to git (add to .gitignore)${colors.reset}`);
    console.log(`${colors.yellow}4. Circle cannot recover lost Entity Secrets${colors.reset}\n`);

    // Save sample .env snippet
    const envSnippet = `# Circle Entity Secret (GENERATED - ${new Date().toISOString()})
CIRCLE_ENTITY_SECRET="${entitySecret}"
CIRCLE_RECOVERY_FILE="${recoveryFilePath}"
CIRCLE_API_KEY="${apiKey}"
`;

    const envSnippetPath = path.join(process.cwd(), '.env.circle-snippet');
    fs.writeFileSync(envSnippetPath, envSnippet);
    console.log(`${colors.green}✓ Sample .env snippet saved to: ${envSnippetPath}${colors.reset}\n`);

  } catch (error) {
    console.error(`${colors.red}❌ Error during setup:${colors.reset}`);
    console.error(error);
    process.exit(1);
  }
}

// Run the setup
setupEntitySecret().catch(console.error);
