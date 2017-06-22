//
//  AppState.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-11-27.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation
import FirebaseStorage
import Firebase
import Stripe

class AppState: NSObject {
    static let shared = AppState.init()
    static let companyEmail = "apyaparking@gmail.com"
    static let provinces = ["AB", "BC", "MB", "NB", "NL", "NS", "ON", "PE", "QC", "SK"]

    var customer: Customer!
    var authToken: String!
    var customerParkings = [Int: Parking]()
    let storageReference = Storage.storage().reference()

    func cacheCustomer(_ customer: Customer) {
        self.customer = customer
        updateCache()
    }

    func cacheAuthToken(_ token: String) {
        self.authToken = token
        self.updateTokenCache()
    }

    func cacheBankToken(_ token: STPToken) {
        self.customer.accountId = token.tokenId
        self.customer.externalLast4Digits = token.bankAccount?.last4()
        self.customer.externalBankName = token.bankAccount?.bankName!
        updateCache()
    }

    func cacheCustomerParkings(_ parkings: [(Parking)]) {
        for parking in parkings {
            self.customerParkings[parking.id!] = parking
        }
    }

    func cachedCustomerParkings() -> [(Parking)] {
        var parkings = [Parking]()
        for (_, parking) in self.customerParkings {
            parkings.append(parking)
        }
        return parkings
    }

    func cachedCustomer() -> Customer? {
        if self.customer == nil {
            if let dict = UserDefaults.standard.dictionary(forKey: "user") {
                self.customer = Customer.init(customer: dict)
            }
        }
        return self.customer
    }

    func resetCustomer() {
        self.customer = nil
        UserDefaults.standard.removeObject(forKey: "user")
    }

    func cachedToken() -> String? {
        if self.authToken == nil {
            if let token = UserDefaults.standard.string(forKey: "authToken") {
                self.authToken = token
            }
        }
        return self.authToken
    }

    private func updateCache() {
        UserDefaults.standard.set(self.customer.toDictionnary(), forKey: "user")
    }

    fileprivate func updateTokenCache() {
        UserDefaults.standard.set(self.authToken, forKey: "authToken")
    }

    // Return IP address of WiFi interface (en0) as a String, or `nil`
    class func getWiFiAddress() -> String? {
        var address : String?

        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }

        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    // Convert interface address to a human readable string:
                    var addr = interface.ifa_addr.pointee
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(&addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        return address
    }
}
