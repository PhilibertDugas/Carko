//
//  BookingManager.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-22.
//  Copyright © 2017 QH4L. All rights reserved.
//

import Foundation
import Stripe

enum BookingErrors {
    case ownParking
    case noPaymentMethod
    case noVehicule
    case reservationConflict
}

struct BookingManager {
    var parking: Parking
    var paymentContext: STPPaymentContext
    var event: Event

    init(parking: Parking, paymentContext: STPPaymentContext, event: Event) {
        self.parking = parking
        self.paymentContext = paymentContext
        self.event = event
    }

    func bookingHasAnyErrors() -> BookingErrors? {
        if self.parking.customerId == AuthenticationHelper.getCustomer().id {
            return .ownParking
        } else if self.paymentContext.selectedPaymentMethod == nil {
            return .noPaymentMethod
        } else if AppState.shared.customer.vehicule == nil {
            return .noVehicule
        } else {
            for reservation in ReservationManager.shared.getReservations() {
                if DateHelper.isSameDay(first: reservation?.startTime, second: event.startTime) {
                    return .reservationConflict
                }
            }
        }
        return nil
    }

    func getAlertController(title: String, message: String, okHandler: @escaping (UIAlertAction) -> Void) -> UIAlertController {
        let controller = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction.init(title: Translations.t("Ok"), style: .default, handler: okHandler))
        return controller
    }
}
