//
//  ViewController.swift
//  LifeCounter
//
//  Created by Evan Chang on 4/21/25.
//

import UIKit

class Player {
    var name: String
    var lifeTotal: Int
    var lifeLabel: UILabel
    var nameLabel: UILabel
    var buttonStack: UIStackView
    
    init(name: String) {
        self.name = name
        self.lifeTotal = 20
        
        self.nameLabel = UILabel()
        self.nameLabel.text = name
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.lifeLabel = UILabel()
        self.lifeLabel.text = "20"
        self.lifeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.buttonStack = UIStackView()
        self.buttonStack.distribution = .fillEqually
        self.buttonStack.spacing = 10
        self.buttonStack.translatesAutoresizingMaskIntoConstraints = false
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

class Game {
    var players: [Player]
    
    init(playerCount: Int = 2) {
        players = []
        for i in 1...playerCount {
            players.append(Player(name: "Player \(i)"))
        }
    }
    
    func checkGameStatus() -> String {
        for player in players {
            if player.isDefeated {
                return "\(player.name) LOSES!"
            }
        }
        return ""
    }
}

class ViewController: UIViewController {
    
    typealias ButtonAction = (Int, Int) -> Void
    
    private var game: Game!
    
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
        
        game = Game(playerCount: 2)
        
        setupMainStackView()
        setupPlayersUI()
        setupGameStatusLabel()
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
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80)
        ])
    }
    
    private func setupPlayersUI() {
        for (index, player) in game.players.enumerated() {
            let playerContainer = createPlayerContainer()
            mainStackView.addArrangedSubview(playerContainer)
            
            playerContainer.addSubview(player.nameLabel)
            playerContainer.addSubview(player.lifeLabel)
            playerContainer.addSubview(player.buttonStack)
            
            let adjustLifeAction: (Int, Int) -> Void = { [weak self] playerIndex, amount in
                guard let self = self else { return }
                self.game.players[playerIndex].adjustLife(by: amount)
                self.updateGameStatus()
            }
            
            let minus5Button = createButton(title: "-5") { adjustLifeAction(index, -5) }
            let minus1Button = createButton(title: "-1") { adjustLifeAction(index, -1) }
            let plus1Button = createButton(title: "+1") { adjustLifeAction(index, 1) }
            let plus5Button = createButton(title: "+5") { adjustLifeAction(index, 5) }
            
            player.buttonStack.addArrangedSubview(minus5Button)
            player.buttonStack.addArrangedSubview(minus1Button)
            player.buttonStack.addArrangedSubview(plus1Button)
            player.buttonStack.addArrangedSubview(plus5Button)
            
            NSLayoutConstraint.activate([
                player.nameLabel.topAnchor.constraint(equalTo: playerContainer.topAnchor, constant: 20),
                player.nameLabel.centerXAnchor.constraint(equalTo: playerContainer.centerXAnchor),
                
                player.lifeLabel.centerXAnchor.constraint(equalTo: playerContainer.centerXAnchor),
                player.lifeLabel.centerYAnchor.constraint(equalTo: playerContainer.centerYAnchor),
                
                player.buttonStack.leadingAnchor.constraint(equalTo: playerContainer.leadingAnchor, constant: 20),
                player.buttonStack.trailingAnchor.constraint(equalTo: playerContainer.trailingAnchor, constant: -20),
                player.buttonStack.bottomAnchor.constraint(equalTo: playerContainer.bottomAnchor, constant: -20),
                player.buttonStack.heightAnchor.constraint(equalToConstant: 50)
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
