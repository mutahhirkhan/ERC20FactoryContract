// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
import "./MutahhirERC20.sol";

contract ERC20Factory {
    event Deployed(address addr, uint salt);

    // 1. Get bytecode of contract to be deployed
    // NOTE: _name, _symbol, _decimals and _totalSupply are arguments of the MutahhirERC20's constructor
    function getBytecode(string memory _name, string memory _symbol, uint8 _decimals, uint _totalSupply) public pure returns (bytes memory) {
        bytes memory bytecode = type(MutahhirERC20).creationCode;

        return abi.encodePacked(bytecode, abi.encode(_name, _symbol, _decimals, _totalSupply));
    }

    // 2. Compute the address of the contract to be deployed
    // NOTE: _salt is a random number used to create an address
    function getAddress(bytes memory bytecode, uint _salt)
        public
        view
        returns (address)
    {
        bytes32 hash = keccak256(
            abi.encodePacked(bytes1(0xff), address(this), _salt, keccak256(bytecode))
        );

        // NOTE: cast last 20 bytes of hash to address
        return address(uint160(uint(hash)));
    }

    // 3. Deploy the contract
    // NOTE:
    // Check the event log Deployed which contains the address of the deployed MutahhirERC20.
    // The address in the log should equal the address computed from above.
    //make sure the salt is same as getAddress function
    function deploy(bytes memory bytecode, uint _salt) public payable {
        address addr;

        /*
        NOTE: How to call create2

        create2(v, p, n, s)
        create new contract with code at memory p to p + n
        and send v wei
        and return the new address
        where new address = first 20 bytes of keccak256(0xff + address(this) + s + keccak256(mem[p…(p+n)))
              s = big-endian 256-bit value
        */
        assembly {
            addr := create2(
                callvalue(), // wei sent with current call
                // Actual code starts after skipping the first 32 bytes
                add(bytecode, 0x20),
                mload(bytecode), // Load the size of code contained in the first 32 bytes
                _salt // Salt from function arguments
            )

            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }

        emit Deployed(addr, _salt);
    }
}