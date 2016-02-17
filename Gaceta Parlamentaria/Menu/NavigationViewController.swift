//
//  NavigationViewController.swift
//  Culiacan
//
//  Created by Armando Trujillo on 08/12/14.
//  Copyright (c) 2014 RedRabbit. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {

    var view2 : UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //[self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
        //self.view.gestureRecognizers = [UIPanGestureRecognizer(target: self, action: "panGestureRecognized")]
        
        //var tapGesture = UIPanGestureRecognizer(target: self, action: "panGestureRecognized")
        self.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "panGestureRecognized:"))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "mostrarMensajeAsistencia", name: "mostrarMensajeAsistencia", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "mostrarMensajeVotacion", name: "mostrarMensajeVotacion", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func panGestureRecognized(sender : UIPanGestureRecognizer) {
        view.endEditing(true)
        frostedViewController.view.endEditing(true)

        frostedViewController.panGestureRecognized(sender)

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - mensaje recordar asistencia
    func mostrarMensajeAsistencia() {
        let AlertView = CustomAlertViewController()
        AlertView.text = "favor de registrar tu asistencia"
        self.presentViewController(AlertView, animated: true, completion: nil)
    }
    
    func mostrarMensajeVotacion(){
        let AlertView = CustomAlertViewController()
        AlertView.text = "Realiza tu Voto"
        AlertView.alertVoto = true
        self.presentViewController(AlertView, animated: true, completion: nil)
    }
}
