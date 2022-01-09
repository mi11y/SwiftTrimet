//
//  File.swift
//  
//
//  Created by Milly Guitron on 12/17/21.
//

import Foundation

public final class TestData {
    public static let routesJSON: URL = Bundle.module.url(forResource: "TrimetRoutesResponse", withExtension: "json")!
    public static let stopsJSON: URL = Bundle.module.url(forResource: "TrimetRoutesResponse", withExtension: "json")!
    public static let arrivalsJSON: URL = Bundle.module.url(forResource: "TrimetArrivalsResponse", withExtension: "json")!
    public static let vehiclesJSON: URL = Bundle.module.url(forResource: "TrimetVehiclesResponse", withExtension: "json")!
}

internal extension URL {
    /// Returns a `Data` representation of the current `URL`. Force unwrapping as it's only used for tests.
    var data: Data {
        return try! Data(contentsOf: self)
    }
}
