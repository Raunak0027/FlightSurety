pragma solidity ^0.5.0;

// It's important to avoid vulnerabilities due to numeric overflow bugs
// OpenZeppelin's SafeMath library, when used correctly, protects agains such bugs
// More info: https://www.nccgroup.trust/us/about-us/newsroom-and-events/blog/2018/november/smart-contract-insecurity-bad-arithmetic/

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

/************************************************** */
/* FlightSurety Smart Contract                      */
/************************************************** */
contract FlightSuretyApp {
    using SafeMath for uint256; // Allow SafeMath functions to be called for all uint256 types (similar to "prototype" in Javascript)

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/
    
  
    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in 
    *      the event there is an issue that needs to be fixed
    */
    modifier requireIsOperational() 
    {
         // Modify to call data contract's status
        require(true, "Contract is currently not operational");  
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner()
    {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    function _make_payable(address x) internal pure returns (address payable) {
        return address(uint160(x));
    }

    /********************************************************************************************/
    /*                                       CONSTRUCTOR                                        */
    /********************************************************************************************/

    /**
    * @dev Contract constructor
    *
    */
    constructor
                                (
                                    address datacontractaddress
                                ) 
                                public 
    {
        flightdataaddress = datacontractaddress;
        flightsuretydata = FlightSuretyData(datacontractaddress);
        contractOwner = msg.sender;
        


        //address payable flightdataaddresspayable = _make_payable(flightdataaddress);

        //create random flights

    
        bytes32 flightKey1 = getFlightKey(contractOwner, "FLIGHT1", 1588019095);
        flights[flightKey1] = Flight(contractOwner, "FLIGHT1",STATUS_CODE_UNKNOWN, 1588019095);
        //flights[flightKey1] = Flight(STATUS_CODE_UNKNOWN, now, , "FLIGHT1");
        flightsKeyList.push(flightKey1);

        bytes32 flightKey2 = getFlightKey(contractOwner, "FLIGHT2", now + 1 days);
        flights[flightKey2] = Flight(contractOwner, "FLIGHT2",STATUS_CODE_UNKNOWN, now + 1 days);
        flightsKeyList.push(flightKey2);

        bytes32 flightKey3 = getFlightKey(contractOwner, "FLIGHT3", now + 2 days);
        flights[flightKey3] = Flight(contractOwner, "FLIGHT3",STATUS_CODE_UNKNOWN, now + 2 days);
        flightsKeyList.push(flightKey3);
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    function isOperational() 
                            public 
                            pure 
                            returns(bool) 
    {
        return true;  // Modify to call data contract's status
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

  
    /********************************************************************************************/
    /*                                     Airline FUNCTIONS                                     */
    /********************************************************************************************/

    event AirlineApplied(address airline);
    event AirlineRegistered(address airline);
    event AirlinePaid(address airline);

    event Airlinetest(uint8 value);
    uint constant votes = 4;
   /**
    * @dev Add an airline to the registration queue
    *
    */   

    // function register airline 
    //paid airline 
    //appliedairline -- unregistered airline

    function createAirline(address airlineID, string calldata name ) external{  

        flightsuretydata.createAirline(airlineID, 0, name);
        emit AirlineApplied(airlineID);

    }

    function AirlineRegisteration(address airlineID) external{ // function can only be called by paidairlines


        uint paidairlines = flightsuretydata.getPaidAirlines();
        bool approval = false;
        if(paidairlines <= votes){
                approval = true;
        }
        else{
           uint approvers = flightsuretydata.approveAirlineRegistration(airlineID, msg.sender);
           if(approvers >= (paidairlines/2)){
               approval = true;
           }
        }
        if(approval){
            flightsuretydata.updateAirlineState(airlineID, 1);
            emit AirlineRegistered(airlineID);
        }
    
    }

    

    function AirlinePayment() external payable{   //function that can be only called by registered airlines
        
        address payable flighdataaddresspayable = _make_payable(flightdataaddress);
        flighdataaddresspayable.transfer(msg.value);
        flightsuretydata.updateAirlineState(msg.sender, 2);
    }


    function registerAirline
                            (   
                            )
                            external
                            pure
                            returns(bool success, uint256 votes)
    {
        return (success, 0);
    }

    /********************************************************************************************/
    /*                                     Airline FUNCTIONS                             */
    /********************************************************************************************/

    /********************************************************************************************/
        /*                                     FLIGHT FUNCTIONS                             */
    /********************************************************************************************/
  // Flight status codees
    uint8 private constant STATUS_CODE_UNKNOWN = 0;
    uint8 private constant STATUS_CODE_ON_TIME = 10;
    uint8 private constant STATUS_CODE_LATE_AIRLINE = 20;
    uint8 private constant STATUS_CODE_LATE_WEATHER = 30;
    uint8 private constant STATUS_CODE_LATE_TECHNICAL = 40;
    uint8 private constant STATUS_CODE_LATE_OTHER = 50;

    address private contractOwner;          // Account used to deploy contract

    struct Flight {
       // bool isRegistered;
        address airline;
        string flightnumber;
        uint8 statusCode;
        uint256 updatedTimestamp;
        
    }
    mapping(bytes32 => Flight) private flights;
    bytes32[] private flightsKeyList;

    event FlightRegistered(address airline, string flightname, uint8 statuscode);

    address flightdataaddress;
    FlightSuretyData flightsuretydata;
   /**
    * @dev Register a future flight for insuring.
    *
    */  
    function registerFlight
                                (
                                    uint8 statusCode, string calldata flightnumber, uint256 flighttime
                                )
                                external
                                
    {

        bytes32 flightkey = getFlightKey(msg.sender, flightnumber, flighttime);

        flights[flightkey] = Flight(msg.sender, flightnumber, statusCode, flighttime);
        flightsKeyList.push(flightkey);
    }
    
   // function getFlight(uint flightindex) return airline, timestamp, statuscode, name 
   
   
   //{}
   /**
    * @dev Called after oracle has updated flight status
    *
    */  
    function processFlightStatus  // add status to the flight
                                (
                                    address airline,
                                    string memory flight,
                                    uint256 timestamp,
                                    uint8 statusCode
                                )
                                internal
                                
    {

        bytes32 flightkey = getFlightKey(airline, flight, timestamp);
        flights[flightkey].statusCode = statusCode;

    
    }

    // Generate the list of flights for which the passenger would want to buy the insurance

    function getFlight(uint256 index) external view returns(address airline, string memory flightname, uint256 timestamp, uint8 statuscode){

        airline = flights[flightsKeyList[index]].airline;
        flightname = flights[flightsKeyList[index]].flightnumber;
        timestamp = flights[flightsKeyList[index]].updatedTimestamp;
        statuscode = flights[flightsKeyList[index]].statusCode;

    }

    function getFlightCount() external view returns(uint256){
        return flightsKeyList.length;
    }


    // Generate a request for oracles to fetch flight information
    function fetchFlightStatus
                        (
                            address airline,
                            string calldata flight,
                            uint256 timestamp
                        )
                        external
    {
        uint8 index = getRandomIndex(msg.sender);

        // Generate a unique key for storing the request
        bytes32 key = keccak256(abi.encodePacked(index, airline, flight, timestamp));
        oracleResponses[key] = ResponseInfo({
                                                requester: msg.sender,
                                                isOpen: true
                                            });

        emit OracleRequest(index, airline, flight, timestamp, key);
    } 
    /********************************************************************************************/
        /*                                     FLIGHT FUNCTIONS                             */
    /********************************************************************************************/
/********************************************************************************************/
        /*                                     Passenger FUNCTIONS                             */
    /********************************************************************************************/
    uint public constant max_insurance_price = 1 ether;

    function purchaseinsurance(address passenger, string calldata flightname) external payable{  // function will be called by the passenger

            require(msg.value <= max_insurance_price, 'maximum that you can purchase is of 1eth');
            address payable flighdataaddresspayable = _make_payable(flightdataaddress);
            flighdataaddresspayable.transfer(msg.value);
            uint256 withdrawamount = msg.value.mul(3);
            withdrawamount = withdrawamount.div(2);
            flightsuretydata.createInsurance(flightname, msg.value, withdrawamount, passenger);

    }

    //function getinsurance

    function claimInsurance(address airlineID,address passenger, string calldata flightname, uint256 timestamp) external{
            
            bytes32 flightKey = getFlightKey(airlineID, flightname, timestamp);
            require(flights[flightKey].statusCode == 20, "Flight was not delayed");
            flightsuretydata.claimInsurance(passenger);
    }

    function payPassenger(address passenger) external{

        flightsuretydata.payPassenger(passenger);
    }


/********************************************************************************************/
        /*                                     Passenger FUNCTIONS                             */
    /********************************************************************************************/


// region ORACLE MANAGEMENT

    // Incremented to add pseudo-randomness at various points
    uint8 private nonce = 0;    

    // Fee to be paid when registering oracle
    uint256 public constant REGISTRATION_FEE = 1 ether;

    // Number of oracles that must respond for valid status
    uint256 private constant MIN_RESPONSES = 3;


    struct Oracle {
        bool isRegistered;
        uint8[3] indexes;        
    }

    // Track all registered oracles
    mapping(address => Oracle) private oracles;

    // Model for responses from oracles
    struct ResponseInfo {
        address requester;                              // Account that requested status
        bool isOpen;                                    // If open, oracle responses are accepted
        mapping(uint8 => address[]) responses;          // Mapping key is the status code reported
                                                        // This lets us group responses and identify
                                                        // the response that majority of the oracles
    }

    // Track all oracle responses
    // Key = hash(index, flight, timestamp)
    mapping(bytes32 => ResponseInfo) private oracleResponses;

    // Event fired each time an oracle submits a response
    event FlightStatusInfo(address airline, string flight, uint256 timestamp, uint8 status);

    event OracleReport(address airline, string flight, uint256 timestamp, uint8 status);

    // Event fired when flight status request is submitted
    // Oracles track this and if they have a matching index
    // they fetch data and submit a response
    event OracleRequest(uint8 index, address airline, string flight, uint256 timestamp, bytes32 key);


    // Register an oracle with the contract
    function registerOracle
                            (
                            )
                            external
                            payable
    {
        // Require registration fee
        require(msg.value >= REGISTRATION_FEE, "Registration fee is required");

        uint8[3] memory indexes = generateIndexes(msg.sender);

        oracles[msg.sender] = Oracle({
                                        isRegistered: true,
                                        indexes: indexes
                                    });
    }

    function getMyIndexes
                            (
                            )
                            view
                            external
                            returns(uint8[3] memory )
    {
        require(oracles[msg.sender].isRegistered, "Not registered as an oracle");

        return oracles[msg.sender].indexes;
    }




    // Called by oracle when a response is available to an outstanding request
    // For the response to be accepted, there must be a pending request that is open
    // and matches one of the three Indexes randomly assigned to the oracle at the
    // time of registration (i.e. uninvited oracles are not welcome)
    function submitOracleResponse
                        (
                            uint8 index,
                            address airline,
                            string calldata flight,
                            uint256 timestamp,
                            uint8 statusCode
                        )
                        external
    {
        require((oracles[msg.sender].indexes[0] == index) || (oracles[msg.sender].indexes[1] == index) || (oracles[msg.sender].indexes[2] == index), "Index does not match oracle request");


        bytes32 key = keccak256(abi.encodePacked(index, airline, flight, timestamp)); 
        //require(oracleResponses[key].isOpen, "Flight or timestamp do not match oracle request");

        oracleResponses[key].responses[statusCode].push(msg.sender);
        require(oracleResponses[key].isOpen, "Flight or timestamp do not match oracle request");


        // Information isn't considered verified until at least MIN_RESPONSES
        // oracles respond with the *** same *** information
        emit OracleReport(airline, flight, timestamp, statusCode);

        if (oracleResponses[key].responses[statusCode].length >= MIN_RESPONSES) {

            emit FlightStatusInfo(airline, flight, timestamp, statusCode);

            // Handle flight status as appropriate
            processFlightStatus(airline, flight, timestamp, statusCode);
        }
    }

    function getOracleKey(uint8 index, address airline, string calldata flight, uint256 timestamp) external pure returns(bytes32 key) {

            return keccak256(abi.encodePacked(index, airline, flight, timestamp));

    }

    function getoracleresponselength(bytes32 key, uint8 statusCode) external view returns(uint256 number){

        return oracleResponses[key].responses[statusCode].length;
    }

    function getFlightKey
                        (
                            address airline,
                            string memory flight,
                            uint256 timestamp
                        )
                        pure
                        internal
                        returns(bytes32) 
    {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    // Returns array of three non-duplicating integers from 0-9
    function generateIndexes
                            (                       
                                address account         
                            )
                            internal
                            returns(uint8[3] memory)
    {
        uint8[3] memory indexes;
        indexes[0] = getRandomIndex(account);
        
        indexes[1] = indexes[0];
        while(indexes[1] == indexes[0]) {
            indexes[1] = getRandomIndex(account);
        }

        indexes[2] = indexes[1];
        while((indexes[2] == indexes[0]) || (indexes[2] == indexes[1])) {
            indexes[2] = getRandomIndex(account);
        }

        return indexes;
    }

    // Returns array of three non-duplicating integers from 0-9
    function getRandomIndex
                            (
                                address account
                            )
                            internal
                            returns (uint8)
    {
        uint8 maxValue = 10;

        // Pseudo random number...the incrementing nonce adds variation
        uint8 random = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - nonce++), account))) % maxValue);

        if (nonce > 250) {
            nonce = 0;  // Can only fetch blockhashes for last 256 blocks so we adapt
        }

        return random;
    }

// endregion

}   

contract FlightSuretyData{

    function updateAirlineState(address airlineID, uint8 state) external;
    function createAirline(address airlineID, uint8 state, string calldata name) external;
    function getPaidAirlines() external returns(uint);
    function approveAirlineRegistration(address airlineID, address approver) external returns(uint);
    function createInsurance(string calldata flightname, uint256 amount, uint256 withdrawamount, address passenger) external;
    function claimInsurance(address passenger) external;
    function payPassenger(address passenger) external payable;

}


