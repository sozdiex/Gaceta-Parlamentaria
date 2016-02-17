//
//  WebViewController.swift
//  votaciones
//
//  Created by Armando Trujillo on 18/02/15.
//  Copyright (c) 2015 RedRabbit. All rights reserved.
//

import UIKit
import MessageUI

class WebViewController: UIViewController, UIWebViewDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet var webView : UIWebView!
    @IBOutlet var spinner : UIActivityIndicatorView!
    @IBOutlet var btnSendMail : UIBarButtonItem!
    var isOneDocument = false
    var id_Sesion : String!
    var id_tema : String!
    var id_subTema : String!
    var nameFile : String!
    var dateSesion : String!
    var titulo : String!
    var data : NSData! = NSData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if dateSesion == "" {
            let sesionIniciada = NSUserDefaults.standardUserDefaults().objectForKey("sn_iniciada") as! Bool
            if !sesionIniciada {
                btnSendMail.enabled = false
                btnSendMail.title = ""
            }
        }
        
        spinner.startAnimating()
        if isOneDocument {
            var downloadQueue :dispatch_queue_t = dispatch_queue_create("callDocuments", nil)
                dispatch_async(downloadQueue, {
                    let dic = Fetcher.getDocuments(self.id_Sesion, withTema: self.id_tema, orSubTema: self.id_subTema, andDate: self.dateSesion) as NSDictionary
                    if dic.objectForKey("rs") != nil {
                        let arrayTemp = dic.objectForKey("rs") as! NSArray
                        let dicAux = arrayTemp.objectAtIndex(0) as! NSDictionary
                        
                        var urlPdf : String = kAppUrl + "/votaciones/" + (dicAux.objectForKey("ar_documento") as! String)
                        urlPdf = urlPdf.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                        var remoteUrl : NSURL = NSURL(string: urlPdf)!
                        var request = NSURLRequest(URL: remoteUrl)
                        var error: NSError?
                        let url = NSURL(string: urlPdf)
                        self.data = NSData(contentsOfURL: url!)
                    
                    }
                dispatch_async(dispatch_get_main_queue(), {
                    if self.data.length > 0 {
                        //self.webView.loadHTMLString(self.pdfHtml, baseURL:nil)
                        self.webView.loadData(self.data, MIMEType: "Application/pdf", textEncodingName: "UTF-8", baseURL: nil)
                    }
                    //self.webView.loadRequest(request)
                    self.webView.backgroundColor = UIColor.whiteColor()
                })
            })
        } else {
            nameFile = nameFile.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            var remoteUrl : NSURL = NSURL(string: nameFile)!
            var request = NSURLRequest(URL: remoteUrl)
            var downloadQueue :dispatch_queue_t = dispatch_queue_create("downloandHtml", nil)
            dispatch_async(downloadQueue, {
                var error: NSError?
                self.data = NSData(contentsOfURL: remoteUrl)
                dispatch_async(dispatch_get_main_queue(), {
                    if self.data.length > 0 {
                        self.webView.loadData(self.data, MIMEType: "Application/pdf", textEncodingName: "UTF-8", baseURL: nil)
                    }
                })
            })
            self.webView.backgroundColor = UIColor.whiteColor()
        }
}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       
    }
    */
    
    @IBAction func unWind (segue: UIStoryboardSegue) {
        println("unWind")
    }
    
    //MARK: - IBActions Buttons 
    @IBAction func touchSendEmail(){
        if self.data.length > 0 {
            if MFMailComposeViewController.canSendMail() {
                var picker = MFMailComposeViewController()
                picker.mailComposeDelegate = self
                picker.setSubject(titulo)
                picker.setMessageBody("", isHTML: true)
                picker.addAttachmentData(data, mimeType: "Application/Pdf", fileName: "Documento")
                
                presentViewController(picker, animated: true, completion: nil)
            } else {
                let AlertView = CustomAlertViewController()
                AlertView.text = "Configure una cuenta en Mail para enviar correo electrónico."
                self.presentViewController(AlertView, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: - Mail Delegate 
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

    
    // MARK: - WebView Delegate
    func webViewDidStartLoad(webView: UIWebView) {
        spinner.startAnimating()
        //spinner.hidden = false
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        spinner.stopAnimating()
        //spinner.hidden = true
    }
}
