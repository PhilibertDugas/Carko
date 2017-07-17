import UIKit
import GooglePlaces
import Crashlytics

protocol HandleMapSearch: class {
    func selectedPlace(place: GMSPlace)
}

class LocationSearchTableViewController: UITableViewController {
    var searchResult: [GMSAutocompletePrediction] = []
    var handleMapSearchDelegate: HandleMapSearch?
    var lightText = false

    override func viewDidLoad() {
        tableView.backgroundColor = UIColor.clear
    }
}

extension LocationSearchTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //
    }

    func updateSearchs(for queryString: String?) {
        guard let searchBarText = queryString else { return }
        let filter = GMSAutocompleteFilter.init()
        filter.country = "CA"
        filter.type = .address
        GMSPlacesClient.shared().autocompleteQuery(searchBarText, bounds: nil, filter: filter) { (results, error) in
            if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            } else if let results = results {
                self.searchResult = results
                self.tableView.reloadData()
            }
        }
    }
}

extension LocationSearchTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResult.count
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.init(0.01)
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init(frame: CGRect.zero)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SimpleCellTableViewCell
        cell.backgroundColor = UIColor.clear
        let selectedItem = searchResult[indexPath.row]
        cell.titleLabel.text = selectedItem.attributedPrimaryText.string
        cell.subtitleLabel.text = selectedItem.attributedSecondaryText?.string
        if self.lightText {
            cell.titleLabel.textColor = UIColor.white
            cell.subtitleLabel.textColor = UIColor.white
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = searchResult[indexPath.row]
        guard let placeId = selectedItem.placeID else { return }
        GMSPlacesClient.shared().lookUpPlaceID(placeId) { (place, error) in
            if let error = error {
                super.displayErrorMessage(error.localizedDescription)
                Crashlytics.sharedInstance().recordError(error)
            } else if let place = place {
                self.handleMapSearchDelegate?.selectedPlace(place: place)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
