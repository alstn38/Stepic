//
//  SettingViewController.swift
//  Stepic
//
//  Created by 강민수 on 4/6/25.
//

import UIKit

import SnapKit

final class SettingsViewController: UIViewController {
    
    private let tableView = UITableView()
    private let cellIdentifier: String = "SettingCell"
    
    /// 이용약관, 개인정보 처리 방침, 문의하기
    private let settingItems: [(title: String, url: String)] = [
        (.StringLiterals.Setting.termsOfServiceTitle,
         "https://fish-crowley-c97.notion.site/1cd557e5f30f805c87aaf95e79bc04ca"),
        (.StringLiterals.Setting.privacyPolicyTitle,
         "https://fish-crowley-c97.notion.site/1c7557e5f30f8062aeccd5140e473d95?pvs=4"),
        (.StringLiterals.Setting.contactUsTitle,
         "https://docs.google.com/forms/d/e/1FAIpQLSeD5wFyZFBjnw5w_S2x0e7Zna6OtBBCi4KNsUHUrr5FchlItg/viewform?usp=dialog")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureHierarchy()
        configureLayout()
    }
    
    private func configureView() {
        navigationItem.title = .StringLiterals.Setting.settingsTitle
        view.backgroundColor = .backgroundPrimary
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: cellIdentifier
        )
    }
    
    private func configureHierarchy() {
        view.addSubview(tableView)
    }
    
    private func configureLayout() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return settingItems.count
        case 1: return 1
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return .StringLiterals.Setting.termsAndContactSectionTitle
        case 1: return .StringLiterals.Setting.appInfoSectionTitle
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        if indexPath.section == 0 {
            let item = settingItems[indexPath.row]
            cell.textLabel?.text = item.title
            cell.accessoryType = .disclosureIndicator
        } else {
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"

            cell.textLabel?.text = .StringLiterals.Setting.versionLabel
            cell.selectionStyle = .none
            cell.accessoryType = .none

            let versionLabel = UILabel()
            versionLabel.text = version
            versionLabel.font = UIFont.systemFont(ofSize: 14)
            versionLabel.textColor = .secondaryLabel
            versionLabel.sizeToFit()

            cell.accessoryView = versionLabel
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        let urlString = settingItems[indexPath.row].url
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
