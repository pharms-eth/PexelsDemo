//
//  CuratedCell.swift
//  PexelsApp
//
//  Created by Daniel Bell on 5/7/22.
//

import UIKit

class CustomConfigurationCell: UICollectionViewCell {
    var photo: PexelsPhoto? {
        didSet {
            setNeedsUpdateConfiguration()
        }
    }

    override func updateConfiguration(using state: UICellConfigurationState) {
        backgroundConfiguration = CustomBackgroundConfiguration.configuration(for: state)

        var content = CustomContentConfiguration().updated(for: state)
        content.photo = photo
        contentConfiguration = content
    }
}

struct CustomBackgroundConfiguration {
    static func configuration(for state: UICellConfigurationState) -> UIBackgroundConfiguration {
        var background = UIBackgroundConfiguration.clear()
        background.cornerRadius = 10
        if state.isHighlighted || state.isSelected {
            // Set nil to use the inherited tint color of the cell when highlighted or selected
            background.backgroundColor = nil

            if state.isHighlighted {
                // Reduce the alpha of the tint color to 30% when highlighted
                background.backgroundColorTransformer = .init { $0.withAlphaComponent(0.3) }
            }
        }
        return background
    }
}

struct CustomContentConfiguration: UIContentConfiguration, Hashable {
    var photo: PexelsPhoto? = nil

    func makeContentView() -> UIView & UIContentView {
        return CustomContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
//        guard let state = state as? UICellConfigurationState else { return self }
        let updatedConfig = self
        return updatedConfig
    }
}

class CustomContentView: UIView, UIContentView {
    init(configuration: CustomContentConfiguration) {
        super.init(frame: .zero)
        setupInternalViews()
        apply(configuration: configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var configuration: UIContentConfiguration {
        get { appliedConfiguration }
        set {
            guard let newConfig = newValue as? CustomContentConfiguration else { return }
            apply(configuration: newConfig)
        }
    }

    private let imageView = URLLoadableImageView()

    private func setupInternalViews() {
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
        imageView.preferredSymbolConfiguration = .init(font: .preferredFont(forTextStyle: .body), scale: .large)
        imageView.isHidden = true
    }

    private var appliedConfiguration: CustomContentConfiguration!

    private func apply(configuration: CustomContentConfiguration) {
        guard appliedConfiguration != configuration else { return }
        appliedConfiguration = configuration

        imageView.isHidden = configuration.photo == nil
        guard let photoURL = configuration.photo?.src.large else { return }
        Task {
            await imageView.loadImageUsing(urlString: photoURL)
        }
    }
}

