//
//  File.swift
//  
//
//  Created by Milly Guitron on 12/18/21.
//

import Foundation

public class ServiceLocator {
    public static func routeConfig() -> URLComponents {
        var components = initURLComponents()
        components.path = "/ws/v1/routeConfig"
        return components
    }
    
    private static func initURLComponents() -> URLComponents {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "developer.trimet.org"
        return components
    }
}
