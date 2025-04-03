//
//  RouteView.swift
//  Stepic
//
//  Created by 강민수 on 3/31/25.
//

import UIKit

import MapKit
import SnapKit

final class RouteView: UIView {
    
    private let walkMapRenderer = WalkMapRenderer()
    private let title = UILabel()
    private let mapBackgroundView = UIView()
    private let mapView = MKMapView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureHierarchy()
        configureLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView(with pathCoordinates: [CLLocationCoordinate2D]) {
        walkMapRenderer.renderPath(on: mapView, pathCoordinates: pathCoordinates)
    }
    
    func configureView(with photos: [WalkPhotoEntity]) {
        walkMapRenderer.renderPhotos(on: mapView, photos: photos)
    }
    
    private func configureView() {
        title.text = .StringLiterals.Detail.routeTitle
        title.textColor = .textPrimary
        title.font = .titleLarge
        
        mapBackgroundView.backgroundColor = .backgroundSecondary
        mapBackgroundView.layer.cornerRadius = 10
        mapBackgroundView.clipsToBounds = true
        
        mapView.isUserInteractionEnabled = false
        mapView.layer.cornerRadius = 10
        mapView.clipsToBounds = true
        mapView.delegate = self
    }
    
    private func configureHierarchy() {
        self.addSubviews(
            title,
            mapBackgroundView,
            mapView
        )
    }
    
    private func configureLayout() {
        title.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(22)
        }
        
        mapBackgroundView.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(22)
            $0.height.equalTo(261.adjustedHeight)
            $0.bottom.equalToSuperview()
        }
        
        mapView.snp.makeConstraints {
            $0.edges.equalTo(mapBackgroundView).inset(4)
        }
    }
}

// MARK: - MKMapViewDelegate
extension RouteView: MKMapViewDelegate {
    
    /// 경로 polyLine의 색상, 두께 등을 설정
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyLine = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyLine)
            renderer.strokeColor = .accentPrimary
            renderer.lineWidth = 4
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    /// 커스텀 애노테이션 뷰 반환 메서드
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        if let photoAnnotation = annotation as? PhotoAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: PhotoAnnotationView.identifier)
            
            if annotationView == nil {
                annotationView = PhotoAnnotationView(
                    annotation: photoAnnotation,
                    reuseIdentifier: PhotoAnnotationView.identifier
                )
            } else {
                annotationView?.annotation = photoAnnotation
            }
            
            return annotationView
        }
        
        return nil
    }
}
