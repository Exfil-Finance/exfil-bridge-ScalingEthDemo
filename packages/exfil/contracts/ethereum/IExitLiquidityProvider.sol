pragma solidity ^0.6.11;

interface IExitLiquidityProvider {
    function requestLiquidity(
        address dest,
        address erc20,
        uint256 amount,
        uint256 exitNum,
        bytes calldata liquidityProof
    ) external;
}
