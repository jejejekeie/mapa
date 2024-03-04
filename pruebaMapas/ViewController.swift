//
//  ViewController.swift
//  pruebaMapas
//
//  Created by Eva Paracuellos on 26/2/24.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var countryInput: UITextField!
    @IBOutlet weak var cityInput: UITextField!
    @IBOutlet weak var streetInput: UITextField!
    @IBOutlet weak var latitudeResult: UILabel!
    @IBOutlet weak var longitudeResult: UILabel!
    
    @IBOutlet weak var latitudeInput: UITextField!
    @IBOutlet weak var longitudeInput: UITextField!
    @IBOutlet weak var addressResult: UITextView!
    
    @IBOutlet weak var searchInput: UITextField!
    
    lazy var geocoder = CLGeocoder()
    
    //INICIALICACIÓN DEL OBJETO LOCATIONMANAGER
    let locationManager = CLLocationManager()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countryInput.placeholder = "Introduza el país"
        cityInput.placeholder = "Introduzca la ciudad"
        streetInput.placeholder = "Introduzca la calle"
        latitudeInput.placeholder = "Introduzca la latitud"
        longitudeInput.placeholder = "Introduzca la longitud"
        searchInput.placeholder = "Introduzca la dirección"
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        
        //LLAMANDO A TODOS LOS ELEMENTOS DEL OBJETO
        locationManager.delegate = self as CLLocationManagerDelegate
        //PETICIÓN DE PRIVACIDAD
        // locationManager.requestWhenInUseAuthorization()
        //PETICÓN DE LA LOCALIZACIÓN, LANZA EL LOCALIZADOR
        // locationManager.requestLocation()
        
        if CLLocationManager.locationServicesEnabled() {
            print("location Services enabled")
        } else {
            print("show user instructions")
        }
    }
    
    func checkLocationAuthoritation() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            locationManager.requestLocation()
        case .denied:
            print("show alert asking to user to turn on permisions")
            break
        case .notDetermined:
            print("Not determined")
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        case .restricted:
            print("premissions restricted - show alert with instructions")
            break
        case .authorizedAlways:
            break
        @unknown default:
            fatalError()
        }
    }
    
    @IBAction func sendAddress(_ sender: Any) {
        guard let street = streetInput.text else {return}
        print(street)
        guard let city = cityInput.text else {return}
        print(city)
        guard let country = countryInput.text else {return}
        print(country)
        
        let address = "\(country), \(city), \(street)"
        print(address)
         
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            self.proccessForwardResponse(withPlacemarks: placemarks, error: error)
        }
    }
    
    @IBAction func sendCoordinates(_ sender: Any) {
        guard let latString = latitudeResult.text, let lat = Double(latString) else {return}
        guard let lonString = longitudeResult.text, let lon = Double(lonString) else {return}
        let location = CLLocation(latitude: lat, longitude: lon)
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            self.processReverseResponse(withPlacemarks: placemarks, error: error)
        }
    }
    
    @IBAction func sendLocation(_ sender: Any) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchInput.text
        guard let latString = latitudeResult.text, let lat = Double(latString) else {return}
        guard let lonString = longitudeResult.text, let lon = Double(lonString) else {return}
        let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        request.region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 500, longitudinalMeters: 500)
        let search = MKLocalSearch(request: request)
        search.start {response, _ in
            guard let response = response else {
                return
            }
            print(response)
        }
    }
    
    func proccessForwardResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        if let error = error {
            print("Unable to Forward Geocode address \(error)")
            latitudeResult.text = "ERROR"
            longitudeResult.text = "ERROR"
        } else {
            var location : CLLocation?
            if let placemarks = placemarks, placemarks.count > 0 {
                print(placemarks)
                location = placemarks.first?.location
            }
            if let location = location {
                let coordinate = location.coordinate
                latitudeResult.text = "\(coordinate.latitude)"
                longitudeResult.text = "\(coordinate.longitude)"
            } else {
                latitudeResult.text = "No latitude match"
                longitudeResult.text = "No longitude match"
            }
        }
    }
    
    func processReverseResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        if error != nil {
            addressResult.text = "Unable to find address for location"
        } else {
            if let placemarks = placemarks, let placemark = placemarks.first {
                print(placemark)
                addressResult.text = placemark.name
            } else {
                addressResult.text = "No matching addresses foundx"
            }
        }
    }
}

//PARA PODER MANIPULARLO
extension ViewController : CLLocationManagerDelegate {
    //ACTUALIZAR LA LOCALIZACIÓN
    //DEVUELVE LOCALIZACIÓNES, GUARDA UN ARRAY DE LAS MISMAS
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("LATITUD: \(location.coordinate.latitude)")
            print("LONGITUD: \(location.coordinate.longitude)")
        }
    }
    //HAY QUE AÑADIR ESTO PORQUE REQUEST LOCATION PIDE EL CASO DE FALLO, SI NO SE AÑADE CON DIDUPDATE LA COMPILAZIÓN DARÁ ERROR
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR: - \(error)")
    }
}

