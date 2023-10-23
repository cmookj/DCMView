//
//  Utility.swift
//  DCMView
//
//  Created by Changmook Chun on 10/22/23.
//

import Foundation

func saturate(value v: CGFloat, toUpper upper: Int, andLowerLimit lower: Int) -> Int {
    if Int(v) < lower {
        return lower
    }
    
    if Int(v) > upper {
        return upper
    }
    
    return Int(v)
}
