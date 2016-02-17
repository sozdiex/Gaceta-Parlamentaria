//
//  Web2ViewController.swift
//  votaciones
//
//  Created by Armando Trujillo on 20/02/15.
//  Copyright (c) 2015 RedRabbit. All rights reserved.
//

import UIKit

class Web2ViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet var webView : UIWebView!
    @IBOutlet var viewTotal : UIView!
    @IBOutlet var viewLoad : UIView!
    @IBOutlet var spinner : UIActivityIndicatorView!
    @IBOutlet weak var btnBack: UIBarButtonItem!
    
    private var arrayHistorial = NSMutableArray()
    private var limpiar : Bool = false
    var pageUrl : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewLoad.layer.cornerRadius = 7
        viewLoad.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        spinner.startAnimating()
    }
    
    override func viewDidAppear(animated: Bool) {
        if Reachability.isConnectedToNetwork() {
            var downloadQueue :dispatch_queue_t = dispatch_queue_create("loadPage", nil)
            dispatch_async(downloadQueue, {
                let stringHtml = self.getHtml( self.pageUrl )
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.webView.loadHTMLString(stringHtml, baseURL:nil)
                })
            })
        } else {
            //UIAlertView(title: "Advertencia", message: "No cuenta con acceso a internet", delegate: nil, cancelButtonTitle: "Aceptar").show()
            let AlertView = CustomAlertViewController()
            AlertView.text = "No cuenta con acceso a internet"
            self.presentViewController(AlertView, animated: true, completion: nil)
            viewTotal.hidden = true
            btnBack.enabled = false
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getHtml(url : NSString) -> String {
        
        var error: NSError?
        let html: String? = String(contentsOfURL: NSURL(string: url as String)!, encoding: NSUTF8StringEncoding, error: &error)
        
        //println("contenido " + html!)
        
        var rango : NSRange!
        var stringWithOutBody : NSString = html!
        
        rango = stringWithOutBody.rangeOfString("<div id=\"side-page\" class=\"contents clearfix\">")
        var rangoEnd : NSRange = stringWithOutBody.rangeOfString("<aside id=\"sidebar\">")
        //var location = rangoEnd.location + rangoEnd.length
        rango.length = rangoEnd.location - rango.location - 1
        
        var content = stringWithOutBody.substringWithRange(rango)
        
        stringWithOutBody = stringWithOutBody.stringByReplacingCharactersInRange(rango, withString: "")
        
        rango = stringWithOutBody.rangeOfString("<!-- START wrapper -->")
        rangoEnd = stringWithOutBody.rangeOfString("<!-- END #wrapper -->")
        var location = rangoEnd.location + rangoEnd.length
        rango.length = location - rango.location
        
        stringWithOutBody = stringWithOutBody.stringByReplacingCharactersInRange(rango, withString: content)
        
        //arrayHistorial.addObject(stringWithOutBody)
        
        return stringWithOutBody as String
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        println("cargando...")
        
        viewTotal.hidden = false
        if limpiar {
            let newUrl  = webView.request?.URL!.absoluteString
            let stringHtml = getHtml( newUrl! )
            webView.loadHTMLString(stringHtml, baseURL:nil)
            
            limpiar = false
        } else {
            limpiar = true
        }

    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if arrayHistorial.count > 1 {
            btnBack.enabled = true
        } else {
            btnBack.enabled = false
        }
        
        viewTotal.hidden = true
        println("Termino de cargar")
        //UIAlertView(title: "Mensaje", message: "Termino de Cargar.", delegate: nil, cancelButtonTitle: "Aceptar").show()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Buttons Actiones
    
    @IBAction func touchMenu(any : AnyObject) {
        frostedViewController.presentMenuViewController()
    }
    
    @IBAction func touchBack(any : AnyObject) {
        if arrayHistorial.count > 1 {
            limpiar = false
            webView.loadHTMLString(arrayHistorial.objectAtIndex(arrayHistorial.count - 2) as! String, baseURL:nil)
            arrayHistorial.removeLastObject()
        }
    }
    
    

}
