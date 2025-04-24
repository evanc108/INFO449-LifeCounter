import UIKit

class Player {
    var name: String
    var lifeTotal: Int
    var lifeLabel: UILabel
    var nameLabel: UILabel
    var buttonStack: UIStackView
    var inputField: UITextField
    
    init(name: String) {
        self.name = name
        self.lifeTotal = 20
        
        self.nameLabel = UILabel()
        self.nameLabel.text = name
        self.nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.lifeLabel = UILabel()
        self.lifeLabel.text = "20"
        self.lifeLabel.font = .systemFont(ofSize: 36, weight: .bold)
        self.lifeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.buttonStack = UIStackView()
        self.buttonStack.distribution = .fill
        self.buttonStack.spacing = 8
        self.buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        self.inputField = UITextField()
        self.inputField.text = "5"
        self.inputField.keyboardType = .numberPad
        self.inputField.textAlignment = .center
        self.inputField.borderStyle = .roundedRect
        self.inputField.font = .systemFont(ofSize: 14)
        self.inputField.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func adjustLife(by lives: Int) {
        lifeTotal += lives
        lifeTotal = max(0, min(lifeTotal, 999))
        updateLifeLabel()
    }
    
    func updateLifeLabel() {
        lifeLabel.text = "\(lifeTotal)"
    }
    
    var isDefeated: Bool {
        return lifeTotal <= 0
    }
}

struct HistoryEntry {
    let playerName: String
    let lifeChange: Int
    let timestamp: Date
    
    var description: String {
        let sign = lifeChange > 0 ? "+" : "-"
        return "\(playerName) \(sign) \(abs(lifeChange))"
    }
}

class Game {
    var players: [Player]
    private var isGameStarted: Bool = false
    var history: [HistoryEntry] = []
    
    init(playerCount: Int = 4) {
        players = []
        for i in 1...playerCount {
            players.append(Player(name: "Player \(i)"))
        }
    }
    
    func addHistoryEntry(playerName: String, lifeChange: Int) {
        let entry = HistoryEntry(playerName: playerName, lifeChange: lifeChange, timestamp: Date())
        history.append(entry)
    }
    
    func addPlayer() -> Bool {
        guard players.count < 8 && !isGameStarted else { return false }
        let playerNumber = players.count + 1
        players.append(Player(name: "Player \(playerNumber)"))
        return true
    }
    
    func checkGameStatus() -> String {
        for player in players {
            if player.isDefeated {
                return "\(player.name) LOSES!"
            }
        }
        return ""
    }
    
    func hasGameStarted() -> Bool {
        return players.contains { $0.lifeTotal != 20 }
    }
    
    func updateGameStarted() {
        isGameStarted = hasGameStarted()
    }
    
    func canAddPlayer() -> Bool {
        return players.count < 8 && !isGameStarted
    }
}

class ViewController: UIViewController {
    
    typealias ButtonAction = (Int, Int) -> Void
    
    private var game: Game!
    
    private lazy var addPlayerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Player", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addPlayerTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var historyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("History", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(historyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var gameStatusLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        game = Game(playerCount: 4)
        
        setupAddPlayerButton()
        setupHistoryButton()
        setupMainStackView()
        setupPlayersUI()
        setupGameStatusLabel()
        adjustStackSpacing()
 
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    @objc private func historyButtonTapped() {
        let historyVC = HistoryViewController()
        historyVC.historyEntries = game.history
        let navController = UINavigationController(rootViewController: historyVC)
        present(navController, animated: true)
    }
    
    @objc private func addPlayerTapped() {
        guard game.canAddPlayer() else { return }
        
        if game.addPlayer() {
            mainStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            setupPlayersUI()
            updateAddPlayerButton()
            adjustStackSpacing()
        }
    }
    
    private func adjustStackSpacing() {
        let spacing: CGFloat = game.players.count > 6 ? 5 : game.players.count > 4 ? 10 : 20
        mainStackView.spacing = spacing
    }
    
    private func updateAddPlayerButton() {
        addPlayerButton.isEnabled = game.canAddPlayer()
        addPlayerButton.backgroundColor = game.canAddPlayer() ? .systemGreen : .systemGray
    }
    
    private func setupAddPlayerButton() {
        view.addSubview(addPlayerButton)
        
        NSLayoutConstraint.activate([
            addPlayerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            addPlayerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addPlayerButton.widthAnchor.constraint(equalToConstant: 120),
            addPlayerButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupHistoryButton() {
        view.addSubview(historyButton)
        
        NSLayoutConstraint.activate([
            historyButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            historyButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            historyButton.widthAnchor.constraint(equalToConstant: 120),
            historyButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else { return }
            
            if UIDevice.current.orientation.isLandscape {
                self.mainStackView.axis = .horizontal
            } else {
                self.mainStackView.axis = .vertical
            }
            
            self.view.layoutIfNeeded()
        })
    }
    
    private func setupMainStackView() {
        view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            mainStackView.topAnchor.constraint(equalTo: addPlayerButton.bottomAnchor, constant: 20),
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80)
        ])
    }
    
    private func setupPlayersUI() {
        for (index, player) in game.players.enumerated() {
            let playerContainer = createPlayerContainer()
            mainStackView.addArrangedSubview(playerContainer)

            player.buttonStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            playerContainer.addSubview(player.nameLabel)
            playerContainer.addSubview(player.lifeLabel)
            playerContainer.addSubview(player.buttonStack)
            
            let adjustLifeAction: (Int, Int) -> Void = { [weak self] playerIndex, amount in
                guard let self = self else { return }
                let player = self.game.players[playerIndex]
                
                if amount != 0 {
                    self.game.addHistoryEntry(playerName: player.name, lifeChange: amount)
                }
                
                player.adjustLife(by: amount)
                self.game.updateGameStarted()
                self.updateAddPlayerButton()
                self.updateGameStatus()
            }
            
            let minus1Button = createButton(title: "-1") { adjustLifeAction(index, -1) }
            let plus1Button = createButton(title: "+1") { adjustLifeAction(index, 1) }
            
            let minusCustomButton = createButton(title: "-") { [weak self] in
                guard let self = self else { return }
                if let customAmount = Int(self.game.players[index].inputField.text ?? "0") {
                    adjustLifeAction(index, -customAmount)
                }
            }
            
            let plusCustomButton = createButton(title: "+") { [weak self] in
                guard let self = self else { return }
                if let customAmount = Int(self.game.players[index].inputField.text ?? "0") {
                    adjustLifeAction(index, customAmount)
                }
            }
            
            player.buttonStack.addArrangedSubview(minus1Button)
            player.buttonStack.addArrangedSubview(plus1Button)
            player.buttonStack.addArrangedSubview(minusCustomButton)
            player.buttonStack.addArrangedSubview(player.inputField)
            player.buttonStack.addArrangedSubview(plusCustomButton)
 
            minus1Button.widthAnchor.constraint(equalToConstant: 36).isActive = true
            plus1Button.widthAnchor.constraint(equalToConstant: 36).isActive = true
            minusCustomButton.widthAnchor.constraint(equalToConstant: 36).isActive = true
            plusCustomButton.widthAnchor.constraint(equalToConstant: 36).isActive = true
            player.inputField.widthAnchor.constraint(equalToConstant: 50).isActive = true

            
            player.lifeLabel.font = .systemFont(ofSize: 10, weight: .bold)
            player.nameLabel.font = .systemFont(ofSize: 10, weight: .medium)

            let topPadding: CGFloat = game.players.count > 6 ? 5 : 10
            let bottomPadding: CGFloat = game.players.count > 6 ? 5 : 10
            
            NSLayoutConstraint.activate([
                player.nameLabel.topAnchor.constraint(equalTo: playerContainer.topAnchor, constant: topPadding),
                player.nameLabel.centerXAnchor.constraint(equalTo: playerContainer.centerXAnchor),
                
                player.lifeLabel.centerXAnchor.constraint(equalTo: playerContainer.centerXAnchor),
                player.lifeLabel.centerYAnchor.constraint(equalTo: playerContainer.centerYAnchor, constant: -10),
                
                player.buttonStack.centerXAnchor.constraint(equalTo: playerContainer.centerXAnchor),
                player.buttonStack.bottomAnchor.constraint(equalTo: playerContainer.bottomAnchor, constant: -bottomPadding),
                player.buttonStack.heightAnchor.constraint(equalToConstant: 36)
            ])
        }
    }
    
    private func setupGameStatusLabel() {
        view.addSubview(gameStatusLabel)
        
        NSLayoutConstraint.activate([
            gameStatusLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            gameStatusLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            gameStatusLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            gameStatusLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func createPlayerContainer() -> UIView {
        let container = UIView()
        container.clipsToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }
    
    private func createButton(title: String, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    private func updateGameStatus() {
        gameStatusLabel.text = game.checkGameStatus()
    }
}

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var historyEntries: [HistoryEntry] = []
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.dataSource = self
        table.delegate = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "History"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissHistory))
        
        setupTableView()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func dismissHistory() {
        dismiss(animated: true)
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        let entry = historyEntries[indexPath.row]
        cell.textLabel?.text = entry.description
        cell.textLabel?.numberOfLines = 0
        return cell
    }
}
