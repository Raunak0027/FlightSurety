import FlightSuretyApp from '../../build/contracts/FlightSuretyApp.json';
import FlightSuretyData from '../../build/contracts/FlightSuretyData.json';
import Config from './config.json';
import Web3 from 'web3';


export default class Contract {
    constructor(network, callback) {

        let config = Config[network];
        this.web3 = new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:7545'));
        this.flightSuretyApp = new this.web3.eth.Contract(FlightSuretyApp.abi, config.appAddress);
        this.flightSuretyData = new this.web3.eth.Contract(FlightSuretyData.abi, config.dataAddress);
        this.initialize(callback);
        this.owner = null;
        this.airlines = [];
        this.passengers = [];
    }

    initialize(callback) {
        this.web3.eth.getAccounts((error, accts) => {
           
            this.owner = accts[0];
          //  console.log("this is the owner"+this.owner);

            let counter = 1;
            
            while(this.airlines.length < 5) {
                this.airlines.push(accts[counter++]);
            }

            while(this.passengers.length < 5) {
                this.passengers.push(accts[counter++]);
            }

            callback();
        });
    }

    isOperational(callback) {
       let self = this;
       self.flightSuretyApp.methods
            .isOperational()
            .call({ from: self.owner}, callback);
    }

    fetchFlightStatus(flight, callback) {
        let self = this;
        let payload = {
            airline: self.airlines[0],
            flight: flight,
            timestamp: Math.floor(Date.now() / 1000)
        } 
        self.flightSuretyApp.methods
            .fetchFlightStatus(payload.airline, payload.flight, payload.timestamp)
            .send({ from: self.owner}, (error, result) => {
                callback(error, payload);
            });
    }

    // getAirlineStatus(airlineid, callback){
    //     let self = this;
    //     self.flightSuretyData.methods
    //     .getAirlineStatus(airlineid).call({from: self.owner}, (error)=>{
    //         callback(error);
    //     });
    // }
    getAirlineStatus(airlineid){
        let self = this;
        return new Promise((resolve, reject) => {
            self.flightSuretyData.methods
                .getAirlineStatus(
                    airlineid
                ).call({"from": self.owner}, (error, airlineStatus) => {
                    //console.log(`worked when returning flight status`);
                    return error ? reject(error) : resolve(airlineStatus)
                }
            );
        });
    }



    createAirline(airlineid, airlinename, callback){
        let self = this;
        self.flightSuretyApp.methods
        .createAirline(airlineid, airlinename)
        .send({from: self.owner} , (error)=>{
            self.getAirlineStatus(
                airlineid
            ).then((airlineStatus) => {
                console.log(`Airline status of the recent airline created: ${airlineStatus}`);
                callback();
            }).catch(err => {
                callback(err);
            });
        });

    }
        //FLIGHT FUNCTIONS

       async registerFlight(statuscode, flightnumber, flighttime, callback){
            let self = this;
          await self.flightSuretyApp.methods
            .registerFlight(statuscode, flightnumber, flighttime)
            .send({from: self.owner}, (error) => {
                    callback(error);
            });

           /* await self.getFlightCount().then((flightcount) => {
                console.log(`flight registered ${flightcount}`);
                callback();
            }).catch((err)=>{
                callback(err);
            }); */
            
        };

        getFlightCount(){
            let self = this;
            return new Promise((resolve,reject) => {
               self.flightSuretyApp.methods
                .getFlightCount()
                .call({"from": self.owner}, (error, flightcount) => {
                            console.log(`Flight count ${flightcount}`)
                            return error ? reject(error) : resolve(flightcount);
                        }
                    
                    );
               });
           
        }
    
      async getFlights(){
            let self = this;
             await  self.getFlightCount().then((flightcount) => {console.log("This is the flight count"+flightcount)});
            
        }

        // then((flightcount) =>{
        //     const flight = [];
        //     console.log("it is here");
        //     for(var i = 0; i<flightcount; i++){
        //         const res = self.flightSuretyApp.methods
        //                     .getFlight(i);
        //         flight.push(res);
        //     }
        //     return flight;
        //     });

}