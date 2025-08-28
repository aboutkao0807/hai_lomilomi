

import UIKit
import SnapKit
import Foundation

final class RegisterViewController: UIViewController {

    private let emailLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .secondaryLabel
        lb.numberOfLines = 1
        return lb
    }()

    private let nameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "姓名"
        tf.borderStyle = .roundedRect
        return tf
    }()

    private let phoneField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "電話"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .phonePad
        return tf
    }()

    private let submitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("完成註冊", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.tintColor = .white
        btn.layer.cornerRadius = 10
        btn.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return btn
    }()

    private let activity = UIActivityIndicatorView(style: .medium)
    private let vm = RegisterViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "填寫會員資料"

        setupUI()
        bindVM()
        setupActions()
        setupDismissKeyboardGesture()

        vm.loadEmail() // 把目前登入者的 email 顯示出來
    }

    private func setupUI() {
        let emailTitle = UILabel()
        emailTitle.text = "註冊 Email（唯讀）："
        emailTitle.textColor = .secondaryLabel
        emailTitle.font = .systemFont(ofSize: 13)

        let stack = UIStackView(arrangedSubviews: [emailTitle, emailLabel, nameField, phoneField, submitButton, activity])
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .fill

        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
        }
    }

    private func bindVM() {
        vm.emailText = { [weak self] email in self?.emailLabel.text = "註冊 Email：\(email)" }
                vm.onLoading = { [weak self] loading in
                    loading ? self?.activity.startAnimating() : self?.activity.stopAnimating()
                    [self?.nameField, self?.phoneField, self?.submitButton].forEach { $0?.isUserInteractionEnabled = !loading }
                }
                vm.onError = { [weak self] msg in self?.showAlert(title: "錯誤", message: msg) }
                vm.onSuccess = { [weak self] in self?.goToHomePage() }
    }

    private func setupActions() {
        submitButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
    }

    @objc private func submit() {
        vm.name = nameField.text ?? ""
        vm.phone = phoneField.text ?? ""
        vm.submit()
    }

    private func setEnabled(_ enabled: Bool) {
        [nameField, phoneField, submitButton].forEach {
            $0.isUserInteractionEnabled = enabled
            ($0 as? UIButton)?.alpha = enabled ? 1.0 : 0.6
        }
    }

    private func setupDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditingNow))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc private func endEditingNow() { view.endEditing(true) }

    // 前面已有的共用導頁方法
    private func goToHomePage() {
        let home = HomePageViewController()
        if let window = view.window ?? UIApplication.shared.windows.first {
            window.rootViewController = UINavigationController(rootViewController: home)
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
            window.makeKeyAndVisible()
        } else {
            navigationController?.setViewControllers([home], animated: true)
        }
    }
}
