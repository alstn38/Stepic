//
//  KalmanFilterManager.swift
//  Stepic
//
//  Created by 강민수 on 4/7/25.
//

import Foundation
import CoreLocation

final class KalmanFilterManager {
    /// 프로세스 노이즈 (시스템의 불확실성, 작을수록 추정값에 더 의존)
    var Q: Double
    /// 측정 노이즈 (센서의 노이즈 수준, 작을수록 센서 값을 신뢰)
    var R: Double
    /// 현재 추정값
    var x: Double
    /// 오차 공분산
    var p: Double
    /// 칼만 게인 (업데이트 단계에서 사용)
    var K: Double = 0.0

    /// 초기값, 초기 오차, 프로세스 노이즈, 측정 노이즈를 설정하여 칼만 필터를 초기화합니다.
    init(
        initialValue: Double,
        initialError: Double,
        processNoise: Double,
        measurementNoise: Double
    ) {
        self.x = initialValue
        self.p = initialError
        self.Q = processNoise
        self.R = measurementNoise
    }

    /// 새로운 측정값을 입력받아 필터를 업데이트하고 보정된 값을 반환합니다.
    func update(measurement: Double) -> Double {
        /// 예측 단계: 오차 공분산 업데이트
        p = p + Q
        
        /// 업데이트 단계: 칼만 게인 계산
        K = p / (p + R)
        /// 측정값과 예측값의 차이를 보정하여 추정값 업데이트
        x = x + K * (measurement - x)
        /// 업데이트된 오차 공분산
        p = (1 - K) * p
        
        return x
    }
    
    /// GPS 정확도와 속도 정보를 기반으로 R, Q를 동적으로 조정한 후 필터를 업데이트합니다.
    func update(measurement: Double, accuracy: CLLocationAccuracy, speed: CLLocationSpeed) -> Double {
        updateR(basedOn: accuracy)
        updateQ(basedOn: speed)
        
        /// 예측 단계
        p = p + Q
        
        /// 업데이트 단계
        K = p / (p + R)
        x = x + K * (measurement - x)
        p = (1 - K) * p
        
        return x
    }
    
    /// GPS 수평 정확도를 기준으로 R(측정 노이즈) 조정
    private func updateR(basedOn accuracy: CLLocationAccuracy) {
        switch accuracy {
        case ..<5:
            R = 0.01  /// 매우 정확할 때는 센서 값을 강하게 반영
        case 5..<10:
            R = 0.05
        default:
            R = 0.1   /// 정확도가 낮을수록 센서 신뢰도 낮춤
        }
    }

    /// 사용자 속도를 기준으로 Q(프로세스 노이즈) 조정
    private func updateQ(basedOn speed: CLLocationSpeed) {
        switch speed {
        case ..<1.0:
            Q = 0.005  /// 정지 상태에 가까움
        case 1.0..<3.0:
            Q = 0.01   /// 일반적인 걷기
        case 3.0..<6.0:
            Q = 0.02   /// 빠르게 걷기 또는 조깅
        default:
            Q = 0.05   /// 달리기 이상
        }
    }
}
