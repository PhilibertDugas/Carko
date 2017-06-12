//
//  PhotoCreationLayout.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-11.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit

class PhotoCreationLayout: UICollectionViewLayout {
    private var attributes: [UICollectionViewLayoutAttributes] = []

    private var numberOfColumns = 0
    private var numberOfRow = 0
    private var currentColumn = 0
    private var currentRow = 0

    private var yOffset: [(CGFloat)] = []
    private var xOffset: [(CGFloat)] = []

    override func prepare() {
        attributes.removeAll()
        self.numberOfRow = collectionView!.numberOfSections
        self.numberOfColumns = collectionView!.numberOfSections
        self.xOffset = [CGFloat](repeating: 0, count: self.numberOfRow)
        self.yOffset = [CGFloat](repeating: 0, count: self.numberOfColumns)

        switch collectionView!.numberOfSections {
        case 1:
            setupOneSectionLayout()
            break
        case 2:
            setupTwoSectionLayout()
            break
        case 3:
            setupThreeSectionLayout()
            break
        default:
            return
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let columnWidth = contentWidth / CGFloat(self.numberOfColumns)
        
    }

    private func setupOneSectionLayout() {

    }

    private func setupTwoSectionLayout() {

    }

    private func setupThreeSectionLayout() {

    }
}
