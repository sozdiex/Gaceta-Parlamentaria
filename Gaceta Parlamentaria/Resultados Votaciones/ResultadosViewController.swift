//
//  ResultadosViewController.swift
//  votaciones
//
//  Created by Armando Trujillo on 18/02/15.
//  Copyright (c) 2015 RedRabbit. All rights reserved.
//

import UIKit

class ResultadosViewController: UIViewController {
    
    @IBOutlet var viewPregunta : UIView!
    @IBOutlet var viewGrafica : UIView!
    @IBOutlet var lblPregunta : UILabel!
    
    @IBOutlet var lblSi : UILabel!
    @IBOutlet var lblSiP : UILabel!
    @IBOutlet var lblNo : UILabel!
    @IBOutlet var lblNoP : UILabel!
    @IBOutlet var lblAbs : UILabel!
    @IBOutlet var lblAbsP : UILabel!
    @IBOutlet var lblTotal : UILabel!
    @IBOutlet var lblTotalP : UILabel!
    
    private var arrayVotos : NSMutableArray = NSMutableArray()
    private var pieChart : PCPieChart!
    private var timer : NSTimer!
    private var isOnRelaod = true

    
    var votoUsuario : Int = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "touchTerminar", name:"cerrarResultadoVotacion" , object: nil)
        self.navigationItem.setHidesBackButton(true, animated: false)
        arrayVotos = [["title":"No","value":0],["title":"Abstención","value":0],["title":"Si","value":0]]
        reloadGrafic()
        
        let dicVotar = NSUserDefaults.standardUserDefaults().objectForKey("dicVotar") as! NSDictionary
        lblPregunta.text = dicVotar.objectForKey("nb_tema") as? String
        
        loadVotos()
        
        
        
        lblSi.textColor = Colors.verde()
        lblSiP.textColor = Colors.verde()
        lblNo.textColor = Colors.rojoNaranja()
        lblNoP.textColor = Colors.rojoNaranja()
        lblAbs.textColor = Colors.amarillo()
        lblAbsP.textColor = Colors.amarillo()
    }
    
    
    func loadVotos() {
        if isOnRelaod {
            var downloadQueue :dispatch_queue_t = dispatch_queue_create("callListSesion", nil)
            
            dispatch_async(downloadQueue, {
                let dicVotar = NSUserDefaults.standardUserDefaults().objectForKey("dicVotar") as! NSDictionary
                let id_votacion = (dicVotar.objectForKey("id_votacion") as! NSNumber).stringValue
                let id_sesion = (dicVotar.objectForKey("id_sesion") as! NSNumber).stringValue
                let dic = Fetcher.obtenerVotacionActual(id_votacion, withSesion: id_sesion) as NSDictionary
                
                dispatch_async(dispatch_get_main_queue(), {
                    if dic.objectForKey("sn_error") != nil {
                        if !(dic.objectForKey("sn_error") as! Bool){
                            let arrayRS = dic.objectForKey("rs") as! NSArray
                            if arrayRS.count > 0 {
                                let dicRS = arrayRS.objectAtIndex(0) as! NSDictionary
                                let no : NSNumber = dicRS.objectForKey("nu_contra") as! NSNumber
                                let si : NSNumber  = dicRS.objectForKey("nu_favor") as! NSNumber
                                let abs  : NSNumber = dicRS.objectForKey("nu_abstencion") as! NSNumber
                                self.arrayVotos = [["title":"No","value":no],["title":"Abstención","value":abs],["title":"Si","value":si]]
                                
                                let totalVotos  : NSNumber = no.integerValue + si.integerValue + abs.integerValue
                                
                                let siP : NSNumber = (si.floatValue / totalVotos.floatValue) * 100.0
                                let noP : NSNumber = (no.floatValue / totalVotos.floatValue) * 100.0
                                let absP : NSNumber = (abs.floatValue / totalVotos.floatValue) * 100.0
                                
                                self.lblTotal.text = "\(totalVotos)"
                                self.lblSiP.text = "\(siP.integerValue)%"
                                self.lblNoP.text = "\(noP.integerValue)%"
                                self.lblAbsP.text = "\(absP.integerValue )%"
                            }
                            self.reloadGrafic()
                            if NSUserDefaults.standardUserDefaults().objectForKey("sn_grafica") as! Bool {
                                 self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("loadVotos"), userInfo: nil, repeats: false)
                            } else {
                                 self.timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("loadVotos"), userInfo: nil, repeats: false)
                            }
                           
                        }
                    }
                })
            })
        }
    }
    
    func reloadGrafic() {
        
        if pieChart != nil {
            pieChart.removeFromSuperview()
        }
        
        var height = self.view.bounds.size.width/3*2
        var width = self.view.bounds.size.width
        
        pieChart = PCPieChart(frame: CGRectMake((viewGrafica.bounds.size.width - width) / 2,(viewGrafica.bounds.size.height - height) / 2, width , height))
        pieChart.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleBottomMargin | UIViewAutoresizing.FlexibleTopMargin
        
        pieChart.diameter = 300
        pieChart.sameColorLabel = true
        
        viewGrafica.addSubview(pieChart)
        
        pieChart.titleFont = UIFont(name: "HelveticaNeue-Bold", size: 30)
        pieChart.percentageFont = UIFont(name: "HelveticaNeue-Bold", size: 50)
        
        var components : NSMutableArray = NSMutableArray()
        var i = 0
        for item in arrayVotos {
            var title = item.objectForKey("title") as! String
            var value = item.objectForKey("value") as! Float
            var component : PCPieComponent = PCPieComponent(title: title, value: value)
            
            if i == 0 {
                component.colour = Colors.rojoNaranja()
            } else if i == 1 {
                component.colour = Colors.amarillo()
            }else if i == 2 {
                component.colour = Colors.verde()
            }
            i = i + 1
            
            components.addObject(component)
        }
        
        pieChart.components = components
    }
    
    func update() {
        var voto : Int = random() % 3
        var dic : NSMutableDictionary = NSMutableDictionary()
        if voto == 0 {
            // Si
            var totalVotos = arrayVotos.objectAtIndex(2).objectForKey("value") as! Int
            
            dic.setValue("Si", forKey: "title")
            dic.setValue(totalVotos + 1 , forKey: "value")
            arrayVotos.removeObjectAtIndex(2)
            arrayVotos.insertObject(dic, atIndex: 2)
            
        } else if voto == 1{
            // No
            var totalVotos = arrayVotos.objectAtIndex(0).objectForKey("value") as! Int
            
            dic.setValue("No", forKey: "title")
            dic.setValue(totalVotos + 1 , forKey: "value")
            arrayVotos.removeObjectAtIndex(0)
            arrayVotos.insertObject(dic, atIndex: 0)
        } else {
            // Abstencion
            var totalVotos = arrayVotos.objectAtIndex(1).objectForKey("value") as! Int
            
            dic.setValue("Abstención", forKey: "title")
            dic.setValue(totalVotos + 1 , forKey: "value")
            
            arrayVotos.removeObjectAtIndex(1)
            arrayVotos.insertObject(dic, atIndex: 1)
        }
        
        println(voto)
        
        var total = (arrayVotos.objectAtIndex(0).objectForKey("value") as! Int) + (arrayVotos.objectAtIndex(1).objectForKey("value") as! Int) +
            (arrayVotos.objectAtIndex(2).objectForKey("value") as! Int)
        
        if  total  == 40 {
            timer.invalidate()
        }
        
        reloadGrafic()
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
    
    // MARK: - Buttons Action
    @IBAction func cambiarVoto() {
        self.performSegueWithIdentifier("unWindVotar", sender: self)
    }
    @IBAction func touchMenu() {
        frostedViewController.presentMenuViewController()
    }
    
    
    @IBAction func touchTerminar() {
        isOnRelaod = false
        self.performSegueWithIdentifier("pushResultadosDetalle", sender: self)
        
        /*if NSUserDefaults.standardUserDefaults().objectForKey("sn_grafica") as! Bool {
            let RootController = self.storyboard?.instantiateViewControllerWithIdentifier("graficaNavigation") as! UINavigationController
            self.presentViewController(RootController, animated: true, completion: nil)
        } else {
            var RootController = self.storyboard?.instantiateViewControllerWithIdentifier("RootViewController") as! RootViewController
            self.presentViewController(RootController, animated: true, completion: nil)
        }*/

    }
    
}
