//
//  Constants.swift
//  IFLD Calculator
//
//  Created by Adam Zemmoura on 03/05/2017.
//  Copyright © 2017 Adam Zemmoura. All rights reserved.
//

import Foundation

struct Selection {
    static let flapSelection = "flapSelection"
    static let weightSelection = "weightSelection"
    static let reverseSelection = "reverseSelection"
    static let windDirectionSelection = "windDirectionSelection"
    static let windSpeedSelection = "windSpeedSelection"
    static let tempSelection = "tempSelection"
    static let runwaySelection = "runwaySelection"
}

struct RunwayCondition {
    static let good = "good"
    static let goodToMedium = "good-med"
    static let medium = "medium"
    static let mediumPoor = "med-poor"
    static let poor = "poor"
}

enum AutobrakeSetting: String {
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case max
}

enum AircraftVariant: String {
    case twoHundreds = "777-200"
    case twoHundredsER = "777-200ER"
    case threeHundredER = "777-300ER"
}
