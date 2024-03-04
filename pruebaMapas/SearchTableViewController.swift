//
//  SearchTableViewController.swift
//  pruebaMapas
//
//  Created by Eva Paracuellos on 26/2/24.
//

import UIKit
import MapKit

// DEFINE UNA CLASE QUE CONTROLA SEARCH TABLE VIEW, CON INHERITANCE DE UITableViewController
class SearchTableViewController: UITableViewController {
    // PROPIEDAD DELEGATE PARA COMUNICAR LA SELECCIÓN DE EVENTOS AL COMPONENTE InitialViewController
    weak var delegate: LocationSearchDelegate?

    // ARRAY PARA GUARDAR LOS RESULTADOS
    var matchingItems:[MKMapItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // ESPECIFICA EL NÚMERO DE SECCIONES EN LA VISTA SearchTableViewController, siempre 1
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // ESPECIFICA EL NUMERO DE FILAS, muestra tantas como resultados haya
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    // ASIGNA UNA CELDA A CADA FILA, MOSTRANDO EL NOMBRE DEL LUGAR DE LA BÚSQUEDA
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // REUTILIZA LAS CELDAS
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath as IndexPath)
        // RECOGE EL LUGAR ASOCIADO A LA FILA
        let selectedItem = matchingItems[indexPath.row].placemark
        // ASOCIA EL TEXTO DE LA CELDA AL NOMBRE DEL LUGAR SELECCIONADO
        cell.textLabel?.text = selectedItem.name
        return cell
    }
    
    // SELECCIÓN DE CELDA EL LA VISTA DE LA TABLA
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // RECOGE EL ITEM SELECCINADO BASADO EN LA FILA QUE SE HAYA ESCOGIDO
        let selectedItem = matchingItems[indexPath.row]
        // LLAMA A DELEGATE PARA PASANDO LA SELECCIÓN
        delegate?.locationDidSelect(selectedItem)
        // DESVINCULA EL VIEW CONTROLLER
        dismiss(animated: true, completion: nil)
    }
}

// DEFINE EL PROTOCOLO PARA COMUNICAR LA SELECCIÓN DE UN LUGAR AL COMPONENTE InitialViewController
protocol LocationSearchDelegate: AnyObject {
    func locationDidSelect(_ mapItem: MKMapItem)
}

// PERMITE LE ACTUALIZACIÓN DE LAS CELDAS SEGÚN LA BÚSQUEDA
extension SearchTableViewController: UISearchResultsUpdating {
    // ACTUALIZACIÓN CUANDO EL INPUT DEL BUSCADOR CAMBIA
    func updateSearchResults(for searchController: UISearchController) {
        // REGOGE EL TEXTO DE LA BARRA DE BÚSQUEDA
        let searchBarInput = searchController.searchBar.text
        // PETICIÓN DE BÚSQUEDA BASADA EN EL INPUT DE LA BARRA DE BÚSQUEDA
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarInput
        // ESPECIFICACIÓN DE LA REGIÓN DE BÚSQUEDA
        let coordinates = CLLocationCoordinate2D(latitude: 10.32592768332979, longitude: -85.84202773313018)
        request.region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 500, longitudinalMeters: 500)
        // GENERA LA BÚSQUEDA CON LA PETICIÓN
        let search = MKLocalSearch(request: request)
        search.start {response, _ in
            guard let response = response else {
                return
            }
            print(response)
            // ACTUALIZA LA LOS RESULTADOS DE BÚSQUEDA EN BASE A LA RESPUESTA search
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}
