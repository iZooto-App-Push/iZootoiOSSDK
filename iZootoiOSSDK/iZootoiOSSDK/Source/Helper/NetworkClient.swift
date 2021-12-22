//
//  NetworkClient.swift
//  NetworkClient
//
//  Created by Amit on 14/09/21.
//

import Foundation

class NetworkClient
{
    
    var delegate : ResponseDelegate?
    class var shareInstance : NetworkClient
    {
        struct SingletonWrapper
        {
        static let singleton = NetworkClient()

        }
       return SingletonWrapper.singleton

    }
    let session = URLSession(configuration:
                         URLSessionConfiguration.default,
                         delegate: nil, delegateQueue: nil)
    func fetchWithRetry(url: String,
                       completion: @escaping (_ reuestParams: String?,
                                              _ error: String?) -> Void) {
                                              
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = "GET"
            requestWithRetry(with: request) {
                          (data, response, error, retriesLeft) in
                          
                if let error = error {
                    completion(nil, "\(error.localizedDescription)")
                    return
                }
                
                let statusCode = (response as! HTTPURLResponse).statusCode

                if statusCode == 200, let data = data {
                    
                    let outputStr  = String(data: data, encoding: String.Encoding.utf8)!
                    
                   completion(outputStr,nil)
                } else {
                    completion(error?.localizedDescription, "Error encountered1: \(statusCode)")
                }
            }
        }
    // **** This function is recursive, and will automatically retry
       private func requestWithRetry(with request: URLRequest,
                                     retries: Int = 3,
                                     completionHandler: @escaping
                                           (Data?, URLResponse?, Error?,
                                            _ retriesLeft: Int) -> Void) {
           
           let task = session.dataTask(with: request) {
                                      (data, response, error) in
               if error != nil {
                   completionHandler(data, response, error, retries)
                   return
               }
               
               let statusCode = (response as! HTTPURLResponse).statusCode
               
               if (200...299).contains(statusCode) {
                   completionHandler(data, response, error, retries)
               } else if retries > 0 {
                   print("Received status code \(statusCode) with \(retries) retries remaining. RETRYING VIA RECURSIVE CALL.")
                   self.requestWithRetry(with: request,
                                 retries: retries - 1,
                                 completionHandler: completionHandler)
               } else {
                   print("Received status code \(statusCode) with \(retries) retries remaining. EXIT WITH FAILURE.")
                   completionHandler(data, response, error, retries)
               }
           }
           task.resume()
       }
    // fetching without retry
    // MARK: - Fetching without retry
       func fetchWithoutRetry(url: String, completion: @escaping (_ requestParams: RequestParams?, _ error: String?) -> Void) {
           var request = URLRequest(url: URL(string: url)!)
           request.httpMethod = "GET"
           
           let task = session.dataTask(with: request) { (data, response, error) in
               let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
               
               if let error = error {
                   completion(nil, error.localizedDescription)
                   return
               }
               
               if (200...299).contains(statusCode), let data = data {
                   let requestParams = try? JSONDecoder().decode(RequestParams.self, from: data)
                   completion(requestParams, nil)
               } else {
                   completion(nil, "Error encountered: \(statusCode)")
               }
           }
           task.resume()
       }
    // fetching without retry
    // MARK: - Fetching without retry
    func fetchWithoutPostRetry(url: String,token: String,izootoID : Int ,data : Dictionary<String,Any>, completion: @escaping (_ requestParams: RequestParams?, _ error: String?) -> Void) {
           var request = URLRequest(url: URL(string: url)!)
           request.httpMethod = "POST"
           let task = session.dataTask(with: request) { (data, response, error) in
               let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
               
               if let error = error {
                   completion(nil, error.localizedDescription)
                   return
               }
               
               if (200...299).contains(statusCode), let data = data {
                   let requestParams = try? JSONDecoder().decode(RequestParams.self, from: data)
                   completion(requestParams, nil)
               } else {
                   completion(nil, "Error encountered: \(statusCode)")
               }
           }
           task.resume()
       }
}

struct RequestParams : Decodable {
    let name: String
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Double
    let humidity: Double
    let visibility: Double
    let windSpeed: Double
    let windDirection: Double
    let response : String
    
}
protocol ResponseDelegate
{
    func onSucess(statusCode : Int,response : String)
    func onFailure(statusCode : Int, error : String)
}
