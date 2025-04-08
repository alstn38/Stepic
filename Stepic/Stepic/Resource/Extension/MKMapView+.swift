//
//  MKMapView+.swift
//  Stepic
//
//  Created by 강민수 on 4/4/25.
//

import MapKit

extension MKMapView {
    
    func captureSnapshot() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
        return renderer.image { _ in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
    }
}
