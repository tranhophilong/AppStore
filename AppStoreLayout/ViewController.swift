
import UIKit

class ViewController: UIViewController {
    
    // MARK: Section Definitions
    enum Section: Hashable {
        case promoted
        case standard(String)
        case categories
    }
    
    enum SupplementaryViewKind{
        static let header = "header"
        static let topLine = "topLine"
        static let bottomLine = "bottomLine"
    }

    @IBOutlet var collectionView: UICollectionView!
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Item.ID>!
    
    var sections = [Section]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Collection View Setup
        collectionView.collectionViewLayout = createLayout()
                
        configureDataSource()
    }
    
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutInviroment in
            guard let self else{
                return nil
            }
            
            let section = sections[sectionIndex]
            
            let supplementaryItemContentEdgeInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
            
            let headerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.92), heightDimension: .estimated(44))
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerItemSize, elementKind: SupplementaryViewKind.header, alignment: .top)
            headerItem.contentInsets = supplementaryItemContentEdgeInsets
            
            let lineItemHeight = 1 / layoutInviroment.traitCollection.displayScale
            let lineItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.92), heightDimension: .absolute(lineItemHeight))
            let topLineItem =  NSCollectionLayoutBoundarySupplementaryItem(layoutSize: lineItemSize, elementKind: SupplementaryViewKind.topLine, alignment: .top)
            let bottomLineItem =  NSCollectionLayoutBoundarySupplementaryItem(layoutSize: lineItemSize, elementKind: SupplementaryViewKind.bottomLine, alignment: .bottom)
            topLineItem.contentInsets = supplementaryItemContentEdgeInsets
            bottomLineItem.contentInsets = supplementaryItemContentEdgeInsets
            
            
            switch section{
                
            case .promoted:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0))
                let item =  NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.92), heightDimension: .estimated(300))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.orthogonalScrollingBehavior = .groupPagingCentered
                section.boundarySupplementaryItems = [topLineItem, bottomLineItem]
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 20, trailing: 0)
                
                return section
                
            case .standard:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1/3))
                let item =  NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.92), heightDimension: .estimated(250))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 3)
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPagingCentered
                section.boundarySupplementaryItems = [headerItem, bottomLineItem]
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 20, trailing: 0)
                
                return section
                
            case .categories:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1))
                let item =  NSCollectionLayoutItem(layoutSize: itemSize)
                
                let availabelLayoutWidth = layoutInviroment.container.effectiveContentSize.width
                let groupWidth = availabelLayoutWidth * 0.92
                let remainWidth = availabelLayoutWidth - groupWidth
                let halfOfRemainWidth = remainWidth / 2
                let nonCategorySectionItemInset = CGFloat(4)
                let itemLeadingAndTrailingInset = nonCategorySectionItemInset + halfOfRemainWidth
                
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: itemLeadingAndTrailingInset, bottom: 0, trailing: itemLeadingAndTrailingInset)
            
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.92), heightDimension: .estimated(44))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                return section
                
            }
        }
        
        return layout
    }
    
    func configureDataSource() {
        
//        MARK: Snapshot
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item.ID>()
        snapshot.appendSections([.promoted])
        snapshot.appendItems(Item.promotedApps.map({$0.id}), toSection: .promoted)
        
        let popularSection = Section.standard("Popular this week")
        let essentialSection = Section.standard("Essential picks")
        
        snapshot.appendSections([popularSection, essentialSection])
      
        snapshot.appendItems(Item.popularApps.map({$0.id}), toSection: popularSection)
        snapshot.appendItems(Item.essentialApps.map({$0.id}), toSection: essentialSection)
        
        
        snapshot.appendSections([.categories])
        snapshot.appendItems(Item.categories.map({$0.id}), toSection: .categories)
        
        sections = snapshot.sectionIdentifiers
        
        let promotedAppCellRegistration = UICollectionView.CellRegistration<PromotedAppCollectionViewCell,  Item.ID> { cell, indexPath, itemIdentifier in
            guard  let promotedAppItem = Item.promotedApps.first(where: {$0.id == itemIdentifier}) else{
                return
            }
            
            if let app = promotedAppItem.app{
                cell.configureCell(app)
            }
           
        }
        
//        MARK: Cell registration
        
        let standardAppCellRegistration = UICollectionView.CellRegistration<StandardAppCollectionViewCell, Item.ID> {  cell, indexPath, itemIdentifier in
            guard  let standardAppItem = (Item.popularApps + Item.essentialApps).first(where: {$0.id == itemIdentifier})  else{
                return
            }
            
            if let app = standardAppItem.app{
                let isThirdItem = (indexPath.row + 1).isMultiple(of: 3)
                cell.configureCell(app, hideBottomLine: isThirdItem)
            }
        }
        
        let categoryCellRegistration = UICollectionView.CellRegistration<CategoryCollectionViewCell, Item.ID> { [weak self] cell, indexPath, itemIdentifier in
            guard let self else { return }
            guard  let categoryItem = Item.categories.first(where: { $0.id == itemIdentifier}) else { return }
            
            if let category = categoryItem.category{
                let isLastIndex = indexPath.row + 1 == collectionView.numberOfItems(inSection: indexPath.section)
                cell.configureCell(category, hideBottomLine: isLastIndex)
            }
        }
        
        
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item.ID>(collectionView: collectionView, cellProvider: {[weak self] collectionView, indexPath, itemIdentifier in
            guard let self else{
                return nil
            }
            
            let section = sections[indexPath.section]
            
            switch section{
            case .promoted:
                return collectionView.dequeueConfiguredReusableCell(using: promotedAppCellRegistration, for: indexPath, item: itemIdentifier)
            case .standard:
                return collectionView.dequeueConfiguredReusableCell(using: standardAppCellRegistration, for: indexPath, item: itemIdentifier)
            case .categories:
                return collectionView.dequeueConfiguredReusableCell(using: categoryCellRegistration, for: indexPath, item: itemIdentifier)
            }
           
        })
        
//        MARK: supplementary provider
        let sectionHeaderRegistration = UICollectionView.SupplementaryRegistration<SectionHeaderView>(elementKind: SupplementaryViewKind.header) { [weak self] headerView, elementKind, indexPath in
            guard let self else {return}
            let section  = sections[indexPath.section]
            let sectionName: String
            
            switch section{
            case .promoted:
                sectionName = ""
            case .standard(let name):
                sectionName = name
            case .categories:
                sectionName = "Categories"
            }
            
            headerView.setTitle(sectionName)
        }
        
      
        let bottomLineRegistration = UICollectionView.SupplementaryRegistration<LineView>(elementKind: SupplementaryViewKind.bottomLine) { supplementaryView, elementKind, indexPath in
            
        }
        
        let topLineRegistration = UICollectionView.SupplementaryRegistration<LineView>(elementKind: SupplementaryViewKind.topLine) { supplementaryView, elementKind, indexPath in
            
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView? in
            guard let self else{
                return nil
            }
            switch kind{
            case SupplementaryViewKind.header:
                guard  sections[indexPath.section] != .promoted else {return nil}
                return collectionView.dequeueConfiguredReusableSupplementary(using: sectionHeaderRegistration, for: indexPath)
            case SupplementaryViewKind.topLine:
                return collectionView.dequeueConfiguredReusableSupplementary(using: topLineRegistration, for: indexPath)
            case SupplementaryViewKind.bottomLine:
                return collectionView.dequeueConfiguredReusableSupplementary(using: bottomLineRegistration, for: indexPath)
            default:
                fatalError("Not yet elemented ")
            }
        }
        
        dataSource.apply(snapshot)
    }
}

