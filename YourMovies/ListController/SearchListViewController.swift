//
//  SearchListViewController.swift
//  YourMovies
//
//  Created by Francisco José Gonzlález Egea on 04/10/2019.
//  Copyright © 2019 Francisco José Gonzlález Egea. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class SearchListViewController: UITableViewController {

    // MARK: - Variables
    @IBOutlet weak var m_searchBar: UISearchBar!
    private let m_searchController = UISearchController(searchResultsController: nil)
    private var m_searchResults = [JSON]() {
        didSet {
            tableView.reloadData()
        }
    }

    private let m_apiFetcher = APIRoute()
    private var m_previousRun = Date()
    private let m_minInterval = 0.05
    private let m_identifierCell = "cell"
    private let m_identifierSegue = "showDetail"

    // MARK: - Inits
    override func viewDidLoad() {
        super.viewDidLoad()
        m_searchBar.delegate = self
        tableView.tableHeaderView = m_searchBar
        setupTableViewBackgroundView(text: "No results to show")
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if (m_searchResults.count > 0) {
            setupTableViewBackgroundView(text: "")
        } else {
            setupTableViewBackgroundView(text: "No results to show")
        }

        return m_searchResults.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: m_identifierCell, for: indexPath) as! CellTableViewCell

        cell.IdMovie = m_searchResults[indexPath.row]["imdbID"].stringValue
        cell.m_titleLabel.text = m_searchResults[indexPath.row]["Title"].stringValue
        cell.m_year.text = m_searchResults[indexPath.row]["Year"].stringValue
        cell.m_imageView.image = UIImage(named: "imagePlaceholer")

        if let url = m_searchResults[indexPath.row]["Poster"].string {
            m_apiFetcher.fetchImage(url: url, completionHandler: { image, error in

                if (error == .success) {
                    cell.m_imageView.image = image
                } else {
                    cell.m_imageView.image = UIImage(named: "imagePlaceholer")
                }
            })
        }

        return cell
    }

    // MARK: - Private Methods
    private func setupTableViewBackgroundView(text: String) {
        let backgroundViewLabel = UILabel(frame: .zero)
        backgroundViewLabel.textColor = .darkGray
        backgroundViewLabel.numberOfLines = 0
        backgroundViewLabel.text = text
        backgroundViewLabel.textAlignment = NSTextAlignment.center
        backgroundViewLabel.font.withSize(20)
        tableView.backgroundView = backgroundViewLabel
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        super.prepare(for: segue, sender: sender)
        switch segue.identifier ?? "" {
        case m_identifierSegue:
            guard let detailView = segue.destination as? DetailViewController else {
                fatalError("Unexpected segue: \(segue.destination)")
            }
            guard let selectedMealCell = sender as? CellTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            detailView.m_idMovie = selectedMealCell.IdMovie!
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
}

// MARK: - Extensions
extension SearchListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        m_searchResults.removeAll()
        m_searchBar.endEditing(true)


        guard let textToSearch = searchBar.text, !textToSearch.isEmpty else {
            return
        }

        if Date().timeIntervalSince(m_previousRun) > m_minInterval {
            m_previousRun = Date()
            fetchResults(for: textToSearch)
        }
    }

    func fetchResults(for text: String) {
        m_apiFetcher.search(searchText: text, completionHandler: {
            [weak self] results, error in
            if case .failure = error {
                return
            }

            guard let results = results, !results.isEmpty else {
                return
            }

            self?.m_searchResults = results
        })
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        m_searchResults.removeAll()
    }
}
