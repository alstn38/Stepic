//
//  WalkViewController.swift
//  Stepic
//
//  Created by 강민수 on 3/29/25.
//

import UIKit

import Lottie
import SnapKit

final class WalkViewController: UIViewController {
    
    private let weatherView = WeatherView()
    private let countDownView = CountDownView()
    private let durationStackView = UIStackView()
    private let durationTimeLabel = UILabel()
    private let timeTitleLabel = UILabel()
    private let durationDistanceLabel = UILabel()
    private let distanceTitleLabel = UILabel()
    private lazy var pictureCollectionView = UICollectionView(frame: .zero, collectionViewLayout: configureFlowLayout())
    private let walkAnimationView = LottieAnimationView(name: "walkLight")
    private let albumButtonView = WalkButtonView(buttonImage: .photo)
    private let pauseButtonView = WalkButtonView(buttonImage: .squareFill)
    private let cameraButtonView = WalkButtonView(buttonImage: .camera)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureHierarchy()
        configureLayout()
        
        // TODO: 이후 위치 변경
        countDownView.startAnimation {
            print("애니메이션 끝남")
        }
    }
    
    private func configureView() {
        view.backgroundColor = .backgroundRunning
        
        durationStackView.axis = .horizontal
        durationStackView.distribution = .equalCentering
        
        durationTimeLabel.text = "16:23" // TODO: 이후 삭제
        durationTimeLabel.textColor = .textPrimary
        durationTimeLabel.font = .titleExtraLarge
        
        timeTitleLabel.text = .StringLiterals.Walk.timeTitle
        timeTitleLabel.textColor = .textPrimary
        timeTitleLabel.font = .bodyRegular
        
        durationDistanceLabel.text = "8.23km" // TODO: 이후 삭제
        durationDistanceLabel.textColor = .textPrimary
        durationDistanceLabel.font = .titleExtraLarge
        
        distanceTitleLabel.text = .StringLiterals.Walk.distanceTitle
        distanceTitleLabel.textColor = .textPrimary
        distanceTitleLabel.font = .bodyRegular
        
        pictureCollectionView.showsHorizontalScrollIndicator = false
        pictureCollectionView.backgroundColor = .clear
        pictureCollectionView.register(
            WalkPictureCollectionViewCell.self,
            forCellWithReuseIdentifier: WalkPictureCollectionViewCell.identifier
        )
        pictureCollectionView.delegate = self // TODO: 이후 삭제
        pictureCollectionView.dataSource = self // TODO: 이후 삭제
        
        walkAnimationView.loopMode = .loop
        walkAnimationView.play()
    }
    
    private func configureHierarchy() {
        view.addSubviews(
            weatherView,
            durationStackView,
            timeTitleLabel,
            distanceTitleLabel,
            pictureCollectionView,
            walkAnimationView,
            albumButtonView,
            pauseButtonView,
            cameraButtonView
        )
        
        durationStackView.addArrangedSubviews(
            durationTimeLabel,
            durationDistanceLabel
        )
        
        view.addSubview(countDownView)
    }
    
    private func configureLayout() {
        let screenWidth: CGFloat = view.window?.windowScene?.screen.bounds.width ?? UIScreen.main.bounds.width
        
        countDownView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        weatherView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(44)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        durationStackView.snp.makeConstraints {
            $0.top.equalTo(weatherView.snp.bottom).offset(44)
            $0.horizontalEdges.equalToSuperview().inset(50)
        }
        
        timeTitleLabel.snp.makeConstraints {
            $0.top.equalTo(durationTimeLabel.snp.bottom).offset(5)
            $0.centerX.equalTo(durationTimeLabel)
        }
        
        distanceTitleLabel.snp.makeConstraints {
            $0.top.equalTo(durationDistanceLabel.snp.bottom).offset(5)
            $0.centerX.equalTo(durationDistanceLabel)
        }
        
        pictureCollectionView.snp.makeConstraints {
            $0.top.equalTo(distanceTitleLabel.snp.bottom).offset(86.adjustedHeight)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(screenWidth - 120)
        }
        
        walkAnimationView.snp.makeConstraints {
            $0.centerY.equalTo(pauseButtonView.snp.top).offset(-80.adjustedHeight)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(150)
            $0.width.equalTo(200)
        }
        
        albumButtonView.snp.makeConstraints {
            $0.size.equalTo(52)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60.adjustedHeight)
            $0.leading.equalToSuperview().offset((screenWidth - 156) / 4)
        }
        
        pauseButtonView.snp.makeConstraints {
            $0.size.equalTo(52)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
        
        cameraButtonView.snp.makeConstraints {
            $0.size.equalTo(52)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60.adjustedHeight)
            $0.trailing.equalToSuperview().inset((screenWidth - 156) / 4)
        }
    }
    
    private func configureFlowLayout() -> UICollectionViewFlowLayout {
        let screenWidth: CGFloat = view.window?.windowScene?.screen.bounds.width ?? UIScreen.main.bounds.width
        let spacing: CGFloat = 65
        let cellLength: CGFloat = screenWidth - (spacing * 2)
        
        let layout = CarouselLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: cellLength, height: cellLength)
        layout.sectionInset = UIEdgeInsets(top: .zero, left: spacing, bottom: .zero, right: spacing)
        
        return layout
    }
}

// MARK: - UIScrollViewDelegate
extension WalkViewController: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let layout = pictureCollectionView.collectionViewLayout as? CarouselLayout else { return }
        
        let pageWidth = layout.itemSize.width + layout.minimumLineSpacing
        let currentPage = round(scrollView.contentOffset.x / pageWidth)
        let nextPage: CGFloat
        
        if velocity.x > 0 {
            nextPage = ceil(scrollView.contentOffset.x / pageWidth)
        } else if velocity.x < 0 {
            nextPage = floor(scrollView.contentOffset.x / pageWidth)
        } else {
            nextPage = round(scrollView.contentOffset.x / pageWidth)
        }
        
        let targetX = nextPage * pageWidth
        targetContentOffset.pointee = CGPoint(x: targetX, y: targetContentOffset.pointee.y)
    }
}

// TODO: 이후 삭제
extension WalkViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: WalkPictureCollectionViewCell.identifier,
            for: indexPath
        ) as? WalkPictureCollectionViewCell else { return UICollectionViewCell() }
        
        return cell
    }
}
