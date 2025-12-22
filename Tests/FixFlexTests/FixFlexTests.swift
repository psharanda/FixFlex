@testable import FixFlex
import XCTest

#if os(macOS)
import AppKit

extension NSLayoutGuide {
    var _layoutFrame: CGRect {
        return frame
    }
}

final class TestView: NSView {
    override var isFlipped: Bool { true }
}

#else
import UIKit

extension UILayoutGuide {
    var _layoutFrame: CGRect {
        return layoutFrame
    }
}

typealias TestView = UIView

#endif

// MARK: - Test Helpers

extension _View {
    /// Force layout calculation for testing
    func forceLayout() {
        #if os(macOS)
        layoutSubtreeIfNeeded()
        #else
        layoutIfNeeded()
        #endif
    }
}

/// Convenience helpers for inspecting constraints in tests
extension Array where Element == NSLayoutConstraint {
    /// Returns first constraint that references given anchors in any order.
    func constraint(between lhs: AnyObject, and rhs: AnyObject) -> NSLayoutConstraint? {
        return first(where: { ($0.firstAnchor === lhs && $0.secondAnchor === rhs) || ($0.firstAnchor === rhs && $0.secondAnchor === lhs) })
    }
}

/// Creates a parent view with fixed dimensions for testing
func makeParentView(width: CGFloat, height: CGFloat) -> _View {
    let parent = TestView()
    parent.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        parent.widthAnchor.constraint(equalToConstant: width),
        parent.heightAnchor.constraint(equalToConstant: height),
    ])
    return parent
}

/// Creates a child view and adds it to parent
func makeChildView(parent: _View) -> _View {
    let child = TestView()
    parent.addSubview(child)
    return child
}

// MARK: - Fix Sizing Intent Tests

class FixSizingIntentTests: XCTestCase {
    func test_Fix_spacer_createsLayoutGuideWithFixedSize() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100
        let fixedSpacerSize: CGFloat = 30

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child = makeChildView(parent: parent)

        let result = parent.fx.hstack(
            Fix(fixedSpacerSize),
            Flex(child)
        )

        parent.forceLayout()

        // Should create 1 layout guide for the spacer
        XCTAssertEqual(result.layoutGuides.count, 1)

        // The layout guide should have the fixed size
        let spacerGuide = result.layoutGuides[0]
        XCTAssertEqual(spacerGuide._layoutFrame.width, fixedSpacerSize, accuracy: 0.01)

        // Child should fill remaining space: parentWidth - fixedSpacerSize
        let expectedChildWidth = parentWidth - fixedSpacerSize
        XCTAssertEqual(child.frame.width, expectedChildWidth, accuracy: 0.01)
    }

    func test_Fix_singleView_setsCorrectDimension() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100
        let fixedViewWidth: CGFloat = 80

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child = makeChildView(parent: parent)

        parent.fx.hstack(
            Fix(child, fixedViewWidth),
            Flex()
        )

        parent.forceLayout()

        // Child should have the fixed width
        XCTAssertEqual(child.frame.width, fixedViewWidth, accuracy: 0.01)
    }

    func test_Fix_multipleViews_allGetSameDimension() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100
        let fixedViewHeight: CGFloat = 40

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child1 = makeChildView(parent: parent)
        let child2 = makeChildView(parent: parent)

        parent.fx.vstack(
            Fix([child1, child2], fixedViewHeight),
            Flex()
        )

        parent.forceLayout()

        // Both children should have the same fixed height
        XCTAssertEqual(child1.frame.height, fixedViewHeight, accuracy: 0.01)
        XCTAssertEqual(child2.frame.height, fixedViewHeight, accuracy: 0.01)
    }

    func test_Fix_viewSetsTranslatesAutoresizingMaskToFalse() {
        let parent = makeParentView(width: 200, height: 100)
        let child = makeChildView(parent: parent)

        // Initially true by default
        child.translatesAutoresizingMaskIntoConstraints = true

        parent.fx.hstack(Fix(child, 50))

        XCTAssertFalse(child.translatesAutoresizingMaskIntoConstraints)
    }

    func test_Flex_viewSetsTranslatesAutoresizingMaskToFalse() {
        let parent = makeParentView(width: 200, height: 100)
        let child = makeChildView(parent: parent)

        child.translatesAutoresizingMaskIntoConstraints = true

        parent.fx.hstack(Flex(child))

        XCTAssertFalse(child.translatesAutoresizingMaskIntoConstraints)
    }

    func test_Fill_viewSetsTranslatesAutoresizingMaskToFalse() {
        let parent = makeParentView(width: 200, height: 100)
        let child = makeChildView(parent: parent)

        child.translatesAutoresizingMaskIntoConstraints = true

        parent.fx.hstack(Fill(child))

        XCTAssertFalse(child.translatesAutoresizingMaskIntoConstraints)
    }

    func test_Match_viewSetsTranslatesAutoresizingMaskToFalse() {
        let parent = makeParentView(width: 200, height: 100)
        let reference = makeChildView(parent: parent)
        let matched = makeChildView(parent: parent)

        parent.fx.hstack(Fix(reference, 40))
        matched.translatesAutoresizingMaskIntoConstraints = true

        parent.fx.hstack(Match(matched, dimension: reference.widthAnchor))

        XCTAssertFalse(matched.translatesAutoresizingMaskIntoConstraints)
    }
}

// MARK: - Flex Sizing Intent Tests

class FlexSizingIntentTests: XCTestCase {
    func test_Flex_spacer_createsFlexibleGuide() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100
        let fixedSize: CGFloat = 50

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child = makeChildView(parent: parent)

        let result = parent.fx.hstack(
            Fix(child, fixedSize),
            Flex()
        )

        parent.forceLayout()

        // Should create 1 layout guide for the flex spacer
        XCTAssertEqual(result.layoutGuides.count, 1)

        // Spacer fills remaining space: parentWidth - fixedSize
        let expectedSpacerWidth = parentWidth - fixedSize
        XCTAssertEqual(result.layoutGuides[0]._layoutFrame.width, expectedSpacerWidth, accuracy: 0.01)
    }

    func test_Flex_viewSetsPrioritiesWhenProvided() {
        let parent = makeParentView(width: 200, height: 100)
        let child = makeChildView(parent: parent)
        let hugging: _LayoutPriority = .defaultHigh
        let compression: _LayoutPriority = .defaultLow

        parent.fx.hstack(
            Flex(child, huggingPriority: hugging, compressionResistancePriority: compression),
            Flex()
        )

        // Priorities should be applied on stacking axis (horizontal here)
        XCTAssertEqual(child.contentHuggingPriority(for: .horizontal), hugging)
        XCTAssertEqual(child.contentCompressionResistancePriority(for: .horizontal), compression)
    }

    func test_Flex_viewSetsPrioritiesWhenProvided_vertical() {
        let parent = makeParentView(width: 100, height: 200)
        let child = makeChildView(parent: parent)
        let hugging: _LayoutPriority = .defaultHigh
        let compression: _LayoutPriority = .defaultLow

        parent.fx.vstack(
            Flex(child, huggingPriority: hugging, compressionResistancePriority: compression),
            Flex()
        )

        // Priorities should be applied on stacking axis (vertical here)
        XCTAssertEqual(child.contentHuggingPriority(for: .vertical), hugging)
        XCTAssertEqual(child.contentCompressionResistancePriority(for: .vertical), compression)
    }

    func test_Flex_spacerWithMin_respectsMinimumSize() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100
        let minSpacerSize: CGFloat = 150

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child = makeChildView(parent: parent)

        // Child will want to be larger but min constraint should limit spacer
        let result = parent.fx.hstack(
            Flex(child),
            Flex(min: minSpacerSize)
        )

        parent.forceLayout()

        // Spacer should be at least minSpacerSize
        XCTAssertGreaterThanOrEqual(result.layoutGuides[0]._layoutFrame.width, minSpacerSize - 0.01)
    }

    func test_Flex_spacerWithMax_respectsMaximumSize() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100
        let maxSpacerSize: CGFloat = 30

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child = makeChildView(parent: parent)

        let result = parent.fx.hstack(
            Fix(child, 50),
            Flex(max: maxSpacerSize),
            Flex()
        )

        parent.forceLayout()

        // Spacer should be at most maxSpacerSize
        XCTAssertLessThanOrEqual(result.layoutGuides[0]._layoutFrame.width, maxSpacerSize + 0.01)
    }

    func test_Flex_view_fillsRemainingSpace() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100
        let fixedSpacing: CGFloat = 20

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child = makeChildView(parent: parent)

        parent.fx.hstack(
            Fix(fixedSpacing),
            Flex(child),
            Fix(fixedSpacing)
        )

        parent.forceLayout()

        // Child fills space between two fixed spacers
        let expectedChildWidth = parentWidth - fixedSpacing * 2
        XCTAssertEqual(child.frame.width, expectedChildWidth, accuracy: 0.01)
    }

    func test_Flex_viewWithMinMax_constrainsDimension() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100
        let minWidth: CGFloat = 80
        let maxWidth: CGFloat = 120

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child = makeChildView(parent: parent)

        parent.fx.hstack(
            Flex(child, min: minWidth, max: maxWidth),
            Flex()
        )

        parent.forceLayout()

        // Child should be within bounds (will likely hit max due to filling)
        XCTAssertGreaterThanOrEqual(child.frame.width, minWidth - 0.01)
        XCTAssertLessThanOrEqual(child.frame.width, maxWidth + 0.01)
    }

    func test_Flex_multipleViews_alignedInParallel() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100
        let spacing: CGFloat = 10

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child1 = makeChildView(parent: parent)
        let child2 = makeChildView(parent: parent)

        parent.fx.hstack(
            Fix(spacing),
            Flex([child1, child2]),
            Fix(spacing)
        )

        parent.forceLayout()

        // Both children should have same width and x position
        let expectedWidth = parentWidth - spacing * 2
        XCTAssertEqual(child1.frame.width, expectedWidth, accuracy: 0.01)
        XCTAssertEqual(child2.frame.width, expectedWidth, accuracy: 0.01)
        XCTAssertEqual(child1.frame.minX, spacing, accuracy: 0.01)
        XCTAssertEqual(child2.frame.minX, spacing, accuracy: 0.01)
    }
}

// MARK: - Fill Sizing Intent Tests

class FillSizingIntentTests: XCTestCase {
    func test_Fill_twoEqualWeightSpacers_haveEqualSize() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100
        let viewWidth: CGFloat = 60

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child = makeChildView(parent: parent)

        let result = parent.fx.hstack(
            Fill(),
            Fix(child, viewWidth),
            Fill()
        )

        parent.forceLayout()

        // Two Fill spacers share remaining space equally
        let remainingSpace = parentWidth - viewWidth
        let expectedSpacerWidth = remainingSpace / 2

        XCTAssertEqual(result.layoutGuides.count, 2)
        XCTAssertEqual(result.layoutGuides[0]._layoutFrame.width, expectedSpacerWidth, accuracy: 0.01)
        XCTAssertEqual(result.layoutGuides[1]._layoutFrame.width, expectedSpacerWidth, accuracy: 0.01)
    }

    func test_Fill_weightedSpacers_distributeProportionally() {
        let parentWidth: CGFloat = 300
        let parentHeight: CGFloat = 100
        let weight1: CGFloat = 2
        let weight2: CGFloat = 1

        let parent = makeParentView(width: parentWidth, height: parentHeight)

        let result = parent.fx.hstack(
            Fill(weight: weight1),
            Fill(weight: weight2)
        )

        parent.forceLayout()

        // Total weight is weight1 + weight2
        let totalWeight = weight1 + weight2
        let expectedWidth1 = parentWidth * (weight1 / totalWeight)
        let expectedWidth2 = parentWidth * (weight2 / totalWeight)

        XCTAssertEqual(result.layoutGuides[0]._layoutFrame.width, expectedWidth1, accuracy: 0.01)
        XCTAssertEqual(result.layoutGuides[1]._layoutFrame.width, expectedWidth2, accuracy: 0.01)
    }

    func test_Fill_zeroWeight_createsZeroSizeConstraint() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100

        let parent = makeParentView(width: parentWidth, height: parentHeight)

        let result = parent.fx.hstack(
            Fill(weight: 0),
            Fill(weight: 1)
        )

        parent.forceLayout()

        // Weight 0 should result in 0 width
        XCTAssertEqual(result.layoutGuides[0]._layoutFrame.width, 0, accuracy: 0.01)
        // Weight 1 should take all remaining space
        XCTAssertEqual(result.layoutGuides[1]._layoutFrame.width, parentWidth, accuracy: 0.01)
    }

    func test_Fill_viewWithZeroWeight_collapsesDimension() {
        let parent = makeParentView(width: 200, height: 100)
        let child = makeChildView(parent: parent)

        let result = parent.fx.hstack(
            Fill(child, weight: 0),
            Fix(10),
            Flex()
        )

        parent.forceLayout()

        // Should create a zero-dimension constraint for the view
        let zeroConstraint = result.constraints.first {
            ($0.firstAnchor === child.widthAnchor || $0.secondAnchor === child.widthAnchor) && abs($0.constant) < 0.01
        }
        XCTAssertNotNil(zeroConstraint)
    }

    func test_Fill_twoViews_shareSpaceEqually() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child1 = makeChildView(parent: parent)
        let child2 = makeChildView(parent: parent)

        parent.fx.hstack(
            Fill(child1),
            Fill(child2)
        )

        parent.forceLayout()

        // Two views with equal weight share space equally
        let expectedWidth = parentWidth / 2
        XCTAssertEqual(child1.frame.width, expectedWidth, accuracy: 0.01)
        XCTAssertEqual(child2.frame.width, expectedWidth, accuracy: 0.01)
    }

    func test_Fill_multipleViews_distributeProportionallyWithWeights() {
        let parentWidth: CGFloat = 300
        let parentHeight: CGFloat = 100
        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child1 = makeChildView(parent: parent)
        let child2 = makeChildView(parent: parent)
        let child3 = makeChildView(parent: parent)

        let w1: CGFloat = 3
        let w2: CGFloat = 1
        let w3: CGFloat = 0

        parent.fx.hstack(
            Fill(child1, weight: w1),
            Fill(child2, weight: w2),
            Fill(child3, weight: w3)
        )

        parent.forceLayout()

        let totalWeight = w1 + w2 // weight 0 should collapse
        let expected1 = parentWidth * (w1 / totalWeight)
        let expected2 = parentWidth * (w2 / totalWeight)

        XCTAssertEqual(child1.frame.width, expected1, accuracy: 0.01)
        XCTAssertEqual(child2.frame.width, expected2, accuracy: 0.01)
        XCTAssertEqual(child3.frame.width, 0, accuracy: 0.01)
    }

    func test_Fill_weightedViews_distributeProportionally() {
        let parentWidth: CGFloat = 300
        let parentHeight: CGFloat = 100
        let weight1: CGFloat = 2
        let weight2: CGFloat = 1
        let spacing: CGFloat = 15

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child1 = makeChildView(parent: parent)
        let child2 = makeChildView(parent: parent)

        parent.fx.hstack(
            Fix(spacing),
            Fill(child1, weight: weight1),
            Fix(spacing),
            Fill(child2, weight: weight2),
            Fix(spacing)
        )

        parent.forceLayout()

        // Available space after fixed spacings
        let availableWidth = parentWidth - spacing * 3
        let totalWeight = weight1 + weight2
        let expectedWidth1 = availableWidth * (weight1 / totalWeight)
        let expectedWidth2 = availableWidth * (weight2 / totalWeight)

        XCTAssertEqual(child1.frame.width, expectedWidth1, accuracy: 0.01)
        XCTAssertEqual(child2.frame.width, expectedWidth2, accuracy: 0.01)
    }

    func test_Fill_threeViews_correctProportions() {
        let parentWidth: CGFloat = 280
        let parentHeight: CGFloat = 100
        let weight1: CGFloat = 2
        let weight2: CGFloat = 1
        let weight3: CGFloat = 1
        let spacing: CGFloat = 5

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child1 = makeChildView(parent: parent)
        let child2 = makeChildView(parent: parent)
        let child3 = makeChildView(parent: parent)

        parent.fx.vstack(
            Flex([child1, child2, child3])
        )

        parent.fx.hstack(
            Fix(spacing),
            Fill(child1, weight: weight1),
            Fix(spacing),
            Fill(child2, weight: weight2),
            Fix(spacing),
            Fill(child3, weight: weight3),
            Fix(spacing)
        )

        parent.forceLayout()

        // Available space: parentWidth - 4 * spacing
        let availableWidth = parentWidth - spacing * 4
        let totalWeight = weight1 + weight2 + weight3
        let expectedWidth1 = availableWidth * (weight1 / totalWeight)
        let expectedWidth2 = availableWidth * (weight2 / totalWeight)
        let expectedWidth3 = availableWidth * (weight3 / totalWeight)

        XCTAssertEqual(child1.frame.width, expectedWidth1, accuracy: 0.01)
        XCTAssertEqual(child2.frame.width, expectedWidth2, accuracy: 0.01)
        XCTAssertEqual(child3.frame.width, expectedWidth3, accuracy: 0.01)
    }
}

// MARK: - Match Sizing Intent Tests

class MatchSizingIntentTests: XCTestCase {
    func test_Match_spacerMatchesDimensionExactly() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100
        let referenceWidth: CGFloat = 60

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let referenceView = makeChildView(parent: parent)

        // Set up reference view with known width
        parent.fx.hstack(
            Fix(referenceView, referenceWidth),
            Flex()
        )

        let result = parent.fx.vstack(
            Match(dimension: referenceView.widthAnchor),
            Flex()
        )

        parent.forceLayout()

        // Matched spacer should have width equal to reference
        XCTAssertEqual(result.layoutGuides[0]._layoutFrame.height, referenceWidth, accuracy: 0.01)
    }

    func test_Match_withMultiplier_scalesDimension() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100
        let referenceWidth: CGFloat = 40
        let multiplier: CGFloat = 2.5

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let referenceView = makeChildView(parent: parent)

        parent.fx.hstack(
            Fix(referenceView, referenceWidth),
            Flex()
        )

        let result = parent.fx.vstack(
            Match(dimension: referenceView.widthAnchor, multiplier: multiplier),
            Flex()
        )

        parent.forceLayout()

        let expectedHeight = referenceWidth * multiplier
        XCTAssertEqual(result.layoutGuides[0]._layoutFrame.height, expectedHeight, accuracy: 0.01)
    }

    func test_Match_withOffset_addsToDimension() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 150
        let referenceWidth: CGFloat = 50
        let offset: CGFloat = 20

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let referenceView = makeChildView(parent: parent)

        parent.fx.hstack(
            Fix(referenceView, referenceWidth),
            Flex()
        )

        let result = parent.fx.vstack(
            Match(dimension: referenceView.widthAnchor, offset: offset),
            Flex()
        )

        parent.forceLayout()

        let expectedHeight = referenceWidth + offset
        XCTAssertEqual(result.layoutGuides[0]._layoutFrame.height, expectedHeight, accuracy: 0.01)
    }

    func test_Match_withMultiplierAndOffset_combinesCorrectly() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 200
        let referenceWidth: CGFloat = 30
        let multiplier: CGFloat = 2.0
        let offset: CGFloat = 15

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let referenceView = makeChildView(parent: parent)

        parent.fx.hstack(
            Fix(referenceView, referenceWidth),
            Flex()
        )

        let result = parent.fx.vstack(
            Match(dimension: referenceView.widthAnchor, multiplier: multiplier, offset: offset),
            Flex()
        )

        parent.forceLayout()

        // Formula: dimension * multiplier + offset
        let expectedHeight = referenceWidth * multiplier + offset
        XCTAssertEqual(result.layoutGuides[0]._layoutFrame.height, expectedHeight, accuracy: 0.01)
    }

    func test_Match_viewMatchesDimension() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 150
        let referenceWidth: CGFloat = 80

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let referenceView = makeChildView(parent: parent)
        let matchedView = makeChildView(parent: parent)

        parent.fx.hstack(
            Fix(referenceView, referenceWidth),
            Flex()
        )

        parent.fx.vstack(
            Match(matchedView, dimension: referenceView.widthAnchor),
            Flex()
        )

        parent.forceLayout()

        // Matched view height equals reference width
        XCTAssertEqual(matchedView.frame.height, referenceWidth, accuracy: 0.01)
    }
}

// MARK: - hstack Tests

class HStackTests: XCTestCase {
    func test_hstack_emptyIntents_returnsEmptyResult() {
        let parent = makeParentView(width: 200, height: 100)

        let result = parent.fx.hstack([])

        XCTAssertEqual(result.constraints.count, 0)
        XCTAssertEqual(result.layoutGuides.count, 0)
    }

    func test_hstack_singleIntent_pinsToBothEdges() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child = makeChildView(parent: parent)

        parent.fx.hstack(
            Flex(child)
        )

        parent.forceLayout()

        // Child should span full width
        XCTAssertEqual(child.frame.minX, 0, accuracy: 0.01)
        XCTAssertEqual(child.frame.width, parentWidth, accuracy: 0.01)
    }

    func test_hstack_multipleIntents_chainCorrectly() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100
        let spacing: CGFloat = 20
        let viewWidth: CGFloat = 50

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child1 = makeChildView(parent: parent)
        let child2 = makeChildView(parent: parent)

        parent.fx.hstack(
            Fix(spacing),
            Fix(child1, viewWidth),
            Flex(),
            Fix(child2, viewWidth),
            Fix(spacing)
        )

        parent.forceLayout()

        // child1 starts after initial spacing
        XCTAssertEqual(child1.frame.minX, spacing, accuracy: 0.01)
        XCTAssertEqual(child1.frame.width, viewWidth, accuracy: 0.01)

        // child2 ends at parentWidth - spacing
        XCTAssertEqual(child2.frame.maxX, parentWidth - spacing, accuracy: 0.01)
        XCTAssertEqual(child2.frame.width, viewWidth, accuracy: 0.01)
    }

    func test_hstack_startOffset_addsInitialSpacing() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100
        let startOffset: CGFloat = 25

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child = makeChildView(parent: parent)

        parent.fx.hstack(
            startOffset: startOffset,
            Flex(child)
        )

        parent.forceLayout()

        // Child starts after startOffset
        XCTAssertEqual(child.frame.minX, startOffset, accuracy: 0.01)
        // Width is parentWidth - startOffset
        XCTAssertEqual(child.frame.width, parentWidth - startOffset, accuracy: 0.01)
    }

    func test_hstack_endOffset_addsEndSpacing() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100
        let endOffset: CGFloat = -30 // Negative because it's relative to end anchor

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child = makeChildView(parent: parent)

        parent.fx.hstack(
            endOffset: endOffset,
            Flex(child)
        )

        parent.forceLayout()

        // Child ends at parentWidth + endOffset (endOffset is negative)
        let expectedWidth = parentWidth + endOffset
        XCTAssertEqual(child.frame.width, expectedWidth, accuracy: 0.01)
    }

    func test_hstack_startOffsetNil_leavesStartUnpinned() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child = makeChildView(parent: parent)

        // With startOffset nil and a Flex view, the view's intrinsic size determines position
        let result = parent.fx.hstack(
            startOffset: nil,
            Flex(child)
        )

        // Should still create constraints but not pin to start
        XCTAssertFalse(result.constraints.isEmpty)
        XCTAssertNil(result.constraints.constraint(between: child.leadingAnchor, and: parent.leadingAnchor))
    }

    func test_hstack_endOffsetNil_leavesEndUnpinned() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child = makeChildView(parent: parent)

        let result = parent.fx.hstack(
            endOffset: nil,
            Flex(child)
        )

        // Should still create constraints but not pin to end
        XCTAssertFalse(result.constraints.isEmpty)
        XCTAssertNil(result.constraints.constraint(between: child.trailingAnchor, and: parent.trailingAnchor))
    }

    func test_hstack_customAnchors_usesProvidedAnchors() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100
        let referenceViewWidth: CGFloat = 150

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let referenceView = makeChildView(parent: parent)
        let child = makeChildView(parent: parent)

        // Set up reference view
        parent.fx.hstack(
            Fix(25),
            Fix(referenceView, referenceViewWidth),
            Flex()
        )

        // Stack child between reference view's anchors
        parent.fx.hstack(
            startAnchor: referenceView.leadingAnchor,
            endAnchor: referenceView.trailingAnchor,
            Flex(child)
        )

        parent.forceLayout()

        // Child should match reference view's width
        XCTAssertEqual(child.frame.width, referenceViewWidth, accuracy: 0.01)
    }

    func test_hstack_constraintsAreActive() {
        let parent = makeParentView(width: 200, height: 100)
        let child = makeChildView(parent: parent)

        let result = parent.fx.hstack(
            Fix(20),
            Flex(child),
            Fix(20)
        )

        // All constraints should be active
        XCTAssertTrue(result.constraints.allSatisfy { $0.isActive })
    }
}

// MARK: - vstack Tests

class VStackTests: XCTestCase {
    func test_vstack_emptyIntents_returnsEmptyResult() {
        let parent = makeParentView(width: 200, height: 100)

        let result = parent.fx.vstack([])

        XCTAssertEqual(result.constraints.count, 0)
        XCTAssertEqual(result.layoutGuides.count, 0)
    }

    func test_vstack_singleIntent_pinsToBothEdges() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child = makeChildView(parent: parent)

        parent.fx.vstack(
            Flex(child)
        )

        parent.forceLayout()

        // Child should span full height
        XCTAssertEqual(child.frame.minY, 0, accuracy: 0.01)
        XCTAssertEqual(child.frame.height, parentHeight, accuracy: 0.01)
    }

    func test_vstack_multipleIntents_chainCorrectly() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 150
        let topSpacing: CGFloat = 10
        let viewHeight: CGFloat = 40
        let bottomSpacing: CGFloat = 15

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child = makeChildView(parent: parent)

        parent.fx.vstack(
            Fix(topSpacing),
            Fix(child, viewHeight),
            Flex(),
            Fix(bottomSpacing)
        )

        parent.forceLayout()

        // Child starts after top spacing
        XCTAssertEqual(child.frame.minY, topSpacing, accuracy: 0.01)
        XCTAssertEqual(child.frame.height, viewHeight, accuracy: 0.01)
    }

    func test_vstack_centersWithFillSpacers() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100
        let viewHeight: CGFloat = 40

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child = makeChildView(parent: parent)

        parent.fx.vstack(
            Fill(),
            Fix(child, viewHeight),
            Fill()
        )

        parent.forceLayout()

        // Child should be centered vertically
        let expectedTopSpace = (parentHeight - viewHeight) / 2
        XCTAssertEqual(child.frame.minY, expectedTopSpace, accuracy: 0.01)
        XCTAssertEqual(child.frame.height, viewHeight, accuracy: 0.01)
    }

    func test_vstack_usesTopAndBottomAnchors() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child = makeChildView(parent: parent)

        parent.fx.vstack(
            Flex(child)
        )

        parent.forceLayout()

        // Verify child uses full vertical space (top to bottom)
        XCTAssertEqual(child.frame.minY, 0, accuracy: 0.01)
        XCTAssertEqual(child.frame.maxY, parentHeight, accuracy: 0.01)
    }
}

// MARK: - Modifier Tests

class ModifierTests: XCTestCase {
    func test_spacingBefore_addsSpacingBetweenIntents() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100
        let viewWidth: CGFloat = 50
        let spacingBefore: CGFloat = 30

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child1 = makeChildView(parent: parent)
        let child2 = makeChildView(parent: parent)

        parent.fx.hstack(
            Fix(child1, viewWidth),
            Fix(child2, viewWidth).spacingBefore(spacingBefore),
            Flex()
        )

        parent.forceLayout()

        // child2 should start after child1 + spacingBefore
        let expectedChild2Start = viewWidth + spacingBefore
        XCTAssertEqual(child2.frame.minX, expectedChild2Start, accuracy: 0.01)
    }

    func test_spacingBefore_negativeAllowsOverlap() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100
        let viewWidth: CGFloat = 60
        let negativeSpacing: CGFloat = -20

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child1 = makeChildView(parent: parent)
        let child2 = makeChildView(parent: parent)

        parent.fx.hstack(
            Fix(child1, viewWidth),
            Fix(child2, viewWidth).spacingBefore(negativeSpacing),
            Flex()
        )

        parent.forceLayout()

        // child2 should overlap with child1
        let expectedChild2Start = viewWidth + negativeSpacing
        XCTAssertEqual(child2.frame.minX, expectedChild2Start, accuracy: 0.01)
        // Verify overlap: child2 starts before child1 ends
        XCTAssertLessThan(child2.frame.minX, child1.frame.maxX)
    }

    func test_onCreateDimensionConstraint_receivesConstraint() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100
        let fixedSize: CGFloat = 50

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child = makeChildView(parent: parent)

        var receivedConstraints: [NSLayoutConstraint] = []

        parent.fx.hstack(
            Fix(child, fixedSize).onCreateDimensionConstraint { constraint in
                receivedConstraints.append(constraint)
            },
            Flex()
        )

        // Should receive exactly one dimension constraint
        XCTAssertEqual(receivedConstraints.count, 1)
        XCTAssertEqual(receivedConstraints[0].constant, fixedSize)
    }

    func test_onCreateStartConstraint_receivesConstraint() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child = makeChildView(parent: parent)

        var receivedConstraints: [NSLayoutConstraint] = []

        parent.fx.hstack(
            Fix(20),
            Flex(child).onCreateStartConstraint { constraint in
                receivedConstraints.append(constraint)
            }
        )

        // Should receive start constraint
        XCTAssertEqual(receivedConstraints.count, 1)
    }

    func test_onCreateEndConstraint_receivesConstraint() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child = makeChildView(parent: parent)

        var receivedConstraints: [NSLayoutConstraint] = []

        parent.fx.hstack(
            Flex(child).onCreateEndConstraint { constraint in
                receivedConstraints.append(constraint)
            }
        )

        // Should receive end constraint
        XCTAssertEqual(receivedConstraints.count, 1)
    }

    func test_onCreateLayoutGuide_receivesGuideForSpacer() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100

        let parent = makeParentView(width: parentWidth, height: parentHeight)

        var receivedGuides: [_LayoutGuide] = []

        parent.fx.hstack(
            Fix(30).onCreateLayoutGuide { guide in
                receivedGuides.append(guide)
            },
            Flex()
        )

        // Should receive exactly one layout guide
        XCTAssertEqual(receivedGuides.count, 1)
    }

    func test_onCreateLayoutGuide_notCalledForViews() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child = makeChildView(parent: parent)

        var callCount = 0

        parent.fx.hstack(
            Fix(child, 50).onCreateLayoutGuide { _ in
                callCount += 1
            }
        )

        // Should not be called for views (only spacers)
        XCTAssertEqual(callCount, 0)
    }
}

// MARK: - StackingResult Tests

class StackingResultTests: XCTestCase {
    func test_stackingResult_containsAllConstraints() {
        let parent = makeParentView(width: 200, height: 100)
        let child = makeChildView(parent: parent)

        let result = parent.fx.hstack(
            Fix(20),
            Fix(child, 80),
            Fix(20),
            Flex()
        )

        // Should have constraints for: spacer width, child width, spacer-to-start,
        // child-to-spacer, spacer2-to-child, flex-to-spacer2, flex-to-end
        XCTAssertGreaterThan(result.constraints.count, 0)
        XCTAssertTrue(result.constraints.allSatisfy { $0.isActive })
    }

    func test_stackingResult_layoutGuidesOnlyForSpacers() {
        let parent = makeParentView(width: 200, height: 100)
        let child = makeChildView(parent: parent)

        let result = parent.fx.hstack(
            Fix(20), // spacer -> guide
            Fix(child, 80), // view -> no guide
            Flex() // spacer -> guide
        )

        // Should have 2 layout guides (for the two spacers)
        XCTAssertEqual(result.layoutGuides.count, 2)
    }

    func test_stackingResult_layoutGuidesAddedToParent() {
        let parent = makeParentView(width: 200, height: 100)

        let result = parent.fx.hstack(
            Fix(20),
            Flex()
        )

        // Layout guides should be added to parent
        for guide in result.layoutGuides {
            XCTAssertEqual(guide.owningView, parent)
        }
    }
}

// MARK: - Parallel Views Tests

class ParallelViewsTests: XCTestCase {
    func test_parallelViews_allStartFromSameAnchor() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100
        let leadingSpacing: CGFloat = 15

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child1 = makeChildView(parent: parent)
        let child2 = makeChildView(parent: parent)
        let child3 = makeChildView(parent: parent)

        parent.fx.hstack(
            Fix(leadingSpacing),
            Flex([child1, child2, child3]),
            Fix(leadingSpacing)
        )

        parent.forceLayout()

        // All children should start at the same x position
        XCTAssertEqual(child1.frame.minX, leadingSpacing, accuracy: 0.01)
        XCTAssertEqual(child2.frame.minX, leadingSpacing, accuracy: 0.01)
        XCTAssertEqual(child3.frame.minX, leadingSpacing, accuracy: 0.01)

        // All children should have same width
        let expectedWidth = parentWidth - leadingSpacing * 2
        XCTAssertEqual(child1.frame.width, expectedWidth, accuracy: 0.01)
        XCTAssertEqual(child2.frame.width, expectedWidth, accuracy: 0.01)
        XCTAssertEqual(child3.frame.width, expectedWidth, accuracy: 0.01)
    }

    func test_parallelViews_withFix_allHaveSameDimension() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100
        let fixedHeight: CGFloat = 30

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child1 = makeChildView(parent: parent)
        let child2 = makeChildView(parent: parent)

        parent.fx.vstack(
            Fix([child1, child2], fixedHeight),
            Flex()
        )

        parent.forceLayout()

        XCTAssertEqual(child1.frame.height, fixedHeight, accuracy: 0.01)
        XCTAssertEqual(child2.frame.height, fixedHeight, accuracy: 0.01)
        XCTAssertEqual(child1.frame.minY, 0, accuracy: 0.01)
        XCTAssertEqual(child2.frame.minY, 0, accuracy: 0.01)
    }
}

// MARK: - Edge Cases Tests

class EdgeCasesTests: XCTestCase {
    func test_emptyViewsArray_treatedAsSpacer() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100

        let parent = makeParentView(width: parentWidth, height: parentHeight)

        // Empty array should be treated as spacer
        let result = parent.fx.hstack(
            Fix([], 30),
            Flex()
        )

        // Should create layout guide for empty array (treated as spacer)
        XCTAssertGreaterThan(result.layoutGuides.count, 0)
    }

    func test_singleViewArray_equivalentToSingleView() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100
        let viewWidth: CGFloat = 80

        let parent1 = makeParentView(width: parentWidth, height: parentHeight)
        let child1 = makeChildView(parent: parent1)

        let parent2 = makeParentView(width: parentWidth, height: parentHeight)
        let child2 = makeChildView(parent: parent2)

        parent1.fx.hstack(
            Fix(child1, viewWidth),
            Flex()
        )
        parent2.fx.hstack(
            Fix([child2], viewWidth),
            Flex()
        )

        parent1.forceLayout()
        parent2.forceLayout()

        // Both should produce same result
        XCTAssertEqual(child1.frame.width, child2.frame.width, accuracy: 0.01)
    }

    func test_combiningAllIntentTypes_worksCorrectly() {
        let parentWidth: CGFloat = 400
        let parentHeight: CGFloat = 100
        let fixSize: CGFloat = 30
        let fixViewWidth: CGFloat = 50
        let fillWeight: CGFloat = 1.0

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let fixedView = makeChildView(parent: parent)
        let flexView = makeChildView(parent: parent)
        let fillView = makeChildView(parent: parent)
        let matchView = makeChildView(parent: parent)

        // Use all intent types
        let result = parent.fx.hstack(
            Fix(fixSize), // Fixed spacer
            Fix(fixedView, fixViewWidth), // Fixed view
            Flex(flexView, min: 20), // Flex view with min
            Fill(fillView), // Fill view
            Match(matchView, dimension: fixedView.widthAnchor), // Match view
            Fill(weight: fillWeight) // Fill spacer
        )

        parent.forceLayout()

        // Verify basic expectations
        XCTAssertEqual(fixedView.frame.width, fixViewWidth, accuracy: 0.01)
        XCTAssertEqual(matchView.frame.width, fixViewWidth, accuracy: 0.01) // Matches fixedView
        XCTAssertGreaterThanOrEqual(flexView.frame.width, 20 - 0.01) // Min 20

        // Should have at least one layout guide (for the fixed spacer and fill spacer)
        XCTAssertGreaterThanOrEqual(result.layoutGuides.count, 2)
    }

    func test_zeroSizeIntent_createsZeroDimension() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100

        let parent = makeParentView(width: parentWidth, height: parentHeight)

        let result = parent.fx.hstack(
            Fix(0),
            Flex()
        )

        parent.forceLayout()

        // Zero-size spacer should have width 0
        XCTAssertEqual(result.layoutGuides[0]._layoutFrame.width, 0, accuracy: 0.01)
    }

    func test_largeNumberOfIntents_handlesCorrectly() {
        let parentWidth: CGFloat = 1000
        let parentHeight: CGFloat = 100
        let intentCount = 20
        let spacingPerIntent: CGFloat = 10

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        var children: [_View] = []
        var intents: [SizingIntent] = [Fix(spacingPerIntent)]

        for _ in 0 ..< intentCount {
            let child = makeChildView(parent: parent)
            children.append(child)
            intents.append(Fill(child))
            intents.append(Fix(spacingPerIntent))
        }

        parent.fx.hstack(intents)

        parent.forceLayout()

        // Available width for fill views
        // Total spacings: (intentCount + 1) * spacingPerIntent
        let totalSpacing = CGFloat(intentCount + 1) * spacingPerIntent
        let availableWidth = parentWidth - totalSpacing
        let expectedViewWidth = availableWidth / CGFloat(intentCount)

        for child in children {
            XCTAssertEqual(child.frame.width, expectedViewWidth, accuracy: 0.5)
        }
    }
}

// MARK: - Constraint Identifier Tests (DEBUG mode)

#if DEBUG
class ConstraintIdentifierTests: XCTestCase {
    func test_constraints_haveIdentifiersInDebugMode() {
        let parent = makeParentView(width: 200, height: 100)
        let child = makeChildView(parent: parent)

        let result = parent.fx.hstack(
            Fix(child, 50),
            Flex()
        )

        // In DEBUG mode, constraints should have identifiers
        for constraint in result.constraints {
            XCTAssertNotNil(constraint.identifier)
            XCTAssertTrue(constraint.identifier!.contains("FixFlex"))
        }
    }

    func test_constraints_useRawFileIDWhenMalformed() {
        let parent = makeParentView(width: 200, height: 100)
        let child = makeChildView(parent: parent)

        let customLine = 777
        let customFileID = ""

        let result = parent.fx.hstack(
            Fix(child, 40, fileID: customFileID, line: customLine),
            Flex()
        )

        // Identifiers should fall back to raw fileID when split fails
        let identifiers = result.constraints.compactMap { $0.identifier }
        XCTAssertFalse(identifiers.isEmpty)
        XCTAssertNotNil(identifiers.first { $0.contains("#\(customLine)") })
    }
}
#endif

// MARK: - Absolute Positioning Tests

class AbsolutePositioningTests: XCTestCase {
    func test_useAbsolutePositioning_usesLeftRightAnchors() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 100

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child = makeChildView(parent: parent)

        // With useAbsolutePositioning, should use left/right instead of leading/trailing
        let result = parent.fx.hstack(
            useAbsolutePositioning: true,
            Flex(child)
        )

        parent.forceLayout()

        // Child should still fill the width (behavior same, just different anchors used)
        XCTAssertEqual(child.frame.width, parentWidth, accuracy: 0.01)
        XCTAssertNotNil(result.constraints.constraint(between: child.leftAnchor, and: parent.leftAnchor))
        XCTAssertNotNil(result.constraints.constraint(between: child.rightAnchor, and: parent.rightAnchor))
        XCTAssertNil(result.constraints.constraint(between: child.leadingAnchor, and: parent.leadingAnchor))
        XCTAssertNil(result.constraints.constraint(between: child.trailingAnchor, and: parent.trailingAnchor))
    }

    func test_useAbsolutePositioning_forSpacerUsesLeftRightAnchors() {
        let parent = makeParentView(width: 200, height: 100)

        let result = parent.fx.hstack(
            useAbsolutePositioning: true,
            Fix(20)
        )

        guard let guide = result.layoutGuides.first else {
            return XCTFail("Expected spacer guide")
        }

        XCTAssertNotNil(result.constraints.constraint(between: guide.leftAnchor, and: parent.leftAnchor))
        XCTAssertNotNil(result.constraints.constraint(between: guide.rightAnchor, and: parent.rightAnchor))
        XCTAssertNil(result.constraints.constraint(between: guide.leadingAnchor, and: parent.leadingAnchor))
        XCTAssertNil(result.constraints.constraint(between: guide.trailingAnchor, and: parent.trailingAnchor))
    }
}

// MARK: - Combined hstack/vstack Tests

class CombinedStackingTests: XCTestCase {
    func test_combinedStacks_cellLayout() {
        let parentWidth: CGFloat = 300
        let parentHeight: CGFloat = 80
        let horizontalMargin: CGFloat = 15
        let iconSize: CGFloat = 44
        let chevronWidth: CGFloat = 20
        let verticalPadding: CGFloat = 10

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let iconView = makeChildView(parent: parent)
        let titleLabel = makeChildView(parent: parent)
        let subtitleLabel = makeChildView(parent: parent)
        let chevron = makeChildView(parent: parent)

        // Horizontal layout
        parent.fx.hstack(
            Fix(horizontalMargin),
            Fix(iconView, iconSize),
            Fix(horizontalMargin),
            Flex([titleLabel, subtitleLabel]),
            Fix(horizontalMargin),
            Fix(chevron, chevronWidth),
            Fix(horizontalMargin)
        )

        // Icon vertical: top padding + fixed size + flex bottom
        parent.fx.vstack(
            Fix(verticalPadding),
            Fix(iconView, iconSize),
            Flex()
        )

        // Labels vertical: padding + flex + padding
        parent.fx.vstack(
            Fix(verticalPadding),
            Flex(titleLabel),
            Flex(subtitleLabel),
            Fix(verticalPadding)
        )

        // Chevron: centered vertically
        let chevronHeight: CGFloat = 30
        parent.fx.vstack(
            Fill(),
            Fix(chevron, chevronHeight),
            Fill()
        )

        parent.forceLayout()

        // Verify icon position
        XCTAssertEqual(iconView.frame.minX, horizontalMargin, accuracy: 0.01)
        XCTAssertEqual(iconView.frame.width, iconSize, accuracy: 0.01)
        XCTAssertEqual(iconView.frame.height, iconSize, accuracy: 0.01)
        XCTAssertEqual(iconView.frame.minY, verticalPadding, accuracy: 0.01)

        // Verify labels horizontal position and width
        let labelsStartX = horizontalMargin + iconSize + horizontalMargin
        let labelsWidth = parentWidth - labelsStartX - horizontalMargin - chevronWidth - horizontalMargin
        XCTAssertEqual(titleLabel.frame.minX, labelsStartX, accuracy: 0.01)
        XCTAssertEqual(titleLabel.frame.width, labelsWidth, accuracy: 0.01)
        XCTAssertEqual(subtitleLabel.frame.minX, labelsStartX, accuracy: 0.01)
        XCTAssertEqual(subtitleLabel.frame.width, labelsWidth, accuracy: 0.01)

        // Verify chevron is centered vertically
        let expectedChevronY = (parentHeight - chevronHeight) / 2
        XCTAssertEqual(chevron.frame.minY, expectedChevronY, accuracy: 0.01)
        XCTAssertEqual(chevron.frame.height, chevronHeight, accuracy: 0.01)
    }

    func test_nestedViews_positionedCorrectly() {
        let parentWidth: CGFloat = 200
        let parentHeight: CGFloat = 200
        let margin: CGFloat = 20

        let parent = makeParentView(width: parentWidth, height: parentHeight)
        let child = makeChildView(parent: parent)

        parent.fx.hstack(
            Fix(margin),
            Flex(child),
            Fix(margin)
        )

        parent.fx.vstack(
            Fix(margin),
            Flex(child),
            Fix(margin)
        )

        parent.forceLayout()

        // Child should be inset by margin on all sides
        let expectedSize = parentWidth - margin * 2
        XCTAssertEqual(child.frame.minX, margin, accuracy: 0.01)
        XCTAssertEqual(child.frame.minY, margin, accuracy: 0.01)
        XCTAssertEqual(child.frame.width, expectedSize, accuracy: 0.01)
        XCTAssertEqual(child.frame.height, expectedSize, accuracy: 0.01)
    }
}
