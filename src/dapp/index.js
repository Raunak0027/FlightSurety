
import DOM from './dom';
import Contract from './contract';
import './flightsurety.css';


(async() => {

    let result = null;

    let contract = new Contract('localhost', () => {

        // Read transaction
        contract.isOperational((error, result) => {
            console.log(error,result);
            display('Operational Status', 'Check if contract is operational', [ { label: 'Operational Status', error: error, value: result} ]);
        });
    
    //    contract.creatAirline((error, result) => {
    //       console.log(error,result);
    //       display('Airline', 'provide the name of airline' [ { label: 'Airline', error: error, value: result} ]);
    //   });

     DOM.elid('submit-airline').addEventListener('click', () => {
        let airlineid = DOM.elid('airlineid').value;
        let airlinename = DOM.elid('airlinename').value;
        // Write transaction
        contract.createAirline(airlineid, airlinename, (error)=>{
            console.log("airline not added to "+ error);
        });
        console.log("Airline created");
    })

     DOM.elid('submit-flight').addEventListener('click', async() => {
        let flightname = DOM.elid('flightname').value;
        let flighttime = DOM.elid('flighttime').value;
        // Write transaction
         await contract.registerFlight(0, flightname, flighttime, (error) => {
            console.log(`Flight not registered error: ${error}`);
        });
        
          await contract.getFlights();
       // console.log("Size of flights "+ flight.length);
       console.log("Flight count should be mentioned now");
    })


        // User-submitted transaction
        DOM.elid('submit-oracle').addEventListener('click', () => {
            let flight = DOM.elid('flight-number').value;
            // Write transaction
            contract.fetchFlightStatus(flight, (error, result) => {
                display('Oracles', 'Trigger oracles', [ { label: 'Fetch Flight Status', error: error, value: result.flight + ' ' + result.timestamp} ]);
            });
            
        })

    
    });
    

})();


function display(title, description, results) {
    let displayDiv = DOM.elid("display-wrapper");
    let section = DOM.section();
    section.appendChild(DOM.h2(title));
    section.appendChild(DOM.h5(description));
    results.map((result) => {
        let row = section.appendChild(DOM.div({className:'row'}));
        row.appendChild(DOM.div({className: 'col-sm-4 field'}, result.label));
        row.appendChild(DOM.div({className: 'col-sm-8 field-value'}, result.error ? String(result.error) : String(result.value)));
        section.appendChild(row);
    })
    displayDiv.append(section);

}







