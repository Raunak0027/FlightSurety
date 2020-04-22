
var Test = require('../config/testConfig.js');
var BigNumber = require('bignumber.js');
let airline1;
let airline2;
let airline3;
let airline4;
let airline5;
contract('Flight Surety Tests', async (accounts) => {
 
  var config;
  airline1 = accounts[0];
  airline2 = accounts[1];
  airline3 = accounts[2];
    airline4 = accounts[3];
    airline5 = accounts[4];
  before('setup contract', async () => {
    config = await Test.Config(accounts);

   // await config.flightSuretyData.authorizeCaller(config.flightSuretyApp.address);
  });

  /****************************************************************************************/
  /* Operations and Settings                                                              */
  /****************************************************************************************/
  it(`Applied airline Create Airline function from flight surety app`, async function () {

    
   
   // let tx = await config.flightSuretyApp.createAirline(airline1, 'firstairline');
  //  let event = tx.logs[0].event;
  //  console.log(event);
    
    let statusvalue = await config.flightSuretyData.getAirlineStatus(airline1);
    console.log("Owner airline by default value "+statusvalue);


    await config.flightSuretyApp.createAirline(airline2,'secondairline');
    await config.flightSuretyApp.createAirline(airline3,'thirdairline');
    await config.flightSuretyApp.createAirline(airline4,'fourthairline');
  //  await config.flightSuretyApp.createAirline(airline5,'fifthairline');

    let statusvalue1 = await config.flightSuretyData.getAirlineStatus(airline2);
    let statusvalue2 = await config.flightSuretyData.getAirlineStatus(airline3);
    let statusvalue3 = await config.flightSuretyData.getAirlineStatus(airline4);
    //let statusvalue4 = await config.flightSuretyData.getAirlineStatus(airline5);
    console.log("Post creation");
    console.log("second airline status "+statusvalue1);
    console.log("third airline status "+statusvalue2);
    console.log("fourth airline status "+statusvalue3);
   // console.log("ffifth airline status "+statusvalue4);

    //assert.equal(status, true, "Incorrect initial operating status value");

  });

  it(`Register and pay the data contract with four airplanes`, async function () {
    
    //Create Airline for the registeration 

    console.log("are you ahere'");
    let value = await config.flightSuretyApp.AirlineRegisteration(airline2, {from: airline1});
    let value2 = await config.flightSuretyApp.AirlineRegisteration(airline3, {from: airline1});
    let value3 = await config.flightSuretyApp.AirlineRegisteration(airline4, {from: airline1});

    let event = value.logs[0].event;
    console.log(event);

    //console.log("that is the second "+event);

    //assert.equal(await config.flightSuretyData.getAirlineState(airline2), 1, "2nd registered airline is of incorrect state");

    let status_value = await config.flightSuretyData.getAirlineStatus(airline2);
    let statusvalue2 = await config.flightSuretyData.getAirlineStatus(airline3);
    let statusvalue3 = await config.flightSuretyData.getAirlineStatus(airline4);

    console.log("Post registeration");
    console.log("second airline status "+status_value);
    console.log("third airline status "+statusvalue2);
    console.log("fourth airline status "+statusvalue3);

    await config.flightSuretyApp.AirlinePayment({from: airline2, value: web3.utils.toWei('10', 'ether')});
    await config.flightSuretyApp.AirlinePayment({from: airline3, value: web3.utils.toWei('10', 'ether')});
    await config.flightSuretyApp.AirlinePayment({from: airline4, value: web3.utils.toWei('10', 'ether')});
    


    let statusvalue4 = await config.flightSuretyData.getAirlineStatus(airline2);
    let statusvalue5 = await config.flightSuretyData.getAirlineStatus(airline3);
    let statusvalue6 = await config.flightSuretyData.getAirlineStatus(airline4);


    console.log("Post payment");
   // console.log(event2);
    console.log("second airline status "+statusvalue4);
    console.log("third airline status "+statusvalue5);
    console.log("fourth airline status "+statusvalue6);
    //assert.equal(status, true, "Incorrect initial operating status value");

  });



  it(`(multiparty) has correct initial isOperational() value`, async function () {

    // Get operating status
    let status = await config.flightSuretyData.isOperational.call();
    assert.equal(status, true, "Incorrect initial operating status value");

  });

  it(`(multiparty) can block access to setOperatingStatus() for non-Contract Owner account`, async function () {

      // Ensure that access is denied for non-Contract Owner account
      let accessDenied = false;
      try 
      {
          await config.flightSuretyData.setOperatingStatus(false, { from: config.testAddresses[2] });
      }
      catch(e) {
          accessDenied = true;
      }
      assert.equal(accessDenied, true, "Access not restricted to Contract Owner");
            
  });

  it(`(multiparty) can allow access to setOperatingStatus() for Contract Owner account`, async function () {

      // Ensure that access is allowed for Contract Owner account
      let accessDenied = false;
      try 
      {
          await config.flightSuretyData.setOperatingStatus(false);
      }
      catch(e) {
          accessDenied = true;
      }
      assert.equal(accessDenied, false, "Access not restricted to Contract Owner");
      
  });

  it(`(multiparty) can block access to functions using requireIsOperational when operating status is false`, async function () {

      await config.flightSuretyData.setOperatingStatus(false);

      let reverted = false;
      try 
      {
          await config.flightSurety.setTestingMode(true);
      }
      catch(e) {
          reverted = true;
      }
      assert.equal(reverted, true, "Access not blocked for requireIsOperational");      

      // Set it back for other tests to work
      await config.flightSuretyData.setOperatingStatus(true);

  });

  it('(airline) cannot register an Airline using registerAirline() if it is not funded', async () => {
    
    // ARRANGE
    let newAirline = accounts[2];

    // ACT
    try {
        await config.flightSuretyApp.registerAirline(newAirline, {from: config.firstAirline});
    }
    catch(e) {

    }
    let result = await config.flightSuretyData.isAirline.call(newAirline); 

    // ASSERT
    assert.equal(result, false, "Airline should not be able to register another airline if it hasn't provided funding");

  });
 

});
