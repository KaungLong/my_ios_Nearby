//
//  MainViewController.swift
//  NearBy
//
//  Created by 危末狂龍 on 2023/2/2.
//

import UIKit
import MapKit

class MainViewController: UIViewController {

    var locationManager: CLLocationManager?
    private var places: [PlaceAnnotation] = []

    lazy var mapView: MKMapView = {
        let map = MKMapView()
        
        map.showsUserLocation = true
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    lazy var searchTextField: UITextField = {
        let searchTextField = UITextField()
        searchTextField.layer.cornerRadius = 10
        searchTextField.delegate = self
        searchTextField.clipsToBounds = true
        searchTextField.backgroundColor = UIColor.white
        searchTextField.placeholder = "Search"
        searchTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        searchTextField.leftViewMode = .always
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        return searchTextField
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize location manager
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        mapView.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestAlwaysAuthorization()
        locationManager?.requestLocation()
        
        setupUI()
    }
    
    private func setupUI() {
        
        view.addSubview(searchTextField)
        view.addSubview(mapView)
        
        view.bringSubviewToFront(searchTextField)
        
        // add constraints to search text field
        searchTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        searchTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchTextField.widthAnchor.constraint(equalToConstant: view.bounds.size.width/1.2).isActive = true
        searchTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        searchTextField.returnKeyType = .go
        
        // add constraints to the mapView
        mapView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        mapView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager,
              let location = locationManager.location else { return }
        
        switch locationManager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 750, longitudinalMeters: 750)
                mapView.setRegion(region, animated: true)
            case .denied:
                print("Location services has been denied.")
            case .notDetermined, .restricted:
                print("Location cannot be determined or restricted.")
            @unknown default:
                print("Unknown error. Unable to get location.")
        }
    }
    
    private func presentPlacesSheet(places: [PlaceAnnotation]) {
        
        guard let locationManager = locationManager,
        let userLocation = locationManager.location
        else { return }
        
        let placesTVC = PlacesTableViewController(userLocation: userLocation, places: places)
        placesTVC.modalPresentationStyle = .pageSheet
        
        if let sheet = placesTVC.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.detents = [.medium(), .large()]
            present(placesTVC, animated: true)
        }
    }
    
    private func findNearbyPlaces(by query: String) {
        
        // clear all annotations
        mapView.removeAnnotations(mapView.annotations)
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            
            guard let response = response, error == nil else { return }
            
            self?.places = response.mapItems.map(PlaceAnnotation.init)
            self?.places.forEach { place in
                self?.mapView.addAnnotation(place)
            }
            
            if let places = self?.places {
                self?.presentPlacesSheet(places: places)
            }
           
        }
        
    }
}


extension MainViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let text = textField.text ?? ""
        if !text.isEmpty {
            textField.resignFirstResponder()
            // find nearby places
            findNearbyPlaces(by: text)
        }
        
        return true
    }
}

extension MainViewController: MKMapViewDelegate {
    
    private func clearAllSelections() {
        self.places = self.places.map { place in
            place.isSelected = false
            return place
        }
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("GGG")
                // clear all selections
                clearAllSelections()
                print("HHHH")
        guard let selectionAnnotation = view.annotation as? PlaceAnnotation else { return }
                let placeAnnotation = self.places.first(where: { $0.id == selectionAnnotation.id })
                placeAnnotation?.isSelected = true

                presentPlacesSheet(places: self.places)
    }
    
}


extension MainViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}

