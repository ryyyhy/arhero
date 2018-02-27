//
//  ViewController.swift
//  ARHero
//
//  Created by 新井崚平 on 2018/02/23.
//  Copyright © 2018年 RyoheiArai. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AudioToolbox.AudioServices
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var earthStateNotification: UILabel! {
        didSet {
        }
    }
    @IBOutlet weak var playAgainButton: UIButton! {
        didSet {
            playAgainButton.layer.borderColor = #colorLiteral(red: 0.4056862593, green: 0.3735087514, blue: 1, alpha: 1)
            playAgainButton.layer.borderWidth = 2
            playAgainButton.backgroundColor = .black
            playAgainButton.layer.cornerRadius = 13
        }
    }
    @IBOutlet weak var gameOverView: UIView! {
        didSet {
            gameOverView.isHidden = true
            gameOverView.layer.cornerRadius = 10
        }
    }
    
    @IBAction func playAgain(_ sender: UIButton) {
        gameOverView.isHidden = true
        earthStateNotification.isHidden = false
        startGame()
    }
    
    @IBOutlet weak var leftMissileNumber: UILabel! {
        didSet {
            self.leftMissileNumber.text = "\(usableMissilesNumber)"
        }
    }
    
    @IBOutlet weak var demolishedMeterorNumber: UILabel! {
        didSet {
            self.demolishedMeterorNumber.text = "\(destroyedMeterorNumber)"
        }
    }
    
    @IBOutlet weak var clearedMeteror: UILabel!
    @IBOutlet weak var heroLevel: UILabel!
    @IBOutlet weak var bagde: UILabel!
    
    // Game Elements
    var earthHP = 1000
    var usableMissilesNumber = 50
    var destroyedMeterorNumber = 0
    let maxMeterorNuumber = 30
    
    struct AspectRatio {
        static let width: CGFloat = 2100
        static let height: CGFloat = 1850
    }
    
    var playerNode: SKVideoNode!
    var videoPlayer: AVPlayer!
    var videoSound: AVAudioPlayer!
    var earth: SCNNode!
    var meterors = [SCNNode]()
    var ships = [SCNNode]()
    var player: AVAudioPlayer! = nil
    var backgroundSoundPlayer: AVAudioPlayer! = nil
    var approaching = false
    let aimImageView = UIImageView()
    var overlay: SKOverlay!
    var progressBar: ProgressBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.antialiasingMode = .multisampling4X
        sceneView.autoenablesDefaultLighting = true
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.shoot))
        
        overlay = SKOverlay(size: self.sceneView.bounds.size)
        progressBar = overlay.progressBar
        self.sceneView.overlaySKScene = overlay
        progressBar.currentProgress = 1.0
        aimImageView.image = UIImage(named: "aim")
        aimImageView.center = self.sceneView.center
        
        self.sceneView.addGestureRecognizer(tap)
        self.sceneView.addSubview(self.earthStateNotification)
        self.sceneView.addSubview(aimImageView)
        
        startGame()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    // MARK: - Game Functionality
    func configureSession() {
        if ARWorldTrackingConfiguration.isSupported {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = ARWorldTrackingConfiguration.PlaneDetection.horizontal
            sceneView.session.run(configuration)
        } else {
            let configuration = AROrientationTrackingConfiguration()
            sceneView.session.run(configuration)
        }
    }
    
    func setUI() {
        DispatchQueue.main.async {
            self.earthStateNotification.dropShadow(color: .white, offSet: CGSize(width: -1, height: 1))
            self.earthStateNotification.layer.cornerRadius = 13
            self.earthStateNotification.layer.borderWidth = 3
            self.earthStateNotification.backgroundColor = .white
            self.earthStateNotification.textColor = .black
            self.earthStateNotification.layer.borderColor = UIColor.black.cgColor
            self.earthStateNotification.clipsToBounds = true
            self.destroyedMeterorNumber = 0
            self.usableMissilesNumber = 50
            self.demolishedMeterorNumber.text = "\(self.destroyedMeterorNumber)"
            self.leftMissileNumber.text = "\(self.usableMissilesNumber)"
        }
    }
    
    func startGame() {
        earthHP = 1000
        progressBar.reset()
        changeNotification(state: .notHurt)
        setUI()
        prepareForGameEnvironment()
        
        playWarSound()
        
        self.setBackgroundSounds(ofType: .thruster)
        self.setBackgroundSounds(ofType: .alert)
    }
    
    // MARK: - Setup the environment
    
    func prepareForGameEnvironment() {
        createEarth()
        createMeterors()
        createShips()
        
        automaticMissileFromShips(isEnabled: false)
    }
    
    func createMeterors() {
        
        for i in 1...50 {
            let vec = SCNVector3(
                earth.position.x + floatBetween(-3 * Float(i), and: 3 * Float(i)),
                earth.position.y + floatBetween(-3 * Float(i), and: 3 * Float(i)),
                earth.position.z + floatBetween(-3 * Float(i), and: 3 * Float(i))
            )
            let attackingMeterorSize = floatBetween(0.1, and: 0.2)
            let sphere = SCNSphere(radius: CGFloat(attackingMeterorSize))
            var uiimage = UIImage()
            if i % 2 == 0 {
                uiimage = UIImage(named: "rock.jpg")!
            } else {
                uiimage =  #imageLiteral(resourceName: "mercury")
            }
            let meteror = planetModeler(geometry: sphere, diffuse: uiimage, specular: nil, emission: nil, normal: nil, position: vec)
            meteror.name = "meteror" + "-" + "\(i)"
            let shape = SCNPhysicsShape(geometry: sphere, options: nil)
            meteror.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
            meteror.physicsBody?.isAffectedByGravity = false
            meteror.physicsBody?.categoryBitMask = CollisionTypes.otherPhysics.rawValue
            meteror.physicsBody?.contactTestBitMask = CollisionTypes.earthPhysics.rawValue
            meteror.physicsBody?.collisionBitMask = CollisionTypes.earthPhysics.rawValue
            self.sceneView.scene.rootNode.addChildNode(meteror)
            meterors.append(meteror)
            let duration = floatBetween(Float(30 * i), and: 100)
            let action = SCNAction.move(to: earth.position, duration: TimeInterval(duration))
            let rotatingAction = SCNAction.repeatForever(SCNAction.rotateBy(x: CGFloat(360.degreesToRadians), y: 0, z: 0, duration: 10))
            meteror.runAction(rotatingAction)
            meteror.runAction(action)
            if let fireParticle = SCNParticleSystem(named: "fire.scnp", inDirectory: nil) {
                fireParticle.particleSize = 1
                fireParticle.acceleration = earth.position
                meteror.addParticleSystem(fireParticle)
            }
        }
    }
    
    func createEarth() {
        let sphere = SCNSphere(radius: 0.3)
        earth = planetModeler(geometry: sphere, diffuse: #imageLiteral(resourceName: "earth-day") , specular: #imageLiteral(resourceName: "earth-specular"), emission:  #imageLiteral(resourceName: "earth_night"), normal: #imageLiteral(resourceName: "earth_normal"), position: EarthPosition.position)
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        earth.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        earth.physicsBody?.isAffectedByGravity = false
        earth.physicsBody?.categoryBitMask = CollisionTypes.earthPhysics.rawValue
        earth.physicsBody?.contactTestBitMask = CollisionTypes.otherPhysics.rawValue
        earth.physicsBody?.collisionBitMask = CollisionTypes.otherPhysics.rawValue
        earth.name = "earth"
        self.sceneView.scene.rootNode.addChildNode(earth)
        let earthAction = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 50))
        earth.runAction(earthAction)
    }
    
    func createShips() {
        for _ in 1...5 {
            if let node = SCNScene(named: "art.scnassets/ship.scn") {
                if let ship = node.rootNode.childNode(withName: "ship", recursively: false) {
                    ship.name = "ship"
                    ship.position = SCNVector3(
                        earth.position.x + floatBetween(-2, and: 2),
                        earth.position.y + floatBetween(-2, and: 2),
                        earth.position.z + floatBetween(-2, and: 2)
                    )
                    ship.scale.x = 0.2
                    ship.scale.y = 0.2
                    ship.scale.z = 0.2
                    let convert = ship.convertVector(ship.position, to: earth)
                    let pos = SCNVector3.init(convert.x + 0.1, convert.y, convert.z)
                    ship.position = earth.convertVector(pos, to: ship)
                    self.sceneView.scene.rootNode.addChildNode(ship)
                    let rotateAction = SCNAction.rotate(by: 60, around: earth.position, duration: 30)
                    ship.runAction(rotateAction)
                }
            }
        }
    }
    
    func planetModeler(geometry: SCNGeometry, diffuse: UIImage,
                       specular: UIImage?, emission: UIImage?, normal: UIImage?, position: SCNVector3) -> SolarNode {
        let planet = SolarNode(geometry: geometry)
        planet.geometry?.firstMaterial?.diffuse.contents = diffuse
        planet.geometry?.firstMaterial?.specular.contents = specular
        planet.geometry?.firstMaterial?.emission.contents = emission
        planet.geometry?.firstMaterial?.normal.contents = normal
        planet.geometry?.firstMaterial?.locksAmbientWithDiffuse = true
        planet.geometry?.firstMaterial?.shininess = 0.1
        planet.geometry?.firstMaterial?.specular.intensity = 0.5
        planet.position = position
        return planet
    }
    
    func startPlayMeteroVideo() {
        if videoPlayer != nil {
            videoPlayer = nil
        } else {
            guard let bundlePath = Bundle.main.path(forResource: "meteror", ofType: "mp4") else { return }
            videoPlayer = AVPlayer(url: URL(fileURLWithPath: bundlePath))
            showScreen(x: 0, y: 0.5, z: -1.0)
        }
    }
    
    func showScreen(x: Float, y: Float, z: Float) {
        // place AVPlayer on SKVideoNode
        playerNode = SKVideoNode(avPlayer: videoPlayer)
        // flip video upside down
        playerNode.yScale = -1
        // create SKScene and set player node on it
        let spriteKitScene = SKScene(size: CGSize(width: AspectRatio.width, height: AspectRatio.height))
        spriteKitScene.scaleMode = .aspectFit
        spriteKitScene.backgroundColor = .blue
        playerNode.position = CGPoint(x: spriteKitScene.size.width/2, y: spriteKitScene.size.height/2)
        playerNode.size = spriteKitScene.size
        spriteKitScene.addChild(playerNode)
        
        // create 3D SCNNode and set SKScene as a material
        let videoNode = SCNNode()
        videoNode.geometry = SCNPlane(width: 1, height: 0.5)
        videoNode.geometry?.firstMaterial?.diffuse.contents = spriteKitScene
        videoNode.geometry?.firstMaterial?.isDoubleSided = true
        // place SCNNode inside ARKit 3D coordinate space
        videoNode.position.x = self.getUserVector().1.x
        videoNode.position.y = self.getUserVector().1.y + 0.5
        videoNode.position.z = self.getUserVector().1.z - 0.5
        
        self.sceneView.scene.rootNode.addChildNode(videoNode)
        playerNode.play()
    }
    
    // MARK: - ARSCNViewDelegate
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    
    
    func automaticMissileFromShips(isEnabled: Bool) { }
    
    func getUserVector() -> (SCNVector3, SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform)
            // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
            // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43)
            // location of camera in world space
            return (dir, pos)
        }
        return (SCNVector3(0, 0, 0), SCNVector3(0, 0, -0.2))
    }
    
    func setBackgroundSounds(ofType effect: SoundEffect) {
        do {
            if let effectURL = Bundle.main.url(forResource: effect.rawValue, withExtension: "wav") {
                backgroundSoundPlayer = try AVAudioPlayer(contentsOf: effectURL)
                backgroundSoundPlayer.rate = -1
                backgroundSoundPlayer.play()
            }
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func playWarSound() {
        do {
            if let effectURL = Bundle.main.url(forResource: "meteror", withExtension: "mp4") {
                videoSound = try AVAudioPlayer(contentsOf: effectURL)
                videoSound.play()
            }
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func playSoundEffect(ofType effect: SoundEffect) {
        var ex = ""
        if effect == .explosion || effect == .collision {
            ex = "mp3"
        } else {
            ex = "wav"
        }
        DispatchQueue.main.async {
            do {
                if let effectURL = Bundle.main.url(forResource: effect.rawValue, withExtension: ex) {
                    self.player = try AVAudioPlayer(contentsOf: effectURL)
                    self.player.play()
                }
            }
            catch let error as NSError {
                print(error.description)
            }
        }
    }
    
    
    func removeNodeWithAnimation(_ node: SCNNode, explosion: Bool) {
        self.playSoundEffect(ofType: .explosion)
        if explosion {
            let particleSystem = SCNParticleSystem(named: "explosion", inDirectory: nil)
            particleSystem?.particleColor = .red
            particleSystem?.particleSize = 10
            let systemNode = SCNNode()
            systemNode.addParticleSystem(particleSystem!)
            // place explosion where node is
            systemNode.position = node.position
            sceneView.scene.rootNode.addChildNode(systemNode)
        }
        node.removeFromParentNode()
    }
    
    func gameOver(with score: Int) {
        
        var level = 0
        var badge = ""
        
        if score <= 5 {
            level = 1
            badge = "🚀"
        } else if score >= 6 && score <= 10 {
            level = 2
            badge = "🚀🚀"
        } else if score >= 11 && score <= 15 {
            level = 3
            badge = "🚀🚀🚀"
        } else if score >= 16 && score <= 20 {
            level = 4
            badge = "🚀🚀🚀🚀"
        } else if score >= 21 && score <= 25 {
            level = 5
            badge = "🚀🚀🚀🚀🚀"
        }
        
        DispatchQueue.main.async {
            self.clearedMeteror.text = "破壊した隕石の数: \(score)"
            self.heroLevel.text = "ヒーローレベル: \(level)"
            self.bagde.text = badge
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.sceneView.scene.rootNode.removeAllActions()
            self.sceneView.scene.rootNode.enumerateChildNodes { (node, stop) -> Void in
                node.removeFromParentNode()
            }
            self.meterors.removeAll()
            self.ships.removeAll()
            self.view.backgroundColor = .black
        }
        
        UIView.animate(withDuration: 2, animations: {
            
            DispatchQueue.main.async(execute: {
                
                self.gameOverView.isHidden = false
                self.earthStateNotification.isHidden = true
            })
            
        }) { ( _ ) in
            
        }
    }
}

extension ViewController {
    
    
    func runOutOfBullets() {
    }
    
    @objc func shoot() {
        addBullet()
    }
    
    func addBullet() {
        
        // added one missile so minus One MIssile!
        if usableMissilesNumber == 0 {
            // game over or get missile by watching Advertisement!
            //            gameOver() or watch Reward Video to gain 30 missiles
            
            let alert = UIAlertController(title: "ミサイルが足りない", message: "ミサイルを補充して地球を守ろう", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            let no = UIAlertAction(title: "No", style: .default, handler: nil)
            alert.addAction(ok)
            alert.addAction(no)
            self.present(alert, animated: true, completion: nil)
            print("NO missle to launch...")
            
        } else {
            
            let bulletsNode = Bullet()
            let (direction, position) = self.getUserVector()
            bulletsNode.position.x = position.x // SceneKit/AR coordinates are in meters
            bulletsNode.position.y = position.y + 0.05 // SceneKit/AR coordinates are in meters
            bulletsNode.position.z = position.z // SceneKit/AR coordinates are in meters
            bulletsNode.name = "bullet"
            bulletsNode.physicsBody?.applyForce(direction, asImpulse: true)
            bulletsNode.physicsBody?.velocity.x = direction.x * Float(5.0)
            bulletsNode.physicsBody?.velocity.y = direction.y * Float(5.0)
            bulletsNode.physicsBody?.velocity.z = direction.z * Float(5.0)
            sceneView.scene.rootNode.addChildNode(bulletsNode)
            
            self.playSoundEffect(ofType: .missile)
            
            usableMissilesNumber -= 1
            DispatchQueue.main.async {
                self.leftMissileNumber.text = "\(self.usableMissilesNumber)"
            }
        }
    }
    

}

extension ViewController : SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        
    }
    
    func vibrate() {
        AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate) {
            // do what you'd like now that the sound has completed playing
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("Begin contact!!")
        
        let firstNode = contact.nodeA
        let secondNode = contact.nodeB
        
        if firstNode.physicsBody?.categoryBitMask == CollisionTypes.bulletPhysics.rawValue && secondNode.physicsBody?.categoryBitMask == CollisionTypes.otherPhysics.rawValue || secondNode.physicsBody?.categoryBitMask == CollisionTypes.bulletPhysics.rawValue && firstNode.physicsBody?.categoryBitMask == CollisionTypes.otherPhysics.rawValue {
            
            print("Bullet and planet")
            // destoried a meteror so plus one!
            destroyedMeterorNumber += 1
            DispatchQueue.main.async {
                self.demolishedMeterorNumber.text = "\(self.destroyedMeterorNumber)"
            }
            
            removeNodeWithAnimation(firstNode, explosion: false)
            removeNodeWithAnimation(secondNode, explosion: false)
            
        } else if firstNode.physicsBody?.categoryBitMask == CollisionTypes.earthPhysics.rawValue && secondNode.physicsBody?.categoryBitMask == CollisionTypes.otherPhysics.rawValue || secondNode.physicsBody?.categoryBitMask == CollisionTypes.earthPhysics.rawValue && firstNode.physicsBody?.categoryBitMask == CollisionTypes.otherPhysics.rawValue  {
            
            removeNodeWithAnimation(secondNode, explosion: true)
            
            vibrate()
            monitorEarth()
            
            print("Planet and earth")
        } else {
            print("earth damaged, dont attack youself")
            monitorEarth()
        }

    }

    
    func monitorEarth() {
        
        if earthHP == 0 {
            gameOver(with: destroyedMeterorNumber)
        } else {
            earthHP -= 100
            progressBar.currentProgress -= CGFloat(0.1)
            if progressBar.currentProgress >= 0.5 &&
                progressBar.currentProgress <= 0.6 {
                progressBar.stateColor = .kindaDamaged
                changeNotification(state: .kindaDamaged)
            } else if progressBar.currentProgress <= 0.4 {
                progressBar.stateColor = .seriouslyDamaged
                changeNotification(state: .seriouslyDamaged)
            } else if progressBar.currentProgress <= 0.8 &&
                progressBar.currentProgress >= 1.0 {
                progressBar.stateColor = .notHurt
                changeNotification(state: .notHurt)
            }
            progressBar.updateCurrentEarthHP()
        }
        
    }

    func changeNotification(state: ProgressBar.StateColor) {
        switch state {
        case .notHurt:
            DispatchQueue.main.async {
                self.earthStateNotification.textColor = AlertMessage.help.color
                self.earthStateNotification.text = AlertMessage.help.message
            }
        case .kindaDamaged:
            DispatchQueue.main.async {
                self.earthStateNotification.backgroundColor = AlertMessage.hopeless.color
                self.earthStateNotification.text = AlertMessage.hopeless.message
            }
        case .seriouslyDamaged:
            DispatchQueue.main.async {
                self.earthStateNotification.backgroundColor = AlertMessage.die.color
                self.earthStateNotification.text = AlertMessage.die.message
            }
        }
    }

}
