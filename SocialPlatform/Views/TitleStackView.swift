//
//  TitleStackView.swift
//  SocialPlatform
//
//  Created by Ammar on 1/16/21.
//

import UIKit

class TitleStackView: UIStackView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        axis = .horizontal
        alignment = .center
        addArrangedSubview(titleLabel)
        addArrangedSubview(button)
    }

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize, weight: .heavy)
        label.text = "Home"
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var button: UIButton = {
        let buttonWidth: CGFloat = 35.0
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: buttonWidth, height: buttonWidth)))
        button.setBackgroundImage(UIImage(systemName: "arrowshape.turn.up.left.fill"), for: .normal)
//        button.backgroundColor = .purple
//        button.setTitleColor(.white, for: .normal)
//        button.setTitle("B", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        button.heightAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        button.layer.cornerRadius = button.bounds.height * 0.5
        button.layer.masksToBounds = true
        return button
    }()
}
