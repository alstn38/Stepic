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
    
    private func configureView() {
        title.text = .StringLiterals.Detail.routeTitle
        title.textColor = .textPrimary
        title.font = .titleLarge
        
        mapBackgroundView.backgroundColor = .backgroundSecondary
        mapBackgroundView.layer.cornerRadius = 10
        mapBackgroundView.clipsToBounds = true
        
        mapView.layer.cornerRadius = 10
        mapView.clipsToBounds = true
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
