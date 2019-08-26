import Foundation

/// Defines where the user defaults are stored
// enum TimeStoragePolicy {
//    /// Uses `UserDefaults.Standard`
//    case standard
//    /// Attempts to use the specified App Group ID (which is the String) to access shared storage.
//    case appGroup(String)
//
//    /// Creates an instance
//    ///
//    /// - parameter appGroupID: The App Group ID that maps to a shared container for `UserDefaults`. If this
//    ///                         is nil, the resulting instance will be `.standard`
//     init(appGroupID: String?) {
//        if let appGroupID = appGroupID {
//            self = .appGroup(appGroupID)
//        } else {
//            self = .standard
//        }
//    }
//}


/// Handles saving and retrieving instances of `TimeFreeze` for quick retrieval
 struct TimeStorage {
    private var userDefaults: Keychain
    private let kDefaultsKey = "PresenceStableTime"
    private let kGroupKey = "com.ticketmaster.tiktok"
    /// The most recent stored `TimeFreeze`. Getting retrieves from the UserDefaults defined by the storage
    /// policy. Setting sets the value in UserDefaults
    var stableTime: TimeFreeze? {
        get {
            
            let decoder = JSONDecoder()
            
            do {
                guard let json: String = try self.userDefaults.getString(kDefaultsKey) else {
                    return nil
                }

                let jData = json.data(using: .utf8)
                let stored = try decoder.decode([String : TimeInterval].self, from: jData!)
                
                guard let previousStableTime = TimeFreeze(from: stored) else {
                  
                    return nil
                }
                 return previousStableTime
                
            } catch  {
               
                return nil
            }

        }

        set {
            guard let newFreeze = newValue , let freezeJ = newFreeze.toJSON() else {
                return
            }
            
            do {
                 try self.userDefaults.set(freezeJ, key: kDefaultsKey)
            } catch  {
                 return
            }

        }
    }

    /// Creates an instance
    ///
    /// - parameter storagePolicy: Defines the storage location of `UserDefaults`
     init() {
        userDefaults = Keychain(service:kGroupKey).synchronizable(true)
    }
}
