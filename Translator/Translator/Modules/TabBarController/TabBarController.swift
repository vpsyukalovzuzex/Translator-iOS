//
// TabBarController.swift
//

import UIKit
import Api
import Core

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        Api.parameters["platform"] = "iOS"
        Api.parameters["paid"] = "\(false)"
        Core.setupLanguages().done {
            
        }.catch { eror in
            
        }.finally {
            
        }
    }
    
    private func setup() {
        let a = TranslationViewController
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
        a.navigationController?.setNavigationBarHidden(true, animated: false)
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
