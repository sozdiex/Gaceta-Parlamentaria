//
//  VotacionesViewController.swift
//  votaciones
//
//  Created by Armando Trujillo on 20/02/15.
//  Copyright (c) 2015 RedRabbit. All rights reserved.
//

import UIKit

class VotacionesViewController: UIViewController {

    var tituloVotacion : String = "¿Pregunta?"
    var dicVotar : NSDictionary!
    var voto = ""
    private var isVoto = false
    @IBOutlet var lblTema : UILabel!
    @IBOutlet var btnSi : UIButton!
    @IBOutlet var btnNo : UIButton!
    @IBOutlet var btnAbs : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dicVotar = NSUserDefaults.standardUserDefaults().objectForKey("dicVotar") as! NSDictionary
        lblTema.text = dicVotar.objectForKey("nb_tema") as? String
        lblTema.textAlignment = NSTextAlignment.Justified
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "touchTerminar", name:"cerrarResultadoVotacion" , object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "alertAcceptedVotacion", name: "alertAcceptedVotacion", object: nil)
        
        btnSi.tag = 1
        btnNo.tag = 2
        btnAbs.tag = 3
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
    
    @IBAction func unWindVotar(segue: UIStoryboardSegue) {
        
    }
    
    // MARK: - IBActions Buttons 
    @IBAction func touchMenu(any: AnyObject) {
        frostedViewController.presentMenuViewController()
    }
    
    @IBAction func touchBotonGeneral(button : UIButton) {
        let AlertView = CustomAlertViewController()
        AlertView.text = "¿Confirmar Voto?"
        AlertView.alertQuestion = true
        AlertView.Selector = "alertAcceptedVotacion"
        isVoto = true
        voto = (button.tag as NSNumber).stringValue
        self.presentViewController(AlertView, animated: true, completion: nil)
    }
    
    func touchTerminar() {
        var RootController = self.storyboard?.instantiateViewControllerWithIdentifier("RootViewController") as! RootViewController
        self.presentViewController(RootController, animated: true, completion: nil)
    }
    
    func alertAcceptedVotacion() {
        if isVoto {
            isVoto = false
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
                let ipServidor = Fetcher.getIpServidor()
                
                var dicReturn = NSDictionary()
                if ipServidor == SystemServices().wiFiRouterAddress {
                    let id_diputado = (NSUserDefaults.standardUserDefaults().objectForKey("id_usuario") as! NSNumber).stringValue
                    let id_votacion = (self.dicVotar.objectForKey("id_votacion") as! NSNumber).stringValue
                    let id_sesion = (self.dicVotar.objectForKey("id_sesion") as! NSNumber).stringValue
                    dicReturn = Fetcher.registrarVoto(id_votacion, withSesion: id_sesion, withUsuario: id_diputado, andVoto: self.voto)
                } else {
                    let AlertView = CustomAlertViewController()
                    AlertView.text = "no se encuentra conectado a la red oficial del pleno"
                    self.presentViewController(AlertView, animated: true, completion: nil)
                }
                dispatch_async(dispatch_get_main_queue(), {
                    if ipServidor == SystemServices().wiFiRouterAddress {
                        if (dicReturn.objectForKey("sn_error")?.boolValue != nil) {
                            if !(dicReturn.objectForKey("sn_error") as! Bool) {
                                self.performSegueWithIdentifier("pushVoto", sender: self)
                            } else {
                                //UIAlertView(title: "Advertencia", message: dicReturn.objectForKey("mensaje") as? String, delegate: nil, cancelButtonTitle: "Aceptar").show()
                                let AlertView = CustomAlertViewController()
                                AlertView.text = dicReturn.objectForKey("mensaje") as? String
                                self.presentViewController(AlertView, animated: true, completion: nil)
                            }
                        }else {
                            //UIAlertView(title: "Advertencia", message: "No se pudo conectar en este momento con el servidor, vuelva a intentar mas tarde", delegate: nil, cancelButtonTitle: "Aceptar").show()
                            let AlertView = CustomAlertViewController()
                            AlertView.text = "No se pudo conectar en este momento con el servidor, vuelva a intentar mas tarde"
                            self.presentViewController(AlertView, animated: true, completion: nil)
                        }
                    }
                    spinner.stopAnimating()
                    viewSpinner.removeFromSuperview()
                })
            })
        }
    }

}
