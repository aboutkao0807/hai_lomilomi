import UIKit
import SnapKit

struct HomeItem {
    let title: String
    let subtitle: String
}

final class HomePageViewController: UIViewController {

    private var items: [HomeItem] = [
        .init(title: "歡迎回來", subtitle: "這裡是你的首頁。"),
        .init(title: "最新公告", subtitle: "本週優惠：回饋點數加倍。"),
        .init(title: "預約提醒", subtitle: "您明天 15:00 有一筆按摩預約。"),
        .init(title: "小知識", subtitle: "深層組織按摩有助於舒緩長期肌肉緊繃。")
    ]

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize // 自動高度

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.alwaysBounceVertical = true
        cv.dataSource = self
        cv.delegate = self
        cv.register(HomeCell.self, forCellWithReuseIdentifier: HomeCell.reuseID)
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "首頁"

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

//DataSource / Delegate
extension HomePageViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCell.reuseID, for: indexPath) as! HomeCell
        let item = items[indexPath.item]
        cell.configure(title: item.title, subtitle: item.subtitle)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        print("點到：\(items[indexPath.item].title)")
        // TODO: 導到對應頁面
    }
}

//Cell
final class HomeCell: UICollectionViewCell {
    static let reuseID = "HomeCell"

    private let container = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        contentView.addSubview(container)
        container.layer.cornerRadius = 12
        container.layer.masksToBounds = true
        container.backgroundColor = .secondarySystemBackground

        container.snp.makeConstraints { make in
            // 讓 cell 自動高度生效的關鍵：container 貼滿 contentView
            make.edges.equalToSuperview()
            // 也可限制最小寬度，避免自動尺寸計算時壓縮錯誤
        }

        // 標題
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.numberOfLines = 0

        // 內文
        subtitleLabel.font = .systemFont(ofSize: 15)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0

        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.right.equalToSuperview().inset(14)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.left.right.equalTo(titleLabel)
            make.bottom.equalToSuperview().inset(14) // 定義底邊，才能自動撐高
        }
    }

    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
    
    //建立預約
    @objc private func testCreateBooking() {
        let svc = BookingService()
        svc.createBooking(shopId: "shop001",
                          serviceId: "sv001",
                          startAt: Date(),
                          price: 1200) { result in
            switch result {
            case .success(let bookingId):
                print("預約建立成功：\(bookingId)")
            case .failure(let error):
                print("建立失敗：\(error.localizedDescription)")
            }
        }
    }

}
