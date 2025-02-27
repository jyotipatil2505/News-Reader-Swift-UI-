//
//  NetworkRequestType.swift
//  NewsAPIKit
//
//  Created by Jyoti Patil on 07/01/25.
//

import Foundation

/// This type alias is used to define HTTP headers, where the headers are represented as a dictionary with String keys and String values.
typealias HTTPHeaders = [String: String]

/// This type alias represents parameters used in the network request, either in the URL query string or in the request body. It is defined as a dictionary with String keys and String values.
typealias Parameters = [String: String]

/// The NetworkRequestType protocol defines the structure of a network request in the application.
protocol NetworkRequestType {
    
    /// Relative path of the endpoint we want to call (ie. `users/login`)
    var path: String { get }
    
    /// This define the HTTP method we should use to perform the call
    /// We have defined it inside an String based enum called `HTTPMethod`
    var httpMethod: HTTPMethod { get }
    
    /// These are the parameters we need to send along with the call.
    /// Params can be passed in the query along with the URL
    var queryParameters: Parameters { get }
    
    // These are the parameters we need to send along with the call.
    /// Params can be passed into the body
    var bodyParameters: Parameters { get }
    
    /// You may also define a list of headers to pass along with each request.
    var headers: HTTPHeaders { get }
    
    ////  A type conforming to the BodyEncoder protocol, responsible for encoding the body parameters into Data.
    var bodyEncoder: BodyEncoder { get }
    
    /// This method prepares and returns a URLRequest object based on the configuration provided by NetworkConfigurable and the request details defined in NetworkRequestType.
    /// It handles URL construction, appending query parameters, setting headers, and encoding the request body.
    func prepareURLRequest(config: NetworkConfigurable, requestType: NetworkRequestType) throws -> URLRequest
}

extension NetworkRequestType {
    
    func prepareURLRequest(config: NetworkConfigurable, requestType: NetworkRequestType) throws -> URLRequest {
        let baseURL = config.baseURL.absoluteString.last != "/"
        ? config.baseURL.absoluteString + "/"
        : config.baseURL.absoluteString
        let endpoint = baseURL.appending(path)
        
        guard let requestURL = URL(string: endpoint) else { throw NetworkError.invalidURL }
        
        Utilities.debugPrint(log: "REQUEST URL ::: \(requestURL)")
                
        var request = URLRequest(url: requestURL)
        
        //HTTP METHOD
        request.httpMethod = httpMethod.rawValue
        
        //HEADERS
        var allHeaders: [String: String] = config.headers
        headers.forEach { allHeaders.updateValue($1, forKey: $0) }
        request.allHTTPHeaderFields = allHeaders

        Utilities.debugPrint(log: "ALL HEADERS ::: \(allHeaders)")
        
        //QUERY PARAMETERS
        var urlQueryItems = [URLQueryItem]()
        queryParameters.forEach {
            urlQueryItems.append(URLQueryItem(name: $0.key, value: "\($0.value)"))
        }
        config.queryParameters.forEach {
            urlQueryItems.append(URLQueryItem(name: $0.key, value: $0.value))
        }
        !urlQueryItems.isEmpty ? request.url?.append(queryItems: urlQueryItems) : nil
        
        //HTTP BODY
        if !bodyParameters.isEmpty {
            request.httpBody = bodyEncoder.encode(bodyParameters)
        }
        
        Utilities.debugPrint(log: "FINAL REQUEST ::: \(request)")

        return request
    }
}
