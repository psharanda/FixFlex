//
//  Created by Pavel Sharanda on 02/12/2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)

        let vc = StorybookViewController(componentsStories: [
            FixFlexStories(),
        ])
        let nc = UINavigationController(rootViewController: vc)
        window.rootViewController = nc

        self.window = window
        window.makeKeyAndVisible()
    }
}
