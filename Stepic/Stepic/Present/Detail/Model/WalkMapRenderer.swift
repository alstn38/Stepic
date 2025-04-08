//
//  WalkMapRenderer.swift
//  Stepic
//
//  Created by 강민수 on 4/3/25.
//

import MapKit

final class WalkMapRenderer {
    
    private var cachedRegion: MKCoordinateRegion?
    
    /// 경로를 MapView에 추가 및 확대 비율 조절 메서드
    func renderPath(on mapView: MKMapView, pathCoordinates: [CLLocationCoordinate2D]) {
        let existingPolyLines = mapView.overlays.filter { $0 is MKPolyline }
        mapView.removeOverlays(existingPolyLines)
        
        guard !pathCoordinates.isEmpty else { return }

        let polyLine = MKPolyline(coordinates: pathCoordinates, count: pathCoordinates.count)
        mapView.addOverlay(polyLine)

        let region = regionForCoordinates(pathCoordinates)
        mapView.setRegion(region, animated: false)
    }
    
    /// 사진 애노테이션을 MapView에 추가하는 메서드
    func renderPhotos(on mapView: MKMapView, photos: [WalkPhotoEntity]) {
        /// 기존 PhotoAnnotation 제거
        let existingPhotoAnnotations = mapView.annotations.filter { $0 is PhotoAnnotation }
        mapView.removeAnnotations(existingPhotoAnnotations)
        
        /// 위치 정보가 있는 사진에 대해 애노테이션 추가
        for photo in photos {
            if let _ = photo.location {
                let annotation = PhotoAnnotation(photo: photo)
                mapView.addAnnotation(annotation)
            }
        }
        
        guard let cachedRegion else { return }
        mapView.setRegion(cachedRegion, animated: false)
    }
    
    /// 좌표를 기반으로 1.5배 기준 확대/중심 설정하는 메서드
    func regionForCoordinates(_ coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        var minLat = coordinates.first?.latitude ?? 0
        var maxLat = coordinates.first?.latitude ?? 0
        var minLng = coordinates.first?.longitude ?? 0
        var maxLng = coordinates.first?.longitude ?? 0

        for coord in coordinates {
            minLat = min(minLat, coord.latitude)
            maxLat = max(maxLat, coord.latitude)
            minLng = min(minLng, coord.longitude)
            maxLng = max(maxLng, coord.longitude)
        }

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLng + maxLng) / 2
        )

        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5,
            longitudeDelta: (maxLng - minLng) * 1.5
        )
        
        cachedRegion = MKCoordinateRegion(center: center, span: span)

        return MKCoordinateRegion(center: center, span: span)
    }
}
