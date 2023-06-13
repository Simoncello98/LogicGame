//
//  EndViewController.swift
//  logicGame
//
//  Created by Simone Scionti on 08/09/18.
//  Copyright © 2018 Mobo. All rights reserved.
//

import UIKit

class EndViewController: UIViewController {

    var position : Int!
    var points : String!
    var username : String!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        dataView.layer.cornerRadius = 7
        dataView.clipsToBounds = true
        dataView.layer.masksToBounds = true
        positionLabel.text = "Ti sei classificato \(String(position))° 💪"
        pointsLabel.text = "Hai \(points!) punti! 👏"
        usernameLabel.text =  username!
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
