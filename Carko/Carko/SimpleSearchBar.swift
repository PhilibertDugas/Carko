//
//  SimpleSearchBar.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-12-28.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit

class SimpleSearchBar: UISearchBar {
    override func layoutSubviews() {
        super.layoutSubviews()
        setShowsCancelButton(false, animated: false)
    }
}

class SimpleSearchController: UISearchController, UISearchBarDelegate {
    lazy var _searchBar: SimpleSearchBar = {
        [unowned self] in
        let result = SimpleSearchBar(frame: CGRect.zero)
        result.delegate = self
        return result
    }()

    override var searchBar: UISearchBar {
        get {
            return _searchBar
        }
    }
}
