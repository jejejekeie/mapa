//
//  InitialViewController.swift
//  pruebaMapas
//
//  Created by Eva Paracuellos on 26/2/24.
//

import UIKit
import MapKit

// DEFINICIÓN DE LA CLASE QUE CONTROLLA InitialView, cogiendo de UIViewController
class InitialViewController: UIViewController {
    
    // INSTANCIA AL CONTROLADOR DE BÚSQUEDA
    var resultSearchController: UISearchController? = nil
    
    // OUTLET DEL MapView EN InitialView
    @IBOutlet weak var mapView: MKMapView!
    
    // DECLARACIÓN DE VARIABLES PARA LA DIRECCIÓN INICIAL Y LA DISTANCIA DE ZOOM INICIAL
    var initialLocation = CLLocation()
    var initialDistance = CLLocationDistance()
    
    // INSTANCIACIÓN DEL CLLocationManager PARA LA ACTUALIZACIÓN DE DIRECCIONES
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // CONGIGURACIÓN DE SearchTableViewController CON LOS RESULTADOS DE LA BÚSQUEDA
        let searchTableViewController = storyboard!.instantiateViewController(withIdentifier: "SearchTableViewController") as! SearchTableViewController
        searchTableViewController.delegate = self
        resultSearchController = UISearchController(searchResultsController: searchTableViewController)
        resultSearchController?.searchResultsUpdater = searchTableViewController as UISearchResultsUpdating
        
        // CONFIGURACIÓN DE LA BARRA DE BÚSQUEDA
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Introduce tu búsqueda"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.obscuresBackgroundDuringPresentation = true
        definesPresentationContext = true

        // MARCA LA DIRECCIÓN INICIAL Y EL ZOOM
        initialLocation = CLLocation(latitude: 40.417122417017765, longitude: -3.7037408964307303)
        initialDistance = 500
        centerLocation(location: initialLocation, distance: initialDistance)
        
        // GENERAL LOS DELEGATES PARA mapView y para locationManager
        mapView.delegate = self
        //locationManager.delegate = self
        
        // PETICIÓN DE LA DIRECCIÓN ACTUAL Y CARGA LOS DATOS INICIALES
        currentLocation()
        loadInitialData()
    }
    
    // PETICIÓN DE AUTORIZACIÓN Y CARGAR DE LA ACTUALIZACIÓN DE LA DIRECCIÓN
    func currentLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    // CENTRA EL MAPA EN LA LOCALIZACIÓN Y DISTANCIA ESPECIFICADA
    func centerLocation(location: CLLocation, distance: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: distance, longitudinalMeters: distance)
        mapView.setRegion(coordinateRegion, animated: true)

    }
    
    // CARGA LOS DATOS INICIALES DESDE EL ARCHIVO JSON Y LO AÑADE COMO ANOTACIONES AL MAPA
    func loadInitialData() {
        //LEER EL CONTENIDOD EL JSON
        if let url = Bundle.main.url(forResource: "multipleData", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                if let dictionary = object as? [String: AnyObject] {
                    let resources = dictionary["resources"] as! [Any]
                    for resource in resources {
                        let tempResource = resource as! [String: Any]
                        var latResource = Double()
                        var lonResource = Double()
                        if let lat = tempResource["ayto: latitud"] as? String, let lon = tempResource["ayto:longirud"] as? String {
                            latResource = Double(lat) ?? 0.0
                            lonResource = Double(lon) ?? 0.0
                        }
                        let monument = Monument(
                            title: tempResource["ayto: Nombre"] as? String,
                            locationName: tempResource["ayto: Dirección"] as? String,
                            discipline: tempResource["ayto: tipo"] as? String,
                            coordinate: CLLocationCoordinate2D(latitude: latResource, longitude: lonResource)
                        )
                        mapView.addAnnotation(monument)
                    }
                }
            } catch {
                print("Error")
            }
            
        }
    }
}

// IMPLEMENTEACIÓN DE LOS MÉTODOS DE MKMapViewDelegate
extension InitialViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Monument else { return nil }
        let identifier = "monument"
        var view: MKAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            (view as? MKMarkerAnnotationView)?.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
}

// IMPLEMENTACIÓN DE LOS MÉTODOS CLLocationManagerDelegate
/*
extension InitialViewController: CLLocationManagerDelegate {
    // ACTUALIZA EL MAPA PARA CENTRARLO EN LA DIRECCIÓN ACTUAL
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        let currentLocation = location.coordinate
        let coordinateRegion = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(coordinateRegion, animated: true)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
*/
extension InitialViewController: LocationSearchDelegate {
    func locationDidSelect(_ mapItem: MKMapItem) {
        let coordinate = mapItem.placemark.coordinate
        centerLocation(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), distance: initialDistance)
    }
}
