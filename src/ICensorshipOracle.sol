// SPDX-License-Identifier: APACHE-2.0
pragma solidity 0.8.19;

struct TestInfo {
    uint8 percentNoncensoringValidators;
    uint32 inverseConfidenceLevel;
    uint64 testStartTimestamp;
    uint64 testResultAvailableTimestamp;
    bool testHasFinished;
    bool nonCensoredBlockWasIncluded;
    uint64 testStartBlock;
}

// https://ethresear.ch/t/reducing-challenge-times-in-rollups/14997
interface ICensorshipOracle {
    function testParameters(uint256 percentNoncensoringValidators, uint256 inverseConfidenceLevel)
        external
        pure
        returns (
            uint256, // test duration
            uint256
        ); // max missing blocks allowing test to pass

    function startTest(uint256 percentNoncensoringValidators, uint256 inverseConfidenceLevel)
        external
        returns (bytes32, uint256, uint256);

    function getTestInfo(bytes32 testId)
        external
        view
        returns (
            uint256, // percent non-censoring validators
            uint256, // inverse confidence level
            uint256, // test start timestamp
            uint256, // test result available timestamp
            bool, // test has finished
            bool
        ); // (test has finished) && (non-censored block was included)

    function finishAndGetTestInfo(bytes32 testId)
        external
        returns (
            uint256, // percent non-censoring validators
            uint256, // inverse confidence level
            uint256, // test start timestamp
            uint256, // test result available timestamp
            bool, // test has finished (will be false if result not available yet)
            bool
        ); // (test has finished) && (non-censored block was included)
}
