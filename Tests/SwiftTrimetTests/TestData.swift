//
//  File.swift
//  
//
//  Created by Milly Guitron on 12/17/21.
//

import Foundation

public final class TestData {
    public static let exampleJSON: URL = Bundle.module.url(forResource: "TrimetRoutesResponse", withExtension: "json")!
}

internal extension URL {
    /// Returns a `Data` representation of the current `URL`. Force unwrapping as it's only used for tests.
    var data: Data {
        return try! Data(contentsOf: self)
    }
}
