//
//  APIClient.swift
//  +r3
//
//  Created by Xin Hua on 9/21/16.
//  Copyright © 2016 Igor Gubanov. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import CoreLocation
import SystemConfiguration

class APIClient: NSObject {

    // Shared;
    static let shared = APIClient()
    
    // Base URL;
    let baseURL = "http://r3.rna.webfactional.com/poilist.php"
    
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = flags == .reachable
        let needsConnection = flags == .connectionRequired
        
        return isReachable && !needsConnection
    }
    
    // Places;
    func places(_ location: CLLocation, completion: ((_ places: [Place]) -> Void)!) {
        // PersistentContainer;
        let appDelegate = AppDelegate.shared
        let persistentContainer = appDelegate.persistentContainer

        if isConnectedToNetwork() {
            // URL;
            let urlString = "\(baseURL)?x=\(location.coordinate.latitude)&y=\(location.coordinate.longitude)"
            
            // Request;
            Alamofire.request(urlString, method: .get)
                .responseJSON { response in
                    // Places;
                    var places = [Place]()
                    
                    switch response.result {
                    case .success(let responseObject):
                        // Places;
                        let responseArray = responseObject as! NSArray
                        for placeItem in responseArray {
                            let placeDictionary = placeItem as! NSDictionary
                            
                            let place = NSEntityDescription.insertNewObject(forEntityName: "Place", into: persistentContainer.viewContext) as? Place
                            place?.id = placeDictionary.object(forKey: "record_id") as? String
                            place?.insertedDate = placeDictionary.object(forKey: "insert_date") as? String
                            place?.latitude = placeDictionary.object(forKey: "x") as? String
                            place?.longitude = placeDictionary.object(forKey: "y") as? String
                            place?.shortInfo = placeDictionary.object(forKey: "short_info") as? String
                            place?.longInfo = placeDictionary.object(forKey: "long_info") as? String
                            places.append(place!)
                        }
                        
                        // Save;
                        appDelegate.saveContext()
                        break
                        
                    case .failure:
                        break
                    }
                    
                    completion?(places)
            }
        }
        else {
            // Request;
            let request = NSFetchRequest<Place>(entityName: "Place")
            
            do {
                // Places;
                let places = try persistentContainer.viewContext.fetch(request)
                completion?(places)
            }
            catch let error as NSError {
                print("\(#function) threw exception: \(error.localizedDescription)")
            }
            catch {
                print("\(#function) threw exception")
                fatalError()
            }
        }
    }

    
}
