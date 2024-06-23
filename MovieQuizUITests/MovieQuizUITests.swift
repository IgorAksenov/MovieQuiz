//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by  Игорь on 18.06.2024.
//




import XCTest

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Убедитесь, что инициализация проходит успешно
        app = XCUIApplication()
        guard app != nil else {
            XCTFail("Failed to initialize XCUIApplication")
            return
        }
        app.launch()
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Убедитесь, что приложение завершено корректно
        if app != nil {
            app.terminate()
        }
        app = nil
        
        try super.tearDownWithError()
    }

    func testYesButton(){
        sleep(3)
           
           let firstPoster = app.images["Poster"]
           let firstPosterData = firstPoster.screenshot().pngRepresentation
           
           app.buttons["Yes"].tap()
           sleep(3)
           
           let secondPoster = app.images["Poster"]
           let secondPosterData = secondPoster.screenshot().pngRepresentation
           
           XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    func testNoButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        let indexLabel = app.staticTexts["Index"]
       
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    func testGameFinish() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }

        let alert = app.alerts["GameResultsAlert"]
        
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Пройти еще раз")
    }

    func testAlertDismiss() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["GameResultsAlert"]
        alert.buttons.firstMatch.tap()
        
        sleep(2)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
}

