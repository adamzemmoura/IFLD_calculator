//
//  ViewController.swift
//  IFLD Calculator
//
//  Created by Adam Zemmoura on 01/05/2017.
//  Copyright © 2017 Adam Zemmoura. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

enum FlapSelection: Int {
    case twenty = 20
    case twentyFive = 25
    case thirty = 30
}

enum ReverseSelection: Int {
    case none = 0
    case one = 1
    case both = 2
}

enum TickOrCross: String {
    case tick = "✅"
    case cross = "❌"
}

class ViewController: UIViewController {
    
    private var databaseRef: FIRDatabaseReference!
    private var databaseHandle: FIRDatabaseHandle!
    
    private func setUpDatabase() {
        FIRDatabase.database().persistenceEnabled = true
        databaseRef = FIRDatabase.database().reference()
        databaseHandle = FIRDatabaseHandle()
        
        databaseRef.observe(.value, with: { (snapshot) in
            self.airportData.updateWith(snapshot: snapshot)
        })
        
    }
    
    enum PickerViewTag: Int {
        case windPicker = 1
        case tempPicker = 2
        case runwayPicker = 3
        case runwayConditionPicker = 4
    }
    
    enum TextFieldTag: Int {
        case airport = 20
        case weight = 21
    }
    
    enum TableViewTag: Int {
        case airport = 30
        case aircraftVariant = 31
    }
    
    // Data model
    fileprivate var landingDistanceCalculator = LandingDistanceCalculator()
    
    fileprivate var airportData = AirportData() 
    fileprivate var airports: [Airport]! {
        didSet {
            airportTableView.reloadData()
        }
    }
    
    fileprivate let runwayConditions = ["dry", "good", "good-med", "med", "med-poor", "poor"]
    
    // MARK: User Selections
    fileprivate var selectedAirport: Airport? = nil {
        didSet {
            airportTextField.text = selectedAirport?.name
            runwayPicker.reloadAllComponents()
            resetRunwayDetails()
        }
    }
    
    fileprivate var filteredAirports = [Airport]() {
        didSet {
            airportTableView.reloadData()
        }
    }
    
    fileprivate var selectedRunway: Runway? = nil
    
    private var flapSelection: FlapSelection = .twentyFive {
        didSet {
            if flapSelection == .twenty {
                alertWithMessage("App does not yet support F20 landing.\n\nPlease select another flap setting.")
            }
        }
    }
    private var reverseSelection: ReverseSelection = .both
    
    fileprivate var weightSelection: Int? = nil {
        didSet {
            print("\(weightSelection)")
        }
    }
    fileprivate var windSelection: (direction: Int, speed: Int) = (180,10) // default value
    fileprivate var tempSelection: Int = 15 // default value - ISA
    fileprivate var runwayCondition: String {
        let currentRowIndex = runwayConditionPicker.selectedRow(inComponent: 0)
        return runwayConditions[currentRowIndex]
    }
    
    // Properties
    
    fileprivate var landingDistances: [Int]? = nil {
        didSet {
            if landingDistances != nil {
                updateDistanceLabelsWith(landingDistances!)
                updateTickOrCrossLabels(with: landingDistances)
            }
        }
    }
    
    fileprivate var safetyMarginApplied: Bool = false
    
    fileprivate var landingDistancesWithSafetyMargins: [Int]? = nil {
        didSet {
            if landingDistancesWithSafetyMargins != nil {
                safetyMarginApplied = true
                updateDistanceLabelsWith(landingDistancesWithSafetyMargins!)
                updateTickOrCrossLabels(with: landingDistancesWithSafetyMargins)
            }
            else {
                safetyMarginApplied = false
                if landingDistances != nil {
                    updateDistanceLabelsWith(landingDistances!)
                    updateTickOrCrossLabels(with: landingDistances)
                }
            }
        }
    }
    
    fileprivate var userIsCurrentlyEditingAirport = false
    
    fileprivate var resultsDisplayed: Bool = false {
        didSet {
            if resultsDisplayed {
                calculateButton.isHidden = true
            }
            if !resultsDisplayed {
                calculateButton.isHidden = false
            }
        }
    }
    
    fileprivate var somethingOnTheUIChanged: Bool = true {
        didSet {
            if somethingOnTheUIChanged && resultsDisplayed {
                calculateButtonPressed()
            }
        }
    }
    
    fileprivate var degrees: [Int] {
        get {
            var degrees = [Int]()
            for i in 0...360 {
                if i % 10 == 0 {
                    degrees.append(i)
                }
            }
            return degrees
        }
    }
    
    fileprivate var knots: [Int] {
        get {
            var knots = [Int]()
            for i in 0...50 {
                knots.append(i)
            }
            return knots
        }
    }
    
    fileprivate var windData: [[Int]] {
        get {
            return [degrees,knots]
        }
    }
    
    fileprivate var tempratureRange: [Int] {
        get {
            var temps = [Int]()
            for i in -30...50 {
                temps.append(i)
            }
            return temps
        }
    }
    
    fileprivate var pressureRange : [Int] {
        get {
            var pressures = [Int]()
            for i in 970...1040 {
                pressures.append(i)
            }
            return pressures
        }
    }
    
    // MARK: Outlets
    
    // Aircraft
    @IBOutlet weak var flapSelectionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var weightTextField: UITextField!
    
    @IBOutlet weak var reverseSelectionSegmentedControl: UISegmentedControl!
    
    // Weather
    @IBOutlet weak var windPicker: UIPickerView!
    @IBOutlet weak var tempPicker: UIPickerView!
    @IBOutlet weak var runwayConditionPicker: UIPickerView!
    
    // Airport & Runway
    @IBOutlet weak var runwayStack: UIStackView!
    @IBOutlet weak var runwayPicker: UIPickerView!
    @IBOutlet weak var slopeLabel: UILabel!
    @IBOutlet weak var elevationLabel: UILabel!
    @IBOutlet weak var airportTextField: UITextField!
    @IBOutlet weak var airportTableView: UITableView!
    @IBOutlet weak var runwayDetailStack: UIStackView!
    @IBOutlet weak var airportTextFieldCancelButton: UILabel!
    
    
    @IBOutlet weak var LDALabel: UILabel!
    
    // Wind Components
    
    @IBOutlet weak var windStack: UIStackView!
    @IBOutlet weak var headTailStack: UIStackView!
    @IBOutlet weak var headTailWindLabel: UILabel!
    @IBOutlet weak var crosswindStack: UIStackView!
    @IBOutlet weak var crosswindLabel: UILabel!
    @IBOutlet weak var headTailWindTitleLabel: UILabel!
    @IBOutlet weak var crosswindWarningLabel: UILabel!
    
    // Landing Distances
    @IBOutlet weak var resultsStack: UIStackView!
    @IBOutlet weak var autobrakeMaxDistance: UILabel!
    @IBOutlet weak var autobrake4Distance: UILabel!
    @IBOutlet weak var autobrake3Distance: UILabel!
    @IBOutlet weak var autobrake2Distance: UILabel!
    @IBOutlet weak var autobrake1Distance: UILabel!
    
    @IBOutlet weak var tickOrCrossStack: UIStackView!
    @IBOutlet weak var maxTickOrCross: UILabel!
    @IBOutlet weak var fourTickOrCross: UILabel!
    @IBOutlet weak var threeTickOrCross: UILabel!
    @IBOutlet weak var twoTickOrCross: UILabel!
    @IBOutlet weak var oneTickOrCross: UILabel!
    
    // Saftey Margin
    @IBOutlet weak var safetyMarginStack: UIStackView!
    @IBOutlet weak var safetyMarginLabelsStack: UIStackView!
    @IBOutlet weak var safteyMarginSlider: UISlider!
    @IBOutlet weak var safetyMarginInfo: UIImageView!
    
    // Calculate button
    @IBOutlet weak var calculateButton: UIButton!
    
    // Engine Variant
    @IBOutlet weak var aircraftVariantLabel: UILabel!
    @IBOutlet weak var aircraftVariantTable: UITableView!
    
    
    // MARK: Actions
    
    @IBAction func engineVariantTapped(_ sender: UITapGestureRecognizer) {
        shouldShowAircraftVariantTable(true)
    }
    
    
    @IBAction func userTappedSafetyInfo(_ sender: UITapGestureRecognizer) {
        let title = "Info"
        let message = "Landing distances already include a 15% safety margin."
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        ac.addAction(okAction)
        present(ac, animated: true, completion: nil)
    }
    
    
    @IBAction func userTappedAirportTextFieldCancelButton(_ sender: UITapGestureRecognizer) {
        print("tap recognised")
        
    }
    @IBAction func safetyMarginChanged(_ sender: UISlider) {
        
        let value = sender.value
        
        if value > 0 && value < 0.165 {
            safteyMarginSlider.setValue(0, animated: true)
        }
        else if value >= 0.165 && value < 0.33 {
            safteyMarginSlider.setValue(0.33, animated: true)
        }
        else if value >= 0.33 && value < 0.495 {
            safteyMarginSlider.setValue(0.33, animated: true)
        }
        else if value >= 0.495 && value < 0.66 {
            safteyMarginSlider.setValue(0.66, animated: true)
        }
        else if value >= 0.66 && value < 0.825 {
            safteyMarginSlider.setValue(0.66, animated: true)
        }
        else if value >= 0.825 && value < 1.0 {
            safteyMarginSlider.setValue(1.0, animated: true)
        }
        
        let newValue = safteyMarginSlider.value
        
        var safetyMargin = 0.0
        
        if newValue == 0 {
            safetyMargin = 0
            landingDistancesWithSafetyMargins = nil
        }
        else if newValue == 0.33 {
            safetyMargin = 1.1
        }
        else if newValue == 0.66 {
            safetyMargin = 1.15
        }
        else if newValue == 1 {
            safetyMargin = 1.2
        }
        
        applySafetyMarginToDistances(safetyMargin: safetyMargin)
    }
    
    private func applySafetyMarginToDistances(safetyMargin margin: Double) {
        
        guard let _ = landingDistances else { return }
        
        if margin == 0 { return }
        
        var newDistances = [Int]()
        
        for distance in landingDistances! {
            let newDistance = Double(distance) * margin
            newDistances.append(Int(newDistance.rounded()))
        }
        
        landingDistancesWithSafetyMargins = newDistances
        
    }
    
    
    @IBAction func calculateButtonPressed() {
        
        if allowCalculateButtonToBePressed() {
        
            view.endEditing(true)
            somethingOnTheUIChanged = false
            showResults()
            getCurrentSelections()
        
            
        }
        else {
            let ac = UIAlertController(title: "Cannot perform calculation",
                                       message: "\nNot enough information.\n\nMake sure you have selected an airport, runway & entered a weight",
                                       preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
            ac.addAction(okAction)
            
            present(ac, animated: true, completion: nil)
        }
    }
    
    private func allowCalculateButtonToBePressed() -> Bool {
        if weightSelection != nil && selectedAirport != nil && selectedRunway != nil {
            return true
        }
        else {
            return false
        }
    }
    
    @IBAction func flapSelectionChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        let flapSetting = sender.titleForSegment(at: index)!
        flapSelection = FlapSelection(rawValue: Int(flapSetting)!)!
        somethingOnTheUIChanged = true
    }
    
    @IBAction func reverseSelectionChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        let title = sender.titleForSegment(at: index)!
        if title == "None" {
            reverseSelection = .none
        }
        else {
            reverseSelection = ReverseSelection(rawValue: Int(title)!)!
        }
        somethingOnTheUIChanged = true
    }
    
    
    // MARK: Instance Methods
    fileprivate func shouldShowAircraftVariantTable(_ bool: Bool) {
        aircraftVariantTable.isHidden = !bool
    }
    
    
    private func resetRunwayDetails() {
        runwayPicker.selectRow(0, inComponent: 0, animated: true)
        selectedRunway = nil
        resetRunwayLabels()
    }
    
    private func alertWithMessage(_ message: String) {
        let ac = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        let selectF25Action = UIAlertAction(title: "F25", style: .default) { (action) in
            self.flapSelection = .twentyFive
            self.flapSelectionSegmentedControl.selectedSegmentIndex = 1 // sets 25 in UI
            print("Flap\(self.flapSelection) selected")
        }
        let selectF30Action = UIAlertAction(title: "F30", style: .default) { (action) in
            self.flapSelection = .thirty
            self.flapSelectionSegmentedControl.selectedSegmentIndex = 2 // sets 30 in UI
            print("FLap\(self.flapSelection) selected")
        }
        
        ac.addAction(selectF25Action)
        ac.addAction(selectF30Action)
        
        present(ac, animated: true, completion: nil)
    }
    
    private func getCurrentSelections() {
        
        var selections = [ String : Int ]()

        selections[Selection.flapSelection] = flapSelection.rawValue
        if let weightSelection = weightSelection {
            selections[Selection.weightSelection] = weightSelection
        }
        selections[Selection.reverseSelection] = reverseSelection.rawValue
        selections[Selection.windDirectionSelection] = windSelection.direction
        selections[Selection.windSpeedSelection] = windSelection.speed
        selections[Selection.tempSelection] = tempSelection
        
        if let runway = selectedRunway {
            landingDistances = landingDistanceCalculator.calculateDistanceFor(runway: runway, condition:runwayCondition, withSelections: selections)
        
        }
        
        // TODO: implement error handling, such that method cannot be called if not enough info.
        
    }
    
    fileprivate func updateDistanceLabelsWith(_ distances: [Int]) {
        if distances.count == 5 {
            autobrakeMaxDistance.text =
                String(distances[0])
            autobrake4Distance.text = String(distances[1])
            autobrake3Distance.text = String(distances[2])
            autobrake2Distance.text = String(distances[3])
            autobrake1Distance.text = String(distances[4])
        }
    }
    
    fileprivate func updateTickOrCrossLabels(with landingDistances: [Int]?) {
        var count = 0
        
        guard let landingDistances = landingDistances else { return }
        
        for distance in landingDistances {
            if distance >= selectedRunway!.distance {
                if count == 0 {
                  maxTickOrCross.text = TickOrCross.cross.rawValue
                }
                if count == 1 {
                    fourTickOrCross.text = TickOrCross.cross.rawValue
                }
                if count == 2 {
                    threeTickOrCross.text = TickOrCross.cross.rawValue
                }
                if count == 3 {
                    twoTickOrCross.text = TickOrCross.cross.rawValue
                }
                if count == 4 {
                    oneTickOrCross.text = TickOrCross.cross.rawValue
                }
            }
            else if distance <= selectedRunway!.distance {
                if count == 0 {
                    maxTickOrCross.text = TickOrCross.tick.rawValue
                }
                if count == 1 {
                    fourTickOrCross.text = TickOrCross.tick.rawValue
                }
                if count == 2 {
                    threeTickOrCross.text = TickOrCross.tick.rawValue
                }
                if count == 3 {
                    twoTickOrCross.text = TickOrCross.tick.rawValue
                }
                if count == 4 {
                    oneTickOrCross.text = TickOrCross.tick.rawValue
                }
            }
            count += 1
            
        }
    }
    
    private func showResults() {
        resultsDisplayed = true
        windStack.isHidden = false
        resultsStack.isHidden = false
        tickOrCrossStack.isHidden = false
    }
    
    private func hideResults() {
        resultsDisplayed = false
        windStack.isHidden = true
        resultsStack.isHidden = true
        tickOrCrossStack.isHidden = true
        
    }
    
    fileprivate func updateRunwayLabelsFor(runway: Runway) {
        
        slopeLabel.text = String(runway.slope)
        elevationLabel.text = String(runway.elevation)
        LDALabel.text = String(runway.distance)
        
    }
    
    fileprivate func resetRunwayLabels() {
        slopeLabel.text = "----"
        elevationLabel.text = "----"
        LDALabel.text = "----"
    }
    
    private func setUpPickers() {
        // Wind picker
        let index = windData[0].count / 2
        windPicker.selectRow(index, inComponent: 0, animated: true)
        windPicker.selectRow(10, inComponent: 1, animated: true)
        
        // Temp picker
        tempPicker.selectRow(45, inComponent: 0, animated: true)
    
    }
    
    fileprivate func showAirportTable() {
        UIView.animate(withDuration: 0.3) { 
            self.airportTableView.isHidden = false
            self.runwayDetailStack.isHidden = true
        }
    }
    
    fileprivate func hideAirportTable() {
        UIView.animate(withDuration: 0.3) {
            self.airportTableView.isHidden = true
            self.runwayDetailStack.isHidden = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    // MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpDatabase()
        
        // set up airport data model 
        airportData.delegate = self
        airports = airportData.airports
        
        airportTableView.delegate = self
        
        // Initial set up of UI
        resultsStack.isHidden = true
        windStack.isHidden = true
        tickOrCrossStack.isHidden = true
        airportTableView.isHidden = true
        crosswindWarningLabel.isHidden = true
        
        calculateButton.layer.cornerRadius = 5.0 // round corners of the button
        shouldShowAircraftVariantTable(false)
        
        setUpPickers()
    
    }
    
    override func viewDidLayoutSubviews() {
        landingDistanceCalculator.delegate = self
    }
    
    deinit {
        databaseRef.removeAllObservers()
    }
}

// MARK: UIPickerViewDataSource & UIPickerViewDelegate
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        guard let tag = PickerViewTag(rawValue: pickerView.tag) else { return nil }
        
        switch tag {
            case .windPicker :
                let data = windData[component][row]
                var dataAsString = String(data)
                // if compass direction ie. component 0 , add preceding zero if required.
                if component == 0 {
                    dataAsString = formatWindData(from: dataAsString)
                }
                return dataAsString
            case .tempPicker:
                return String(tempratureRange[row])
            case .runwayPicker :
                if let selectedAirport = selectedAirport {
                    if row == 0 {
                        return "select"
                    }
                    return selectedAirport.runways[row-1].name
                }
                return "-----"
            case .runwayConditionPicker :
                return runwayConditions[row]
            }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let tag = PickerViewTag(rawValue: pickerView.tag)!
        
        switch tag {
        case .runwayPicker :
            if row != 0 {
                selectedRunway = selectedAirport!.runways[row-1]
                if selectedRunway != nil {
                    updateRunwayLabelsFor(runway: selectedRunway!)
                    if resultsDisplayed {
                        
                        updateTickOrCrossLabels(with: landingDistances)
                        
                    }
                    somethingOnTheUIChanged = true
                } else {
                    resetRunwayLabels()
                }
            }
        case .windPicker :
            var direction: Int = windSelection.direction

            var speed: Int = windSelection.speed
            
            if component == 0 {
                direction = windData[component][row]
            }
            else if component == 1 {
                speed = windData[component][row]
            }
            
            windSelection = (direction, speed)
            somethingOnTheUIChanged = true
        case .tempPicker :
            tempSelection = tempratureRange[row]
            somethingOnTheUIChanged = true
        case .runwayConditionPicker :
            somethingOnTheUIChanged = true
        }
    }
    
    // Takes a wind direction and adds zeros where necessary eg. 2 becomes 020, 35 becomes 035.
    private func formatWindData(from data: String) -> String {
        var formattedString = data
        let charCount = data.characters.count
        
        if charCount == 1 {
            formattedString = "0" + formattedString + "0"
        }
        if charCount == 2 {
            formattedString = "0" + formattedString
        }
        return formattedString
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        guard let tag = PickerViewTag(rawValue: pickerView.tag) else { return 0 }
        
        switch tag {
            case .windPicker : return 2
            case .tempPicker : return 1
            case .runwayPicker : return 1
            case .runwayConditionPicker : return 1
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let tag = PickerViewTag(rawValue: pickerView.tag) else { return 0 }
        
        switch tag {
            case .windPicker:
                if component == 0 {
                    return windData[component].count
                }
                else if component == 1 {
                    return knots.count // up to 60 knots
                }
            case .tempPicker :
                return tempratureRange.count
            case .runwayConditionPicker :
                return runwayConditions.count
            default:
                if let selectedAirport = selectedAirport {
                    return selectedAirport.runways.count + 1
                }
                return 1 // to show default message
        }
        
        return 0
    }
    
}

// MARK: UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        guard let tag = TextFieldTag(rawValue: textField.tag) else { return false }
        
        switch tag {
        case .airport :
            var searchText = ""
            if let text = textField.text {
                searchText = text + string
                searchText = searchText.lowercased()
                if searchText.characters.count == 1 && string == "" {
                    userIsCurrentlyEditingAirport = false
                    airportTableView.reloadData()
                }
                else {
                    userIsCurrentlyEditingAirport = true
                }
            }
            
            filteredAirports = [Airport]()
            for airport in airports {
                let name = airport.name.lowercased()
                if name.contains(searchText) {
                    filteredAirports.append(airport)
                }
            }
            
            return true
        case .weight :
            
            let exisitingTextContainsDecimal = textField.text?.contains(".") ?? false
            let newTextContainsDecimal = string.contains(".")
            
            if exisitingTextContainsDecimal && newTextContainsDecimal {
                return false
            }
            
            if exisitingTextContainsDecimal {
                let charsAfterDecimal = textField.text!.components(separatedBy: ".").last!
                if charsAfterDecimal.characters.count > 0 {
                    return false
                }
            }
            
            return true

        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let tag = TextFieldTag(rawValue: textField.tag) else { return }
        
        switch tag {
        case .airport :
            resultsStack.isHidden = true
            tickOrCrossStack.isHidden = true
            windStack.isHidden = true
            crosswindWarningLabel.isHidden = true
            resultsDisplayed = false
            landingDistancesWithSafetyMargins = nil
            
            
            showAirportTable()
        case .weight :
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        somethingOnTheUIChanged = true
        guard let tag = TextFieldTag(rawValue: textField.tag) else { return }
        
        switch tag {
        case .airport :
            userIsCurrentlyEditingAirport = false
            hideAirportTable()
        case .weight :
            if let text = textField.text, text != "" {
                var weightAsDouble = 0.0
                
                if text.contains(".") {
                    weightAsDouble = Double(text)!
                    weightAsDouble = weightAsDouble.rounded()
                    weightSelection = Int(weightAsDouble)
                }
                else {
                    weightSelection = Int(text)!
                }
                
                weightTextField.text = String(weightSelection!)
            }
        }
    }

}

// MARK: UITableView Delegate & DataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let tag = TableViewTag(rawValue: tableView.tag)!
        
        switch tag {
        case .airport:
            if userIsCurrentlyEditingAirport {
                return filteredAirports.count
            }
            return airports.count
        case .aircraftVariant:
            return AircraftVariants.variants.count
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tag = TableViewTag(rawValue: tableView.tag)!
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AirportCell", for: indexPath)
        
        switch tag {
            
        case .airport:
            if userIsCurrentlyEditingAirport {
                cell.textLabel?.text = filteredAirports[indexPath.row].name
            }
            else {
                cell.textLabel?.text = airports[indexPath.row].name
            }
            
        case .aircraftVariant:
            
            cell.textLabel?.text = AircraftVariants.variants[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let tag = TableViewTag(rawValue: tableView.tag)!
        
        switch tag {
        case .airport :
            selectedAirport = nil
            
            if userIsCurrentlyEditingAirport {
                print("didSelect : \(filteredAirports[indexPath.row].name)")
                selectedAirport = filteredAirports[indexPath.row]
                
            }
            else {
                print("didSelect : \(airports[indexPath.row].name)")
                selectedAirport = airports[indexPath.row]
                
            }
            view.endEditing(true)
            hideAirportTable()
            somethingOnTheUIChanged = true
            resultsStack.isHidden = true
            tickOrCrossStack.isHidden = true
            windStack.isHidden = true
            crosswindWarningLabel.isHidden = true
            resultsDisplayed = false
            
        case .aircraftVariant:
            print("\(AircraftVariants.variants[indexPath.row]) selected")
            let variant = AircraftVariant(rawValue: AircraftVariants.variants[indexPath.row])!
            switch variant {
            case .twoHundreds:
                aircraftVariantLabel.text = "\(AircraftVariants.variants[indexPath.row])"
            default:
                alertWithMessage(message: "App does not currently support \(variant.rawValue).\nComing soon...")
                aircraftVariantLabel.text = AircraftVariant.twoHundreds.rawValue
            }
            shouldShowAircraftVariantTable(false)
            
        }
    }
    
    private func alertWithMessage(message: String) {
        let ac = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        ac.addAction(okayAction)
        present(ac, animated: true, completion: nil)
    }
    
}

extension ViewController: LandingDistanceCalculatorDelegate {
    func landingDistanceCalculatorHasCalculated(windComponents: [(component: WindComponent, knots: Double)]) {
        for wind in windComponents {
            print("\(wind.component.rawValue) : \(wind.knots)kts")
            
            if windComponents.count == 1 {
                let component = wind.component
                switch component {
                case .crosswind :
                    headTailStack.isHidden = true
                    crosswindStack.isHidden = false
                    if wind.knots > (40.0 * 0.66) {
                        crosswindWarningLabel.text = "WARNING: Crosswind > 26.4 KT - Out of co-pilot limits"
                        crosswindWarningLabel.isHidden = false
                    } else {
                        crosswindWarningLabel.isHidden = true
                    }
                    let roundedKnots = wind.knots.rounded()
                    crosswindLabel.text = "\(Int(roundedKnots)) Kts"
                case .headwind :
                    crosswindStack.isHidden = true
                    crosswindWarningLabel.isHidden = true
                    headTailStack.isHidden = false
                    let roundedKnots = wind.knots.rounded()
                    headTailWindTitleLabel.text = "Headwind :"
                    headTailWindLabel.text = "\(Int(roundedKnots)) Kts"
                case .tailwind:
                    if wind.knots == 15 {
                        crosswindWarningLabel.text = "WARNING: Tailwind is on limits."
                        crosswindWarningLabel.isHidden = false
                    }
                    else if wind.knots > 15 {
                        crosswindWarningLabel.text = "WARNING: Tailwaind > 15KT - Out of limits."
                        crosswindWarningLabel.isHidden = false
                    } else {
                        crosswindWarningLabel.isHidden = true
                    }
                    crosswindStack.isHidden = true
                    headTailStack.isHidden = false
                    let roundedKnots = wind.knots.rounded()
                    headTailWindTitleLabel.text = "Tailwind :"
                    headTailWindLabel.text = "\(Int(roundedKnots)) Kts"
                }
                
            }
            
            if windComponents.count == 2 {
                headTailStack.isHidden = false
                crosswindStack.isHidden = false
                let component = wind.component
                switch component {
                    case .crosswind :
                        if wind.knots > (40.0 * 0.66) {
                            crosswindWarningLabel.text = "WARNING: Crosswind > 26.4 KT - Out of co-pilot limits"
                            crosswindWarningLabel.isHidden = false
                        } else {
                            crosswindWarningLabel.isHidden = true
                        }
                        let roundedKnots = wind.knots.rounded()
                        crosswindLabel.text = "\(Int(roundedKnots)) Kts"
                    case .headwind :
                        let roundedKnots = wind.knots.rounded()
                        headTailWindTitleLabel.text = "Headwind :"
                        headTailWindLabel.text = "\(Int(roundedKnots)) Kts"
                    case .tailwind:
                        if wind.knots > 15 {
                            crosswindWarningLabel.text = "WARNING: Tailwaind > 15KT - Out of limits."
                            crosswindWarningLabel.isHidden = false
                        }
                        let roundedKnots = wind.knots.rounded()
                        headTailWindTitleLabel.text = "Tailwind :"
                        headTailWindLabel.text = "\(Int(roundedKnots)) Kts"
                }
            }
        }
    }
}

extension ViewController: AirportDataDelegate {
    func airportDatabaseUpdatedWith(airports: [Airport]) {
        self.airports = airports
    }
}

