//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

let heading = 000
let windDirection = 000
let windSpeed = 60

func cosine(degrees: Int) -> Double {
    let deg = Double(degrees)
    let result = cos(deg * M_PI / 180)
    return result
}

func sine(degrees: Int) -> Double {
    let deg = Double(degrees)
    let result = sin(deg * M_PI / 180)
    return result
}


func calculateWindComponentsFor(heading: Int,
                                windDirection: Int,
                                windSpeed: Int) {
    
    let factoredHeading = heading - 360
    let factoredWindDirection = windDirection - 360
    
    var angle = abs(factoredHeading - factoredWindDirection)
    
    if angle > 180 {
        angle = 360 - angle
    }
    
    if angle < 90 {
        let headwind = Double(windSpeed) * cosine(degrees: angle)
        let crosswind = Double(windSpeed) * sine(degrees: angle)
        print("headwind : \(abs(headwind))\ncrosswind: \(abs(crosswind))")
        
    }
    else if angle == 90 {
        let crosswind = Double(windSpeed) * sine(degrees: angle)
        print("crosswind: \(abs(crosswind))")
    }
    else if angle == 180 {
        let tailwind = Double(windSpeed) * cosine(degrees: angle)
        print("tailwind: \(abs(tailwind))")
    }
    else {
        let tailwind = Double(windSpeed) * cosine(degrees: angle)
        let crosswind = Double(windSpeed) * sine(degrees: angle)
        print("tailwind : \(abs(tailwind))\ncrosswind: \(abs(crosswind))")
    }
    
}

calculateWindComponentsFor(heading: heading, windDirection: windDirection, windSpeed: windSpeed)

















