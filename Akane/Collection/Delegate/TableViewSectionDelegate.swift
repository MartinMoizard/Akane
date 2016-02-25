//
// This file is part of Akane
//
// Created by JC on 17/01/16.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code
//

import Foundation

class TableViewSectionDelegate<TableViewType : UITableView where
    TableViewType : ComponentTableView,
    TableViewType.DataSourceType : DataSourceTableViewSections,
    TableViewType.ViewModelType : ComponentCollectionSectionsViewModel> : TableViewDelegate<TableViewType>
{

    override init(tableView: TableViewType, collectionViewModel: CollectionViewModelType) {
        super.init(tableView: tableView, collectionViewModel: collectionViewModel)
    }

    // MARK: DataSource

    @objc
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.viewForSection(section, sectionKind: "footer")
    }

    @objc
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.viewForSection(section, sectionKind: "header")
    }

    @objc
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableView.layout.heightForSection(section, sectionKind: "footer") ?? tableView.sectionFooterHeight
    }

    @objc
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.layout.heightForSection(section, sectionKind: "header") ?? tableView.sectionHeaderHeight
    }

    @objc
    func tableView(tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return tableView.layout.estimatedHeightForSection(section, sectionKind: "footer") ?? tableView.estimatedSectionFooterHeight
    }

    @objc
    func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return tableView.layout.estimatedHeightForSection(section, sectionKind: "header") ?? tableView.estimatedSectionHeaderHeight
    }

    func viewForSection(section: Int, sectionKind: String) -> UIView? {
        let data = self.dataSource.sectionItemAtIndex(section)
        let sectionType = CollectionElementCategory.Section(identifier: data.identifier.rawValue, kind: sectionKind)

        let template = self.dataSource.tableViewSectionTemplate(data.identifier, kind: sectionKind)

        if (self.templateHolder[sectionType] == nil) {
            self.tableView.register(template, type: sectionType)
        }

        let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(data.identifier.rawValue)!

        if template.needsComponentViewModel {
            let viewModel = self.collectionViewModel.createSectionViewModel(data.item as? CollectionViewModelType.SectionType)

            self.observer?.observe(viewModel).bindTo(view, template: template)
        }

        return view
    }
}
