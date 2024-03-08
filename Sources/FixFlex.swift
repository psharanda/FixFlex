#if os(macOS)
    import AppKit

    public typealias _View = NSView
    public typealias _LayoutGuide = NSLayoutGuide
    public typealias _LayoutPriority = NSLayoutConstraint.Priority
#else
    import UIKit

    public typealias _View = UIView
    public typealias _LayoutGuide = UILayoutGuide
    public typealias _LayoutPriority = UILayoutPriority
#endif

public struct FixFlexing {
    let base: _View
    init(_ base: _View) {
        self.base = base
    }
}

public extension _View {
    var fx: FixFlexing {
        return FixFlexing(self)
    }
}

public struct SizingIntent {
    let views: [_View]?

    enum Sizing {
        case fix(value: CGFloat)
        case flex(min: CGFloat?, max: CGFloat?, huggingPriority: _LayoutPriority?, compressionResistancePriority: _LayoutPriority?)
        case match(dimension: NSLayoutDimension, multiplier: CGFloat?, offset: CGFloat?)
        case fill(weight: CGFloat)
    }

    let sizing: Sizing

    var onCreateDimensionConstraint: ((NSLayoutConstraint) -> Void)?

    public func onCreateDimensionConstraint(_ block: @escaping (NSLayoutConstraint) -> Void) -> SizingIntent {
        var newSelf = self
        newSelf.onCreateDimensionConstraint = block
        return newSelf
    }
}

/// Fix shorthands

public func Fix(_ value: CGFloat) -> SizingIntent {
    return SizingIntent(views: nil, sizing: .fix(value: value))
}

public func Fix(_ view: _View, _ value: CGFloat) -> SizingIntent {
    return Fix([view], value)
}

public func Fix(_ views: [_View], _ value: CGFloat) -> SizingIntent {
    return SizingIntent(views: views, sizing: .fix(value: value))
}

/// Flex shorthands

public func Flex(min: CGFloat? = nil, max: CGFloat? = nil) -> SizingIntent {
    return SizingIntent(views: nil, sizing: .flex(min: min, max: max, huggingPriority: .required, compressionResistancePriority: .required))
}

public func Flex(_ view: _View, min: CGFloat? = nil, max: CGFloat? = nil, huggingPriority: _LayoutPriority? = nil, compressionResistancePriority: _LayoutPriority? = nil) -> SizingIntent {
    return Flex([view], min: min, max: max, huggingPriority: huggingPriority, compressionResistancePriority: compressionResistancePriority)
}

public func Flex(_ views: [_View], min: CGFloat? = nil, max: CGFloat? = nil, huggingPriority: _LayoutPriority? = nil, compressionResistancePriority: _LayoutPriority? = nil) -> SizingIntent {
    return SizingIntent(views: views, sizing: .flex(min: min, max: max, huggingPriority: huggingPriority, compressionResistancePriority: compressionResistancePriority))
}

/// Match shorthands

public func Match(dimension: NSLayoutDimension, multiplier: CGFloat? = nil, offset: CGFloat? = nil) -> SizingIntent {
    return SizingIntent(views: nil, sizing: .match(dimension: dimension, multiplier: multiplier, offset: offset))
}

public func Match(_ view: _View, dimension: NSLayoutDimension, multiplier: CGFloat? = nil, offset: CGFloat? = nil) -> SizingIntent {
    return Match([view], dimension: dimension, multiplier: multiplier, offset: offset)
}

public func Match(_ views: [_View], dimension: NSLayoutDimension, multiplier: CGFloat? = nil, offset: CGFloat? = nil) -> SizingIntent {
    return SizingIntent(views: views, sizing: .match(dimension: dimension, multiplier: multiplier, offset: offset))
}

/// Fill shorthands

public func Fill(weight: CGFloat = 1.0) -> SizingIntent {
    return SizingIntent(views: nil, sizing: .fill(weight: weight))
}

public func Fill(_ view: _View, weight: CGFloat = 1.0) -> SizingIntent {
    return Fill([view], weight: weight)
}

public func Fill(_ views: [_View], weight: CGFloat = 1.0) -> SizingIntent {
    return SizingIntent(views: views, sizing: .fill(weight: weight))
}

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
    func setContentCompressionResistancePriority(for view: _View, layoutPriority: _LayoutPriority)
}

private struct XAxisAnchorsBuilder: AxisAnchorsBuilder {
    typealias AnchorType = NSLayoutXAxisAnchor

    let useAbsolutePositioning: Bool
    init(useAbsolutePositioning: Bool) {
        self.useAbsolutePositioning = useAbsolutePositioning
    }

    func anchorsForView(_ view: _View) -> AxisAnchors<NSLayoutXAxisAnchor> {
        return AxisAnchors<NSLayoutXAxisAnchor>(startAnchor: useAbsolutePositioning ? view.leftAnchor : view.leadingAnchor,
                                                dimensionAnchor: view.widthAnchor,
                                                endAnchor: useAbsolutePositioning ? view.rightAnchor : view.trailingAnchor)
    }

    func anchorsForLayoutGuide(_ layoutGuide: _LayoutGuide) -> AxisAnchors<NSLayoutXAxisAnchor> {
        return AxisAnchors<NSLayoutXAxisAnchor>(startAnchor: useAbsolutePositioning ? layoutGuide.leftAnchor : layoutGuide.leadingAnchor,
                                                dimensionAnchor: layoutGuide.widthAnchor,
                                                endAnchor: useAbsolutePositioning ? layoutGuide.rightAnchor : layoutGuide.trailingAnchor)
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

public struct StackingResult {
    public let constraints: [NSLayoutConstraint]
    public let layoutGuides: [_LayoutGuide]
}

public extension FixFlexing {
    private func _stack<AnchorType: AnyObject, AxisAnchorsBuilderType: AxisAnchorsBuilder>(
        startAnchor: NSLayoutAnchor<AnchorType>,
        startOffset: CGFloat,
        endAnchor: NSLayoutAnchor<AnchorType>,
        endOffset: CGFloat,
        builder: AxisAnchorsBuilderType,
        intents: [SizingIntent]
    ) -> StackingResult where AxisAnchorsBuilderType.AnchorType == AnchorType {
        assert(intents.count > 0)

        guard intents.count > 0 else {
            return StackingResult(constraints: [], layoutGuides: [])
        }
        var lastAnchors = [startAnchor]
        var weightsInfo: (dimensionAnchor: NSLayoutDimension, weight: CGFloat)?
        var constraints: [NSLayoutConstraint] = []
        var layoutGuides: [_LayoutGuide] = []

        for intent in intents {
            let aas: [AxisAnchors<AnchorType>]

            if let views = intent.views, views.count > 0 {
                for view in views {
                    view.translatesAutoresizingMaskIntoConstraints = false
                }

                aas = views.map { view in
                    builder.anchorsForView(view)
                }
            } else {
                let layoutGuide = _LayoutGuide()
                layoutGuides.append(layoutGuide)
                base.addLayoutGuide(layoutGuide)
                aas = [builder.anchorsForLayoutGuide(layoutGuide)]
            }

            for aa in aas {
                for lastAnchor in lastAnchors {
                    constraints.append(aa.startAnchor.constraint(equalTo: lastAnchor,
                                                                 constant: lastAnchor === startAnchor ? startOffset : 0))
                }

                func handleSizingConstraint(_ constraint: NSLayoutConstraint) {
                    constraints.append(constraint)
                    intent.onCreateDimensionConstraint?(constraint)
                }

                switch intent.sizing {
                case let .fix(value):
                    handleSizingConstraint(aa.dimensionAnchor.constraint(equalToConstant: value))
                case let .flex(min, max, huggingPriority, compressionResistancePriority):

                    if let huggingPriority {
                        intent.views?.forEach {
                            builder.setContentHuggingPriority(for: $0, layoutPriority: huggingPriority)
                        }
                    }

                    if let compressionResistancePriority {
                        intent.views?.forEach {
                            builder.setContentCompressionResistancePriority(for: $0, layoutPriority: compressionResistancePriority)
                        }
                    }

                    if let min {
                        handleSizingConstraint(aa.dimensionAnchor.constraint(greaterThanOrEqualToConstant: min))
                    }
                    if let max {
                        handleSizingConstraint(aa.dimensionAnchor.constraint(lessThanOrEqualToConstant: max))
                    }
                case let .match(dimension, multiplier, offset):
                    handleSizingConstraint(aa.dimensionAnchor.constraint(equalTo: dimension, multiplier: multiplier ?? 1, constant: offset ?? 0))
                case let .fill(weight):
                    assert(weight >= 0)

                    let finalWeight = max(weight, 0)
                    if let weightsInfo {
                        handleSizingConstraint(aa.dimensionAnchor.constraint(equalTo: weightsInfo.dimensionAnchor,
                                                                             multiplier: finalWeight / weightsInfo.weight))
                    } else {
                        if finalWeight > 0 {
                            weightsInfo = (aa.dimensionAnchor, finalWeight)
                        } else {
                            handleSizingConstraint(aa.dimensionAnchor.constraint(equalToConstant: 0))
                        }
                    }
                }
            }
            lastAnchors = aas.map { $0.endAnchor }
        }

        for lastAnchor in lastAnchors {
            constraints.append(lastAnchor.constraint(equalTo: endAnchor, constant: endOffset))
        }

        NSLayoutConstraint.activate(constraints)

        return StackingResult(constraints: constraints, layoutGuides: layoutGuides)
    }

    @discardableResult
    func hstack(
        startAnchor: NSLayoutXAxisAnchor? = nil,
        startOffset: CGFloat = 0,
        endAnchor: NSLayoutXAxisAnchor? = nil,
        endOffset: CGFloat = 0,
        useAbsolutePositioning: Bool = false,
        _ intents: [SizingIntent]
    ) -> StackingResult {
        return _stack(startAnchor: startAnchor ?? (useAbsolutePositioning ? base.leftAnchor : base.leadingAnchor),
                      startOffset: startOffset,
                      endAnchor: endAnchor ?? (useAbsolutePositioning ? base.rightAnchor : base.trailingAnchor),
                      endOffset: endOffset,
                      builder: XAxisAnchorsBuilder(useAbsolutePositioning: useAbsolutePositioning),
                      intents: intents)
    }

    @discardableResult
    func hstack(
        startAnchor: NSLayoutXAxisAnchor? = nil,
        startOffset: CGFloat = 0,
        endAnchor: NSLayoutXAxisAnchor? = nil,
        endOffset: CGFloat = 0,
        useAbsolutePositioning: Bool = false,
        _ intents: SizingIntent...
    ) -> StackingResult {
        return hstack(startAnchor: startAnchor,
                      startOffset: startOffset,
                      endAnchor: endAnchor,
                      endOffset: endOffset,
                      useAbsolutePositioning: useAbsolutePositioning,
                      intents)
    }

    @discardableResult
    func vstack(
        startAnchor: NSLayoutYAxisAnchor? = nil,
        startOffset: CGFloat = 0,
        endAnchor: NSLayoutYAxisAnchor? = nil,
        endOffset: CGFloat = 0,
        _ intents: [SizingIntent]
    ) -> StackingResult {
        return _stack(startAnchor: startAnchor ?? base.topAnchor,
                      startOffset: startOffset,
                      endAnchor: endAnchor ?? base.bottomAnchor,
                      endOffset: endOffset,
                      builder: YAxisAnchorsBuilder(),
                      intents: intents)
    }

    @discardableResult
    func vstack(
        startAnchor: NSLayoutYAxisAnchor? = nil,
        startOffset: CGFloat = 0,
        endAnchor: NSLayoutYAxisAnchor? = nil,
        endOffset: CGFloat = 0,
        _ intents: SizingIntent...
    ) -> StackingResult {
        return vstack(startAnchor: startAnchor,
                      startOffset: startOffset,
                      endAnchor: endAnchor,
                      endOffset: endOffset,
                      intents)
    }
}
