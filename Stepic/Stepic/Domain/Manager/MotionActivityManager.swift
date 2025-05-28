//
//  MotionActivityManager.swift
//  Stepic
//
//  Created by 강민수 on 5/28/25.
//

import CoreMotion

import RxSwift
import RxCocoa

protocol MotionActivityManager {
    var isUserMoving: Observable<Bool> { get }
    func startMonitoring()
    func stopMonitoring()
}

final class DefaultMotionActivityManager: MotionActivityManager {
    
    private let activityManager = CMMotionActivityManager()
    private let activityQueue = OperationQueue()
    private let isMovingSubject = BehaviorSubject<Bool>(value: false)
    
    var isUserMoving: Observable<Bool> {
        return isMovingSubject.asObservable()
    }
    
    init() {
        self.activityQueue.maxConcurrentOperationCount = 1
    }
    
    func startMonitoring() {
        guard CMMotionActivityManager.isActivityAvailable() else { return }
        
        activityManager.startActivityUpdates(to: activityQueue) { [weak self] activity in
            guard let self, let activity else { return }

            let isMoving = activity.walking || activity.running || activity.cycling || activity.automotive
            self.isMovingSubject.onNext(isMoving)
        }
    }
    
    func stopMonitoring() {
        activityManager.stopActivityUpdates()
    }
}
