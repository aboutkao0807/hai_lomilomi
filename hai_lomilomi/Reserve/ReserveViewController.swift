
import Foundation
import UIKit


final class SlotCell: UICollectionViewCell {
    static let reuseID = "SlotCell"

    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true

        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center

        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            label.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(_ text: String) { label.text = text }
}


    //ReserveViewController
final class ReserveViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // 假資料
    private var sections: [DaySection] = [
        DaySection(title: "2025/09/01 週一", slots: ["09:00", "10:30", "13:00", "15:30", "17:00"]),
        DaySection(title: "2025/09/02 週二", slots: ["10:00", "11:30", "14:00", "16:00"]),
        DaySection(title: "2025/09/03 週三", slots: ["09:30", "11:00", "13:30", "18:00", "19:30"]),
    ]

    // 底部浮動按鈕
    private let reserveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("我要預約", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        btn.layer.cornerRadius = 12
        btn.heightAnchor.constraint(equalToConstant: 52).isActive = true
        return btn
    }()

    // 佈局
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        layout.headerReferenceSize = CGSize(width: 0, height: 36) // section header 高度
        super.init(collectionViewLayout: layout)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "我的預約"

        collectionView.backgroundColor = .systemBackground
        collectionView.register(SlotCell.self, forCellWithReuseIdentifier: SlotCell.reuseID)
        collectionView.register(DayHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: DayHeaderView.reuseID)

        // 底部按鈕
        view.addSubview(reserveButton)
        reserveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            reserveButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            reserveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            reserveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
        reserveButton.addTarget(self, action: #selector(reserveTapped), for: .touchUpInside)

        // 讓列表不被按鈕擋住
        collectionView.contentInset.bottom = 12 + 52 + 12
        collectionView.scrollIndicatorInsets.bottom = collectionView.contentInset.bottom
    }

    // MARK: - DataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sections[section].slots.count
    }
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SlotCell.reuseID, for: indexPath) as! SlotCell
        let slot = sections[indexPath.section].slots[indexPath.item]
        cell.configure(slot)
        return cell
    }

    // Header
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind, withReuseIdentifier: DayHeaderView.reuseID, for: indexPath
            ) as! DayHeaderView
            header.configure(sections[indexPath.section].title)
            return header
        }
        return UICollectionReusableView()
    }

    // 點選某個時段
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let day = sections[indexPath.section].title
        let slot = sections[indexPath.section].slots[indexPath.item]
        print("選擇：\(day) \(slot)")
        // TODO: 這裡之後接你的預約檢查/建立流程
    }

    // MARK: - FlowLayout Delegate（排版）
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 兩欄排版
        let totalInset: CGFloat = 16 + 16
        let interItem: CGFloat = 12
        let width = (collectionView.bounds.width - totalInset - interItem) / 2
        return CGSize(width: width, height: 48)
    }

    // Header 的大小（如果你想用自適應，也可以改 constraints）
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 36)
    }

    // MARK: - Actions
    @objc private func reserveTapped() {
        print("點擊『我要預約』")
        // TODO: 之後導向選擇店家/師傅/服務 or 建立預約的頁面
    }
}
