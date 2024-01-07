//
//  Created by Pavel Sharanda on 03/12/2023.
//

import SwiftUI
import UIKit

class FixFlexStories: DynamicComponentStories {
    @objc static func story_FillParentWithInset() -> UIView {
        let child = UIView()
        child.backgroundColor = .systemRed

        let parent = UIView()
        parent.translatesAutoresizingMaskIntoConstraints = false
        parent.backgroundColor = .systemMint
        parent.addSubview(child)

        parent.widthAnchor.constraint(equalToConstant: 200).isActive = true
        parent.heightAnchor.constraint(equalToConstant: 100).isActive = true

        parent.fx.hput(Fix(15), Flex(child), Fix(15))
        parent.fx.vput(Fix(15), Flex(child), Fix(15))

        return parent
    }

    @objc static func story_PinToParentTrailingBottom() -> UIView {
        let child = UIView()
        child.backgroundColor = .systemRed

        let parent = UIView()
        parent.translatesAutoresizingMaskIntoConstraints = false
        parent.backgroundColor = .systemMint
        parent.addSubview(child)

        parent.widthAnchor.constraint(equalToConstant: 200).isActive = true
        parent.heightAnchor.constraint(equalToConstant: 100).isActive = true

        parent.fx.hput(Flex(),
                       Fix(child, 100),
                       Fix(15))

        parent.fx.vput(Flex(),
                       Fix(child, 50),
                       Fix(15))

        return parent
    }

    @objc static func story_CenterInParent() -> UIView {
        let child = UIView()
        child.backgroundColor = .systemRed

        let parent = UIView()
        parent.translatesAutoresizingMaskIntoConstraints = false
        parent.backgroundColor = .systemMint
        parent.addSubview(child)

        parent.widthAnchor.constraint(equalToConstant: 200).isActive = true
        parent.heightAnchor.constraint(equalToConstant: 100).isActive = true

        parent.fx.hput(Split(),
                       Fix(child, 100),
                       Split())

        parent.fx.vput(Split(),
                       Fix(child, 50),
                       Split())

        return parent
    }

    @objc static func story_VerticallyCenterTwoLabels() -> UIView {
        let topLabel = UILabel()
        topLabel.text = "topLabel"
        topLabel.font = .preferredFont(forTextStyle: .title1)
        topLabel.adjustsFontForContentSizeCategory = true
        topLabel.backgroundColor = .systemRed

        let bottomLabel = UILabel()
        bottomLabel.text = "bottomLabel"
        bottomLabel.font = .preferredFont(forTextStyle: .caption1)
        bottomLabel.adjustsFontForContentSizeCategory = true
        bottomLabel.backgroundColor = .systemBlue

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .systemMint
        container.addSubview(topLabel)
        container.addSubview(bottomLabel)

        container.widthAnchor.constraint(equalToConstant: 300).isActive = true
        container.heightAnchor.constraint(equalToConstant: 300).isActive = true

        container.fx.hput(Flex([topLabel, bottomLabel]))

        container.fx.vput(Split(),
                          Flex(topLabel),
                          Fix(5),
                          Flex(bottomLabel),
                          Split())

        return container
    }

    @objc static func story_CellWithIconTitleAndSubtitle() -> UIView {
        let iconView = UIView()
        iconView.backgroundColor = .systemBrown

        let titleLabel = UILabel()
        titleLabel.text = "Title"
        titleLabel.font = .preferredFont(forTextStyle: .title1)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.backgroundColor = .systemRed

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Subtitle"
        subtitleLabel.font = .preferredFont(forTextStyle: .body)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.backgroundColor = .systemBlue

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .systemMint

        container.addSubview(iconView)
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)

        container.widthAnchor.constraint(equalToConstant: 300).isActive = true

        container.fx.hput(Fix(5),
                          Fix(iconView, 44),
                          Fix(5),
                          Flex([titleLabel, subtitleLabel]),
                          Fix(5))

        container.fx.vput(Fix(5),
                          Fix(iconView, 44),
                          Flex())

        container.fx.vput(Fix(5),
                          Flex(titleLabel),
                          Fix(5),
                          Flex(subtitleLabel),
                          Fix(5))

        return container
    }

    @objc static func story_CardWithIconTitleAndSubtitle() -> UIView {
        let iconView = UIImageView(image: UIImage(systemName: "bell"))
        iconView.backgroundColor = .systemBrown
        iconView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = "Title"
        titleLabel.font = .preferredFont(forTextStyle: .title1)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.backgroundColor = .systemRed
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Subtitle"
        subtitleLabel.font = .preferredFont(forTextStyle: .body)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.backgroundColor = .systemBlue
        subtitleLabel.textAlignment = .center

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .systemMint

        container.addSubview(iconView)
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)

        container.widthAnchor.constraint(equalToConstant: 150).isActive = true

        container.fx.hput(Fix(5),
                          Flex([iconView, titleLabel, subtitleLabel]),
                          Fix(5))

        container.fx.vput(Fix(5),
                          Fix(iconView, 50),
                          Fix(10),
                          Flex(titleLabel),
                          Flex(subtitleLabel),
                          Fix(5))

        return container
    }

    @objc static func story_LabelsRowWithNotEnoughSpaceForBoth() -> UIView {
        let leftLabel = UILabel()
        leftLabel.text = "leftLabel"
        leftLabel.font = .preferredFont(forTextStyle: .title1)
        leftLabel.adjustsFontForContentSizeCategory = true
        leftLabel.backgroundColor = .systemRed

        let rightLabel = UILabel()
        rightLabel.text = "rightLabel"
        rightLabel.font = .preferredFont(forTextStyle: .title1)
        rightLabel.adjustsFontForContentSizeCategory = true
        rightLabel.backgroundColor = .systemBlue

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .systemMint
        container.addSubview(leftLabel)
        container.addSubview(rightLabel)

        container.widthAnchor.constraint(equalToConstant: 200).isActive = true

        container.fx.vput(Flex([leftLabel, rightLabel]))

        container.fx.hput(Flex(leftLabel, compressionResistancePriority: .required),
                          Fix(5),
                          Flex(rightLabel))

        return container
    }

    @objc static func story_LabelsSplit() -> UIView {
        let label1 = UILabel()
        label1.text = "1) label"
        label1.font = .preferredFont(forTextStyle: .title1)
        label1.adjustsFontForContentSizeCategory = true
        label1.backgroundColor = .systemRed

        let label2 = UILabel()
        label2.text = "2) label"
        label2.font = .preferredFont(forTextStyle: .title1)
        label2.adjustsFontForContentSizeCategory = true
        label2.backgroundColor = .systemBlue

        let label3 = UILabel()
        label3.text = "3) label"
        label3.font = .preferredFont(forTextStyle: .title1)
        label3.adjustsFontForContentSizeCategory = true
        label3.backgroundColor = .systemYellow

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .systemMint
        container.addSubview(label1)
        container.addSubview(label2)
        container.addSubview(label3)

        container.widthAnchor.constraint(equalToConstant: 250).isActive = true

        container.fx.vput(Fix(5),
                          Flex([label1, label2, label3]),
                          Fix(5))

        container.fx.hput(Fix(5),
                          Split(label1),
                          Fix(5),
                          Split(label2),
                          Fix(5),
                          Split(label3),
                          Fix(5))

        return container
    }

    @objc static func story_FlexMinMax() -> UIView {
        let label1 = UILabel()
        label1.text = "Elit Aenean"
        label1.font = .preferredFont(forTextStyle: .title1)
        label1.adjustsFontForContentSizeCategory = true
        label1.backgroundColor = .systemRed

        let label2 = UILabel()
        label2.text = "Elit Aenean"
        label2.font = .preferredFont(forTextStyle: .title1)
        label2.adjustsFontForContentSizeCategory = true
        label2.backgroundColor = .systemBlue

        let label3 = UILabel()
        label3.text = "Elit Aenean"
        label3.font = .preferredFont(forTextStyle: .title1)
        label3.adjustsFontForContentSizeCategory = true
        label3.backgroundColor = .systemYellow

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .systemMint
        container.addSubview(label1)
        container.addSubview(label2)
        container.addSubview(label3)

        container.widthAnchor.constraint(equalToConstant: 250).isActive = true

        container.fx.vput(Fix(5),
                          Flex(label1),
                          Flex(label2),
                          Flex(label3),
                          Fix(5))

        container.fx.hput(Fix(5),
                          Flex(label1),
                          Flex(),
                          Fix(5))

        container.fx.hput(Fix(5),
                          Flex(label2, min: 200),
                          Flex(),
                          Fix(5))

        container.fx.hput(Fix(5),
                          Flex(label3, max: 100),
                          Flex(),
                          Fix(5))

        return container
    }

    @objc static func story_PutBetweenAnchors() -> UIView {
        let label = UILabel()
        label.text = "Lorem Ipsum"
        label.font = .preferredFont(forTextStyle: .title1)
        label.adjustsFontForContentSizeCategory = true
        label.backgroundColor = .systemYellow

        let leadingView = UIView()
        leadingView.backgroundColor = .systemGreen.withAlphaComponent(0.5)

        let trailingView = UIView()
        trailingView.backgroundColor = .systemRed.withAlphaComponent(0.5)

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .systemMint
        container.addSubview(label)
        container.addSubview(leadingView)
        container.addSubview(trailingView)

        container.widthAnchor.constraint(equalToConstant: 200).isActive = true

        container.fx.vput(Flex([label, leadingView, trailingView]))

        container.fx.hput(Split(),
                          Flex(label),
                          Split())

        container.fx.hput(startAnchor: label.leadingAnchor,
                          endAnchor: label.trailingAnchor,
                          Fix(leadingView, 20),
                          Flex(),
                          Fix(trailingView, 20))

        return container
    }

    @objc static func story_PutBetweenAnchorsAbsolute() -> UIView {
        let label = UILabel()
        label.text = "Lorem Ipsum"
        label.font = .preferredFont(forTextStyle: .title1)
        label.adjustsFontForContentSizeCategory = true
        label.backgroundColor = .systemYellow

        let leadingView = UIView()
        leadingView.backgroundColor = .systemGreen.withAlphaComponent(0.5)

        let trailingView = UIView()
        trailingView.backgroundColor = .systemRed.withAlphaComponent(0.5)

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .systemMint
        container.addSubview(label)
        container.addSubview(leadingView)
        container.addSubview(trailingView)

        container.widthAnchor.constraint(equalToConstant: 200).isActive = true

        container.fx.vput(Flex([label, leadingView, trailingView]))

        container.fx.hput(Split(),
                          Flex(label),
                          Split())

        container.fx.hput(startAnchor: label.leftAnchor,
                          endAnchor: label.rightAnchor,
                          useAbsolutePositioning: true,
                          Fix(leadingView, 20),
                          Flex(),
                          Fix(trailingView, 20))

        return container
    }

    @objc static func story_ShadowUsingMatch() -> UIView {
        let label = UILabel()
        label.text = "Lorem Ipsum"
        label.font = .preferredFont(forTextStyle: .title1)
        label.adjustsFontForContentSizeCategory = true
        label.backgroundColor = .systemYellow

        let matchView = UIView()
        matchView.backgroundColor = .systemRed.withAlphaComponent(0.5)

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .systemMint

        container.addSubview(matchView)
        container.addSubview(label)

        container.widthAnchor.constraint(equalToConstant: 300).isActive = true
        container.heightAnchor.constraint(equalToConstant: 300).isActive = true

        container.fx.vput(Split(),
                          Flex(label),
                          Split())

        container.fx.hput(Split(),
                          Flex(label),
                          Split())

        container.fx.vput(startAnchor: label.topAnchor,
                          Fix(10),
                          Match(matchView, label.heightAnchor),
                          Flex())

        container.fx.hput(startAnchor: label.leadingAnchor,
                          Fix(10),
                          Match(matchView, label.widthAnchor),
                          Flex())

        return container
    }
}

struct Basic_Previews: PreviewProvider {
    static var previews: some View {
        previewStories(FixFlexStories().stories)
    }
}
