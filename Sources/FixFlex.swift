#if os(macOS)
import AppKit

/// Platform-agnostic view typealias (NSView on macOS, UIView elsewhere).
public typealias _View = NSView
/// Platform-agnostic layout guide typealias (NSLayoutGuide/UILayoutGuide).
public typealias _LayoutGuide = NSLayoutGuide
/// Platform-agnostic layout priority typealias.
public typealias _LayoutPriority = NSLayoutConstraint.Priority
#else
import UIKit

/// Platform-agnostic view typealias (NSView on macOS, UIView elsewhere).
public typealias _View = UIView
/// Platform-agnostic layout guide typealias (NSLayoutGuide/UILayoutGuide).
public typealias _LayoutGuide = UILayoutGuide
/// Platform-agnostic layout priority typealias.
public typealias _LayoutPriority = UILayoutPriority
#endif

/// Namespacing wrapper that exposes FixFlex helpers through the `fx` property.
public struct FixFlexing {
    let base: _View
    init(_ base: _View) {
        self.base = base
    }
}

public extension _View {
    /// Entrypoint to FixFlex stacking helpers (e.g. `view.fx.hstack(...)`).
    var fx: FixFlexing {
        return FixFlexing(self)
    }
}

/// Describes how FixFlex should size views or spacers within a stack.
public struct SizingIntent {
    let views: [_View]?
    #if DEBUG
    let fileID: String
    let line: Int
    #endif

    enum Sizing {
        case fix(value: CGFloat)
        case flex(
            min: CGFloat?,
            max: CGFloat?,
            huggingPriority: _LayoutPriority?,
            compressionResistancePriority: _LayoutPriority?
        )
        case match(
            dimension: NSLayoutDimension,
            multiplier: CGFloat,
            offset: CGFloat
        )
        case fill(weight: CGFloat)

        var asString: String {
            switch self {
            case .fix:
                return "Fix"
            case .flex:
                return "Flex"
            case .match:
                return "Match"
            case .fill:
                return "Fill"
            }
        }
    }

    let sizing: Sizing

    #if DEBUG
    init(views: [_View]?, sizing: Sizing, fileID: String, line: Int) {
        self.views = views
        self.sizing = sizing
        self.fileID = fileID
        self.line = line
    }
    #else
    init(views: [_View]?, sizing: Sizing) {
        self.views = views
        self.sizing = sizing
    }
    #endif

    var spacingBefore: CGFloat = 0

    /// Adds custom spacing before this intent (negative values allow overlaps).
    /// - Parameter value: Additional spacing inserted before the intent in the stack (default 0).
    /// - Returns: New intent with updated spacing.
    public func spacingBefore(_ value: CGFloat) -> SizingIntent {
        var newSelf = self
        newSelf.spacingBefore = value
        return newSelf
    }

    var onCreateDimensionConstraint: ((NSLayoutConstraint) -> Void)?

    /// Callback for adjusting each dimension constraint created for this intent.
    /// - Parameter block: Invoked with every created dimension constraint (e.g., width/height).
    /// - Returns: New intent with the callback registered.
    public func onCreateDimensionConstraint(
        _ block: @escaping (NSLayoutConstraint) -> Void
    ) -> SizingIntent {
        var newSelf = self
        newSelf.onCreateDimensionConstraint = block
        return newSelf
    }

    var onCreateStartConstraint: ((NSLayoutConstraint) -> Void)?

    /// Callback for tweaking constraints that pin this intent to the previous anchor.
    /// - Parameter block: Invoked with each start constraint between the prior anchor and this intent.
    /// - Returns: New intent with the callback registered.
    public func onCreateStartConstraint(
        _ block: @escaping (NSLayoutConstraint) -> Void
    ) -> SizingIntent {
        var newSelf = self
        newSelf.onCreateStartConstraint = block
        return newSelf
    }

    var onCreateEndConstraint: ((NSLayoutConstraint) -> Void)?

    /// Callback for tweaking the constraint that pins the final intent to the end anchor.
    /// - Parameter block: Invoked with the closing constraint that ties the last intent to the end anchor.
    /// - Returns: New intent with the callback registered.
    public func onCreateEndConstraint(
        _ block: @escaping (NSLayoutConstraint) -> Void
    ) -> SizingIntent {
        var newSelf = self
        newSelf.onCreateEndConstraint = block
        return newSelf
    }

    var onCreateLayoutGuide: ((_LayoutGuide) -> Void)?

    /// Callback that exposes the generated layout guide for spacers/fills.
    /// - Parameter block: Invoked with the created layout guide so callers can configure it.
    /// - Returns: New intent with the callback registered.
    public func onCreateLayoutGuide(
        _ block: @escaping (_LayoutGuide) -> Void
    ) -> SizingIntent {
        var newSelf = self
        newSelf.onCreateLayoutGuide = block
        return newSelf
    }
}

// MARK: - Fix

/// Creates a fixed-size spacer layout guide.
/// - Parameter value: Constant size in points for the spacer.
/// - Returns: A sizing intent describing the fixed spacer.
#if DEBUG
public func Fix(
    _ value: CGFloat,
    fileID: String = #fileID,
    line: Int = #line
) -> SizingIntent {
    return SizingIntent(
        views: nil,
        sizing: .fix(value: value),
        fileID: fileID,
        line: line
    )
}
#else
public func Fix(_ value: CGFloat) -> SizingIntent {
    return SizingIntent(views: nil, sizing: .fix(value: value))
}
#endif

/// Constrains the provided view to a fixed size in the stacking axis.
/// - Parameters:
///   - view: View to constrain.
///   - value: Constant size in points for the stacking axis.
/// - Returns: A sizing intent describing the fixed view size.
#if DEBUG
public func Fix(
    _ view: _View,
    _ value: CGFloat,
    fileID: String = #fileID,
    line: Int = #line
) -> SizingIntent {
    return Fix([view], value, fileID: fileID, line: line)
}
#else
public func Fix(_ view: _View, _ value: CGFloat) -> SizingIntent {
    return Fix([view], value)
}
#endif

/// Constrains all provided views to a fixed size in the stacking axis.
/// - Parameters:
///   - views: Views to constrain.
///   - value: Constant size in points for the stacking axis.
/// - Returns: A sizing intent describing the fixed view sizes.
#if DEBUG
public func Fix(
    _ views: [_View],
    _ value: CGFloat,
    fileID: String = #fileID,
    line: Int = #line
) -> SizingIntent {
    return SizingIntent(
        views: views,
        sizing: .fix(value: value),
        fileID: fileID,
        line: line
    )
}
#else
public func Fix(_ views: [_View], _ value: CGFloat) -> SizingIntent {
    return SizingIntent(views: views, sizing: .fix(value: value))
}
#endif

// MARK: - Flex

/// Creates a flexible spacer guide with optional min/max constraints.
/// - Parameters:
///   - min: Optional lower bound on the spacer size (default `nil` for no bound).
///   - max: Optional upper bound on the spacer size (default `nil` for no bound).
/// - Returns: A sizing intent describing a flexible spacer.
#if DEBUG
public func Flex(
    min: CGFloat? = nil,
    max: CGFloat? = nil,
    fileID: String = #fileID,
    line: Int = #line
) -> SizingIntent {
    return SizingIntent(
        views: nil,
        sizing: .flex(
            min: min,
            max: max,
            huggingPriority: .required,
            compressionResistancePriority: .required
        ),
        fileID: fileID,
        line: line
    )
}
#else
public func Flex(
    min: CGFloat? = nil,
    max: CGFloat? = nil
) -> SizingIntent {
    return SizingIntent(
        views: nil,
        sizing: .flex(
            min: min,
            max: max,
            huggingPriority: .required,
            compressionResistancePriority: .required
        )
    )
}
#endif

/// Makes the view flexible within the stack, optionally constraining and adjusting priorities.
/// - Parameters:
///   - view: View to size flexibly.
///   - min: Optional lower bound on the view size (default `nil`).
///   - max: Optional upper bound on the view size (default `nil`).
///   - huggingPriority: Optional hugging priority to apply on the stacking axis (default `nil` leaves existing).
///   - compressionResistancePriority: Optional compression resistance to apply on the stacking axis (default `nil` leaves existing).
/// - Returns: A sizing intent describing a flexible view.
#if DEBUG
public func Flex(
    _ view: _View,
    min: CGFloat? = nil,
    max: CGFloat? = nil,
    huggingPriority: _LayoutPriority? = nil,
    compressionResistancePriority: _LayoutPriority? = nil,
    fileID: String = #fileID,
    line: Int = #line
) -> SizingIntent {
    return Flex(
        [view], min: min,
        max: max,
        huggingPriority: huggingPriority,
        compressionResistancePriority: compressionResistancePriority,
        fileID: fileID,
        line: line
    )
}
#else
public func Flex(
    _ view: _View,
    min: CGFloat? = nil,
    max: CGFloat? = nil,
    huggingPriority: _LayoutPriority? = nil,
    compressionResistancePriority: _LayoutPriority? = nil
) -> SizingIntent {
    return Flex(
        [view],
        min: min,
        max: max,
        huggingPriority: huggingPriority,
        compressionResistancePriority: compressionResistancePriority
    )
}
#endif

/// Makes the views flexible in parallel, optionally constraining and adjusting priorities.
/// - Parameters:
///   - views: Views to size flexibly in parallel.
///   - min: Optional lower bound on each view size (default `nil`).
///   - max: Optional upper bound on each view size (default `nil`).
///   - huggingPriority: Optional hugging priority to apply on the stacking axis (default `nil` leaves existing).
///   - compressionResistancePriority: Optional compression resistance to apply on the stacking axis (default `nil` leaves existing).
/// - Returns: A sizing intent describing flexible parallel views.
#if DEBUG
public func Flex(
    _ views: [_View],
    min: CGFloat? = nil,
    max: CGFloat? = nil,
    huggingPriority: _LayoutPriority? = nil,
    compressionResistancePriority: _LayoutPriority? = nil,
    fileID: String = #fileID,
    line: Int = #line
) -> SizingIntent {
    return SizingIntent(
        views: views,
        sizing: .flex(
            min: min,
            max: max,
            huggingPriority: huggingPriority,
            compressionResistancePriority: compressionResistancePriority
        ),
        fileID: fileID,
        line: line
    )
}
#else
public func Flex(
    _ views: [_View],
    min: CGFloat? = nil,
    max: CGFloat? = nil,
    huggingPriority: _LayoutPriority? = nil,
    compressionResistancePriority: _LayoutPriority? = nil
) -> SizingIntent {
    return SizingIntent(
        views: views,
        sizing: .flex(
            min: min,
            max: max,
            huggingPriority: huggingPriority,
            compressionResistancePriority: compressionResistancePriority
        )
    )
}
#endif

// MARK: - Match

/// Matches a spacer guide dimension to another layout dimension.
/// - Parameters:
///   - dimension: Dimension to match (width/height anchor).
///   - multiplier: Multiplier for proportional sizing (default 1).
///   - offset: Constant added after multiplication (default 0).
/// - Returns: A sizing intent describing the matched spacer.
/// - Note: Effective size is resolved as `otherDimension * multiplier + offset`.
#if DEBUG
public func Match(
    dimension: NSLayoutDimension,
    multiplier: CGFloat = 1,
    offset: CGFloat = 0,
    fileID: String = #fileID,
    line: Int = #line
) -> SizingIntent {
    return SizingIntent(
        views: nil,
        sizing: .match(
            dimension: dimension,
            multiplier: multiplier,
            offset: offset
        ),
        fileID: fileID,
        line: line
    )
}
#else
public func Match(
    dimension: NSLayoutDimension,
    multiplier: CGFloat = 1,
    offset: CGFloat = 0
) -> SizingIntent {
    return SizingIntent(
        views: nil,
        sizing: .match(
            dimension: dimension,
            multiplier: multiplier,
            offset: offset
        )
    )
}
#endif

/// Matches the view dimension to another layout dimension.
/// - Parameters:
///   - view: View whose dimension is matched.
///   - dimension: Dimension to match (width/height anchor).
///   - multiplier: Multiplier for proportional sizing (default 1).
///   - offset: Constant added after multiplication (default 0).
/// - Returns: A sizing intent describing the matched view.
/// - Note: Effective size is resolved as `otherDimension * multiplier + offset`.
#if DEBUG
public func Match(
    _ view: _View,
    dimension: NSLayoutDimension,
    multiplier: CGFloat = 1,
    offset: CGFloat = 0,
    fileID: String = #fileID,
    line: Int = #line
) -> SizingIntent {
    return Match(
        [view],
        dimension: dimension,
        multiplier: multiplier,
        offset: offset,
        fileID: fileID,
        line: line
    )
}
#else
public func Match(
    _ view: _View,
    dimension: NSLayoutDimension,
    multiplier: CGFloat = 1,
    offset: CGFloat = 0
) -> SizingIntent {
    return Match(
        [view],
        dimension: dimension,
        multiplier: multiplier,
        offset: offset
    )
}
#endif

/// Matches all provided views to another layout dimension.
/// - Parameters:
///   - views: Views whose dimensions are matched in parallel.
///   - dimension: Dimension to match (width/height anchor).
///   - multiplier: Multiplier for proportional sizing (default 1).
///   - offset: Constant added after multiplication (default 0).
/// - Returns: A sizing intent describing matched parallel views.
/// - Note: Effective size is resolved as `otherDimension * multiplier + offset`.
#if DEBUG
public func Match(
    _ views: [_View],
    dimension: NSLayoutDimension,
    multiplier: CGFloat = 1,
    offset: CGFloat = 0,
    fileID: String = #fileID,
    line: Int = #line
) -> SizingIntent {
    return SizingIntent(
        views: views,
        sizing: .match(
            dimension: dimension,
            multiplier: multiplier,
            offset: offset
        ),
        fileID: fileID,
        line: line
    )
}
#else
public func Match(
    _ views: [_View],
    dimension: NSLayoutDimension,
    multiplier: CGFloat = 1,
    offset: CGFloat = 0
) -> SizingIntent {
    return SizingIntent(
        views: views,
        sizing: .match(
            dimension: dimension,
            multiplier: multiplier,
            offset: offset
        )
    )
}
#endif

// MARK: - Fill

/// Creates a weighted spacer that shares remaining space with other fills.
/// - Parameter weight: Proportional weight for distributing remaining space (default 1.0; 0 collapses the spacer).
/// - Returns: A sizing intent describing the weighted spacer.
#if DEBUG
public func Fill(
    weight: CGFloat = 1.0,
    fileID: String = #fileID,
    line: Int = #line
) -> SizingIntent {
    return SizingIntent(
        views: nil,
        sizing: .fill(weight: weight),
        fileID: fileID,
        line: line
    )
}
#else
public func Fill(weight: CGFloat = 1.0) -> SizingIntent {
    return SizingIntent(views: nil, sizing: .fill(weight: weight))
}
#endif

/// Makes the view occupy remaining space proportionally to the provided weight.
/// - Parameters:
///   - view: View to fill remaining space.
///   - weight: Proportional weight for distributing remaining space (default 1.0; 0 collapses the view dimension).
/// - Returns: A sizing intent describing the weighted view.
#if DEBUG
public func Fill(
    _ view: _View,
    weight: CGFloat = 1.0,
    fileID: String = #fileID,
    line: Int = #line
) -> SizingIntent {
    return Fill(
        [view],
        weight: weight,
        fileID: fileID,
        line: line
    )
}
#else
public func Fill(_ view: _View, weight: CGFloat = 1.0) -> SizingIntent {
    return Fill([view], weight: weight)
}
#endif

/// Makes the views occupy remaining space in parallel with a shared weight.
/// - Parameters:
///   - views: Views to fill remaining space in parallel.
///   - weight: Proportional weight for distributing remaining space (default 1.0; 0 collapses each view dimension).
/// - Returns: A sizing intent describing weighted parallel views.
#if DEBUG
public func Fill(
    _ views: [_View],
    weight: CGFloat = 1.0,
    fileID: String = #fileID,
    line: Int = #line
) -> SizingIntent {
    return SizingIntent(
        views: views,
        sizing: .fill(weight: weight),
        fileID: fileID,
        line: line
    )
}
#else
public func Fill(_ views: [_View], weight: CGFloat = 1.0) -> SizingIntent {
    return SizingIntent(views: views, sizing: .fill(weight: weight))
}
#endif

/// Axis anchors abstraction

private struct AxisAnchors<AnchorType: AnyObject> {
    let startAnchor: NSLayoutAnchor<AnchorType>
    let dimensionAnchor: NSLayoutDimension
    let endAnchor: NSLayoutAnchor<AnchorType>
}

private protocol AxisAnchorsBuilder {
    associatedtype AnchorType: AnyObject
    func anchorsForView(_ view: _View) -> AxisAnchors<AnchorType>
    func anchorsForLayoutGuide(_ layoutGuide: _LayoutGuide) -> AxisAnchors<AnchorType>
    func setContentHuggingPriority(for view: _View, layoutPriority: _LayoutPriority)
    func setContentCompressionResistancePriority(
        for view: _View,
        layoutPriority: _LayoutPriority
    )
}

private struct XAxisAnchorsBuilder: AxisAnchorsBuilder {
    typealias AnchorType = NSLayoutXAxisAnchor

    let useAbsolutePositioning: Bool
    init(useAbsolutePositioning: Bool) {
        self.useAbsolutePositioning = useAbsolutePositioning
    }

    func anchorsForView(_ view: _View) -> AxisAnchors<NSLayoutXAxisAnchor> {
        return AxisAnchors<NSLayoutXAxisAnchor>(
            startAnchor: useAbsolutePositioning ? view.leftAnchor : view.leadingAnchor,
            dimensionAnchor: view.widthAnchor,
            endAnchor: useAbsolutePositioning ? view.rightAnchor : view.trailingAnchor
        )
    }

    func anchorsForLayoutGuide(_ layoutGuide: _LayoutGuide) -> AxisAnchors<NSLayoutXAxisAnchor> {
        return AxisAnchors<NSLayoutXAxisAnchor>(
            startAnchor: useAbsolutePositioning ? layoutGuide.leftAnchor : layoutGuide.leadingAnchor,
            dimensionAnchor: layoutGuide.widthAnchor,
            endAnchor: useAbsolutePositioning ? layoutGuide.rightAnchor : layoutGuide.trailingAnchor
        )
    }

    func setContentHuggingPriority(for view: _View, layoutPriority: _LayoutPriority) {
        view.setContentHuggingPriority(layoutPriority, for: .horizontal)
    }

    func setContentCompressionResistancePriority(for view: _View, layoutPriority: _LayoutPriority) {
        view.setContentCompressionResistancePriority(layoutPriority, for: .horizontal)
    }
}

private struct YAxisAnchorsBuilder: AxisAnchorsBuilder {
    typealias AnchorType = NSLayoutYAxisAnchor

    func anchorsForView(_ view: _View) -> AxisAnchors<NSLayoutYAxisAnchor> {
        return AxisAnchors<NSLayoutYAxisAnchor>(startAnchor: view.topAnchor,
                                                dimensionAnchor: view.heightAnchor,
                                                endAnchor: view.bottomAnchor)
    }

    func anchorsForLayoutGuide(_ layoutGuide: _LayoutGuide) -> AxisAnchors<NSLayoutYAxisAnchor> {
        return AxisAnchors<NSLayoutYAxisAnchor>(startAnchor: layoutGuide.topAnchor,
                                                dimensionAnchor: layoutGuide.heightAnchor,
                                                endAnchor: layoutGuide.bottomAnchor)
    }

    func setContentHuggingPriority(for view: _View, layoutPriority: _LayoutPriority) {
        view.setContentHuggingPriority(layoutPriority, for: .vertical)
    }

    func setContentCompressionResistancePriority(for view: _View, layoutPriority: _LayoutPriority) {
        view.setContentCompressionResistancePriority(layoutPriority, for: .vertical)
    }
}

/// Result object containing everything created during a stack operation.
public struct StackingResult {
    /// Constraints activated for the stack.
    public let constraints: [NSLayoutConstraint]
    /// Layout guides generated for spacers and fills.
    public let layoutGuides: [_LayoutGuide]
}

public extension FixFlexing {
    private func _stack<AnchorType: AnyObject, AxisAnchorsBuilderType: AxisAnchorsBuilder>(
        startAnchor: NSLayoutAnchor<AnchorType>,
        startOffset: CGFloat?,
        endAnchor: NSLayoutAnchor<AnchorType>,
        endOffset: CGFloat?,
        axisName: String,
        builder: AxisAnchorsBuilderType,
        intents: [SizingIntent]
    ) -> StackingResult where AxisAnchorsBuilderType.AnchorType == AnchorType {
        guard intents.count > 0 else {
            return StackingResult(
                constraints: [],
                layoutGuides: []
            )
        }

        #if DEBUG
        func constraintIdentifier(
            sizing: SizingIntent.Sizing,
            section: String,
            intentIndex: Int,
            targetIndex: Int,
            fileID: String,
            line: Int
        ) -> String {
            let fileName = fileID.split(separator: "/").last.map(String.init) ?? fileID
            let label = "\(fileName)#\(line)"
            return "FixFlex.\(axisName)[\(intentIndex)].\(sizing.asString).\(section)[\(targetIndex)] \(label)"
        }
        #else
        _ = axisName
        #endif

        var lastAnchors = startOffset != nil ? [startAnchor] : []
        var weightsInfo: (dimensionAnchor: NSLayoutDimension, weight: CGFloat)?
        var constraints: [NSLayoutConstraint] = []
        var layoutGuides: [_LayoutGuide] = []

        for (intentIndex, intent) in intents.enumerated() {
            let axisAnchorsList: [AxisAnchors<AnchorType>]

            if let views = intent.views, views.count > 0 {
                for view in views {
                    view.translatesAutoresizingMaskIntoConstraints = false
                }

                axisAnchorsList = views.map { view in
                    builder.anchorsForView(view)
                }
            } else {
                let layoutGuide = _LayoutGuide()
                layoutGuides.append(layoutGuide)
                base.addLayoutGuide(layoutGuide)
                intent.onCreateLayoutGuide?(layoutGuide)
                axisAnchorsList = [builder.anchorsForLayoutGuide(layoutGuide)]
            }

            for (index, axisAnchors) in axisAnchorsList.enumerated() {
                for lastAnchor in lastAnchors {
                    let startConstant = (lastAnchor === startAnchor ? startOffset ?? 0 : 0) + intent.spacingBefore
                    let constraint = axisAnchors.startAnchor.constraint(
                        equalTo: lastAnchor,
                        constant: startConstant
                    )
                    #if DEBUG
                    constraint.identifier = constraintIdentifier(
                        sizing: intent.sizing,
                        section: "start",
                        intentIndex: intentIndex,
                        targetIndex: index,
                        fileID: intent.fileID,
                        line: intent.line
                    )
                    #endif

                    constraints.append(constraint)
                    intent.onCreateStartConstraint?(constraint)
                }

                func handleSizingConstraint(_ constraint: NSLayoutConstraint) {
                    #if DEBUG
                    constraint.identifier = constraintIdentifier(
                        sizing: intent.sizing,
                        section: "dimension",
                        intentIndex: intentIndex,
                        targetIndex: index,
                        fileID: intent.fileID,
                        line: intent.line
                    )
                    #endif
                    constraints.append(constraint)
                    intent.onCreateDimensionConstraint?(constraint)
                }

                switch intent.sizing {
                case let .fix(value):
                    handleSizingConstraint(
                        axisAnchors.dimensionAnchor.constraint(equalToConstant: value)
                    )
                case let .flex(min, max, huggingPriority, compressionResistancePriority):

                    if let huggingPriority {
                        intent.views?.forEach {
                            builder.setContentHuggingPriority(
                                for: $0,
                                layoutPriority: huggingPriority
                            )
                        }
                    }

                    if let compressionResistancePriority {
                        intent.views?.forEach {
                            builder.setContentCompressionResistancePriority(
                                for: $0,
                                layoutPriority: compressionResistancePriority
                            )
                        }
                    }
                    if let min {
                        handleSizingConstraint(
                            axisAnchors.dimensionAnchor.constraint(greaterThanOrEqualToConstant: min)
                        )
                    }
                    if let max {
                        handleSizingConstraint(
                            axisAnchors.dimensionAnchor.constraint(lessThanOrEqualToConstant: max)
                        )
                    }
                case let .match(dimension, multiplier, offset):
                    handleSizingConstraint(
                        axisAnchors.dimensionAnchor.constraint(
                            equalTo: dimension,
                            multiplier: multiplier,
                            constant: offset
                        )
                    )
                case let .fill(weight):
                    assert(weight >= 0)

                    let finalWeight = max(weight, 0)
                    if let weightsInfo {
                        handleSizingConstraint(
                            axisAnchors.dimensionAnchor.constraint(
                                equalTo: weightsInfo.dimensionAnchor,
                                multiplier: finalWeight / weightsInfo.weight
                            )
                        )
                    } else {
                        if finalWeight > 0 {
                            weightsInfo = (axisAnchors.dimensionAnchor, finalWeight)
                        } else {
                            handleSizingConstraint(
                                axisAnchors.dimensionAnchor.constraint(equalToConstant: 0)
                            )
                        }
                    }
                }
            }
            // Track end anchors from all parallel views so the next intent chains from each of them
            lastAnchors = axisAnchorsList.map { $0.endAnchor }
        }

        if let endOffset {
            for (lastAnchorIndex, lastAnchor) in lastAnchors.enumerated() {
                let constraint = lastAnchor.constraint(equalTo: endAnchor, constant: endOffset)
                let lastIntent = intents.last!
                #if DEBUG
                constraint.identifier = constraintIdentifier(
                    sizing: lastIntent.sizing,
                    section: "end",
                    intentIndex: intents.count - 1,
                    targetIndex: lastAnchorIndex,
                    fileID: lastIntent.fileID,
                    line: lastIntent.line
                )
                #endif
                constraints.append(constraint)
                lastIntent.onCreateEndConstraint?(constraint)
            }
        }

        NSLayoutConstraint.activate(constraints)

        return StackingResult(
            constraints: constraints,
            layoutGuides: layoutGuides
        )
    }

    /// Stacks intents horizontally using leading/trailing anchors by default (mirrors in RTL).
    /// Pass `useAbsolutePositioning` to force left/right anchors or set `startOffset`/`endOffset` to `nil` to leave a side unpinned.
    /// - Parameters:
    ///   - startAnchor: Custom anchor to begin stacking from (default `base.leadingAnchor`/`leftAnchor`).
    ///   - startOffset: Spacing from the start anchor (default 0); `nil` skips pinning to start.
    ///   - endAnchor: Custom anchor to end stacking at (default `base.trailingAnchor`/`rightAnchor`).
    ///   - endOffset: Spacing to the end anchor (default 0); `nil` skips pinning to end.
    ///   - useAbsolutePositioning: If true uses left/right anchors to force LTR layout (default false).
    ///   - intents: Collection of sizing intents in order.
    /// - Returns: StackingResult containing generated constraints and layout guides.
    @discardableResult
    func hstack(
        startAnchor: NSLayoutXAxisAnchor? = nil,
        startOffset: CGFloat? = 0,
        endAnchor: NSLayoutXAxisAnchor? = nil,
        endOffset: CGFloat? = 0,
        useAbsolutePositioning: Bool = false,
        _ intents: [SizingIntent]
    ) -> StackingResult {
        return _stack(
            startAnchor: startAnchor ?? (useAbsolutePositioning ? base.leftAnchor : base.leadingAnchor),
            startOffset: startOffset,
            endAnchor: endAnchor ?? (useAbsolutePositioning ? base.rightAnchor : base.trailingAnchor),
            endOffset: endOffset,
            axisName: "hstack",
            builder: XAxisAnchorsBuilder(useAbsolutePositioning: useAbsolutePositioning),
            intents: intents
        )
    }

    /// Convenience varargs overload for `hstack`.
    /// Stacks intents horizontally using leading/trailing anchors by default (mirrors in RTL).
    /// Pass `useAbsolutePositioning` to force left/right anchors or set `startOffset`/`endOffset` to `nil` to leave a side unpinned.
    /// - Parameters:
    ///   - startAnchor: Custom anchor to begin stacking from (default `base.leadingAnchor`/`leftAnchor`).
    ///   - startOffset: Spacing from the start anchor (default 0); `nil` skips pinning to start.
    ///   - endAnchor: Custom anchor to end stacking at (default `base.trailingAnchor`/`rightAnchor`).
    ///   - endOffset: Spacing to the end anchor (default 0); `nil` skips pinning to end.
    ///   - useAbsolutePositioning: If true uses left/right anchors to force LTR layout (default false).
    ///   - intents: Collection of sizing intents in order.
    /// - Returns: StackingResult containing generated constraints and layout guides.
    @discardableResult
    func hstack(
        startAnchor: NSLayoutXAxisAnchor? = nil,
        startOffset: CGFloat? = 0,
        endAnchor: NSLayoutXAxisAnchor? = nil,
        endOffset: CGFloat? = 0,
        useAbsolutePositioning: Bool = false,
        _ intents: SizingIntent...
    ) -> StackingResult {
        return hstack(
            startAnchor: startAnchor,
            startOffset: startOffset,
            endAnchor: endAnchor,
            endOffset: endOffset,
            useAbsolutePositioning: useAbsolutePositioning,
            intents
        )
    }

    /// Stacks intents vertically between the provided anchors; `startOffset`/`endOffset` can be `nil` to allow overflow.
    /// - Parameters:
    ///   - startAnchor: Custom anchor to begin stacking from (default `base.topAnchor`).
    ///   - startOffset: Spacing from the start anchor (default 0); `nil` skips pinning to start.
    ///   - endAnchor: Custom anchor to end stacking at (default `base.bottomAnchor`).
    ///   - endOffset: Spacing to the end anchor (default 0); `nil` skips pinning to end.
    ///   - intents: Collection of sizing intents in order.
    /// - Returns: StackingResult containing generated constraints and layout guides.
    @discardableResult
    func vstack(
        startAnchor: NSLayoutYAxisAnchor? = nil,
        startOffset: CGFloat? = 0,
        endAnchor: NSLayoutYAxisAnchor? = nil,
        endOffset: CGFloat? = 0,
        _ intents: [SizingIntent]
    ) -> StackingResult {
        return _stack(
            startAnchor: startAnchor ?? base.topAnchor,
            startOffset: startOffset,
            endAnchor: endAnchor ?? base.bottomAnchor,
            endOffset: endOffset,
            axisName: "vstack",
            builder: YAxisAnchorsBuilder(),
            intents: intents
        )
    }

    /// Convenience varargs overload for `vstack`.
    /// Stacks intents vertically between the provided anchors; `startOffset`/`endOffset` can be `nil` to allow overflow.
    /// - Parameters:
    ///   - startAnchor: Custom anchor to begin stacking from (default `base.topAnchor`).
    ///   - startOffset: Spacing from the start anchor (default 0); `nil` skips pinning to start.
    ///   - endAnchor: Custom anchor to end stacking at (default `base.bottomAnchor`).
    ///   - endOffset: Spacing to the end anchor (default 0); `nil` skips pinning to end.
    ///   - intents: Collection of sizing intents in order.
    /// - Returns: StackingResult containing generated constraints and layout guides.
    @discardableResult
    func vstack(
        startAnchor: NSLayoutYAxisAnchor? = nil,
        startOffset: CGFloat? = 0,
        endAnchor: NSLayoutYAxisAnchor? = nil,
        endOffset: CGFloat? = 0,
        _ intents: SizingIntent...
    ) -> StackingResult {
        return vstack(
            startAnchor: startAnchor,
            startOffset: startOffset,
            endAnchor: endAnchor,
            endOffset: endOffset,
            intents
        )
    }
}
