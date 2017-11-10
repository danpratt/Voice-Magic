//
//  RecordSoundsViewController.swift
//  Voice Magic
//
//  Created by Daniel Pratt on 1/18/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import UIKit
import AVFoundation
import StoreKit

protocol AudioRecorder {
    var audioRecorder: AVAudioRecorder! { get }
}

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate, AudioRecorder {

    // UI Buttons
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    // object for dealing with app store reviews
    let rateInAppStore = VMAppStoreReview()
    
    // Instances
    var audioRecorder: AVAudioRecorder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // see if app store review should try to present
        if rateInAppStore.shouldAskToRate {
            SKStoreReviewController.requestReview()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // make sure that the stop button is not enabled when the view is about to appear
        stopRecordingButton.isEnabled = false
    }

    // Action after Record button is pressed
    @IBAction func recordAudio(_ sender: Any) {
        recordSession()
     }

    // action after stop recording button is pressed
    @IBAction func stopRecordingAudioButton(_ sender: Any) {
        setRecordingSessionLabelsAndButtons()
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch {
        showAlert(Alerts.RecordingFailedTitle, message: Alerts.RecordingDisabledMessage)
        }
    }
    
    // MARK: Record audio
    func recordSession() {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        let session = AVAudioSession.sharedInstance()
        session.requestRecordPermission() { allowed in
            DispatchQueue.main.async {
                if allowed {
                    do {
                        try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
                        try self.audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
                        self.setRecordingSessionLabelsAndButtons()
                        self.audioRecorder.delegate = self
                        self.audioRecorder.isMeteringEnabled = true
                        self.audioRecorder.prepareToRecord()
                        self.audioRecorder.record()
                    } catch {
                        self.showAlert(Alerts.AudioSessionError, message: String(describing: Error.self))
                    }
                } else {
                    self.showAlert(Alerts.RecordingDisabledTitle, message: Alerts.RecordingDisabledMessage)
                }
            }
        }
    }
    
    // Checks status of buttons and lables and sets the correctly
    func setRecordingSessionLabelsAndButtons() {
        stopRecordingButton.isEnabled = stopRecordingButton.isEnabled ? false : true
        recordButton.isEnabled = recordButton.isEnabled ? false : true
        recordingLabel.text = recordButton.isEnabled ? "Tap to record" : "Say something: Recording is in progress"
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecordingSegue", sender: audioRecorder.url)
        } else {
            showAlert(Alerts.AudioSessionError, message: String(describing: Error.self))
        }
    }
    
    // Gets ready to send recording over to playSoundsViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecordingSegue" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
    
}

