pragma solidity ^0.5.0;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyData {
    using SafeMath for uint256;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    address private contractOwner;                                      // Account used to deploy contract
    bool private operational = true;                                    // Blocks all state changes throughout the contract if false

    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/


    /**
    * @dev Constructor
    *      The deploying account becomes contractOwner
    */
    constructor
                                (
                                ) 
                                public 
    {
        contractOwner = msg.sender;

        airline[contractOwner] = Airline(contractOwner,"First Airline", AirlineState.paid, 0);

        // contract is operational then there should be one airline already added 
    }

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
        require(operational, "Contract is currently not operational");
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

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
    * @dev Get operating status of contract
    *
    * @return A bool that is the current operating status
    */      
    function isOperational() 
                            public 
                            view 
                            returns(bool) 
    {
        return operational;
    }


    /**
    * @dev Sets contract operations on/off
    *
    * When operational mode is disabled, all write transactions except for this one will fail
    */    
    function setOperatingStatus
                            (
                                bool mode
                            ) 
                            external
                            requireContractOwner 
    {
        operational = mode;
    }


     function _make_payable(address x) internal pure returns (address payable) {
        return address(uint160(x));
    }
    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/
   /********************************************************************************************/
    /*                                     Airline FUNCTIONS                                   */
    /********************************************************************************************/

   /**
    * @dev Add an airline to the registration queue
    *      Can only be called from FlightSuretyApp contract
    *
    */   
 event Airlinetesting(string data);

    enum AirlineState{
        unregistered, //0
        registered, //1
        paid       //2
    }
    uint airlinestate;
    struct Airline{
        address airlineID;
        string airlineName;
        AirlineState airlineState;
        mapping(address => bool) approvers;
        uint approverCount;
    }

    //mapping(address => unit) 
    uint internal PaidAirlines = 1;

    mapping(address => Airline) internal airline;

    function createAirline(address airlineID, uint8 state, string calldata name) external{
    
            airline[airlineID] = Airline(airlineID, name, AirlineState(state), 0);
    }

    function getAirlineStatus(address airlineID) external view returns(AirlineState){

        return airline[airlineID].airlineState;

    }

    function updateAirlineState(address airlineID, uint8 state) external{

        airline[airlineID].airlineState = AirlineState(state);
        if(state==2)
             PaidAirlines++;

    }

    function getPaidAirlines() external returns(uint){

        return PaidAirlines;
    }


    function approveAirlineRegistration(address airlineID, address approver) external returns(uint){

        require(!airline[airlineID].approvers[approver], "Approver already approved the airline");

        airline[airlineID].approvers[approver] = true;

        airline[airlineID].approverCount++;

        return airline[airlineID].approverCount;

    }
    function registerAirline
                            (   address airline
                            )
                            external
                            pure
    {

    }




   /********************************************************************************************/
    /*                                     Airline  FUNCTIONS                                  */
    /********************************************************************************************/

  
    struct Insurance{
            string flightname;
            uint256 amount;
            uint256 withdrawamount;
            
    }

    mapping(address => uint256) private passengerbalance;
    mapping(address => Insurance) passengerinsurance;

    function createInsurance(string calldata flightname, uint256 amount, uint256 withdrawamount, address passenger) external {

        passengerinsurance[passenger] = Insurance(flightname, amount, withdrawamount);

    }
    function claimInsurance(address passenger) external{

            passengerbalance[passenger] = passengerbalance[passenger] + passengerinsurance[passenger].withdrawamount;
    }

    function payPassenger(address passenger) external payable{
        
        passengerbalance[passenger] = 0;
        address payable passengeraddresspayable = _make_payable(passenger);
        passengeraddresspayable.transfer(passengerbalance[passenger]);

    }
    function getInsurance(address passenger) external view returns(string memory flightname, uint256 amount, uint256 withdrawamount){

        flightname = passengerinsurance[passenger].flightname;
        amount = passengerinsurance[passenger].amount;
        withdrawamount = passengerinsurance[passenger].withdrawamount;
    }
     /**
    * @dev Buy insurance for a flight
    *
    */   

    function buy
                            (                             
                            )
                            external
                            payable
    {

    }

    /**
     *  @dev Credits payouts to insurees
    */
    function creditInsurees
                                (
                                )
                                external
                                pure
    {
    }
    

    /**
     *  @dev Transfers eligible payout funds to insuree
     *
    */
    function pay
                            (
                            )
                            external
                            pure
    {
    }

   /**
    * @dev Initial funding for the insurance. Unless there are too many delayed flights
    *      resulting in insurance payouts, the contract should be self-sustaining
    *
    */   
    function fund
                            (   
                            )
                            public
                            payable
    {
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

    /**
    * @dev Fallback function for funding smart contract.
    *
    */
    function() 
                            external 
                            payable 
    {
        fund();
    }


}

