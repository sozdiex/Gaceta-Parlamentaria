//
//  RecuperarContraViewController.swift
//  votaciones
//
//  Created by Armando Trujillo on 20/02/15.
//  Copyright (c) 2015 RedRabbit. All rights reserved.
//

import UIKit

class RecuperarContraViewController: UIViewController {

    @IBOutlet var btnConfirmar : UIButton!
    @IBOutlet var txtContraNueva : UITextField!
    @IBOutlet var txtConfirmar : UITextField!
    @IBOutlet var txtContraAct : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btnConfirmar.layer.borderWidth = 1
        btnConfirmar.layer.borderColor = UIColor.darkGrayColor().CGColor
        btnConfirmar.layer.cornerRadius = 5
        btnConfirmar.tintColor = UIColor.blackColor()
        
        txtContraNueva.layer.borderColor = UIColor.orangeColor().CGColor
        txtContraNueva.layer.borderWidth = 1
        txtConfirmar.layer.borderColor = UIColor.orangeColor().CGColor
        txtConfirmar.layer.borderWidth = 1
        txtContraAct.layer.borderColor = UIColor.orangeColor().CGColor
        txtContraAct.layer.borderWidth = 1
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Buttons ACtions
    
    @IBAction func touchMenu() {
        frostedViewController.presentMenuViewController()
    }
    
    @IBAction func touchChangePassword() {
        if txtContraAct.text == "" {
            //UIAlertView(title: "Advertencia", message: "Favor de ingresar la Contraseña Actual", delegate: nil, cancelButtonTitle: "Aceptar").show()
            let AlertView = CustomAlertViewController()
            AlertView.text = "Favor de ingresar la Contraseña Actual"
            self.presentViewController(AlertView, animated: true, completion: nil)
            return
        } else if txtContraNueva.text == "" {
            //UIAlertView(title: "Advertencia", message: "Favor de ingresar la Nueva Contraseña", delegate: nil, cancelButtonTitle: "Aceptar").show()
            let AlertView = CustomAlertViewController()
            AlertView.text = "Favor de ingresar la Nueva Contraseña"
            self.presentViewController(AlertView, animated: true, completion: nil)
            return
        } else if txtContraNueva.text != txtConfirmar.text {
            //UIAlertView(title: "Advertencia", message: "las contraseñas no coinciden", delegate: nil, cancelButtonTitle: "Aceptar").show()
            let AlertView = CustomAlertViewController()
            AlertView.text = "las contraseñas no coinciden"
            self.presentViewController(AlertView, animated: true, completion: nil)
            return
        }
        
        var downloadQueue :dispatch_queue_t = dispatch_queue_create("callListSesion", nil)
        
        var spinner : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle:UIActivityIndicatorViewStyle.WhiteLarge)
        spinner.color = UIColor.blackColor()
        let viewSpinner : UIView = UIView(frame: CGRectMake(0, 0, 2000, 2000))
        viewSpinner.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleTopMargin | .FlexibleBottomMargin
        
        viewSpinner.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        spinner.center = CGPointMake(viewSpinner.frame.size.width/2.0, viewSpinner.frame.size.height/2.0)
        viewSpinner.addSubview(spinner)
        viewSpinner.center = CGPointMake(view.frame.size.width/2.0, view.frame.size.height/2.0)
        
        self.view.addSubview(viewSpinner)
        spinner.startAnimating()
        
        dispatch_async(downloadQueue, {
            let usuario = NSUserDefaults.standardUserDefaults().objectForKey("usuario") as! String
            let dic = Fetcher.changePassword(usuario, passwordOld: self.txtContraAct.text, andPasswordNew: self.txtContraNueva.text)
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if (dic.objectForKey("mensaje") != nil) {
                    
                    if !(dic.objectForKey("sn_error") as! Bool) {
                        self.txtContraNueva.text = ""
                        self.txtContraAct.text = ""
                        self.txtConfirmar.text = ""
                    }
                    
                    //UIAlertView(title: "Advertencia", message: dic.objectForKey("mensaje") as? String, delegate: nil, cancelButtonTitle: "Aceptar").show()
                    let AlertView = CustomAlertViewController()
                    AlertView.text = dic.objectForKey("mensaje") as? String
                    self.presentViewController(AlertView, animated: true, completion: nil)
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

}
