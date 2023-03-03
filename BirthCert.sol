// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract newBirth{
    address public rootCA;
    mapping(address=>bool) Registrars;
    mapping(address=>bool) Hospitals;
    struct hospDetails{
        address hospital;
        string hospName;
        string firstLine;
        string taluka;
        string district;
        string state;
        uint pincode;
    }
    uint public hospCount=0;
    hospDetails[] public hosp;
    mapping (uint => hospDetails) public hospDeets;
    
    struct registrarDetails{
        address Registrar;
        string registrarName;
        string taluka;
        string district;
        uint pincode;
    }
    uint public registrarCount=0;
    registrarDetails[] public Reg;
    mapping (uint => registrarDetails) public registrarDeets;

    constructor() {
        rootCA=msg.sender;
    }
    modifier onlyOwner(){
        require(rootCA==msg.sender, "Only Root Certificate Authority can access this function");
        _;
    }

    modifier onlyRegistrar() {
        require(Registrars[msg.sender], "Only Registrars can access this function");
        _;
    }

    function WhiteListRegistrars (address user, string memory name, string memory taluka, string memory district , uint pincode) public onlyOwner {
        Registrars[user]=true;
        registrarDeets[registrarCount].Registrar = user;
        registrarDeets[registrarCount].registrarName = name;
        registrarDeets[registrarCount].taluka = taluka;
        registrarDeets[registrarCount].district = district;
        registrarDeets[registrarCount].pincode = pincode;
    }   

    function WhiteListHospital (address user, string memory hospName, string memory firstLine, string memory taluka, string memory district , string memory state, uint pincode) public onlyRegistrar {
        Hospitals[user]=true;
        hospDeets[hospCount].hospital = user; 
        hospDeets[hospCount].hospName = hospName;
        hospDeets[hospCount].firstLine = firstLine;
        hospDeets[hospCount].taluka = taluka;
        hospDeets[hospCount].district = district;
        hospDeets[hospCount].state = state;
        hospDeets[hospCount].pincode = pincode;
        hospCount++;
    }   
    modifier onlyHospital() {
        require(Hospitals[msg.sender], "only Hospitals can access this function");
        _;
    }
    function getHospitalDetails(uint no) public onlyOwner view returns (hospDetails memory) {
        return (hospDeets[no]);
    }
    function getRegistrarDetails(uint no) public onlyOwner view returns (registrarDetails memory) {
        return (registrarDeets[no]);
    }
    struct Certificate{
        address hospDelivered;
        string fatherName;
        //string fatherAadhar;
        string motherName;
        //string motherAadhar;
        string babyName;
        string birthDate;
        string birthTime;
        string Sex;
        string permAdd;
        string docName;
        uint certHash;  //this is the certificate number
        address RegistrarAddress;
        bool registrarVerified;
    }

    uint public certCount=1;
    Certificate[] public Cert;
    uint public BlackCertCount=1;
    Certificate[] public BCert;
    mapping (uint => Certificate) public certNumber;
    event certAdded(uint indexed attributeID, address indexed owner, string fatherName, /*string fatherAadhar,*/ string motherName, /*string motherAadhar,*/ string babyName, string birthDate, string birthTime, string Sex, string permAdd, string docName , bool registrarVerified);

    function createBirthRecord(string memory fatherName, /*string memory fatherAadhar,*/ string memory motherName, /*string memory motherAadhar,*/ string memory babyName, string memory birthDate, string memory birthTime, string memory Sex, string memory permAdd, string memory docName) public onlyHospital{
        
        certNumber[certCount].hospDelivered = msg.sender;
        certNumber[certCount].fatherName = fatherName;
        //certNumber[certCount].fatherAadhar = fatherAadhar;
        certNumber[certCount].motherName = motherName;
        //certNumber[certCount].motherAadhar = motherAadhar;
        certNumber[certCount].babyName = babyName;
        certNumber[certCount].birthDate = birthDate;
        certNumber[certCount].birthTime = birthTime;
        certNumber[certCount].Sex = Sex;
        certNumber[certCount].permAdd = permAdd;
        certNumber[certCount].docName = docName;
        certNumber[certCount].certHash = certCount;
        certCount++;
        emit certAdded(certCount, msg.sender, fatherName, /*fatherAadhar,*/ motherName, /*motherAadhar,*/ babyName, birthDate, birthTime, Sex, permAdd , docName, false);
    }

    function getBirthDetails(uint Count) public view returns(Certificate memory) {
        return certNumber[Count];
    }

    function registrarVerification (uint _no, string memory _babyName ) public onlyRegistrar {
        uint no = _no;
        require(certNumber[no].registrarVerified == false, "The certificate has already been verified by Registrar");
        certNumber[no].registrarVerified = true;
        if (keccak256(abi.encodePacked('-')) == keccak256(abi.encodePacked(certNumber[no].babyName))) {
            certNumber[no].babyName=_babyName;
        }
        certNumber[no].RegistrarAddress = msg.sender;
    }
    function revokeCertificate (uint _no) public onlyRegistrar {
        uint no = _no;
        certNumber[no].registrarVerified = false;
    }
}
// Hospital: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
// Registrar: 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db