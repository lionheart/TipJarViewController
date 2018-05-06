//
//  TipJarFrequency.swift
//  TipJarViewController
//
//  Created by Dan Loewenherz on 5/6/18.
//

public enum TipJarFrequency {
    case monthly
    case yearly
    case oneTime
    
    var description: String {
        switch self {
        case .monthly: return "monthly"
        case .yearly: return "yearly"
        case .oneTime: return "one-time"
        }
    }
}
