//
//  InitialViewController.swift
//  ARHero
//
//  Created by 新井崚平 on 2018/02/26.
//  Copyright © 2018年 RyoheiArai. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton! {
        didSet {
            startButton.layer.borderColor = #colorLiteral(red: 0.4056862593, green: 0.3735087514, blue: 1, alpha: 1)
            startButton.layer.borderWidth = 2
            startButton.backgroundColor = .black
            startButton.layer.cornerRadius = 13
        }
    }
    
    @IBAction func startMissionPressed(_ sender: UIButton) {
//        let sb = UIStoryboard(name: "Main", bundle: nil)
//        if let view = sb.instantiateViewController(withIdentifier: "ship") as? OnBoardShipViewController {
//            self.present(view, animated: true, completion: nil)
//        }
////
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let view = sb.instantiateViewController(withIdentifier: "game") as? ViewController {
            self.present(view, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
