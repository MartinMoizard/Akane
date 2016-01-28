//
// This file is part of Akane
//
// Created by JC on 17/01/16.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code
//

import Foundation

public protocol ViewObserverDelegate {
    func bind(observer: ViewObserver, viewModel: ComponentViewModel)
}

// MARK: TableView

public extension ViewObserverDelegate where
    Self : UITableView,
    Self : ComponentTableView,
    Self.DataSourceType : DataSourceTableViewItems,
    Self.DataSourceType.DataType == Self.ViewModelType.DataType,
    Self.DataSourceType.ItemIdentifier.RawValue == String
{
    func bind(observer: ViewObserver, viewModel: ComponentViewModel) {
        let viewModel = viewModel as! Self.ViewModelType
        let delegate = TableViewDelegate(tableView: self, collectionViewModel: viewModel)

        delegate.becomeDataSource(observer, data: viewModel.data)
    }
}

public extension ViewObserverDelegate where
    Self : UITableView,
    Self : ComponentTableView,
    Self.DataSourceType : DataSourceTableViewItems,
    Self.ViewModelType.DataType: Observation,
    Self.DataSourceType.DataType == Self.ViewModelType.DataType.Element,
    Self.DataSourceType.ItemIdentifier.RawValue == String
{
    func bind(observer: ViewObserver, viewModel: ComponentViewModel) {
        let viewModel = viewModel as! Self.ViewModelType
        let delegate = TableViewDelegate(tableView: self, collectionViewModel: viewModel)

        viewModel.data.observe { [unowned observer] collection in
            delegate.becomeDataSource(observer, data: collection)
        }
    }
}

// MARK: TableView with sections

public extension ViewObserverDelegate where
    Self : UITableView,
    Self : ComponentTableView,
    Self.ViewModelType : ComponentCollectionSectionsViewModel,
    Self.DataSourceType : DataSourceTableViewSections,
    Self.DataSourceType.DataType == Self.ViewModelType.DataType,
    Self.DataSourceType.ItemIdentifier.RawValue == String,
    Self.DataSourceType.SectionIdentifier.RawValue == String
{
    func bind(observer: ViewObserver, viewModel: ComponentViewModel) {
        let viewModel = viewModel as! Self.ViewModelType
        let delegate = TableViewSectionDelegate(tableView: self, collectionViewModel: viewModel)

        delegate.becomeDataSource(observer, data: viewModel.data)
    }
}

public extension ViewObserverDelegate where
    Self : UITableView,
    Self : ComponentTableView,
    Self.ViewModelType : ComponentCollectionSectionsViewModel,
    Self.DataSourceType : DataSourceTableViewSections,
    Self.ViewModelType.DataType: Observation,
    Self.DataSourceType.DataType == Self.ViewModelType.DataType.Element,
    Self.DataSourceType.ItemIdentifier.RawValue == String,
    Self.DataSourceType.SectionIdentifier.RawValue == String
{
    func bind(observer: ViewObserver, viewModel: ComponentViewModel) {
        let viewModel = viewModel as! Self.ViewModelType
        let delegate = TableViewSectionDelegate(tableView: self, collectionViewModel: viewModel)

        viewModel.data.observe { [unowned observer] collection in
            delegate.becomeDataSource(observer, data: collection)
        }
    }
}