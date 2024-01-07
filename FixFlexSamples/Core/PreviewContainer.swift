import SwiftUI
import SwiftUIKitView

func previewStories(_ stories: [Story]) -> ForEach<[Story], String, some View> {
    return ForEach(stories, id: \.name) { story in
        UIViewContainer(story.makeView(), layout: .intrinsic)
            .fixedSize()
            .previewDisplayName(story.name)
            .previewLayout(.sizeThatFits)
    }
}
