//
//  Created by Pavel Sharanda on 02/12/2023.
//

@testable import FixFlexSamples
import iOSSnapshotTestCase
import XCTest

class NativeBookSnapshotTestCase: FBSnapshotTestCase {
    override func setUp() {
        super.setUp()
        usesDrawViewHierarchyInRect = true
    }

    func runTests(for componentStories: ComponentStories) {
        for story in componentStories.stories {
            verifyView(story.makeView(), storyName: story.name)
        }
    }

    private func verifyView(_ view: UIView, storyName: String) {
        let window = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }.last!
        window.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: window.centerYAnchor),
        ])

        let contentSizeCategories: [UIContentSizeCategory: String] = [
            .extraSmall: "xs",
            .small: "s",
            .medium: "m",
            .large: "default",
            .extraLarge: "xl",
            .extraExtraLarge: "xxl",
            .extraExtraExtraLarge: "xxxl",
            .accessibilityMedium: "am",
            .accessibilityLarge: "al",
            .accessibilityExtraLarge: "axl",
            .accessibilityExtraExtraLarge: "axxl",
            .accessibilityExtraExtraExtraLarge: "axxxl",
        ]

        for (category, categoryName) in contentSizeCategories {
            view.traitOverrides.preferredContentSizeCategory = category
            window.layoutIfNeeded()
            FBSnapshotVerifyView(view, identifier: storyName + "__" + categoryName)
        }

        view.traitOverrides.preferredContentSizeCategory = .large

        view.traitOverrides.layoutDirection = .rightToLeft
        view.semanticContentAttribute = .forceRightToLeft
        view.traitOverrides.userInterfaceStyle = .light
        window.layoutIfNeeded()
        FBSnapshotVerifyView(view, identifier: storyName + "__rtl")

        view.removeFromSuperview()
    }
}

final class FixFlexTests: NativeBookSnapshotTestCase {
    func test() {
        //recordMode = true
        runTests(for: FixFlexStories())
    }
}
