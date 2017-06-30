//
//  ImageLoaderHelper.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-13.
//  Copyright © 2017 QH4L. All rights reserved.
//

import Foundation
import UIKit

struct ImageLoaderHelper {
    static func loadImageFromUrl(_ view: UIImageView, url: URL) {
        let imageReference = AppState.shared.storageReference.storage.reference(forURL: url.absoluteString)
        view.sd_setImage(with: imageReference, placeholderImage: UIImage.init(named: "placeholder-1"))
    }

    static func loadPublicImageIntoView(_ view: UIImageView, url: URL?) {
        view.sd_setImage(with: url, placeholderImage: UIImage.init(named: "placeholder-1"))
    }
}
