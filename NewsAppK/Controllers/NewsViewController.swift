//
//  NewsViewController.swift
//  quowigeq
//
//  Created by студент on 09.10.2026.
//

import UIKit

class NewsViewController: UIViewController {
    private let tableView = UITableView()
    private let spinner = UIActivityIndicatorView(style: .large)
    private let refreshControl = UIRefreshControl()
    
    private var posts: [post] = []
    private let networkService = NetworkService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPosts()
    }
    
    private func setupUI() {
        title = "Новости"
        view.backgroundColor = .white
        
        // Таблица
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PostCell.self, forCellReuseIdentifier: PostCell.reuseID)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Спиннер
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        
        // Refresh Control
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        // Констрейнты
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func loadPosts() {
        spinner.startAnimating()
        
        networkService.fetchPosts { [weak self] result in
            DispatchQueue.main.async {
                self?.spinner.stopAnimating()
                self?.refreshControl.endRefreshing()
                
                switch result {
                case .success(let posts):
                    self?.posts = posts
                    self?.tableView.reloadData()
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }
    
    @objc private func handleRefresh() {
        loadPosts()
    }

    private func showError(_ error: NetworkError) {
        let message: String
        switch error {
        case .invalidURL: message = "Неверный URL"
        case .noData: message = "Нет данных"
        case .decodingError: message = "Ошибка парсинга данных"
        case .serverError(let code): message = "Ошибка сервера: \(code)"
        case .transportError(let err): message = "Ошибка сети: \(err.localizedDescription)"
        }
        
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadPosts()
        })
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
}

extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.reuseID, for: indexPath) as? PostCell else {
            return UITableViewCell()
        }
        cell.configure(with: posts[indexPath.row])
        return cell
    }
}


extension NewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Здесь позже добавим переход на DetailViewController
    }
}
