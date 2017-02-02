//
//  RecordSoundsViewController.swift
//  Voice Magic
//
//  Created by Daniel Pratt on 1/18/17.
//  Copyright © 2017 Daniel Pratt. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    // UI Buttons
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    // Instances
    var audioRecorder: AVAudioRecorder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear called")
        stopRecordingButton.isEnabled = false
    }

    @IBAction func recordAudio(_ sender: Any) {
        
        // Record audio
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
                        self.stopRecordingButton.isEnabled = true
                        self.recordButton.isEnabled = false
                        self.recordingLabel.text = "Say something: Recording is in progress"
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

    @IBAction func stopRecordingAudioButton(_ sender: Any) {
        stopRecordingButton.isEnabled = false
        recordButton.isEnabled = true
        recordingLabel.text = "Tap to record"
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch {
        showAlert(Alerts.RecordingFailedTitle, message: Alerts.RecordingDisabledMessage)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecordingSegue", sender: audioRecorder.url)
        } else {
            showAlert(Alerts.AudioSessionError, message: String(describing: Error.self))
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecordingSegue" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
    
}

