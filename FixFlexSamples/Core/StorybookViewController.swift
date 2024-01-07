//
//  Created by Pavel Sharanda on 02/12/2023.
//

import UIKit

class StorybookViewController: UITableViewController {
    let componentsStories: [ComponentStories]

    init(componentsStories: [ComponentStories]) {
        self.componentsStories = componentsStories
        super.init(style: .plain)
        title = "FixFlex Samples"
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func numberOfSections(in _: UITableView) -> Int {
        return componentsStories.count
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return componentsStories[section].stories.count
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        return componentsStories[section].componentName
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellId") ?? UITableViewCell()
        cell.textLabel?.text = componentsStories[indexPath.section].stories[indexPath.row].name
        return cell
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyViewController = StoryViewController(story: componentsStories[indexPath.section].stories[indexPath.row])
        navigationController?.pushViewController(storyViewController, animated: true)
    }
}
