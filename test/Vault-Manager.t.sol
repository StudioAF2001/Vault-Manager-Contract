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

        vaultManager.addVault("Test Vault");

        bytes memory fnCall = abi.encodeWithSignature("deposit(uint256)", 0);
        (bool okay, ) = address(vaultManager).call{value: 100}(fnCall);

        assertEq(true, okay);

        (,uint256 balance) = vaultManager.getVault(0);

        assertEq(balance, 100);
        vm.stopPrank();
    }

    function test_withdraw() public {

        vm.startPrank(alice);
        vm.deal(alice, 100);

        vaultManager.addVault("Test Vault");
        bytes memory fnCall = abi.encodeWithSignature("deposit(uint256)", 0);
        (bool okay, ) = address(vaultManager).call{value: 100}(fnCall);
        assertEq(true, okay);

        vaultManager.withdraw(0, 50);

        (,uint256 balance) = vaultManager.getVault(0);

        assertEq(balance, 50);
        vm.stopPrank();
    }

    function test_multipleVaults() public {

        vm.startPrank(alice);
        vm.deal(alice, 200);

        vaultManager.addVault("Test Vault alice 1");
        vaultManager.addVault("Test Vault alice 2");

        bytes memory fnCall = abi.encodeWithSignature("deposit(uint256)", 0);
        (bool okay, ) = address(vaultManager).call{value: 100}(fnCall);
        assertEq(true, okay);

        (,uint256 balance) = vaultManager.getVault(0);
        assertEq(balance, 100);

        fnCall = abi.encodeWithSignature("deposit(uint256)", 1);
        (okay, ) = address(vaultManager).call{value: 100}(fnCall);
        assertEq(true, okay);

        (, balance) = vaultManager.getVault(1);
        assertEq(balance, 100);

        assertEq(vaultManager.getVaultsLength(), 2);

        vm.stopPrank();

        vm.startPrank(bob);
        vm.deal(bob, 200);
        vaultManager.addVault("Test Vault bob");

        fnCall = abi.encodeWithSignature("deposit(uint256)", 2);
        (okay, ) = address(vaultManager).call{value: 100}(fnCall);
        assertEq(true, okay);


        (,balance) = vaultManager.getVault(1);
        assertEq(balance, 100);

        assertEq(vaultManager.getVaultsLength(), 3);

        uint256[] memory bobsVaults = vaultManager.getMyVaults();

        assertEq(bobsVaults.length, 1);
        vm.stopPrank();
    }

    function test_widthdraw_by_other_user() public {

        vm.startPrank(alice);
        vm.deal(alice, 200);

        vaultManager.addVault("Test Vault alice");

        bytes memory fnCall = abi.encodeWithSignature("deposit(uint256)", 0);
        (bool okay, ) = address(vaultManager).call{value: 100}(fnCall);
        assertEq(true, okay);

        vm.stopPrank();

        vm.startPrank(bob);
        vm.deal(bob, 200);

        fnCall = abi.encodeWithSignature("withdraw(uint256,uint256)", 0, 50);
        (okay, ) = address(vaultManager).call(fnCall);
        assertEq(false, okay);

        vm.stopPrank();
    }

    
}
