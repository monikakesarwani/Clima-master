

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

/* 1. import CoreLocation
 2. weatherViewController class conform the protocol of CLLocationManagerDelegate
 3. create an oject from CLLocationManager class :-
 let locationManager = CLLocationManager()
 4. get URL address
 5. API ID (unique key)
 6. Set up the location manager here.
 locationManager.delegate = self (set locationManager delegate properties we uses . we are setting  weatherViewController as the delegete of the locationManager. )
 locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters (this is accuracy of location data)
 locationManager.requestWhenInUseAuthorization() // this authorization doesnot work untill you add description in pilist. In order to do that you have to add properties in pilist and two keys 1. privacy-location-usage-description 2. privacy-location-when in use user-description as well as give value of key (We need your location inorder to give current weather condition)
 
 **** App Tranport security setting ******
 <key>NSAppTransportSecurity</key>
 <dict>
 <key>NSExceptionDomains</key>
 <dict>
 <key>openweathermap.org</key>
 <dict>
 <key>NSIncludesSubdomains</key>
 <true/>
 <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
 <true/>
 </dict>
 </dict>
 </dict>
 
 locationManager.startUpdatingLocation() (this is asynchronous method ruuning in background and after looking for accurate location inform to weatherviewController that I suessfully update location. therefore used two methods )
 func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
 print(got location)
 and if fail than
 func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
 print(error)
 }
 */





class WeatherViewController: UIViewController, CLLocationManagerDelegate,changeCityDelegate  {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "620b55b53286cb3ff60dba91117e3dba"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    
    
    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url: String, parameters: [String: String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                
                //print("Success! Got the weather data")
                let weatherJSON : JSON = JSON(response.result.value!)
                print(weatherJSON)
                
                self.updateWeatherData(json: weatherJSON)
                
            }
            else {
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    //Write the updateWeatherData method here:
    func updateWeatherData(json: JSON) {
        if let tempResult = json["main"]["temp"].double{
            weatherDataModel.temperature = Int(tempResult - 273.15)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            updateUIWithWeatherData()
        }
        else{
            cityLabel.text = "Weather Unvailable"
        }
    }
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData(){
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //after getting the accurate location it save the data in array
        let location = locations[locations.count - 1] // in order to get last, in number of count minus one 1 because array index starts with 0
        
        if location.horizontalAccuracy > 0{ //checking the location is valid or not..if so than use stopUpdatingLocation() prpperties. otherwise battery will be low.why because of it will keep updating.
            locationManager.stopUpdatingLocation()
            // locationManager.delegate = nil // once data location found just set locationManager delegate = nill so this way it will print once
            
            print("longitude = \(location.coordinate.longitude) latitude = \(location.coordinate.latitude)")
            
            let longitude = String(location.coordinate.longitude)//save logitude in constant for future use
            let latitude = String(location.coordinate.latitude)
            let APP_ID = "620b55b53286cb3ff60dba91117e3dba"
            
            //after than converting in dictionary
            
            let params : [String : String] = ["lon" : longitude, "lat" : latitude, "appid" : APP_ID]
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    func userEnteredNewCityName(city: String) {
        let params : [String : String] = ["q": city, "appId": APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
        
    }
    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    
    
}


