//
//  ViewController.swift
//  PexelsApp
//
//  Created by Daniel Bell on 4/25/22.
//

import UIKit

class ViewController: UIViewController {

    enum Section {
        case main
    }

    var dataSource: UICollectionViewDiffableDataSource<Section, PexelsPhoto>? = nil
    var collectionView: UICollectionView? = nil

    var retrievedPhotos: [PexelsPhoto] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Nested Groups"
        configureHierarchy()
        configureDataSource()

        navigationItem.title = "Pexels App"
        navigationController?.navigationBar.prefersLargeTitles = true

        let layout = UICollectionViewFlowLayout()
        let restultsController = ResultsViewController(collectionViewLayout: layout)
        searchController = UISearchController(searchResultsController: UINavigationController(rootViewController: restultsController))
        searchController.searchResultsUpdater = self    //set to the delegate
        searchController.obscuresBackgroundDuringPresentation = false //true if not using self to obscure self
        searchController.searchBar.placeholder = "Search Pictures"
        navigationItem.searchController = searchController
        searchController.delegate = self
        definesPresentationContext = true
        Task {
            let networkConnector = try? await PexelsCuratedImages().nextResults()
            guard let photos = networkConnector?.photos else {
                return
            }
            retrievedPhotos.append(contentsOf: photos)
            var snapshot = NSDiffableDataSourceSnapshot<Section, PexelsPhoto>()
            snapshot.appendSections([Section.main])
            snapshot.appendItems(retrievedPhotos)
            await self.dataSource?.apply(snapshot, animatingDifferences: false)
        }

    }
    var searchController = UISearchController(searchResultsController: nil)//nil uses self

    func configureHierarchy() {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
         collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
         collectionView.backgroundColor = .systemBackground
         view.addSubview(collectionView)

        self.collectionView = collectionView
//         collectionView?.delegate = self
     }
     func configureDataSource() {

         let cellRegistration = UICollectionView.CellRegistration<CustomConfigurationCell, PexelsPhoto> { (cell, indexPath, identifier) in
             // Populate the cell with our item description.
             cell.contentView.layer.borderWidth = 1
             cell.contentView.layer.cornerRadius = 8
             cell.photo = identifier
         }

         dataSource = UICollectionViewDiffableDataSource<Section, PexelsPhoto>(collectionView: collectionView!) {
             (collectionView: UICollectionView, indexPath: IndexPath, identifier: PexelsPhoto) -> UICollectionViewCell? in
             // Return the cell.
             return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
         }

         // initial data
         var snapshot = NSDiffableDataSourceSnapshot<Section, PexelsPhoto>()
         snapshot.appendSections([Section.main])
         dataSource?.apply(snapshot, animatingDifferences: false)
     }
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            let leadingItem = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7),
                                                  heightDimension: .fractionalHeight(1.0)))

            let trailingItem = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(0.3)))
            let trailingGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3),
                                                  heightDimension: .fractionalHeight(1.0)),
                subitem: trailingItem, count: 2)

            let nestedGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(0.4)),
                subitems: [leadingItem, trailingGroup])
            let section = NSCollectionLayoutSection(group: nestedGroup)
            return section

        }
        return layout
    }

}

extension ViewController: UISearchControllerDelegate {
    func presentSearchController(_ searchController: UISearchController) {
        searchController.showsSearchResultsController = true
    }
    func willDismissSearchController(_ searchController: UISearchController) {
        let topController = (searchController.searchResultsController as? UINavigationController)?.topViewController
        if let resultsController = topController as? ResultsViewController {
            resultsController.photos = []
        } else if let _ = topController as? FullScreenImage {
            topController?.navigationController?.popToRootViewController(animated: false)
            let topController = (searchController.searchResultsController as? UINavigationController)?.topViewController
            if let resultsController = topController as? ResultsViewController {
                resultsController.photos = []
            }
        }
    }
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchController.showsSearchResultsController = true

        guard let searchBarText = searchController.searchBar.text else { return }

        Task {
            guard let resultsController = (searchController.searchResultsController as? UINavigationController)?.topViewController as? ResultsViewController else {
                return
            }

            resultsController.query = PexelsImageSearch(query: searchBarText)
            resultsController.photos = try? await resultsController.query?.nextResults()
            resultsController.collectionView.reloadData()
        }
    }
}
