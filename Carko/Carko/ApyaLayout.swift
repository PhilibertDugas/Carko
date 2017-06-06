//
//  ApyaLayout.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-04-22.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit

protocol ApyaLayoutDelegate {
    func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath,
                        withWidth:CGFloat) -> CGFloat

    func collectionView(collectionView: UICollectionView,
                        heightForAnnotationAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat
}

class ApyaLayout: UICollectionViewLayout {
    var delegate: ApyaLayoutDelegate!

    let reservationCellHeight: CGFloat = 345
    let reservationNumberOfColumns = 1
    let firstEventNumberOfColumns = 1
    let eventNumberOfColumns = 2

    var currentColumn = 0
    var yOffset = [CGFloat]()
    var cellPadding: CGFloat = 6.0

    private var cache = [ApyaLayoutAttributes]()

    private var contentHeight: CGFloat  = 0.0
    private var contentWidth: CGFloat {
        let insets = collectionView!.contentInset
        return collectionView!.bounds.width - (insets.left + insets.right)
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override class var layoutAttributesClass: AnyClass {
        return ApyaLayoutAttributes.self
    }

    override func prepare() {
        cache.removeAll()

        self.yOffset = [CGFloat](repeating: 0, count: eventNumberOfColumns)

        self.currentColumn = 0
        setupReservationCells()
        setupEventCells()
    }

    fileprivate func setupReservationCells() {
        let columnWidth = contentWidth / CGFloat(reservationNumberOfColumns)
        var xOffset = [CGFloat]()
        for column in 0 ..< reservationNumberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth )
        }

        for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
            let indexPath = IndexPath.init(item: item, section: 0)

            let height = cellPadding + reservationCellHeight + cellPadding

            let frame = CGRect(x: xOffset[self.currentColumn], y: yOffset[self.currentColumn], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)

            let attributes = ApyaLayoutAttributes.init(forCellWith: indexPath)
            attributes.photoHeight = reservationCellHeight
            attributes.frame = insetFrame
            cache.append(attributes)

            contentHeight = max(contentHeight, frame.maxY)
            self.yOffset[0] = height
            self.yOffset[1] = height

            if self.currentColumn >= (reservationNumberOfColumns - 1) {
                self.currentColumn = 0
            } else {
                self.currentColumn = self.currentColumn + 1
            }
        }

    }

    fileprivate func setupEventCells() {
        var firstEvent = true

        let columnWidth = contentWidth / CGFloat(eventNumberOfColumns)
        let firstColumnWidth = contentWidth / CGFloat(firstEventNumberOfColumns)
        var xOffset = [CGFloat]()
        for column in 0 ..< eventNumberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth )
        }

        for item in 0 ..< collectionView!.numberOfItems(inSection: 1) {
            let indexPath = IndexPath.init(item: item, section: 1)

            let width = firstEvent ? firstColumnWidth - cellPadding * 2 : columnWidth - cellPadding * 2
            let photoHeight = delegate.collectionView(collectionView: collectionView!, heightForPhotoAtIndexPath: indexPath, withWidth: width)
            let height = cellPadding + photoHeight + cellPadding

            var frame: CGRect!
            if firstEvent {
                frame = CGRect(x: 0, y: self.yOffset[self.currentColumn], width: firstColumnWidth, height: height)
            } else {
                frame = CGRect(x: xOffset[self.currentColumn], y: self.yOffset[self.currentColumn], width: columnWidth, height: height)
            }

            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            let attributes = ApyaLayoutAttributes.init(forCellWith: indexPath)
            attributes.photoHeight = photoHeight
            attributes.frame = insetFrame
            cache.append(attributes)

            contentHeight = max(contentHeight, frame.maxY)

            if firstEvent {
                self.yOffset[0] = yOffset[0] + height
                self.yOffset[1] = yOffset[1] + height
            } else {
                self.yOffset[self.currentColumn] = yOffset[self.currentColumn] + height
                if self.currentColumn >= (eventNumberOfColumns - 1) {
                    self.currentColumn = 0
                } else {
                    self.currentColumn = self.currentColumn + 1
                }
            }
            firstEvent = firstEvent ? !firstEvent : firstEvent
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [ApyaLayoutAttributes]()

        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
}

class ApyaLayoutAttributes: UICollectionViewLayoutAttributes {
    var photoHeight: CGFloat = 0.0

    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! ApyaLayoutAttributes
        copy.photoHeight = photoHeight
        return copy
    }

    override func isEqual(_ object: Any?) -> Bool {
        if let attributes = object as? ApyaLayoutAttributes {
            if( attributes.photoHeight == photoHeight  ) {
                return super.isEqual(object)
            }
        }
        return false
    }
}
