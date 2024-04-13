// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

error Unauthorised();

contract VaultManager {

    struct Vault {
        string name;
        address owner;
        uint256 balance;
    }

    Vault[] public vaults;

    mapping (address => uint256[]) public vaultsByOwner;

    event VaultAdded(uint256 id, address owner);
    event VaultDeposit(uint256 id, address owner, uint256 amount);
    event VaultWithdraw();

    modifier onlyOwner (uint256 _vaultId){
        if (vaults[_vaultId].owner != msg.sender){
            revert Unauthorised();
        }

        _;
    }

    function addVault(uint256 vaultIndex, string calldata _name, string _owner) public view{
        Vault memory vault = Vault({
            name: _name,
            owner: _owner
        });


        emit VaultAdded(id, owner);
    }

    function deposit(uint256 _vaultId) public view onlyOwner(_vaultId) {
        vaults[_vaultId];

        emit VaultDeposit(id, owner, amount);
    }

    function withdraw(uint256 _vaultId, uint256 amount) public onlyOwner(_vaultId){

        
        emit VaultWithdraw();
    }

    function getVaultsLength() public view returns (uint256) {
        return vaults.length;
    }

    function getVault(uint256 _vaultId) public view returns (address owner, uint256 balance) {
        balance = vaults[_vaultId].balance;
        owner = vaults[_vaultId].owner;
    }

    function getMyVaults() public view {

    }

}
