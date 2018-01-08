//
//  Airports.swift
//  IFLD Calculator
//
//  Created by Adam Zemmoura on 02/05/2017.
//  Copyright © 2017 Adam Zemmoura. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

struct Runway {
    let name: String
    let distance: Int
    let slope: Double
    let elevation: Int
}

struct Airport {
    
    let name: String
    let runways: [Runway]
    
    init(name: String, runways: [Runway]) {
        self.name = name
        self.runways = runways
    }
    
    
}

protocol AirportDataDelegate {
    func airportDatabaseUpdatedWith(airports: [Airport])
}

class AirportData {
    
    // todo: make this just an empty array
    let costaRica = Airport(name: "Costa Rica", runways: [
        Runway(name: "07", distance: 3011, slope: 1.1, elevation: 3028),
        Runway(name: "25", distance: 2517, slope: -1.1, elevation: 3028)
        ])
    
    let stLucia = Airport(name: "St Lucia", runways: [
        Runway(name: "10", distance: 2709, slope: 0.0, elevation: 14),
        Runway(name: "28", distance: 2594, slope: 0.0, elevation: 14)
        ])
    
    let telAviv = Airport(name: "Tel Aviv", runways: [
        Runway(name: "12", distance: 3112, slope: 0, elevation: 134),
        Runway(name: "21", distance: 2772, slope: 0, elevation: 134)
        ])
    
    let seattle = Airport(name: "Seattle", runways: [
        Runway(name: "16L", distance: 3627, slope: -0.7, elevation: 433),
        Runway(name: "16C", distance: 2873, slope: -0.7, elevation: 433),
        Runway(name: "16R", distance: 2591, slope: -0.7, elevation: 433),
        Runway(name: "34L", distance: 2591, slope: 0.7, elevation: 433),
        Runway(name: "34C", distance: 2873, slope: 0.7, elevation: 433),
        Runway(name: "34R", distance: 3627, slope: 0.7, elevation: 433)
        ])

    
    private var _airports = [Airport]()
    
    init() {
        _airports = [costaRica, telAviv, seattle, stLucia]
    }
    
    var delegate: AirportDataDelegate! = nil 
    
    func updateWith(snapshot: FIRDataSnapshot) {
        
        guard let dict = snapshot.value as? [String:Any] else { fatalError("Could not load data from database") }
        
        print("something changed in the database. new snapshot: \(dict)")
        
        if let airports = dict["airports"] as? [String : Any] {
            
            print(airports)
            
            let airportKeys = airports.keys.sorted()
            
            for key in airportKeys {
                
                let airportName = key.capitalized
                var airportRunways = [Runway]()
                
                if let airport = airports[key] as? [String: Any] {
                    print(airport)
                    
                    if let runways = airport["runways"] as? [String: Any] {
                        
                        let runwayKeys = runways.keys.sorted()
                        
                        for key in runwayKeys {
                            
                            let runwayName = key
                            var runwayLength: Int!
                            var runwayElevation: Int!
                            var runwaySlope: Double!
                            
                            if let runway = runways[key] as? [String: Any] {
                                if let elevation = runway["elevation"] as? Int {
                                    runwayElevation = elevation
                                }
                                if let slope = runway["slope"] as? Double {
                                    runwaySlope = slope
                                }
                                if let length = runway["length"] as? Int {
                                    runwayLength = length
                                }
                            }
                            
                            let newRunway = Runway(name: runwayName, distance: runwayLength, slope: runwaySlope, elevation: runwayElevation)
                            airportRunways.append(newRunway)
                        }
                        
                    }
                }
                
                let newAirport = Airport(name: airportName, runways: airportRunways)
                if _airports.contains(where: { $0.name == newAirport.name }) {
                    let index = _airports.index(where: {$0.name == newAirport.name })!
                    print("removing: \(_airports[index].name)")
                    _airports.remove(at: index)
                    print("inserting: \(newAirport.name)")
                    _airports.insert(newAirport, at: index)
                    delegate?.airportDatabaseUpdatedWith(airports: self.airports)
                }
                else {
                    print("New airport added: \(newAirport.name)")
                    _airports.append(newAirport)
                    delegate?.airportDatabaseUpdatedWith(airports: self.airports)
                }
            }
        }
        
    }
    
    
    
    
    
    
    var airports: [Airport] {
        get {
            return _airports.sorted(by: { $0.name < $1.name })
        }
    }
}
