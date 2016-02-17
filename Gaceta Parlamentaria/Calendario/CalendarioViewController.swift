//
//  CalendarioViewController.swift
//  votaciones
//
//  Created by Armando Trujillo on 19/02/15.
//  Copyright (c) 2015 RedRabbit. All rights reserved.
//

import UIKit

class CalendarioViewController: UIViewController, JTCalendarDataSource {
    
    @IBOutlet var calendarMenuView : JTCalendarMenuView!
    @IBOutlet var calendarContentView : JTCalendarContentView!
    @IBOutlet var calendarContentViewHeight : NSLayoutConstraint!
    @IBOutlet var calendar : JTCalendar!
    @IBOutlet var viewAntes : UIView!
    @IBOutlet var viewHoy : UIView!
    @IBOutlet var viewDespues : UIView!
    @IBOutlet var viewSeleccionado : UIView!
    
    private var arrayGacetas : NSMutableArray = NSMutableArray()
    private var nameSesionSelected = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar = JTCalendar()
        
        calendar.calendarAppearance().calendar().firstWeekday = 1 // domingo = 1, sabado = 7
        calendar.calendarAppearance().dayCircleRatio = 9 / 10
        calendar.calendarAppearance().dayDotRatio = 9 / 10 
        calendar.calendarAppearance().ratioContentMenu = 1
        calendar.calendarAppearance().dayTextFont = UIFont(name: "Arial", size: 20)
        
        calendar.calendarAppearance().dayDotColor = Colors.cafe3()
        calendar.calendarAppearance().dayDotColorOtherMonth = Colors.cafe3().colorWithAlphaComponent(0.5)
        calendar.calendarAppearance().dayCircleColorToday = Colors.cremita()
        calendar.calendarAppearance().dayCircleColorTodayOtherMonth = Colors.cremita().colorWithAlphaComponent(0.5)
        
        calendarMenuView.backgroundColor = UIColor.orangeColor().colorWithAlphaComponent(0.2)
        calendarContentView.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.2)
        
        calendar.menuMonthsView = calendarMenuView
        calendar.contentView = calendarContentView
        calendar.dataSource = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "recargarCaledario", name:UIDeviceOrientationDidChangeNotification , object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "leaving", name:"changeView" , object: nil)
        
        viewAntes.backgroundColor = Colors.cafe3()
        viewHoy.backgroundColor = Colors.cremita()
        viewDespues.backgroundColor = Colors.amarilloMoztasa()
        
        viewAntes.layer.cornerRadius = 25
        viewHoy.layer.cornerRadius = 25
        viewDespues.layer.cornerRadius = 25
        viewSeleccionado.layer.cornerRadius = 25
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        var downloadQueue :dispatch_queue_t = dispatch_queue_create("callListSesion", nil)
        
        var spinner : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle:UIActivityIndicatorViewStyle.WhiteLarge)
        spinner.color = UIColor.blackColor()
        let viewSpinner : UIView = UIView(frame: CGRectMake(0, 0, 2000, 2000))
        viewSpinner.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleTopMargin | .FlexibleBottomMargin
        
        viewSpinner.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        spinner.center = CGPointMake(viewSpinner.frame.size.width/2.0, viewSpinner.frame.size.height/2.0)
        viewSpinner.addSubview(spinner)
        viewSpinner.center = CGPointMake(UIScreen.mainScreen().applicationFrame.size.width/2.0, UIScreen.mainScreen().applicationFrame.size.height/2.0)
        
        self.view.addSubview(viewSpinner)
        spinner.startAnimating()
        
        dispatch_async(downloadQueue, {
            let dic : NSDictionary = Fetcher.getGacetasAnteriores()
            dispatch_async(dispatch_get_main_queue(), {
                
                if dic.objectForKey("rs") != nil {
                    let array = dic.objectForKey("rs") as! NSArray
                    
                    for item in array {
                        self.arrayGacetas.addObject(item.objectForKey("fh_sesion")!)
                    }
                }
                self.calendar.reloadData()
                spinner.stopAnimating()
                viewSpinner.removeFromSuperview()
            })
        })
        
        self.calendar.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Functions Notification Center
    func leaving() {
        calendarContentView.removeFromSuperview()
        calendarMenuView.removeFromSuperview()
    }
    
    func recargarCaledario() {
        calendar.reloadData()
    }
    
    // MARK: - Buttons Actions
    @IBAction func touchMenu(any: AnyObject) {
        frostedViewController.presentMenuViewController()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pushGacetaAnterior" {
            let ordenView = segue.destinationViewController as! OrdenViewController
            ordenView.nameSesion = nameSesionSelected
            ordenView.isFromCalendario = true
        }
    }
    
    @IBAction func unWind(segue: UIStoryboardSegue) {
        println("unWind: Calendario")
    }
    
    // MARK: - JTCalendarDataSource
    
    func calendarHaveEvent(calendar: JTCalendar!, date: NSDate!) -> Bool {
        println("Fecha: \(date)")
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        println(dateFormatter.stringFromDate(date))
        
        /*if dateFormatter.stringFromDate(date) == "2015-02-17" {
            return true
        }*/
        
        for item in arrayGacetas {
            let dateStirng : String = item.substringToIndex(10)
            if dateFormatter.stringFromDate(date) == item.substringToIndex(10) {
                return true
            }
        }
        
        return false
    }
    
    func calendarEventColor(calendar : JTCalendar!, date: NSDate!) -> UIColor {
        
        if date.compare(NSDate()) == NSComparisonResult.OrderedDescending {
            println("la fecha ya paso")
            return Colors.amarilloMoztasa()
        }
        
        return Colors.cafe3()
    }
    
    func calendarDidDateSelected(calendar: JTCalendar!, date: NSDate!) {
        println("Fecha: \(date)")
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        println(dateFormatter.stringFromDate(date))
        
        for item in arrayGacetas {
            let dateStirng : String = item.substringToIndex(10)
            if dateFormatter.stringFromDate(date) == item.substringToIndex(10) {
                nameSesionSelected = dateFormatter.stringFromDate(date)
                println(dateFormatter.stringFromDate(date))
                self.performSegueWithIdentifier("pushGacetaAnterior", sender: self)
                return
            }
        }
        
        calendar.reloadData()

    }
}
