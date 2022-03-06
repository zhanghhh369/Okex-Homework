pragma solidity ^0.8.4;

contract Teacher {
    address public scoreAddress;

    constructor() {
        Score score = new Score(msg.sender);
        scoreAddress = address(score);
    }
    function getGrade(address studentAddr) external view returns (uint) {
        return IScore(scoreAddress).getGrade(studentAddr);
    }
    function setGrade(address studentAddr, uint grade) external {
        IScore(scoreAddress).setGrade(studentAddr, grade);
    }
}

interface IScore {
    function getGrade(address studentAddr) external view returns (uint);
    function setGrade(address studentAddr, uint grade) external;
}


contract Score {
    address teacherAddr;
    mapping(address => uint) public grades;
    constructor(address teacherAddrNew){
        teacherAddr = teacherAddrNew;
    }
    modifier onlyTeacher() {
        require(msg.sender == teacherAddr, "Must be teacher");
        _;
    }
    modifier lessThan100(uint grade) {
        require(grade<100, "Scores are too large");
        _;
    }
    function setGrade(address studentAddr, uint grade) public onlyTeacher lessThan100(grade) {
        grades[studentAddr] = grade;
    }
    function getGrade(address studentAddr) public view returns (uint) {
        return grades[studentAddr];
    }
}