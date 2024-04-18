// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {VaultManager, Unauthorised} from "../src/Vault-Manager.sol";

contract VaultManagerTest is Test {

    VaultManager public vaultManager;

    address public alice;
    address public bob;
    address public carol;

    function setUp() public {
        vaultManager = new VaultManager();

        alice = makeAddr("Alice");
        bob = makeAddr("Bob");
        carol = makeAddr("Carol");
    }

    function test_addVault() public {

        vm.prank(alice);

        uint256 vaultId = vaultManager.addVault("Test Vault");

        assertEq(vaultId, 0);

        vm.stopPrank();
    }


    function test_deposit() public {

        vm.startPrank(alice);
        vm.deal(alice, 100);

        //creating a test vault and adding funds
        vaultManager.addVault("Test Vault");

        bytes memory fnCall = abi.encodeWithSignature("deposit(uint256)", 0);
        (bool okay, ) = address(vaultManager).call{value: 100}(fnCall);

        assertEq(true, okay);

        //checking to see that the funds have been added and the balance is at the expected 100
        (,uint256 balance) = vaultManager.getVault(0);

        assertEq(balance, 100);
        vm.stopPrank();
    }

    function test_withdraw() public {

        vm.startPrank(alice);
        vm.deal(alice, 100);

        //create test vaults and add funds
        vaultManager.addVault("Test Vault");
        bytes memory fnCall = abi.encodeWithSignature("deposit(uint256)", 0);
        (bool okay, ) = address(vaultManager).call{value: 100}(fnCall);
        assertEq(true, okay);

        //test withdraw function
        vaultManager.withdraw(0, 50);

        //checking balance to confirm correct amount was withdrawn
        (,uint256 balance) = vaultManager.getVault(0);

        assertEq(balance, 50);
        vm.stopPrank();
    }

    function test_multipleVaults() public {

        vm.startPrank(alice);
        vm.deal(alice, 200);

        //create two tests vaults for alice
        vaultManager.addVault("Test Vault alice 1");
        vaultManager.addVault("Test Vault alice 2");

        //add funds to those vaults
        bytes memory fnCall = abi.encodeWithSignature("deposit(uint256)", 0);
        (bool okay, ) = address(vaultManager).call{value: 100}(fnCall);
        assertEq(true, okay);

        //checking to see if the funds were successfully depoisited
        (,uint256 balance) = vaultManager.getVault(0);
        assertEq(balance, 100);

        fnCall = abi.encodeWithSignature("deposit(uint256)", 1);
        (okay, ) = address(vaultManager).call{value: 100}(fnCall);
        assertEq(true, okay);

        (, balance) = vaultManager.getVault(1);
        assertEq(balance, 100);

        //checking to see if the numbers of vaults are correct
        assertEq(vaultManager.getVaultsLength(), 2);

        //using getMyVaults to check if alice has the correct amount of vaults, which should be 2
        assertEq(vaultManager.getMyVaults().length, 2);

        vm.stopPrank();

        //creating a new vault for bob
        vm.startPrank(bob);
        vm.deal(bob, 200);
        vaultManager.addVault("Test Vault bob");

        //adding funds to bob's vault
        fnCall = abi.encodeWithSignature("deposit(uint256)", 2);
        (okay, ) = address(vaultManager).call{value: 100}(fnCall);
        assertEq(true, okay);

        (,balance) = vaultManager.getVault(1);
        assertEq(balance, 100);

        //checking to see if the numbers of vaults are correct again after new users makes another vault
        assertEq(vaultManager.getVaultsLength(), 3);

        //check to see if bob has the correct amount of vaults, which should be 1
        assertEq(vaultManager.getMyVaults().length, 1);

        vm.stopPrank();
    }

    function test_widthdraw_by_other_user() public {

        vm.startPrank(alice);
        vm.deal(alice, 200);

        //creating a test vault for alice and adding funds
        vaultManager.addVault("Test Vault alice");

        bytes memory fnCall = abi.encodeWithSignature("deposit(uint256)", 0);
        (bool okay, ) = address(vaultManager).call{value: 100}(fnCall);
        assertEq(true, okay);

        vm.stopPrank();

        vm.startPrank(bob);
        vm.deal(bob, 200);

        //trying to withdraw funds from alice's vault as bob and checking to make sure it fails
        fnCall = abi.encodeWithSignature("withdraw(uint256,uint256)", 0, 50);
        (okay, ) = address(vaultManager).call(fnCall);
        assertEq(false, okay);

        vm.stopPrank();
    }

    function test_deposit_by_other_user() public {

        vm.startPrank(alice);
        vm.deal(alice, 200);

        //creating a test vault for alice and adding funds
        vaultManager.addVault("Test Vault alice");

        bytes memory fnCall = abi.encodeWithSignature("deposit(uint256)", 0);
        (bool okay, ) = address(vaultManager).call{value: 100}(fnCall);
        assertEq(true, okay);

        vm.stopPrank();

        vm.startPrank(bob);
        vm.deal(bob, 200);

        //this time trying to depoist funds into alice's vault as bob and checking to make sure it fails
        fnCall = abi.encodeWithSignature("deposit(uint256)", 0);
        (okay, ) = address(vaultManager).call{value: 100}(fnCall);
        assertEq(false, okay);

        vm.stopPrank();
    }

    
}
