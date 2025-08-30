import UIKit
import SnapKit
import FirebaseAuth

final class LoginViewController: UIViewController {

    private let logoLabel: UILabel = {
        let lb = UILabel()
        lb.text = "海眠"
        lb.font = .boldSystemFont(ofSize: 34)
        lb.textAlignment = .center
        return lb
    }()

    private let googleButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("使用 Google 登入", for: .normal)
        btn.backgroundColor = .orange
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.systemGray3.cgColor
        btn.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return btn
    }()

    private let registerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("我要註冊", for: .normal)
        btn.tintColor = .systemBlue
        return btn
    }()

    private let activity: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(style: .medium)
        a.hidesWhenStopped = true
        return a
    }()

    private let viewModel = LoginViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
              self.navigationItem.title = "登入"
          }

        setupUI()
        setupActions()
        bindViewModel()
        enableTapToDismissKeyboard()
    }

    private func setupUI() {
        // 垂直堆疊
        let stack = UIStackView(arrangedSubviews: [logoLabel, googleButton, registerButton, activity])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill

        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(40)
            make.centerY.equalToSuperview().offset(-40)
        }

        logoLabel.snp.makeConstraints { $0.height.equalTo(48) }
    }

    private func setupActions() {
        googleButton.addTarget(self, action: #selector(handleGoogleSignIn), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
    }

    //綁定閉包輸出
    private func bindViewModel() {
        viewModel.onLoading = { [weak self] loading in
            DispatchQueue.main.async {
                   loading ? self?.activity.startAnimating() : self?.activity.stopAnimating()
                   self?.setControlsEnabled(!loading)
               }
        }
        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                self?.showAlert(title: "錯誤", message: message)
            }
        }
        viewModel.onLoginSuccess = { [weak self] user in
            DispatchQueue.main.async {
                //進入主畫面
                self?.goToHomePage()
            }
        }
        viewModel.onRequireRegistration = { [weak self] user in
            DispatchQueue.main.async {
                try? Auth.auth().signOut() // 若策略是不允許未註冊直接登入
                self?.showAlert(title: "尚未註冊", message: "此 Gmail（\(user.email ?? "")）尚未在本 App 建立帳號")
                //導向註冊補資料頁
            }
        }
        viewModel.onProceedToRegister = { [weak self] in
               DispatchQueue.main.async {
                   let vc = RegisterViewController()   // 這頁只做姓名/電話建立 users{uid}
                   self?.navigationController?.pushViewController(vc, animated: true)
               }
           }
    }

    private func setControlsEnabled(_ enabled: Bool) {
        googleButton.isEnabled = enabled
        registerButton.isEnabled = enabled
        googleButton.alpha = enabled ? 1.0 : 0.6
        registerButton.alpha = enabled ? 1.0 : 0.6
    }


    // 藍色過場動畫
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showSplashAndFade()
    }
    
    //按鈕事件呼叫 ViewModel
    @objc private func handleGoogleSignIn() {
          viewModel.googleTapped(presenting: self)
      }
    
    @objc private func handleGoogle() {
        viewModel.googleTapped(presenting: self)
    }

    @objc private func handleRegister() {
        // 跳轉註冊頁
        viewModel.startRegistration(presenting: self)
    }
    
    private func goToHomePage() {
        let home = HomePageViewController()

        if let window = view.window ?? UIApplication.shared.windows.first {
            // 換 root：不會出現返回到登入頁的箭頭
            window.rootViewController = UINavigationController(rootViewController: home)
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
            window.makeKeyAndVisible()
        } else {
            // 後備方案：若拿不到 window，就用 push
            navigationController?.setViewControllers([home], animated: true)
        }
    }
    
    //過場動畫
    private func showSplashAndFade() {
        let splash = UIView(frame: view.bounds)
        splash.backgroundColor = .blue
        let logo = UILabel()
        logo.text = "海眠"
        logo.font = .boldSystemFont(ofSize: 28)
        logo.textColor = .white
        logo.textAlignment = .center
        splash.addSubview(logo)
        view.addSubview(splash)
        logo.snp.makeConstraints { $0.center.equalToSuperview() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIView.animate(withDuration: 0.5, animations: { splash.alpha = 0 }) { _ in
                splash.removeFromSuperview()
            }
        }
    }
}

extension UIViewController {
    func showAlert(title: String, message: String,
                   okTitle: String = "OK",
                   completion: (() -> Void)? = nil) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: okTitle, style: .default) { _ in completion?() })
        present(ac, animated: true)
    }
}
