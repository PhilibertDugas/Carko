//
//  PhotoEditLayout.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-13.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit

class PhotoEditLayout: UICollectionViewLayout {
    private var cache: [UICollectionViewLayoutAttributes] = []

    private var numberOfColumns = 2
    private var currentColumn = 0

    private var yOffset: [(CGFloat)] = []
    private var xOffset: [(CGFloat)] = []

    private var contentWidth: CGFloat {
        return collectionView!.bounds.width
    }

    private var cellPadding: CGFloat = 0.0

    override func prepare() {
        self.cache.removeAll()
        self.currentColumn = 0
        self.cellPadding = 0.04 * self.contentWidth
        let columnWidth = (contentWidth / CGFloat(self.numberOfColumns))
        let rowHeight = columnWidth

        self.yOffset = [CGFloat](repeating: 0, count: self.numberOfColumns)

        for column in 0 ..< self.numberOfColumns {
            self.xOffset.append(CGFloat(column) * columnWidth)
        }

        for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
            let indexPath = IndexPath.init(row: item, section: 0)
            let frame = CGRect.init(x: self.xOffset[self.currentColumn], y: self.yOffset[self.currentColumn], width: columnWidth, height: rowHeight)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            let attributes = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
            attributes.frame = insetFrame
            self.cache.append(attributes)

            self.yOffset[self.currentColumn] = yOffset[self.currentColumn] + rowHeight
            if self.currentColumn >= (self.numberOfColumns - 1) {
                self.currentColumn = 0
            } else {
                self.currentColumn +=  1
            }
        }

    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.cache
    }
}
