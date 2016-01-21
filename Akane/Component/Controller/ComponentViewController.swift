//
// This file is part of Akane
//
// Created by JC on 15/12/15.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code
//

import Foundation
import UIKit

public class ComponentViewController : UIViewController, ComponentController {
    public var viewModel: ComponentViewModel! {
        didSet {
            if (self.isViewLoaded()) {
                self.prepareIfNeeded()
                self.lifecycle.bindView()
            }
        }
    }

    public var componentView: ComponentView! {
        get { return self.view as! ComponentView }
    }

    var lifecycle: ControllerLifecycle<ComponentViewController>!

    required public init(view: UIView) {
        super.init(nibName: nil, bundle: nil)

        self.view = view
        self.viewDidLoad()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func viewDidLoad() {
        if (self.viewModel != nil) {
            self.prepareIfNeeded()
            self.lifecycle.bindView()
        }
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.lifecycle.mountOnce()
    }

    func prepareIfNeeded() {
        if (self.lifecycle == nil) {
            self.lifecycle = ControllerLifecycle(controller: self)
            self.didLoad()
        }
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

    public func controllerForComponent<V:UIView where V:ComponentView>(component: V) -> ComponentViewController? {
        for childViewController in self.childViewControllers {
            if let controller = childViewController as? ComponentViewController {
                if (controller.view == component) {
                    return controller
                }
            }
        }

        return nil
    }
}