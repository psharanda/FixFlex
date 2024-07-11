<p align="center">
<img src="Readme/static/logo.png" width="50%" alt="FixFlex Logo" />
</p>
      
`FixFlex` is a simple yet powerful Auto Layout library built on top of the NSLayoutAnchor API, a swifty and type-safe reimagination of [Visual Format Language](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/VisualFormatLanguage.html)

## Features

- Declarative Auto Layout code that is easy to write, read, and modify
- Simple API with 2 functions and 4 specifiers, covering 99% of layout use cases
- Implementation is only 300 lines of code
- Compatible with any other Auto Layout code
- Basically generates a bunch of activated `NSLayoutConstraint` and `UILayoutGuide`
- Keeps your view hierarchy flat, no need for exta containers
- Lightweight alternative to `UIStackView`
- Super straightforward mental model
- Typesafe alternative to VFL
- Dynamic Type and Right-To-Left friendly
- Automatically sets `translatesAutoresizingMaskIntoConstraints` to false
- Supports iOS 12.0+ / Mac OS X 10.13+ / tvOS 12.0+

## Usage

Imagine we want to create a layout like this:

<img class="snapshot"
     src="FixFlexSamples/Ref/ReferenceImages_64/FixFlexSamplesTests.FixFlexTests/test_CellWithIconTitleSubtitleAndChevron__default@3x.png"
     width="200"/>

1. Let's scan the layout horizontally and translate it into FixFlex code:

<img class="snapshot"
     src="Readme/static/hstack.png"
     width="400"/>

Most of the views and spacings have a fixed width (`Fix`), while the title and subtitle widths are flexible, designed to occupy the remaining space (`Flex`):

```swift
parent.fx.hstack(Fix(15),
                 Fix(iconView, 44),
                 Fix(15),
                 Flex([titleLabel, subtitleLabel]),
                 Fix(15),
                 Fix(chevron, 20),
                 Fix(15))
```

2. Vertically, we have three distinct groups of views. Starting with the icon:

<img class="snapshot"
     src="Readme/static/vstack1.png"
     width="400"/>

We do a spacing at the top using `Fix`. The bottom spacing should be at least 15pt, for the case when the labels' height is less than the icon's height:

```swift
parent.fx.vstack(Fix(15),
                 Fix(iconView, 44),
                 Flex(min: 15))
```

3. Next, we perform a vertical scan of the title and subtitle:

<img class="snapshot"
     src="Readme/static/vstack2.png"
     width="400"/>

```swift
parent.fx.vstack(Fix(15),
                 Flex(titleLabel),
                 Flex(subtitleLabel),
                 Fix(15))
```

4. Finally, we scan the chevron vertically:

<img class="snapshot"
     src="Readme/static/vstack3.png"
     width="400"
/>

To center the chevron, we ensure the top spacing is equal to the bottom spacing using `Fill`:

```swift
parent.fx.vstack(Fill(),
                 Fix(chevron, 30),
                 Fill())
```

That's it! The best part is how easy it is to modify FixFlex layout code, inserting extra padding or views effortlessly, without the need to rewire constraints.

## API

### hstack/vstack

`FixFlex` provides two functions for laying out views horizontally (`hstack`) and vertically (`vstack`), accessible through the `view.fx.*` namespace.

You can specify `startAnchor`/`endAnchor` to layout items between arbitrary anchors instead of the view's edges. `startOffset`/`endOffset` are used to add spacing or offsets from the `startAnchor` and `endAnchor` respectively.

By default, `hstack` works in natural positioning mode and operates using `leadingAnchor`/`trailingAnchor`. This setup ensures that the layout is mirrored for Right-to-Left languages. However, this behavior can be overridden by enabling the `useAbsolutePositioning` flag. When this flag is set to true, `hstack` shifts to using `leftAnchor`/`rightAnchor` for layout positioning.

```swift
func hstack(
        startAnchor: NSLayoutXAxisAnchor? = nil, // if nil, we use leadingAnchor or leftAnchor
        startOffset: CGFloat = 0,
        endAnchor: NSLayoutXAxisAnchor? = nil, // if nil, we use trailingAnchor or rightAnchor
        endOffset: CGFloat = 0,
        useAbsolutePositioning: Bool = false, // if true, we use leftAnchor/rightAnchor based positioning (force Left-To-Right)
        _ intents: SizingIntent...
    ) -> StackingResult
```

```swift
func vstack(
        startAnchor: NSLayoutYAxisAnchor? = nil, // if nil, we use topAnchor
        startOffset: CGFloat = 0,
        endAnchor: NSLayoutYAxisAnchor? = nil, // if nil, we use bottomAnchor
        endOffset: CGFloat = 0,
        _ intents: SizingIntent...
    ) -> StackingResult
```

A `SizingIntent` is essentially an instruction for calculating the width or height of:

- a spacer (for which a `UILayoutGuide` is created behind the scenes)
- a view
- an array of views (when they are aligned in parallel)

Concrete instances of `SizingIntent` can be created using specialized builder functions:

### Fix

Used for specifying the exact size of a view/spacer.

```swift
func Fix(_ value: CGFloat) -> SizingIntent

func Fix(_ view: _View, _ value: CGFloat) -> SizingIntent

func Fix(_ views: [_View], _ value: CGFloat) -> SizingIntent
```

### Flex

Useful for sizes that change dynamically. Optionally, it is possible to specify min/max constraints and in-place priority settings for hugging and compression resistance.

```swift
func Flex(min: CGFloat? = nil, max: CGFloat? = nil) -> SizingIntent

func Flex(_ view: _View, min: CGFloat? = nil, max: CGFloat? = nil, huggingPriority: _LayoutPriority? = nil, compressionResistancePriority: _LayoutPriority? = nil) -> SizingIntent

func Flex(_ views: [_View], min: CGFloat? = nil, max: CGFloat? = nil, huggingPriority: _LayoutPriority? = nil, compressionResistancePriority: _LayoutPriority? = nil) -> SizingIntent
```

### Fill

`Fill` allows a view/spacer to proportionally occupy the available free space based on its weight. It's particularly useful for achieving equal spacing, centering elements, or for designing symmetrical layouts like tables or grids.

```swift
func Fill(weight: CGFloat = 1.0) -> SizingIntent

func Fill(_ view: _View, weight: CGFloat = 1.0) -> SizingIntent

func Fill(_ views: [_View], weight: CGFloat = 1.0) -> SizingIntent
```

### Match

This is used to match the size of a view or spacer to a specified `NSLayoutDimension`. It is particularly useful for aligning the sizes of different views or spacers, or for making their sizes proportional to each other.

```swift
public func Match(dimension: NSLayoutDimension, multiplier: CGFloat? = nil, offset: CGFloat? = nil) -> SizingIntent

public func Match(_ view: _View, dimension: NSLayoutDimension, multiplier: CGFloat? = nil, offset: CGFloat? = nil) -> SizingIntent

public func Match(_ views: [_View], dimension: NSLayoutDimension, multiplier: CGFloat? = nil, offset: CGFloat? = nil) -> SizingIntent
```

## How it works

FixFlex is not a black box and doesn't use any magic. It is simply a declarative and convenient way to create constraints and layout guides. Let's take a look at how FixFlex is translated into standard Auto Layout calls when we want to center vertically two labels:

<img class="snapshot"
     src="FixFlexSamples/Ref/ReferenceImages_64/FixFlexSamplesTests.FixFlexTests/test_VerticallyCenterTwoLabels__default@3x.png"
     width="200"/>

```swift
parent.fx.hstack(Flex([topLabel, bottomLabel]))

parent.fx.vstack(Fill(),
                 Flex(topLabel),
                 Fix(5),
                 Flex(bottomLabel),
                 Fill())
```

Under the hood, FixFlex creates constraints and layout guides which equivalent to the following:

```swift
topLabel.translatesAutoresizingMaskIntoConstraints = false
bottomLabel.translatesAutoresizingMaskIntoConstraints = false

let layoutGuideTop = UILayoutGuide()
let layoutGuideMiddle = UILayoutGuide()
let layoutGuideBottom = UILayoutGuide()

parent.addLayoutGuide(layoutGuideTop)
parent.addLayoutGuide(layoutGuideMiddle)
parent.addLayoutGuide(layoutGuideBottom)

NSLayoutConstraint.activate([
    // hstack
    topLabel.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
    topLabel.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
    bottomLabel.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
    bottomLabel.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
    //vstack
    layoutGuideTop.topAnchor.constraint(equalTo: parent.topAnchor),
    layoutGuideTop.bottomAnchor.constraint(equalTo: topLabel.topAnchor),
    topLabel.bottomAnchor.constraint(equalTo: layoutGuideMiddle.topAnchor),
    layoutGuideMiddle.heightAnchor.constraint(equalToConstant: 5),
    layoutGuideMiddle.bottomAnchor.constraint(equalTo: bottomLabel.topAnchor),
    bottomLabel.bottomAnchor.constraint(equalTo: layoutGuideBottom.topAnchor),
    layoutGuideBottom.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
    layoutGuideTop.heightAnchor.constraint(equalTo: layoutGuideBottom.heightAnchor),
])
```

Huh, that's a lot of code to write, and imagine needing to modify it — inserting an extra view or changing the order. Once you try FixFlex, you won't want to go back!

## Examples

<% stories.forEach(function(story){ %>

### <%- story.nameAsWords %>

<img class="snapshot"
     src="<%- story.imageName %>"
     width="<%- `${story.imageWidth/3}` %>"/>

```swift
<%- story.codeSnippet %>
```

<% }); %>

## Integration

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

Use Swift Package Manager and add dependency to `Package.swift` file.

```swift
  dependencies: [
    .package(url: "https://github.com/psharanda/FixFlex.git", .upToNextMajor(from: "1.0.0"))
  ]
```

Alternatively, in Xcode select `File > Add Package Dependencies…` and add FixFlex repository URL:

```
https://github.com/psharanda/FixFlex.git
```

### Carthage

Add `github "psharanda/FixFlex"` to your `Cartfile`

### CocoaPods
`FixFlex` is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "FixFlex"
```

## Contributing

We welcome contributions! If you find a bug, have a feature request, or want to contribute code, please open an issue or submit a pull request.

## License

FixFlex is available under the MIT license. See the LICENSE file for more info.
