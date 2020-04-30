
var Test = require('../config/testConfig.js');
//var BigNumber = require('bignumber.js');
const truffleAssert = require('truffle-assertions');

contract('Oracles', async (accounts) => {

  const TEST_ORACLES_COUNT = 30;
  var config;
  before('setup contract', async () => {
    config = await Test.Config(accounts);

    // Watch contract events
    const STATUS_CODE_UNKNOWN = 0;
    const STATUS_CODE_ON_TIME = 10;
    const STATUS_CODE_LATE_AIRLINE = 20;
    const STATUS_CODE_LATE_WEATHER = 30;
    const STATUS_CODE_LATE_TECHNICAL = 40;
    const STATUS_CODE_LATE_OTHER = 50;
    var KEYgenerated;

  });


  it('can register oracles', async () => {
    
    // ARRANGE
    let fee = await config.flightSuretyApp.REGISTRATION_FEE.call();

    // ACT
    console.log("totalt number of flights "+ await config.flightSuretyApp.getFlightCount());
    for(let a=0; a<TEST_ORACLES_COUNT; a++) {      
      await config.flightSuretyApp.registerOracle({ from: accounts[a], value: fee });
      let result = await config.flightSuretyApp.getMyIndexes.call({from: accounts[a]});
      console.log(`Oracle Registered: ${result[0]}, ${result[1]}, ${result[2]}`);
    }
  });

  it('can request flight status', async () => {
    
    // ARRANGE
    let flight = 'ND1309'; // Course number
    flight = 'FLIGHT1';
    let timestamp = Math.floor(Date.now() / 1000);
    timestamp = 1588019095;
    // Submit a request for oracles to get status information for a flight
    let oraclerequest = await config.flightSuretyApp.fetchFlightStatus(config.owner, flight, timestamp);
    
    truffleAssert.eventEmitted(oraclerequest, 'OracleRequest', (ev)=>{
      //emittedindex = ;
      //console.log("this is the flight index "+ev.index.toNumber());
      KEYgenerated = ev.key;
      console.log(`\n\nOracle Requested: index: ${ev.index.toNumber()}, flight:  ${ev.flight}, timestamp: ${ev.timestamp.toNumber()}, key: ${ev.key}`);
      return ev.index.toNumber() && ev.flight === flight ;

  });
    
    // ACT

    // Since the Index assigned to each test account is opaque by design
    // loop through all the accounts and for each account, all its Indexes (indices?)
    // and submit a response. The contract will reject a submission if it was
    // not requested so while sub-optimal, it's a good test of that feature
    for(let a=0; a<TEST_ORACLES_COUNT; a++) {

      // Get oracle information
      let oracleIndexes = await config.flightSuretyApp.getMyIndexes.call({ from: accounts[a]});

      for(let idx=0;idx<3;idx++) {

        
        var keycomparable = await config.flightSuretyApp.getOracleKey(oracleIndexes[idx], config.owner, flight, timestamp);
       
        //console.log("Oracle key generated "+ keycomparable);
        if(KEYgenerated == keycomparable){
              console.log("Keys Matched");
              console.log("Accounts "+ accounts[a]);
              console.log("Index Generated "+ oracleIndexes[idx] +"\n");
              
        }
          


        try {
          // Submit a response...it will only be accepted if there is an Index match


        let flightinfo =  await config.flightSuretyApp.submitOracleResponse(oracleIndexes[idx], config.owner, flight, timestamp, 0, { from: accounts[a] });
        console.log("length of oracleresponses "+ await config.flightSuretyApp.getoracleresponselength(KEYgenerated, 0));
        
        truffleAssert.eventEmitted(flightinfo, 'FlightStatusInfo', (ev) => {
          
          console.log("Index generated " + oracleIndexes[idx]);
          console.log(`\n\nFlight Status Available: flight: ${a}, ${ev.flight}, timestamp: ${ev.timestamp.toNumber()}, status: ${ev.status.toNumber()}`);
          
          return ev.flight === flight;
        });

        }
        catch(e) {
          // Enable this when debugging
          // console.log('\nError', idx, oracleIndexes[idx].toNumber(), flight, timestamp);
        }

      }
    }


  });


 
});
