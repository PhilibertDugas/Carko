//
//  EventsLayout.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-30.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit

class EventsLayout: UICollectionViewLayout {
    private var cache: [UICollectionViewLayoutAttributes] = []

    private var numberOfColumns = 2
    private var currentColumn = 0

    private var yOffset: [(CGFloat)] = []
    private var xOffset: [(CGFloat)] = []

    private let reservationRowHeight: CGFloat = 345
    private let firstSectionRowHeight: CGFloat = 165
    private let bigEventRowHeight: CGFloat = 345
    private var squareCellHeight: CGFloat = 0.0

    private var contentWidth: CGFloat {
        return collectionView!.bounds.width
    }
    private var contentHeight: CGFloat = 0.0

    private var cellPadding: CGFloat = 0.0


    override var collectionViewContentSize: CGSize {
        return CGSize.init(width: contentWidth, height: contentHeight)
    }

    override func prepare() {
        self.cache.removeAll()
        contentHeight = 0

        self.currentColumn = 0
        self.cellPadding = 0.03 * self.contentWidth
        let columnWidth = (contentWidth / CGFloat(self.numberOfColumns))


        self.yOffset = [CGFloat](repeating: 0, count: self.numberOfColumns)

        for column in 0 ..< self.numberOfColumns {
            self.xOffset.append(CGFloat(column) * columnWidth)
        }

        setupFirstSection()
        setupSecondSection()
        setupThirdSection()
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.cache
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes.init(forSupplementaryViewOfKind: elementKind, with: indexPath)
        let frame = CGRect(x: self.xOffset[0], y: self.yOffset[0], width: contentWidth, height: UIScreen.main.bounds.height * 0.1)
        let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
        attributes.frame = insetFrame

        return attributes
    }

    private func setupFirstSection() {
        for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
            let indexPath = IndexPath.init(row: item, section: 0)
            let height = reservationRowHeight + ( 2 * cellPadding)
            let frame = CGRect.init(x: 0, y: self.yOffset[0], width: contentWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            contentHeight = insetFrame.maxY
            let attributes = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
            attributes.frame = insetFrame
            self.cache.append(attributes)

            self.yOffset[0] += height
            self.yOffset[1] += height
        }
    }

    private func setupSecondSection() {
        if collectionView?.numberOfItems(inSection: 0) == 0 {
            addHeader()
        }

        for item in 0 ..< collectionView!.numberOfItems(inSection: 1) {
            let indexPath = IndexPath.init(row: item, section: 1)
            let height = firstSectionRowHeight + (2 * cellPadding)
            let frame = CGRect.init(x: 0, y: self.yOffset[0], width: contentWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            contentHeight = insetFrame.maxY

            let attributes = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
            attributes.frame = insetFrame
            self.cache.append(attributes)

            self.yOffset[0] += height
            self.yOffset[1] += height
        }
    }

    private func addHeader() {
        let attribute = layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: IndexPath.init(row: 0, section: 1))

        guard let attr = attribute else { return }

        self.cache.append(attr)
        self.yOffset[0] += attr.frame.maxY
        self.yOffset[1] += attr.frame.maxY
    }

    private func setupThirdSection() {
        var bigEventWasPut = false
        for item in 0 ..< collectionView!.numberOfItems(inSection: 2) {
            let indexPath = IndexPath.init(item: item, section: 2)

            let columnWidth = (contentWidth / CGFloat(self.numberOfColumns))
            let width = columnWidth - cellPadding * 2
            var height: CGFloat = 0.0
            if self.currentColumn == 1 && !bigEventWasPut {
                height = self.bigEventRowHeight
                bigEventWasPut = true
            } else {
                height = width
            }

            let frame = CGRect(x: xOffset[self.currentColumn], y: self.yOffset[self.currentColumn], width: columnWidth, height: height)

            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            contentHeight = insetFrame.maxY

            let attributes = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)

            self.yOffset[self.currentColumn] = yOffset[self.currentColumn] + height
            if self.yOffset[0] < self.yOffset[1] {
                self.currentColumn = 0
            } else {
                self.currentColumn = 1
            }
        }

    }

}
