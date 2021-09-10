//
// TabBarController.swift
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        let a = ConferenceViewController
            .instantiate()
            .wrap(in: .init())
        let b = ConferenceViewController
            .instantiate()
            .wrap(in: .init())
        let c = FakeViewController
            .instantiate()
            .wrap(in: .init())
        let d = SettingsViewController
            .instantiate()
            .wrap(in: .init())
        let e = FakeViewController
            .instantiate()
            .wrap(in: .init())
        a.navigationController?.tabBarItem = .init(title: "Translate", image: nil, tag: 0)
        b.navigationController?.tabBarItem = .init(title: "Conference", image: nil, tag: 1)
        c.navigationController?.tabBarItem = .init(title: "Phone", image: nil, tag: 2)
        d.navigationController?.tabBarItem = .init(title: "Settings", image: nil, tag: 3)
        e.navigationController?.tabBarItem = .init(title: "More", image: nil, tag: 4)
        viewControllers = [
            a.navigationController!,
            b.navigationController!,
            c.navigationController!,
            d.navigationController!,
            e.navigationController!
        ]
    }
}
