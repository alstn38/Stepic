//
//  PhotoAnnotationView.swift
//  Stepic
//
//  Created by 강민수 on 4/4/25.
//

import MapKit

final class PhotoAnnotationView: MKAnnotationView, ReusableViewProtocol {
    
    private let imageView = UIImageView()
    private let backgroundContainer = UIView()
    
    override var annotation: MKAnnotation? {
        didSet {
            configureUI()
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        configureView()
        configureHierarchy()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        backgroundContainer.backgroundColor = .white
        backgroundContainer.layer.cornerRadius = 8
        backgroundContainer.layer.shadowColor = UIColor.black.cgColor
        backgroundContainer.layer.shadowOpacity = 0.2
        backgroundContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        backgroundContainer.layer.shadowRadius = 4
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
    }
    
    private func configureHierarchy() {
        addSubview(backgroundContainer)
        backgroundContainer.addSubview(imageView)
    }
    
    private func setupSubviews() {
        backgroundContainer.backgroundColor = .white
        backgroundContainer.layer.cornerRadius = 8
        backgroundContainer.layer.shadowColor = UIColor.black.cgColor
        backgroundContainer.layer.shadowOpacity = 0.2
        backgroundContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        backgroundContainer.layer.shadowRadius = 4
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        
        addSubview(backgroundContainer)
        backgroundContainer.addSubview(imageView)
    }
    
    private func configureUI() {
        guard let photoAnnotation = annotation as? PhotoAnnotation else { return }
        imageView.image = photoAnnotation.photo.image
        
        frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        backgroundContainer.frame = bounds
        imageView.frame = backgroundContainer.bounds.insetBy(dx: 2, dy: 2)
        
        canShowCallout = false
    }
}
