//
//  LogInViewController.swift
//  logicGame
//
//  Created by Simone Scionti on 27/04/18.
//  Copyright © 2018 Mobo. All rights reserved.
//

import UIKit
import Firebase



class LogInViewController: UIViewController {
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var gameCodeTextField: UITextField!
    var myRandomID : String!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.isHidden = true
        self.errorLabel.isHidden = true
        gameCodeTextField.keyboardType = UIKeyboardType.numberPad
        
        
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        joinButton.layer.cornerRadius = 3.0
        joinButton.clipsToBounds = true
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

    @IBAction func joinClicked(_ sender: Any) {
        joinButton.isUserInteractionEnabled = false
        view.endEditing(true)
        self.activityIndicatorView.isHidden = false
        errorLabel.isHidden = true
        self.errorLabel.text = "Inserisci tutti i dati!"
        if let _ = usernameTextField.text , usernameTextField.text != "" , let _ = gameCodeTextField.text , gameCodeTextField.text != "" {
            
            let username = usernameTextField.text!
            if(username.count > 10) {
                self.errorLabel.text = "Non puoi superare 10 caratteri!"
                self.errorLabel.isHidden = false
                self.joinButton.isUserInteractionEnabled = true
                return
            }
            let gameCode = gameCodeTextField.text!
            let ref = Database.database().reference().child("lobby").child(gameCode)
            ref.child("started").observeSingleEvent(of: .value) { (snap) in
                if snap.exists(){
                    if snap.value as! Bool == false{
                        
                        //controllo se esiste già un utente con questo username
                        ref.child("players").queryOrdered(byChild: "username").queryEqual(toValue: username).observeSingleEvent(of: .value, with: { (snapUsername) in
                            if(!snapUsername.exists()){
                                print("partita non iniziata, mi inserisco")
                                let myAutoIDRef = ref.child("players").childByAutoId()
                                self.myRandomID =  myAutoIDRef.key
                                myAutoIDRef.child("username").setValue(username)
                                self.performSegue(withIdentifier: "segueToWaiting", sender: nil)
                            }
                            else{
                                print("cambia nome")
                                self.activityIndicatorView.isHidden = true
                                self.errorLabel.text = "Esiste già un utente con questo username!"
                                self.errorLabel.isHidden = false
                                self.joinButton.isUserInteractionEnabled = true
                            }
                        })
                        
                        
                    }
                    else {
                        print("partita iniziata")
                        self.activityIndicatorView.isHidden = true
                        self.errorLabel.text = "Partita iniziata, fai più in fretta la prossima volta!"
                        self.errorLabel.isHidden = false
                        self.joinButton.isUserInteractionEnabled = true
                    }
                }
                else{
                    self.activityIndicatorView.isHidden = true
                    self.errorLabel.text = "Nessuna partita con questo Game code!"
                    self.errorLabel.isHidden = false
                    self.joinButton.isUserInteractionEnabled = true
                }
            }
          
        }
        else {
            self.activityIndicatorView.isHidden = true
            errorLabel.isHidden = false
            joinButton.isUserInteractionEnabled = true
            
        }
        
        
        
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? WaitingViewController {
            vc.username = usernameTextField.text!
            vc.gameCode = gameCodeTextField.text!
            vc.myRandomID = myRandomID
        }
    }
}
