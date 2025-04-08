//
//  KalmanFilterManager.swift
//  Stepic
//
//  Created by 강민수 on 4/7/25.
//

import Foundation

final class KalmanFilterManager {
    // 프로세스 노이즈 (시스템의 불확실성, 작을수록 추정값에 더 의존)
    var Q: Double
    // 측정 노이즈 (센서의 노이즈 수준, 작을수록 센서 값을 신뢰)
    var R: Double
    // 현재 추정값
    var x: Double
    // 오차 공분산
    var p: Double
    // 칼만 게인 (업데이트 단계에서 사용)
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
}
