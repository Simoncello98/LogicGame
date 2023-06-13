//
//  QuizViewController.swift
//  logicGame
//
//  Created by Simone Scionti on 05/09/18.
//  Copyright © 2018 Mobo. All rights reserved.
//

import UIKit
import Firebase
class QuizViewController: UIViewController, UIWebViewDelegate{
    var myRandomID : String!
    var gameCode: String!
    var username : String!
    var teacherUID : String!
    var header : UIImageView!
    var questionNumber : Int = 1
    var textFieldO1 :  UITextField!
    var textFieldO2 :  UITextField!
    var textFieldO3 :  UITextField!
    var textFieldO4 :  UITextField!
    var sendButton : UIButton!
    var questionLabel : UILabel!
    var outputIsCorrect : Bool!
    var questionTimer : Timer!
    var timeToAnswer : Float!
    var myPoints : Float! = 0
    var answered : Bool! =  false
    var myPosition : Int!
    var thisQuestionPoints : Float! = 0
    var myNodeQuizRef : DatabaseReference!
    var questionEndRef : DatabaseReference!
    var questionTimeOutRef: DatabaseReference!
    @IBOutlet weak var waitingViewWaitingLabel: UILabel!
    @IBOutlet weak var QuestionResponseView: UIView!
    @IBOutlet weak var responseImageView: UIImageView!
    @IBOutlet weak var responseCorrectLabel: UILabel!
    @IBOutlet weak var responsePositionLabel: UILabel!
    @IBOutlet weak var responseBonusLabel: UILabel!
    @IBOutlet weak var responseUnderLabel: UILabel!
    @IBOutlet weak var responsePointsLabel: UILabel!
    @IBOutlet weak var waitingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var waitingViewUsernameLabel: UILabel!
    @IBOutlet weak var waitingViewActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var quizImageView: UIImageView!
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var dataView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.waitingView.isHidden = true
        self.hideKeyboardWhenTappedAround()
        webView.backgroundColor = UIColor.clear
        webView.isOpaque = false;
        webView.delegate = self
        webView.scrollView.isScrollEnabled = false
        webView.alpha = 0
        quizImageView.alpha = 0
        activityIndicator.startAnimating()
        activityIndicator.transform = CGAffineTransform.init(scaleX: 1.8, y: 1.8)
        waitingViewActivityIndicator.transform = CGAffineTransform.init(scaleX: 1.8, y: 1.8)
        waitingViewUsernameLabel.text = username
        QuestionResponseView.isHidden = true
        dataView.layer.cornerRadius = 7
        dataView.layer.masksToBounds = true
        dataView.clipsToBounds = true
        //prima volta che viene istanziata la view
        let gameRef = Database.database().reference().child("lobby").child(gameCode)
        gameRef.child("teacher").observeSingleEvent(of: .value) { (snap) in
            if(snap.exists()){
                self.teacherUID = snap.value as! String
                self.getQuestionData()
            }
        }
        //self.webView.backgroundColor = UIColor.init(patternImage: UIImage.init(named: "sfondo")!);
        // Do any additional setup after loading the view.
    }

    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIView.animate(withDuration: 0.6, animations: {
            self.webView.alpha = 1.0
            self.quizImageView.alpha = 1.0
        }, completion: { (flag) in
            print("animazione terminata")
            let newImg = self.getImageFromContext(view: self.quizImageView)
            self.webView.isHidden = true
            self.quizImageView.image = newImg
            //if(self.questionNumber == 2){ return;}
            if(screenWidth < 376){
                UIView.animate(withDuration: 0.3, animations: {
                    self.quizImageView.transform = CGAffineTransform.init(translationX: 0, y: 0)
                })
            }
            
            // fare in modo di trovar eil numero giusto pe rlo scale in modo che il width si auguale allo schermo
            let imageWidth = self.quizImageView.frame.width
            print("original imageWidth:", imageWidth)
            print("new imag Width * :", imageWidth * 1.5)
            
            
           
            
            
            let scale = screenWidth/imageWidth
            
            let screenSize =  screenHeight/screenWidth
            print("iPhone screen size" , screenSize)
            
            print("scale", scale);
            
            UIView.animate(withDuration: 0.4, animations: {
                let scaleTrans = CGAffineTransform.init(scaleX: scale, y: scale)
                let trasl = CGAffineTransform.init(translationX: 0, y: -5)
                self.quizImageView.transform = trasl.concatenating(scaleTrans)
            }, completion: { (flag2) in
                
                 print("seconda terminata")
                let imageViewTransformed = self.quizImageView
                self.header = UIImageView()
                if screenWidth < 370{// è un 5s
                    print("compatibilità 5-SE")
                    self.header.frame = CGRect(x: imageViewTransformed!.newTopLeft.x, y: imageViewTransformed!.newTopLeft.y-60, width: imageViewTransformed!.frame.size.width * 1.5, height: imageViewTransformed!.frame.size.height / 4)
                }
                else{
                    print("compatibilità 6-7-8-X")
                    self.header.frame = CGRect(x: imageViewTransformed!.newTopLeft.x, y: imageViewTransformed!.newTopLeft.y-5, width: imageViewTransformed!.frame.size.width * 1.5, height: imageViewTransformed!.frame.size.height / 6.6)
                }
                
                
                self.header.image = UIImage.init(named: "sfondo")
                self.header.alpha = 0.0
                self.view.addSubview(self.header)
                
                self.sendButton = UIButton()
                
                if screenWidth < 370 {
                    print("compatibilità 5s")
                    self.sendButton.frame = CGRect(x: imageViewTransformed!.newTopRight.x - 130, y: imageViewTransformed!.newTopRight.y + 25, width: 100, height: 35)
                }
                else{
                      self.sendButton.frame = CGRect(x: imageViewTransformed!.newTopRight.x - 130, y: imageViewTransformed!.newTopRight.y + 35, width: 100, height: 35)
                }
              
                self.sendButton.setTitle("Rispondi", for: UIControlState.normal)
                self.sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
                //self.sendButton.titleLabel?.font = UIFont(name: "Times New Roman, Bold", size: 20)
                
                self.sendButton.setTitleColor(#colorLiteral(red: 0, green: 0.490734756, blue: 0.01141213812, alpha: 1), for: UIControlState.normal)
                self.sendButton.backgroundColor = #colorLiteral(red: 0.9654372334, green: 0.959697783, blue: 0.9698489308, alpha: 1)
                self.sendButton.layer.cornerRadius = 5.0
                self.sendButton.clipsToBounds = true
                self.sendButton.layer.masksToBounds = true
                self.sendButton.addTarget(self, action: #selector(self.sendButtonClicked), for: .touchUpInside)
                self.sendButton.alpha = 0.0
                self.view.addSubview(self.sendButton)
                
                self.questionLabel = UILabel()
                if screenWidth < 370 {
                    print("compatibilità 5s")
                     self.questionLabel.frame = CGRect(x: imageViewTransformed!.newTopLeft.x + 25, y: imageViewTransformed!.newTopLeft.y + 20, width: 300, height: 45)
                     self.questionLabel.font = UIFont(name: "Times New Roman", size: 28)
                }
                else{
                     self.questionLabel.frame = CGRect(x: imageViewTransformed!.newTopLeft.x + 30, y: imageViewTransformed!.newTopLeft.y + 28, width: 300, height: 45)
                     self.questionLabel.font = UIFont(name: "Times New Roman", size: 34)
                }
               
               
                //questionLabel.font =  questionLabel.font.withSize(34)
                self.questionLabel.text = "Question " + String(self.questionNumber)
                self.questionLabel.textColor = UIColor.white
                self.questionLabel.alpha = 0.0
                self.view.addSubview(self.questionLabel)
                
                UIView.animate(withDuration: 0.4, animations: {
                    self.questionLabel.alpha = 1
                    self.header.alpha = 1
                    self.sendButton.alpha = 1
                })
                
                self.textFieldO1 =  UITextField()
                self.textFieldO2 =  UITextField()
                self.textFieldO3 =  UITextField()
                self.textFieldO4 =  UITextField()
                
                if (screenIntegerH == 568 && screenIntegerW == 320) {
                    print("compatibilità 5s")
                    self.textFieldO1.frame = CGRect(x: self.quizImageView.newTopRight.x - 53, y: self.quizImageView.newTopRight.y + 101, width: 40, height: 40)
                    
                }
                else if( screenIntegerH == 736 && screenIntegerW == 414){
                    self.textFieldO1.frame = CGRect(x: self.quizImageView.newTopRight.x - 63, y: self.quizImageView.newTopRight.y + 136, width: 40, height: 40)
                    
                }
                else{
                    self.textFieldO1.frame = CGRect(x: self.quizImageView.newTopRight.x - 58, y: self.quizImageView.newTopRight.y + 122, width: 40, height: 40)
                }
                
                self.textFieldO1.backgroundColor = UIColor.clear
                self.textFieldO1.textAlignment = NSTextAlignment.center
                self.textFieldO1.font = UIFont(name: "Arial", size: 24)
                self.textFieldO1.keyboardType =  UIKeyboardType.numberPad
                self.textFieldO1.layer.cornerRadius = 6.0
                self.textFieldO1.clipsToBounds = true
                self.textFieldO1.layer.masksToBounds = true
                self.view.addSubview(self.textFieldO1)
                
                
                if screenIntegerH == 568 && screenIntegerW == 320{
                    print("compatibilità 5s")
                    self.textFieldO2.frame = CGRect(x: self.quizImageView.newTopRight.x - 53, y: self.quizImageView.newTopRight.y + 234, width: 40, height: 40)
                }
                else if( screenIntegerH == 736 && screenIntegerW == 414){
                    print("compatibilità Plus")
                    self.textFieldO2.frame = CGRect(x: self.quizImageView.newTopRight.x - 62, y: self.quizImageView.newTopRight.y + 310, width: 40, height: 40)
                }
                else{
                    self.textFieldO2.frame = CGRect(x: self.quizImageView.newTopRight.x - 58, y: self.quizImageView.newTopRight.y + 280, width: 40, height: 40)
                }
                
                self.textFieldO2.backgroundColor = UIColor.clear
                self.textFieldO2.textAlignment = NSTextAlignment.center
                self.textFieldO2.font = UIFont(name: "Arial", size: 24)
                self.textFieldO2.keyboardType =  UIKeyboardType.numberPad
                self.textFieldO2.layer.cornerRadius = 6.0
                self.textFieldO2.clipsToBounds = true
                self.textFieldO2.layer.masksToBounds = true
                self.view.addSubview(self.textFieldO2)
                
                
                if screenIntegerH == 568 && screenIntegerW == 320 {
                    print("compatibilità 5s")
                    self.textFieldO3.frame = CGRect(x: self.quizImageView.newTopRight.x - 53, y: self.quizImageView.newBottomRight.y - 218, width: 40, height: 40)
                }
                else if( screenIntegerH == 736 && screenIntegerW == 414){
                    print("compatibilità Plus")
                    self.textFieldO3.frame = CGRect(x: self.quizImageView.newTopRight.x - 62, y: self.quizImageView.newBottomRight.y - 246, width: 40, height: 40)
                }
                else{
                    self.textFieldO3.frame = CGRect(x: self.quizImageView.newTopRight.x - 58, y: self.quizImageView.newBottomRight.y - 226, width: 40, height: 40)
                }
                
                self.textFieldO3.backgroundColor = UIColor.clear
                self.textFieldO3.textAlignment = NSTextAlignment.center
                self.textFieldO3.font = UIFont(name: "Arial", size: 24)
                self.textFieldO3.keyboardType =  UIKeyboardType.numberPad
                self.textFieldO3.layer.cornerRadius = 6.0
                self.textFieldO3.clipsToBounds = true
                self.textFieldO3.layer.masksToBounds = true
                self.view.addSubview(self.textFieldO3)
                
                
                if screenIntegerH == 568 && screenIntegerW == 320 {
                    print("compatibilità 5s")
                    self.textFieldO4.frame = CGRect(x: self.quizImageView.newTopRight.x - 53, y: self.quizImageView.newBottomRight.y - 61, width: 40, height: 40)
                }
                else if( screenIntegerH == 736 && screenIntegerW == 414){
                    print("compatibilità Plus")
                    self.textFieldO4.frame = CGRect(x: self.quizImageView.newTopRight.x - 62, y: self.quizImageView.newBottomRight.y - 72, width: 40, height: 40)
                }
                else{
                    self.textFieldO4.frame = CGRect(x: self.quizImageView.newTopRight.x - 58, y: self.quizImageView.newBottomRight.y - 67, width: 40, height: 40)
                }
                
                self.textFieldO4.backgroundColor = UIColor.clear
                self.textFieldO4.textAlignment = NSTextAlignment.center
                self.textFieldO4.font = UIFont(name: "Arial", size: 24)
                self.textFieldO4.keyboardType =  UIKeyboardType.numberPad
                self.textFieldO4.layer.cornerRadius = 6.0
                self.textFieldO4.clipsToBounds = true
                self.textFieldO4.layer.masksToBounds = true
                self.view.addSubview(self.textFieldO4)
                
                self.questionTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimerVar), userInfo: nil, repeats: true)
                
        
            })
        })
        
        
    }
    
   @objc func updateTimerVar(){
        timeToAnswer = timeToAnswer - 1
        print(timeToAnswer)
        if(timeToAnswer == 0){
            self.questionTimer.invalidate()
            timeToAnswer = 60
        }
    
    }
    func getQuestionData(){
        
        //inizializzo i dati utili ad ogni domanda
        observeAndControlAnswer()  // elimina automaticamente gli observer quando trova un valore
        observeQuestionNumberEnd() // elimina automaticamente gli observer quando trova un valore
        reinitObjects()
        let scaleTrans = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
        let trasl = CGAffineTransform.init(translationX: 0, y: 0)
        self.quizImageView.transform = trasl.concatenating(scaleTrans)
        self.quizImageView.image = nil
    
        
        UIView.animate(withDuration: 0.4, animations: {
            self.waitingView.alpha = 0.0
            self.QuestionResponseView.alpha = 0.0
        }) { (flag) in
            self.waitingView.isHidden = true
            self.QuestionResponseView.isHidden = true
            self.webView.alpha = 0
            self.quizImageView.alpha = 0
            self.webView.isHidden = false
            self.outputIsCorrect = false
        
            //prendo i dati della domanda n. (questionNumber)
            let teacherRef = Database.database().reference().child("users").child(self.teacherUID)
            teacherRef.child("quiz").child("Question " + String(self.questionNumber)).observeSingleEvent(of: .value) { (snap) in
                if(snap.exists()){
                    let value = snap.value as! [String:Any]
                    let linesHTML = value["lines"] as! String
                    let imageBase64 = value["imageBase64"] as! String
                    if screenWidth < 370{// è un 5s
                        print("traslo l'imageview, compatibilità 5s")
                        self.quizImageView.transform = CGAffineTransform.init(translationX: 0, y: 14)
                    }
                    
                    self.updateQuizViewWithData(lines: linesHTML, imageBase64: imageBase64)
                }
            }
        }
    }
    
    func  observeQuestionNumberEnd(){ // quando viene settato il campo end nella domanda sul db, viene eseguito il codice dentro lo snap di questa funzione
        questionEndRef = Database.database().reference().child("lobby").child(gameCode).child("Question " + String(self.questionNumber)).child("end")
        questionEndRef.observe(.value) { (snap) in
            if(snap.exists()){
                if(snap.value as?  Bool == true){
                    if(self.questionNumber ==  10){
                        // siamo arrivata alla 10ima domanda
                        self.questionEndRef.removeAllObservers()
                        self.performSegue(withIdentifier: "segueToEndViewController", sender: nil)
                        
                    }
                    else{
                        self.questionEndRef.removeAllObservers()
                        //prima rimuovo l'observer e poi ne creo uno con questionNUmber +1
                        self.questionNumber += 1
                        print("go to question " + String(self.questionNumber))
                        self.getQuestionData()
                    }
                    //nel sito alla lavagna viene mostrata l'immagine dell'output che era corretto
                    // e c'è un bottone grazie al quale il prof può andare alla domanda successiva
                    //appena viene premuto viene settato sul db il campo end a true, e qui nell'app viene dismesso il view controller che ci dava l'esito della risposta.
                }
            }
        }
    }
    func updateQuizViewWithData(lines : String , imageBase64 : String){
        print("inserisco immagine e linee")
        webView.loadHTMLString(lines, baseURL: nil)
        let newStr = imageBase64.replacingOccurrences(of: "data:image/png;base64,", with: "", options: .caseInsensitive)
        let imageData = Data(base64Encoded: newStr)
        let image = UIImage.init(data: imageData!)
        quizImageView.image = image
        
        
    }
    
    @objc func sendButtonClicked(sender: UIButton!){ // se viene invocata setta il  myOutput e mostra in anticipo la waiting view, sennò il myOutput è ""  e la waitingView viene mostrata quando sul database c'è il timeOut
        //controlla le textField
        textFieldO1.backgroundColor = UIColor.clear
        textFieldO2.backgroundColor = UIColor.clear
        textFieldO3.backgroundColor = UIColor.clear
        textFieldO4.backgroundColor = UIColor.clear
        var responseOk = true
        if textFieldO1.text == nil || textFieldO1.text == "" || (textFieldO1.text != "0" && textFieldO1.text != "1") {textFieldO1.backgroundColor = #colorLiteral(red: 0.8477363586, green: 0.2285090983, blue: 0.2242255211, alpha: 0.7995505137); responseOk = false }
        if textFieldO2.text == nil || textFieldO2.text == "" || (textFieldO2.text != "0" && textFieldO2.text != "1") {textFieldO2.backgroundColor = #colorLiteral(red: 0.8477363586, green: 0.2285090983, blue: 0.2242255211, alpha: 0.7995505137); responseOk = false }
        if textFieldO3.text == nil || textFieldO3.text == "" || (textFieldO3.text != "0" && textFieldO3.text != "1") { textFieldO3.backgroundColor = #colorLiteral(red: 0.8477363586, green: 0.2285090983, blue: 0.2242255211, alpha: 0.7995505137); responseOk = false}
        if textFieldO4.text == nil || textFieldO4.text == "" || (textFieldO4.text != "0" && textFieldO4.text != "1") {textFieldO4.backgroundColor = #colorLiteral(red: 0.8477363586, green: 0.2285090983, blue: 0.2242255211, alpha: 0.7995505137); responseOk = false}
        guard responseOk else {return}

        if let t1 = textFieldO1.text , let t2 = textFieldO2.text , let t3 = textFieldO3.text , let t4 = textFieldO4.text{
            if( t1 != "" && t2 != "" && t3 != "" && t4 != ""){
                
                
                let myOutput = t1+"-"+t2+"-"+t3+"-"+t4
                
                self.waitingViewWaitingLabel.text = "Attendo le risposte.."
                waitingView.alpha = 0.0
                waitingView.isHidden = false
                waitingView.layer.zPosition = 2
                waitingViewActivityIndicator.startAnimating()
                UIView.animate(withDuration: 0.4) {
                    self.waitingView.alpha = 1.0
                }
                self.sendButton.isUserInteractionEnabled = false
                self.questionTimer.invalidate()
                self.answered = true
                
                //setto sul db se ho risposto bene o no e lo setto anche in locale per capire poi cosa far apparire come immagine
                let gameRef = Database.database().reference().child("lobby").child(self.gameCode)
                let questionRef = Database.database().reference().child("users").child(self.teacherUID).child("quiz").child("Question " + String(self.questionNumber))
                questionRef.child("output").observeSingleEvent(of: .value, with: { (snap2) in
                    if(snap2.exists()){
                        let output = snap2.value as! String
                        let myref = Database.database().reference().child("lobby").child(self.gameCode).child("players").child(self.myRandomID).child("Question " + String(self.questionNumber))
                        
                        if output == myOutput{
                            //risposta esatta
                            self.outputIsCorrect = true//setto outputIsCorrect, ad ogni domanda all'inizio viene risettato a false
                            print("risposta esatta")
                            myref.child("correctOutput").setValue(true)
                            self.thisQuestionPoints = Float(10 + (self.timeToAnswer/10))
                            self.myPoints =  self.myPoints + self.thisQuestionPoints
                            print("punti questa domanda = ", self.thisQuestionPoints)
                            print("punti tot = ", self.myPoints)
                            print("punti per tempo = ", self.timeToAnswer/10)
                            
                            
                            gameRef.child("classification").child(self.myRandomID).setValue(self.myPoints)
                        }
                        else{
                            //risposta errata
                            
                            self.outputIsCorrect = false
                            print("risposta errata")
                            myref.child("correctOutput").setValue(false)
                            self.thisQuestionPoints = 0
                            print("punti questa domanda = ", self.thisQuestionPoints)
                            print("punti tot = ", self.myPoints)
                            //settare punteggio
                            gameRef.child("classification").child(self.myRandomID).setValue(self.myPoints)
                        }
                    }
                    else{
                        print("nessun output salvato dal docende sul db")
                    }
                })
                
            }
        }
        
        // all'inizio quando viene lanciata la domanda deve essere settato sul db il campo gameCode/questionNumber/output con la stringa di output "1-0-0-1"(esempio)
        //quando tutti hanno consegnato risposte oppure è scaduto il tempo, bisogna settare il campo sotto gameCode/questionNumber/ timeOut = true
        //quando viene cliccato il bottone next deve essere settato sul db il campo gameCode/questionNumber/end = true
        
        
        
        
    }
    
    func observeAndControlAnswer(){
        let gameRef = Database.database().reference().child("lobby").child(self.gameCode)
        let myref = Database.database().reference().child("lobby").child(self.gameCode).child("players").child(self.myRandomID).child("Question " + String(self.questionNumber))
        
        questionTimeOutRef = Database.database().reference().child("lobby").child(gameCode).child("Question " + String(self.questionNumber)).child("timeOut")
        questionTimeOutRef.observe(.value) { (snap) in
            if snap.exists(){
                self.questionTimeOutRef.removeAllObservers()
                if(snap.value as! Bool ==  true){ // tutte le risposte sono state consegnate
                    //mostro l'esito della propria risposta
                    if let _ = self.questionTimer{
                        self.questionTimer.invalidate()
                    }
                    self.waitingViewWaitingLabel.text = "Attendo il docente.."
                    if(self.waitingView.isHidden == true){ // se non avevo finito in tempo, mostro la waitingView
                        gameRef.child("classification").child(self.myRandomID).setValue(self.myPoints)
                        self.waitingView.alpha = 0.0
                        self.waitingView.isHidden = false
                        self.waitingView.layer.zPosition = 2
                        self.waitingViewActivityIndicator.startAnimating()
                        UIView.animate(withDuration: 0.4) {
                            self.waitingView.alpha = 1.0
                        }
                    }
                    let stringPoints = String(self.myPoints)
                    let strArray = stringPoints.components(separatedBy: ".")
                    var points : String!
                    if(strArray[1] == "0"){
                        points = strArray[0];
                    }
                    else{
                        points = String(self.myPoints)
                    }
                   
                    self.responsePointsLabel.text = "Hai \(points!) punti!👏 "
                    //self.responsePositionLabel.text =
                
                    if self.outputIsCorrect{
                        myref.child("correctOutput").setValue(true)
                        print("mostro risposta corretta")
                        
                        
                        let stringPoints = String(self.timeToAnswer/10)
                        let strArray = stringPoints.components(separatedBy: ".")
                        var points : String!
                        if(strArray[1] == "0"){
                            points = strArray[0];
                        }
                        else{
                            points = String(self.timeToAnswer/10)
                        }
                        self.responseBonusLabel.text = "\(points!) Punti Bonus per tempo risposta!"
                        self.responseCorrectLabel.text = "Risposta corretta!💪"
                        self.responseImageView.image = UIImage.init(named: "ok")
                    }
                    else{
                        myref.child("correctOutput").setValue(false)
                        self.responseBonusLabel.isHidden = true
                        if(self.answered){
                            print("mostro risposta errata")
                            self.responseCorrectLabel.text = "Risposta errata!😫"
                        }
                        else{
                            print("tempo scaduto")
                            self.responseCorrectLabel.text = "Tempo scaduto!😢"
                           
                        }
                        self.responseImageView.image = UIImage.init(named: "error")
                        //mostro il punteggio ma non il tempo di risposta di questa domanda
                    }
                    
                    print("scarico i dati dal DB riguardo pos e under")
                    //scarica i dati dal db riguardo position e under
                    
                        gameRef.child("classification").queryOrderedByValue().queryStarting(atValue: self.myPoints, childKey: self.myRandomID).observeSingleEvent(of: .value, with: { (snapPos) in
                            if snap.exists(){
                                let myPosition = Int(snapPos.childrenCount)
                                print("MY POSITION : ", myPosition)
                                self.responsePositionLabel.text = "Sei in posizione \(String(myPosition))✌"
                                self.myPosition = myPosition
                                
                                if(myPosition ==  1){ // se sono primo mostro tutto e mi fermo qui
                                    self.responseUnderLabel.isHidden = true
                                    self.QuestionResponseView.alpha = 0.0
                                    self.QuestionResponseView.isHidden = false
                                    self.QuestionResponseView.layer.zPosition = 3
                                    UIView.animate(withDuration: 0.4, animations: {
                                        self.QuestionResponseView.alpha = 1.0
                                        self.waitingViewActivityIndicator.alpha = 0.0
                                    }, completion: { (flag) in
                                        self.waitingViewActivityIndicator.isHidden = true
                                        self.waitingViewActivityIndicator.alpha = 1.0
                                    })
                                    
                                    
                                    
                                    return
                                }
                                
                                //scarico precedente a me
                                print("scarico dati precedente")
                                gameRef.child("classification").queryOrderedByValue().queryStarting(atValue: self.myPoints).queryLimited(toFirst: 2).observeSingleEvent(of:.value, with: { (snap) in
                                    print("scarico precedente")
                                    if snap.exists(){
                                        let dict = snap.value as! [String:Float]
                                        var prevUserUID : String = "undefined"
                                        var prevUserPoints : Float = 0
                                        var prevUserPointsString : String!
                                        for elem in dict{
                                            if elem.key != self.myRandomID{
                                                prevUserUID = elem.key
                                                prevUserPoints = elem.value
                                                let stringPoints = String(prevUserPoints)
                                                var newString = ""
                                                var last = false
                                                for c in stringPoints{
                                                    newString.append(c)
                                                    if(last == true) {break;}
                                                    if( c == ".") {last = true}
                                                }
                                                
                                                let strArray = newString.components(separatedBy: ".")
                                                var points : String!
                                                if(strArray[1] == "0"){
                                                    points = strArray[0];
                                                }
                                                else{
                                                    points = newString
                                                }
                                                prevUserPointsString = points
                                                
                                            }
                                        }
                                        
                                        gameRef.child("players").child(prevUserUID).child("username").observeSingleEvent(of: .value, with: { (snapPrevUser) in
                                            if(snapPrevUser.exists()){
                                                let prevUsername = snapPrevUser.value as! String
                                                
                                                //qui ho tutti i dati
                                                
                                                self.responseUnderLabel.text = "Sei sotto \(prevUsername) 😡, punti: \(prevUserPointsString!)"
                                                
                                                // mostro tutti i dati graficamente
                                                
                                                self.QuestionResponseView.alpha = 0.0
                                                self.QuestionResponseView.isHidden = false
                                                self.QuestionResponseView.layer.zPosition = 3
                                                
                                                UIView.animate(withDuration: 0.4, animations: {
                                                    self.QuestionResponseView.alpha = 1.0
                                                    self.waitingViewActivityIndicator.alpha = 0.0
                                                }, completion: { (flag) in
                                                    self.waitingViewActivityIndicator.isHidden = true
                                                    self.waitingViewActivityIndicator.alpha = 1.0
                                                })
                                                
                                                
                                            }
                                            
                                            
                                        })
                                        
                                        
                                        
                                    }
                                })
                            }
                        })
                    
                } // chiudo if snap = true
            }
        }
    }
    func reinitObjects(){
        
        
       
        
        
        if let _ = textFieldO1{
             textFieldO1.text = nil;
            textFieldO1.backgroundColor = UIColor.clear
        }
        if let _ = textFieldO2{
            textFieldO2.text = nil;
             textFieldO2.backgroundColor = UIColor.clear
        }
        if let _ = textFieldO3{
            textFieldO3.text = nil;
            textFieldO3.backgroundColor = UIColor.clear
        }
        if let _ = textFieldO4{
            textFieldO4.text = nil;
            textFieldO4.backgroundColor = UIColor.clear
        }
        if let _ = header{
            header.removeFromSuperview()
            header = nil;
        }
        if let _ = sendButton{
            sendButton.removeFromSuperview()
            sendButton = nil;
        }
        if let _ = questionLabel{
            questionLabel.removeFromSuperview()
            questionLabel = nil;
        }
        if let _ = questionTimer{
            questionTimer.invalidate()
            questionTimer = nil
        }
        
        
        self.timeToAnswer = 55
        self.thisQuestionPoints = 0
        self.answered = false
        
        self.responseBonusLabel.isHidden = false
        self.responseUnderLabel.isHidden =  false
        self.waitingViewActivityIndicator.isHidden = false
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EndViewController{
            vc.username = self.username
            vc.points = String(self.myPoints)
            vc.position = self.myPosition
        }
    }
    
    func getImageFromContext(view : UIView) -> UIImage{
        //create snapshot of the blurView
        let window = UIApplication.shared.delegate!.window!!
        //capture the entire window into an image
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, UIScreen.main.scale)
        window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        let windowImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //now position the image x/y away from the top-left corner to get the portion we want
        UIGraphicsBeginImageContext(view.frame.size)
        windowImage?.draw(at: CGPoint(x: -view.frame.origin.x, y: -view.frame.origin.y))
        let croppedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return croppedImage
    }
}

extension UIView {
    /// Helper to get pre transform frame
    var originalFrame: CGRect {
        let currentTransform = transform
        transform = .identity
        let originalFrame = frame
        transform = currentTransform
        return originalFrame
    }
    
    /// Helper to get point offset from center
    func centerOffset(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x - center.x, y: point.y - center.y)
    }
    
    /// Helper to get point back relative to center
    func pointRelativeToCenter(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x + center.x, y: point.y + center.y)
    }
    
    /// Helper to get point relative to transformed coords
    func newPointInView(_ point: CGPoint) -> CGPoint {
        // get offset from center
        let offset = centerOffset(point)
        // get transformed point
        let transformedPoint = offset.applying(transform)
        // make relative to center
        return pointRelativeToCenter(transformedPoint)
    }
    
    var newTopLeft: CGPoint {
        return newPointInView(originalFrame.origin)
    }
    
    var newTopRight: CGPoint {
        var point = originalFrame.origin
        point.x += originalFrame.width
        return newPointInView(point)
    }
    
    var newBottomLeft: CGPoint {
        var point = originalFrame.origin
        point.y += originalFrame.height
        return newPointInView(point)
    }
    
    var newBottomRight: CGPoint {
        var point = originalFrame.origin
        point.x += originalFrame.width
        point.y += originalFrame.height
        return newPointInView(point)
    }
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// Screen width.

public var screenIntegerH : Int {
    return Int(UIScreen.main.bounds.height)
}
public var screenIntegerW : Int {
    return Int(UIScreen.main.bounds.width)
}

public var screenWidth: CGFloat {
    return UIScreen.main.bounds.width
}

// Screen height.
public var screenHeight: CGFloat {
    return UIScreen.main.bounds.height
}

