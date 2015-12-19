//
// This file is part of Akane
//
// Created by JC on 15/12/15.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code
//

import Foundation
import UIKit

public class ComponentViewController<ViewType: UIView where ViewType: ViewComponent> : UIViewController, ComponentController {
    public var viewModel: AKNViewModelProtocol! {
        didSet {
            if (self.isViewLoaded()) {
                self.lifecycleManager.bindView()
            }
        }
    }
    public var componentView: ViewType! {
        get { return self.view as! ViewType }
    }

    var lifecycleManager: LifecycleManager<ComponentViewController<ViewType>>!

    public required init(view: ViewType) {
        super.init(nibName: nil, bundle: nil)

        self.lifecycleManager = LifecycleManager(controller: self)
        self.view = view
        self.viewDidLoad()
    }

    public override func viewDidLoad() {
        if (self.viewModel != nil) {
            self.lifecycleManager.bindView()
        }
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.lifecycleManager.mountOnce()
    }
}

extension ComponentController where Self:UIViewController {
    public func didLoad() {

    }
    
    public func addController<C:UIViewController where C:ComponentController>(childController: C) {
        if (!self.childViewControllers.contains(childController)) {
            self.addChildViewController(childController)
            childController.didMoveToParentViewController(self)
        }
    }

    public func controllerForComponent<V:UIView where V:ViewComponent>(component: V) -> ComponentViewController<V>? {
        for childViewController in self.childViewControllers {
            if let controller = childViewController as? ComponentViewController<V> {
                if (controller.componentView == component) {
                    return controller
                }
            }
        }

        return nil
    }
}