//
//  LandingDistanceCalculator.swift
//  IFLD Calculator
//
//  Created by Adam Zemmoura on 01/05/2017.
//  Copyright © 2017 Adam Zemmoura. All rights reserved.
//

import Foundation

protocol LandingDistanceCalculatorDelegate {
    func landingDistanceCalculatorHasCalculated(windComponents: [(component: WindComponent, knots: Double)])
}

enum WindComponent: String {
    case headwind
    case tailwind
    case crosswind
}

struct LandingDistanceCalculator {
    
    var delegate: LandingDistanceCalculatorDelegate? = nil
    
    private var flap: FlapSelection! {
        didSet {
            // Any time the flap selection is changed, change datasource to appropriate data
            if flap != nil {
                switch flap! {
                    case .twenty:
                        fatalError("Landind Distance Calculator object tried to set data source to F20.")
                    case .twentyFive:
                        data = Flap25Data_Normal()
                    case .thirty:
                        data = Flap30Data_Normal()
                }
            }
        }
    }
    private var weight: Int!
    private var reverse: ReverseSelection!
    private var windDirection: Int!
    private var windSpeed: Int!
    private var temperature: Int!
    private var runwayLength: Int!
    private var slope: Double!
    private var elevation: Int!
    private var runwayCondition: String!
    private var runway: Runway!
    private var runwayHeading: Int {
        get {
            if runway != nil {
                var runwayName = runway.name.lowercased()
                for char in runwayName.characters {
                    let index = runwayName.characters.index(of: char)!
                    let possibleNumber = Int(String(char))
                    if possibleNumber == nil {
                        // not a number so remove it
                        runwayName.remove(at: index)
                    }
                }
                
                runwayName.characters.append("0")
                
                return Int(runwayName)!
            }
            return -1 // represents error
        }
    }
    
    private var data: LandingData!
    
    mutating func calculateDistanceFor(runway: Runway,
                                       condition: String,
                              withSelections selections: [String : Int ]) -> [Int] {
        
        if let flapSelection = selections[Selection.flapSelection] {
            flap = FlapSelection(rawValue: flapSelection)!
        }
        if let weightSelection = selections[Selection.weightSelection] {
            weight = weightSelection
        }
        if let reverseSelection = selections[Selection.reverseSelection] {
            reverse = ReverseSelection(rawValue: reverseSelection)!
        }
        if let windDirectionSelction = selections[Selection.windDirectionSelection] {
            windDirection = windDirectionSelction
        }
        if let windSpeedSelection = selections[Selection.windSpeedSelection] {
            windSpeed = windSpeedSelection
        }
        if let temp = selections[Selection.tempSelection] {
            temperature = temp
        }
        
        runwayLength = runway.distance
        slope = runway.slope
        elevation = runway.elevation
        runwayCondition = condition
        self.runway = runway
        
        var finalDistances = [Int]() // partially corrected until last correction method executed.
        
        let refDistances = getReferenceDistances()
        
        finalDistances = applyWeightCorrection(with: weight, to: refDistances)
        
        finalDistances = applyReverseThrustCorrectionFor(reverse, to: finalDistances)
        
        finalDistances = applyWindCorrections(to: finalDistances)
        
        finalDistances = applyTempCorrections(to: finalDistances)
        
        finalDistances = applyVrefCorrections(to: finalDistances)
        
        return finalDistances
        
    }
    
    private func applyVrefCorrections(to distances: [Int]) -> [Int] {
        
        var correctedDistances = [Int]()
        
        var vrefCorrections: [Int] = [0,0,0,0,0]
        
        if let vRefCorrections = data.vrefAdjustments[runwayCondition] {
            for (key, correction) in vRefCorrections {
                let autobrakeSetting = AutobrakeSetting(rawValue: key)!
                switch autobrakeSetting {
                case .max:
                    vrefCorrections.remove(at: 0)
                    vrefCorrections.insert(correction, at: 0)
                case .four:
                    vrefCorrections.remove(at: 1)
                    vrefCorrections.insert(correction, at: 1)
                case .three:
                    vrefCorrections.remove(at: 2)
                    vrefCorrections.insert(correction, at: 2)
                case .two:
                    vrefCorrections.remove(at: 3)
                    vrefCorrections.insert(correction, at: 3)
                case .one:
                    vrefCorrections.remove(at: 4)
                    vrefCorrections.insert(correction, at: 4)
                }
                
            }
        }
        
        for distance in distances {
            let index = distances.index(of: distance)!
            let newDistance = distance + vrefCorrections[index]
            correctedDistances.append(newDistance)
        }
        
        return correctedDistances
    }
    
    private func applyTempCorrections(to distances: [Int]) -> [Int] {
        
        var correctedDistances = [Int]()
        
        var tempCorrectionsSorted: [(above: Int, below: Int)] = [(0,0),(0,0),(0,0),(0,0),(0,0)]
        
        if let tempCorrections = data.tempAdjustments[runwayCondition] {
            for (key, correction) in tempCorrections {
                let autobrakeSetting = AutobrakeSetting(rawValue: key)!
                switch autobrakeSetting {
                case .max:
                    tempCorrectionsSorted.remove(at: 0)
                    tempCorrectionsSorted.insert(correction, at: 0)
                case .four:
                    tempCorrectionsSorted.remove(at: 1)
                    tempCorrectionsSorted.insert(correction, at: 1)
                case .three:
                    tempCorrectionsSorted.remove(at: 2)
                    tempCorrectionsSorted.insert(correction, at: 2)
                case .two:
                    tempCorrectionsSorted.remove(at: 3)
                    tempCorrectionsSorted.insert(correction, at: 3)
                case .one:
                    tempCorrectionsSorted.remove(at: 4)
                    tempCorrectionsSorted.insert(correction, at: 4)
                }
            }
        }
        
        if temperature > 15 {
            for distance in distances {
                let index = distances.index(of: distance)!
                let correctionPerDegree = Double(tempCorrectionsSorted[index].above) / 10
                let degreesAboveISA = temperature - 15
                let correction = Double(degreesAboveISA) * correctionPerDegree
                let newDistance = distance + Int(correction)
                correctedDistances.append(newDistance)
            }
        }
        else if temperature < 15 {
            for distance in distances {
                let index = distances.index(of: distance)!
                let correctionPerDegree = Double(tempCorrectionsSorted[index].below) / 10
                let degreesBelowISA = 15 - temperature
                let correction = Double(degreesBelowISA) * correctionPerDegree
                let newDistance = distance + Int(correction)
                correctedDistances.append(newDistance)
            }
        }
        else {
            return distances
        }
        
        
        
        return correctedDistances
    }
    
    private func applyWindCorrections(to distances: [Int]) -> [Int] {
        
        var correctedDistances = [Int]()
        
        if runwayHeading == -1 {
            fatalError("Runway Heading not getting set")
        }
        
        let windComponents = calculateWindComponentsFor(heading: runwayHeading, windDirection: windDirection, windSpeed: windSpeed)
        delegate?.landingDistanceCalculatorHasCalculated(windComponents: windComponents)
        
        var windCorrectionsSorted: [(head:Int,tail:Int)] = [(0,0),(0,0),(0,0),(0,0),(0,0)]
        
        if let windCorrections = data.windAdjustments[runwayCondition] {
            for (key, windCorrection) in windCorrections {
                let autobrakeSetting = AutobrakeSetting(rawValue: key)!
                
                switch autobrakeSetting {
                case .max:
                    windCorrectionsSorted.remove(at: 0)
                    windCorrectionsSorted.insert(windCorrection, at: 0)
                case .four:
                    windCorrectionsSorted.remove(at: 1)
                    windCorrectionsSorted.insert(windCorrection, at: 1)
                case .three:
                    windCorrectionsSorted.remove(at: 2)
                    windCorrectionsSorted.insert(windCorrection, at: 2)
                case .two:
                    windCorrectionsSorted.remove(at: 3)
                    windCorrectionsSorted.insert(windCorrection, at: 3)
                case .one:
                    windCorrectionsSorted.remove(at: 4)
                    windCorrectionsSorted.insert(windCorrection, at: 4)
                }
                
            }
        }
        
        let wind = windComponents.first!.component
        let speed = windComponents.first!.knots
        
        switch wind {
            case .crosswind: return distances
            case .headwind:
                for distance in distances {
                    let index = distances.index(of: distance)!
                    let correctionPerKnot = Double(windCorrectionsSorted[index].head) / 10.0
                    let correctionForWind = correctionPerKnot * speed
                    let newDistance = distance + Int(correctionForWind)
                    correctedDistances.append(newDistance)
                }
            case .tailwind:
                for distance in distances {
                    let index = distances.index(of: distance)!
                    let correctionPerKnot = Double(windCorrectionsSorted[index].tail) / 10.0
                    let correctionForWind = correctionPerKnot * speed
                    let newDistance = distance + Int(correctionForWind)
                    correctedDistances.append(newDistance)
            }
        }
        
        return correctedDistances
    }
    
    private func applyReverseThrustCorrectionFor(_ reverse: ReverseSelection, to distances: [Int]) -> [Int] {
        
        var correctedDistances = [Int]()
        
        var revCorrections: [(one: Int, none: Int)] = [(0,0),
                                                      (0,0),
                                                      (0,0),
                                                      (0,0),
                                                      (0,0)]
        
        if let reverseCorrections = data.reverseAdjustments[runwayCondition] {
            for (key, revCorrection) in reverseCorrections {
                let autobrakeSetting = AutobrakeSetting(rawValue: key)!
                
                switch autobrakeSetting {
                    case .max:
                        revCorrections.remove(at: 0)
                        revCorrections.insert(revCorrection, at: 0)
                    case .four:
                        revCorrections.remove(at: 1)
                        revCorrections.insert(revCorrection, at: 1)
                    case .three:
                        revCorrections.remove(at: 2)
                        revCorrections.insert(revCorrection, at: 2)
                    case .two:
                        revCorrections.remove(at: 3)
                        revCorrections.insert(revCorrection, at: 3)
                    case .one:
                        revCorrections.remove(at: 4)
                        revCorrections.insert(revCorrection, at: 4)
                    }
            }
            
            for distance in distances {
                let index = distances.index(of: distance)!
                
                switch reverse {
                    case .both :
                        return distances
                case .one :
                    let newDistance = distance + revCorrections[index].one
                    correctedDistances.append(newDistance)
                case .none :
                    let newDistance = distance + revCorrections[index].none
                    correctedDistances.append(newDistance)
                }
            }
        }
        else {
            fatalError("Problem retrieving data for data.reverseAdjustments[\(runwayCondition)].")
        }
        
        return correctedDistances
        
    }
    
    private func applyWeightCorrection(with weight: Int, to distances: [Int]) -> [Int] {
        
        var correctedDistances = [Int]()
        
        let referenceWeight = 200 // 200T is the reference weight for all the data
        
        let multiplier = (referenceWeight - weight) // the diffence from refWeight in tonnes
        
        var incrementalFactor: [Int]! // inc & dec factors hold array of factors per tonne
        var decementalFactor: [Int]!  // sorted highest to lowest - [max,4,3,2,1]
        
        if let correctionFactors = data.weightAdjustments[runwayCondition] {
            var incFactors = [Int]()
            var decFactors = [Int]()
            
            for (_,factor) in correctionFactors {
                incFactors.append(factor.above / 5) // divided by 5 to get per tonne correction
                decFactors.append(factor.below / 5)
            }
            
            incrementalFactor = incFactors.sorted() // sort by lowest to highest
            decementalFactor = decFactors.sorted().reversed() // sort by highest to lowest
            
        }
        else {
            fatalError("Problem accessing Flap 25 Data for \(runwayCondition).")
        }
        
        // True if weight below reference - reduce the landing distance - use decrementalFactor
        if multiplier > 0 {
            for distance in distances {
                let index = distances.index(of: distance)!
                let newDistance = distance + (decementalFactor[index] * multiplier)
                correctedDistances.append(newDistance)
                
            }
        }
        // True if weight above reference - increase the landing distance - use incrementalFactor
        else if multiplier < 0 {
            for distance in distances {
                let index = distances.index(of: distance)!
                let newDistance = distance - (incrementalFactor[index] * multiplier)
                correctedDistances.append(newDistance)
            }
        }
        // True if aircraft is at reference distance ie. weighs 200 tonnes
        else {
            return distances
        }
        
        return correctedDistances
        
    }
    
    private func getReferenceDistances() -> [Int] {
        
        var refDistances = [Int]()
        
        // get correct set of data depending on flap
        if let referenceDistances = data.referenceDistances[runwayCondition] {
            for (_ ,value) in referenceDistances {
                refDistances.append(value)
            }
            refDistances = refDistances.sorted()
        }
        
        return refDistances
    }
    

    private func calculateWindComponentsFor(heading: Int, windDirection: Int, windSpeed: Int) -> [(component: WindComponent, knots: Double)]{
        
        var results = [(WindComponent, Double)]()
        
        let factoredHeading = heading - 360
        let factoredWindDirection = windDirection - 360
        
        var angle = abs(factoredHeading - factoredWindDirection)
        
        if angle > 180 {
            angle = 360 - angle
        }
        
        if angle == 0 {
            let headwind = Double(windSpeed) * cosine(degrees: angle)
            let headwindComponent = (WindComponent.headwind, abs(headwind))
            
            results.append(headwindComponent)
        }
        else if angle < 90 {
            let headwind = Double(windSpeed) * cosine(degrees: angle)
            let crosswind = Double(windSpeed) * sine(degrees: angle)
            
            let headWindComponent = (WindComponent.headwind, abs(headwind))
            let crosswindCompoent = (WindComponent.crosswind, abs(crosswind))
            
            results.append(headWindComponent)
            results.append(crosswindCompoent)
        }
        else if angle == 90 {
            let crosswind = Double(windSpeed) * sine(degrees: angle)
            let crosswindComponent = (WindComponent.crosswind, abs(crosswind))
            results.append(crosswindComponent)
        }
        else if angle == 180 {
            let tailwind = Double(windSpeed) * cosine(degrees: angle)
            let tailWindComponent = (WindComponent.tailwind, abs(tailwind))
            results.append(tailWindComponent)
        }
        else {
            let tailwind = Double(windSpeed) * cosine(degrees: angle)
            let crosswind = Double(windSpeed) * sine(degrees: angle)
            
            let tailWindComponent = (WindComponent.tailwind, abs(tailwind))
            let crosswindCompoent = (WindComponent.crosswind, abs(crosswind))
            
            results.append(tailWindComponent)
            results.append(crosswindCompoent)
        }
        
        return results
        
    }
    
    private func cosine(degrees: Int) -> Double {
        let deg = Double(degrees)
        let result = cos(deg * M_PI / 180)
        return result
    }
    
    private func sine(degrees: Int) -> Double {
        let deg = Double(degrees)
        let result = sin(deg * M_PI / 180)
        return result
    }
    
}
