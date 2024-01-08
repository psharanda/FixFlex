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

public struct PutIntent {
    let views: [_View]?

    enum Sizing {
        case fix(value: CGFloat)
        case flex(min: CGFloat?, max: CGFloat?, huggingPriority: _LayoutPriority?, compressionResistancePriority: _LayoutPriority?)
        case match(dimension: NSLayoutDimension, multiplier: CGFloat, offset: CGFloat)
        case split(weight: CGFloat)
    }

    let sizing: Sizing

    var onCreateDimensionConstraint: ((NSLayoutConstraint) -> Void)?

    public func onCreateDimensionConstraint(_ block: @escaping (NSLayoutConstraint) -> Void) -> PutIntent {
        var newSelf = self
        newSelf.onCreateDimensionConstraint = block
        return newSelf
    }
}

/// Fix shorthands

public func Fix(_ value: CGFloat) -> PutIntent {
    return PutIntent(views: nil, sizing: .fix(value: value))
}

public func Fix(_ view: _View, _ value: CGFloat) -> PutIntent {
    return Fix([view], value)
}

public func Fix(_ views: [_View], _ value: CGFloat) -> PutIntent {
    return PutIntent(views: views, sizing: .fix(value: value))
}

/// Flex shorthands

public func Flex(min: CGFloat? = nil, max: CGFloat? = nil) -> PutIntent {
    return PutIntent(views: nil, sizing: .flex(min: min, max: max, huggingPriority: .required, compressionResistancePriority: .required))
}

public func Flex(_ view: _View, min: CGFloat? = nil, max: CGFloat? = nil, huggingPriority: _LayoutPriority? = nil, compressionResistancePriority: _LayoutPriority? = nil) -> PutIntent {
    return Flex([view], min: min, max: max, huggingPriority: huggingPriority, compressionResistancePriority: compressionResistancePriority)
}

public func Flex(_ views: [_View], min: CGFloat? = nil, max: CGFloat? = nil, huggingPriority: _LayoutPriority? = nil, compressionResistancePriority: _LayoutPriority? = nil) -> PutIntent {
    return PutIntent(views: views, sizing: .flex(min: min, max: max, huggingPriority: huggingPriority, compressionResistancePriority: compressionResistancePriority))
}

/// Match shorthands

public func Match(dimension: NSLayoutDimension, multiplier: CGFloat = 1, offset: CGFloat = 0) -> PutIntent {
    return PutIntent(views: nil, sizing: .match(dimension: dimension, multiplier: multiplier, offset: offset))
}

public func Match(_ view: _View, dimension: NSLayoutDimension, multiplier: CGFloat = 1, offset: CGFloat = 0) -> PutIntent {
    return Match([view], dimension: dimension, multiplier: multiplier, offset: offset)
}

public func Match(_ views: [_View], dimension: NSLayoutDimension, multiplier: CGFloat = 1, offset: CGFloat = 0) -> PutIntent {
    return PutIntent(views: views, sizing: .match(dimension: dimension, multiplier: multiplier, offset: offset))
}

/// Split shorthands

public func Split(weight: CGFloat = 1.0) -> PutIntent {
    return PutIntent(views: nil, sizing: .split(weight: weight))
}

public func Split(_ view: _View, weight: CGFloat = 1.0) -> PutIntent {
    return Split([view], weight: weight)
}

public func Split(_ views: [_View], weight: CGFloat = 1.0) -> PutIntent {
    return PutIntent(views: views, sizing: .split(weight: weight))
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

public struct PutResult {
    public let constraints: [NSLayoutConstraint]
    public let layoutGuides: [_LayoutGuide]
}

public extension FixFlexing {
    private func _put<AnchorType: AnyObject, AxisAnchorsBuilderType: AxisAnchorsBuilder>(
        _ intents: [PutIntent],
        builder: AxisAnchorsBuilderType,
        startAnchor: NSLayoutAnchor<AnchorType>,
        endAnchor: NSLayoutAnchor<AnchorType>
    ) -> PutResult where AxisAnchorsBuilderType.AnchorType == AnchorType {
        var lastAnchors = [startAnchor]
        var weightsInfo: (dimensionAnchor: NSLayoutDimension, weight: CGFloat)?
        var constraints: [NSLayoutConstraint] = []
        var layoutGuides: [_LayoutGuide] = []

        for intent in intents {
            let aas: [AxisAnchors<AnchorType>]

            if let views = intent.views, views.count > 0 {
                views.forEach { view in
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
                    constraints.append(aa.startAnchor.constraint(equalTo: lastAnchor))
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
                    handleSizingConstraint(aa.dimensionAnchor.constraint(equalTo: dimension, multiplier: multiplier, constant: offset))
                case let .split(weight):
                    if let weightsInfo {
                        handleSizingConstraint(aa.dimensionAnchor.constraint(equalTo: weightsInfo.dimensionAnchor,
                                                                             multiplier: weight / weightsInfo.weight))
                    } else {
                        weightsInfo = (aa.dimensionAnchor, weight)
                    }
                }
            }
            lastAnchors = aas.map { $0.endAnchor }
        }

        lastAnchors.forEach {
            constraints.append($0.constraint(equalTo: endAnchor))
        }

        NSLayoutConstraint.activate(constraints)

        return PutResult(constraints: constraints, layoutGuides: layoutGuides)
    }

    @discardableResult
    func hput(
        startAnchor: NSLayoutXAxisAnchor? = nil,
        endAnchor: NSLayoutXAxisAnchor? = nil,
        useAbsolutePositioning: Bool = false,
        _ intents: [PutIntent]
    ) -> PutResult {
        return _put(intents,
                    builder: XAxisAnchorsBuilder(useAbsolutePositioning: useAbsolutePositioning),
                    startAnchor: startAnchor ?? (useAbsolutePositioning ? base.leftAnchor : base.leadingAnchor),
                    endAnchor: endAnchor ?? (useAbsolutePositioning ? base.rightAnchor : base.trailingAnchor))
    }

    @discardableResult
    func hput(
        startAnchor: NSLayoutXAxisAnchor? = nil,
        endAnchor: NSLayoutXAxisAnchor? = nil,
        useAbsolutePositioning: Bool = false,
        _ intents: PutIntent...
    ) -> PutResult {
        return hput(startAnchor: startAnchor, endAnchor: endAnchor, useAbsolutePositioning: useAbsolutePositioning, intents)
    }

    @discardableResult
    func vput(
        startAnchor: NSLayoutYAxisAnchor? = nil,
        endAnchor: NSLayoutYAxisAnchor? = nil,
        _ intents: [PutIntent]
    ) -> PutResult {
        return _put(intents,
                    builder: YAxisAnchorsBuilder(),
                    startAnchor: startAnchor ?? base.topAnchor,
                    endAnchor: endAnchor ?? base.bottomAnchor)
    }

    @discardableResult
    func vput(
        startAnchor: NSLayoutYAxisAnchor? = nil,
        endAnchor: NSLayoutYAxisAnchor? = nil,
        _ intents: PutIntent...
    ) -> PutResult {
        return vput(startAnchor: startAnchor, endAnchor: endAnchor, intents)
    }
}
