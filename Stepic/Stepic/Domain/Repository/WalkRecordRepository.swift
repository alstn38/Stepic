//
//  WalkRecordRepository.swift
//  Stepic
//
//  Created by 강민수 on 4/4/25.
//

import UIKit

protocol WalkRecordRepository {
    func save(entity: WalkDiaryEntity) throws
    func fetchAll() -> [WalkDiaryEntity]
    func fetch(byYear year: Int, month: Int) -> [WalkDiaryEntity]
    func fetchBookmarked() -> [WalkDiaryEntity]
    func fetch(by id: String) throws -> WalkDiaryEntity
    func updateBookmark(entity: WalkDiaryEntity) throws
    func delete(entity: WalkDiaryEntity) throws
}
