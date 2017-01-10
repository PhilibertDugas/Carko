import Foundation
import UIKit
import QuartzCore
extension CALayer{
    var size:CGSize{
        get{ return self.bounds.size.checked }
        set{ return self.bounds.size = newValue }
    }

    var occupation:(CGSize, CGPoint) {
        get{ return (size, self.center.checked) }
        set{ size = newValue.0; position = newValue.1 }
    }

    var center:CGPoint{
        get{ return self.bounds.center.checked }
    }
}
