//
//  Variants.swift
//  IFLD Calculator
//
//  Created by Adam Zemmoura on 04/05/2017.
//  Copyright © 2017 Adam Zemmoura. All rights reserved.
//

import Foundation

struct AircraftVariants {
    
    static let twoHundred = "777-200"
    static let twoHundredER = "777-200ER"
    static let threeHundredER = "777-300ER"
    
    static var variants: [String] {
        return [twoHundred,twoHundredER,threeHundredER]
    }
    
}
