//
//  WaitingViewController.swift
//  logicGame
//
//  Created by Simone Scionti on 31/08/18.
//  Copyright © 2018 Mobo. All rights reserved.
//




// da controllare il dealloc della pagina
import UIKit
import Firebase

class WaitingViewController: UIViewController {
    var username : String!
    var gameCode : String!
    var myRandomID : String!
    var connectedUser = 1
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var myUsernameLabel: UILabel!
    @IBOutlet weak var connectedUsersLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        activityIndicator.transform = CGAffineTransform.init(scaleX: 1.8, y: 1.8)
        self.myUsernameLabel.text = username
        let lobbyRef = Database.database().reference().child("lobby").child(gameCode)
        lobbyRef.child("started").observe(.value) { (snap) in
            if snap.exists(){
                if snap.value as! Bool == true{
                    print("segueToQuiz")
                    lobbyRef.child("started").removeAllObservers()
                    lobbyRef.child("players").removeAllObservers()
                    self.performSegue(withIdentifier: "segueToQuiz", sender: nil)
                }
                else{print("notStarted") }
            }
            else{ print( "non esiste snap")}
        }
        lobbyRef.child("players").observe(.value) { (snap) in
            print("childAdded players")
            if(snap.exists()){
                
                print("esiste snap players childrenCount = ", String(snap.children.allObjects.count))
                self.connectedUser = Int(snap.children.allObjects.count)
                self.connectedUsersLabel.text = "Utenti connessi: "+String(self.connectedUser)
            }
        }
        
        // Do any additional setup after loading the view.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? QuizViewController{
            
            vc.gameCode = gameCode!
            vc.username = username!
            vc.myRandomID = myRandomID!
        }
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
