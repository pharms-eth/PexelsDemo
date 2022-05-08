//
//  SearchResultCell.swift
//  PexelsApp
//
//  Created by Daniel Bell on 4/30/22.
//

import UIKit

class SearchResultCell: UICollectionViewCell {
    static let cellID = "PexelsSearchResultCellID"
    var photo: PexelsPhoto? {
        didSet {
            guard let photo = photo else {
                backgroundColor = .white
                titleLabel.text = nil
                return
            }

            titleLabel.text = photo.photographer
            backgroundColor = UIColor(hex: photo.avgColor)

            if let brightness = backgroundColor?.isLight {
                if  brightness {
                    //color is close to black
                    titleLabel.textColor = .white
                    bubbleBackgroundView.backgroundColor = .white.withAlphaComponent(0.4)
                } else {
                    //color is close to white
                    bubbleBackgroundView.backgroundColor = .black.withAlphaComponent(0.4)
                }
            }

            Task {
                await imageView.loadImageUsing(urlString:photo.src.medium)
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        photo = nil
        titleLabel.textColor = .black
        bubbleBackgroundView.backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let bubbleBackgroundView = UIView()

    let imageView: URLLoadableImageView = {
        let imageV = URLLoadableImageView()
//        imageV.image
        imageV.contentMode = .scaleAspectFill
        imageV.layer.cornerRadius = 16
        imageV.layer.masksToBounds = true
        imageV.backgroundColor = .brown
        return imageV
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "TESTING"
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.numberOfLines = 2
        return label
    }()

    func setupViews() {
        backgroundColor = .green
        bubbleBackgroundView.layer.cornerRadius = 12
        bubbleBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        imageView.translatesAutoresizingMaskIntoConstraints = false

        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width/3).isActive = true

        addSubview(bubbleBackgroundView)
        addSubview(titleLabel)
        addSubview(imageView)


        let constraints = [
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            imageView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -2),
            imageView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 2),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            titleLabel.widthAnchor.constraint(equalTo: widthAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.leadingAnchor, constant: 6),
            titleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.trailingAnchor, constant: 6),

            bubbleBackgroundView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 2),
            bubbleBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            bubbleBackgroundView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            bubbleBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            ]
        NSLayoutConstraint.activate(constraints)
    }
}

