//
//  Created by Pavel Sharanda on 03/12/2023.
//

import SwiftUI
import SwiftUIKitView
import UIKit

class FixFlexStories: DynamicComponentStories {
    @objc static func story_FillParentWithInset() -> UIView {
        let child = UIView()
        child.backgroundColor = .systemYellow

        let parent = UIView()
        parent.translatesAutoresizingMaskIntoConstraints = false
        parent.backgroundColor = .systemMint
        parent.addSubview(child)

        parent.widthAnchor.constraint(equalToConstant: 200).isActive = true
        parent.heightAnchor.constraint(equalToConstant: 100).isActive = true

        parent.fx.hput(Fix(15),
                       Flex(child),
                       Fix(15))
        
        parent.fx.vput(Fix(15),
                       Flex(child),
                       Fix(15))

        return parent
    }

    @objc static func story_PinToParentTrailingBottom() -> UIView {
        let child = UIView()
        child.backgroundColor = .systemYellow

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
        child.backgroundColor = .systemYellow

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

    @objc static func story_CenterLabelInParent() -> UIView {
        let label = UILabel()
        label.text = "topLabel"
        label.font = .preferredFont(forTextStyle: .title1)
        label.adjustsFontForContentSizeCategory = true
        label.backgroundColor = .systemYellow

        let parent = UIView()
        parent.translatesAutoresizingMaskIntoConstraints = false
        parent.backgroundColor = .systemMint
        parent.addSubview(label)

        parent.widthAnchor.constraint(equalToConstant: 200).isActive = true
        parent.heightAnchor.constraint(equalToConstant: 200).isActive = true

        parent.fx.hput(Split(),
                       Flex(label),
                       Split())

        parent.fx.vput(Split(),
                       Flex(label),
                       Split())

        return parent
    }

    @objc static func story_VerticallyCenterTwoLabels() -> UIView {
        let topLabel = UILabel()
        topLabel.text = "topLabel"
        topLabel.font = .preferredFont(forTextStyle: .title1)
        topLabel.adjustsFontForContentSizeCategory = true
        topLabel.backgroundColor = .systemYellow

        let bottomLabel = UILabel()
        bottomLabel.text = "bottomLabel"
        bottomLabel.font = .preferredFont(forTextStyle: .caption1)
        bottomLabel.adjustsFontForContentSizeCategory = true
        bottomLabel.backgroundColor = .systemOrange

        let parent = UIView()
        parent.translatesAutoresizingMaskIntoConstraints = false
        parent.backgroundColor = .systemMint
        parent.addSubview(topLabel)
        parent.addSubview(bottomLabel)

        parent.widthAnchor.constraint(equalToConstant: 200).isActive = true
        parent.heightAnchor.constraint(equalToConstant: 200).isActive = true

        parent.fx.hput(Flex([topLabel, bottomLabel]))

        parent.fx.vput(Split(),
                       Flex(topLabel),
                       Fix(5),
                       Flex(bottomLabel),
                       Split())

        return parent
    }

    @objc static func story_CellWithIconTitleSubtitleAndChevron() -> UIView {
        let iconView = UIView()
        iconView.backgroundColor = .systemBrown

        let titleLabel = UILabel()
        titleLabel.text = "Title"
        titleLabel.font = .preferredFont(forTextStyle: .title1)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.backgroundColor = .systemYellow

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Subtitle"
        subtitleLabel.font = .preferredFont(forTextStyle: .body)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.backgroundColor = .systemOrange
        
        let chevron = UIView()
        chevron.backgroundColor = .systemBlue

        let parent = UIView()
        parent.translatesAutoresizingMaskIntoConstraints = false
        parent.backgroundColor = .systemMint

        parent.addSubview(iconView)
        parent.addSubview(titleLabel)
        parent.addSubview(subtitleLabel)
        parent.addSubview(chevron)

        parent.widthAnchor.constraint(equalToConstant: 200).isActive = true

        parent.fx.hput(Fix(15),
                       Fix(iconView, 44),
                       Fix(15),
                       Flex([titleLabel, subtitleLabel]),
                       Fix(15),
                       Fix(chevron, 20),
                       Fix(15))

        parent.fx.vput(Fix(15),
                       Fix(iconView, 44),
                       Flex(min: 15))
        
        parent.fx.vput(Fix(15),
                       Flex(titleLabel),
                       Flex(subtitleLabel),
                       Fix(15))
        
        parent.fx.vput(Split(),
                       Fix(chevron, 30),
                       Split())

        return parent
    }

    @objc static func story_CardWithIconTitleAndSubtitle() -> UIView {
        let iconView = UIView()
        iconView.backgroundColor = .systemBrown

        let titleLabel = UILabel()
        titleLabel.text = "Title"
        titleLabel.font = .preferredFont(forTextStyle: .title1)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.backgroundColor = .systemYellow
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Subtitle"
        subtitleLabel.font = .preferredFont(forTextStyle: .body)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.backgroundColor = .systemOrange
        subtitleLabel.textAlignment = .center

        let parent = UIView()
        parent.translatesAutoresizingMaskIntoConstraints = false
        parent.backgroundColor = .systemMint

        parent.addSubview(iconView)
        parent.addSubview(titleLabel)
        parent.addSubview(subtitleLabel)

        parent.widthAnchor.constraint(equalToConstant: 200).isActive = true

        parent.fx.hput(Fix(5),
                       Flex([iconView, titleLabel, subtitleLabel]),
                       Fix(5))

        parent.fx.vput(Fix(5),
                       Fix(iconView, 50),
                       Fix(10),
                       Flex(titleLabel),
                       Flex(subtitleLabel),
                       Fix(5))

        return parent
    }

    @objc static func story_LabelsRowWithNotEnoughSpaceForBoth() -> UIView {
        let leftLabel = UILabel()
        leftLabel.text = "leftLabel"
        leftLabel.font = .preferredFont(forTextStyle: .title1)
        leftLabel.adjustsFontForContentSizeCategory = true
        leftLabel.backgroundColor = .systemYellow

        let rightLabel = UILabel()
        rightLabel.text = "rightLabel"
        rightLabel.font = .preferredFont(forTextStyle: .title1)
        rightLabel.adjustsFontForContentSizeCategory = true
        rightLabel.backgroundColor = .systemOrange

        let parent = UIView()
        parent.translatesAutoresizingMaskIntoConstraints = false
        parent.backgroundColor = .systemMint
        parent.addSubview(leftLabel)
        parent.addSubview(rightLabel)

        parent.widthAnchor.constraint(equalToConstant: 200).isActive = true

        parent.fx.vput(Flex([leftLabel, rightLabel]))

        parent.fx.hput(Flex(leftLabel, compressionResistancePriority: .required),
                       Fix(5),
                       Flex(rightLabel))

        return parent
    }

    @objc static func story_LabelsSplit() -> UIView {
        let label1 = UILabel()
        label1.text = "L1"
        label1.font = .preferredFont(forTextStyle: .title3)
        label1.adjustsFontForContentSizeCategory = true
        label1.backgroundColor = .systemYellow

        let label2 = UILabel()
        label2.text = "L2"
        label2.font = .preferredFont(forTextStyle: .title3)
        label2.adjustsFontForContentSizeCategory = true
        label2.backgroundColor = .systemOrange

        let label3 = UILabel()
        label3.text = "L3"
        label3.font = .preferredFont(forTextStyle: .title3)
        label3.adjustsFontForContentSizeCategory = true
        label3.backgroundColor = .systemBrown

        let parent = UIView()
        parent.translatesAutoresizingMaskIntoConstraints = false
        parent.backgroundColor = .systemMint
        parent.addSubview(label1)
        parent.addSubview(label2)
        parent.addSubview(label3)

        parent.widthAnchor.constraint(equalToConstant: 200).isActive = true

        parent.fx.vput(Fix(5),
                       Flex([label1, label2, label3]),
                       Fix(5))

        parent.fx.hput(Fix(5),
                       Split(label1),
                       Fix(5),
                       Split(label2),
                       Fix(5),
                       Split(label3),
                       Fix(5))

        return parent
    }

    @objc static func story_FlexMinMax() -> UIView {
        let label1 = UILabel()
        label1.text = "Elit Aenean"
        label1.font = .preferredFont(forTextStyle: .title1)
        label1.adjustsFontForContentSizeCategory = true
        label1.backgroundColor = .systemYellow

        let label2 = UILabel()
        label2.text = "Elit Aenean"
        label2.font = .preferredFont(forTextStyle: .title1)
        label2.adjustsFontForContentSizeCategory = true
        label2.backgroundColor = .systemOrange

        let label3 = UILabel()
        label3.text = "Elit Aenean"
        label3.font = .preferredFont(forTextStyle: .title1)
        label3.adjustsFontForContentSizeCategory = true
        label3.backgroundColor = .systemBrown

        let parent = UIView()
        parent.translatesAutoresizingMaskIntoConstraints = false
        parent.backgroundColor = .systemMint
        parent.addSubview(label1)
        parent.addSubview(label2)
        parent.addSubview(label3)

        parent.widthAnchor.constraint(equalToConstant: 200).isActive = true

        parent.fx.vput(Fix(5),
                       Flex(label1),
                       Flex(label2),
                       Flex(label3),
                       Fix(5))

        parent.fx.hput(Fix(5),
                       Flex(label1),
                       Flex(),
                       Fix(5))

        parent.fx.hput(Fix(5),
                       Flex(label2, min: 175),
                       Flex(),
                       Fix(5))

        parent.fx.hput(Fix(5),
                       Flex(label3, max: 100),
                       Flex(),
                       Fix(5))

        return parent
    }

    @objc static func story_PutBetweenAnchors() -> UIView {
        let label = UILabel()
        label.text = "Green Red"
        label.font = .preferredFont(forTextStyle: .title1)
        label.adjustsFontForContentSizeCategory = true
        label.backgroundColor = .systemYellow

        let leadingView = UIView()
        leadingView.backgroundColor = .systemGreen.withAlphaComponent(0.5)

        let trailingView = UIView()
        trailingView.backgroundColor = .systemRed.withAlphaComponent(0.5)

        let parent = UIView()
        parent.translatesAutoresizingMaskIntoConstraints = false
        parent.backgroundColor = .systemMint
        parent.addSubview(label)
        parent.addSubview(leadingView)
        parent.addSubview(trailingView)

        parent.widthAnchor.constraint(equalToConstant: 200).isActive = true

        parent.fx.vput(Flex([label, leadingView, trailingView]))

        parent.fx.hput(Split(),
                       Flex(label),
                       Split())

        parent.fx.hput(startAnchor: label.leadingAnchor,
                       endAnchor: label.trailingAnchor,
                       Fix(leadingView, 20),
                       Flex(),
                       Fix(trailingView, 20))

        return parent
    }

    @objc static func story_PutBetweenAnchorsAbsolute() -> UIView {
        let label = UILabel()
        label.text = "Green Red"
        label.font = .preferredFont(forTextStyle: .title1)
        label.adjustsFontForContentSizeCategory = true
        label.backgroundColor = .systemYellow

        let leadingView = UIView()
        leadingView.backgroundColor = .systemGreen.withAlphaComponent(0.5)

        let trailingView = UIView()
        trailingView.backgroundColor = .systemRed.withAlphaComponent(0.5)

        let parent = UIView()
        parent.translatesAutoresizingMaskIntoConstraints = false
        parent.backgroundColor = .systemMint
        parent.addSubview(label)
        parent.addSubview(leadingView)
        parent.addSubview(trailingView)

        parent.widthAnchor.constraint(equalToConstant: 200).isActive = true

        parent.fx.vput(Flex([label, leadingView, trailingView]))

        parent.fx.hput(Split(),
                       Flex(label),
                       Split())

        parent.fx.hput(startAnchor: label.leftAnchor,
                       endAnchor: label.rightAnchor,
                       useAbsolutePositioning: true,
                       Fix(leadingView, 20),
                       Flex(),
                       Fix(trailingView, 20))

        return parent
    }

    @objc static func story_ShadowUsingMatch() -> UIView {
        let label = UILabel()
        label.text = "Lorem Ipsum"
        label.font = .preferredFont(forTextStyle: .title1)
        label.adjustsFontForContentSizeCategory = true
        label.backgroundColor = .systemYellow

        let matchView = UIView()
        matchView.backgroundColor = .systemRed.withAlphaComponent(0.5)

        let parent = UIView()
        parent.translatesAutoresizingMaskIntoConstraints = false
        parent.backgroundColor = .systemMint

        parent.addSubview(matchView)
        parent.addSubview(label)

        parent.widthAnchor.constraint(equalToConstant: 200).isActive = true
        parent.heightAnchor.constraint(equalToConstant: 200).isActive = true

        parent.fx.vput(Split(),
                       Flex(label),
                       Split())

        parent.fx.hput(Split(),
                       Flex(label),
                       Split())

        parent.fx.vput(startAnchor: label.topAnchor,
                       Fix(10),
                       Match(matchView, dimension: label.heightAnchor),
                       Flex())

        parent.fx.hput(startAnchor: label.leadingAnchor,
                       Fix(10),
                       Match(matchView, dimension: label.widthAnchor),
                       Flex())

        return parent
    }
}

struct Basic_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(FixFlexStories().stories, id: \.name) { story in
            UIViewContainer(story.makeView(), layout: .intrinsic)
                .fixedSize()
                .previewDisplayName(story.name)
                .previewLayout(.sizeThatFits)
        }
    }
}
