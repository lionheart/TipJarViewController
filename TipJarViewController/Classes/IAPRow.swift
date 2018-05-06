//
//  IAPRow.swift
//  TipJarViewController
//
//  Created by Dan Loewenherz on 5/6/18.
//

public protocol IAPRow {
    var frequency: TipJarFrequency { get }
    var productIdentifier: String { get }
}

extension IAPRow where Self: RawRepresentable, Self.RawValue == Int {
    static var productIdentifiers: [String] {
        var identifiers: [String] = []
        for i in 0..<Int.max {
            guard let identifier = Self(rawValue: i)?.productIdentifier else {
                break
            }
            
            identifiers.append(identifier)
        }
        
        return identifiers
    }
}
