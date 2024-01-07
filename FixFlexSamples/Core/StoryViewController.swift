//
//  Created by Pavel Sharanda on 03/12/2023.
//

import CoreImage
import UIKit

class StoryViewController: UIViewController {
    let story: Story
    init(story: Story) {
        self.story = story
        super.init(nibName: nil, bundle: nil)
        title = story.name
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .secondarySystemBackground

        let storyView = story.makeView()

        view.addSubview(storyView)

        storyView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            storyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            storyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
