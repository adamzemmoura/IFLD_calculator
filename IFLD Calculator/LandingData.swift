//
//  Flap30Data_Normal.swift
//  IFLD Calculator
//
//  Created by Adam Zemmoura on 01/05/2017.
//  Copyright © 2017 Adam Zemmoura. All rights reserved.
//

import Foundation

protocol LandingData {
    var referenceDistances: [String: [String:Int]] { get }
    var weightAdjustments: [String: [String:(above:Int,below:Int)]] { get }
    var altitudeAdjustments: [String: [String: Int]] { get }
    var windAdjustments: [String: [String:(head:Int,tail:Int)]] { get }
    var slopeAdjustments: [String: [String:(down:Int,up:Int)]] { get }
    var tempAdjustments: [String: [String:(above:Int,below:Int)]] { get }
    var vrefAdjustments: [String: [String:Int]] { get }
    var reverseAdjustments: [String: [String:(one:Int,none:Int)]] { get }
}

// MARK: Flap 30 Normal
struct Flap30Data_Normal: LandingData {
    
    let referenceDistances: [String: [String:Int]] = ["dry":["max":1530,
                                                             "4":1850,
                                                             "3":2175,
                                                             "2":2400,
                                                             "1":2545,],
                                                      "good":["max":1660,
                                                              "4":1855,
                                                              "3":2175,
                                                              "2":2400,
                                                              "1":2545,],
                                                      "good-med":["max":1855,
                                                                  "4":1970,
                                                                  "3":2225,
                                                                  "2":2425,
                                                                  "1":2560,],
                                                      "med":["max":2055,
                                                             "4":2085,
                                                             "3":2275,
                                                             "2":2450,
                                                             "1":2575,],
                                                      "med-poor":["max":2310,
                                                                  "4":2330,
                                                                  "3":2445,
                                                                  "2":2580,
                                                                  "1":2675,],
                                                      "poor":["max":2560,
                                                              "4":2580,
                                                              "3":2615,
                                                              "2":2710,
                                                              "1":2775,]]
    
    let weightAdjustments: [String: [String:(above:Int,below:Int)]] = ["dry":["max": (25,-5),
                                                                  "4":(30,-10),
                                                                  "3":(35,-10),
                                                                  "2":(45,-25),
                                                                  "1":(50,-30)],
                                                           "good":["max":(30,-10),
                                                                   "4":(30,-5),
                                                                   "3":(35,-10),
                                                                   "2":(45,-25),
                                                                   "1":(50,-30)],
                                                           "good-med":["max":(35,-25),
                                                                       "4":(35,-10),
                                                                       "3":(35,-15),
                                                                       "2":(45,-25),
                                                                       "1":(50,-30)],
                                                           "med":["max":(40,-15),
                                                                  "4":(40,-15),
                                                                  "3":(40,-15),
                                                                  "2":(45,-25),
                                                                  "1":(50,-30)],
                                                           "med-poor":["max":(50,-25),
                                                                       "4":(50,-25),
                                                                       "3":(45,-25),
                                                                       "2":(50,-30),
                                                                       "1":(55,-30)],
                                                           "poor":["max":(60,-35),
                                                                   "4":(60,-35),
                                                                   "3":(50,-30),
                                                                   "2":(60,-35),
                                                                   "1":(60,-35)]]
    
    let altitudeAdjustments: [String: [String: Int]] = ["dry":["max": 30,
                                                               "4": 45,
                                                               "3": 50,
                                                               "2": 65,
                                                               "1": 75],
                                                        "good":["max": 40,
                                                                "4": 45,
                                                                "3": 50,
                                                                "2": 65,
                                                                "1": 75],
                                                        "good-med":["max": 50,
                                                                    "4": 50,
                                                                    "3": 55,
                                                                    "2": 65,
                                                                    "1": 75],
                                                        "med":["max": 60,
                                                               "4": 60,
                                                               "3": 60,
                                                               "2": 65,
                                                               "1": 75],
                                                        "med-poor":["max": 70,
                                                                    "4": 70,
                                                                    "3": 70,
                                                                    "2": 70,
                                                                    "1": 80],
                                                        "poor":["max": 80,
                                                                "4": 80,
                                                                "3": 80,
                                                                "2": 80,
                                                                "1": 85]]
    
    let windAdjustments: [String: [String:(head:Int,tail:Int)]] = ["dry":["max": (-60,200),
                                                                "4":(-80,280),
                                                                "3":(-105,350),
                                                                "2":(-115,405),
                                                                "1":(-130,455)],
                                                         "good":["max":(-70,255),
                                                                 "4":(-80,290),
                                                                 "3":(-105,350),
                                                                 "2":(-115,405),
                                                                 "1":(-130,455)],
                                                         "good-med":["max":(-90,330),
                                                                     "4":(-95,345),
                                                                     "3":(-110,390),
                                                                     "2":(-120,430),
                                                                     "1":(-130,470)],
                                                         "med":["max":(-110,405),
                                                                "4":(-110,405),
                                                                "3":(-115,430),
                                                                "2":(-125,455),
                                                                "1":(-130,485)],
                                                         "med-poor":["max":(-130,510),
                                                                     "4":(-135,510),
                                                                     "3":(-140,530),
                                                                     "2":(-145,545),
                                                                     "1":(-150,565)],
                                                         "poor":["max":(-155,620),
                                                                 "4":(-160,620),
                                                                 "3":(-160,625),
                                                                 "2":(-165,640),
                                                                 "1":(-165,650)]]
    
    let slopeAdjustments: [String: [String:(down:Int,up:Int)]] = ["dry":["max": (0,0),
                                                                 "4":(0,-5),
                                                                 "3":(10,-10),
                                                                 "2":(25,-40),
                                                                 "1":(50,-60)],
                                                          "good":["max":(30,-25),
                                                                  "4":(5,-5),
                                                                  "3":(10,-10),
                                                                  "2":(25,-40),
                                                                  "1":(50,-60)],
                                                          "good-med":["max":(55,-45),
                                                                      "4":(45,-30),
                                                                      "3":(35,-25),
                                                                      "2":(40,-50),
                                                                      "1":(65,-65)],
                                                          "med":["max":(80,-65),
                                                                 "4":(80,-60),
                                                                 "3":(60,-40),
                                                                 "2":(60,-60),
                                                                 "1":(75,-70)],
                                                          "med-poor":["max":(140,-100),
                                                                      "4":(135,-95),
                                                                      "3":(120,-75),
                                                                      "2":(115,-90),
                                                                      "1":(125,-95)],
                                                          "poor":["max":(195,-130),
                                                                  "4":(190,-130),
                                                                  "3":(185,-110),
                                                                  "2":(175,-120),
                                                                  "1":(180,-120)]]
    
    let tempAdjustments: [String: [String:(above:Int,below:Int)]] = ["dry":["max": (35,-35),
                                                                "4":(45,-45),
                                                                "3":(60,-60),
                                                                "2":(65,-65),
                                                                "1":(70,-70)],
                                                         "good":["max":(35,-35),
                                                                 "4":(45,-45),
                                                                 "3":(60,-60),
                                                                 "2":(65,-65),
                                                                 "1":(70,-70)],
                                                         "good-med":["max":(40,-45),
                                                                     "4":(50,-50),
                                                                     "3":(60,-60),
                                                                     "2":(65,-65),
                                                                     "1":(70,-70)],
                                                         "med":["max":(45,-50),
                                                                "4":(50,-50),
                                                                "3":(60,-60),
                                                                "2":(65,-65),
                                                                "1":(70,-70)],
                                                         "med-poor":["max":(55,-60),
                                                                     "4":(60,-60),
                                                                     "3":(60,-65),
                                                                     "2":(65,-65),
                                                                     "1":(70,-70)],
                                                         "poor":["max":(65,-65),
                                                                 "4":(65,-70),
                                                                 "3":(65,-70),
                                                                 "2":(70,-70),
                                                                 "1":(70,-75)]]
    
    let vrefAdjustments: [String: [String:Int]] = ["dry":["max":75,
                                                          "4":90,
                                                          "3":110,
                                                          "2":100,
                                                          "1":105,],
                                                   "good":["max":70,
                                                           "4":90,
                                                           "3":110,
                                                           "2":100,
                                                           "1":105,],
                                                   "good-med":["max":75,
                                                               "4":90,
                                                               "3":110,
                                                               "2":100,
                                                               "1":105,],
                                                   "med":["max":80,
                                                          "4":85,
                                                          "3":110,
                                                          "2":100,
                                                          "1":105,],
                                                   "med-poor":["max":80,
                                                               "4":85,
                                                               "3":105,
                                                               "2":100,
                                                               "1":100,],
                                                   "poor":["max":80,
                                                           "4":80,
                                                           "3":105,
                                                           "2":100,
                                                           "1":100,]]
    
    let reverseAdjustments: [String: [String:(one:Int,none:Int)]] = ["dry":["max": (0,0),
                                                                   "4":(0,0),
                                                                   "3":(0,0),
                                                                   "2":(25,25),
                                                                   "1":(140,140)],
                                                            "good":["max":(85,200),
                                                                    "4":(10,50),
                                                                    "3":(0,0),
                                                                    "2":(25,25),
                                                                    "1":(140,140)],
                                                            "good-med":["max":(160,405),
                                                                        "4":(125,335),
                                                                        "3":(65,235),
                                                                        "2":(60,185),
                                                                        "1":(160,240)],
                                                            "med":["max":(230,605),
                                                                   "4":(235,620),
                                                                   "3":(125,465),
                                                                   "2":(100,345),
                                                                   "1":(185,345)],
                                                            "med-poor":["max":(380,1115),
                                                                        "4":(385,1130),
                                                                        "3":(320,1045),
                                                                        "2":(265,930),
                                                                        "1":(325,900)],
                                                            "poor":["max":(535,1625),
                                                                    "4":(535,1640),
                                                                    "3":(510,1620),
                                                                    "2":(430,1520),
                                                                    "1":(465,1455)]]
    
}

// MARK: Flap 25 Normal
struct Flap25Data_Normal: LandingData {

    let referenceDistances: [String: [String:Int]] = ["dry":["max":1625,
                                                             "4":1980,
                                                             "3":2335,
                                                             "2":2555,
                                                             "1":2695,],
                                                      "good":["max":1740,
                                                              "4":1980,
                                                              "3":2335,
                                                              "2":2555,
                                                              "1":2695,],
                                                      "good-med":["max":1945,
                                                                  "4":2090,
                                                                  "3":2385,
                                                                  "2":2580,
                                                                  "1":2710,],
                                                      "med":["max":2155,
                                                             "4":2200,
                                                             "3":2435,
                                                             "2":2610,
                                                             "1":2725,],
                                                      "med-poor":["max":2420,
                                                                  "4":2450,
                                                                  "3":2600,
                                                                  "2":2735,
                                                                  "1":2825,],
                                                      "poor":["max":2680,
                                                              "4":2700,
                                                              "3":2770,
                                                              "2":2860,
                                                              "1":2925,]]
    
    let weightAdjustments: [String: [String:(above:Int,below:Int)]] = ["dry":["max": (25,-15),
                                                                  "4":(35,-25),
                                                                  "3":(40,-30),
                                                                  "2":(50,-40),
                                                                  "1":(60,-45)],
                                                           "good":["max":(30,-15),
                                                                   "4":(35,-25),
                                                                   "3":(40,-30),
                                                                   "2":(50,-40),
                                                                   "1":(60,-45)],
                                                           "good-med":["max":(35,-25),
                                                                       "4":(35,-25),
                                                                       "3":(45,-30),
                                                                       "2":(50,-40),
                                                                       "1":(60,-45)],
                                                           "med":["max":(40,-30),
                                                                  "4":(40,-30),
                                                                  "3":(45,-35),
                                                                  "2":(50,-40),
                                                                  "1":(60,-45)],
                                                           "med-poor":["max":(50,-35),
                                                                       "4":(50,-35),
                                                                       "3":(50,-40),
                                                                       "2":(60,-45),
                                                                       "1":(60,-50)],
                                                           "poor":["max":(60,-45),
                                                                   "4":(60,-45),
                                                                   "3":(60,-45),
                                                                   "2":(65,-45),
                                                                   "1":(65,-50)]]
    
    let altitudeAdjustments: [String: [String: Int]] = ["dry":["max": 35,
                                                               "4": 45,
                                                               "3": 60,
                                                               "2": 70,
                                                               "1": 80],
                                                        "good":["max": 40,
                                                                "4": 45,
                                                                "3": 60,
                                                                "2": 70,
                                                                "1": 80],
                                                        "good-med":["max": 50,
                                                                    "4": 50,
                                                                    "3": 60,
                                                                    "2": 70,
                                                                    "1": 80],
                                                        "med":["max": 60,
                                                               "4": 60,
                                                               "3": 65,
                                                               "2": 75,
                                                               "1": 80],
                                                        "med-poor":["max": 70,
                                                                    "4": 70,
                                                                    "3": 75,
                                                                    "2": 80,
                                                                    "1": 85],
                                                        "poor":["max": 85,
                                                                "4": 85,
                                                                "3": 85,
                                                                "2": 85,
                                                                "1": 90]]
    
    let windAdjustments: [String: [String:(head:Int,tail:Int)]] = ["dry":["max": (-65,205),
                                                                "4":(-85,295),
                                                                "3":(-110,370),
                                                                "2":(-120,420),
                                                                "1":(-130,465)],
                                                         "good":["max":(-75,260),
                                                                 "4":(-85,300),
                                                                 "3":(-110,370),
                                                                 "2":(-120,420),
                                                                 "1":(-130,465)],
                                                         "good-med":["max":(-90,335),
                                                                     "4":(-100,355),
                                                                     "3":(-115,405),
                                                                     "2":(-125,445),
                                                                     "1":(-135,480)],
                                                         "med":["max":(-110,410),
                                                                "4":(-115,415),
                                                                "3":(-120,445),
                                                                "2":(-130,470),
                                                                "1":(-140,495)],
                                                         "med-poor":["max":(-135,520),
                                                                     "4":(-140,525),
                                                                     "3":(-145,540),
                                                                     "2":(-150,560),
                                                                     "1":(-155,580)],
                                                         "poor":["max":(-160,625),
                                                                 "4":(-160,635),
                                                                 "3":(-165,640),
                                                                 "2":(-165,650),
                                                                 "1":(-175,660)]]
    
    let slopeAdjustments: [String: [String:(down:Int,up:Int)]] = ["dry":["max": (0,0),
                                                                 "4":(0,-5),
                                                                 "3":(10,-15),
                                                                 "2":(35,-50),
                                                                 "1":(60,-65)],
                                                          "good":["max":(30,-25),
                                                                  "4":(5,-5),
                                                                  "3":(10,-15),
                                                                  "2":(35,-50),
                                                                  "1":(60,-65)],
                                                          "good-med":["max":(60,-45),
                                                                      "4":(40,-30),
                                                                      "3":(30,-30),
                                                                      "2":(50,-60),
                                                                      "1":(70,-70)],
                                                          "med":["max":(85,-65),
                                                                 "4":(75,-50),
                                                                 "3":(50,-45),
                                                                 "2":(65,-70),
                                                                 "1":(85,-80)],
                                                          "med-poor":["max":(140,-100),
                                                                      "4":(130,-90),
                                                                      "3":(115,-80),
                                                                      "2":(120,-100),
                                                                      "1":(135,-105)],
                                                          "poor":["max":(195,-130),
                                                                  "4":(190,-130),
                                                                  "3":(180,-115),
                                                                  "2":(180,-125),
                                                                  "1":(185,-125)]]
    
    let tempAdjustments: [String: [String:(above:Int,below:Int)]] = ["dry":["max": (35,-35),
                                                                "4":(45,-45),
                                                                "3":(65,-65),
                                                                "2":(70,-70),
                                                                "1":(70,-70)],
                                                         "good":["max":(35,-35),
                                                                 "4":(45,-45),
                                                                 "3":(65,-65),
                                                                 "2":(70,-70),
                                                                 "1":(70,-70)],
                                                         "good-med":["max":(45,-45),
                                                                     "4":(50,-50),
                                                                     "3":(65,-65),
                                                                     "2":(70,-70),
                                                                     "1":(70,-70)],
                                                         "med":["max":(50,-50),
                                                                "4":(50,-60),
                                                                "3":(65,-65),
                                                                "2":(70,-70),
                                                                "1":(70,-75)],
                                                         "med-poor":["max":(60,-60),
                                                                     "4":(60,-65),
                                                                     "3":(65,-70),
                                                                     "2":(70,-70),
                                                                     "1":(70,-80)],
                                                         "poor":["max":(65,-70),
                                                                 "4":(65,-70),
                                                                 "3":(70,-75),
                                                                 "2":(70,-75),
                                                                 "1":(75,-80)]]
    
    let vrefAdjustments: [String: [String:Int]] = ["dry":["max":75,
                                                          "4":100,
                                                          "3":110,
                                                          "2":100,
                                                          "1":105,],
                                                   "good":["max":70,
                                                           "4":100,
                                                           "3":110,
                                                           "2":100,
                                                           "1":105,],
                                                   "good-med":["max":75,
                                                               "4":95,
                                                               "3":110,
                                                               "2":100,
                                                               "1":105,],
                                                   "med":["max":80,
                                                          "4":90,
                                                          "3":110,
                                                          "2":100,
                                                          "1":105,],
                                                   "med-poor":["max":85,
                                                               "4":85,
                                                               "3":105,
                                                               "2":95,
                                                               "1":100,],
                                                   "poor":["max":85,
                                                           "4":80,
                                                           "3":105,
                                                           "2":90,
                                                           "1":100,]]

    let reverseAdjustments: [String : [String : (one: Int, none: Int)]] = ["dry":["max": (0,0),
                                                                   "4":(0,0),
                                                                   "3":(0,0),
                                                                   "2":(60,60),
                                                                   "1":(195,205)],
                                                            "good":["max":(100,235),
                                                                    "4":(10,50),
                                                                    "3":(0,0),
                                                                    "2":(60,60),
                                                                    "1":(195,205)],
                                                            "good-med":["max":(180,460),
                                                                        "4":(130,370),
                                                                        "3":(65,245),
                                                                        "2":(95,225),
                                                                        "1":(220,315)],
                                                            "med":["max":(260,685),
                                                                   "4":(245,690),
                                                                   "3":(125,495),
                                                                   "2":(130,395),
                                                                   "1":(240,425)],
                                                            "med-poor":["max":(425,1260),
                                                                        "4":(420,1270),
                                                                        "3":(330,1145),
                                                                        "2":(305,1050),
                                                                        "1":(390,1035)],
                                                            "poor":["max":(585,1840),
                                                                    "4":(590,1850),
                                                                    "3":(535,1800),
                                                                    "2":(475,1700),
                                                                    "1":(535,1645)]]
    
}

