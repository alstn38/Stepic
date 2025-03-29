//
//  CalendarCell.swift
//  Stepic
//
//  Created by 강민수 on 3/29/25.
//

import UIKit

import FSCalendar

final class CalendarCell: FSCalendarCell, ReusableViewProtocol {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let shapeLayer = self.shapeLayer {
            // 타이틀 라벨(날짜)의 위치와 크기에 맞추기
            
            let width: CGFloat = titleLabel.frame.width / 2 + 7
            let height: CGFloat = 20
            
            // 중요: 타이틀 라벨의 위치를 기준으로 하이라이트 위치 조정
            // 이미지는 아래쪽에 있으므로 타이틀 라벨 위치를 직접 사용
            let rect = CGRect(
                x: titleLabel.frame.minX + (width / 2) - 11,
                y: titleLabel.frame.minY + (titleLabel.frame.height / 2) - 16.5,
                width: width + 1,
                height: height
            )
            
            // 둥근 모서리 직사각형 패스 생성
            let path = UIBezierPath(roundedRect: rect, cornerRadius: 8.0)
            shapeLayer.path = path.cgPath
        }
    }
}
