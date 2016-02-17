//
//  LoginViewController.swift
//  votaciones
//
//  Created by Armando Trujillo on 18/02/15.
//  Copyright (c) 2015 RedRabbit. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var btnIngresar : UIButton!
    @IBOutlet var txtUsuario : UITextField!
    @IBOutlet var txtContra : UITextField!
    @IBOutlet var viewForm : UIView!
    private var isFristLoad = true
    private var isKeyBoardVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeView()
    
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "keyboardDisappeared", name: UIKeyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: "keyboardAppeared", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "changeOrentation", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        /*txtUsuario.text = "rcota"
        txtContra.text = "1234"
        
        txtUsuario.text = "jhernandez"
        txtContra.text = "123"
        */
        
       txtUsuario.text = "yrincon"
       txtContra.text = "123"
        
        //txtUsuario.text = "yrincon"
        //txtContra.text = "123"
        
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey("usuario")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("nom_Usuario")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("admin")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("urlImagenUsuario")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("id_diputado")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("imagenUsuario")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("id_rowVotoActivado")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("id_votacion")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("sn_asistenciahoy")
        NSUserDefaults.standardUserDefaults().setObject(false, forKey: "navigationView")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func customizeView(){
        btnIngresar.layer.borderWidth = 1
        btnIngresar.layer.borderColor = UIColor.darkGrayColor().CGColor
        btnIngresar.layer.cornerRadius = 5
        btnIngresar.tintColor = UIColor.blackColor()
        
        txtUsuario.layer.borderColor = UIColor.orangeColor().CGColor
        txtUsuario.layer.borderWidth = 1
        txtContra.layer.borderColor = UIColor.orangeColor().CGColor
        txtContra.layer.borderWidth = 1
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Buttons Actions
    
    @IBAction func touchIngresar(sender: AnyObject) {
        
        /*iosAudio = IosAudioController()
        iosAudio.start()
        
        return*/
       
        /*let AlertView = CustomAlertViewController()
        AlertView.text = "prueba de alertView"
        self.presentViewController(AlertView, animated: true, completion: nil)
        return
          */
            
        //view.endEditing(true)
        if txtUsuario.text == "" {
           // UIAlertView(title: "Advertencia", message: "Falta ingresar Usuario", delegate: nil, cancelButtonTitle: "Aceptar").show()
            let AlertView = CustomAlertViewController()
            AlertView.text = "Falta ingresar Usuario"
            self.presentViewController(AlertView, animated: true, completion: nil)
            return
        } else if txtContra.text == "" {
            //UIAlertView(title: "Advertencia", message: "Falta ingresar Contraseña", delegate: nil, cancelButtonTitle: "Aceptar").show()
            let AlertView = CustomAlertViewController()
            AlertView.text = "Falta ingresar Contraseña"
            self.presentViewController(AlertView, animated: true, completion: nil)
            return
        }
        
        if !Reachability.isConnectedToNetwork() {
            Fetcher.msgInternet().show()
            return
        }

        var downloadQueue :dispatch_queue_t = dispatch_queue_create("callListSesion", nil)
        
        var spinner : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle:UIActivityIndicatorViewStyle.WhiteLarge)
        spinner.color = UIColor.blackColor()
        let viewSpinner : UIView = UIView(frame: CGRectMake(0, 0, 2000, 2000))
        viewSpinner.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleTopMargin | .FlexibleBottomMargin
        
        viewSpinner.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        viewSpinner.center = CGPointMake(view.frame.size.width/2.0, view.frame.size.height/2.0)
        spinner.center = CGPointMake(viewSpinner.frame.size.width/2.0, viewSpinner.frame.size.height/2.0)
        viewSpinner.addSubview(spinner)
        
        self.view.addSubview(viewSpinner)
        spinner.startAnimating()
        
        dispatch_async(downloadQueue, {

            let dic = Fetcher.validateUsuer(self.txtUsuario.text, andPassword: self.txtContra.text)
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if (dic.objectForKey("sn_accesoCorrecto")?.boolValue != nil) {
                    if (dic.objectForKey("sn_accesoCorrecto") as! Bool) {

                        NSUserDefaults.standardUserDefaults().setObject(self.txtUsuario.text, forKey: "usuario")
                        NSUserDefaults.standardUserDefaults().setObject(dic.objectForKey("nb_empleado"), forKey: "nom_Usuario")
                        NSUserDefaults.standardUserDefaults().setObject(dic.objectForKey("sn_presidente"), forKey: "admin")
                        NSUserDefaults.standardUserDefaults().setObject(dic.objectForKey("de_imagenDiputado"), forKey: "urlImagenUsuario")
                        NSUserDefaults.standardUserDefaults().setObject(dic.objectForKey("id_diputado"), forKey: "id_diputado")
                        NSUserDefaults.standardUserDefaults().setObject(dic.objectForKey("sn_grafica"), forKey: "sn_grafica")
                        NSUserDefaults.standardUserDefaults().setObject(dic.objectForKey("id_usuario"), forKey: "id_usuario")
                        NSUserDefaults.standardUserDefaults().setObject(dic.objectForKey("sn_asistenciahoy"), forKey: "sn_asistenciahoy")
                        NSUserDefaults.standardUserDefaults().setObject(dic.objectForKey("sn_iniciada"), forKey: "sn_iniciada")
                        NSUserDefaults.standardUserDefaults().setObject(dic.objectForKey("sn_permitirasistencia"), forKey: "sn_permitirasistencia")
                        NSUserDefaults.standardUserDefaults().setObject(NSNumber(int: -1), forKey: "id_rowVotoActivado")
                        NSUserDefaults.standardUserDefaults().setObject(NSNumber(int: -1), forKey: "id_votacion")
                        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "navigationView")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        //recordarAsistencia
                        
                        
                        if !(dic.objectForKey("sn_grafica") as! Bool) {
                            var RootController = self.storyboard?.instantiateViewControllerWithIdentifier("RootViewController") as! RootViewController
                            self.presentViewController(RootController, animated: true, completion: nil)
                            
                            if (dic.objectForKey("sn_permitirasistencia") as! Bool) {
                                NSNotificationCenter.defaultCenter().postNotificationName("recordarAsistencia", object: nil)
                            }
                            
                        } else {
                            let  esperarController = self.storyboard?.instantiateViewControllerWithIdentifier("graficaNavigation") as! UINavigationController
                            self.presentViewController(esperarController, animated: true, completion: nil)
                        }
                    } else {
                        //UIAlertView(title: "Advertencia", message: dic.objectForKey("mensaje") as? String, delegate: nil, cancelButtonTitle: "Aceptar").show()
                        let AlertView = CustomAlertViewController()
                        AlertView.text = dic.objectForKey("mensaje") as? String
                        self.presentViewController(AlertView, animated: true, completion: nil)
                    }
                }else {
                    //UIAlertView(title: "Advertencia", message: "No se pudo conectar en este momento con el servidor, vuelva a intentar mas tarde", delegate: nil, cancelButtonTitle: "Aceptar").show()
                    let AlertView = CustomAlertViewController()
                    AlertView.text = "No se pudo conectar en este momento con el servidor, vuelva a intentar mas tarde"
                    self.presentViewController(AlertView, animated: true, completion: nil)
                }
                
                spinner.stopAnimating()
                viewSpinner.removeFromSuperview()
            })
        })
    }
    
    // MARK: - TextField Delegate 
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == txtUsuario {
            txtContra.becomeFirstResponder()
        } else if (textField == txtContra) {
            touchIngresar("holo")
        }
        return true
    }
    
    // MARK: - KeyBoard Delegate 
    
    func changeOrentation() {
        if UIDevice.currentDevice().orientation.isLandscape {
            isKeyBoardVisible = false
        }
    }
    
    func keyboardAppeared() {
        if isKeyBoardVisible {
            return
        }
        
        if UIDevice.currentDevice().orientation.isLandscape {
            UIView.beginAnimations("animate", context: nil)
            UIView.setAnimationDuration(0.4)
            UIView.setAnimationBeginsFromCurrentState(false)

            viewForm.frame = CGRect(x: viewForm.frame.origin.x , y: viewForm.frame.origin.y-230 , width: viewForm.frame.size.width, height: viewForm.frame.size.height)
            UIView.commitAnimations()
            isKeyBoardVisible = true
        }
    }
    
    func keyboardDisappeared() {
        if isKeyBoardVisible && UIDevice.currentDevice().orientation.isLandscape {
            UIView.beginAnimations("animate", context: nil)
            UIView.setAnimationDuration(0.5)
            UIView.setAnimationBeginsFromCurrentState(false)
            
            viewForm.frame = CGRect(x: viewForm.frame.origin.x , y: viewForm.frame.origin.y+230 , width: viewForm.frame.size.width, height: viewForm.frame.size.height)
            UIView.commitAnimations()
            isKeyBoardVisible = false
            txtUsuario.resignFirstResponder()
            txtContra.resignFirstResponder()
        }
    }
}
