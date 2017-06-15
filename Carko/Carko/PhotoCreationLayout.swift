//
//  PhotoCreationLayout.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-11.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit

class PhotoCreationLayout: UICollectionViewLayout {
    private var cache: [UICollectionViewLayoutAttributes] = []

    private var numberOfColumns = 0
    private var numberOfRow = 0
    private var currentColumn = 0
    private var currentRow = 0

    private var yOffset: [(CGFloat)] = []
    private var xOffset: [(CGFloat)] = []

    private var contentHeight: CGFloat {
        return collectionView!.bounds.height
    }

    private var contentWidth: CGFloat {
        return collectionView!.bounds.width
    }

    private var firstSectionPadding: CGFloat = 0.0
    private var secondSectionPadding: CGFloat = 0.0
    private var thirdSectionPadding: CGFloat = 0.0


    override func prepare() {
        self.cache.removeAll()
        self.currentColumn = 0
        self.currentRow = 0
        self.firstSectionPadding = 0.02 * self.contentWidth
        self.secondSectionPadding = 0.55 * self.firstSectionPadding
        self.thirdSectionPadding = 0.4 * self.firstSectionPadding

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
        return self.cache
    }

    private func setupOneSectionLayout() {
        // 1 section means only 1 item that takes the full collection view
        let indexPath = IndexPath.init(item: 0, section: 0)
        let frame = CGRect.init(x: 0, y: 0, width: contentWidth, height: contentHeight)
        let insetFrame = frame.insetBy(dx: firstSectionPadding, dy: firstSectionPadding)
        let attributes = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
        attributes.frame = insetFrame
        self.cache.append(attributes)
    }

    private func setupTwoSectionLayout() {
        let firstSectionColumnWidth = 0.65 * contentWidth
        let firstSectionColumnHeight = contentHeight

        // Images in the second column are square dimensions
        let secondSectionColumnWidth = 0.35 * contentWidth
        let secondSectionRowHeight = secondSectionColumnWidth

        self.xOffset[0] = 0
        self.xOffset[1] = firstSectionColumnWidth
        self.yOffset[0] = 0
        self.yOffset[1] = secondSectionRowHeight

        let firstSectionIndexPath = IndexPath.init(row: 0, section: 0)
        let firstSectionFrame = CGRect.init(x: 0, y: 0, width: firstSectionColumnWidth, height: firstSectionColumnHeight)
        let firstInsetFrame = firstSectionFrame.insetBy(dx: firstSectionPadding, dy: firstSectionPadding)
        let firstAttribute = UICollectionViewLayoutAttributes.init(forCellWith: firstSectionIndexPath)
        firstAttribute.frame = firstInsetFrame
        self.cache.append(firstAttribute)
        self.currentColumn += 1

        for item in 0 ..< collectionView!.numberOfItems(inSection: 1) {
            let indexPath = IndexPath.init(row: item, section: 1)
            let width = secondSectionColumnWidth - secondSectionPadding * 2
            let height = secondSectionRowHeight - secondSectionPadding * 2
            let frame = CGRect.init(x: self.xOffset[self.currentColumn], y: self.yOffset[self.currentRow], width: width, height: height)
            let insetFrame = frame.insetBy(dx: secondSectionPadding, dy: secondSectionPadding)
            let attributes = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
            attributes.frame = insetFrame
            self.cache.append(attributes)

            self.currentRow = self.currentRow == 0 ? 1 : 0
        }
    }

    private func setupThreeSectionLayout() {
        let firstSectionColumnWidth = 0.65 * contentWidth
        let firstSectionColumnHeight = contentHeight

        // Images in the second column are square dimensions
        let secondSectionColumnWidth = 0.35 * contentWidth
        let secondSectionRowHeight = secondSectionColumnWidth

        let thirdSectionColumnWidth = 0.16 * contentWidth
        let thirdSectionRowHeight = thirdSectionColumnWidth

        self.xOffset[0] = 0
        self.xOffset[1] = firstSectionColumnWidth
        self.xOffset[2] = firstSectionColumnHeight + thirdSectionColumnWidth
        self.yOffset[0] = 0
        self.yOffset[1] = secondSectionRowHeight
        self.yOffset[2] = secondSectionRowHeight + thirdSectionRowHeight

        let firstSectionIndexPath = IndexPath.init(row: 0, section: 0)
        let firstSectionFrame = CGRect.init(x: 0, y: 0, width: firstSectionColumnWidth, height: firstSectionColumnHeight)
        let firstInsetFrame = firstSectionFrame.insetBy(dx: firstSectionPadding, dy: firstSectionPadding)
        let firstAttribute = UICollectionViewLayoutAttributes.init(forCellWith: firstSectionIndexPath)
        firstAttribute.frame = firstInsetFrame
        self.cache.append(firstAttribute)
        self.currentColumn += 1

        for item in 0 ..< collectionView!.numberOfItems(inSection: 1) {
            let indexPath = IndexPath.init(row: item, section: 1)
            let width = secondSectionColumnWidth - secondSectionPadding * 2
            let height = secondSectionRowHeight - secondSectionPadding * 2
            let frame = CGRect.init(x: self.xOffset[self.currentColumn], y: self.yOffset[self.currentRow], width: width, height: height)
            let insetFrame = frame.insetBy(dx: secondSectionPadding, dy: secondSectionPadding)
            let attributes = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
            attributes.frame = insetFrame
            self.cache.append(attributes)
            self.currentRow += 1
        }

        for item in 0 ..< collectionView!.numberOfItems(inSection: 2) {
            let indexPath = IndexPath.init(row: item, section: 2)
            let width = thirdSectionColumnWidth - thirdSectionPadding * 2
            let height = thirdSectionRowHeight - thirdSectionPadding * 2
            let frame = CGRect.init(x: self.xOffset[self.currentColumn], y: self.yOffset[self.currentRow], width: width, height: height)
            let insetFrame = frame.insetBy(dx: thirdSectionPadding, dy: thirdSectionPadding)
            let attributes = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
            attributes.frame = insetFrame
            self.cache.append(attributes)
            let photoRowColumn = (self.currentRow, self.currentColumn)
            switch photoRowColumn {
            case (1, 1):
                self.currentColumn = 2
                break
            case (1, 2):
                self.currentColumn = 1
                self.currentRow = 2
                break
            case (2, 1):
                self.currentColumn = 2
                break
            case (2, 2):
                break
            default:
                print("Impossible")
            }
        }
    }
}
