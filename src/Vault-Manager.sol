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
    event VaultWithdraw(uint256 id, address owner, uint256 amount);

    modifier onlyOwner (uint256 _vaultId){
        if (vaults[_vaultId].owner != msg.sender){
            revert Unauthorised();
        }

        _;
    }

    function addVault(string calldata _name) public returns (uint256 vaultId){
        Vault memory vault = Vault({
            name: _name,
            owner: msg.sender,
            balance: 0
        });

        vaults.push(vault);
        vaultId = vaults.length - 1;

        vaultsByOwner[msg.sender].push(vaultId);

        emit VaultAdded(vaultId, msg.sender);
    }

    function deposit(uint256 _vaultId) payable public onlyOwner(_vaultId) {
        vaults[_vaultId].balance = vaults[_vaultId].balance + msg.value;

        emit VaultDeposit(_vaultId, msg.sender, msg.value);
    }

    function withdraw(uint256 _vaultId, uint256 amount) public onlyOwner(_vaultId){
        require(vaults[_vaultId].balance >= amount, "Not enough funds in the vault :(");

        vaults[_vaultId].balance = vaults[_vaultId].balance - amount;

        payable(vaults[_vaultId].owner).transfer(amount);
        
        emit VaultWithdraw(_vaultId, msg.sender, amount);
    }

    function getVaultsLength() public view returns (uint256) {
        return vaults.length;
    }

    function getVault(uint256 _vaultId) public view returns (address owner, uint256 balance) {
        balance = vaults[_vaultId].balance;
        owner = vaults[_vaultId].owner;
    }

    function getMyVaults() public view returns (uint256[] memory){
        return vaultsByOwner[msg.sender];
    }

}
