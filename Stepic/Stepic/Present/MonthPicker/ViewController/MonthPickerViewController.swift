//
//  MonthPickerViewController.swift
//  Stepic
//
//  Created by 강민수 on 4/4/25.
//

import UIKit

import SnapKit

final class MonthPickerViewController: UIViewController {
    
    private var onSelect: ((YearMonth) -> Void)
    private var items: [YearMonth] = []
    private let titleLabel = UILabel()
    private let tableView = UITableView()
    private let cellIdentifier: String = "MonthCell"
    
    init(onSelect: @escaping (YearMonth) -> Void) {
        self.onSelect = onSelect
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureHierarchy()
        configureLayout()
    }
    
    private func configureView() {
        items = generateYearMonthList()
        view.backgroundColor = .backgroundSecondary
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        
        titleLabel.text = .StringLiterals.Alert.selectDateTitle
        titleLabel.font = .titleSmall
        titleLabel.textAlignment = .center
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func configureHierarchy() {
        view.addSubviews(
            titleLabel,
            tableView
        )
    }

    private func configureLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.centerX.equalToSuperview()
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    private func generateYearMonthList() -> [YearMonth] {
        let calendar = Calendar.current
        var startDate = calendar.date(from: DateComponents(year: 2025, month: 1)) ?? Date()
        let endDate = Date()
        var result: [YearMonth] = []

        while startDate <= endDate {
            let year = calendar.component(.year, from: startDate)
            let month = calendar.component(.month, from: startDate)
            result.append(YearMonth(year: year, month: month))
            startDate = calendar.date(byAdding: .month, value: 1, to: startDate) ?? Date()
        }

        return result.reversed()
    }
}

extension MonthPickerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = DateFormatManager.shared.selectMonthTitle(year: item.year, month: item.month)
        cell.textLabel?.textAlignment = .center
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = items[indexPath.row]
        onSelect(selected)
        dismiss(animated: true)
    }
}
