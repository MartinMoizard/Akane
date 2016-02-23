//
// This file is part of Akane
//
// Created by JC on 16/12/15.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code
//

import Foundation
import UIKit
import Bond

var TableViewDataSourceAttr = "TableViewDataSourceAttr"

/// Adapter class, making the link between `UITableViewDataSource`, `UITableViewDelegate` and
/// `DataSource`, `ComponentCollectionViewModel`, `CollectionLayout`
public class TableViewDelegate<TableViewType : UITableView where
    TableViewType : ComponentTableView,
    TableViewType.DataSourceType.ItemIdentifier.RawValue == String> : NSObject, UITableViewDataSource, UITableViewDelegate
{
    public typealias CollectionViewModelType = TableViewType.ViewModelType
    public typealias DataSourceType = TableViewType.DataSourceType

    var templateHolder: [CollectionRowType:Template]
    weak var observer: ViewObserver?
    weak var collectionViewModel: CollectionViewModelType!
    unowned var tableView: TableViewType
    var dataSource: DataSourceType! {
        didSet { self.tableView.reloadData() }
    }

    /// init the delegate with a `UITableView` and its view model
    init(tableView: TableViewType, collectionViewModel: CollectionViewModelType) {
        self.tableView = tableView
        self.templateHolder = [:]
        self.collectionViewModel = collectionViewModel

        super.init()

        // Without casting swift complains about ambiguous delegate
        (self.tableView as UITableView).delegate = self
        tableView.dataSource = self

        objc_setAssociatedObject(self.tableView, &TableViewDataSourceAttr, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    /// make the delegate effective
    func becomeDataSource(observer: ViewObserver, data: DataSourceType.DataType) {
        self.observer = observer
        self.dataSource = DataSourceType.init(data: data)
    }

    // MARK: DataSource

    @objc
    /// - see: `UITableViewDataSource.numberOfSectionsInTableView(_:)`
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.dataSource.numberOfSections()
    }

    @objc
    /// - see: `UITableViewDataSource.tableView(_:, numberOfRowsInSection:)`
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.numberOfItemsInSection(section)
    }

    @objc
    /// - see: `DataSourceTableViewItems.itemAtIndexPath(_:)`
    /// - see: `DataSourceTableViewItems.tableViewItemTemplate(_:)`
    /// - seeAlso: `UITableViewDataSource.tableView(_:, cellForRowAtIndexPath:)`
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let data = self.dataSource.itemAtIndexPath(indexPath)
        let template = self.templateHolder.findOrCreate(.Item(identifier: data.identifier.rawValue)) {
            let template = self.dataSource.tableViewItemTemplate(data.identifier)

            self.tableView.register(template, type: .Item(identifier: data.identifier.rawValue))

            return template
        }

        let cell = tableView.dequeueReusableCellWithIdentifier(data.identifier.rawValue, forIndexPath: indexPath)

        if let item = data.item {
            let viewModel = self.collectionViewModel.createItemViewModel(item as! CollectionViewModelType.ItemType)

            self.observer?.observe(viewModel).bindTo(cell, template: template)
        }

        return cell
    }

    // MARK: Layout

    @objc
    /// - see: `CollectionLayout.estimatedHeightForItem(_:)`
    /// - seeAlso: `UITableViewDelegate.tableView(_:, estimatedHeightForRowAtIndexPath:)`
    public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.layout.estimatedHeightForItem(indexPath)
    }

    @objc
    /// - see: `CollectionLayout.heightForItem(_:)`
    /// - see: `UITableViewDelegate.tableView(_:, heightForRowAtIndexPath:)`
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.layout.heightForItem(indexPath)
    }

    @objc
    /// - returns the row index path if its viewModel is of type `ComponentItemViewModel` and it defines `select`, nil otherwise
    /// - see: `ComponentItemViewModel.select()`
    /// - seeAlso: `UITableViewDelegate.tableView(_:, willSelectRowAtIndexPath:)`
    public func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if let item = self.dataSource.itemAtIndexPath(indexPath).item,
            let viewModel = self.collectionViewModel.createItemViewModel(item as! CollectionViewModelType.ItemType) as? ComponentItemViewModel {
            return (viewModel.select != nil) ? indexPath : nil
        }

        return nil
    }

    // MARK: Selection

    @objc
    /// Call the row view model `select` `Command`
    /// - see: `ComponentItemViewModel.select()`
    /// - seeAlso: `UITableViewDelegate.tableView(_:, didSelectRowAtIndexPath:)`
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = self.dataSource.itemAtIndexPath(indexPath).item
        let viewModel = self.collectionViewModel.createItemViewModel(item as! CollectionViewModelType.ItemType) as! ComponentItemViewModel

        viewModel.select!.execute(nil)
    }

    @objc
    /// - returns the row index path if its viewModel is of type `ComponentItemViewModel` and it defines `unselect`, nil otherwise
    /// - seeAlso: `UITableViewDelegate.tableView(_:, willDeselectRowAtIndexPath:)`
    public func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let item = self.dataSource.itemAtIndexPath(indexPath).item
        let viewModel = self.collectionViewModel.createItemViewModel(item as! CollectionViewModelType.ItemType) as! ComponentItemViewModel

        return (viewModel.unselect != nil) ? indexPath : nil
    }

    @objc
    /// Call the row view model `unselect` `Command`
    /// - seeAlso: `UITableViewDelegate.tableView(_:, didDeselectRowAtIndexPath:)`
    public func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let item = self.dataSource.itemAtIndexPath(indexPath).item
        let viewModel = self.collectionViewModel.createItemViewModel(item as! CollectionViewModelType.ItemType) as! ComponentItemViewModel

        viewModel.unselect!.execute(nil)
    }
}

