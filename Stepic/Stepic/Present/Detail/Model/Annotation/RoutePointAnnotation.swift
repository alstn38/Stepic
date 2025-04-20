//
//  RoutePointAnnotation.swift
//  Stepic
//
//  Created by 강민수 on 4/20/25.
//

import MapKit

final class RoutePointAnnotation: NSObject, MKAnnotation {
    
    static let identifier: String = "RoutePointAnnotation"
    
    enum PointType {
        case start
        case end
    }
    
    let type: PointType
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D, type: PointType) {
        self.coordinate = coordinate
        self.type = type
        super.init()
    }
    
    var title: String? {
        switch type {
        case .start: return .StringLiterals.Detail.walkDepartureTitle
        case .end: return .StringLiterals.Detail.walkEndLocationTitle
        }
    }
    
    var markerColor: UIColor {
        switch type {
        case .start: return .systemGreen
        case .end: return .systemRed
        }
    }
    
    var glyphSystemImage: UIImage {
        switch type {
        case .start: return .figureWalk
        case .end: return .flagPatternCheckered
        }
    }
}
