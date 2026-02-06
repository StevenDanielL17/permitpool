// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {LicenseManager} from "../src/LicenseManager.sol";
import {ArcOracle} from "../src/ArcOracle.sol";
import {MockArcVerifier} from "../src/MockArcVerifier.sol";
import {INameWrapper} from "../src/interfaces/INameWrapper.sol";

contract FixLicenseSetup is Script {
    function run() external {
        address licenseManagerAddr = vm.envAddress("NEXT_PUBLIC_LICENSE_MANAGER_ADDRESS");
        address nameWrapperAddr = vm.envAddress("ENS_NAME_WRAPPER");
        uint256 ownerPrivateKey = vm.envUint("OWNER_PRIVATE_KEY");
        address owner = vm.envAddress("OWNER_ADDRESS");
        
        require(licenseManagerAddr != address(0), "LicenseManager Address Missing");

        vm.startBroadcast(ownerPrivateKey);

        // 1. Dynamic Discovery of Dependencies
        LicenseManager lm = LicenseManager(licenseManagerAddr);
        address oracleAddr = address(lm.arcOracle());
        console.log("Found ArcOracle at:", oracleAddr);
        
        ArcOracle oracle = ArcOracle(oracleAddr);
        address verifierAddr = oracle.arcVerifier();
        console.log("Found ArcVerifier at:", verifierAddr);
        
        MockArcVerifier verifier = MockArcVerifier(verifierAddr);

        // 2. Register Credential
        string memory validCred = "VALID_ARC_TEST_CREDENTIAL";
        console.log("Whitelisting Credential:", validCred);
        verifier.setValid(validCred);
        
        // 3. Approve ENS
        console.log("Approving LicenseManager on NameWrapper...");
        INameWrapper nameWrapper = INameWrapper(nameWrapperAddr);
        // Check if already approved to save gas
        if (!nameWrapper.isApprovedForAll(owner, licenseManagerAddr)) {
            nameWrapper.setApprovalForAll(licenseManagerAddr, true);
            console.log("Approved.");
        } else {
            console.log("Already approved.");
        }

        vm.stopBroadcast();
    }
}
