import Foundation
import UIKit

class NewsViewController: UIViewController {

    // MARK: - UI
    private let tableView = UITableView()
    private let spinner = UIActivityIndicatorView(style: .large)
    private let refreshControl = UIRefreshControl()

    // MARK: - Data
    private var posts: [Post] = [] // Предполагается, что у вас есть модель Post
    private let networkService = NetworkService() // Предполагается, что есть сервис сети

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPosts()
    }

    // MARK: - Setup
    private func setupUI() {
        // 1. title, backgroundColor
        title = "Новости"
        view.backgroundColor = .systemBackground

        // 2. Делегаты таблицы (о них ниже)
        tableView.dataSource = self
        tableView.delegate = self

        // 3. Регистрация PostCell (предполагается, что ячейка называется PostCell)
        tableView.register(PostCell.self, forCellReuseIdentifier: "PostCell")

        // 4. refreshControl.addTarget
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl

        // 5. addSubview (tableView, spinner)
        view.addSubview(tableView)
        view.addSubview(spinner)

        // 6. Активация констрейнтов (обязательно translatesAutoresizingMaskIntoConstraints = false)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        spinner.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Констрейнты для таблицы (на весь экран)
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Констрейнты для спиннера (по центру)
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Loading
    private func loadPosts() {
        spinner.startAnimating()
        
        networkService.fetchPosts { [weak self] result in
            // Возвращаемся в главный поток для обновления UI
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

    // MARK: - Actions
    @objc private func handleRefresh() {
        loadPosts()
    }

    // MARK: - Errors
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
        
        // Кнопка "Повторить"
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadPosts()
        }
        // Кнопка "Отмена"
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        alert.addAction(retryAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        let post = posts[indexPath.row]
        cell.configure(with: post)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Здесь можно добавить логику перехода на детальный экран
    }
}
