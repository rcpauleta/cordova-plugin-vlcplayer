import Foundation
import MobileVLCKit

@objc(VLCPlayer) class VLCPlayer: CDVPlugin, VLCMediaPlayerDelegate {
    private var player: VLCMediaPlayer?
    private var containerVC: UIViewController?
    private var videoView: UIView?

    @objc(init:)
    func `init`(_ command: CDVInvokedUrlCommand) {
        // Prepare a simple fullscreen container
        DispatchQueue.main.async {
            let vc = UIViewController()
            vc.view.backgroundColor = .black

            let v = UIView(frame: UIScreen.main.bounds)
            v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            vc.view.addSubview(v)

            self.videoView = v
            self.containerVC = vc

            let result = CDVPluginResult(status: CDVCommandStatus_OK)
            self.commandDelegate.send(result, callbackId: command.callbackId)
        }
    }

    @objc(play:)
    func play(_ command: CDVInvokedUrlCommand) {
        guard let urlString = command.argument(at: 0) as? String,
              let url = URL(string: urlString) else {
            sendError("Invalid URL", command.callbackId); return
        }
        let optsDict = (command.argument(at: 1) as? [String: Any]) ?? [:]
        let caching = (optsDict["networkCaching"] as? Int) ?? 1000

        DispatchQueue.main.async {
            if self.containerVC == nil { self.init(CDVInvokedUrlCommand()) }

            // Present our container if not on screen
            if let root = self.viewController, let vc = self.containerVC, vc.presentingViewController == nil {
                root.present(vc, animated: true, completion: nil)
            }

            // Build VLC player
            let args = ["--network-caching=\(caching)"]
            let p = VLCMediaPlayer(options: args)
            p.delegate = self
            p.drawable = self.videoView

            let media = VLCMedia(url: url)
            p.media = media

            self.player = p
            p.play()

            let ok = CDVPluginResult(status: CDVCommandStatus_OK)
            self.commandDelegate.send(ok, callbackId: command.callbackId)
        }
    }

    @objc(pause:)
    func pause(_ command: CDVInvokedUrlCommand) {
        DispatchQueue.main.async {
            self.player?.pause()
            self.commandDelegate.send(CDVPluginResult(status: .ok), callbackId: command.callbackId)
        }
    }

    @objc(resume:)
    func resume(_ command: CDVInvokedUrlCommand) {
        DispatchQueue.main.async {
            self.player?.play()
            self.commandDelegate.send(CDVPluginResult(status: .ok), callbackId: command.callbackId)
        }
    }

    @objc(seek:)
    func seek(_ command: CDVInvokedUrlCommand) {
        let ms = (command.argument(at: 0) as? NSNumber)?.doubleValue ?? 0
        DispatchQueue.main.async {
            if let length = self.player?.media?.length, length.intValue > 0 {
                // VLC seek uses position 0..1
                let pos = Float(ms / length.doubleValue)
                self.player?.position = pos
            }
            self.commandDelegate.send(CDVPluginResult(status: .ok), callbackId: command.callbackId)
        }
    }

    @objc(position:)
    func position(_ command: CDVInvokedUrlCommand) {
        DispatchQueue.main.async {
            let timeMs = self.player?.time.intValue ?? 0
            let lenMs  = self.player?.media?.length.intValue ?? 0
            let payload: [String: Any] = ["time": timeMs, "length": lenMs]
            let res = CDVPluginResult(status: .ok, messageAs: payload)
            self.commandDelegate.send(res, callbackId: command.callbackId)
        }
    }

    @objc(stop:)
    func stop(_ command: CDVInvokedUrlCommand) {
        DispatchQueue.main.async {
            self.player?.stop()
            self.player = nil
            // Dismiss container
            self.containerVC?.dismiss(animated: true, completion: nil)
            self.containerVC = nil
            self.videoView = nil
            self.commandDelegate.send(CDVPluginResult(status: .ok), callbackId: command.callbackId)
        }
    }

    // Helpers
    private func sendError(_ msg: String, _ cb: String?) {
        let res = CDVPluginResult(status: .error, messageAs: msg)
        self.commandDelegate.send(res, callbackId: cb)
    }
}
