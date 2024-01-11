<p align="center">
<img src="Readme/static/logo.png" width="50%" alt="FixFlex Logo" />
</p>
      
`FixFlex` is a simple yet powerful Auto Layout library built on top of the NSLayoutAnchor API, a swifty and type-safe reimagination of [Visual Format Language](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/VisualFormatLanguage.html)

## Features

- Auto Layout code that is easy to write, read, and modify
- Simple API with 2 functions and 4 specifiers, covering 99% of layout use cases
- Lightweight, implementation is only 300 lines of code
- Compatible with any other Auto Layout code
- Basically generates a bunch of activated `NSLayoutConstraint` and `UILayoutGuide`
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
     src="Readme/static/hput.png"
     width="400"/>

Most of the views and spacings have a fixed width (`Fix`), while the title and subtitle widths are flexible, designed to occupy the remaining space (`Flex`):

```swift
parent.fx.hput(Fix(15),
               Fix(iconView, 44),
               Fix(15),
               Flex([titleLabel, subtitleLabel]),
               Fix(15),
               Fix(chevron, 20),
               Fix(15))
```

2. Vertically, we have three distinct groups of views. Starting with the icon:

<img class="snapshot"
     src="Readme/static/vput1.png"
     width="400"/>

We do a spacing at the top using `Fix`. The bottom spacing should be at least 15pt, for the case when the labels' height is less than the icon's height:

```swift
parent.fx.vput(Fix(15),
               Fix(iconView, 44),
               Flex(min: 15))
```

3. Next, we perform a vertical scan of the title and subtitle:

<img class="snapshot"
     src="Readme/static/vput2.png"
     width="400"/>

```swift
parent.fx.vput(Fix(15),
               Flex(titleLabel),
               Flex(subtitleLabel),
               Fix(15))
```

4. Finally, we scan the chevron vertically:

<img class="snapshot"
     src="Readme/static/vput3.png"
     width="400"
/>

To center the chevron, we ensure the top spacing is equal to the bottom spacing using `Grow`:

```swift
parent.fx.vput(Grow(),
               Fix(chevron, 30),
               Grow())
```

That's it! The best part is how easy it is to modify FixFlex layout code, inserting extra padding or views effortlessly, without the need to rewire constraints.

## API

### hput/vput

`FixFlex` provides two functions for laying out views horizontally (`hput`) and vertically (`vput`), accessible through the `view.fx.*` namespace.

You can specify `startAnchor`/`endAnchor` to layout items between arbitrary anchors instead of the view's edges. `startOffset`/`endOffset` are used to add spacing or offsets from the `startAnchor` and `endAnchor` respectively.

By default, `hput` works in natural positioning mode and operates using `leadingAnchor`/`trailingAnchor`. This setup ensures that the layout is mirrored for Right-to-Left languages. However, this behavior can be overridden by enabling the `useAbsolutePositioning` flag. When this flag is set to true, `hput` shifts to using `leftAnchor`/`rightAnchor` for layout positioning.

```swift
func hput(
        startAnchor: NSLayoutXAxisAnchor? = nil, // if nil, we use leadingAnchor or leftAnchor
        startOffset: CGFloat = 0,
        endAnchor: NSLayoutXAxisAnchor? = nil, // if nil, we use trailingAnchor or rightAnchor
        endOffset: CGFloat = 0,
        useAbsolutePositioning: Bool = false, // if true, we use leftAnchor/rightAnchor based positioning (force Left-To-Right)
        _ intents: PutIntent...
    ) -> PutResult
```

```swift
func vput(
        startAnchor: NSLayoutYAxisAnchor? = nil, // if nil, we use topAnchor
        startOffset: CGFloat = 0,
        endAnchor: NSLayoutYAxisAnchor? = nil, // if nil, we use bottomAnchor
        endOffset: CGFloat = 0,
        _ intents: PutIntent...
    ) -> PutResult
```

A `PutIntent` is essentially an instruction for calculating the width or height of:

- a spacer (for which a `UILayoutGuide` is created behind the scenes)
- a view
- an array of views (when they are aligned in parallel)

Concrete instances of `PutIntent` can be created using specialized builder functions:

### Fix

Used for specifying the exact size of a view/spacer.

```swift
func Fix(_ value: CGFloat) -> PutIntent

func Fix(_ view: _View, _ value: CGFloat) -> PutIntent

func Fix(_ views: [_View], _ value: CGFloat) -> PutIntent
```

### Flex

Useful for sizes that change dynamically. Optionally, it is possible to specify min/max constraints and in-place priority settings for hugging and compression resistance.

```swift
func Flex(min: CGFloat? = nil, max: CGFloat? = nil) -> PutIntent

func Flex(_ view: _View, min: CGFloat? = nil, max: CGFloat? = nil, huggingPriority: _LayoutPriority? = nil, compressionResistancePriority: _LayoutPriority? = nil) -> PutIntent

func Flex(_ views: [_View], min: CGFloat? = nil, max: CGFloat? = nil, huggingPriority: _LayoutPriority? = nil, compressionResistancePriority: _LayoutPriority? = nil) -> PutIntent
```

### Grow

`Grow` allows a view/spacer to proportionally occupy the available free space based on its weight. It's particularly useful for achieving equal spacing, centering elements, or for designing symmetrical layouts like tables or grids.

```swift
func Grow(weight: CGFloat = 1.0) -> PutIntent

func Grow(_ view: _View, weight: CGFloat = 1.0) -> PutIntent

func Grow(_ views: [_View], weight: CGFloat = 1.0) -> PutIntent
```

### Match

This is used to match the size of a view or spacer to a specified `NSLayoutDimension`. It is particularly useful for aligning the sizes of different views or spacers, or for making their sizes proportional to each other.

```swift
public func Match(dimension: NSLayoutDimension, multiplier: CGFloat? = nil, offset: CGFloat? = nil) -> PutIntent

public func Match(_ view: _View, dimension: NSLayoutDimension, multiplier: CGFloat? = nil, offset: CGFloat? = nil) -> PutIntent

public func Match(_ views: [_View], dimension: NSLayoutDimension, multiplier: CGFloat? = nil, offset: CGFloat? = nil) -> PutIntent
```

## Examples

<% stories.forEach(function(story){ %>

### <%- story.nameAsWords %>

<img class="snapshot"
     src="<%- story.imageName %>"
     width="<%- `${story.imageWidth/3}` %>"
     align="left"/>

```swift
<%- story.codeSnippet %>
```

<% }); %>

## Integration

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

## Contributing

We welcome contributions! If you find a bug, have a feature request, or want to contribute code, please open an issue or submit a pull request.

## License

FixFlex is available under the MIT license. See the LICENSE file for more info.
