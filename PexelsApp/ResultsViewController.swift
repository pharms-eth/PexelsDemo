//
//  ResultsViewController.swift
//  PexelsApp
//
//  Created by Daniel Bell on 5/1/22.
//

import UIKit

class ResultsViewController: UICollectionViewController {

    var photos: [PexelsPhoto]?
    var query: PexelsImageSearch?

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(SearchResultCell.self, forCellWithReuseIdentifier: SearchResultCell.cellID)
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultCell.cellID, for: indexPath) as? SearchResultCell else {
            fatalError("\(type(of: collectionView)) cell at \(indexPath.description) not fully implemented")
        }

        cell.photo = photos?[indexPath.item]
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

//        let currentPage = collectionView.contentOffset.y / collectionView.frame.size.height

        let threshold = collectionView.contentSize.height - view.frame.height
        let offestValue = collectionView.contentOffset.y

        //  to only continue once per row
        guard indexPath.item.isMultiple(of: 3) else {
            return
        }
        //  to check if we are at the end
        guard offestValue > threshold else {
            print(offestValue)
            print(threshold)
            return
        }

        //  to check if we have scrolled or in the initial load
        guard collectionView.contentOffset.y > view.frame.height else {
            return
        }

        Task {
            guard let pexelsPhotoQuery = try? await query?.nextResults() else {
                return
            }
            print(pexelsPhotoQuery)
            photos?.append(contentsOf: pexelsPhotoQuery)
            self.collectionView.reloadData()
        }
    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        photos?[indexPath.item] != nil
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedPhoto = photos?[indexPath.item] else { return }
        let vc = FullScreenImage(url: selectedPhoto.src.large2X, lowURL: selectedPhoto.src.medium)
        vc.view.backgroundColor = UIColor(hex: selectedPhoto.avgColor)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ResultsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
