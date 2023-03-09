// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../src/CensorshipOracle.sol";

contract CensorshipOracleTest is Test {
    ICensorshipOracle public oracle;

    error AlreadyFinished();
    error TooSoon();
    error NoSuchTest();

    event TestStarted(bytes32 indexed testId, uint256 percentNoncensoringValidators, uint256 inverseConfidenceLevel);
    event TestFinished(bytes32 indexed testId, bool nonCensoredBlockWasIncluded);

    function setUp() public {
        oracle = new CensorshipOraclePOC();
    }

    function testStartTest() public returns (bytes32) {
        vm.expectEmit(false, false, false, false);
        emit TestStarted(bytes32(0), 0, 0);
        (bytes32 testId,,) = oracle.startTest(10, 100);
        return testId;
    }

    function testCompleteTestWithCensor(uint256 missedBlocks) public {
        bytes32 testId = testStartTest();
        (uint256 percentNoncensoringValidators, uint256 inverseConfidenceLevel,, uint256 testResultAvailableTimestamp,,)
        = oracle.getTestInfo(testId);
        (, uint256 maxMissBlock) = oracle.testParameters(percentNoncensoringValidators, inverseConfidenceLevel);
        uint256 missedBlocks = 20;
        vm.assume(missedBlocks > maxMissBlock);
        vm.roll(block.number + (testResultAvailableTimestamp - block.timestamp) / 12 - missedBlocks);
        vm.warp(testResultAvailableTimestamp);
        vm.expectEmit(true, true, true, true);
        emit TestFinished(testId, false);
        oracle.finishAndGetTestInfo(testId);
    }

    function testCompleteTestWithoutCensor(uint256 missedBlocks) public {
        bytes32 testId = testStartTest();
        (uint256 percentNoncensoringValidators, uint256 inverseConfidenceLevel,, uint256 testResultAvailableTimestamp,,)
        = oracle.getTestInfo(testId);
        (, uint256 maxMissBlock) = oracle.testParameters(percentNoncensoringValidators, inverseConfidenceLevel);
        vm.assume(missedBlocks <= maxMissBlock);
        vm.roll(block.number + (testResultAvailableTimestamp - block.timestamp) / 12 - missedBlocks);
        vm.warp(testResultAvailableTimestamp);
        vm.expectEmit(true, true, true, true);
        emit TestFinished(testId, true);
        oracle.finishAndGetTestInfo(testId);
    }

    function testDuplicateTestSuccess() external {
        testStartTest();
        testStartTest();
    }

    function testRevertTooSoon() external {
        bytes32 testId = testStartTest();
        (,,, uint256 testResultAvailableTimestamp,,) = oracle.getTestInfo(testId);
        vm.warp(testResultAvailableTimestamp - 1);
        vm.expectRevert(TooSoon.selector);
        oracle.finishAndGetTestInfo(testId);
    }

    function testRevertNoTest() external {
        vm.expectRevert(NoSuchTest.selector);
        oracle.finishAndGetTestInfo(bytes32(0));
    }

    function testRevertAlreadFinished() external {
        bytes32 testId = testStartTest();
        (,,, uint256 testResultAvailableTimestamp,,) = oracle.getTestInfo(testId);
        vm.warp(testResultAvailableTimestamp);
        oracle.finishAndGetTestInfo(testId);
        vm.expectRevert(AlreadyFinished.selector);
        oracle.finishAndGetTestInfo(testId);
    }
}
