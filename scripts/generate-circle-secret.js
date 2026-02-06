#!/usr/bin/env node

/**
 * Simple Circle Entity Secret Generator
 * Generates a 32-byte entity secret and provides guidance for registration
 */

const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

// Colors
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  red: '\x1b[31m',
  cyan: '\x1b[36m',
  bold: '\x1b[1m',
};

console.log(`\n${colors.cyan}${colors.bold}=== Circle Entity Secret Generation ===${colors.reset}\n`);

try {
  // Step 1: Generate Entity Secret
  console.log(`${colors.yellow}Step 1: Generating Entity Secret...${colors.reset}`);
  
  // Generate 32-byte random hex string (for entity secret)
  const entitySecret = crypto.randomBytes(32).toString('hex');
  
  console.log(`${colors.green}✓ Entity Secret generated${colors.reset}`);
  console.log(`   Type: 32-byte hex string`);
  console.log(`   Length: ${entitySecret.length} characters\n`);

  // Step 2: Create recovery backup
  console.log(`${colors.yellow}Step 2: Creating recovery file...${colors.reset}`);
  
  const recoveryDir = path.join(process.cwd(), '.circle-recovery');
  if (!fs.existsSync(recoveryDir)) {
    fs.mkdirSync(recoveryDir, { recursive: true });
  }
  
  const timestamp = Date.now();
  const recoveryFileName = `entity-secret-recovery-${timestamp}.json`;
  const recoveryFilePath = path.join(recoveryDir, recoveryFileName);
  
  const recoveryData = {
    generatedAt: new Date().toISOString(),
    entitySecret: entitySecret,
    apiKey: process.env.CIRCLE_API_KEY ? '***MASKED***' : 'NOT_PROVIDED',
    instructions: 'Store this entity secret in a secure location. Circle cannot recover it if lost.',
  };
  
  fs.writeFileSync(recoveryFilePath, JSON.stringify(recoveryData, null, 2));
  console.log(`${colors.green}✓ Recovery file created${colors.reset}`);
  console.log(`   Path: ${recoveryFilePath}\n`);

  // Step 3: Display environment variables
  console.log(`${colors.cyan}${colors.bold}============= ADD TO .env =============${colors.reset}\n`);
  console.log(`${colors.yellow}# Circle Entity Secret (Generated: ${new Date().toISOString()})${colors.reset}`);
  console.log(`CIRCLE_ENTITY_SECRET="${entitySecret}"`);
  console.log(`CIRCLE_RECOVERY_FILE="${recoveryFilePath}"\n`);

  // Step 4: Display important warnings
  console.log(`${colors.red}${colors.bold}⚠️  IMPORTANT - SECURE YOUR FILES ⚠️${colors.reset}\n`);
  console.log(`${colors.yellow}1. Store Entity Secret in password manager${colors.reset}`);
  console.log(`   (1Password, LastPass, Bitwarden, etc.)`);
  console.log(`\n${colors.yellow}2. Move recovery file to separate secure location${colors.reset}`);
  console.log(`   mkdir -p ~/Secure/circle-backups`);
  console.log(`   mv ${recoveryFilePath} ~/Secure/circle-backups/\n`);
  console.log(`${colors.yellow}3. Never commit to git${colors.reset}`);
  console.log(`   .env and .circle-recovery/ are already gitignored\n`);
  console.log(`${colors.yellow}4. Circle cannot recover lost Entity Secrets${colors.reset}`);
  console.log(`   Loss of both entity secret AND recovery file = permanent wallet loss\n`);

  // Step 5: Next steps
  console.log(`${colors.cyan}${colors.bold}============= NEXT STEPS =============${colors.reset}\n`);
  console.log(`${colors.green}1. Copy Entity Secret above${colors.reset}`);
  console.log(`2. Create .env file: cp .env.example .env`);
  console.log(`3. Paste into .env: CIRCLE_ENTITY_SECRET="<paste here>"`);
  console.log(`4. Save recovery file: cp ${recoveryFilePath} ~/Secure/circle-backups/`);
  console.log(`5. Continue with deployment\n`);

  // Step 6: Save env snippet
  const envSnippet = `# Circle Entity Secret (Generated: ${new Date().toISOString()})
CIRCLE_ENTITY_SECRET="${entitySecret}"
CIRCLE_RECOVERY_FILE="${recoveryFilePath}"
`;

  const envSnippetPath = path.join(process.cwd(), '.env.circle-snippet');
  fs.writeFileSync(envSnippetPath, envSnippet);
  console.log(`${colors.green}✓${colors.reset} Sample .env snippet saved to: ${colors.cyan}${envSnippetPath}${colors.reset}\n`);

  console.log(`${colors.green}${colors.bold}✅ Entity Secret Generation Complete!${colors.reset}\n`);

} catch (error) {
  console.error(`${colors.red}❌ Error:${colors.reset}`);
  console.error(error.message);
  process.exit(1);
}
