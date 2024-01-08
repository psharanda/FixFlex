<p align="center">
<img src="Readme/logo.png" width="50%" alt="RxSwift Logo" />
</p>
      
`FixFlex` is a simple yet powerful Auto Layout library built on top of the NSLayoutAnchor API, a swifty and type-safe reimagination of [Visual Format Language](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/VisualFormatLanguage.html)

## Features

- Auto Layout code that is easy to write, read, and modify
- Simple API with 2 functions and 4 modifiers
- Lightweight, implementation is only 300 lines of code
- Compatible with any other Auto Layout code
- Basically generates a bunch of `NSLayoutConstraint` and `UILayoutGuide`
- Super straightforward mental model
- Typesafe alternative to VFL
- Automatically sets `translatesAutoresizingMaskIntoConstraints` to false
- Supports iOS 12.0+ / Mac OS X 10.13+ / tvOS 12.0+

## Usage

Imagine we want to create a layout like this:

<img
        class="snapshot"
        src="Ref/ReferenceImages_64/FixFlexSamplesTests.FixFlexTests/test_CellWithIconTitleSubtitleAndChevron__default@3x.png"
        width="200"
      />

1. Let's 'scan' the layout horizontally and translate it into FixFlex code:

<img
        class="snapshot"
        src="Readme/hput.png"
        width="400"
      />

The title and subtitle widths can vary on different devices, which is why we use the Flex intent for them:

```swift
parent.fx.hput(Fix(10),
               Fix(iconView, 44),
               Fix(5),
               Flex([titleLabel, subtitleLabel]),
               Fix(5),
               Fix(chevron, 20),
               Fix(10))
```

2. Vertically, we have three different groups of views. Let's start with the icon:

<img
        class="snapshot"
        src="Readme/vput1.png"
        width="400"
      />

We pin `iconView` to the top of the parent with an offset of 5pt. The bottom padding is at least 5pt, but can be more (for the case when the labels' height + 5 is less than the icon's height):

```swift
parent.fx.vput(Fix(5),
               Fix(iconView, 44),
               Flex(min: 5))
```

3. Next is the vertical scan of the title and subtitle:

<img
        class="snapshot"
        src="Readme/vput2.png"
        width="400"
      />

```swift
parent.fx.vput(Fix(5),
               Flex(titleLabel),
               Fix(5),
               Flex(subtitleLabel),
               Fix(5))
```

4. Finally, the vertical scan of the chevron:

<img
        class="snapshot"
        src="Readme/vput3.png"
        width="400"
      />

To center the chevron, the top padding should be equal to the bottom one. We use Split for this:

```swift
parent.fx.vput(Split(),
               Fix(chevron, 20),
               Split())
```

## API

`FixFlex` provides two functions for laying out UIViews or NSViews, accessible through the 'fx' namespace.

- `view.fx.hput(...)`: handles the horizontal layout of views
- `view.fx.vput(...)`: handles the vertical layout of views

Both `hput` and `vput` process an array of `PutIntent`. A `PutIntent` is essentially an instruction on how to calculate the width or height for a view, an array of views, or a spacer (a UILayoutGuide is created for a `PutIntent` with a not specified view).

`PutIntent` types:

- `Fix`: This is used when you know the exact size of the view/spacer.
- `Flex`: This is particularly useful for view/spacer whose size may change dynamically based on content. It can also have minimum or maximum value constraints.
- `Split`: This is used when you want the size of one view/spacer to be the same as another. It's typically used for equal spacing or for creating symmetrical layouts.
- `Match`: The size will match some other NSLayoutDimension. This is useful when you want to align the sizes of different view/spacer or make them proportional to each other.

## Examples

<% component.stories.forEach(function(story){ %>

### <%- story.nameAsWords %>

<img
        class="snapshot"
        src="<%- story.imageName %>"
        width="<%- `${story.imageWidth/3}` %>"
        align="left"
      />

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
